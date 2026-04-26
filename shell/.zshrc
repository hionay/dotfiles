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
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias myip="curl ifconfig.me/ip"
alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'

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
