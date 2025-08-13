# General bash utilities

function util_random_string () {
  if [ -z $1 ]; then
    echo "Specify number of characters as argument."
  else
    cat /dev/urandom | \
      LC_ALL=C tr -dc 'a-zA-Z0-9' | \
      fold -w $1 | head -n 1
  fi
}

# create env vars based on 'key=value' env file
function util_load_env () {
  if [ -z $1 ]; then
    echo "Provide path to env file..."
  else
    export $(cat $1 | grep -v ^# | xargs)
  fi
}

function util_timestamp() {
  date +"%Y%m%d%H%M%S"
}

# Mac OS X timer with desktop notification
function util_timer () {
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

function util_weather () {
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

function util_list_vars () {
  compgen -v | while read var; do printf "%s=%q\n" "$var" "${!var}"; done
}

function util_wifi_signal () {
  /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I
}

function util_wifi_survey () {
  /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s
}

function util_pyinit () {
  pyenv version
  python -m venv venv
  source venv/bin/activate
}