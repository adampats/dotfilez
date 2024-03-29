
# Load the default .profile
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile"

# disable homebrew autoupdate
export HOMEBREW_NO_AUTO_UPDATE=1
eval "$(/opt/homebrew/bin/brew shellenv)"

eval "$(pyenv init -)"
eval "$(rbenv init -)"
eval "$(jenv init -)"

export JAVA_HOME=$(/usr/libexec/java_home)
export GOPATH=$HOME/go
export GO111MODULE=on

# Turns off OS X Catalina warning about zsh
export BASH_SILENCE_DEPRECATION_WARNING=1

mkdir -p $HOME/Applications/bin
export PATH=$PATH:$(find $HOME/Applications/bin -type d)
export PATH=$PATH:$HOME/Applications
export PATH=$PATH:$HOME/go/bin

dotfile="$HOME/git/personal/dotfilez/functions.sh"
if [ -e "$dotfile" ]; then source "$dotfile"; fi

alias gitp='/usr/bin/git -c user.name="adampats" -c user.email="adampatterson@protonmail.com" '
alias gitl='/usr/bin/git -c user.name="Adam Patterson" -c user.email="adamthepatterson@gmail.com" '
alias gs='git status'
alias ga='git add '
alias gd='git diff '
alias gdc='git diff --cached '
alias gcm='git commit -m '
alias gl='git log --pretty=oneline --abbrev-commit '
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

# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
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

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

source <(kubectl completion bash)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

complete -C /usr/local/bin/vault vault
