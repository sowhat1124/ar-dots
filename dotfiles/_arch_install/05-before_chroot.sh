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

echo "rsync 從當前系統複制 _data 目錄..."
# ===============================

pacman -S --noconfirm --needed rsync

echo ""

# 推薦組合：保留時間戳記與內容，但不強求 NTFS 不支援的 Linux 權限
# rsync -rtv --delete /source/ /destination/
# dry-run: rsync -rtv --delete -n /source/ /destination/

#rsync -rtv --delete "/home/$USER_NAME/_Storage/disk1/_data/bin" "$TARGET_MNT/home/$USER_NAME/_data/"
#rsync -rtv --delete "/home/$USER_NAME/_Storage/disk1/_data/ar-dots" "$TARGET_MNT/home/$USER_NAME/_data/"
#rsync -rtv --delete "/home/$USER_NAME/_Storage/disk1/_data/user-local" "$TARGET_MNT/home/$USER_NAME/_data/"

rsync -rltDv --delete "/home/$USER_NAME/_Storage/disk1/_data/bin" "$TARGET_MNT/home/$USER_NAME/_data/"
rsync -rltDv --delete "/home/$USER_NAME/_Storage/disk1/_data/ar-dots" "$TARGET_MNT/home/$USER_NAME/_data/"

mkdir -p "$TARGET_MNT/home/$USER_NAME/_data/user-local/share"
rsync -rltDv --delete "/home/$USER_NAME/_Storage/disk1/_data/user-local/share/fcitx5" "$TARGET_MNT/home/$USER_NAME/_data/user-local/share/"

# btrfs to ntfs
# =============
#rsync -rtv --delete -n /home/ar/_Storage/disk1/_data/ar-dots /home/ar/test/
#rsync -rtv --delete --no-perms --no-owner --no-group /home/ar/_data/ar-dots /home/ar/_Storage/disk1/_data/

## git clone 設定檔
#find "$TARGET_MNT"/home/ar/_dots -mindepth 1 -delete

##sudo -u "$USER_NAME" git clone git@github.com:sowhat1124/ar-dots.git "$TARGET_MNT"/home/"$USER_NAME"/_dots

#git clone https://github.com/sowhat1124/ar-dots "$TARGET_MNT"/home/"$USER_NAME"/_dots

echo "dotfiles 已下載"
echo ""

echo ""
echo "=== 「Arch Linux 安裝第五階段：before chroot」任務完成==="
echo ""
