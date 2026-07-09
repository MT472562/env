#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/MT472562/env.git"
REPO_DIR="$HOME/env"

# このスクリプトがリポジトリ内から実行されているか確認
if [ ! -f "$(dirname "$0")/.tmux.conf" ]; then
  echo "--- Cloning env repo ---"
  if [ -d "$REPO_DIR" ]; then
    echo "Updating existing repo..."
    git -C "$REPO_DIR" pull
  else
    git clone "$REPO_URL" "$REPO_DIR"
  fi
  cd "$REPO_DIR"
else
  cd "$(dirname "$0")"
fi

echo "=== env setup ==="

echo "--- Config files ---"
cp -v .bashrc     ~/.bashrc
mkdir -p ~/.bashrc.d
cp -v bashrc.d/*.sh ~/.bashrc.d/
cp -v .tmux.conf  ~/.tmux.conf
cp -v .vimrc      ~/.vimrc
cp -v .profile    ~/.profile
mkdir -p ~/.cargo
cp -v cargo_env   ~/.cargo/env
mkdir -p ~/.config
cp -v starship.toml   ~/.config/starship.toml
mkdir -p ~/.config/aerc
cp -v aerc/*          ~/.config/aerc/
mkdir -p ~/.ssh
cp -v ssh_config ~/.ssh/config

echo "--- Tmux sub-configs ---"
mkdir -p ~/.tmux
cp -v tmux/*.conf tmux/paste.sh ~/.tmux/

echo "--- Font ---"
echo "Install PlemolJP Console NF from:"
echo "  https://github.com/yuru7/PlemolJP/releases"

echo "--- apt ---"
sudo apt update
sudo apt install -y eza

echo "--- NVM ---"
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts

echo "--- Rust ---"
if ! command -v rustup &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

echo "--- Starship ---"
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh
fi

echo "--- Tmux TPM ---"
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "--- Vim ---"
if [ ! -f ~/.vim/autoload/plug.vim ]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "=== Apply ==="
bash deploy.sh
