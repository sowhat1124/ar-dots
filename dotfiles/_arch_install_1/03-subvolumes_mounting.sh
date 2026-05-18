#!/bin/bash

echo ""
echo "=== Arch Linux 安裝第三階段：子卷掛載 ==="
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
    echo "=== Arch Linux 安裝第三階段：任務失敗 ==="
    exit 1
fi

echo "Btrfs 分區設備路徑：$ROOT_DEV"
echo "掛載點：$TARGET_MNT"
echo ""

# starting operating
# ==================
#
mount -t btrfs -o "$OPTS,subvol=@" "$ROOT_DEV" "$TARGET_MNT"

echo "1. 處理子卷清單$SUBVOLS([@]），掛載子卷"
# ============================================

for item in "${SUBVOLS[@]}"; do
    SV_NAME="${item%%:*}"       # 從右刪除到冒號（提取子卷名）
    SV_PATH="${item#*:}"        # 從左刪除到冒號（提取掛載路徑）
    FULL_PATH="${TARGET_MNT}/${SV_PATH}"

    echo "正在處理: $SV_NAME -> $FULL_PATH"

    # 建立目錄
    mkdir -p "$FULL_PATH"

    # 使用正確的變數 $ROOT_DEV
    if ! mountpoint -q "$FULL_PATH"; then
        # 建議加上 -t btrfs 強制指定類型
        mount -t btrfs -o "$OPTS,subvol=$SV_NAME" "$ROOT_DEV" "$FULL_PATH"
        echo "   [成功] 已掛載至 $FULL_PATH"
    else
        echo "   [跳過] $FULL_PATH 已經是掛載點。"
    fi
done

echo ""

echo "2. 掛載 EFI 分區"
# =====================

echo "正在處理: EFI -> $TARGET_MNT/boot"
mkdir -p "$TARGET_MNT"/boot
mount "$BOOT_DEV" "$TARGET_MNT"/boot && echo "   [成功] EFI 已掛載"

echo ""

echo "3. 子卷掛載任務完成，尚未缷載，等待下一階段 pacstrap"
# =========================================================

sync

echo ""
echo "=== 「Arch Linux 安裝第三階段：子卷掛載」 任務完成==="
echo ""
