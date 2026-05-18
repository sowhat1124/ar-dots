# README

## 指令說明

```bash
set -euo pipefail
```

set -e: 任何指令失敗即刻退出
set -u: 使用未宣告變數即刻退出
o pipefail: 管線中任何一段失敗即視為整體失敗

## 持久化

flatpak apps: mount /var/lib/flatpak
flatpak setting files: ~/.var/app, stow it)
podman: mount ~/.local/share/containers/storage (包含鏡像、容器層與資料)
KVM VM: mount /var/lib/libvirt/images (KVM 虛擬機磁碟所在。務必執行 chattr +C 停用 CoW 以確保效能。)
KVM setting files in /etc/libvirt, stow it

