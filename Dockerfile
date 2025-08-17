FROM ubuntu:22.04

ENV TZ=Asia/Shanghai \
    SSH_USER=ubuntu \
    SSH_PASSWORD=ubuntu123

COPY entrypoint.sh /entrypoint.sh
COPY reboot.sh /usr/local/sbin/reboot

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    [cite_start]apt-get install -y tzdata openssh-server sudo curl ca-certificates wget vim net-tools supervisor cron unzip iputils-ping telnet git iproute2 --no-install-recommends; [cite: 2] \
    [cite_start]apt-get clean; [cite: 3] \
    [cite_start]rm -rf /var/lib/apt/lists/*; [cite: 3] \
    [cite_start]mkdir /var/run/sshd; [cite: 3] \
    [cite_start]chmod +x /entrypoint.sh; [cite: 4] \
    [cite_start]chmod +x /usr/local/sbin/reboot; [cite: 4] \
    [cite_start]ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; [cite: 5] \
    [cite_start]echo $TZ > /etc/timezone [cite: 5]

# 添加安装 Cloudflared 的步骤
# 从 Cloudflare 下载 Cloudflared 二进制文件
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared \
    && chmod +x /usr/local/bin/cloudflared

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]