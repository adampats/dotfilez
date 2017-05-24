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
