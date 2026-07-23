# bash 補完の本体 + readline を厚くする
if shopt -oq posix; then
  return 0 2>/dev/null || exit 0
fi

if [ -f /usr/share/bash-completion/bash_completion ]; then
  # shellcheck disable=SC1091
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  # shellcheck disable=SC1091
  . /etc/bash_completion
fi

# --- readline: 補完の挙動を強化 ---
# 大文字小文字を無視（Git / パスが楽）
bind 'set completion-ignore-case on' 2>/dev/null || true
# あいまいなとき一覧をすぐ出す
bind 'set show-all-if-ambiguous on' 2>/dev/null || true
bind 'set show-all-if-unmodified on' 2>/dev/null || true
# 一覧を色付き（LS_COLORS）
bind 'set colored-stats on' 2>/dev/null || true
bind 'set colored-completion-prefix on' 2>/dev/null || true
# 長い一覧はページャ風
bind 'set page-completions on' 2>/dev/null || true
bind 'set completion-query-items 200' 2>/dev/null || true
# メニュー補完: Tab 連打で候補を順送り（Shift-Tab で戻る）
bind 'TAB:menu-complete' 2>/dev/null || true
bind '"\e[Z":menu-complete-backward' 2>/dev/null || true
# 共通プレフィックスを先に埋める
bind 'set menu-complete-display-prefix on' 2>/dev/null || true
# 単語区切り（パスやオプションが切れやすい文字を調整）
bind 'set skip-completed-text on' 2>/dev/null || true

# ディレクトリ補完のあと / を付ける
bind 'set mark-directories on' 2>/dev/null || true
bind 'set mark-symlinked-directories on' 2>/dev/null || true

# 履歴検索: 途中まで打って↑↓で前方一致
bind '"\e[A": history-search-backward' 2>/dev/null || true
bind '"\e[B": history-search-forward' 2>/dev/null || true
# Ctrl-P / Ctrl-N も同様
bind '"\C-p": history-search-backward' 2>/dev/null || true
bind '"\C-n": history-search-forward' 2>/dev/null || true
