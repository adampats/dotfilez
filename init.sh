#!/bin/bash

copy_files () {
  chsh -s /bin/bash
  cp -v bash_profile ~/.bash_profile
}

brew_install () {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew bundle install
}

setup_iterm2 () {
  curl -L https://iterm2.com/shell_integration/bash -o ~/.iterm2_shell_integration.bash
}

python_scripts () {
  uv python install
  uv sync --project ./scripts/tokenizer
  uv sync --project ./scripts/claude_youtube
}

misc () {
  mkdir -p $HOME/Applications/bin
  echo "Manual task:  Import iterm2_profile.json to iTerm2."
  echo "Manual task:  Copy SSH keys."
  echo "Manual task:  Copy GPG keys."
}

main() {
  copy_files
  brew_install
  setup_iterm2
  python_scripts
  misc
  echo "Done"
}
