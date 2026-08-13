#!/bin/bash
# クリップボード貼り付け（macOS / Wayland / X11 を自動判定）
if [ "$(uname -s)" = Darwin ] && command -v pbpaste >/dev/null 2>&1; then
  content="$(pbpaste 2>/dev/null)"
elif [ -n "${WAYLAND_DISPLAY:-}" ] && command -v wl-paste >/dev/null 2>&1; then
  content="$(wl-paste -n 2>/dev/null)"
elif command -v xclip >/dev/null 2>&1; then
  content="$(xclip -o -selection clipboard 2>/dev/null)"
else
  exit 1
fi
[ -z "$content" ] && exit 1
tmux set-buffer "$content"
tmux paste-buffer -p
