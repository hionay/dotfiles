#!/bin/sh
# Jump to the next window whose agent needs you, across all sessions:
# blocked first, then done. Searches forward from the current window, wraps,
# and skips the current window so repeated presses move on.
# usage: agent-next.sh <current window id>

target=$(tmux list-windows -a -F '#{window_id} #{@agent}' | awk -v cur="$1" '
  { id[NR] = $1; st[NR] = $2; if ($1 == cur) c = NR }
  END {
    split("blocked done", want, " ")
    n = c ? NR - 1 : NR
    for (w = 1; w <= 2; w++)
      for (i = 1; i <= n; i++) {
        j = (c + i - 1) % NR + 1
        if (st[j] == want[w]) { print id[j]; exit }
      }
  }')

if [ -n "$target" ]; then
  tmux switch-client -t "$target"
else
  tmux display-message "No agent needs you"
fi
