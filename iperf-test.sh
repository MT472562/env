#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-proxy.maruchan.dev}"
DURATION="${2:-10}"
BW="${3:-4M}"

SSH_USER="${4:-ubuntu}"

HOST_SSH="$SSH_USER@$HOST"

cleanup() {
  ssh "$HOST_SSH" "pkill iperf 2>/dev/null; pkill iperf3 2>/dev/null" || true
}
trap cleanup EXIT

echo "=================================="
echo "  iperf 速度テスト"
echo "  対象: $HOST"
echo "=================================="
echo ""

# ── TCP 速度テスト ──
echo "──────────────────────────────"
echo " [1/2] TCP 速度テスト (${DURATION}秒)"
echo "──────────────────────────────"
ssh "$HOST_SSH" "iperf -s >/dev/null 2>&1 &"
sleep 0.5
iperf -c "$HOST" -t "$DURATION"
cleanup
echo ""

# ── UDP パケロステスト ──
echo "──────────────────────────────"
echo " [2/2] UDP 品質テスト (${BW}/s, ${DURATION}秒)"
echo "──────────────────────────────"
ssh "$HOST_SSH" "iperf -s -u >/dev/null 2>&1 &"
sleep 0.5
iperf -c "$HOST" -u -b "$BW" -t "$DURATION"
cleanup
echo ""

echo "=================================="
echo "  完了"
echo "=================================="
