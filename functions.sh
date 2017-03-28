# A collection of handy functions.

source general.sh

### git

# grab single file from GH Enterprise
git_e_file () {
  if [ -z $1 ]; then
    echo "Provide repo path in format: org/repo/path/to/file"
  else
    repo=$(echo "$1" | cut -d '/' -f -2)
    rfile=$(echo "$1" | cut -d '/' -f 3-)
    if [ -z $user ] || [ -z $pass ]; then
      read -p "Username: " user
      read -s -p "Password: " pass
    fi
    curl -k -X GET -O -L \
      "https://github.starbucks.net/api/v3/repos/$repo/contents/$rfile" \
      -H "Accept: application/vnd.github.v3.raw" \
      -u $user:$pass
    echo 'Done. File in current directory. Credentials cached in $user:$pass variables...'
  fi
}

### AWS

# bog shortcut for switching accounts
bog_switch () {
  if [ -z $(command -v bog) ]; then
    echo "bog not found."
  else
    if [ -z $1 ]; then
      echo 'Provide bog account to switch to as argument. bog list:'
      bog -l
    else
      bog $1
      aws_env_vars
    fi
  fi
}

# enable AWS CLI tab completion!
complete -C $(which aws_completer) aws

aws_ec2_list () {
  if [ -z $1 ]; then
    echo "INFO: Optionally provide region as argument. Default is current configured."
  else
    region="--region $1"
  fi

  jq_filter='PublicDnsName,VpcId,InstanceId,KeyName,InstanceType,State,ImageId,SubnetId,LaunchTime'
  aws ec2 describe-instances $region | jq -S \
    ".|.Reservations[]|.Instances[]|{$jq_filter}"
}

aws_ec2_images () {
  aws ec2 describe-images --owner "self" | jq -S ".|.Images[]|{ \
    Name,ImageId,Platform,Description, \
    SnapshotId:(.BlockDeviceMappings[].Ebs.SnapshotId), \
    VolumeSize:(.BlockDeviceMappings[].Ebs.VolumeSize)}"
}

# launch an instance with args
aws_ec2_run () {
  # defaults
  itype='t2.micro'
  key='adamthepatterson_rsa'
  ami='ami-3d2cce5d'
  count=1

  if [ -z $1 ]; then
    echo 'Instance type as $1 minimum req arg.  Positional args [defaults]:'
    echo "  aws_ec2_run \$itype [$itype] \$key [$key] \$ami [$ami] \$count [$count]"
  else
    itype=$1
    if [ ! -z $2 ]; then key=$2; fi
    if [ ! -z $3 ]; then ami=$3; fi
    if [ ! -z $4 ]; then count=$4; fi

    jq_filter='State,VpcId,InstanceId,KeyName,SecurityGroups,InstanceType,Placement'
    aws ec2 run-instances \
      --image-id $ami \
      --instance-type $itype \
      --key-name $key \
      --count $count \
      --security-groups "ssh-anywhere" "web-anywhere" | jq -S \
        ".|.Instances[]|{$jq_filter}"
  fi
}

# spin up some micros, specify count via $1
aws_ec2_run_micro () {
  if [ -z $1 ]; then key='adamthepatterson_rsa'; else key=$1; fi
  if [ -z $2 ]; then count=1; else count=$2; fi
  jq_filter='State,VpcId,InstanceId,KeyName,SecurityGroups,InstanceType,Placement'
  aws ec2 run-instances \
    --image-id ami-3d2cce5d \
    --instance-type t2.micro \
    --key-name $key \
    --count $count \
    --security-groups "ssh-anywhere" "web-anywhere" | jq -S \
      ".|.Instances[]|{$jq_filter}"
}

# get public IP for an instance
aws_ec2_ip () {
  aws ec2 describe-instances --instance-ids $1 | jq '.|.Reservations[]|.Instances[]|.PublicDnsName'
}

# takes parameter of EC2 instance ID to terminate
aws_ec2_terminate () {
  read -r -p "Terminate instance, $1, are you sure? [Y/n]" response
  if [[ $response =~ ^(yes|y| ) ]] || [ -z $response ]; then
    aws ec2 terminate-instances --instance-ids $1 | jq .
  fi
}

