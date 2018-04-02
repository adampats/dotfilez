
# Load the default .profile
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile"

# # Load RVM into a shell session *as a function*
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# screw you apple...
if which pyenv > /dev/null; then
  eval "$(pyenv init -)"
fi

# Or use rbenv because it's better
eval "$(rbenv init -)"

# export HOMEBREW_GITHUB_API_TOKEN=FOO
export JAVA_HOME=$(/usr/libexec/java_home)
export GOPATH=$HOME/go

# export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH=$PATH:$(find $HOME/Applications/bin -type d)
export PATH=$PATH:$HOME/Applications

dotfile="$HOME/git/dotfilez/functions.sh"
if [ -e "$dotfile" ]; then source "$dotfile"; fi

alias gitp='/usr/bin/git -c user.name="adampats" -c user.email="adamthepatterson@gmail.com" '
alias gs='git status'
alias ga='git add '
alias gd='git diff '
alias gdc='git diff --cached '
alias gcm='git commit -m '
alias tf='terraform '
alias d='docker '
alias dm='docker-machine '
alias dc='docker-compose '
alias lv='list_vars'
alias k='kubectl '

# GREEN="\[\033[0;32m\]"
# YELLOW="\[\033[0;33m\]"
# YELLOWBOLD="\[\033[1;33m\]"
# CYAN="\[\033[0;36m\]"
# CYANBOLD="\[\033[1;36m\]"
# RESETCOLOR="\[\e[00m\]"

# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
if [[ -f ~/.git-prompt.sh ]]; then
  source ~/.git-prompt.sh
  export GIT_PS1_SHOWDIRTYSTATE=1
  export PS1="\[\033[1;33m\]\h (\W) $(__git_ps1 "\[\033[0;36m\]{%s}\[\e[00m\]") \[\033[0;33m\]\$\[\e[00m\] "
else
  export PS1="\[\033[1;33m\]\h (\W) \$\[\e[00m\] "
fi

# The next line updates PATH for the Google Cloud SDK.
gcpath="$HOME/Applications/google-cloud-sdk/path.bash.inc"
if [ -f "$gcpath" ]; then source "$gcpath"; fi

# The next line enables shell command completion for gcloud.
gccompletion="$HOME/Applications/google-cloud-sdk/completion.bash.inc"
if [ -f "$gccompletion" ]; then source "$gccompletion"; fi
