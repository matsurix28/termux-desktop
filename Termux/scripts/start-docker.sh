#!/data/data/com.termux/files/usr/bin/bash

print_help() {
  cat << EOF
Usage: start-docker [-Options]
Options:
  -d: Run in Background.
  -l: Login qemu after boot.
EOF
exit
}


IS_DAEMON=false
IS_LOGIN=false

while getopts "dlh?" opt; do
  case "$opt" in
    d) IS_DAEMON=true ;;
    l) IS_LOGIN=true ;;
    h) print_help ;;
    ?) print_help ;;
  esac
done


wait_qemu() {
  until ssh -o StrictHostKeyChecking=no -p 2222 root@localhost true 2>/dev/null; do
    sleep 5
  done
}


# Is QEMU running
QEMU_PID=$(pgrep qemu)
if [ -n "$QEMU_PID" ]; then
  echo "QEMU is already running. Do you want to restart it? [yes/no]: "
  read answer
  case "$answer" in
    [Yy][Ee][Ss]|[Yy])
      echo "Shutting down QEMU..."
      wait_qemu
      ssh -p 2222 root@localhost poweroff
      TIME_OUT=30
      WAITED=0
      INTERVAL=5
      while pgrep qemu > /dev/null; do
        if [ "$WAITED" -ge "$TIME_OUT" ]; then
	  echo "Time out."
	  exit
	fi
	sleep "$INTERVAL"
	WAITED=$(( WAITED + INTERVAL ))
      done
      echo "qemu syuryo"
      echo "Restart QEMU."
      ;;
    [Nn][Oo]|[Nn])
      exit
      ;;
  esac
fi


# Boot QEMU
export TERMUX_HOME=/data/data/com.termux/files/home

qemu-system-aarch64 -machine virt -m 4096 -smp cpus=1 -cpu cortex-a76 -drive if=pflash,format=raw,file=$TERMUX_HOME/qemu/docker/edk2-aarch64-code.fd -netdev user,id=n1,dns=8.8.8.8,hostfwd=tcp::2222-:22,hostfwd=tcp::5555-:2375 -device virtio-net-device,netdev=n1 -daemonize $TERMUX_HOME/qemu/docker/alpine.img
if $IS_DAEMON; then
  exit
fi

QEMU_PID=$(pgrep qemu)
if [ -n "$QEMU_PID" ]; then
  wait_qemu
  if $IS_LOGIN; then
    echo "QEMU has booted. Logging in now."
    ssh -p 2222 root@localhost
  else
    echo "QEMU has finished booting."
    exit
  fi
else
  echo "Could not start qemu."
fi
