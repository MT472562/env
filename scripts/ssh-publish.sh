#!/usr/bin/env bash
# Publish this env repo over SSH (multi-account Host alias).
# Does NOT create the empty repo on GitHub (do that once in the UI if missing).
#
# Usage:
#   bash scripts/ssh-publish.sh maruchandev maruchandev/env
#   bash scripts/ssh-publish.sh mt472562 MT472562/env
#   bash scripts/ssh-publish.sh              # defaults: maruchandev / maruchandev/env
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ACCOUNT="${1:-maruchandev}"
FULL="${2:-}"

case "$ACCOUNT" in
  maruchandev | maruchan | personal)
    ACCOUNT=maruchandev
    FULL="${FULL:-maruchandev/env}"
    ;;
  mt472562 | mt | work)
    ACCOUNT=mt472562
    FULL="${FULL:-MT472562/env}"
    ;;
esac

echo "=== SSH publish → $FULL (account=$ACCOUNT) ==="

bash "$ROOT/scripts/ssh-github.sh" test "$ACCOUNT" || true
bash "$ROOT/scripts/ssh-github.sh" remote "$ACCOUNT" "$FULL"

# Ensure config is deployed
if [ -f "$ROOT/ssh_config" ]; then
  mkdir -p "$HOME/.ssh"
  cp "$ROOT/ssh_config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
fi

if ! git push -u origin HEAD; then
  echo
  echo "push failed. Checklist:"
  echo "  1) Key registered on the correct GitHub account?"
  echo "       bash scripts/ssh-github.sh pubkey $ACCOUNT"
  echo "       → https://github.com/settings/keys"
  echo "  2) Empty repo exists? Create: https://github.com/new"
  echo "       name: ${FULL#*/}  owner: ${FULL%%/*}  (no README)"
  echo "  3) Re-test: bash scripts/ssh-github.sh status"
  exit 1
fi

echo "=== done ==="
git remote -v
