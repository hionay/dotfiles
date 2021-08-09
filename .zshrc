if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="/Users/halil/.oh-my-zsh"

#ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

KEYTIMEOUT=1
export TERM="xterm-256color"

export EDITOR="vim"
export USE_EDITOR=$EDITOR
export VISUAL=$EDITOR

export GOPATH=$HOME/Projects/go
export PATH=$PATH:$HOME/Projects/go/bin
export PATH="/usr/local/sbin:$PATH"
export PATH=$PATH:$HOME/bin
export PATH="$PATH:/usr/local/opt/mysql-client/bin"

export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export GPG_TTY=$TTY

# Aliases
alias python='python3'
alias pip='pip3'
alias bu="brew update && brew upgrade && brew upgrade --cask && brew cleanup -s && brew doctor"
alias du="du -sh * | sort -h"
alias duh='du -sh -t 1M * .[^.]* 2> /dev/null | sort -h'
alias php='/usr/local/bin/php'

alias v='nvim'
alias vi='nvim'
alias vim='nvim'

alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias zshrc="vim ~/.zshrc && reload"
alias vimrc="vim ~/.config/nvim/init.vim"
alias tmuxrc="vim ~/.tmux.conf && tmux source-file ~/.tmux.conf"

alias myip='curl http://ifconfig.me/ip'
alias now='date +"%T"'
alias path='echo -e ${PATH//:/\\n}'

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="/usr/local/opt/openjdk/bin:$PATH"
