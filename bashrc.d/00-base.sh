case $- in *i*) ;; *) return;; esac
HISTCONTROL=ignoreboth
shopt -s histappend checkwinsize
HISTSIZE=1000 HISTFILESIZE=2000
export COLORTERM=truecolor
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
