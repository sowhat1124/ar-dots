# =======
# 01-formatting_disk
# =======
TARGET_DEV="/dev/nvme0n1"    # disk to format
EFI_SIZE="+1G"               # EFI size
ROOT_LABEL="ARCH_ROOT"       # fstab label
EFI_PART="/dev/nvme0n1p1"    # 請依實際調整
ROOT_PART="/dev/nvme0n1p2"   # 請依實際調整

# =======
# 02-subvolumes_creating
# =======

TARGET_DEV="/dev/nvme0n1"    # disk to format
# 定義目標設備與掛載根目錄
ROOT_DEV="/dev/nvme0n1p2"  # 請替換為你的 Btrfs 分區設備路徑
TARGET_MNT="/mnt"            # 臨時掛載根目錄




# =======
# 
# =======
USERNAME="your_username"     # ⚠️ 修改為實際用戶名！
TARGET_MNT="/mnt"
BOOT_MNT="/mnt/boot"
MOUNT_OPTS="noatime,compress=zstd:3"

# 系統級掛載子卷 (stage2 自動掛載)
SYS_SUBVOLS=(
    "@home:home"
    "@log:var/log"
    "@pkg:var/cache/pacman/pkg"
    "@libvirt_images:var/lib/libvirt/images"  # 移入 SYS 以自動掛載
)

# 資料子卷 (僅建立，不自動掛載；fstab 或 stage3 使用)
DATA_SUBVOLS=(
    "@snapshots:.snapshots"
    "@flatpak_sys:var/lib/flatpak"
    "@podman_storage:podman_internal"  # Podman 手動掛載於用戶家目錄
)

USER_UID=1000
USER_GID=1000


03-subvolumes_mounting.sh

