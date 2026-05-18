#!/bin/bash

echo ""
echo "=== Arch Linux 安裝第三階段：子卷與硬碟掛載 ==="
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

# starting
# ========

echo "1. 處理子卷清單 \${SUBVOLS[@]}，掛載子卷"
# ============================================

# 為頂層 @ 子卷加上冪等性檢查
mkdir -p "$TARGET_MNT"
if ! mountpoint -q "$TARGET_MNT"; then
    mount -t btrfs -o "$OPTS,subvol=@" "$ROOT_DEV" "$TARGET_MNT"
    echo "   [成功] @ 子卷已掛載至 $TARGET_MNT"
else
    echo "   [跳過] $TARGET_MNT 已經是掛載點。"
fi
echo ""

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

# 為 EFI 掛載加上冪等性檢查
if ! mountpoint -q "$TARGET_MNT"/boot; then
    mount "$BOOT_DEV" "$TARGET_MNT"/boot
    echo "   [成功] EFI 已掛載"
else
    echo "   [跳過] $TARGET_MNT/boot 已經是掛載點。"
fi

echo ""

echo "3. 掛載外部 NTFS 硬碟"
# ==========================

# 檢查 vars.sh 是否有定義 NTFS 陣列與參數
if [ -n "${NTFS_DISKS+x}" ] && [ ${#NTFS_DISKS[@]} -gt 0 ]; then
    for ntfs_item in "${NTFS_DISKS[@]}"; do
        DEV_PATH="${ntfs_item%%:*}"   # 提取設備路徑 (如 /dev/sdb2)
        MNT_PATH="${ntfs_item#*:}"    # 提取掛載路徑 (如 home/ar/_Storage/disk3)
        FULL_NTFS_PATH="${TARGET_MNT}/${MNT_PATH}"

        echo "正在處理 NTFS 硬碟: $DEV_PATH -> $FULL_NTFS_PATH"

        # 建立目錄
        mkdir -p "$FULL_NTFS_PATH"

        # 冪等性檢查
        if ! mountpoint -q "$FULL_NTFS_PATH"; then
            # 使用 Linux 內建的高效能 ntfs3 驅動掛載
            if mount -t ntfs3 -o "$NTFS_OPTS" "$DEV_PATH" "$FULL_NTFS_PATH"; then
                echo "   [成功] NTFS 硬碟已掛載"
            else
                echo "   [警告] $DEV_PATH 掛載失敗！請確認該硬碟在 Windows 中是否有完全關機（無快速啟動）。"
            fi
        else
            echo "   [跳過] $FULL_NTFS_PATH 已經是掛載點。"
        fi
    done
else
    echo "[跳過] 未偵測到 NTFS 掛載設定。"
fi

echo ""

echo "3.5. 處理個人資料夾的 Bind 掛載"
# ====================================

if [ -n "${BIND_MOUNTS+x}" ] && [ ${#BIND_MOUNTS[@]} -gt 0 ]; then
    for bind_item in "${BIND_MOUNTS[@]}"; do
        SRC_PATH="${bind_item%%:*}"   # 來源路徑 (如 home/ar/_Storage/disk1/Documents)
        DST_PATH="${bind_item#*:}"    # 目標路徑 (如 home/ar/Documents)
        
        FULL_SRC="${TARGET_MNT}/${SRC_PATH}"
        FULL_DST="${TARGET_MNT}/${DST_PATH}"

        echo "正在處理 Bind 掛載: $FULL_SRC -> $FULL_DST"

        # 1. 確保 NTFS 碟內的來源資料夾存在（如果 Windows 那邊沒有，就在這裡自動建立）
        if [ ! -d "$FULL_SRC" ]; then
            mkdir -p "$FULL_SRC"
            echo "   [提示] 於 NTFS 硬碟中建立來源目錄: $SRC_PATH"
        fi

        # 2. 建立新系統家目錄下的目標掛載點
        mkdir -p "$FULL_DST"

        # 3. 執行 Bind 掛載與冪等性檢查
        if ! mountpoint -q "$FULL_DST"; then
            if mount --bind "$FULL_SRC" "$FULL_DST"; then
                echo "   [成功] Bind 掛載完成"
            else
                echo "   [錯誤] $SRC_PATH Bind 掛載失敗！"
            fi
        else
            echo "   [跳過] $FULL_DST 已經是掛載點。"
        fi
    done
else
    echo "[跳過] 未偵測到 Bind 掛載設定。"
fi

echo ""

echo "子卷與硬碟掛載完成，尚未缷載，等待下一階段 pacstrap"
# =========================================================

sync

echo ""
echo "=== 「Arch Linux 安裝第三階段：子卷與硬碟掛載」 任務完成==="
echo ""
