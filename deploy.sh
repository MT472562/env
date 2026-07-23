#!/usr/bin/env bash
# env の設定を $HOME に反映する（パッケージ導入はしない）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

copy_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  cp -v "$src" "$dest"
}

# Neovim: env/nvim/ → ~/.config/nvim/
deploy_nvim() {
  local src="$ROOT/nvim"
  local dest="$HOME/.config/nvim"

  if [ ! -d "$src" ]; then
    echo "警告: $src がありません（nvim 設定をスキップ）" >&2
    return 0
  fi
  if [ ! -f "$src/init.lua" ]; then
    echo "警告: $src/init.lua がありません" >&2
    return 0
  fi

  mkdir -p "$dest"

  if command -v rsync >/dev/null 2>&1; then
    # リポジトリ側を正とし、ホーム側の余分なファイルは消す
    rsync -a --delete \
      --exclude='.git' \
      --exclude='lazy-lock.json.bak' \
      "$src/" "$dest/"
  else
    # rsync が無い環境向けフォールバック
    find "$dest" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
    cp -a "$src"/. "$dest"/
  fi

  echo "Neovim 設定を配置しました: $src → $dest"
  echo "  init.lua / lua/config / lua/plugins など"
  if command -v nvim >/dev/null 2>&1; then
    echo "  nvim: $(command -v nvim) （$(nvim --version 2>/dev/null | head -1)）"
  else
    echo "  注意: nvim コマンドが見つかりません。setup.sh で入れるか手動インストールしてください"
  fi
  echo "  プラグインは初回の nvim 起動時に lazy.nvim が導入します"
}

echo "=== 設定をデプロイ ==="

copy_file "$ROOT/.bashrc" "$HOME/.bashrc"
copy_file "$ROOT/.profile" "$HOME/.profile"
copy_file "$ROOT/.tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.bashrc.d"
rm -f "$HOME/.bashrc.d/"*.bak 2>/dev/null || true
cp -v "$ROOT"/bashrc.d/*.sh "$HOME/.bashrc.d/"

mkdir -p "$HOME/.tmux"
cp -v "$ROOT"/tmux/*.conf "$ROOT"/tmux/paste.sh "$HOME/.tmux/"
chmod +x "$HOME/.tmux/paste.sh"

mkdir -p "$HOME/.config"
[ -f "$ROOT/starship.toml" ] && copy_file "$ROOT/starship.toml" "$HOME/.config/starship.toml"

# --- Neovim ---
deploy_nvim

# --- fish（任意・対話用。無い場合はスキップ）---
if [ -d "$ROOT/fish" ]; then
  mkdir -p "$HOME/.config/fish"
  if [ -f "$ROOT/fish/config.fish" ]; then
    copy_file "$ROOT/fish/config.fish" "$HOME/.config/fish/config.fish"
  fi
  if [ -d "$ROOT/fish/completions" ]; then
    mkdir -p "$HOME/.config/fish/completions"
    cp -v "$ROOT/fish/completions/"* "$HOME/.config/fish/completions/" 2>/dev/null || true
  fi
  echo "fish 設定: env/fish → ~/.config/fish （試す: fish-try）"
fi

# --- fzf シェルスクリプト ---
if [ -d "$ROOT/fzf" ]; then
  mkdir -p "$HOME/.local/share"
  for f in fzf-key-bindings.bash fzf-completion.bash; do
    if [ -f "$ROOT/fzf/$f" ]; then
      copy_file "$ROOT/fzf/$f" "$HOME/.local/share/$f"
    fi
  done
  # バイナリが無ければ案内のみ（setup で入れる想定）
  if ! command -v fzf >/dev/null 2>&1; then
    echo "注意: fzf コマンドが PATH にありません（~/.local/bin/fzf を推奨）"
  fi
fi

# aerc: 既存の accounts.conf は上書きしない（秘密情報が入っているため）
mkdir -p "$HOME/.config/aerc"
for f in "$ROOT"/aerc/*; do
  [ -e "$f" ] || continue
  base="$(basename "$f")"
  [[ "$base" == *.example ]] && continue
  if [ "$base" = "accounts.conf" ] && [ -f "$HOME/.config/aerc/accounts.conf" ]; then
    echo "skip aerc/accounts.conf （既存を保持）"
    continue
  fi
  copy_file "$f" "$HOME/.config/aerc/$base"
done
if [ ! -f "$HOME/.config/aerc/accounts.conf" ] && [ -f "$ROOT/aerc/accounts.conf.example" ]; then
  copy_file "$ROOT/aerc/accounts.conf.example" "$HOME/.config/aerc/accounts.conf.example"
fi

# SSH config（鍵本体は含めない）
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ -f "$ROOT/ssh_config" ]; then
  copy_file "$ROOT/ssh_config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
fi

if [ -f "$ROOT/cargo_env" ] && [ ! -f "$HOME/.cargo/env" ]; then
  mkdir -p "$HOME/.cargo"
  copy_file "$ROOT/cargo_env" "$HOME/.cargo/env"
fi

# 空の古い .vimrc は削除
if [ -f "$HOME/.vimrc" ] && [ ! -s "$HOME/.vimrc" ]; then
  rm -v "$HOME/.vimrc" || true
fi

echo "--- リロード ---"
if command -v tmux >/dev/null 2>&1; then
  tmux source-file "$HOME/.tmux.conf" 2>/dev/null && echo "tmux を再読込しました" || echo "tmux は起動していません（問題なし）"
fi

echo "=== デプロイ完了 ==="
echo "  bash  : source ~/.bashrc または新しいシェル"
echo "  nvim  : ~/.config/nvim （初回起動でプラグイン導入）"
