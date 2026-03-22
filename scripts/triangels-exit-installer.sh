#!/usr/bin/env bash

set -e

echo "🚀 TriAngels Exit Node Installer v1.0"
echo "====================================="

# ===== ВВОД ДАННЫХ =====

read -p "Введите hostname (например triangels-exit-hu-01): " HOSTNAME
read -p "Введите Headscale URL (например https://your-core): " HEADSCALE_URL
read -p "Введите Auth Key (hskey-...): " AUTH_KEY

# ===== ОБНОВЛЕНИЕ =====

echo "📦 Обновление системы..."
sudo apt update && sudo apt upgrade -y

echo "📦 Установка пакетов..."
sudo apt install -y curl sudo ufw nano iptables-persistent

# ===== HOSTNAME =====

echo "🖥 Установка hostname..."
sudo hostnamectl set-hostname "$HOSTNAME"

# ===== IP FORWARDING =====

echo "🌐 Включение IP forwarding..."
sudo bash -c 'cat >> /etc/sysctl.conf <<EOF

# TriAngels IP Forwarding
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF'

sudo sysctl -p

# ===== TAILSCALE =====

echo "📡 Установка Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "🔗 Подключение к Headscale..."
sudo tailscale up \
  --login-server="$HEADSCALE_URL" \
  --auth-key="$AUTH_KEY" \
  --hostname="$HOSTNAME" \
  --advertise-exit-node \
  --accept-dns=false \
  --reset

# ===== NAT =====

echo "🔁 Настройка NAT..."

IFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')

echo "Интерфейс: $IFACE"

sudo iptables -t nat -A POSTROUTING -o "$IFACE" -j MASQUERADE
sudo netfilter-persistent save

# ===== NETWORK TUNING =====

echo "⚡ Применение Network Tuning..."

sudo bash -c 'cat >> /etc/sysctl.conf <<EOF

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
EOF'

sudo sysctl -p

# ===== ПРОВЕРКИ =====

echo "🔍 Проверка статуса..."

tailscale status || true
tailscale netcheck || true

echo "📊 Проверка BBR..."
sysctl net.ipv4.tcp_congestion_control
sysctl net.core.default_qdisc

echo "🌐 Проверка IP forwarding..."
sysctl net.ipv4.ip_forward

echo "🔁 Проверка NAT..."
sudo iptables -t nat -L -n

echo "====================================="
echo "✅ Установка завершена!"
echo "👉 Проверь на Core: headscale nodes list"
echo "👉 Проверь с клиента: curl ifconfig.me"
