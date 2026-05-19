#!/bin/bash

echo ""
echo "=== Arch Linux： chroot 軟體安裝 ==="
echo ""

# before starting
# ===============
set -euo pipefail

# Load variables
if [ -f "./vars.sh" ]; then
    source ./vars.sh
    echo "成功讀取 vars.sh 變數"
else
    echo "錯誤：vars.sh 不存在!"
    echo "Arch Linux 安裝第六階段：任務失敗 ==="
    exit 1
fi

echo "預計安裝的 \$Wayland_DT 所有套件為: ${WAY_DT[*]}"

# 安裝 Wayland_DT
#pacman -S --noconfirm --needed --overwrite "*" "${WAY_DT[@]}"

echo ""
echo "=== 「Arch Linux ： chroot 軟體安裝」任務完成 ==="
echo ""
