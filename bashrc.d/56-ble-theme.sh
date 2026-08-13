# ble.sh 用 TokyoNight テーマ（56-ble-theme.sh）
#   55-ble.sh の後で読み込む。ble.sh の構文ハイライト / 補完メニュー / サジェストを
#   TokyoNight(night) パレットに揃える。
#   truecolor 端末（_TERM_TRUECOLOR=1）では #RRGGBB、それ以外は 256 色近似を使う。
#   色の上書きは ~/.bashrc.terminal で _TB_* を再定義してから source し直すか、
#   直接 ble-face で指定。

[ -n "${BLE_VERSION:-}" ] || return 0 2>/dev/null || true

# --- TokyoNight (night) パレット ---
if [ "${_TERM_TRUECOLOR:-0}" = 1 ]; then
  _TB_BG='#1a1b26'     # 背景（エディタ基準）
  _TB_BLACK='#15161e'  # terminal black
  _TB_FG='#c0caf5'     # 前景
  _TB_FG_DIM='#a9b1d6' # 強調前景
  _TB_DIM='#565f89'    # comment / 無効系
  _TB_BLUE='#7aa2f7'   # command / primary
  _TB_CYAN='#7dcfff'   # alias / 構造
  _TB_GREEN='#9ece6a'  # string / file
  _TB_YELLOW='#e0af68' # option / glob
  _TB_ORANGE='#ff9e64' # variable
  _TB_PURPLE='#bb9af7' # keyword / escape
  _TB_RED='#f7768e'    # error / builtin
else
  # 256 色近似（TokyoNight 相当の ANSI インデックス）
  _TB_BG='235'
  _TB_BLACK='234'
  _TB_FG='252'
  _TB_FG_DIM='189'
  _TB_DIM='60'
  _TB_BLUE='111'
  _TB_CYAN='117'
  _TB_GREEN='150'
  _TB_YELLOW='179'
  _TB_ORANGE='209'
  _TB_PURPLE='141'
  _TB_RED='204'
fi

# --- 構文ハイライト ---
ble-face syntax_default="fg=$_TB_FG"
ble-face syntax_command="fg=$_TB_BLUE"
ble-face syntax_quoted="fg=$_TB_GREEN"
ble-face syntax_quotation="fg=$_TB_GREEN,bold"
ble-face syntax_escape="fg=$_TB_PURPLE"
ble-face syntax_expr="fg=$_TB_BLUE"
ble-face syntax_error="fg=$_TB_BLACK,bg=$_TB_RED"
ble-face syntax_varname="fg=$_TB_ORANGE"
ble-face syntax_delimiter="fg=$_TB_FG,bold"
ble-face syntax_param_expansion="fg=$_TB_ORANGE"
ble-face syntax_history_expansion="fg=$_TB_BLACK,bg=$_TB_DIM"
ble-face syntax_function_name="fg=$_TB_BLUE,bold"
ble-face syntax_comment="fg=$_TB_DIM"
ble-face syntax_glob="fg=$_TB_YELLOW,bold"
ble-face syntax_brace="fg=$_TB_CYAN,bold"
ble-face syntax_tilde="fg=$_TB_CYAN,bold"
ble-face syntax_document="fg=$_TB_YELLOW"
ble-face syntax_document_begin="fg=$_TB_YELLOW,bold"

# --- コマンド種別 ---
ble-face command_builtin_dot="fg=$_TB_RED,bold"
ble-face command_builtin="fg=$_TB_RED"
ble-face command_alias="fg=$_TB_CYAN"
ble-face command_function="fg=$_TB_BLUE"
ble-face command_file="fg=$_TB_GREEN"
ble-face command_keyword="fg=$_TB_PURPLE"
ble-face command_jobs="fg=$_TB_RED,bold"
ble-face command_directory="fg=$_TB_BLUE,underline"
ble-face command_suffix="fg=$_TB_BLACK,bg=$_TB_GREEN"
ble-face command_suffix_new="fg=$_TB_BLACK,bg=$_TB_RED"

# --- 変数 ---
ble-face varname_unset="fg=$_TB_DIM"
ble-face varname_empty="fg=$_TB_CYAN"
ble-face varname_number="fg=$_TB_YELLOW"
ble-face varname_expr="fg=$_TB_PURPLE,bold"
ble-face varname_array="fg=$_TB_ORANGE,bold"
ble-face varname_hash="fg=$_TB_GREEN,bold"
ble-face varname_readonly="fg=$_TB_ORANGE"
ble-face varname_transform="fg=$_TB_CYAN,bold"
ble-face varname_export="fg=$_TB_ORANGE,bold"
ble-face varname_new="fg=$_TB_GREEN"

# --- 引数 / オプション ---
ble-face argument_option="fg=$_TB_YELLOW"
ble-face argument_error="fg=$_TB_BLACK,bg=$_TB_RED"

# --- 自動サジェスト / 補完メニュー ---
ble-face auto_complete="fg=$_TB_DIM"
ble-face menu_filter_fixed="fg=$_TB_BLUE,bold"
ble-face menu_filter_input="fg=$_TB_BLACK,bg=$_TB_BLUE"
ble-face menu_desc_default="fg=$_TB_DIM"
ble-face menu_complete_match="fg=$_TB_GREEN,bold"
ble-face menu_complete_selected="fg=$_TB_BLACK,bg=$_TB_BLUE"

# --- 編集領域 ---
ble-face region="fg=$_TB_BLACK,bg=$_TB_FG_DIM"
ble-face region_match="fg=$_TB_BLACK,bg=$_TB_PURPLE"
ble-face overwrite_mode="fg=$_TB_BLACK,bg=$_TB_CYAN"
ble-face disabled="fg=$_TB_DIM"
ble-face prompt_status_line="fg=$_TB_BLACK,bg=$_TB_BLUE"

unset _TB_BG _TB_BLACK _TB_FG _TB_FG_DIM _TB_DIM _TB_BLUE _TB_CYAN _TB_GREEN \
      _TB_YELLOW _TB_ORANGE _TB_PURPLE _TB_RED
