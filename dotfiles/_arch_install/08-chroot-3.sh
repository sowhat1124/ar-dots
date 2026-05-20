#!/bin/bash

echo ""
echo "=== Arch Linux 安裝第七階段：chroot 設定檔及執行檔建立 ==="
echo ""

# before starting
# ===============
set -euo pipefail

# Load variables
if [ -f "./vars.sh" ]; then
    source ./vars.sh
    echo "成功讀取 vars.sh 變數"
else
    echo "錯誤：vars.sh 不存在!"
    echo "Arch Linux 安裝第七階段：任務失敗 ==="
    exit 1
fi

echo "調整 _Storage, _data, tmp 目錄權限..."
# ===================================================
# /home/ar/_Storage: 不用 + -R，_Storage 裡掛載的 ntfs 硬碟在 fstab 裡已設定權限
chown "$USER_NAME":"$USER_NAME" "/home/$USER_NAME/_Storage"
chown -R "$USER_NAME":"$USER_NAME" "/home/$USER_NAME/_data"
chown "$USER_NAME":"$USER_NAME" "/home/$USER_NAME/tmp"
#chmod 755 "/home/$USER_NAME/_Storage"

echo "建立 stow-root..."
# ===================================================
if [ -d "/home/$USER_NAME/_dots" ]; then
    stow -d "/home/$USER_NAME/_data/ar-dots" -t / -D stow-root || true
    stow -d "/home/$USER_NAME/_data/ar-dots" -t / stow-root
else
    echo "警告：找不到 /home/$USER_NAME/_data/ar-dots，跳過 stow-root"
fi

echo "建立 systemd-tmpfiles 連結與檔案..."
# ===================================================
# 確認缷載已避免 systemd-tmpfiles 失敗
mountpoint -q /etc/resolv.conf && umount /etc/resolv.conf
systemd-tmpfiles --remove --create /etc/tmpfiles.d/persist.conf

echo "建立 stow-user 設定檔連結..."
# ================================
runuser -u "$USER_NAME" -- mkdir -p "/home/$USER_NAME/.config"
runuser -u "$USER_NAME" -- stow -d "/home/$USER_NAME/_data/ar-dots" -t "/home/$USER_NAME/" -D stow-user || true
runuser -u "$USER_NAME" -- stow -d "/home/$USER_NAME/_data/ar-dots" -t "/home/$USER_NAME/" stow-user

echo "ln -s 建立 /usr/local/bin 連結..."
# ================================
#mkdir -p /usr/local/bin
#cp -r /home/$USER_NAME/Documents/_bin/* /usr/local/bin
mv /usr/local/bin /usr/local/bin_bak || true
ln -s /home/$USER_NAME/_data/bin /usr/local/bin

echo "ln -s 建立 /home/ar/.local/share/fcitx5 連結..."
# ================================
runuser -u "$USER_NAME" -- mkdir -p "/home/$USER_NAME/.local/share"
runuser -u "$USER_NAME" -- ln -s /home/$USER_NAME/_data/user-local/share/fcitx5 "/home/$USER_NAME/.local/share/fcitx5"

echo ""
echo "=== 「Arch Linux 安裝第七階段：chroot 設定檔及執行檔建立」任務完成 ==="
echo ""
