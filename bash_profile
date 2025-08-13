### Shell

# Load the default .profile
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile"

dotfile="$HOME/git/personal/dotfilez/util.sh"
if [ -e "$dotfile" ]; then source "$dotfile"; fi

# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
if [[ -f ~/.git-prompt.sh ]]; then
  source ~/.git-prompt.sh
  export GIT_PS1_SHOWDIRTYSTATE=1
  export PS1="\[\033[1;33m\]\h (\W) \$(__git_ps1 '\[\033[0;36m\]{%s}\[\e[00m\]') \[\033[0;33m\]\$\[\e[00m\] "
else
  export PS1="\[\033[1;33m\]\h (\W) \$\[\e[00m\] "
fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Turns off OS X Catalina warning about zsh
export BASH_SILENCE_DEPRECATION_WARNING=1

mkdir -p $HOME/Applications/bin
export PATH=$PATH:$(find $HOME/Applications/bin -type d)
export PATH=$PATH:$HOME/Applications
export PATH=$PATH:$HOME/go/bin


### Tools

# disable homebrew autoupdate
export HOMEBREW_NO_AUTO_UPDATE=1
eval "$(/opt/homebrew/bin/brew shellenv)"

eval "$(pyenv init -)"
#eval "$(rbenv init -)"

export GOPATH=$HOME/go
export GO111MODULE=on

alias gs='git status'
alias ga='git add '
alias gd='git diff '
alias gdc='git diff --cached '
alias gcm='git commit -m '
alias gl='git log --pretty=oneline --abbrev-commit '
alias lv='util_list_vars'
alias k='kubectl '


### Misc

[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

source <(kubectl completion bash)

# brew pg utils, might break native postgresql
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

#source /opt/homebrew/opt/asdf/libexec/asdf.sh
# complete -C /usr/local/bin/vault vault
#export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"

# fixes netskope cert issues for aws-cli, pip, node, etc - must acquire mitm vpn cert first
#export REQUESTS_CA_BUNDLE='/Library/Application Support/Netskope/STAgent/data/nscacert.pem'
#export REQUESTS_CA_BUNDLE='/opt/homebrew/Cellar/azure-cli/2.67.0_1/libexec/lib/python3.12/site-packages/certifi/cacert.pem'
#export CURL_CA_BUNDLE='/Library/Application Support/Netskope/STAgent/data/nscacert.pem'
#export NODE_EXTRA_CA_CERTS='/Library/Application Support/Netskope/STAgent/data/nscacert.pem'
export REQUESTS_CA_BUNDLE='/opt/homebrew/Cellar/azure-cli/2.69.0/libexec/lib/python3.12/site-packages/certifi/cacert.pem'


### Bash history

# Append to history, don't overwrite
shopt -s histappend

# Update history after each command
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

HISTSIZE=1000
HISTFILESIZE=1000
