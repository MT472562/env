#!/usr/bin/env bash
# Publish this env repo with gh (create remote if needed + push).
# Usage:
#   bash scripts/gh-publish.sh                 # private, owner = gh user
#   bash scripts/gh-publish.sh --public
#   bash scripts/gh-publish.sh --repo owner/name
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VISIBILITY=private
REPO_NAME=""

for arg in "$@"; do
  case "$arg" in
    --public) VISIBILITY=public ;;
    --private) VISIBILITY=private ;;
    --repo=*) REPO_NAME="${arg#--repo=}" ;;
    --repo)
      shift || true
      ;;
    -h | --help)
      sed -n '2,8p' "$0"
      exit 0
      ;;
  esac
done
# re-parse --repo value if passed as separate arg (simple)
prev=""
for arg in "$@"; do
  if [ "$prev" = "--repo" ]; then
    REPO_NAME="$arg"
  fi
  prev="$arg"
done

if ! command -v gh >/dev/null 2>&1; then
  echo "gh not found. Install: https://cli.github.com/  (or re-run setup.sh)" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Not logged in. Running: gh auth login"
  echo "  Prefer: GitHub.com → HTTPS → Login with a web browser"
  gh auth login
fi

# Wire git to use gh credentials (HTTPS happy path)
gh auth setup-git

OWNER="$(gh api user --jq .login)"
NAME="$(basename "$ROOT")"
FULL="${REPO_NAME:-$OWNER/$NAME}"

echo "=== publish $ROOT → github.com/$FULL ($VISIBILITY) ==="

# Ensure origin points at the intended repo (HTTPS — gh manages tokens)
TARGET="https://github.com/${FULL}.git"
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$TARGET"
else
  git remote add origin "$TARGET"
fi
# Drop leftover alternate remotes from experiments
git remote remove maruchan 2>/dev/null || true

if gh repo view "$FULL" >/dev/null 2>&1; then
  echo "remote exists: $FULL"
  git push -u origin HEAD
else
  echo "creating $FULL ..."
  gh repo create "$FULL" \
    --"$VISIBILITY" \
    --source=. \
    --remote=origin \
    --push
fi

echo "=== done ==="
gh repo view "$FULL" --web 2>/dev/null || gh repo view "$FULL"
