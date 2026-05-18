#!/bin/bash

echo ""
echo "=== Arch Linux 安裝第二階段：子卷建立 ==="
echo ""

# before starting
# ===============
set -euo pipefail

# Load variables
if [ -f "./vars.sh" ]; then
    source ./vars.sh
    echo "成功讀取 vars.sh 變數："
else
    echo "錯誤：vars.sh 不存在!"
    echo "=== Arch Linux 安裝第二階段：任務失敗 ==="
    exit 1
fi

echo "Btrfs 分區設備路徑：$ROOT_DEV"
echo "掛載點：$TARGET_MNT"
echo ""

# starting
# ========

echo "1. 掛載 Btrfs 分區設備路徑 $ROOT_DEV 至 $TARGET_MNT"
# ========================================================

#mount -o subvolid=5 "$ROOT_DEV" "$TARGET_MNT"
mountpoint -q "$TARGET_MNT" || mount -o subvolid=5 "$ROOT_DEV" "$TARGET_MNT"
echo ""

echo "2. 處理子卷清單 \${SUBVOLS[@]}，建立以下子卷："
# ===================================================
printf "%s " "${SUBVOLS[@]%%:*}"

echo ""

for item in "${SUBVOLS[@]}"; do
    # 使用 IFS 分割子卷名與路徑
    SV_NAME="${item%%:*}"       # 從右刪除到冒號（提取子卷名）
    SV_PATH="${item#*:}"        # 從左刪除到冒號（提取掛載路徑）
    FULL_PATH="${TARGET_MNT}/${SV_PATH}"

    # 建立 Btrfs 子卷：子卷通常建立在根分區的頂層，所以直接在 $MOUNT_ROOT 下建立
    if [ ! -d "${TARGET_MNT}/${SV_NAME}" ]; then
        btrfs subvolume create "${TARGET_MNT}/${SV_NAME}"
        echo "已建立子卷 $SV_NAME"
    else
        echo "[跳過] 子卷 ${SV_NAME} 已存在。"
    fi
done

echo ""

echo "3. 結束並缷載..."
# =====================

sync
umount -R "$TARGET_MNT"

echo "已缷載 $TARGET_MNT"

echo ""
echo "=== 「Arch Linux 安裝第二階段：子卷建立」 任務完成==="
echo ""
