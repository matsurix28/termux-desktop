#!/data/data/com.termux/files/usr/bin/bash

TIME_OUT=60
INTERVAL=5
WAITED=0

QEMU_PID=$(pgrep qemu)

if [ -n "$QEMU_PID" ]; then
  echo "Connecting to QEMU..."
  until ssh -o StrictHostKeyChecking=no -p 2222 root@localhost true 2>/dev/null; do
    sleep 5
  done
  ssh -o StrictHostKeyChecking=no -p 2222 root@localhost poweroff
  echo "Shutting down QEMU..."
  # Wait finish QEMU process
  while pgrep qemu > /dev/null; do
    if [ "$WAITED" -ge "$TIME_OUT" ]; then
      echo "Time out."
      exit
    fi
    sleep "$INTERVAL"
    WAITED=$(( WAITED + INTERVAL ))
  done
  echo "Done."
else
  echo "No QEMU process."
  exit
fi
