if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux attach -t default 2>/dev/null || tmux new -s default
fi
