# ~/.bashrc — interactive shell only; modules live in ~/.bashrc.d/
case $- in *i*) ;; *) return ;; esac

for f in ~/.bashrc.d/*.sh; do
  [ -f "$f" ] && . "$f"
done
