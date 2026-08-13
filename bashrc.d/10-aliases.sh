# eza（アイコンは Nerd Font 端末のみ。_TERM_NF は 01-terminal.sh が定義）
if command -v eza >/dev/null 2>&1; then
  if [ "${_TERM_NF:-1}" = 1 ]; then
    alias ls='eza --icons --git'
    alias ll='eza -lah --icons --git'
    alias la='eza -a --icons --git'
    alias lt='eza --tree --icons'
  else
    alias ls='eza --git'
    alias ll='eza -lah --git'
    alias la='eza -a --git'
  fi
else
  alias ll='ls -alF'
  alias la='ls -A'
  alias l='ls -CF'
fi
alias grep='grep --color=auto'
