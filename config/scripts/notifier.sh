#!/bin/bash

# Function to show volume
show_volume() {
    local current_vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)
    local is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes')
    
    if [ "$is_muted" = "yes" ]; then
        dunstify -a "sysmenu_osd" -u low -h string:x-dunst-stack-tag:osd "󰖁 Volume: Muted"
    else
        local val=$current_vol
        if [ "$val" -gt 100 ]; then val=100; fi
        dunstify -a "sysmenu_osd" -u low -h string:x-dunst-stack-tag:osd -h int:value:"$val" " Volume: ${current_vol}%"
    fi
}

# Function to show brightness
show_brightness() {
    local current_br=$(brightnessctl i | grep -Po '(?<=\()\d+(?=\%\))')
    dunstify -a "sysmenu_osd" -u low -h string:x-dunst-stack-tag:osd -h int:value:"$current_br" "󰃠 Brightness: ${current_br}%"
}

# Listen for volume changes
pactl subscribe 2>/dev/null | grep --line-buffered "Event 'change' on sink" | while read -r _; do
    show_volume
done &

# Listen for brightness changes
udevadm monitor --subsystem-match=backlight 2>/dev/null | grep --line-buffered "change" | while read -r _; do
    show_brightness
done &

# Listen for USB changes
udisksctl monitor 2>/dev/null | while read -r line; do
    # If USB is INSERTED
    if echo "$line" | grep -q "Added /org/freedesktop/UDisks2/block_devices/"; then
        device=$(echo "$line" | awk -F'/' '{print $NF}' | tr -d "'") 
        # Filter to react only to main drives (sdb, sdc...), ignoring partitions
        if [[ "$device" =~ ^sd[a-z]$ ]]; then
            notify-send -u normal -t 4000 "USB Connected 󰪹" "Device ($device) has been plugged in."
        fi
        
    # If USB is REMOVED
    elif echo "$line" | grep -q "Removed /org/freedesktop/UDisks2/block_devices/"; then
        device=$(echo "$line" | awk -F'/' '{print $NF}' | tr -d "'")
        if [[ "$device" =~ ^sd[a-z]$ ]]; then
            notify-send -u normal -t 4000 "USB Disconnected 󰪺" "Device ($device) has been unplugged."
        fi
    fi
done &

wait
