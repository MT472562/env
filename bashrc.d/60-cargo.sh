# Rust / Go PATH (skip if not installed)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -d /usr/local/go/bin ] && case ":$PATH:" in *:/usr/local/go/bin:*) ;; *) PATH="$PATH:/usr/local/go/bin" ;; esac
