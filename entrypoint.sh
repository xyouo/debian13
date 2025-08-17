#!/usr/bin/env sh

# 1. 创建 SSH 用户和配置
useradd -m -s /bin/bash "$SSH_USER"
echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
usermod -aG sudo "$SSH_USER"
echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/init-users
echo 'PermitRootLogin no' > /etc/ssh/sshd_config.d/my_sshd.conf

# 2. 启动 Cloudflare Tunnel
# 检查 CLOUDFLARE_TOKEN 环境变量，如果存在则启动 cloudflared
if [ -n "$CLOUDFLARE_TOKEN" ]; then
    echo "发现 CLOUDFLARE_TOKEN，正在启动 Cloudflare Tunnel..."
    cloudflared service install --token "$CLOUDFLARE_TOKEN"
    cloudflared tunnel run &
else
    echo "警告：未设置 CLOUDFLARE_TOKEN 环境变量，Cloudflare Tunnel 将不会启动。"
fi

# 3. 启动 SSH 服务
# 将 CMD 传递给 exec，让 sshd 成为容器主进程
# 这样做的好处是，当容器停止时，信号会直接传递给 sshd，确保它能优雅退出
exec "$@"