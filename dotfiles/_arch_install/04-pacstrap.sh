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

echo "1. 使用 reflector 來自動篩選並更新台灣最快的鏡像站..."
# =======================================================

pacman -S --needed --noconfirm reflector

MIRROR_FILE="/home/ar/_dots/dotfiles/_tmpfiles/pacman_mirrors_reflector"

# 檢查鏡像檔是否已存在，若存在則跳過，避免重複下載浪費時間
if [ ! -f "$MIRROR_FILE" ]; then
    echo "正在更新鏡像站..."
    # 確保父目錄存在
    mkdir -p "$(dirname "$MIRROR_FILE")"
    reflector --country Taiwan --age 12 --protocol https --sort rate --save "$MIRROR_FILE"
else
    echo "偵測到已存在的鏡像站設定，跳過 reflector 更新。"
fi

echo "2. 讀取 PACS 變數，執行 pacstrap"
# ====================================

echo "預計安裝的所有套件為: ${PACS[*]}"

pacstrap -K "$TARGET_MNT" "${PACS[@]}"

echo "3. 生成 fstab"
# ==================
echo "開始生成 fstab..."

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

echo ""
echo "=== 「Arch Linux 安裝第四階段：pacstrap」 任務完成==="
echo ""
