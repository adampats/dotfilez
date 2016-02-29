# export HOMEBREW_GITHUB_API_TOKEN=FOO
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export GOPATH=$HOME/go

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH=$PATH:$(find $HOME/Applications/packer* -type d)
export PATH=$PATH:$(find $HOME/Applications/terraform* -type d)
export PATH=$PATH:$(find $HOME/Applications/etcd* -type d | head -1)

alias gitp='/usr/bin/git -c user.name="adampats" -c user.email="adamthepatterson@gmail.com"'
# alias dme='eval "$(docker-machine env dev)"'

source $HOME/git/personal/dotfilez/functions.sh

# export PS1="\h:\W \u\$ "
# export PS1="\h:\W \u\$(git-radar --bash --fetch) $ "
export PS1="☣︎ \h:\W \$ "
