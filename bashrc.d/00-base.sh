# 対話シェルの基本（.bashrc が interactive のときだけ読まれる）
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend checkwinsize cmdhist lithist 2>/dev/null || shopt -s histappend checkwinsize
# 履歴を厚く（Ctrl-R / fzf 用）
HISTSIZE=50000
HISTFILESIZE=100000
# 複数端末でも履歴を追記共有しやすく
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a"

export COLORTERM=truecolor
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ディレクトリ名だけで cd、タイポ補正
shopt -s autocd 2>/dev/null || true
shopt -s cdspell dirspell 2>/dev/null || true
shopt -s globstar 2>/dev/null || true
