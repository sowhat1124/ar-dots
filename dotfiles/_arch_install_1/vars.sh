# 01 - 03
# ======================

TARGET_MNT="/mnt/new"             # 臨時掛載根目錄
BOOT_DEV="/dev/nvme0n1p1"         # EFI
ROOT_DEV="/dev/nvme0n1p2"         # 要建立 Btrfs 分區設備路徑
DISK_LABEL="ARCH_ROOT"
OPTS="noatime,compress=zstd:3"    # btrfs 子卷掛載參數

# chroot vars
HOST_NAME="host-arch"
USER_ROOT="root:s6213210916"
USER_AR="ar:1124"

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

# 04 pacstrap 基本工具
PACS=(
    base
    #base-devel
    linux-firmware
    mkinitcpio          # for linux-lts
    linux-lts
    btrfs-progs
    nano
    iwd
    sudo
    stow
    fuse2               # for appimage
)
#-------

#USERNAME="your_username"     # ⚠️ 修改為實際用戶名！
#TARGET_MNT="/mnt"
#MOUNT_OPTS="noatime,compress=zstd:3"
#
## 系統級掛載子卷 (stage2 自動掛載)
#SYS_SUBVOLS=(
#    "@home:home"
#    "@log:var/log"
#    "@pkg:var/cache/pacman/pkg"
#    "@libvirt_images:var/lib/libvirt/images"  # 移入 SYS 以自動掛載
#)
#
## 資料子卷 (僅建立，不自動掛載；fstab 或 stage3 使用)
#DATA_SUBVOLS=(
#    "@snapshots:.snapshots"
#    "@flatpak_sys:var/lib/flatpak"
#    "@podman_storage:podman_internal"  # Podman 手動掛載於用戶家目錄
#)
#
#USER_UID=1000
#USER_GID=1000


#03-subvolumes_mounting.sh

