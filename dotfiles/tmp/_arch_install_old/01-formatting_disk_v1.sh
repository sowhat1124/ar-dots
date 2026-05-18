#!/bin/bash

# 1. Enable exit on error
set -e

# 2. Load variables
if [ -f "./vars.sh" ]; then
    source ./vars.sh
    echo "Variables loaded from vars.sh"
else
    echo "Error: vars.sh not found!"
    exit 1
fi

echo "=== Stage 1: Disk Preparation ==="

# 3. Check if device exists
if [ ! -b "$TARGET_DEV" ]; then
    echo "Error: Device $TARGET_DEV not found!"
    exit 1
fi

# 4. Confirmation
echo "WARNING: This will wipe all data on $TARGET_DEV!"
read -p "Type 'YES' to confirm and proceed: " confirm

if [[ "$confirm" != "YES" ]]; then
    echo "Operation cancelled. You must type 'YES' (case-sensitive) to proceed."
    exit 1
fi

echo "Creating GPT partition table and partitions..."

# 5. Wipe and Partitioning
# -Z: Zap (destroy) structures, -o: New GPT, -n: New partition, -t: Type code
sgdisk -Z $TARGET_DEV
sgdisk -o $TARGET_DEV
sgdisk -n 1:0:${EFI_SIZE} -t 1:ef00 $TARGET_DEV
sgdisk -n 2:0:0          -t 2:8300 $TARGET_DEV

# Refresh partition table
partprobe $TARGET_DEV
sleep 1

echo "Formatting partitions..."

# 6. Format EFI partition (FAT32)
if [ -b "$EFI_PART" ]; then
    mkfs.vfat -F 32 "$EFI_PART"
else
    echo "Error: Partition $EFI_PART not found!"
    exit 1
fi

# 7. Format Btrfs partition
if [ -b "$ROOT_PART" ]; then
    mkfs.btrfs -f -L "$ROOT_LABEL" "$ROOT_PART"
else
    echo "Error: Partition $ROOT_PART not found!"
    exit 1
fi

echo "--------------------------------------"
lsblk -f $TARGET_DEV
echo "--------------------------------------"
echo "Stage 1 completed successfully!"
