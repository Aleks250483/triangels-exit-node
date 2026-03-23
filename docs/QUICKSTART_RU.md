
# Быстрый старт TriAngels Exit Node

Краткая инструкция для партнёров и администраторов по развёртыванию exit-ноды TriAngels Mesh.

---

## Что потребуется

Перед началом у вас должно быть:

- новый VPS с Ubuntu 22.04
- доступ по SSH
- `hostname` для ноды  
  пример: `triangels-exit-hu-01`
- адрес вашего Headscale-сервера  
  пример: `https://your-headscale-server`
- auth key вида `hskey-auth-...`

---

## Шаг 1. Подключиться к серверу

Пример:

```bash
ssh username@SERVER_IP

Если вход под root:

ssh root@SERVER_IP
Шаг 2. Скачать установщик

Выполнить на сервере:

curl -fsSL -o triangels-exit-installer.sh https://raw.githubusercontent.com/Aleks250483/triangels-exit-node/main/scripts/triangels-exit-installer.sh
Шаг 3. Выдать права на запуск
chmod +x triangels-exit-installer.sh
Шаг 4. Запустить установщик

Если вы вошли как root:

./triangels-exit-installer.sh

Если вы вошли как обычный пользователь:

sudo ./triangels-exit-installer.sh
Шаг 5. Ответить на вопросы установщика

Скрипт попросит ввести:

hostname
пример: triangels-exit-hu-01
Headscale URL
пример: https://your-headscale-server
Auth Key
пример: hskey-auth-XXXXXXXX

После этого начнётся автоматическая установка.

Что делает установщик

Скрипт автоматически:

обновляет систему
ставит базовые пакеты
задаёт hostname
включает IP forwarding
устанавливает Tailscale
подключает сервер к Headscale
настраивает NAT
применяет сетевой tuning
выполняет базовые проверки
Шаг 6. Скачать скрипт проверки

После установки можно проверить состояние ноды.

curl -fsSL -o triangels-exit-verify.sh https://raw.githubusercontent.com/Aleks250483/triangels-exit-node/main/scripts/triangels-exit-verify.sh
Шаг 7. Выдать права на запуск
chmod +x triangels-exit-verify.sh
Шаг 8. Запустить проверку

Если вы вошли как root:

./triangels-exit-verify.sh

Если вы вошли как обычный пользователь:

sudo ./triangels-exit-verify.sh
Что проверяет verify

Скрипт проверяет:

статус Tailscale
сетевую доступность (tailscale netcheck)
BBR и fq
IP forwarding
NAT
внешний IP сервера
Что проверить администратору на Core

После установки на Core-сервере выполнить:

headscale nodes list

Нужно убедиться, что новая нода:

появилась в списке
online
предлагает exit node
Что проверить с клиента

На клиентском устройстве:

выбрать exit node
проверить внешний IP:
curl ifconfig.me

IP должен совпасть с IP exit-ноды.

Типовой сценарий установки
ssh username@SERVER_IP
curl -fsSL -o triangels-exit-installer.sh https://raw.githubusercontent.com/Aleks250483/triangels-exit-node/main/scripts/triangels-exit-installer.sh
chmod +x triangels-exit-installer.sh
sudo ./triangels-exit-installer.sh

Потом:

curl -fsSL -o triangels-exit-verify.sh https://raw.githubusercontent.com/Aleks250483/triangels-exit-node/main/scripts/triangels-exit-verify.sh
chmod +x triangels-exit-verify.sh
sudo ./triangels-exit-verify.sh
Если что-то пошло не так

Проверьте:

правильно ли введён Headscale URL
не истёк ли auth key
открыт ли SSH-доступ к серверу
есть ли интернет на VPS
не заблокирован ли UDP
Статус

Текущий вариант предназначен для ручной установки с подтверждением данных пользователем.

Полностью автоматический режим будет добавлен позже, после практической обкатки.