aws_sg_list () {
  jq_filter='Description,GroupName,GroupId,VpcId'
  aws ec2 describe-security-groups | jq -S ".|.SecurityGroups[]|{$jq_filter}"
}

aws_iam_roles () {
  aws iam list-roles | jq -S ".|.Roles[]|{RoleName,Arn,RoleId,CreateDate}"
}

# launch a spot instance
aws_spot_run () {
  # defaults
  itype='m3.medium'
  price='0.03'
  key='adamthepatterson_rsa'
  ami='ami-f7a2bf96'
  count=1

  if [ -z $1 ]; then
    echo 'Minimum req args: $1: instance_type $2: price'
    echo 'Full positional args [defaults]:'
    echo "  aws_ec2_run \$itype [$itype] \$price [$price] \$key [$key] " \
      "\$ami [$ami] \$count [$count]"
  else
    itype=$1
    if [ ! -z $2 ]; then price=$2; fi
    if [ ! -z $3 ]; then key=$3; fi
    if [ ! -z $4 ]; then ami=$4; fi
    if [ ! -z $5 ]; then count=$5; fi

    # EC2 LaunchSpecification in JSON - because heredocs are STUPID
    read -r -d '' launchspec << EOF
{
  "ImageId": "$ami",
  "KeyName": "$key",
  "InstanceType": "$itype",
  "SecurityGroups": [ "allow_ssh" ]
}
EOF

    jq_filter='Status,SpotInstanceRequestId,CreateTime,SpotPrice'
    aws ec2 request-spot-instances \
      --spot-price $price \
      --type "one-time" \
      --instance-count $count \
      --launch-specification "$launchspec" | jq -S \
        ".|.SpotInstanceRequests[]|{$jq_filter}"
  fi
}

# get the latest spot price for a given instance type ($1)
aws_spot_price () {
  if [ -z $1 ]; then
    echo "Provide instance type as argument..."
  else
    if [ ! -z $2 ]; then
      p_desc="$2"
    else
      p_desc='Linux/UNIX'
    fi
    zulu=$(date -j -u +"%Y-%m-%dT%H:%M:%S")
    aws ec2 describe-spot-price-history --instance-types $1 \
      --product-description "$p_desc" --start-time $zulu | jq .
  fi
}

# list spot requests, short format
aws_spot_requests () {
  if [ -z $1 ]; then
    echo "INFO: Optionally provide region as argument. Default is current configured."
  else
    region="--region $1"
  fi
  aws ec2 describe-spot-instance-requests $region | \
    jq -S ".|.SpotInstanceRequests[]|{ \
      Status,SpotInstanceRequestId,State,Type,CreateTime,SpotPrice, \
      InstanceType:(.LaunchSpecification.InstanceType), \
      AvailabilityZone:(.LaunchSpecification.Placement.AvailabilityZone), \
      ImageId:(.LaunchSpecification.ImageId), \
      InstanceId}"
}

# put ~/.aws/config creds into env variables
aws_env_vars () {
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  export AWS_ACCESS_KEY_ID=$( \
    cat ~/.aws/config | grep -i aws_access_key_id | awk -F\= '{print $2}' )
  export AWS_SECRET_ACCESS_KEY=$( \
    cat ~/.aws/config | grep -i aws_secret_access_key | awk -F\= '{print $2}' )
}

# find what IAM user an access key is tied to
aws_access_key_to_user () {
  if [ -z $1 ]; then
    echo "Usage: $FUNCNAME AWS_ACCESS_KEY_ID"
  else
    for i in $(aws iam list-users | jq -r '.|.Users[]|.UserName'); do
      aws iam list-access-keys --user-name "$i" | grep -i -B 3 "$1";
    done
  fi
}

# return short instance list based on keyword in Name tag
aws_ec2_find () {
  if [ -z $1 ]; then
    echo "Provide single Key=Value pair to search on as argument."
  else
    key=$(echo "$1" | awk -F= '{print $1}')
    value=$(echo "$1" | awk -F= '{print $2}')
    jq_filter="PublicDnsName,VpcId,InstanceId,PrivateIpAddress,InstanceType,\
      PublicIpAddress,State,ImageId,SubnetId,LaunchTime,\
      Tags:(.Tags[]|select(.Key ==\"$key\"))"

    aws ec2 describe-instances --filter \
      "Name=tag-key,Values=$key" \
      "Name=tag-value,Values=$value" | \
        jq -S ".|.Reservations[]|.Instances[]|{$jq_filter}"
  fi
}


