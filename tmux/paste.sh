#!/bin/bash
content=$(wl-paste -n)
[ -z "$content" ] && exit 1
tmux set-buffer "$content"
tmux paste-buffer -p
