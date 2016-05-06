
# Load the default .profile
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile"

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Or use rbenv because it's better
eval "$(rbenv init -)"

# export HOMEBREW_GITHUB_API_TOKEN=FOO
export JAVA_HOME=$(/usr/libexec/java_home)
export GOPATH=$HOME/go

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH=$PATH:$(find $HOME/Applications/bin -type d)
export PATH=$PATH:$HOME/Applications

alias gitp='/usr/bin/git -c user.name="adampats" -c user.email="adamthepatterson@gmail.com" '
alias gitw='/usr/bin/git -c user.name="apatterson" -c user.email="apatterson@datapipe.com" '
alias gs='git status'
alias ga='git add '
alias gd='git diff '
alias gdc='git diff --cached '
alias tf='terraform '
alias d='docker '
alias dm='docker-machine '
alias dc='docker-compose '

dotfile=/Users/adam/git/dotfilez/functions.sh
if [ -e "$dotfile" ]; then
  source "$dotfile"
fi

GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
YELLOWBOLD="\[\033[1;33m\]"
CYAN="\[\033[0;36m\]"
CYANBOLD="\[\033[1;36m\]"
RESETCOLOR="\[\e[00m\]"
export PS1="$YELLOWBOLD ☣︎ \h:\W \$$RESETCOLOR "
