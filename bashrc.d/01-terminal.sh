# 端末依存設定の一元管理（01-terminal.sh）
#   検出結果は _TERM_* に格納し、後続モジュールが参照する（00-base より後に読む）。
#   端末ごとの上書きは ~/.bashrc.terminal に書く（このファイルの後で source）。

_TERM_TRUECOLOR=0   # 24bit 色対応
_TERM_WAYLAND=0     # Wayland セッション
_TERM_NF=1          # Nerd Font アイコンを使う（無い端末は .bashrc.terminal で 0 に）

# --- truecolor 判定 ---
case "${COLORTERM:-}" in
  truecolor | 24bit) _TERM_TRUECOLOR=1 ;;
  no-truecolor | no_color) _TERM_TRUECOLOR=0 ;;
esac
case "$TERM" in
  *-truecolor | *-direct | alacritty | kitty | tmux-direct | screen-direct | wezterm) _TERM_TRUECOLOR=1 ;;
esac

# --- クリップボード（Wayland / X11）---
[ -n "${WAYLAND_DISPLAY:-}" ] && _TERM_WAYLAND=1

# --- 端末ごとの上書き ---
# 例: _TERM_NF=0  # Nerd Font 非対応端末
#     BROWSER=firefox
[ -f "$HOME/.bashrc.terminal" ] && . "$HOME/.bashrc.terminal"

# truecolor 端末なら COLORTERM を公開（アプリの 24bit 有効化）
if [ "$_TERM_TRUECOLOR" -eq 1 ] && [ -z "${COLORTERM:-}" ]; then
  export COLORTERM=truecolor
fi
