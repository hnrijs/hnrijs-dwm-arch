#!/bin/bash
if xset q | grep -q "DPMS is Enabled"; then
    xset -dpms
    xautolock -disable
    notify-send -u normal "Caffeine Mode" "Enabled: Screen will not turn off."
else
    xset +dpms
    xset dpms 120 120 120
    xautolock -enable
    notify-send -u normal "Idle Mode" "Enabled: Lock (1m) -> Off (2m) -> Sleep (5m)."
fi
