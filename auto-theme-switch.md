# Auto Theme Switching for Ghostty, Neovim, and Tmux (Kanagawa Dragon/Lotus)

We both use Kanagawa Dragon for dark mode and Kanagawa Lotus for light mode. Here's how to wire all three tools to follow macOS system appearance automatically.

---

## Ghostty

The easiest one. Ghostty has native light/dark support:

```
theme = light:Kanagawa Lotus,dark:Kanagawa Dragon
```

That's it. It switches the moment you toggle macOS appearance.

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

Tmux is the tricky one — it doesn't watch the OS appearance. The solution has two parts.

**1. Set the initial theme on startup** in `tmux.conf`:

```tmux
if-shell 'defaults read -g AppleInterfaceStyle >/dev/null 2>&1' \
  'set -g @ukiyo-theme "kanagawa/dragon"' \
  'set -g @ukiyo-theme "kanagawa/lotus"'
```

`defaults read -g AppleInterfaceStyle` returns `Dark` when dark mode is on, and exits with an error in light mode. The `if-shell` condition uses that exit code.

**2. Sync on appearance changes** with a script + LaunchAgent.

Create `~/.local/bin/tmux-theme-sync`:

```bash
#!/usr/bin/env bash
set -euo pipefail

if defaults read -g AppleInterfaceStyle >/dev/null 2>&1; then
  desired='kanagawa/dragon'
else
  desired='kanagawa/lotus'
fi

current="$(tmux show -gv @ukiyo-theme 2>/dev/null || true)"
if [[ -z "${current}" ]]; then
  exit 0
fi

if [[ "${current}" != "${desired}" ]]; then
  tmux set -g @ukiyo-theme "${desired}"
  tmux source-file ~/.config/tmux/tmux.conf >/dev/null 2>&1 || true
fi
```

Then register it as a LaunchAgent at `~/Library/LaunchAgents/com.yourname.tmux-theme-sync.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.yourname.tmux-theme-sync</string>
    <key>ProgramArguments</key>
    <array>
      <string>/bin/bash</string>
      <string>-lc</string>
      <string>~/.local/bin/tmux-theme-sync</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
      <key>PATH</key>
      <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>StartInterval</key>
    <integer>5</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/tmux-theme-sync.out</string>
    <key>StandardErrorPath</key>
    <string>/tmp/tmux-theme-sync.err</string>
  </dict>
</plist>
```

Load it:

```sh
launchctl load ~/Library/LaunchAgents/com.yourname.tmux-theme-sync.plist
```

The agent polls every 5 seconds. When it detects a theme mismatch it updates the tmux option and reloads the config. The reload is cheap since the script exits early if nothing changed.

---

## Result

Toggle macOS dark/light mode. Ghostty switches instantly, Neovim follows the terminal's background signal, and tmux catches up within 5 seconds.
