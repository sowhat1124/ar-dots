#!/bin/bash

# 1. 定義變數 (確保名稱統一)
DEV="/dev/nvme0n1p2"  
MNT="/mnt"            
OPTS="noatime,compress=zstd:3"

echo "--- 開始執行 Btrfs 子卷自動化任務 ---"

# 2. 先掛載根子卷 (@)
mkdir -p "$MNT"
if ! mountpoint -q "$MNT"; then
    mount -t btrfs -o "$OPTS,subvol=@" "$DEV" "$MNT"
    echo "   [成功] 根子卷 @ 已掛載至 $MNT"
else
    echo "   [跳過] $MNT 已經是掛載點。"
fi

# 3. 子卷清單
SUBVOLS=(
    "@home:home"
    "@log:var/log"
    "@pkg:var/cache/pacman/pkg"
    "@snapshots:.snapshots"
    "@flatpak_sys:var/lib/flatpak"
    "@libvirt_images:var/lib/libvirt/images"
    "@podman_storage:home/ar/.local/share/containers/storage"
    "@dots:home/ar/_dots"
    "@data:home/ar/_data"
)

for item in "${SUBVOLS[@]}"; do
    SV_NAME="${item%%:*}"       # 從右刪除到冒號（提取子卷名）
    SV_PATH="${item#*:}"        # 從左刪除到冒號（提取掛載路徑）
    FULL_PATH="${MNT}/${SV_PATH}"

    echo "正在處理: $SV_NAME -> $FULL_PATH"

    # 建立目錄
    mkdir -p "$FULL_PATH"

    # 使用正確的變數 $DEV
    if ! mountpoint -q "$FULL_PATH"; then
        # 建議加上 -t btrfs 強制指定類型
        mount -t btrfs -o "$OPTS,subvol=$SV_NAME" "$DEV" "$FULL_PATH"
        echo "   [成功] 已掛載至 $FULL_PATH"
    else
        echo "   [跳過] $FULL_PATH 已經是掛載點。"
    fi
done

# 4. 掛載 EFI 分區 (先建目錄再掛載)
echo "正在處理: EFI -> /mnt/boot"
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot && echo "   [成功] EFI 已掛載"

sync

echo "--- 任務完成 ---"

# -----------

# flatpak apps: mount /var/lib/flatpak
# flatpak setting files: ~/.var/app, stow it)
# podman: mount ~/.local/share/containers/storage (包含鏡像、容器層與資料)
# KVM VM: mount /var/lib/libvirt/images (KVM 虛擬機磁碟所在。務必執行 chattr +C 停用 CoW 以確保效能。)
# KVM setting files in /etc/libvirt, stow it

#echo -e "\n提示：安裝完成進入系統後，請記得執行 'chown -R $USERNAME:$USERNAME /home/$USERNAME'"
