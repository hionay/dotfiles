# p10k instant prompt: must stay at top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Keep PATH deduped so re-sourcing this file does not stack entries
typeset -U path PATH

# Homebrew: must come before OMZ so plugins that call brew find it
eval "$(/opt/homebrew/bin/brew shellenv)"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  aliases
  brew
  dirhistory
  docker
  eza
  fzf-tab
  golang
  git
  history
  macos
  tmux
  zsh-autosuggestions
  fast-syntax-highlighting
)

zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' 'icons' yes

# Fix stale fpath after Homebrew zsh upgrades
fpath+=(/opt/homebrew/share/zsh/functions)

fpath=(~/.zsh/completion $fpath)
source $ZSH/oh-my-zsh.sh

# Environment
export EDITOR="nvim"
export MANPAGER="nvim +Man!"
export XDG_CONFIG_HOME="$HOME/.config"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ASK=1
export PATH="$HOME/.local/bin:$HOME/go/bin:/usr/local/go/bin:$PATH"

# Aliases
alias v="nvim"
alias vim="nvim"
alias lg="lazygit"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias myip="curl -s ifconfig.me && echo"
alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
alias copy="pbcopy"
alias paste="pbpaste"

# Antigravity CLI
agy() {
  GOOGLE_CLOUD_PROJECT=poltio-dev command agy "$@"
}

gemini() {
  GOOGLE_CLOUD_PROJECT=poltio-dev command gemini "$@"
}

# Drop-in replacements
alias cat="bat --paging=never"
alias top="btop"
alias find="fd"
alias grep="rg"

btop() {
  local theme
  if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
    theme="kanagawa-dragon"
  else
    theme="kanagawa-lotus"
  fi
  sed -i '' "s/^color_theme = .*/color_theme = \"$theme\"/" "$(realpath ~/.config/btop/btop.conf)"
  command btop "$@"
}

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
reload() { exec zsh }   # fresh process: re-sourcing would re-wrap the ZLE widgets
extract() {
  case "$1" in
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.bz2)      tar xjf "$1" ;;
    *.tar.xz)       tar xJf "$1" ;;
    *.zip)          unzip "$1" ;;
    *.gz)           gunzip "$1" ;;
    *.rar)          unrar x "$1" ;;
    *)              echo "unknown archive: $1" ;;
  esac
}

# FZF interactive
fco() {
  local b
  b=$(git branch -a --format='%(refname:short)' |
    sed -e 's|^origin/||' -e '/^origin$/d' | sort -u | fzf) || return
  [[ -n $b ]] && git checkout "$b"
}
fkill() {
  local p
  p=$(ps aux | fzf --header-lines=1 | awk '{print $2}') || return
  [[ -n $p ]] && kill -9 "$p"
}
fcd() {
  local d
  d=$(fd --type d | fzf) || return
  [[ -n $d ]] && cd "$d"
}

# Git
# 'command' bypasses the rg alias above: rg would read \| as a literal pipe,
# so the filter would match nothing and -d would eat main/master/dev.
git-clean() {
  git branch --merged "${1:-main}" |
    command grep -vE '^\*|^[[:space:]]*(main|master|dev)$' |
    xargs git branch -d
}
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

[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets

# Tool integrations
source ~/.orbstack/shell/init.zsh 2>/dev/null || true
(( $+commands[fzf] )) && source <(fzf --zsh)
(( $+commands[fx] )) && source <(fx --comp zsh)
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
