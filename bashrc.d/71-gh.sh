# GitHub CLI (gh) — 認証・repo 操作は gh に統一
# 補完は 32-tool-completions.sh 側。ここは PATH のみ。
[ -d "$HOME/.local/bin" ] && case ":$PATH:" in *:"$HOME/.local/bin":*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac
