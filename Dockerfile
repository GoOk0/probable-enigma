FROM ghcr.io/vevc/ubuntu:25.7.14

RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    useradd -m -s /bin/bash Bisam && \
    echo "root:Bisam" | chpasswd && \
    echo "Bisam:Bisam" | chpasswd && \
    usermod -aG sudo Bisam

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
