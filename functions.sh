# A collection of handy aliases / functions.

# git
alias gitp='/usr/bin/git -c user.name="adampats" -c user.email="adamthepatterson@gmail.com"'
alias gs='git status'
alias ga='git add '

# AWS
# enable AWS CLI tab completion!
complete -C $(which aws_completer) aws

aws_ec2_list () {
  jq_filter='PublicDnsName,VpcId,InstanceId,KeyName,InstanceType,State,ImageId,SubnetId,LaunchTime'
  aws ec2 describe-instances | jq -S \
    ".|.Reservations[]|.Instances[]|{$jq_filter}"
}

# takes parameter of count (number of EC2 instances to run)
aws_ec2_run () {
  if [ -z $1 ]; then count=1; else count=$1; fi
  jq_filter='State,VpcId,InstanceId,KeyName,SecurityGroups,InstanceType,Placement'
  aws ec2 run-instances \
    --image-id ami-d24c5cb3 \
    --instance-type t2.micro \
    --key-name 'adpatter_aws' \
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

# docker
alias dm='docker-machine '
dme () {
  eval "$(docker-machine env dev)"
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
docker_reg_image_versions () {
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

# general
timestamp() {
  date +"%Y%m%d%H%M%S"
}

# NSX - yuck
nsx_dump_sgs () {
  if [ -z $1 ]; then
    echo "Provide NSX Manager hostname as argument."
  else
    nsx=$1
    read -p "NSX Username: " user
    read -s -p "NSX Password: " pass
    curl -k -X GET \
      https://$nsx/api/2.0/services/securitygroup/scope/globalroot-0 \
      -H "Accept: application/json" \
      -u $user:$pass | jq . > prod-nsx-sgs-$(timestamp).json
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
