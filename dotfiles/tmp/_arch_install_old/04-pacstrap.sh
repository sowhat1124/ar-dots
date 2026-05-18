#!/bin/bash

# set -e: 出錯即停止, -u: 變數未定義即停止, -o pipefail: 管道出錯也停止
set -euo pipefail

echo "--- 檢查掛載狀態 ---"
if ! mountpoint -q /mnt; then
    echo "錯誤: /mnt 尚未掛載，請先掛載分割區！"
    exit 1
fi

echo "--- 偵測硬體環境 ---"
# 自動判定 Microcode
UCODE="intel-ucode"
if grep -q "AuthenticAMD" /proc/cpuinfo; then
    UCODE="amd-ucode"
fi
echo "將安裝: $UCODE"

echo "--- 開始執行 pacstrap ---"

# 建議加入 base-devel (編譯常用) 以及網路管理工具
PACS=(
    base
    base-devel
    linux-lts
    linux-firmware
    btrfs-progs
    nano
    "$UCODE"
    iwd
)

pacstrap -K /mnt "${PACS[@]}"

echo "--- 開始生成 fstab ---"

# 確保目錄存在
mkdir -p /mnt/etc

# 建議先備份舊的 fstab (如果存在)，然後重寫而非追加，避免重複執行導致內容疊加
if [ -f /mnt/etc/fstab ]; then
    cp /mnt/etc/fstab /mnt/etc/fstab.bak
    echo "已備份現有 fstab 至 /mnt/etc/fstab.bak"
fi

genfstab -U /mnt > /mnt/etc/fstab

echo "生成的 fstab 內容如下："
echo "--------------------------------------"
cat /mnt/etc/fstab
echo "--------------------------------------"

echo "==> 任務完成！請執行下一個腳本進入 arch-chroot。"

# note 1:
# 安裝微代碼：確認 CPU 廠商
# lscpu | grep "Vendor ID"
# 若顯示 GenuineIntel：請安裝 intel-ucode。
# 若顯示 AuthenticAMD：請安裝 amd-ucode。
