#!/usr/bin/env sh

useradd -m -s /bin/bash $SSH_USER
echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
usermod -aG sudo $SSH_USER
echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/init-users
echo 'PermitRootLogin no' > /etc/ssh/sshd_config.d/my_sshd.conf

# 检查 Cloudflared Token 环境变量是否存在，如果存在则启动 Cloudflared
if [ -n "$CLOUDFLARED_TOKEN" ]; then
    echo "Starting Cloudflared Tunnel..."
    cloudflared tunnel run --token "$CLOUDFLARED_TOKEN" &
else
    echo "Warning: CLOUDFLARED_TOKEN environment variable is not set. Skipping Cloudflared Tunnel startup."
fi

exec "$@"