#!/bin/bash
set -e

# 环境变量：账号密码（默认 root/rootpassword）
USER_NAME=${SSH_USER:-root}
USER_PASS=${SSH_PASS:-rootpassword}

# 如果用户不是 root，则新建用户
if [ "$USER_NAME" != "root" ]; then
    if ! id -u "$USER_NAME" >/dev/null 2>&1; then
        useradd -m "$USER_NAME"
    fi
fi

echo "$USER_NAME:$USER_PASS" | chpasswd

# 把 /root 替换成 /data 符号链接（保证 root 登录就是持久化目录）
if [ ! -L /root ]; then
    rm -rf /root
    mkdir -p /data
    ln -s /data /root
fi

# 启动 supervisor 管理服务
exec "$@"

