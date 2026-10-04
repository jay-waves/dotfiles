# 工具:
# GNU Tools (Coreutils)
# Starship, Zoxide, Fzf, tldr, Neovim

# 将 CapsLock 和 Escape 互换
xmodmap -e "keycode 9 = Caps_Lock"
xmodmap -e "keycode 66 = Escape"

# Network (with Clash/Mihomo localport)
proxy="http://127.0.0.1:7890" 
export all_proxy=$proxy
export https_proxy=$proxy
export http_proxy=$proxy
export ALL_PROXY=$proxy
export HTTPS_PROXY=$proxy
export HTTP_PROXY=$proxy
export no_pxory="localhost,127.0.0.1,::1"

# git config --global http.proxy "socks5://$host_ip:7890"
# git config --global https.proxy "socks5://$host_ip:7890"
#

# Readline (行内命令编辑，Vim 模式)
set -o vi

# Use  Ctrl+R to toggle Fzf History Walker
source /usr/share/fzf/shell/key-bindings.bash

# Starship
eval "$(starship init bash)"

# std tools 
export VISUAL='nvim'
export EDITOR='nvim'
export PAGER='bat --pager=builtin'
export SHELL='/usr/bin/bash'
