# bash 補完の本体（キー操作の強化は 55-ble.sh / ble.sh が担当）
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
