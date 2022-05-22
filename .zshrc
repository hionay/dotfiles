if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="/Users/hio/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    1password
    aliases
    brew
    docker
    gh
    git
    colored-man-pages
    golang
    sudo
)

source $ZSH/oh-my-zsh.sh

eval "$(/opt/homebrew/bin/brew shellenv)"

KEYTIMEOUT=1
export TERM="xterm-256color"

export EDITOR="nvim"
export USE_EDITOR=$EDITOR
export VISUAL=$EDITOR

export GOROOT="/usr/local/go"
export GOPATH=$HOME/Projects/go
export PATH="/usr/local/sbin:$PATH"
export PATH=$PATH:$HOME/bin
export PATH="$PATH:$GOPATH/bin"

export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export GPG_TTY=$(tty)

# Aliases
alias python='python3'
alias pip='pip3'
alias bu="brew update && brew upgrade && brew cu -y --cleanup && brew cleanup -s && brew autoremove && brew doctor"
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
alias gitpullall="find . -type d -depth 1 -exec git --git-dir={}/.git --work-tree=$PWD/{} pull --all \;"

op-clip-Bulutistan() {
    eval $(op signin --account my)
    item_totp=$(op item get Bulutistan --field type=otp --format json | jq -r .totp)
    item_password=$(op item get Bulutistan --field type=concealed --format json | jq -r .value)
    echo -n $(echo "${item_password}${item_totp}") | pbcopy
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
