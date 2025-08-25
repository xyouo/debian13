FROM debian:13

ENV TZ=Asia/Shanghai \
    SSH_USER=debian \
    SSH_PASSWORD=123123 \
    LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8

COPY entrypoint.sh /entrypoint.sh
COPY reboot.sh /usr/local/sbin/reboot

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y \
    locales \
    fonts-wqy-zenhei \
    tzdata \
    openssh-server \
    sudo \
    curl \
    ca-certificates \
    wget \
    vim \
    net-tools \
    supervisor \
    cron \
    unzip \
    iputils-ping \
    telnet \
    git \
    iproute2 \
    python3-pip \
    python3.13-venv \
    --no-install-recommends; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /var/run/sshd; \
    chmod +x /entrypoint.sh; \
    chmod +x /usr/local/sbin/reboot; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone; \
    echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen; \
    /usr/sbin/update-locale LANG=zh_CN.UTF-8

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]