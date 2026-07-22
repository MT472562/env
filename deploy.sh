#!/usr/bin/env bash
# Apply env configs to $HOME (no package installs).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

copy_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  cp -v "$src" "$dest"
}

echo "=== deploy configs ==="

copy_file "$ROOT/.bashrc" "$HOME/.bashrc"
copy_file "$ROOT/.profile" "$HOME/.profile"
copy_file "$ROOT/.tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.bashrc.d"
# Drop obsolete modules if present
rm -f "$HOME/.bashrc.d/"*.bak 2>/dev/null || true
cp -v "$ROOT"/bashrc.d/*.sh "$HOME/.bashrc.d/"

mkdir -p "$HOME/.tmux"
cp -v "$ROOT"/tmux/*.conf "$ROOT"/tmux/paste.sh "$HOME/.tmux/"
chmod +x "$HOME/.tmux/paste.sh"

mkdir -p "$HOME/.config"
[ -f "$ROOT/starship.toml" ] && copy_file "$ROOT/starship.toml" "$HOME/.config/starship.toml"

# Neovim (modular Lua config)
if [ -d "$ROOT/nvim" ]; then
  mkdir -p "$HOME/.config/nvim"
  rsync -a --delete \
    --exclude='.git' \
    "$ROOT/nvim/" "$HOME/.config/nvim/"
  echo "nvim → ~/.config/nvim"
fi

# aerc: never overwrite existing accounts (may contain secrets)
mkdir -p "$HOME/.config/aerc"
for f in "$ROOT"/aerc/*; do
  base="$(basename "$f")"
  [[ "$base" == *.example ]] && continue
  if [ "$base" = "accounts.conf" ] && [ -f "$HOME/.config/aerc/accounts.conf" ]; then
    echo "skip aerc/accounts.conf (already exists)"
    continue
  fi
  copy_file "$f" "$HOME/.config/aerc/$base"
done
if [ ! -f "$HOME/.config/aerc/accounts.conf" ] && [ -f "$ROOT/aerc/accounts.conf.example" ]; then
  copy_file "$ROOT/aerc/accounts.conf.example" "$HOME/.config/aerc/accounts.conf.example"
fi

# SSH config (keys are never shipped — only config template)
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ -f "$ROOT/ssh_config" ]; then
  copy_file "$ROOT/ssh_config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
fi

# Cargo env helper (only if cargo not yet installed)
if [ -f "$ROOT/cargo_env" ] && [ ! -f "$HOME/.cargo/env" ]; then
  mkdir -p "$HOME/.cargo"
  copy_file "$ROOT/cargo_env" "$HOME/.cargo/env"
fi

# Remove obsolete Vim-era files from home if empty/unused markers
if [ -f "$HOME/.vimrc" ] && [ ! -s "$HOME/.vimrc" ]; then
  rm -v "$HOME/.vimrc" || true
fi

echo "--- reload hooks ---"
if command -v tmux >/dev/null 2>&1; then
  tmux source-file "$HOME/.tmux.conf" 2>/dev/null && echo "tmux reloaded" || echo "tmux not running (ok)"
fi

echo "=== deploy done ==="
echo "Open a new shell (or: source ~/.bashrc) to pick up bash changes."
echo "Neovim plugins install on first launch (lazy.nvim)."
