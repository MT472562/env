if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --git'
  alias ll='eza -lah --icons --git'
  alias la='eza -a --icons --git'
  alias lt='eza --tree --icons'
else
  alias ll='ls -alF'
  alias la='ls -A'
  alias l='ls -CF'
fi
alias grep='grep --color=auto'
