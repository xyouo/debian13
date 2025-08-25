FROM debian:13

ENV TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    SSH_USER=developer \
    SSH_PASSWORD="changeme" \
    SSH_PORT=22

COPY entrypoint.sh /entrypoint.sh
COPY reboot.sh /usr/local/sbin/reboot

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
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
        python3.13 \
        python3.13-venv \
        python3-pip \
        python3-wheel \
        --no-install-recommends && \
    echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 LC_CTYPE=zh_CN.UTF-8 && \
    chmod 644 /etc/locale.gen && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    mkdir /var/run/sshd && \
    chmod +x /entrypoint.sh && \
    chmod +x /usr/local/sbin/reboot && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*;

EXPOSE ${SSH_PORT}

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]