# 将基础镜像从 Ubuntu 22.04 更改为 Debian 13 "Trixie"
FROM debian:13

ENV TZ=Asia/Shanghai \
    SSH_USER=debian \
    SSH_PASSWORD=debian!23 \
    CLOUDFLARE_TOKEN="" # 这里定义了 CLOUDFLARE_TOKEN 变量

# 复制入口点和重启脚本
COPY entrypoint.sh /entrypoint.sh
COPY reboot.sh /usr/local/sbin/reboot

# 安装必要的软件包，包括通过官方 APT 仓库安装 cloudflared
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y tzdata openssh-server sudo curl ca-certificates wget vim net-tools cron unzip iputils-ping telnet git iproute2 --no-install-recommends; \
    \
    # 添加 Cloudflare GPG 密钥
    mkdir -p --mode=0755 /usr/share/keyrings; \
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null; \
    \
    # 添加 Cloudflare APT 仓库
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /etc/apt/sources.list.d/cloudflared.list; \
    \
    # 重新更新软件包列表并安装 cloudflared
    apt-get update; \
    apt-get install -y cloudflared; \
    \
    # 清理APT缓存并进行基本配置
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /var/run/sshd; \
    chmod +x /entrypoint.sh; \
    chmod +x /usr/local/sbin/reboot; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone

# 暴露 SSH 端口
EXPOSE 22

# 定义容器启动时的入口点和默认命令
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]