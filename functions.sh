# A collection of handy functions.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/general.sh"
source "$DIR/aws.sh"

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
