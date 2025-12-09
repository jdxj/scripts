#!/usr/bin/env bash

# 密码
passwd

# 设置主机名
read -p "主机名: " -r name
hostnamectl hostname "$name"

# 安装必要软件
apt install -y zsh curl git vim wget make net-tools

# zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sed -i '11s/robbyrussell/jonathan/' ~/.zshrc

# tcp
wget https://raw.githubusercontent.com/yeahwu/v2ray-wss/main/tcp-window.sh && bash tcp-window.sh

# 生成key
ssh-keygen
cat ~/.ssh/id_ed25519.pub
