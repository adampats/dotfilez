
# Load the default .profile
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile"

# # Load RVM into a shell session *as a function*
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
# export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

if which pyenv > /dev/null; then
  eval "$(pyenv init -)"
fi

if which rbenv > /dev/null; then
  eval "$(rbenv init -)"
fi

# export HOMEBREW_GITHUB_API_TOKEN=FOO
export JAVA_HOME=$(/usr/libexec/java_home)
export GOPATH=$HOME/go

mkdir -p $HOME/Applications/bin
export PATH=$PATH:$(find $HOME/Applications/bin -type d)
export PATH=$PATH:$HOME/Applications

dotfile="$HOME/git/dotfilez/functions.sh"
if [ -e "$dotfile" ]; then source "$dotfile"; fi

alias gitp='/usr/bin/git -c user.name="adampats" -c user.email="adampatterson@protonmail.com" '
alias gitl='/usr/bin/git -c user.name="Adam Patterson" -c user.email="adamthepatterson@gmail.com" '
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
alias tk='bundle exec kitchen '

# GREEN="\[\033[0;32m\]"
# YELLOW="\[\033[0;33m\]"
# YELLOWBOLD="\[\033[1;33m\]"
# CYAN="\[\033[0;36m\]"
# CYANBOLD="\[\033[1;36m\]"
# RESETCOLOR="\[\e[00m\]"

# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
if [[ -f ~/.git-prompt.sh ]]; then
  source ~/.git-prompt.sh
  export GIT_PS1_SHOWDIRTYSTATE=1
  export PS1="\[\033[1;33m\]\h (\W) \$(__git_ps1 '\[\033[0;36m\]{%s}\[\e[00m\]') \[\033[0;33m\]\$\[\e[00m\] "
else
  export PS1="\[\033[1;33m\]\h (\W) \$\[\e[00m\] "
fi

# The next line updates PATH for the Google Cloud SDK.
gcpath="$HOME/Applications/google-cloud-sdk/path.bash.inc"
if [ -f "$gcpath" ]; then source "$gcpath"; fi

# The next line enables shell command completion for gcloud.
gccompletion="$HOME/Applications/google-cloud-sdk/completion.bash.inc"
if [ -f "$gccompletion" ]; then source "$gccompletion"; fi
