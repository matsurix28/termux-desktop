#!/bin/bash

ZENITY_WIDTH=300
ZENITY_HEIGHT=150

# Exit popup
if zenity --question --title="Exit openbox" --text="Do you want to shut down?" --width=$ZENITY_WIDTH --height=$ZENITY_HEIGHT; then
  # Back to HOME
  am start -a android.intent.action.MAIN -c android.intent.category.HOME
  exit-docker
  openbox --exit
fi

