# ble.sh: ラインエディタ（構文ハイライト）。自動補完は無効（WSL で遅すぎたため削除）
#   50-starship.sh の後（PS1 確定後）に読む。無ければ fzf の公式キーバインドにフォールバック。
#   無効化: touch ~/.no_ble または export NO_BLE=1
#   補完は Tab（bash 標準）と fzf（Ctrl-R / Ctrl-T / Alt-C / **<Tab>）だけ。

# fzf が ~/.local/bin に居る場合（71-gh.sh より先に読むため明示）
prepend_path "$HOME/.local/bin"

_BLE_ACTIVE=0
if [ -z "${NO_BLE:-}" ] && [ ! -f "$HOME/.no_ble" ]; then
  # --- ble.sh 本体を読み込む ---
  _BLE=
  if [ -f "$HOME/.local/share/blesh/out/ble.sh" ]; then
    _BLE="$HOME/.local/share/blesh/out/ble.sh"
  elif [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
    _BLE="$HOME/.local/share/blesh/ble.sh"
  fi

  if [ -n "$_BLE" ]; then
    # shellcheck disable=SC1090
    . "$_BLE" || return 1 2>/dev/null || true
  fi
  unset _BLE

  # --- ble.sh 有効時 ---
  if [ -n "${BLE_VERSION:-}" ]; then
    _BLE_ACTIVE=1

    # --- 自動補完はすべてオフ（遅延の元凶だったので削除）---
    bleopt complete_auto_complete=   # 灰色の自動サジェスト
    bleopt complete_auto_menu=       # 入力停止後の自動メニュー
    bleopt complete_auto_history=    # 履歴ベース自動補完
    bleopt complete_menu_complete=   # Tab メニュー補完モード
    bleopt complete_menu_filter=     # メニュー中の自動絞り込み
    bleopt complete_ambiguous=       # 曖昧補完

    # fzf 連携で使う「コマンド実行＋入力を再送」を誤ってペースト扱いにしない
    bleopt accept_line_threshold=15
    # "[ble: ...]" 系の雑音マーカーを消す
    bleopt prompt_eol_mark=''
    bleopt exec_errexit_mark=''
    bleopt exec_exit_mark=''
    bleopt edit_marker=''
    bleopt edit_marker_error=''

    # ファイル名ハイライトは stat 連発になる（特に /mnt/* で重い）→ 切る
    if [ -n "${WSL_DISTRO_NAME:-}${WSL_INTEROP:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then
      bleopt highlight_filename=
    fi

    # fzf 統合（Ctrl-R / Ctrl-T / Alt-C / **<Tab>）— fzf>=0.48 は内部で eval "$(fzf --bash)" を使用
    ble-import integration/fzf-key-bindings
    ble-import integration/fzf-completion
  fi
fi

# --- ble.sh 無しのフォールバック: fzf の公式シェル統合 ---
if [ "$_BLE_ACTIVE" -eq 0 ] && command -v fzf >/dev/null 2>&1; then
  # fzf >= 0.48
  eval "$(fzf --bash 2>/dev/null)" || true
  # 古い fzf / --bash が使えない場合のフォールバック（deploy.sh が配置）
  if ! command -v _fzf_complete >/dev/null 2>&1 || ! command -v __fzf_history__ >/dev/null 2>&1; then
    for _f in "$HOME/.local/share/fzf/key-bindings.bash" "$HOME/.local/share/fzf/completion.bash" \
              "$HOME/env/fzf/fzf-key-bindings.bash" "$HOME/env/fzf/fzf-completion.bash"; do
      [ -f "$_f" ] && . "$_f" 2>/dev/null || true
    done
    unset _f
  fi
fi
unset _BLE_ACTIVE
