#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

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
mkdir -p ~/.tmux
cp -v tmux/*.conf tmux/paste.sh ~/.tmux/

echo "--- tmux ---"
tmux source ~/.tmux.conf 2>/dev/null && echo "tmux reloaded" || echo "tmux not running"

echo "--- vim ---"
if [ -f ~/.vim/autoload/plug.vim ]; then
    vim +PlugInstall +qall 2>/dev/null && echo "vim plugins installed"
fi

echo "--- shell ---"
exec "$SHELL"
