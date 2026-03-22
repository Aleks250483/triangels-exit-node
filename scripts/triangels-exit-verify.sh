#!/usr/bin/env bash
set -euo pipefail

echo "🔍 TriAngels Exit Node Verify v1.0"
echo "================================="

echo ""
echo "📡 Проверка Tailscale..."
tailscale status || echo "❌ Tailscale не работает"

echo ""
echo "🌐 Проверка сети..."
tailscale netcheck || echo "❌ Netcheck ошибка"

echo ""
echo "📊 Проверка BBR..."
sysctl net.ipv4.tcp_congestion_control
sysctl net.core.default_qdisc

echo ""
echo "🌐 Проверка IP forwarding..."
sysctl net.ipv4.ip_forward
sysctl net.ipv6.conf.all.forwarding

echo ""
echo "🔁 Проверка NAT..."
iptables -t nat -L -n

echo ""
echo "🌍 Проверка внешнего IP..."
curl -s ifconfig.me || echo "❌ Нет выхода в интернет"

echo ""
echo "================================="
echo "✅ Проверка завершена"
