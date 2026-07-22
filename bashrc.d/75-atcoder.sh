# AtCoder environment (host side)
export ATCODER_ENV="${ATCODER_ENV:-$HOME/atcoder-env}"

# Prefer a real browser on native Linux (wslview is WSL-only)
if [ -z "${WSL_DISTRO_NAME:-}" ] && [ -z "${WSL_INTEROP:-}" ]; then
  if [ -z "${BROWSER:-}" ]; then
    if command -v google-chrome >/dev/null 2>&1; then
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