### docker

dme () {
  vm="$1"
  if [ -z $1 ]; then
    echo -n "Using 'default' as docker-machine vm..."
    echo " override by passing vm name as argument."
    vm='default'
  fi
  eval "$(docker-machine env $vm)"
}

docker_image_cleanup () {
  images=$(docker images | grep "^<none>" | awk '{print $3}')
  if [ ! -z "$images" ]; then
    docker rmi $images
  fi
}

docker_container_cleanup () {
  containers=$(docker ps -qa)
  if [ ! -z "$containers" ]; then
    docker rm $containers
  fi
}

docker_stats () {
  docker stats --no-stream=true $(docker ps -q)
}

docker_ps () {
  containers=$(docker ps -q)
	for i in $containers; do
		ds=$(docker inspect $i)
		echo "$ds" | grep Hostname\"
		echo "$ds" | grep -A 2 'Labels'
	done
}

# Fetch list of images (repositories) from a remote Docker Registry 2.0
docker_reg_images () {
  if [ -z $1 ]; then
    echo "Pass registry hostname as argument."
  else
    reg="$1"
    read -p "$reg username: " user
    read -s -p "$reg password: " pass
    curl -k -s -X GET \
      "https://$reg/v2/_catalog" \
      -u "$user:$pass" \
      -H "Accept: application/json" | jq .
  fi
}

# Fetch versions for a given image
docker_reg_image_versions () {
  if [ -z $1 ] || [ -z $2 ]; then
    echo "Pass registry hostname and image name as arguments."
  else
    reg="$1"
    image="$2"
    read -p "$reg username: " user
    read -s -p "$reg password: " pass
    echo ""
    curl -k -s -X GET \
      "https://$reg/v2/$image/tags/list" \
      -u "$user:$pass" \
      -H "Accept: application/json" | jq .
  fi
}

# Dump all docker registry image versions
docker_reg_image_dump () {
  if [ -z $1 ]; then
    echo "Pass registry hostname as argument."
  else
    reg="$1"
    read -p "$reg username: " user
    read -s -p "$reg password: " pass
    echo ""
    for i in $(curl -k -s -X GET "https://$reg/v2/_catalog" \
                -u "$user:$pass" -H "Accept: application/json" | \
                jq '.|.repositories[]' | cut -d'"' -f2); do
      curl -k -s -X GET "https://$reg/v2/$i/tags/list" \
        -u "$user:$pass" | jq .
    done
  fi
}

# NSX - yuck
nsx_dump_sgs () {
  if [ -z $1 ]; then
    echo "Provide NSX Manager hostname as argument."
  else
    nsx=$1
    outfile=prod-nsx-sgs-$(timestamp).json
    read -p "NSX Username: " user
    read -s -p "NSX Password: " pass
    curl -k -X GET \
      https://$nsx/api/2.0/services/securitygroup/scope/globalroot-0 \
      -H "Accept: application/json" \
      -u $user:$pass | jq . > $outfile
    echo "Dumped to $outfile"
  fi
}

# jenkins
jenkins_set_jcli () {
  if [ -z $JENKINS ]; then
    echo '$JENKINS host not set. e.g. https://$JENKINS'
  else
    if [ ! -f jenkins-cli.jar ]; then
      curl -k https://$JENKINS/jnlpJars/jenkins-cli.jar -O
    fi
    read -s -p "password: " PASS
    java -jar jenkins-cli.jar -noCertificateCheck -noKeyAuth -s https://$JENKINS \
      login --username $USER --password $PASS
    alias jcli="java -jar jenkins-cli.jar -noCertificateCheck -noKeyAuth -s https://$JENKINS "
  fi
}

jenkins_run_job () {
  if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
    echo "Missing args.  Syntax: jenkins_run_job JENKINS_HOST JOB_NAME API_TOKEN PARAMS=foo"
  else
    resp=$(curl -i -s -k -X POST \
      "https://$1/job/$2/buildWithParameters?$4" \
      -u "$USER:$3")
    echo $resp
  fi
}
