#!/usr/bin/env bash
set -euo pipefail

VERSION="1.1"
LOG_FILE="/var/log/triangels-exit-install.log"

echo "🚀 TriAngels Exit Node Installer v$VERSION"
echo "📄 Лог: $LOG_FILE"

# === Проверка root ===
if [ "$EUID" -ne 0 ]; then
  echo "❌ Запусти скрипт с sudo"
  exit 1
fi

# === Логирование ===
exec > >(tee -a "$LOG_FILE") 2>&1

# === Ввод данных ===
read -rp "Введите hostname (например triangels-exit-hu-01): " HOSTNAME
read -rp "Введите Headscale URL (например https://your-core): " HEADSCALE_URL
read -rp "Введите Auth Key (hskey-...): " AUTH_KEY

echo "📦 Обновление системы..."
apt update && apt upgrade -y

echo "🧰 Установка базовых пакетов..."
apt install -y curl wget git ufw fail2ban iptables-persistent

echo "🖥 Установка hostname..."
hostnamectl set-hostname "$HOSTNAME"

echo "🔥 Настройка firewall..."
ufw allow OpenSSH
ufw allow 41641/udp
ufw --force enable

echo "🔒 Включение fail2ban..."
systemctl enable fail2ban
systemctl start fail2ban

echo "⚡ Включение IP forwarding..."
grep -q "TriAngels IP Forwarding" /etc/sysctl.conf || cat <<EOF >> /etc/sysctl.conf

# TriAngels IP Forwarding
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF

sysctl -p

echo "🌐 Установка Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "🔗 Подключение к Headscale..."
tailscale up \
  --login-server="$HEADSCALE_URL" \
  --auth-key="$AUTH_KEY" \
  --hostname="$HOSTNAME" \
  --advertise-exit-node \
  --accept-dns=false \
  --reset

echo "🔁 Настройка NAT..."
IFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
echo "Интерфейс: $IFACE"

iptables -t nat -C POSTROUTING -o "$IFACE" -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o "$IFACE" -j MASQUERADE

netfilter-persistent save

echo "⚡ Применение Network Tuning..."
grep -q "TriAngels Network Tuning Baseline v1.0" /etc/sysctl.conf || cat <<EOF >> /etc/sysctl.conf

# TriAngels Network Tuning Baseline v1.0
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
EOF

sysctl -p

echo "🔍 Проверка статуса..."
tailscale status || true
tailscale netcheck || true

echo "📊 Проверка BBR..."
sysctl net.ipv4.tcp_congestion_control
sysctl net.core.default_qdisc

echo "🌐 Проверка IP forwarding..."
sysctl net.ipv4.ip_forward
sysctl net.ipv6.conf.all.forwarding

echo "🔁 Проверка NAT..."
iptables -t nat -L -n

echo "====================================="
echo "✅ Установка завершена!"
echo "👉 Проверь на Core: headscale nodes list"
echo "👉 Проверь с клиента: curl ifconfig.me"
