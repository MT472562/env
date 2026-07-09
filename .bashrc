for f in ~/.bashrc.d/*.sh; do
    [ -f "$f" ] && . "$f"
done
