#!/bin/bash

# before starting
# ===============
set -euo pipefail

echo "=== Arch Linux 安裝第一階段：硬碟準備 (讀取變數版) ==="

# 1. 載入變數
if [ -f "./vars.sh" ]; then
    source ./vars.sh
    echo "已載入 vars.sh 設定。"
else
    echo "錯誤: 找不到 ./vars.sh，請先建立變數檔案。"
    exit 1
fi

echo "目標裝置: $TARGET_DEV"
echo "----------------------------------------"

# 2. 基本安全檢查
if [ ! -b "$TARGET_DEV" ]; then
    echo "錯誤: '$TARGET_DEV' 不是有效的區塊裝置。"
    exit 1
fi

# 3. 強制確認機制 (嚴格檢查 "YES")
echo "警告：這將徹底抹除 $TARGET_DEV 的所有資料！"
read -p "請輸入完整的 'YES' (大寫) 以繼續執行: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "確認失敗。操作已取消。"
    exit 1
fi

echo "確認成功，開始執行..."

# 4. 執行分區 (使用 sgdisk)
echo "正在建立分區表..."
sgdisk -Z "$TARGET_DEV"  # 抹除原有資料
sgdisk -o "$TARGET_DEV"  # 建立新 GPT
sgdisk -n 1:0:+1G -t 1:ef00 "$TARGET_DEV" # EFI 分區
sgdisk -n 2:0:0   -t 2:8300 "$TARGET_DEV" # Btrfs 主分區

# 5. 強制核心更新分區資訊
partprobe "$TARGET_DEV"
# 稍微等待系統反應，避免接下來的格式化抓不到路徑
sleep 2

# 6. 格式化 (處理 NVMe 分區命名邏輯)
# NVMe 分區通常是 p1, p2；一般 SATA 則是 1, 2
if [[ "$TARGET_DEV" == *"nvme"* ]]; then
    PART_EFI="${TARGET_DEV}p1"
    PART_ROOT="${TARGET_DEV}p2"
else
    PART_EFI="${TARGET_DEV}1"
    PART_ROOT="${TARGET_DEV}2"
fi

# 7. 格式化
echo "正在格式化 EFI 分區: $PART_EFI"
mkfs.vfat -F 32 "$PART_EFI"

echo "正在格式化 Btrfs 主分區: $PART_ROOT"
mkfs.btrfs -f -L ARCH_ROOT "$PART_ROOT"

echo "---"
lsblk -f "$TARGET_DEV"
echo "---"
echo "=== 「Arch Linux 安裝第一階段：硬碟準備」成功完成！ ==="
