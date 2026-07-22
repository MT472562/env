# Grok Build CLI (optional)
[ -d "$HOME/.grok/bin" ] && case ":$PATH:" in *:"$HOME/.grok/bin":*) ;; *) PATH="$HOME/.grok/bin:$PATH" ;; esac
[ -r "$HOME/.grok/completions/bash/grok.bash" ] && . "$HOME/.grok/completions/bash/grok.bash"
