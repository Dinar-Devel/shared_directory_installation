# shared_directory_installation

Скрипт для быстрой настройки общей сетевой папки на устройствах с CachyOS/Arch Linux: поднимает [Tailscale](https://tailscale.com/) для приватного доступа между устройствами и монтирует Samba-шару с сервера через `cifs` с автомонтированием (`systemd.automount`).

## Что делает скрипт

1. Устанавливает `tailscale`, `smbclient`, `gvfs-smb`, `cifs-utils`.
2. Запускает и авторизует Tailscale (`tailscale up`).
3. Спрашивает логин/пароль от Samba-шары и Tailscale IP сервера.
4. Создаёт `/etc/samba/credentials` с правами `600`.
5. Добавляет запись в `/etc/fstab` для автомонтирования шары в `/mnt/shared`.
6. Монтирует папку и проверяет результат.

## Требования

- CachyOS или другой Arch-based дистрибутив (`pacman`).
- Уже настроенный Samba-сервер с шарой `shared` (см. основной репозиторий/инструкцию по серверной части).
- Root-права (`sudo`) на клиентской машине.
- Tailscale-аккаунт (Google/GitHub/email — для авторизации устройства).

## Установка и запуск

### Вариант 1 — прямая ссылка (если GitHub доступен без проблем)

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Dinar-Devel/shared_directory_installation/main/shared_directory_installation.sh)"
```

### Вариант 2 — через зеркала (если прямой доступ к GitHub медленный/недоступен)

Зеркала прокидывают тот же raw-файл через сторонний CDN. Если один не работает — попробуйте следующий.

**ghfast.top**
```bash
sudo bash -c "$(curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/Dinar-Devel/shared_directiry_installation/main/shared_directory_installation.sh)"
```

**ghproxy.com**
```bash
sudo bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/Dinar-Devel/shared_directiry_installation/main/shared_directory_installation.sh)"
```

**mirror.ghproxy.com**
```bash
sudo bash -c "$(curl -fsSL https://mirror.ghproxy.com/https://raw.githubusercontent.com/Dinar-Devel/shared_directiry_installation/main/shared_directory_installation.sh)"
```

> ⚠️ Публичные GitHub-зеркала — сторонние сервисы, не принадлежат этому репозиторию. Список рабочих зеркал часто меняется; если ни одно не отвечает — воспользуйтесь [Варианте 3](#вариант-3--вручную) ниже.

### Вариант 3 — вручную

```bash
git clone https://github.com/Dinar-Devel/shared_directory_installation.git
cd shared_directory_installation
sudo bash shared_directory_installation.sh
```

## Что вас спросят при запуске

| Параметр | Где взять |
|---|---|
| Имя пользователя Samba | Логин, под которым делали `smbpasswd -a` на сервере |
| Пароль | Пароль, заданный через `smbpasswd -a` (не пароль от системы!) |
| Tailscale IP сервера | На сервере: `tailscale ip -4` |

## После установки

Папка доступна по пути:
```
/mnt/shared
```

Благодаря `x-systemd.automount`, она примонтируется автоматически при первом обращении (например, `ls /mnt/shared`), а не сразу при загрузке — это нормально, не ошибка.

Добавьте `/mnt/shared` в избранное вашего файлового менеджера (Nautilus, Dolphin и т.д.) для быстрого доступа.

## Безопасность

- Пароль от Samba хранится в открытом виде в `/etc/samba/credentials`, доступном только `root` (`chmod 600`).
- SMB-порты (445, 139) на сервере должны быть закрыты для обычного интернета и открыты только для интерфейса `tailscale0` — см. инструкцию по настройке firewall на сервере.
- Доступ к папке работает только при включённом Tailscale на клиенте.

## Лицензия

MIT
