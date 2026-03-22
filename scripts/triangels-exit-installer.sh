#!/usr/bin/env bash
set -euo pipefail

echo "🚀 TriAngels Exit Node Installer v1.0"

# === Проверка root ===
if [ "$EUID" -ne 0 ]; then
  echo "❌ Запусти скрипт с sudo"
  exit 1
fi

echo "📦 Обновление системы..."
apt update && apt upgrade -y

echo "🧰 Установка базовых пакетов..."
apt install -y curl wget git ufw fail2ban

echo "🔥 Настройка firewall..."
ufw allow OpenSSH
ufw allow 41641/udp
ufw --force enable

echo "🔒 Включение fail2ban..."
systemctl enable fail2ban
systemctl start fail2ban

echo "⚡ Включение IP forwarding..."
cat <<EOF >> /etc/sysctl.conf

# TriAngels tuning
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF

sysctl -p

echo "🌐 Установка Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo ""
echo "✅ Установка завершена"
echo ""
echo "👉 Следующий шаг:"
echo "tailscale up --advertise-exit-node"
