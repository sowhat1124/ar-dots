#!/bin/bash

#bash -c "cd /home/ar/_dots/dotfiles/_arch_install && bash ./chroot-2.sh"

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

# starting
# ========

echo "從 github 下載 dotfiles..."
# ===============================

# git clone 設定檔
find "$TARGET_MNT"/home/ar/_dots -mindepth 1 -delete

sudo -u "$USER_NAME" git clone git@github.com:sowhat1124/ar-dots.git "$TARGET_MNT"/home/"$USER_NAME"/_dots

echo "dotfiles 已下載"
echo ""

echo ""
echo "=== 「Arch Linux 安裝第五階段：before chroot」任務完成==="
echo ""
