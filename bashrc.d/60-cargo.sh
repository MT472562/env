# Rust / Go PATH (skip if not installed)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
prepend_path /usr/local/go/bin
