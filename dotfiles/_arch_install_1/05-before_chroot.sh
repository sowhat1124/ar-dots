#!/bin/bash

echo ""
echo "=== Arch Linux 安裝第五階段：before chroot ==="
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
    echo "Arch Linux 安裝第五階段：任務失敗 ==="
    exit 1
fi

echo "Btrfs 分區設備路徑：$ROOT_DEV"
echo "掛載點：$TARGET_MNT"
echo ""

echo "--- 檢查掛載狀態 ---"
echo ""

if ! mountpoint -q "$TARGET_MNT"; then
    echo "錯誤: $TARGET_MNT 尚未掛載，請先掛載分割區！"
    echo ""
    echo "=== Arch Linux 安裝第五階段：任務失敗 ==="
    exit 1
fi

# starting operating
# ==================

echo "使用 reflector 來自動篩選並更新台灣最快的鏡像站..."

pacman -S --noconfirm reflector

echo "正在更新鏡像站..."

reflector --country Taiwan --age 12 --protocol https --sort rate --save /home/ar/_dots/dotfiles/_tmpfiles/pacman_mirrors_reflector

echo "正在建立使用者檔案..."

# 複製 @dots 設定檔(使用 -T 參數可以更優雅地處理目錄對目錄的複製)
find "$TARGET_MNT"/home/ar/_dots -mindepth 1 -delete
cp -ax /home/ar/_dots "$TARGET_MNT"/home/ar/
echo "@dots 已建立"

# 複製 @data
find "$TARGET_MNT"/home/ar/_data -mindepth 1 -delete
cp -r /home/ar/_data/* "$TARGET_MNT"/home/ar/_data/
echo "@data 已建立"

echo ""
echo "=== 「Arch Linux 安裝第五階段：before chroot」 任務完成==="
echo ""
