#!/bin/bash

echo ""
echo "=== Arch Linux 安裝第四階段：pacstrap ==="
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
    echo "=== Arch Linux 安裝第四階段：任務失敗 ==="
    exit 1
fi

echo "Btrfs 分區設備路徑：$ROOT_DEV"
echo "掛載點：$TARGET_MNT"
echo ""

echo "--- 檢查掛載狀態 ---"

if ! mountpoint -q "$TARGET_MNT"; then
    echo "錯誤: $TARGET_MNT 尚未掛載，請先掛載分割區！"
    echo ""
    echo "=== Arch Linux 安裝第四階段：任務失敗 ==="
    exit 1
fi

# starting
# ========

echo "1. 確認微碼：自動判定 Microcode"
# ====================================
echo ""
echo "--- 偵測硬體環境 ---"

# 偵測硬體並決定微碼套件名稱
# 若顯示 GenuineIntel：安裝 intel-ucode。
# 若顯示 AuthenticAMD：安裝 amd-ucode。
UCODE="intel-ucode"
if grep -q "AuthenticAMD" /proc/cpuinfo; then
    UCODE="amd-ucode"
fi
echo "偵測到硬體對應的微碼: $UCODE"

# 動態將微碼套件追加到 PACS 陣列中
PACS+=("$UCODE")
echo "已將 $UCODE 動態加入安裝清單。目前預計安裝的所有套件為: ${PACS[*]}"
echo ""

echo "2. 讀取 PACS 變數，執行 pacstrap"
# =====================================

echo "刪除原有 $TARGET_MNT/boot 裡的檔案以避免 pacstrap 失敗..."

find "$TARGET_MNT"/boot -mindepth 1 -delete
echo ""

echo "--- 開始執行 pacstrap ---"

pacstrap -K "$TARGET_MNT" "$UCODE" "${PACS[@]}"
echo ""

echo "3. 生成 fstab"
# ==================
echo "--- 開始生成 fstab ---"

# 確保目錄存在
mkdir -p "$TARGET_MNT"/etc

# 建議先備份舊的 fstab (如果存在)，然後重寫而非追加，避免重複執行導致內容疊加
if [ -f "$TARGET_MNT"/etc/fstab ]; then
    cp "$TARGET_MNT"/etc/fstab "$TARGET_MNT"/etc/fstab.bak
    echo "已備份現有 fstab 至 $TARGET_MNT/etc/fstab.bak"
fi

genfstab -U "$TARGET_MNT" > "$TARGET_MNT"/etc/fstab

echo "生成的 fstab 內容如下："
echo "--------------------------------------"
cat "$TARGET_MNT"/etc/fstab

echo "$TARGET_MNT 尚未缷載，等待下一階段 choot 階段"
echo ""

echo "=== 「Arch Linux 安裝第四階段：pacstrap」 任務完成==="
echo "==> 請執行下一個腳本進入 arch-chroot。"

# note:
# 安裝微代碼：確認 CPU 廠商
# lscpu | grep "Vendor ID"
