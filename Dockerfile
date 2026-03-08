FROM ghcr.io/vevc/ubuntu:25.7.14

RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 22

CMD ["/bin/sh", "-c", "echo root:${ROOT_PASSWORD:-Bisam} | chpasswd && /usr/sbin/sshd -D"]
