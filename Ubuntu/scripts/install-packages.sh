#!/bin/bash

VSCODE_URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64"
VIVALDI_URL="https://downloads.vivaldi.com/stable/vivaldi-stable_7.3.3635.9-1_arm64.deb"
ASDF_URL="https://github.com/asdf-vm/asdf/releases/download/v0.16.7/asdf-v0.16.7-linux-arm64.tar.gz"

# Install packages
apt update
apt upgrade -y
apt install -y pulseaudio dbus-x11 openbox sudo vim language-pack-ja fonts-noto-cjk fonts-noto-color-emoji fcitx5-mozc xterm x11-xserver-utils x11-xkb-utils python3-xdg wget openssh-client docker.io  git j4-dmenu-desktop tint2 pcmanfm libreoffice libreoffice-l10n-ja libgles2
# for python
apt install -y build-essential libbz2-dev libdb-dev libreadline-dev libffi-dev libgdbm-dev liblzma-dev libncursesw5-dev libsqlite3-dev libssl-dev zlib1g-dev uuid-dev tk-dev

# Vivaldi
wget -O vivaldi.deb "$VIVALDI_URL"
apt install -y ./vivaldi.deb
chown root:root /opt/vivaldi/vivaldi-sandbox
chmod 4755 /opt/vivaldi/vivaldi-sandbox
# VSCode
wget -O code.deb "$VSCODE_URL"
DEBIAN_FRONTEND=noninteractive apt install -y ./code.deb
# asdf
wget -O asdf.tar.gz "$ASDF_URL" 
tar -zxvf ./asdf.tar.gz
mv $HOME/asdf /usr/local/bin/asdf

rm $HOME/*.deb

# Setup User
useradd -m $USER_NAME
echo "${USER_NAME}:${PASSWORD}" | chpasswd
usermod -aG sudo $USER_NAME
echo "${USER_NAME} ALL=(ALL:ALL) ALL" >> /etc/sudoers
usermod -s /bin/bash $USER_NAME

# groups: cannot find name for group ID 1077対策
groupadd -g 1077 android

exit
