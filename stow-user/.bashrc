#
# ~/.bashrc
#

# tmp
export LANG=en_US.UTF-8          # 預設語言設為英文，所有的選單、錯誤訊息
export LC_MESSAGES=en_US.UTF-8   # 系統訊息、提示語、錯誤報告
export LC_TIME=en_US.UTF-8       # 時間與日期的格式
export LC_CTYPE=zh_TW.UTF-8      # 字元辨識、編碼、中文顯示
#LC_ALL	強制覆蓋所有設定，建議留空，以免覆蓋上述細項

export EDITOR='/usr/local/bin/nv'

# 將自定義工具路徑放在原本的 PATH 之後
# for dir in "/home/ar/data/linux-shells" "/home/ar/.local/bin" ; do
#     if [[ ":$PATH:" != *":$dir:"* ]]; then
#         export PATH="$PATH:$dir"
#     fi
# done

alias sudo='sudo '

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# 讓 ls 有顏色
#alias ls='ls --color=auto'
#alias l='ls -alh'
# 將原有的 alias 修改為絕對路徑
alias ls='/usr/bin/ls --color=auto'
alias l='/usr/bin/ls -alh'

alias grep='grep --color=auto'
alias diff='diff --color=auto'

# 讓提示字元 (PS1) 變彩色（例如：使用者名稱變綠色）
#export PS1="\[\e[32m\]\u@\h\[\e[m\]:\[\e[34m\]\w\[\e[m\]\$ "

# yazi
# =====
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# scrot
# =====
cs() {
    local DIR="$HOME/tmp/imgs"
    mkdir -p "$DIR"
    # 執行截圖，注意 $f 在這裡不需要加反斜線，因為它是交給 scrot 解析
    scrot -s "$DIR/%Y-%m-%d-%H%M%S_screenshot.png" -e 'xclip -selection clipboard -t image/png -i $f && notify-send "截圖成功" "檔案：$f" -i $f'
}

# =======
# flatpak
# =======
alias brave="flatpak run com.brave.Browser"
alias flatseal="flatpak run com.github.tchx84.Flatseal"

# neovim
# ======
#alias n='/data/appimages/nv '
# 過濾 "Setting $HOME to /data/appimages/nv.home"
#alias n='HOME=/data/appimages/nv.home /data/appimages/nv'
#alias n='~/data/linux-appimages/nv 2>/dev/null'
#alias n='~/.local/bin/nv 2>/dev/null'

alias ts='date +%y%m%d%H%M%S'
alias nn='n `ts`'

# =====
# incus
# =====

# btrfs commands
# ==============
# alias commands
alias cbm='sudo mkdir -p /mnt/btrfs-root && sudo mount -o subvolid=5 /dev/sda2 /mnt/btrfs-root'
alias cbum='sudo umount /mnt/btrfs-root && sudo rmdir /mnt/btrfs-root'

# alias shells
alias sbbkr='sudo ~/data/linux-shells/backup-root.sh'
alias sbbkh='sudo ~/data/linux-shells/backup-home.sh'
alias sbbkd='sudo ~/data/linux-shells/backup-data.sh'
alias sbrr='sudo ~/data/linux-shells/restore-root.sh'

# chroot shells
alias ssac='~/data/linux-shells/snap-arch-chroot.sh' # shell snap arch-chroot
alias sslc='~/data/linux-shells/snap-chroot.sh' # shell snap linux chroot
alias ssns='~/data/linux-shells/snap-nspawn.sh' # shell snap nspawn

# startx
alias startx='startx ~/_dots/dotfiles/conf-xinitrc/xinitrc'
