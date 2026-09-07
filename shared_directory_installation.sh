#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "Запускай через sudo!"
   exit 1
fi

pacman -S --needed tailscale smbclient gvfs-smb cifs-utils

systemctl enable --now tailscaled
echo ">>>Сейчас будет предложена ссылка для регистрации"
echo ">>>Пожалуйста отправьте эту ссылку админу или же если вы админ пройдите регистрацию сами"
tailscale up

echo ">>>Введите данные для входа:"
read -rp "Имя пользователя: " USERNAME
read -rsp "Пароль: " PASSWORD
echo
read -rp "Tailscale IP: " TAILSCALE_IP

USER_UID=$(id -u "${SUDO_USER:-$USER}")
USER_GID=$(id -g "${SUDO_USER:-$USER}")

mkdir -p /mnt/shared
mkdir -p /etc/samba

cat <<EOF | tee /etc/samba/credentials > /dev/null
username=$USERNAME
password=$PASSWORD
EOF

chmod 600 /etc/samba/credentials

sed -i '\#[[:space:]]/mnt/shared[[:space:]]cifs#d' /etc/fstab

echo "//$TAILSCALE_IP/shared /mnt/shared cifs credentials=/etc/samba/credentials,uid=$USER_UID,gid=$USER_GID,iocharset=utf8,x-systemd.automount,noauto,x-systemd.requires=tailscaled.service 0 0" | tee -a /etc/fstab > /dev/null

echo ">>>Запускаю..."

systemctl daemon-reload
systemctl restart mnt-shared.automount

stat /mnt/shared >/dev/null 2>&1 || true
sleep 1

if mountpoint -q /mnt/shared 2>/dev/null; then
    echo ">>>Успешно, папка примонтирована. Откройте файловый менеджер и используйте /mnt/shared при включённом tailscale"
else
    echo ">>>Не удалось смонтировать автоматически. Проверьте вручную:"
    echo "    sudo mount -t cifs //$TAILSCALE_IP/shared /mnt/shared -o credentials=/etc/samba/credentials,uid=$USER_UID,gid=$USER_GID,iocharset=utf8"
fi
