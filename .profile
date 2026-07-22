# ~/.profile — login shells (sourced by display manager / ssh login)

# if running bash
if [ -n "${BASH_VERSION:-}" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

# user bins
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

# Rust (idempotent; bashrc.d/60-cargo.sh also sources this for non-login shells)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
