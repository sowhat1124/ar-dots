#!/bin/bash

echo ""
echo "=== Arch Linux 安裝第八階段：chroot: mkinitcpio 及網路啟用 ==="
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
    echo "Arch Linux 安裝第八階段：任務失敗 ==="
    exit 1
fi

echo "在 HOOKS 陣列中主動加入 btrfs..."
# =====================================
if ! grep -q -E "\bbtrfs\b" /etc/mkinitcpio.conf || true; then
    echo "偵測到 HOOKS 缺少 btrfs，正在自動加入..."
    sed -i '/^HOOKS=/s/)/ btrfs)/' /etc/mkinitcpio.conf
    NEED_MKINITCPIO=true
else
    echo "mkinitcpio.conf 已包含 btrfs。"
    NEED_MKINITCPIO=false
fi

echo "修改 fstab 避免 bootctl install 報錯..."
# ============================================
if grep -q "/boot.*vfat.*0022" /etc/fstab || true; then
    sed -i '/\/boot.*vfat/s/0022/0077/g' /etc/fstab
fi

# 重新掛載 boot 確保權限變更生效
umount /boot || true
systemctl daemon-reload
mount /boot

echo "安裝引導程式..."
# ====================
if ! bootctl is-installed --quiet || true; then
    bootctl install
else
    bootctl update
fi

echo "使用 printf 產生 arch.conf..."
# =================================
# 直接從 fstab 撈取掛載點為 / 的 UUID
PART_UUID=$(awk '$2=="/" && $1~/UUID/ {print $1}' /etc/fstab | cut -d= -f2)

if [ -z "$PART_UUID" ]; then
    echo "錯誤：無法從 /etc/fstab 獲取根目錄的 UUID！"
    exit 1
fi

# 微碼判斷
UCODE_PACS=()

if grep -q "AuthenticAMD" /proc/cpuinfo; then
    UCODE_PACS+=("amd-ucode")
elif grep -q "GenuineIntel" /proc/cpuinfo; then
    UCODE_PACS+=("intel-ucode")
else
    echo "提示：偵測到虛擬機或未知 CPU，將同時準備雙版本微碼..."
    UCODE_PACS+=("intel-ucode" "amd-ucode")
fi

echo "偵測到的微碼套件: ${UCODE_PACS[*]}"
echo ""

# 安裝微碼
pacman -S --noconfirm --needed --overwrite "*" "${UCODE_PACS[@]}"

if [ ! -f /boot/loader/entries/arch.conf ]; then
    echo "正在產生 arch.conf..."
    printf "title   Arch Linux (LTS)\n\
linux   /vmlinuz-linux-lts\n\
initrd  /%s.img\n\
initrd  /initramfs-linux-lts.img\n\
options root=UUID=%s rw rootflags=subvol=@\n" "$UCODE" "$PART_UUID" > /boot/loader/entries/arch.conf
else
    echo "arch.conf 已存在，跳過避免覆蓋自訂參數。"
fi

# 無論 mkinitcpio.conf 有無更動，因為安裝了微碼，統一在這裡重新生成 Initramfs 最安全
echo "生成 Initramfs..."
mkinitcpio -P

echo ""
cat /boot/loader/entries/arch.conf
echo ""

echo "正在啟用網路..."
# ====================
systemctl enable --quiet systemd-networkd
systemctl enable --quiet systemd-resolved  # 通常會搭配這個來處理 DNS
systemctl enable --quiet iwd

echo ""
echo "=== 「Arch Linux 安裝第八階段：chroot: mkinitcpio 及網路啟用」任務完成 ==="
echo ""
echo "提示：出現 umount: ... not mounted 是正常的。"
echo "請手動執行：sync 隨後退出 chroot 並卸載分區。"
