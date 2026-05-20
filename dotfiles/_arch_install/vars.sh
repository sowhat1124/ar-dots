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
    #"@dots:home/${USER_NAME}/_dots"
    "@data:home/${USER_NAME}/_data"
    "@tmp:home/${USER_NAME}/tmp"
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
    #ntfs-3g             # 雖然核心自帶 ntfs3，但保留此工具供日常維護使用
    nano
    iwd
    git
    sudo
    stow
)

## =================
## Wayland
## =================
WAY_DT=(
    xorg-xwayland
    mesa
    vulkan-intel         # intel
    #xf86-video-amdgpu   # AMD
    #nvidia              # nvidia
    #nvidia-utils        # nvidia
    # 音效 =================================
    pipewire            # 音效
    #pipewire-pulse      # 音效：一般桌面應用程式
    #pipewire-jack       # 音效：專業影音/音樂製作軟體
    #pipewire-alsa       # 音效：極老舊或極底層的程式
    #wireplumber         # 音效：PipeWire 的政策管理器（Session Manager）
    #pavucontrol         # 音效：音量控制面板
    # for sway =================================
    #waybar              # 狀態欄
    #libnotify           # 通知守護進程
    #swaync              # 通知守護進程
    #pywal               # 生成配色、配置桌布
    # 其他 =========================
    #polkit              # 權限管理：遇到再說
    #rofi
    #adwaita-icon-theme  # 或你喜歡的任何圖標包，如 papirus-icon-theme
    #cliphist            # 剪貼簿管理器，透過 Rofi 作為選擇器。
    #rofimoji            # emoji
    #noto-fonts-emoji    # 顯示 emoji 圖示
    #waydroid
)

NIRI_WM=(
    xdg-desktop-portal-wlr      # portal
    niri                        # wm
    xwayland-satellite          # for x11
)

SWAY_WM=(
    #sway                # wm
    # for sway：剪貼簿 =========================
    #wl-clipboard        # 剪貼簿
    #grim                # 負責「抓取」螢幕內容（類似 scrot 的後端）。
    #slurp               # 負責「選取」螢幕區域（提供互動式滑鼠選取框）。
    #sway-contrib        # 多個由 Sway 社群維護的工具腳本
    # for sway：wall paper =========================
    #swaybg              # 桌布：Sway 社群最主流、輕量且穩定的替代工具是 swaybg
    #swww                # 桌布：支援多種過渡動畫（Fade, Step...）且效能極佳。
    #wpaperd             # 桌布：需要多螢幕獨立設定者。
    # 鎖屏管理 =========================
    #swaylock            # 鎖住畫面
    #swayidle            # 計時與觸發動作
    #swaylock-effects    # 鎖屏時背景變模糊或顯示自定義圖片，社群推薦(AUR)。
    )

## =================
## BASIC
## =================
BASIC=(
    fcitx5
    rime
)

## =================
## PKG_SYS
## =================
PKG_SYS=(
    networkmanager
    network-manager-applet
    #iwd
)


## =================
## TUI
## =================
TUI_TOOL=(
    less
    fastfetch
    sc-im
    visidata
    chafa               # forget what it is
    keyd
    htop

)

## =================
## others
## =================
PKG_OTHERS=(
    #imlib2    # (for st teminal)
)

# for X11:
# =================
# i3-wm
# i3blocks
# feh
# picmo
# rofi
# dmenu
# dunst
# libnotify
# scrot

# font:
# =================
# otf-font-awesome
# ttf-jetbrains-mono-nerd
# SarasaFixedSC-TTF-Unhinted-1.0.36
# SarasaFixedTC-TTF-Unhinted-1.0.36

# for podman:
# =================
# crun
# podman

# for distrobox:
# =================
# distrobox
# fuse-overlayfs # Rootless 模式的推薦組件

# flatpak: 
# flatpak install flathub com.github.tchx84.Flatseal    # 權限管理
# flatpak install flathub com.brave.Browser

