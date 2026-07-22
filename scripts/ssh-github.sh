#!/usr/bin/env bash
# Multi-account GitHub over SSH (Host aliases + per-account keys).
#
# Usage:
#   ssh-github.sh status              # who each Host authenticates as
#   ssh-github.sh accounts            # list configured accounts
#   ssh-github.sh gen <account>       # generate ~/.ssh/id_<account> if missing
#   ssh-github.sh pubkey <account>    # print public key to register on GitHub
#   ssh-github.sh test <account>      # ssh -T for that account
#   ssh-github.sh remote <account> [owner/repo]   # set origin to SSH alias URL
#   ssh-github.sh use <account>       # print clone/remote examples
#   ssh-github.sh push                # git push (current origin)
#
# Account names map to:
#   Host github.com-<account>
#   Key  ~/.ssh/id_<account>   (maruchandev → id_maruchan for history)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# account → key file basename (under ~/.ssh/)
key_for() {
  case "$1" in
    maruchandev | maruchan | personal) echo "id_maruchan" ;;
    mt472562 | mt | work) echo "id_mt472562" ;;
    *) echo "id_$1" ;;
  esac
}

host_for() {
  case "$1" in
    maruchandev | maruchan | personal) echo "github.com-maruchandev" ;;
    mt472562 | mt | work) echo "github.com-mt472562" ;;
    *) echo "github.com-$1" ;;
  esac
}

normalize_account() {
  case "$1" in
    maruchan | personal) echo "maruchandev" ;;
    mt | work) echo "mt472562" ;;
    *) echo "$1" ;;
  esac
}

cmd_accounts() {
  cat <<'EOF'
Configured GitHub accounts (SSH Host aliases):

  account       Host alias                 Key
  -----------   ------------------------   -------------------
  maruchandev   github.com-maruchandev     ~/.ssh/id_maruchan
  mt472562      github.com-mt472562        ~/.ssh/id_mt472562

Clone examples:
  git clone git@github.com-maruchandev:maruchandev/env.git
  git clone git@github.com-mt472562:MT472562/env.git

Set this repo's origin:
  bash scripts/ssh-github.sh remote maruchandev maruchandev/env
  bash scripts/ssh-github.sh remote mt472562 MT472562/env
EOF
}

cmd_status() {
  mkdir -p "$HOME/.ssh"
  echo "=== keys ==="
  for k in id_maruchan id_mt472562 id_github id_ed25519; do
    if [ -f "$HOME/.ssh/$k" ]; then
      printf "  %-14s " "$k"
      ssh-keygen -lf "$HOME/.ssh/$k.pub" 2>/dev/null || echo "(no .pub)"
    fi
  done
  echo
  echo "=== ssh -T per Host ==="
  for acc in maruchandev mt472562; do
    local host key
    host="$(host_for "$acc")"
    key="$(key_for "$acc")"
    printf "  %-28s " "$host"
    if [ ! -f "$HOME/.ssh/$key" ]; then
      echo "NO KEY ($key)"
      continue
    fi
    # ssh -T returns 1 on success for GitHub
    set +e
    out="$(ssh -o BatchMode=yes -o ConnectTimeout=8 -T "git@$host" 2>&1)"
    set -e
    echo "$out" | head -1
  done
  echo
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "=== this repo remotes ==="
    git remote -v
  fi
}

cmd_gen() {
  local acc key comment dest
  acc="$(normalize_account "${1:?account required}")"
  key="$(key_for "$acc")"
  dest="$HOME/.ssh/$key"
  comment="${acc}@github"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  if [ -e "$dest" ]; then
    echo "exists: $dest"
    cat "${dest}.pub"
    return 0
  fi
  ssh-keygen -t ed25519 -f "$dest" -C "$comment" -N ""
  chmod 600 "$dest"
  chmod 644 "${dest}.pub"
  echo "generated $dest"
  echo
  echo "Add this public key to GitHub user '$acc':"
  echo "  https://github.com/settings/keys"
  cat "${dest}.pub"
}

cmd_pubkey() {
  local acc key
  acc="$(normalize_account "${1:?account required}")"
  key="$(key_for "$acc")"
  if [ ! -f "$HOME/.ssh/${key}.pub" ]; then
    echo "missing ~/.ssh/${key}.pub — run: $0 gen $acc" >&2
    exit 1
  fi
  cat "$HOME/.ssh/${key}.pub"
  echo
  echo "# Register at: https://github.com/settings/keys  (account: $acc)"
}

cmd_test() {
  local acc host
  acc="$(normalize_account "${1:?account required}")"
  host="$(host_for "$acc")"
  echo "ssh -T git@$host"
  ssh -T "git@$host" || true
}

cmd_remote() {
  local acc host full owner repo url
  acc="$(normalize_account "${1:?account required}")"
  host="$(host_for "$acc")"
  full="${2:-}"
  if [ -z "$full" ]; then
    # try to infer from existing origin
    if git remote get-url origin >/dev/null 2>&1; then
      local cur
      cur="$(git remote get-url origin)"
      # extract owner/repo from various URL forms
      full="$(printf '%s' "$cur" | sed -E 's#.*[:/]([^/]+/[^/]+?)(\.git)?$#\1#' | sed 's/\.git$//')"
    fi
  fi
  if [ -z "$full" ] || [[ "$full" != */* ]]; then
    echo "usage: $0 remote <account> <owner/repo>" >&2
    exit 1
  fi
  url="git@${host}:${full}.git"
  if git remote get-url origin >/dev/null 2>&1; then
    git remote set-url origin "$url"
  else
    git remote add origin "$url"
  fi
  # drop experimental remotes
  git remote remove maruchan 2>/dev/null || true
  echo "origin → $url"
  git remote -v
}

cmd_use() {
  local acc host key
  acc="$(normalize_account "${1:?account required}")"
  host="$(host_for "$acc")"
  key="$(key_for "$acc")"
  cat <<EOF
Account: $acc
Host:    $host
Key:     ~/.ssh/$key

# Test
ssh -T git@$host

# Clone
git clone git@$host:OWNER/REPO.git

# Point current repo origin here
bash $ROOT/scripts/ssh-github.sh remote $acc OWNER/REPO

# Push
git push -u origin main
EOF
}

cmd_push() {
  git push -u origin HEAD
}

usage() {
  sed -n '2,16p' "$0"
}

main() {
  local cmd="${1:-status}"
  shift || true
  case "$cmd" in
    status | st) cmd_status "$@" ;;
    accounts | ls) cmd_accounts "$@" ;;
    gen | generate) cmd_gen "$@" ;;
    pubkey | pub) cmd_pubkey "$@" ;;
    test | t) cmd_test "$@" ;;
    remote | origin) cmd_remote "$@" ;;
    use | how) cmd_use "$@" ;;
    push) cmd_push "$@" ;;
    -h | --help | help) usage ;;
    *)
      echo "unknown: $cmd" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
