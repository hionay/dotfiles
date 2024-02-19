# My dotfiles

This directory contains the dotfiles for my system.

## Requirements

Ensure you have the following installed on your system:

### Git

```shell
brew install git
```

### Stow
```
brew install stow
```

## Installation

First, check out the dotfiles repo in your $HOME directory using git:

```shell
git clone https://github.com/hionay/dotfiles.git ~/dotfiles
```

then use GNU stow to symlink the dotfiles to your home directory:

```shell
cd ~/dotfiles
stow .
```
