# fzf: 環境変数（検索コマンド・表示・プレビュー）
#   キーバインド / **<Tab> 補完の読み込みは 55-ble.sh が ble 有無で切替
#   Ctrl-R  コマンド履歴
#   Ctrl-T  ファイル挿入
#   Alt-C   ディレクトリへ cd
#   **<Tab> あいまいパス補完
#
#   注意: Debian/Ubuntu のパッケージ名は fdfind。存在しない `fd` を先に
#   command -v すると、WSL+Windows PATH 時に 9p を全走査して遅くなる。

command -v fzf >/dev/null 2>&1 || return 0 2>/dev/null || true

# fd 系（パッケージ名優先 → 本家名）
if command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
elif command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
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
