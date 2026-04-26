# p10k instant prompt: must stay at top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Homebrew: must come before OMZ so plugins that call brew find it
eval "$(/opt/homebrew/bin/brew shellenv)"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  aliases alias-finder
  brew
  dirhistory
  docker
  fzf-tab
  golang
  git git-commit
  history
  macos
  tmux
  zsh-autosuggestions
  fast-syntax-highlighting
)

zstyle ':omz:plugins:alias-finder' autoload yes
zstyle ':omz:plugins:alias-finder' longer yes
zstyle ':omz:plugins:alias-finder' exact yes
zstyle ':omz:plugins:alias-finder' cheaper yes

fpath=(~/.zsh/completion $fpath)
source $ZSH/oh-my-zsh.sh

# Environment
export EDITOR="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
export PATH="$HOME/go/bin:$HOME/.local/bin:/usr/local/go/bin:$PATH"

# Aliases
alias v="nvim"
alias vim="nvim"
alias lg="lazygit"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias myip="curl -s ifconfig.me"
alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
alias copy="pbcopy"
alias paste="pbpaste"

# Drop-in replacements
alias ls="eza --icons --group-directories-first"
alias ll="eza -lah --icons --git --group-directories-first"
alias lt="eza --tree --icons --level=2"
alias cat="bat --paging=never"
alias top="btop"
alias find="fd"
alias grep="rg"

# Docker
alias dps="docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'"
dex() { docker exec -it "$1" "${2:-sh}" }
dlog() { docker logs -f "$1" }

# Tmux
t() { tmux new-session -As "${1:-main}" }

# Utils
mkcd() { mkdir -p "$1" && cd "$1" }
serve() { python3 -m http.server "${1:-8000}" }
ports() { lsof -iTCP -sTCP:LISTEN -n -P }
reload() { source ~/.zshrc }
extract() {
  case "$1" in
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.bz2)      tar xjf "$1" ;;
    *.zip)          unzip "$1" ;;
    *.gz)           gunzip "$1" ;;
    *.rar)          unrar x "$1" ;;
    *)              echo "unknown archive: $1" ;;
  esac
}

# FZF interactive
fco() { git checkout "$(git branch -a | fzf | tr -d '[:space:]')" }
fkill() { kill -9 "$(ps aux | fzf | awk '{print $2}')" }
fcd() { cd "$(fd --type d | fzf)" }

# Git
git-clean() { git branch --merged | grep -v '\*\|main\|master\|dev' | xargs git branch -d }
alias ghb="gh browse"

# macOS
alias localip="ipconfig getifaddr en0"
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"
alias o="open ."

# Debug
alias path='echo $PATH | tr ":" "\n"'
alias zsh-time="time zsh -i -c exit"

# Shell behavior
setopt HIST_IGNORE_SPACE
setopt CORRECT

# Update everything
upa() {
  brew update && brew upgrade && brew cleanup && brew autoremove && brew doctor
  npm update -g
  gh extension upgrade --all
  gup update
  omz update
}

# Tool integrations
source ~/.orbstack/shell/init.zsh 2>/dev/null || true
source <(fzf --zsh)
source <(fx --comp zsh)
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
