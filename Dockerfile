FROM debian:13 AS builder

# 安装必要的系统软件包和构建工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    git \
    unzip \
    curl \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 下载并设置 cloudflared
RUN curl -L --output cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x cloudflared

# 下载并设置 ttyd
RUN curl -L --output ttyd https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 && \
    chmod +x ttyd

FROM debian:13

ENV TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    SSH_USER=developer \
    SSH_PASSWORD="changeme" \
    SSH_PORT=22

COPY --from=builder /app/cloudflared /usr/local/bin/cloudflared
COPY --from=builder /app/ttyd /usr/local/bin/ttyd

COPY entrypoint.sh /entrypoint.sh
COPY reboot.sh /usr/local/sbin/reboot

RUN DEBIAN_FRONTEND=noninteractive; \
    apt-get update && apt-get install -y --no-install-recommends \
    locales \
    fonts-wqy-zenhei \
    tzdata \
    openssh-server \
    sudo \
    curl \
    ca-certificates \
    wget \
    nano \
    vim \
    net-tools \
    supervisor \
    cron \
    unzip \
    tar \
    zip \
    jq \
    iputils-ping \
    git \
    iproute2 \
    python3-pip \
    python3.13-venv; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /var/run/sshd; \
    chmod +x /entrypoint.sh /usr/local/sbin/reboot; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone; \
    echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen; \
    /usr/sbin/update-locale LANG=zh_CN.UTF-8

EXPOSE ${SSH_PORT}

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]