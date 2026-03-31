#!/usr/bin/env bash
launchctl unload ~/Library/LaunchAgents/com.halil.tmux-theme-sync.plist 2>/dev/null
launchctl load ~/Library/LaunchAgents/com.halil.tmux-theme-sync.plist
