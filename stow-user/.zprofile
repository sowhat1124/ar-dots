source $HOME/.bashrc

if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    sway
fi

#export FCITX_NO_EVENTFD=1

#TERMINAL=/data/bin/st

# 將自定義工具路徑放在原本的 PATH 之後
#export PATH="/data/bin:$PATH"
#for dir in "/data/appimages" "/data/bin" "/data/shells" "/data/bin/busybox-tools"; do
#    if [[ ":$PATH:" != *":$dir:"* ]]; then
#        export PATH="$PATH:$dir"
#    fi
#done

## 在 .zprofile 中
#typeset -U path  # 自動移除重複的路徑
#path=(/data/appimages /data/bin /data/shells /data/bin/busybox-tools $path)
#export PATH
