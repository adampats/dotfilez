# export HOMEBREW_GITHUB_API_TOKEN=FOO
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export GOPATH=$HOME/go

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH=$PATH:$(find $HOME/Applications/packer* -type d)
export PATH=$PATH:$(find $HOME/Applications/terraform* -type d)
export PATH=$PATH:$(find $HOME/Applications/etcd* -type d | head -1)
export PATH=$PATH:$HOME/Applications

alias gitp='/usr/bin/git -c user.name="adampats" -c user.email="adamthepatterson@gmail.com"'
# alias dme='eval "$(docker-machine env dev)"'

dotfile=/Users/adam/git/dotfilez/functions.sh
if [ -e "$dotfile" ]; then
  source "$dotfile"
fi

GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
YELLOWBOLD="\[\033[1;33m\]"
CYAN="\[\033[0;36m\]"
CYANBOLD="\[\033[1;36m\]"
RESETCOLOR="\[\e[00m\]"\
export PS1="$YELLOWBOLD ☣︎ \h:\W \$$RESETCOLOR "
