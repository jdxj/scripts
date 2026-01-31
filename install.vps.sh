#!/usr/bin/env bash

set -euo pipefail

cleanup() {
    echo "cleanup..."
    rm -rf ./install.vps.sh
}
trap cleanup EXIT

# 密码
passwd

# 设置主机名
read -p "主机名: " -r name
hostnamectl hostname "$name"

# 生成key
ssh-keygen

# 安装必要软件
apt install -y zsh curl git vim wget make net-tools dnsutils telnet nload \
    chrony jq tcpdump netcat-openbsd wireguard-tools nmap

# zsh
if [ ! -e ~/.zshrc ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    sed -i '11s/robbyrussell/jonathan/' ~/.zshrc
fi

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

# scp
Subsystem sftp internal-sftp

# 应该自定义的部分
Port 22
EOF
systemctl restart sshd

# vim
tee ~/.vimrc << EOF
" 行号
set number
" 相对行号
augroup relative_numbser
    autocmd!
    autocmd InsertEnter * :set norelativenumber
    autocmd InsertLeave * :set relativenumber
augroup END

" 语法高亮
syntax on
" 在底部显示，当前处于命令模式还是插入模式。
set showmode
" 命令模式下，在底部显示，当前键入的指令。
set showcmd
" 开启文件类型检查，并且载入与该类型对应的缩进规则。
filetype indent on
" 按下回车键后，下一行的缩进会自动跟上一行的缩进保持一致。
set autoindent
" 高亮当前行
set cursorline
" 关闭自动折行
set nowrap
" 是否显示状态栏。0 表示不显示，1 表示只在多窗口时显示，2 表示显示。
set laststatus=1
" 光标遇到圆括号、方括号、大括号时，自动高亮对应的另一个圆括号、方括号和大括号。
set showmatch
" 搜索时，高亮显示匹配结果。
set hlsearch
" 保留撤销历史。
set undofile
" Vim 需要记住多少次历史操作。
set history=1000
" 打开文件监视。如果在编辑过程中文件发生外部改变（比如被别的编辑器编辑了），就会发出提示。
set autoread
" 命令模式下，底部操作指令按下 Tab 键自动补全。第一次按下 Tab，会显示所有匹配的操作指令的清单；第二次按下 Tab，会依次选择各个指令。
set wildmenu
set wildmode=longest:list,full
" 记住上次退出时光标位置
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
" 粘贴模式，避免格式错乱
set paste
" 显示光标位置
set ruler
" utf8
set encoding=utf-8
EOF

