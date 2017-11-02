
## dotfilez

### Homebrew bootstrap

Install:

```sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install brews from Brewfile:

```sh
brew bundle
```

### Managing APM (atom.io) package lists

Export:

```sh
apm list --installed --bare > apm-package-list.txt
```

Import:

```sh
apm install --packages-file apm-package-list.txt
```

### Installing pythons with pyenv

OpenSSL lib issues:

```sh
CFLAGS="-I$(brew --prefix openssl)/include" \
LDFLAGS="-L$(brew --prefix openssl)/lib" \
pyenv install -v 2.7.14
```

https://github.com/pyenv/pyenv/wiki/Common-build-problems
