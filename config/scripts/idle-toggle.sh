#!/bin/bash

# Check if xidlehook is running
if pgrep -x "xidlehook" > /dev/null; then
    # Disable Idle Mode
    killall xidlehook
    xset -dpms
    xset s off
    notify-send -u normal "Caffeine Mode" "Enabled: Screen will not turn off."
else
    # Enable Idle Mode
    xset -dpms
    xset s off
    
    # Launch xidlehook in the background
    # --not-when-audio and --not-when-fullscreen are the magic flags!
    xidlehook \
      --not-when-audio \
      --not-when-fullscreen \
      --timer 60 "slock" "" \
      --timer 240 "systemctl suspend" "" &
      
    notify-send -u normal "Idle Mode" "Enabled: Lock (1m) -> Sleep (5m)."
fi
