# General bash utilities I use

# create env vars based on 'key=value' env file
load_env () {
  if [ -z $1 ]; then
    echo "Provide path to env file..."
  else
    export $(cat $1 | grep -v ^# | xargs)
  fi
}
