# General bash utilities I use

# create env vars based on 'key=value' env file
load_env () {
  if [ -z $1 ]; then
    echo "Provide path to env file..."
  else
    export $(cat $1 | grep -v ^# | xargs)
  fi
}

timestamp() {
  date +"%Y%m%d%H%M%S"
}

# Mac OS X timer with desktop notification
timer () {
  if [ -z $1 ]; then
    echo "Provide time in minutes as argument."
  else
    echo "Sleeping for $1 minutes... "
    sec=$(( $1 * 60 ))
    while [ $sec -gt 0 ]; do
       echo -ne "\t$sec\033[0K\r"
       sleep 1
       : $((sec--))
    done
    echo "Timer expired @ $(date +%H:%M:%S)"
    say -v whisper "times up"
    terminal-notifier -message "Slept for $1 minutes..." -title "Timer expired!"
  fi
}

weather () {
  if [ -z $1 ]; then
    location="seattle,wa"
  else
    location=$1
  fi
  jq_filter="weather,temperature_string,relative_humidity,wind_string,\
    feelslike_string,visibility_mi,precip_today_string"
  cd ~/Applications # location of wunderground.key (gunderground bug)
  gunderground $location | jq -S ".|.current_observation|{$jq_filter}"
  cd $OLDPWD
}

list_vars () {
  compgen -v | while read var; do printf "%s=%q\n" "$var" "${!var}"; done
}


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

wifi_signal () {
  /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I
}

wifi_survey () {
  /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s
}
