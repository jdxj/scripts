#!/usr/bin/env bash

set -euo pipefail

# 密码
passwd

# 设置主机名
read -p "主机名: " -r name
hostnamectl hostname "$name"

# 生成key
ssh-keygen

# 安装必要软件
apt install -y zsh curl git vim wget make net-tools

# zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sed -i '11s/robbyrussell/jonathan/' ~/.zshrc

# tcp
wget https://raw.githubusercontent.com/yeahwu/v2ray-wss/main/tcp-window.sh && bash tcp-window.sh

# ssh
rm -rf /etc/ssh/sshd_config.d/*.conf
tee /etc/ssh/sshd_config << EOF
# 使用现代协议
Protocol 2

# 禁止 root 密码登录
PermitRootLogin without-password

# 禁止密码登录（只允许 SSH key)
PasswordAuthentication no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no

# 允许公钥认证
PubkeyAuthentication yes

# 禁止空密码
PermitEmptyPasswords no

# 禁止 X11、隧道、Agent forwarding
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
PermitTunnel no

# 安全相关
IgnoreRhosts yes
HostbasedAuthentication no
IgnoreUserKnownHosts yes

# 使用现代 HostKey(只用 ED25519 更快）
HostKey /etc/ssh/ssh_host_ed25519_key

# 强制使用更强的加密算法（兼容现代系统）
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
KexAlgorithms curve25519-sha256

# 登录限制
LoginGraceTime 20
MaxAuthTries 3
MaxSessions 2
MaxStartups 2:30:10

# 记录详细日志
LogLevel VERBOSE
EOF




rm -rf ./install.vps.sh