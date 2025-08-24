FROM debian:bookworm-slim

# 安装必要软件：openssh-server, supervisor, 常用工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server supervisor curl vim ca-certificates net-tools && \
    rm -rf /var/lib/apt/lists/*

# SSH 必需目录
RUN mkdir /var/run/sshd && mkdir -p /var/log/supervisor

# 拷贝配置和脚本
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

# 暴露端口：22 SSH, 80 预留
EXPOSE 22 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n"]
