# fzf: あいまい補完・履歴・ファイル検索
#   Ctrl-R  コマンド履歴
#   Ctrl-T  ファイル挿入
#   Alt-C   ディレクトリへ cd
#   **<Tab> あいまいパス補完

command -v fzf >/dev/null 2>&1 || return 0 2>/dev/null || true

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
elif command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
elif command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'

if command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || head -200 {}'"
else
  export FZF_CTRL_T_OPTS="--preview 'head -200 {} 2>/dev/null || ls -la {}'"
fi
if command -v eza >/dev/null 2>&1; then
  export FZF_ALT_C_OPTS="--preview 'eza -la --icons {} 2>/dev/null || ls -la {}'"
else
  export FZF_ALT_C_OPTS="--preview 'ls -la {}'"
fi

# 公式スクリプト（優先: ~/.local/share → ~/env/fzf）
_fzf_dir=""
if [ -f "$HOME/.local/share/fzf-key-bindings.bash" ]; then
  _fzf_dir="$HOME/.local/share"
elif [ -f "$HOME/env/fzf/fzf-key-bindings.bash" ]; then
  _fzf_dir="$HOME/env/fzf"
fi

if [ -n "$_fzf_dir" ]; then
  # shellcheck disable=SC1091
  [ -f "$_fzf_dir/fzf-key-bindings.bash" ] && . "$_fzf_dir/fzf-key-bindings.bash"
  # shellcheck disable=SC1091
  [ -f "$_fzf_dir/fzf-completion.bash" ] && . "$_fzf_dir/fzf-completion.bash"
fi
unset _fzf_dir
