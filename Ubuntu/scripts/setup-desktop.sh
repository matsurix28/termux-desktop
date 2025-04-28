#!/bin/bash

MESA_DRIVER_ID='1PwY72_qxrEDG27qCCvru8xFp_-4_ay38'

# .bashrc
cat << 'EOF' >> $HOME/.bashrc
# asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
. <(asdf completion bash)

# Desktop environment
export TZ="Asia/Tokyo"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"

# Connect to QEMU alpine docker
export DOCKER_HOST=tcp://127.0.0.1:5555
EOF
source $HOME/.bashrc

# Install python
asdf plugin add python
asdf install python latest
asdf set -u python latest

# Install GPU driver
mkdir -p $HOME/gdown
$HOME/.asdf/shims/python -m venv $HOME/gdown/venv
$HOME/gdown/venv/bin/pip install gdown
# Download driver from Google drive
$HOME/gdown/venv/bin/gdown "$MESA_DRIVER_ID" -O mesa.deb
rm -rf $HOME/gdown

# Setup VSCode
code --no-sandbox --install-extension ms-vscode-remote.remote-containers

# Input method
im-config -n fcitx5
mkdir -p $HOME/.config/fcitx5
cp /mnt/shared/fcitx5/profile $HOME/.config/fcitx5/

# Settings for Xterm
cp /mnt/shared/.Xresources $HOME/

# Settings for openbox
mkdir -p $HOME/.config/openbox
cp /mnt/shared/openbox/* $HOME/.config/openbox/

# Settings for tint2
mkdir -p $HOME/.config/tint2
cp /mnt/shared/tint2/tint2rc $HOME/.config/tint2/

# VSCode SSH
mkdir -p $HOME/.ssh
cp /mnt/shared/ssh/config $HOME/.ssh/

# VSCode docker
mkdir -p $HOME/.config/Code/User
cp /mnt/shared/code/settings.json $HOME/.config/Code/User/

exit
