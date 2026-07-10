#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-proxy.maruchan.dev}"
COUNT=10

RESULTS=()
NOTE()   { RESULTS+=("[NOTE] $1"); }
PASS()   { RESULTS+=("[PASS] $1"); }
WARN()   { RESULTS+=("[WARN] $1"); }
FAIL()   { RESULTS+=("[FAIL] $1"); }

echo "=============================================="
echo "  ネットワーク診断: $TARGET"
echo "=============================================="
echo ""

# ── 1. DNS 名前解決 ──
echo "──────────────────────────────"
echo " [1] DNS 名前解決"
echo "──────────────────────────────"
A_RECORDS=()
if dig "$TARGET" +short A 2>/dev/null | head -5; then
  mapfile -t A_RECORDS < <(dig "$TARGET" +short A 2>/dev/null)
  if [ ${#A_RECORDS[@]} -gt 0 ]; then
    PASS "A レコード: ${A_RECORDS[*]}"
  else
    FAIL "A レコードが解決できません"
  fi
else
  FAIL "dig が利用できません"
fi
echo ""

AAAA_RECORDS=()
AAAA_OUT=$(dig "$TARGET" +short AAAA 2>/dev/null)
if [ -n "$AAAA_OUT" ]; then
  mapfile -t AAAA_RECORDS <<< "$AAAA_OUT"
  NOTE "AAAA レコード: ${AAAA_RECORDS[*]}"
else
  NOTE "AAAA レコードなし (IPv6非対応)"
fi

# 逆引き
for ip in "${A_RECORDS[@]}"; do
  PTR=$(dig +short -x "$ip" 2>/dev/null | head -1)
  if [ -n "$PTR" ]; then
    NOTE "逆引き ($ip): $PTR"
  else
    NOTE "逆引き ($ip): なし"
  fi
done
echo ""

# ── 2. Ping ──
echo "──────────────────────────────"
echo " [2] Ping 疎通確認 (${COUNT}回)"
echo "──────────────────────────────"
ping_out=$(ping -c "$COUNT" -W 3 "$TARGET" 2>&1 || true)
echo "$ping_out"
echo ""
packet_loss=$(echo "$ping_out" | grep -oP '\d+% packet loss' | grep -oP '\d+')
rtt_avg=$(echo "$ping_out" | grep -oP 'rtt min/avg/max/mdev = [\d.]+/[\d.]+/[\d.]+/[\d.]+' | cut -d'/' -f4)
if [ "$packet_loss" = "0" ]; then
  PASS "パケロス 0%"
elif [ "$packet_loss" -le 5 ]; then
  WARN "パケロス ${packet_loss}% (軽微)"
else
  FAIL "パケロス ${packet_loss}%"
fi
if [ -n "$rtt_avg" ]; then
  NOTE "平均RTT: ${rtt_avg}ms"
fi
echo ""

# ── 3. Traceroute ──
echo "──────────────────────────────"
echo " [3] Traceroute"
echo "──────────────────────────────"
if command -v mtr &>/dev/null; then
  mtr -r -c 3 -n "$TARGET" 2>&1 || true
elif command -v traceroute &>/dev/null; then
  traceroute -n -q 1 -w 3 "$TARGET" 2>&1 || true
else
  WARN "traceroute/mtr が利用できません"
fi
echo ""

# ── 4. MTR ──
if command -v mtr &>/dev/null; then
  echo "──────────────────────────────"
  echo " [4] MTR (3秒間)"
  echo "──────────────────────────────"
  mtr --report --report-cycles 3 "$TARGET" 2>&1 || true
  echo ""
fi

# ── 5. ポート疎通 ──
echo "──────────────────────────────"
echo " [5] ポート疎通確認"
echo "──────────────────────────────"
check_port() {
  local port=$1 label=$2
  if timeout 3 bash -c "echo >/dev/tcp/$TARGET/$port" 2>/dev/null; then
    PASS "Port $port ($label): 疎通OK"
  else
    WARN "Port $port ($label): 疎通できず"
  fi
}
check_port 22    SSH
check_port 80    HTTP
check_port 443   HTTPS
check_port 5001  iperf
echo ""

# ── 6. HTTP(S) 応答 ──
echo "──────────────────────────────"
echo " [6] HTTP/HTTPS 応答"
echo "──────────────────────────────"
http_check() {
  local scheme=$1
  local code
  code=$(curl -o /dev/null -s -w "%{http_code}" --connect-timeout 5 --max-time 10 "${scheme}://${TARGET}" 2>/dev/null || true)
  if [ -n "$code" ] && [ "$code" -ne 000 ]; then
    PASS "${scheme}://$TARGET → HTTP $code"
  else
    WARN "${scheme}://$TARGET → 応答なし"
  fi
}
http_check http
http_check https
echo ""

# ── 7. SSL証明書 (HTTPS) ──
echo "──────────────────────────────"
echo " [7] SSL 証明書情報"
echo "──────────────────────────────"
ssl_info=$(echo | openssl s_client -connect "${TARGET}:443" -servername "$TARGET" 2>/dev/null </dev/null | openssl x509 -noout -subject -issuer -dates 2>/dev/null || true)
if [ -n "$ssl_info" ]; then
  echo "$ssl_info"
  PASS "SSL証明書取得OK"
else
  WARN "SSL証明書が取得できません"
fi
echo ""

# ── 8. iperf 速度テスト (簡易) ──
echo "──────────────────────────────"
echo " [8] iperf 速度"
echo "──────────────────────────────"
SSH_USER="${2:-ubuntu}"
HOST_SSH="$SSH_USER@$TARGET"
cleanup() { ssh "$HOST_SSH" "pkill iperf 2>/dev/null; pkill iperf3 2>/dev/null" || true; }
trap cleanup EXIT

ssh "$HOST_SSH" "iperf -s >/dev/null 2>&1 &" 2>/dev/null || true
sleep 0.5
iperf_out=$(iperf -c "$TARGET" -t 5 2>&1 || true)
cleanup
bw=$(echo "$iperf_out" | grep -oP '\d+\.?\d*\s+Mbits/sec' | awk '{print $1}')
if [ -n "$bw" ]; then
  PASS "iperf: ${bw} Mbits/sec"
else
  WARN "iperf 速度テストが完了しませんでした"
fi
echo ""

# ── まとめ ──
echo "=============================================="
echo "  診断結果サマリー"
echo "=============================================="
for r in "${RESULTS[@]}"; do
  echo "  $r"
done
echo "=============================================="
