#!/bin/bash

echo ""
echo "=== Arch Linux 安裝第六階段：chroot 系統設定及建立用戶 ==="
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
    echo "Arch Linux 安裝第六階段：任務失敗 ==="
    exit 1
fi

echo "設定時區..."
# ================
ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
hwclock --systohc

echo "編輯 locale.gen，啟用英文與台灣中文語系..."
# ===============================================
# 啟用 en_US.UTF-8
if ! grep -q "^en_US.UTF-8 UTF-8" /etc/locale.gen; then
    sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
fi

# 啟用 zh_TW.UTF-8
if ! grep -q "^zh_TW.UTF-8 UTF-8" /etc/locale.gen; then
    sed -i 's/^#\(zh_TW.UTF-8 UTF-8\)/\1/' /etc/locale.gen
fi

locale-gen

echo "設定全域語言為英文..."
# ==========================
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "設定主機名稱與密碼 (Network & Security)..."
# ===============================================
echo "$HOST_NAME" > /etc/hostname

echo "設定 root 密碼..."
# ======================
echo "$USER_ROOT" | chpasswd

echo "設定新用戶與密碼..."
# ========================
#if id "$USER_NAME" &>/dev/null; then
#    echo "使用者 $USER_NAME 已存在，跳過建立。"
#    echo "$USER_NAME:$USER_PASS" | chpasswd
#else
#    useradd -m "$USER_NAME"
#    echo "$USER_NAME:$USER_PASS" | chpasswd
#fi

if id "$USER_NAME" &>/dev/null; then
    echo "使用者 $USER_NAME 已存在，跳過建立與初期權限設定。"
    echo "$USER_NAME:$USER_PASS" | chpasswd
else
    # 建立使用者，並直接加入 wheel 群組 (-G)
    useradd -m -G wheel "$USER_NAME"
    echo "$USER_NAME:$USER_PASS" | chpasswd
    
    #echo "初期化新使用者家目錄權限..."
    ## 僅在「新建立」時做基礎權限設定，不使用 -R 避免動到掛載點內已存在的檔案
    #chown "$USER_NAME":"$USER_NAME" "/home/$USER_NAME"
    #chmod 755 "/home/$USER_NAME"
fi

echo "初期化新使用者家目錄權限..."
# 僅在「新建立」時做基礎權限設定，不使用 -R 避免動到掛載點內已存在的檔案
chown "$USER_NAME":"$USER_NAME" "/home/$USER_NAME"
#chmod 755 "/home/$USER_NAME"

echo "將新使用者加入 sudo 群組..."
# ================================
# 不直接動主設定檔，而是放進專用目錄
if [ ! -f /etc/sudoers.d/10-wheel ]; then
    echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/10-wheel
    chmod 0440 /etc/sudoers.d/10-wheel
fi

echo ""
echo "=== 「Arch Linux 安裝第六階段：chroot 系統設定及建立用戶」任務完成 ==="
echo ""
