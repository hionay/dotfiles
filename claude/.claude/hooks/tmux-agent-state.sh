#!/bin/sh
# Claude Code hook: mirrors agent state into the tmux window option @agent,
# which tmux.conf renders in the window list.
# usage: tmux-agent-state.sh working|blocked|done|idle|clear

cat >/dev/null 2>&1
[ -n "${TMUX_PANE:-}" ] || exit 0

# Only the claude that owns this pane's tty. Background `claude -p` runs and
# daemons inherit TMUX_PANE too, but have no tty or a different one.
tty=$(ps -o tty= -p "$PPID" 2>/dev/null | tr -d ' ')
[ "/dev/$tty" = "$(tmux display -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)" ] || exit 0

case "${1:-}" in
  working|blocked|done) tmux set -w -t "$TMUX_PANE" @agent "$1" ;;
  # idle_prompt fires 60s after the last turn with no input. Esc and a declined
  # permission fire no hook, so this clears what they leave behind.
  idle)
    case "$(tmux show -wv -t "$TMUX_PANE" @agent 2>/dev/null)" in
      working|blocked) tmux set -wu -t "$TMUX_PANE" @agent ;;
    esac ;;
  clear) tmux set -wu -t "$TMUX_PANE" @agent ;;
esac >/dev/null 2>&1
exit 0
