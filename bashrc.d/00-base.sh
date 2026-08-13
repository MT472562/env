# 対話シェルの基本（.bashrc が interactive のときだけ読まれる）
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend checkwinsize cmdhist lithist 2>/dev/null || shopt -s histappend checkwinsize
# 履歴を厚く（Ctrl-R / fzf 用）
HISTSIZE=50000
HISTFILESIZE=100000
# 複数端末でも履歴を追記共有しやすく
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a"

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ディレクトリ名だけで cd、タイポ補正
shopt -s autocd 2>/dev/null || true
shopt -s cdspell dirspell 2>/dev/null || true
shopt -s globstar 2>/dev/null || true

# 存在する dir を PATH 先頭へ（冪等）
prepend_path() {
  local dir="$1"
  [ -d "$dir" ] || return 0
  case ":$PATH:" in *":$dir:"*) ;; *) PATH="$dir:$PATH" ;; esac
}

# ---------------------------------------------------------------------------
# WSL: Windows 側 PATH (/mnt/c/...) を落とす
#   interop が Windows の PATH を丸ごと足すとエントリが 50 超になり、
#   存在しないコマンドの command -v / 補完のたびに 9p マウントを舐めて数百 ms 遅延する。
#   無効化: export KEEP_WIN_PATH=1  または  touch ~/.keep_win_path
#   恒久策: /etc/wsl.conf に [interop] appendWindowsPath = false
# ---------------------------------------------------------------------------
if [ -z "${KEEP_WIN_PATH:-}" ] && [ ! -f "$HOME/.keep_win_path" ]; then
  if [ -n "${WSL_DISTRO_NAME:-}${WSL_INTEROP:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then
    case ":$PATH:" in
      *:/mnt/[a-zA-Z]/* | *:/mnt/[a-zA-Z]:*)
        _new_path=
        _ifs="$IFS"
        IFS=:
        for _p in $PATH; do
          case "$_p" in
            /mnt/[a-zA-Z]/* | /mnt/[a-zA-Z]) continue ;;
          esac
          if [ -n "$_p" ]; then
            if [ -z "$_new_path" ]; then
              _new_path="$_p"
            else
              _new_path="$_new_path:$_p"
            fi
          fi
        done
        IFS="$_ifs"
        PATH="$_new_path"
        unset _new_path _p _ifs
        export PATH
        ;;
    esac
  fi
fi
