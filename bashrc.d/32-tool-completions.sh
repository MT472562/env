# よく使う CLI の bash 補完
#   npm / pip / gh 等を毎回 eval すると WSL で数百 ms かかるため、
#   ~/.cache/bash-completions/ にキャッシュして source する。
#   ツールのバイナリがキャッシュより新しいときだけ再生成。

_COMP_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/bash-completions"
mkdir -p "$_COMP_CACHE_DIR" 2>/dev/null || true

# $1=cache名  $2=command名  残り=生成コマンド
_comp_cache_load() {
  local name="$1" cmd="$2"
  shift 2
  local bin cache
  bin=$(command -v "$cmd" 2>/dev/null) || return 0
  cache="$_COMP_CACHE_DIR/$name"
  if [ ! -f "$cache" ] || [ "$bin" -nt "$cache" ]; then
    if ! "$@" >"$cache" 2>/dev/null; then
      rm -f "$cache" 2>/dev/null || true
      return 0
    fi
  fi
  # shellcheck disable=SC1090
  . "$cache" 2>/dev/null || true
}

# GitHub CLI
_comp_cache_load gh gh gh completion -s bash

# rustup / cargo（1 ファイルにまとめる）
if command -v rustup >/dev/null 2>&1; then
  _comp_cache_load rustup rustup bash -c \
    'rustup completions bash; rustup completions bash cargo'
fi

# npm / npx
_comp_cache_load npm npm npm completion

# pip
_comp_cache_load pip pip pip completion --bash

# docker / podman（パッケージ同梱の静的スクリプト）
if command -v docker >/dev/null 2>&1 && [ -f /usr/share/bash-completion/completions/docker ]; then
  # shellcheck disable=SC1091
  . /usr/share/bash-completion/completions/docker 2>/dev/null || true
fi

# kubectl
_comp_cache_load kubectl kubectl kubectl completion bash

# terraform / tofu（バイナリ自身が complete -C で遅延生成）
if command -v terraform >/dev/null 2>&1; then
  complete -C terraform terraform 2>/dev/null || true
fi

# ssh: host 補完を厚く（config + known_hosts）— bash-completion の ssh が無いときだけ
if ! complete -p ssh >/dev/null 2>&1; then
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
  complete -F _ssh_hosts_completion ssh scp sftp 2>/dev/null || true
fi

unset -f _comp_cache_load
unset _COMP_CACHE_DIR
