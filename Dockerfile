FROM debian:13

ENV TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    SSH_USER=developer \
    SSH_PASSWORD="changeme" \
    SSH_PORT=22

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
        vim \
        net-tools \
        supervisor \
        cron \
        unzip \
        iputils-ping \
        git \
        iproute2 \
        python3-pip
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