#!/bin/sh
# Network
setup-interfaces -a
ifup eth0

# Setup Alpine
sed -i -E 's/(local kernel_opts)=.*/\1="console=ttyS0"/' /usr/sbin/setup-disk
cp /mnt/answerfile ./
setup-alpine -f answerfile

poweroff
