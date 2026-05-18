#!/bin/bash

set -euo pipefail

echo "=== Arch Linux 安裝第二階段：子卷建立 ==="

# Load variables
if [ -f "./vars.sh" ]; then
    source ./vars.sh
    echo "Variables loaded from vars.sh"
else
    echo "Error: vars.sh not found!"
    echo "=== Arch Linux 安裝第二階段：任務失敗 ==="
    exit 1
fi

mount "$ROOT_DEV "$TARGET_MNT"

# 子卷清單
SUBVOLS=(
    # /...
    "@:/"
    "@home:home"
    "@log:var/log"
    "@pkg:var/cache/pacman/pkg"
    "@snapshots:/.snapshots"
    "@flatpak_sys:var/lib/flatpak"
    "@libvirt_images:var/lib/libvirt/images"
    # /home/...
    "@podman_storage:home/ar/.local/share/containers/storage"
    "@dots:home/ar/_dots"
    "@data:home/ar/_data"
)

echo "--- 開始執行 Btrfs 子卷自動化任務 ---"

for item in "${SUBVOLS[@]}"; do
    # 使用 IFS 分割子卷名與路徑
    SV_NAME="${item%%:*}"       # 從右刪除到冒號（提取子卷名）
    SV_PATH="${item#*:}"        # 從左刪除到冒號（提取掛載路徑）
    FULL_PATH="${TARGET_MNT}/${SV_PATH}"

    echo "正在處理: $SV_NAME -> $FULL_PATH"

    # 建立 Btrfs 子卷：子卷通常建立在根分區的頂層，所以直接在 $MOUNT_ROOT 下建立
    if [ ! -d "${TARGET_MNT}/${SV_NAME}" ]; then
        btrfs subvolume create "${TARGET_MNT}/${SV_NAME}"
    else
        echo "   [跳過] 子卷 ${SV_NAME} 已存在。"
    fi
done

sync
umount -R /mnt

echo "=== 「Arch Linux 安裝第二階段：子卷建立」 任務完成==="

# -----------

# 變數說明：
# ROOT_DEV="/dev/nvme0n1p2"    # 要建立 Btrfs 分區設備路徑
# TARGET_MNT="/mnt"            # 臨時掛載根目錄

# 指令說明：
# set -e: 任何指令失敗即刻退出
# set -u: 使用未宣告變數即刻退出
# o pipefail: 管線中任何一段失敗即視為整體失敗

# note:
# flatpak apps: mount /var/lib/flatpak
# flatpak setting files: ~/.var/app, stow it)
# podman: mount ~/.local/share/containers/storage (包含鏡像、容器層與資料)
# KVM VM: mount /var/lib/libvirt/images (KVM 虛擬機磁碟所在。務必執行 chattr +C 停用 CoW 以確保效能。)
# KVM setting files in /etc/libvirt, stow it

#echo -e "\n提示：安裝完成進入系統後，請記得執行 'chown -R $USERNAME:$USERNAME /home/$USERNAME'"
