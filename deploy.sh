#!/bin/bash

cat > Dockerfile << 'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y openssh-server socat websocketd -y
RUN mkdir -p /var/run/sshd
RUN echo 'root:jio@2026' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
EXPOSE 80
CMD service ssh start && websocketd --port=80 /bin/bash -c 'socat - TCP:localhost:22'
EOF

cat > render.yaml << 'EOF'
services:
  - type: web
    name: jio-ws-port80
    runtime: image
    plan: free
    dockerfilePath: ./Dockerfile
    ports:
      - port: 80
        protocol: http
EOF

cat > config.json << 'EOF'
{
    "type": "SSH",
    "name": "Jio 4G Port 80",
    "sshTunnelConfig": {
        "injectConfig": {
            "enabled": true,
            "payload": "GET / HTTP/1.1[crlf]Host: jio-ws-port80.onrender.com[crlf]Upgrade: websocket[crlf][crlf]"
        }
    },
    "encryptedLockedConfig": {
        "LockedAppConfig": {
            "TunnelType": "SSH",
            "IsSshLocked": false
        },
        "EncryptedLockedConfig": {
            "InjectConfig": {
                "IsEncrypted": false,
                "EncryptedPayload": "GET / HTTP/1.1[crlf]Host: jio-ws-port80.onrender.com[crlf]Upgrade: websocket[crlf][crlf]"
            },
            "SshConfig": {
                "IsEncrypted": false,
                "EncryptedHost": "jio-ws-port80.onrender.com",
                "EncryptedPort": "80",
                "EncryptedUsername": "root",
                "EncryptedPassword": "jio@2026"
            }
        }
    }
}
EOF

echo "Files created. Deploy on Render. Host after deploy: jio-ws-port80.onrender.com"
