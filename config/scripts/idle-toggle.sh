#!/bin/bash

if pgrep -x "xidlehook" > /dev/null; then
    killall xidlehook
    xset -dpms
    xset s off
    touch /tmp/caffeine
    notify-send -u normal "Caffeine Mode" "Enabled: System Will Stay Awake."
else
    xset -dpms
    xset s off
    rm -f /tmp/caffeine
    xidlehook \
      --not-when-audio \
      --not-when-fullscreen \
      --timer 60 "slock" "" \
      --timer 240 "systemctl suspend" "" &
    notify-send -u normal "Idle Mode" "Enabled: Lock (1m) -> Sleep (5m)."
fi

