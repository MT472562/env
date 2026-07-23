# よく使う CLI の bash 補完を足す（あるものだけ）

# GitHub CLI
if command -v gh >/dev/null 2>&1; then
  eval "$(gh completion -s bash 2>/dev/null)" || true
fi

# rustup / cargo
if command -v rustup >/dev/null 2>&1; then
  eval "$(rustup completions bash 2>/dev/null)" || true
  eval "$(rustup completions bash cargo 2>/dev/null)" || true
fi

# npm / npx（nvm 利用時）
if command -v npm >/dev/null 2>&1; then
  eval "$(npm completion 2>/dev/null)" || true
fi

# pip / pipx
if command -v pip >/dev/null 2>&1; then
  eval "$(pip completion --bash 2>/dev/null)" || true
fi

# docker / podman
if command -v docker >/dev/null 2>&1 && [ -f /usr/share/bash-completion/completions/docker ]; then
  # shellcheck disable=SC1091
  . /usr/share/bash-completion/completions/docker 2>/dev/null || true
fi

# kubectl
if command -v kubectl >/dev/null 2>&1; then
  eval "$(kubectl completion bash 2>/dev/null)" || true
fi

# terraform / tofu
if command -v terraform >/dev/null 2>&1; then
  complete -C terraform terraform 2>/dev/null || true
fi

# starship（特に補完は少ないが念のため）
# grok は 73-grok.sh 側

# ssh: host 補完を厚く（config + known_hosts）
_ssh_hosts_completion() {
  local cur opts
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts=""
  if [ -f "$HOME/.ssh/config" ]; then
    opts+=" $(grep -E '^[Hh]ost ' "$HOME/.ssh/config" 2>/dev/null | awk '{for(i=2;i<=NF;i++) if($i!~/[*?]/ print $i}')"
  fi
  if [ -f "$HOME/.ssh/known_hosts" ]; then
    opts+=" $(awk '{print $1}' "$HOME/.ssh/known_hosts" 2>/dev/null | tr ',' '\n' | grep -v '^[|=]' | cut -d: -f1)"
  fi
  # shellcheck disable=SC2207
  COMPREPLY=($(compgen -W "$opts" -- "$cur"))
}
# bash-completion の ssh が無いときだけ
if ! complete -p ssh >/dev/null 2>&1; then
  complete -F _ssh_hosts_completion ssh scp sftp 2>/dev/null || true
fi
