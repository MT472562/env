# GitHub CLI (gh) — prefer this for all GitHub auth / repo ops
# Ensure user-local install is on PATH (e.g. ~/.local/bin/gh)
[ -d "$HOME/.local/bin" ] && case ":$PATH:" in *:"$HOME/.local/bin":*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac

# Completions when available
if command -v gh >/dev/null 2>&1; then
  if [ -n "${BASH_VERSION:-}" ]; then
    eval "$(gh completion -s bash 2>/dev/null)" || true
  fi
fi
