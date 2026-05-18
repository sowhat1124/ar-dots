# =======================================
# test
# =======================================

#printf '%b' "$(cat ~/.cache/wal/sequences)"

# =======================================
# vi mode
#bindkey -v
# emacs mode
bindkey -e

# 1. 載入內建的編輯功能
autoload -Uz edit-command-line
zle -N edit-command-line

# 2. 定義一個包裝函式，強制該功能使用 busybox vi
_edit_busybox() {
  # 暫時改變環境變數並執行內建 widget
  VISUAL='/usr/local/bin/busybox vi' EDITOR='/usr/local/bin/busybox vi' zle edit-command-line
}

# 3. 將這個函式註冊為一個新的 ZLE Widget
zle -N _edit_busybox

# 4. 綁定按鍵 (vi 模式)
bindkey -M vicmd 'v' _edit_busybox

# 5. 如果你也想在 emacs 模式用這個
bindkey '^x^e' _edit_busybox
# 或者如果你喜歡 Alt-v (Meta-v)
# bindkey '^[v' edit-command-line
# =======================================

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep extendedglob nomatch notify

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/ar/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

[[ -f ~/.bashrc ]] && . ~/.bashrc

# 載入顏色模組
autoload -U colors && colors

# 載入自動建議
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# 載入語法高亮 (同樣必須放在最後)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# 設定 Prompt
# %n 是用戶名, %m 是主機名, %~ 是當前路徑, %# 是身份標識
#PROMPT="%{$fg[cyan]%}%n%{$reset_color%}%{$fg[white]%}@%{$fg[green]%}%m%{$reset_color%}:%{$fg[yellow]%}%~%{$reset_color%}%# "

#PROMPT="%{$fg[cyan]%}%n%{$reset_color%}%{$fg[white]%}@%{$fg[green]%}%m%{$reset_color%}:%{$fg[yellow]%}%~%{$reset_color%}>> "

# 1. 定義基礎顏色與格式
local c_user="%{$fg[cyan]%}"
local c_at="%{$fg[white]%}"
local c_host="%{$fg[green]%}"
local c_path="%{$fg[yellow]%}"
local c_reset="%{$reset_color%}"

# 2. 嘗試從實體檔案提取容器名稱
local container_name=""
if [ -f /run/.containerenv ]; then
    # 從檔案中抓取 name="..." 內容並去引號
    container_name=$(grep '^name=' /run/.containerenv | sed 's/name=//;s/"//g')
fi

# 3. 根據提取結果定義 PROMPT
if [ -n "$container_name" ]; then
    # 容器內：顯示 [容器名] br@c-arch:~>>
    # 這裡 %n 會自動反映 br，%m 反映主機名
    PROMPT="[%F{yellow}${container_name}%f] ${c_user}%n${c_reset}${c_at}@${c_reset}${c_host}%m${c_reset}:${c_path}%~${c_reset}>> "
else
    # 主系統：顯示 ar@arch-host:~>>
    PROMPT="${c_user}%n${c_reset}${c_at}@${c_reset}${c_host}%m${c_reset}:${c_path}%~${c_reset}>> "
fi

export PATH="$(npm config get prefix)/bin:$PATH"
