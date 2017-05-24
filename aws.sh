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
