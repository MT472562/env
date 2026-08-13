# AtCoder environment (host side)
export ATCODER_ENV="${ATCODER_ENV:-$HOME/atcoder-env}"

# OSに合うブラウザ起動コマンドを選ぶ（WSLは端末固有設定を優先）
if [ -z "${WSL_DISTRO_NAME:-}" ] && [ -z "${WSL_INTEROP:-}" ]; then
  if [ -z "${BROWSER:-}" ]; then
    if [ "$(uname -s)" = Darwin ] && command -v open >/dev/null 2>&1; then
      export BROWSER=open
    elif command -v google-chrome >/dev/null 2>&1; then
      export BROWSER=google-chrome
    elif command -v firefox >/dev/null 2>&1; then
      export BROWSER=firefox
    elif command -v xdg-open >/dev/null 2>&1; then
      export BROWSER=xdg-open
    fi
  fi
fi

if [ -x "$ATCODER_ENV/bin/ae" ]; then
  alias ae="$ATCODER_ENV/bin/ae"
  alias ae-watch="$ATCODER_ENV/bin/ae-watch"
  alias ae-stop-watch="$ATCODER_ENV/bin/ae-watch stop"
fi
