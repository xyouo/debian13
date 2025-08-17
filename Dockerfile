FROM debian:13

LABEL org.opencontainers.image.source="https://github.com/vevc/debian"

ENV TZ=Asia/Shanghai SSH_USER=debian SSH_PASSWORD=debian!23 CLOUDFLARE_TOKEN=""

COPY entrypoint.sh /entrypoint.sh
COPY reboot.sh /usr/local/sbin/reboot

# 步骤 1: 更新 APT 并安装基础工具
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    openssh-server \
    sudo \
    curl \
    ca-certificates \
    wget \
    vim \
    net-tools \
    cron \
    unzip \
    iputils-ping \
    git \
    iproute2 \
    gnupg

# 步骤 2: 添加 Cloudflare 仓库并更新
RUN mkdir -p --mode=0755 /usr/share/keyrings && \
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null && \
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /etc/apt/sources.list.d/cloudflared.list

# 步骤 3: 安装 cloudflared
RUN apt-get update && apt-get install -y --no-install-recommends cloudflared

# 步骤 4: 清理和配置
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /var/run/sshd && \
    chmod +x /entrypoint.sh && \
    chmod +x /usr/local/sbin/reboot && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo "$TZ" > /etc/timezone

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]