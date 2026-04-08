FROM ubuntu:22.04
RUN apt-get update && apt-get install -y openssh-server socat websocketd -y
RUN mkdir -p /var/run/sshd
RUN echo 'root:jio@2026' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
EXPOSE 80
CMD service ssh start && websocketd --port=80 /bin/bash -c 'socat - TCP:localhost:22'
