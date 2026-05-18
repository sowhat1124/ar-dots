#!/bin/bash

echo ""
echo "=== Arch Linux 安裝第六階段：chroot ==="
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
    
    echo "初期化新使用者家目錄權限..."
    # 僅在「新建立」時做基礎權限設定，不使用 -R 避免動到掛載點內已存在的檔案
    chown "$USER_NAME":"$USER_NAME" "/home/$USER_NAME"
    chmod 755 "/home/$USER_NAME"
fi

echo "將新使用者加入 sudo 群組..."
# ================================

# 不直接動主設定檔，而是放進專用目錄
if [ ! -f /etc/sudoers.d/10-wheel ]; then
    echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/10-wheel
    chmod 0440 /etc/sudoers.d/10-wheel
fi

#echo "修正家目錄權限..."
## ======================
#
#chown -R "$USER_NAME":"$USER_NAME" "/home/$USER_NAME"
#chmod 755 "/home/$USER_NAME"

echo "建立 stow-root..."
# ===================================================

stow -d "/home/$USER_NAME/_dots" -t / -D stow-root
stow -d "/home/$USER_NAME/_dots" -t / stow-root

echo "建立 systemd-tmpfiles 連結與檔案..."
# ===================================================
mountpoint -q /etc/resolv.conf && umount /etc/resolv.conf     # 確認缷載已避免 systemd-tmpfiles 失敗
systemd-tmpfiles --remove --create /etc/tmpfiles.d/persist.conf

echo ""
echo "建立 systemd-tmpfiles 軟連結..."
echo "建立 /etc/environment"
echo "建立 /usr/local/bin"
echo ""
echo "建立 systemd-tmpfiles 連結..."
echo "建立 /boot/loader/loader.conf"
echo "建立 /etc/vconsole.conf"
echo "建立 /etc/systemd/network/25-wireless.network"
echo "建立 /etc/systemd/resolved.conf"
echo "建立 /etc/pacman.d/mirrorlist"
echo "建立 /var/lib/iwd/*"

echo "在 HOOKS 陣列中主動加入 btrfs..."
# =====================================
# 在 HOOKS 陣列中主動加入 btrfs，這能讓核心在開機時主動尋找所有 Btrfs 標記的裝置，避免因為硬碟偵測順序變動導致找不到系統。
# 僅在 HOOKS 內且沒有 btrfs 的情況下，在 filesystems 前面加上 btrfs
# 使用 \b 確保精確匹配 "btrfs" 這個獨立單字
if ! grep -q -E "\bbtrfs\b" /etc/mkinitcpio.conf; then
    echo "偵測到 HOOKS 缺少 btrfs，正在自動加入..."
    
    # 在 HOOKS=(...) 的最後一個有效 hook 後面（即右括號 ) 之前）插入 btrfs
    sed -i '/^HOOKS=/s/)/ btrfs)/' /etc/mkinitcpio.conf
    
    echo "偵測到設定變更，生成 Initramfs..."
    mkinitcpio -P
else
    echo "mkinitcpio.conf 已包含 btrfs，跳過生成。"
fi

# 引導程式 (systemd-boot) 指令作業
# ================================

echo "修改 fstab 避免 bootctl install 報錯..."
# ============================================

# 修改完 fstab 後，重新掛載讓設定生效
if grep -q "/boot.*vfat.*0022" /etc/fstab; then
    sed -i '/\/boot.*vfat/s/0022/0077/g' /etc/fstab
fi

mount -o remount /boot || mount /boot || true

echo "安裝引導程式..."
# ====================

if ! bootctl is-installed --quiet; then
        bootctl install
    else
        bootctl update
fi

echo "使用 printf 產生 arch.conf..."
# =================================

# 直接從 fstab 撈取掛載點為 / 的 UUID
PART_UUID=$(awk '$2=="/" && $1~/UUID/ {print $1}' /etc/fstab | cut -d= -f2)

# 防禦性檢查：萬一 fstab 真的空了，才印出錯誤，否則就繼續執行
if [ -z "$PART_UUID" ]; then
    echo "錯誤：無法從 /etc/fstab 獲取根目錄的 UUID！"
    exit 1
fi

# 微碼判斷
UCODE="intel-ucode"
# 如果是 AMD，切換變數
if grep -q "AuthenticAMD" /proc/cpuinfo; then
    UCODE="amd-ucode"
fi

# 確保該微碼套件有被安裝（pacman 本身有冪等性，已安裝就會跳過）
#pacman -S --noconfirm --needed "$UCODE"
pacman -S --noconfirm --needed --overwrite "*" "$UCODE"

if [ ! -f /boot/loader/entries/arch.conf ]; then
    echo "正在產生 arch.conf..."
    # 修正：直接在雙引號內使用 $UCODE 即可，不需要另外加雙引號
    printf "title   Arch Linux (LTS)\n\
linux   /vmlinuz-linux-lts\n\
initrd  /%s.img\n\
initrd  /initramfs-linux-lts.img\n\
options root=UUID=%s rw rootflags=subvol=@\n" "$UCODE" "$PART_UUID" > /boot/loader/entries/arch.conf
else
    echo "arch.conf 已存在，跳過避免覆蓋自訂參數。"
fi

cat /boot/loader/entries/arch.conf

echo "正在啟用網路..."
# ====================

systemctl enable --quiet systemd-networkd
systemctl enable --quiet systemd-resolved  # 通常會搭配這個來處理 DNS
systemctl enable --quiet iwd

echo "建立 stow-user 設定檔連結..."
# ================================

#sudo -iu ar bash -c "stow -d /home/ar/_dots -t /home/ar/ -D stow-user"
#sudo -iu ar bash -c "stow -d /home/ar/_dots -t /home/ar/ stow-user"

runuser -u "$USER_NAME" -- stow -d "/home/$USER_NAME/_dots" -t "/home/$USER_NAME/" -D stow-user
runuser -u "$USER_NAME" -- stow -d "/home/$USER_NAME/_dots" -t "/home/$USER_NAME/" stow-user

echo ""
echo "=== 「Arch Linux 安裝第六階段：chroot」任務完成 ==="
echo ""

echo "出現 umount: /mnt/new/etc/resolv.conf: not mounted. 是正常的，不用管他"

#echo "建立 stow-user_files 家目錄下資料夾連結..."
## ===============================================
#
#sudo -iu ar bash -c "stow -d /home/ar/_data -t /home/ar/ -D stow-user_dirs"
#sudo -iu ar bash -c "stow -d /home/ar/_data -t /home/ar/ stow-user_dirs"

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
