#!/data/data/com.termux/files/usr/bin/bash

ALPINE_URL="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-virt-3.21.3-aarch64.iso"

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

# User name and password for Ubuntu
echo "Please enter a username: "
read USER_NAME
echo "Please enter a password: "
stty -echo
read PASSWORD
stty echo
printf "\n"

termux-wake-lock

# Scripts
cp -r $ROOT_DIR/Termux/scripts $HOME/
chmod +x $HOME/scripts/*.sh
ln -s $HOME/scripts/start-gui.sh $PREFIX/bin/start-gui
ln -s $HOME/scripts/start-docker.sh $PREFIX/bin/start-docker
ln -s $HOME/scripts/exit-docker.sh $PREFIX/bin/exit-docker
ln -s $HOME/scripts/exit-openbox.sh $PREFIX/bin/exit-openbox

# termux:widget
mkdir -p $HOME/.shortcuts
cp $HOME/scripts/start-gui.sh $HOME/.shortcuts/Linux

pkg update
yes | pkg upgrade
pkg install -y x11-repo
pkg install -y proot-distro termux-x11-nightly pulseaudio vim qemu-system-aarch64-headless qemu-utils openssh wget

# .bashrc
echo 'alias ubuntu="proot-distro login ubuntu --shared-tmp"' >> $HOME/.bashrc
source $HOME/.bashrc


# ---------- Setup Ubuntu ----------
chmod +x $ROOT_DIR/Ubuntu/scripts/*.sh
proot-distro install ubuntu
proot-distro login ubuntu --bind $ROOT_DIR/Ubuntu:/mnt/shared -- bash -c "USER_NAME=$USER_NAME PASSWORD=$PASSWORD /mnt/shared/scripts/install-packages.sh"
proot-distro login ubuntu --user $USER_NAME --bind $ROOT_DIR/Ubuntu:/mnt/shared --shared-tmp -- bash -c "USER_NAME=$USER_NAME PASSWORD=$PASSWORD /mnt/shared/scripts/setup-desktop.sh"
proot-distro login ubuntu -- bash -c "apt install -y --allow-downgrades /home/$USER_NAME/mesa.deb && apt-mark hold mesa-vulkan-drivers && rm /home/$USER_NAME/mesa.deb"


# ---------- Setup QEMU for Docker ----------
chmod +x $ROOT_DIR/QEMU/scripts/*.sh
# Setup Boot
mkdir -p $HOME/qemu/iso
mkdir -p $HOME/qemu/docker
wget -O $HOME/qemu/iso/alpine-virt.iso "$ALPINE_URL"
cp $PREFIX/share/qemu/edk2-aarch64-code.fd $HOME/qemu/docker/
qemu-img create -f qcow2 $HOME/qemu/docker/alpine.img 32G

# Install Alpine
qemu-system-aarch64 -machine virt -m 4096 -smp cpus=1 -cpu cortex-a76 -drive if=pflash,format=raw,file=$HOME/qemu/docker/edk2-aarch64-code.fd -netdev user,id=n1,dns=8.8.8.8,hostfwd=tcp::2222-:22,hostfwd=tcp::5555-:2375 -device virtio-net-device,netdev=n1 -cdrom $HOME/qemu/iso/alpine-virt.iso -virtfs local,path=$ROOT_DIR/QEMU,mount_tag=hostshare,security_model=none -nographic $HOME/qemu/docker/alpine.img

sleep 5

# Setup for SSH
qemu-system-aarch64 -machine virt -m 4096 -smp cpus=1 -cpu cortex-a76 -drive if=pflash,format=raw,file=$HOME/qemu/docker/edk2-aarch64-code.fd -netdev user,id=n1,dns=8.8.8.8,hostfwd=tcp::2222-:22,hostfwd=tcp::5555-:2375 -device virtio-net-device,netdev=n1 -virtfs local,path=$ROOT_DIR/QEMU,mount_tag=hostshare,security_model=none -nographic $HOME/qemu/docker/alpine.img

rm -rf $ROOT_DIR
termux-wake-unlock
echo "The setup is complete."
exit
