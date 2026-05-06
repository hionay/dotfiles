# Auto Theme Switching for Ghostty, Neovim, Tmux, and btop (Kanagawa Dragon/Lotus)

Kanagawa Dragon for dark mode, Kanagawa Lotus for light mode. Here's how to wire all four tools to follow macOS system appearance automatically.

---

## Ghostty

Ghostty has native light/dark support:

```
theme = light:Kanagawa Lotus,dark:Kanagawa Dragon
```

It switches the moment you toggle macOS appearance.

---

## Neovim

Install `kanagawa.nvim` and configure it with the `background` table:

```lua
require("kanagawa").setup({
  theme = "dragon",
  background = { dark = "dragon", light = "lotus" },
  transparent = true,
})

vim.cmd("color kanagawa")
```

Neovim reads the `background` option from your terminal and picks the right variant automatically. No autocmd needed.

---

## Tmux

Tmux 3.6 added support for [mode 2031](https://github.com/tmux/tmux/pull/4353) — a terminal protocol that lets tmux subscribe to theme change notifications from the terminal emulator. When Ghostty switches themes it sends a notification, and tmux fires a hook in response.

Add this to `tmux.conf`:

```tmux
set-hook -g client-dark-theme {
  set -g @ukiyo-theme "kanagawa/dragon"
  run ~/.tmux/plugins/tmux-ukiyo/ukiyo.tmux
}
set-hook -g client-light-theme {
  set -g @ukiyo-theme "kanagawa/lotus"
  run ~/.tmux/plugins/tmux-ukiyo/ukiyo.tmux
}
```

That's all. No polling script, no LaunchAgent. When a client attaches, tmux subscribes to mode 2031 and Ghostty immediately sends back the current theme, so the hook also fires on startup — no separate startup check needed.

---

## btop

btop has no native appearance detection, so a `btop` shell function in `.zshrc` checks the mode and rewrites `color_theme` in `~/.config/btop/btop.conf` before each launch:

```zsh
btop() {
  local theme
  if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
    theme="kanagawa-dragon"
  else
    theme="kanagawa-lotus"
  fi
  sed -i '' "s/^color_theme = .*/color_theme = \"$theme\"/" ~/.config/btop/btop.conf
  command btop "$@"
}
```

Picks the right theme on every launch. The `top` alias routes through this function automatically.

---

## Result

Toggle macOS dark/light mode. Ghostty switches instantly, Neovim follows the terminal's background signal, tmux switches immediately via the mode 2031 hook, and btop picks the correct theme on next launch.
