#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock

# Start servers
kill -9 $(pgrep -f "termux.x11")
export XDG_RUNTIME_DIR=$TMPDIR
termux-x11 :0 -ac -extension MIT-SHM &
pulseaudio --start --exit-idle-time=-1 --disallow-exit &
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
pactl unload-module module-suspend-on-idle
pactl load-module module-aaudio-sink

# Start GUI session
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
proot-distro login ubuntu --shared-tmp --user kento -- bash -c "DISPLAY=:0 XDG_RUNTIME_DIR=${TMPDIR} dbus-launch --exit-with-session openbox-session"

# Exit session
termux-wake-unlock
exit
