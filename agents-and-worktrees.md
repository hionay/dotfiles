# Coding Agents in Tmux: Status Icons, Jump Key, and Worktree Windows

One tmux window per feature, one git worktree per window, one agent per worktree. Tmux shows what each agent is doing, and one key takes you to the next agent that needs you.

| Key | What it does |
|-----|--------------|
| `prefix F` | Prompt for a branch, open a new window on its worktree, start nvim there |
| `prefix a` | Jump to the next window whose agent is blocked, then the next one that is done |
| `prefix w` | Window/session tree with agent icons |

Window list icons:

| Icon | State | Set when |
|------|-------|----------|
| ⏳ | working | you submit a prompt, or a tool finishes |
| ❓ | blocked | the agent asks for permission |
| ✅ | done | the agent finishes its turn |

✅ clears once you enter or leave that window, so it means "finished and not looked at yet".

Prefix here is `C-a`.

---

## Daily flow

1. In any pane inside a repo, press `prefix F` and type a branch name.
   - Existing branch (local or remote): switches to its worktree, creating it if needed.
   - Unknown name: creates the branch and its worktree.
   - Empty: opens the worktrunk picker. Esc cancels and leaves a plain shell.
2. The new window is renamed after the branch and nvim opens in the worktree.
3. Start the agent in that window (a split, or nvim's terminal, or sidekick).
4. Repeat for the next feature. Each agent works in its own directory, so they never touch each other's files or fight over the index.
5. Look at the status bar, or just press `prefix a` whenever you have a moment. It cycles through blocked windows first, across all sessions, then done ones. When nothing needs you it says `No agent needs you`.
6. `prefix w` gives the whole picture: each window carries its icon, and each session line shows the icons of all its windows.

When a feature is merged, remove its worktree with `wt remove` (see `wt --help`; worktrunk also has `wt merge`).

From a shell you can do the same thing without the key: `feat my-branch`.

---

## Pieces

### 1. worktrunk (`wt`)

The worktree manager. Install it (`brew install worktrunk`), then add its shell integration to `~/.zshrc` so `wt switch` can `cd` your shell:

```zsh
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
```

### 2. `feat` shell function (`shell/.zshrc`)

```zsh
# feat [branch]: switch to the branch's worktree (picker if none given, new
# branch if unknown), name the tmux window after it, then open nvim there
feat() {
  local from=$PWD
  # the picker exits 0 on Esc too, so an unchanged directory means cancelled
  if [[ -z $1 ]]; then wt switch && [[ $PWD != "$from" ]] || return
  elif [[ -n $(git for-each-ref --format=x "refs/heads/$1" "refs/remotes/*/$1") ]]; then wt switch "$1" || return
  else wt switch -c "$1" || return
  fi
  [[ -n $TMUX ]] && tmux rename-window -t "$TMUX_PANE" "$(git branch --show-current)"
  nvim
}
```

Swap `nvim` for your editor, or for the agent itself (`claude`, `codex`, ...) if you want the window to start straight into the agent.

### 3. Agent state hook (`claude/.claude/hooks/tmux-agent-state.sh`)

Writes the agent state into a per-window tmux option, `@agent`. It only acts when it runs inside tmux and when the agent owns the pane's tty, so background `claude -p` runs don't flip the icon of whatever window they were started from.

```sh
#!/bin/sh
# usage: tmux-agent-state.sh working|blocked|done|idle|clear
cat >/dev/null 2>&1
[ -n "${TMUX_PANE:-}" ] || exit 0

tty=$(ps -o tty= -p "$PPID" 2>/dev/null | tr -d ' ')
[ "/dev/$tty" = "$(tmux display -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)" ] || exit 0

case "${1:-}" in
  working|blocked|done) tmux set -w -t "$TMUX_PANE" @agent "$1" ;;
  idle)
    case "$(tmux show -wv -t "$TMUX_PANE" @agent 2>/dev/null)" in
      working|blocked) tmux set -wu -t "$TMUX_PANE" @agent ;;
    esac ;;
  clear) tmux set -wu -t "$TMUX_PANE" @agent ;;
esac >/dev/null 2>&1
exit 0
```

`chmod +x` it.

### 4. Claude Code hooks (`~/.claude/settings.json`)

This file is not in the repo, so add the hooks by hand. Each event calls the script with a state:

| Event | Matcher | Arg |
|-------|---------|-----|
| `UserPromptSubmit` | | `working` |
| `PostToolUse` | | `working` |
| `PostToolUseFailure` | | `working` |
| `PermissionRequest` | | `blocked` |
| `Stop` | | `done` |
| `StopFailure` | | `done` |
| `Notification` | `idle_prompt` | `idle` |
| `SessionStart` | `startup\|resume\|clear` | `clear` |
| `SessionEnd` | | `clear` |

Each entry looks like this:

```json
"hooks": {
  "PermissionRequest": [
    { "hooks": [ { "type": "command", "command": "~/.claude/hooks/tmux-agent-state.sh blocked", "timeout": 5 } ] }
  ],
  "Notification": [
    { "matcher": "idle_prompt",
      "hooks": [ { "type": "command", "command": "~/.claude/hooks/tmux-agent-state.sh idle", "timeout": 5 } ] }
  ]
}
```

Why `idle`: pressing Esc or declining a permission fires no hook, so the icon would stay on ⏳ or ❓. `idle_prompt` fires about 60s after the last turn with no input, and the script uses it to clear a stale ⏳ or ❓ (a ✅ stays).

**Other agents:** anything that can run a shell command on its own events can drive the same icons. Call the script with `working`, `blocked` or `done`. The tty check expects the script's parent process to be the agent; if your agent runs hooks through an extra shell, drop or adjust that check.

### 5. tmux (`tmux/.config/tmux/tmux.conf`)

Icon formats and the "seen" rule:

```tmux
set -g  @agent-icon '#{?#{==:#{@agent},working},⏳,#{?#{==:#{@agent},blocked},❓,#{?#{==:#{@agent},done},✅,}}}'
set -g  @agent-wsf  '#{?@agent, #{E:@agent-icon},}'
set -g  @agent-wscf '#{?@agent,#{E:@agent-icon} ,}'
# a finished agent counts as seen once you enter or leave its window
set-hook -g pane-focus-in  'if -F "#{==:#{@agent},done}" "set -wu @agent"'
set-hook -g pane-focus-out 'if -F "#{==:#{@agent},done}" "set -wu @agent"'
```

Append the icon to the window list **after** your theme sets its formats (themes usually overwrite `window-status-format`):

```tmux
set -ga window-status-format '#{E:@agent-wsf}'
set -ga window-status-current-format '#{E:@agent-wscf}'
```

Here this sits after `run 'tpack init'` and inside the light/dark theme hooks, because the ukiyo theme rewrites the formats each time the system theme flips. If your theme sets its formats once, adding the two lines at the end of the config is enough.

The pane focus hooks need `set -g focus-events on`.

Keys:

```tmux
bind a run-shell "~/.config/tmux/agent-next.sh '#{window_id}'"
bind F command-prompt -p "feature (empty: pick):" { new-window -c "#{pane_current_path}" ; send-keys "feat '%1'" Enter }
```

`prefix w` is tmux's default `choose-tree` format with `#{E:@agent-wsf}` added after the window name and `#{W:#{E:@agent-wsf}}` at the end of the session line. The full line is in `tmux.conf`. It is copied from tmux 3.8; after a tmux upgrade, copy the new default and re-add those two pieces.

### 6. Jump script (`tmux/.config/tmux/agent-next.sh`)

Lists every window in every session, searches forward from the current one (wrapping around, skipping the current window so repeated presses move on), and switches to the first `blocked` window, or the first `done` one if none are blocked. `chmod +x` it.

---

## Gotchas

- The `prefix F` window types `feat '<name>'` into a fresh shell, so `feat` must be defined in your interactive zsh.
- Branch names with a single quote will break the `prefix F` command. Don't name branches like that.
- ✅ is cleared by focus. If you look at the window from a different client without focusing it, it stays.
- After editing `tmux.conf`, `prefix R` reloads it (or `tmux source-file ~/.config/tmux/tmux.conf`). Claude Code reads hook changes in `settings.json` on the next session.
