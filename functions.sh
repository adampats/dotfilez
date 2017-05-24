# A collection of handy functions.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/general.sh"
source "$DIR/aws.sh"
source "$DIR/docker.sh"

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
