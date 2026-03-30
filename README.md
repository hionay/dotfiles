# My dotfiles

This directory contains the dotfiles for my system.

## Requirements

Ensure you have the following installed on your system:

### Git

```shell
brew install git
```

### Stow

```shell
brew install stow
```

## Installation

First, check out the dotfiles repo in your $HOME directory using git:

```shell
git clone https://github.com/hionay/dotfiles.git ~/dotfiles
```

Then use GNU Stow to symlink the dotfiles to your home directory:

```shell
cd ~/dotfiles
stow */
```

You can also stow specific groups individually:

```shell
stow editor shell term
```

Or remove a specific group:

```shell
stow -D shell
```
