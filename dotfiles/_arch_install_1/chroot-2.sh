#!/bin/bash

echo ""
echo "=== Arch Linux 安裝第六階段：arch-chroot ==="
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

sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
sed -i '/^#zh_TW.UTF-8 UTF-8/s/^#//' /etc/locale.gen
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

useradd -m "${USER_AR%%:*}"
echo "$USER_AR" | chpasswd

echo "將新使用者加入 sudo 群組..."
# ================================

usermod -aG wheel "${USER_AR%%:*}"
sed -i '0,/^[[:space:]]*#\s*%wheel\s\+ALL=(ALL:ALL)\s\+ALL/ s/^[[:space:]]*#\s*//' /etc/sudoers

echo "修正家目錄權限..."
# ======================

chown -R "${USER_AR%%:*}":"${USER_AR%%:*}" /home/ar
sudo chmod 755 /home/"${USER_AR%%:*}"

echo "修復 vconsole.conf 錯誤..."
# ===============================
# 修復 vconsole.conf 錯誤：建立一個基礎的虛擬終端機設定檔，這能解決 mkinitcpio 的報錯：

echo "KEYMAP=us" > /etc/vconsole.conf
echo "FONT=sun12x22" >> /etc/vconsole.conf

echo "在 HOOKS 陣列中主動加入 btrfs..."
# =====================================
# 在 HOOKS 陣列中主動加入 btrfs，這能讓核心在開機時主動尋找所有 Btrfs 標記的裝置，避免因為硬碟偵測順序變動導致找不到系統。

sed -i '/^HOOKS=(.*)/c\HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block btrfs filesystems fsck)' /etc/mkinitcpio.conf

echo "生成 Initramfs..."
# ======================
mkinitcpio -P

# 引導程式 (systemd-boot) 指令作業
# ================================

echo "修改 fstab 避免 bootctl install 報錯..."
# ============================================

sed -i '/\/boot.*vfat/s/0022/0077/g' /etc/fstab
# 修改完 fstab 後，重新掛載讓設定生效
umount /boot
mount /boot

echo "安裝引導程式..."
# ====================

bootctl install

echo "自動化配置 Loader：設定預設啟動項與選單倒數..."
# ===================================================

printf "default arch.conf\ntimeout 3\nconsole-mode max\neditor no\n" > /boot/loader/loader.conf

echo "建立啟動條目..."
# ====================
# 建立啟動條目 (Entry)（假設已安裝微碼（如 intel-ucode）。）

PART_UUID=$(blkid -s UUID -o value "$ROOT_DEV")

echo "使用 printf 產生 arch.conf..."
# =================================

printf "title   Arch Linux (LTS)\n\
linux   /vmlinuz-linux-lts\n\
initrd  /intel-ucode.img\n\
initrd  /initramfs-linux-lts.img\n\
options root=UUID=$PART_UUID rw rootflags=subvol=@\n" > /boot/loader/entries/arch.conf


echo "正在建立 stow-root 與 systemd-tmpfiles 連結..."
# ===================================================

cd /home/ar/_dots
stow -t / stow-root
umount /etc/resolv.conf     # 確認掛載已消失
systemd-tmpfiles --create /etc/tmpfiles.d/*

echo "正在啟用網路..."
# ====================

systemctl enable systemd-networkd
systemctl enable systemd-resolved  # 通常會搭配這個來處理 DNS
systemctl enable iwd

echo "建立 stow-user 設定檔連結..."
# ================================

sudo -iu ar bash <<EOF
    echo "目前的執行使用者是: \$(whoami)"
    echo "家目錄在: \$HOME"
    mkdir -p ~/.config
    cd /home/ar/_dots && stow -t ~ stow-user
EOF

echo "建立 stow-user_files 家目錄下資料夾連結..."
# ===============================================

sudo -iu ar bash "cd /home/ar/_dots && stow -t ~ stow-user"

# ===========

#sudo -iu ar bash <<EOF
#    echo "目前的執行使用者是: \$(whoami)"
#    echo "家目錄在: \$HOME"
#    mkdir -p ~/.config
#    cd /home/ar/_dots && stow -t ~ stow-user
#    cd /home/ar/_data && stow -t ~ stow-user_files
#EOF

# ================================

# 安裝中文字體 (確保 GUI 程式可正常顯示中文)
#pacman -S noto-fonts-cjk

# ==============================
# 退出 Chroot 環境
#exit

# 強制同步緩存 (Sync)：在卸載分區前，手動執行 sync 確保所有緩存中的 Btrfs 中繼資料與 UKI 檔案已完全寫入 NVMe 磁碟。
#sync

# 使用 -R 參數從 /mnt 開始遞迴卸載所有子卷（@, @home 等）與 EFI 分區。
#sudo umount -R "$TARGET_MNT" # umount -l /mnt
