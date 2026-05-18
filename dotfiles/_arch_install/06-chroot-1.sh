#!/bin/bash

# Load variables
if [ -f "./vars.sh" ]; then
    source ./vars.sh
    echo "成功讀取 vars.sh 變數"
else
    echo "錯誤：vars.sh 不存在!"
    echo "=== Arch Linux 安裝第六階段：任務失敗 ==="
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
    echo "=== Arch Linux 安裝第六階段：任務失敗 ==="
    exit 1
fi

arch-chroot "$TARGET_MNT" /bin/bash -c "cd /home/"$USER_NAME"/_dots/_arch_install && ./06-chroot-2.sh"
