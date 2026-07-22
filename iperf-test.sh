#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-iperf.maruchan.dev}"
DURATION="${2:-10}"
BW="${3:-4M}"
SSH_USER="${4:-ubuntu}"
HOST_SSH="$SSH_USER@$HOST"

cleanup() { ssh "$HOST_SSH" "pkill iperf 2>/dev/null; pkill iperf3 2>/dev/null" || true; }
trap cleanup EXIT

parse_result() {
  local line="$1"
  local type="$2"

  local transfer=$(echo "$line" | grep -oP '\d+\.?\d*\s+(KBytes|MBytes|GBytes)')
  local transfer_val=$(echo "$transfer" | awk '{print $1}')
  local transfer_unit=$(echo "$transfer" | awk '{print $2}')
  local bw=$(echo "$line" | grep -oP '\d+\.?\d*\s+Mbits/sec' | awk '{print $1}')
  local mbps=$(echo "$bw" | awk '{printf "%.1f", $1 / 8}')

  echo "  転送量: $transfer_val $transfer_unit"
  echo "  速度:   $bw Mbits/sec  ($mbps MB/sec)"

  if [ "$type" = "udp" ]; then
    local jitter=$(echo "$line" | grep -oP '\d+\.?\d*\s+ms' | awk '{print $1}')
    local loss=$(echo "$line" | grep -oP '\d+\.?\d*%' | tr -d '()')
    [ -n "$jitter" ] && echo "  ジッター: $jitter ms"
    [ -n "$loss" ]   && echo "  パケロス: $loss"
  fi
}

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
tcp_out=$(iperf -c "$HOST" -t "$DURATION" 2>&1)
echo "$tcp_out"
tcp_line=$(echo "$tcp_out" | grep -E '^\[\s+1\]' | grep -v 'ID\]' | tail -1)
if [ -n "$tcp_line" ]; then
  echo ""
  echo "--- 結果 ---"
  parse_result "$tcp_line" tcp
fi
cleanup
echo ""

# ── UDP パケロステスト ──
echo "──────────────────────────────"
echo " [2/2] UDP 品質テスト (${BW}/s, ${DURATION}秒)"
echo "──────────────────────────────"
ssh "$HOST_SSH" "iperf -s -u >/dev/null 2>&1 &"
sleep 0.5
udp_out=$(iperf -c "$HOST" -u -b "$BW" -t "$DURATION" 2>&1)
echo "$udp_out"
udp_line=$(echo "$udp_out" | grep -E '^\[\s+1\]' | grep -v 'ID\]' | tail -1)
if [ -n "$udp_line" ]; then
  echo ""
  echo "--- 結果 ---"
  parse_result "$udp_line" udp
fi
cleanup
echo ""

echo "=================================="
echo "  完了"
echo "=================================="
