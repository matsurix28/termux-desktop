#!/bin/sh
# Setup for SSH
cat << 'EOF' >> /etc/ssh/sshd_config
PasswordAuthentication yes
PermitRootLogin yes
PermitEmptyPasswords yes
PermitTunnel yes
AllowTcpForwarding yes
EOF

# Install packages for Docker
passwd -d root
apk update
apk add docker docker-compose gcompat libstdc++ curl bash

# Setup for Docker
service docker start
rc-update add docker
sed -i 's/DOCKER_OPTS="/DOCKER_OPTS="-H tcp:\/\/0.0.0.0:2375 -H unix:\/\/\/var\/run\/docker.sock/' /etc/conf.d/docker

poweroff
