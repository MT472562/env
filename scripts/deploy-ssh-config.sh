#!/usr/bin/env bash
# env 管理の SSH 設定を、既存の ~/.ssh/config と共存させて配置する。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SSH_DIR="${HOME:?HOME is not set}/.ssh"
MAIN_CONFIG="$SSH_DIR/config"
CONFIG_DIR="$SSH_DIR/config.d"
MANAGED_CONFIG="$CONFIG_DIR/00-env.conf"
INCLUDE_LINE='Include ~/.ssh/config.d/00-env.conf'

mkdir -p "$CONFIG_DIR"
chmod 700 "$SSH_DIR" "$CONFIG_DIR"

cp -v "$ROOT/ssh_config" "$MANAGED_CONFIG"
chmod 600 "$MANAGED_CONFIG"

# Include は既存設定の後ろに置く。OpenSSH は先に得た値を優先するため、
# ~/.ssh/config に書いた端末固有・Host 固有設定で管理デフォルトを上書きできる。
# Match all は、既存ファイル末尾の Match 節から確実に抜けるために必要。
if [ ! -f "$MAIN_CONFIG" ]; then
  {
    echo '# Local SSH settings. env-managed defaults are loaded below.'
    echo 'Match all'
    echo "$INCLUDE_LINE"
  } >"$MAIN_CONFIG"
elif ! grep -Fqx "$INCLUDE_LINE" "$MAIN_CONFIG"; then
  {
    echo
    echo '# env managed defaults (keep this block at the end)'
    echo 'Match all'
    echo "$INCLUDE_LINE"
  } >>"$MAIN_CONFIG"
fi

chmod 600 "$MAIN_CONFIG"
echo "SSH 設定を配置しました: $MANAGED_CONFIG"
echo "  端末固有設定は保持: $MAIN_CONFIG"
