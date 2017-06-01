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
