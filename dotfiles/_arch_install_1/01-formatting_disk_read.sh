#!/bin/bash

# before starting
# ===============
set -euo pipefail

echo "=== Arch Linux 安裝第一階段：硬碟準備 (互動版) ==="

# 1. 讓使用者手動輸入目標磁碟
lsblk
echo ""
read -p "請輸入目標磁碟路徑 (例如 /dev/nvme0n1): " TARGET_DEV

# 2. 基本安全檢查
if [ ! -b "$TARGET_DEV" ]; then
    echo "錯誤: '$TARGET_DEV' 不是有效的區塊裝置。"
    exit 1
fi

# 3. 二次確認
echo "警告：即將清除 $TARGET_DEV 的所有資料並建立 GPT 分區表。"
read -p "確定繼續？ [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[yY]$ ]]; then
    echo "已取消操作。"
    exit 1
fi

echo "--- 執行中 ---"

# 4. 執行分區 (使用 sgdisk)
echo "正在建立分區表..."
sgdisk -Z "$TARGET_DEV"  # 抹除原有資料
sgdisk -o "$TARGET_DEV"  # 建立新 GPT
sgdisk -n 1:0:+1G -t 1:ef00 "$TARGET_DEV" # EFI 分區
sgdisk -n 2:0:0   -t 2:8300 "$TARGET_DEV" # Btrfs 主分區

# 5. 強制核心更新分區資訊
partprobe "$TARGET_DEV"
# 稍微等待系統反應，避免接下來的格式化抓不到路徑
sleep 1

# 6. 格式化 (處理 NVMe 分區命名邏輯)
# NVMe 分區通常是 p1, p2；一般 SATA 則是 1, 2
if [[ "$TARGET_DEV" == *"nvme"* ]]; then
    PART_EFI="${TARGET_DEV}p1"
    PART_ROOT="${TARGET_DEV}p2"
else
    PART_EFI="${TARGET_DEV}1"
    PART_ROOT="${TARGET_DEV}2"
fi

echo "正在格式化 EFI 分區: $PART_EFI"
mkfs.vfat -F 32 "$PART_EFI"

echo "正在格式化 Btrfs 主分區: $PART_ROOT"
mkfs.btrfs -f -L ARCH_ROOT "$PART_ROOT"

echo "---"
lsblk -f "$TARGET_DEV"
echo "---"
echo "=== 「Arch Linux 安裝第一階段：硬碟準備」成功完成！ ==="
