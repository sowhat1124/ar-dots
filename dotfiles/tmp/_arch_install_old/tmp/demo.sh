#!/bin/bash

# 使用反斜線 (\) 進行換行，注意 \ 後面不能有任何空格
WL_TOOLS=(
    'grim'                # 截圖工具
    'slurp'               # 區域選擇
    'wl-clipboard'        # 剪貼簿
    'xdg-desktop-portal-wlr' # 桌面門戶
)

UI_COMPONENTS=(
    'waybar'    # 狀態列
    'mako'      # 通知
    'swaybg'    # 桌布
    'swayidle'  # 閒置管理
    'swaylock'  # 鎖屏
)

# 安裝時直接呼叫陣列變數
echo "正在安裝 Wayland 工具..."
sudo pacman -S --noconfirm "${WL_TOOLS[@]}" "${UI_COMPONENTS[@]}"
