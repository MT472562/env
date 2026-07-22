# Auto-attach a default tmux session on interactive TTYs only
# Disable: touch ~/.no_tmux_auto or export NO_TMUX_AUTO=1
if [ -n "${NO_TMUX_AUTO:-}" ] || [ -f "$HOME/.no_tmux_auto" ]; then
  return 0
fi
if command -v tmux >/dev/null 2>&1 && [ -z "${TMUX:-}" ] && [ -t 0 ]; then
  tmux attach -t default 2>/dev/null || tmux new -s default
fi
