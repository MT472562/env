# Prefer Neovim when available
if command -v nvim >/dev/null 2>&1; then
  alias vim='nvim'
  export EDITOR="${EDITOR:-nvim}"
  export VISUAL="${VISUAL:-nvim}"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="${EDITOR:-vim}"
  export VISUAL="${VISUAL:-vim}"
fi
