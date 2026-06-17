#!/usr/bin/env bash
set -euo pipefail

echo "=== env setup ==="

cd "$(dirname "$0")"

echo "--- Config files ---"
cp -v "[.]bashrc"     ~/.bashrc
cp -v "[.]tmux.conf"  ~/.tmux.conf
cp -v "[.]vimrc"      ~/.vimrc
cp -v "[.]profile"    ~/.profile
cp -v "[.]cargo_env"  ~/.cargo/env
mkdir -p ~/.config/starship.toml && rm -f ~/.config/starship.toml
cp -v starship.toml   ~/.config/starship.toml
mkdir -p ~/.config/aerc
cp -v aerc/*          ~/.config/aerc/
mkdir -p ~/.ssh
cp -v "[.]ssh_config" ~/.ssh/config

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
echo "Run 'Prefix + I' inside tmux to install plugins."

echo "--- Vim ---"
if [ ! -f ~/.vim/autoload/plug.vim ]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
echo "Run ':PlugInstall' inside vim to install plugins."

echo "=== Done! Restart your shell: exec \$SHELL ==="
