#!/usr/bin/env bash
# この env リポジトリを gh で公開（未作成なら create + push）
#
# 使い方:
#   bash scripts/gh-publish.sh                 # 非公開・gh ログイン中のユーザー
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
    -h | --help)
      sed -n '2,8p' "$0"
      exit 0
      ;;
  esac
done
prev=""
for arg in "$@"; do
  if [ "$prev" = "--repo" ]; then
    REPO_NAME="$arg"
  fi
  prev="$arg"
done

if ! command -v gh >/dev/null 2>&1; then
  echo "gh がありません。setup.sh を実行するか https://cli.github.com/ を参照" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "未ログインです。gh auth login を実行します"
  echo "  推奨: GitHub.com → HTTPS → ブラウザでログイン"
  gh auth login
fi

gh auth setup-git

OWNER="$(gh api user --jq .login)"
NAME="$(basename "$ROOT")"
FULL="${REPO_NAME:-$OWNER/$NAME}"

echo "=== 公開: $ROOT → github.com/$FULL （$VISIBILITY）==="

TARGET="https://github.com/${FULL}.git"
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$TARGET"
else
  git remote add origin "$TARGET"
fi
git remote remove maruchan 2>/dev/null || true

if gh repo view "$FULL" >/dev/null 2>&1; then
  echo "リモートは既にあります: $FULL"
  git push -u origin HEAD
else
  echo "リポジトリを作成します: $FULL"
  gh repo create "$FULL" \
    --"$VISIBILITY" \
    --source=. \
    --remote=origin \
    --push
fi

echo "=== 完了 ==="
gh repo view "$FULL" --web 2>/dev/null || gh repo view "$FULL"
