# 掛載變數
# ========

TARGET_MNT="/mnt/new"             # 臨時掛載根目錄
BOOT_DEV="/dev/nvme0n1p1"         # EFI
ROOT_DEV="/dev/nvme0n1p2"         # 要建立 Btrfs 分區設備路徑
DISK_LABEL="ARCH_ROOT"
OPTS="noatime,compress=zstd:3"    # btrfs 子卷掛載參數

# chroot vars
# ===========
HOST_NAME="host-arch"
USER_ROOT="root:s6213210916"
USER_NAME="ar"
USER_PASS="1124"

# subvolume and disk to mount
# ===========================
# 子卷清單
SUBVOLS=(
    # /...
    "@:/"
    "@home:home"
    "@log:var/log"
    "@pkg:var/cache/pacman/pkg"
    "@snapshots:/.snapshots"
    #"@flatpak_sys:var/lib/flatpak"
    #"@libvirt_images:var/lib/libvirt/images"
    # /home/...
    #"@podman_storage:home/${USER_NAME}/.local/share/containers/storage"
    "@dots:home/${USER_NAME}/_dots"
    #"@data:home/${USER_NAME}/_data"
    "@tmp:home/${USER_NAME}/_tmp"
)

# NTFS 硬碟及個人資料夾 Bind 掛載掛載
# ===================================

# NTFS 硬碟掛載清單 (格式: "設備路徑:新系統內的掛載路徑")
NTFS_DISKS=(
    "/dev/sdb2:home/${USER_NAME}/_Storage/disk3"
    "/dev/sdc2:home/${USER_NAME}/_Storage/disk1"
    "/dev/sdc3:home/${USER_NAME}/_Storage/disk2"
)

# NTFS 掛載參數說明：
# uid=1000,gid=1000: 讓 ar 使用者擁有讀寫權限 (普通第一個建立的使用者 UID 通常是 1000)
# dmask=0022,fmask=0133: 資料夾權限 755，檔案權限 644
# nofail: 開機時如果沒偵測到這幾顆硬碟，系統依然能正常開機，不會卡住
NTFS_OPTS="uid=1000,gid=1000,dmask=0022,fmask=0133,nofail,windows_names"

# 個人資料夾 Bind 掛載清單 (格式: "disk1內的路徑:新系統家目錄路徑")
BIND_MOUNTS=(
    "home/${USER_NAME}/_Storage/disk1/Documents:home/${USER_NAME}/Documents"
    "home/${USER_NAME}/_Storage/disk1/Downloads:home/${USER_NAME}/Downloads"
    "home/${USER_NAME}/_Storage/disk1/Music:home/${USER_NAME}/Music"
    "home/${USER_NAME}/_Storage/disk1/Pictures:home/${USER_NAME}/Pictures"
    #"home/${USER_NAME}/_Storage/disk1/tmp:home/${USER_NAME}/tmp"
    "home/${USER_NAME}/_Storage/disk1/Videos:home/${USER_NAME}/Videos"
)

# pacstrap 基本工具
# =================
PACS=(
    base
    #base-devel
    linux-firmware
    mkinitcpio          # for linux-lts
    linux-lts
    btrfs-progs
    fuse2               # for appimage
    ntfs-3g             # 雖然核心自帶 ntfs3，但保留此工具供日常維護使用
    nano
    iwd
    git
    sudo
    stow
)

## 
## =================
#Wayland_DT=(
#)
#FONT=(
#)

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
