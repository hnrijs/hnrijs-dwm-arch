#!/bin/bash

# 1. Volume Change Listener
pactl subscribe 2>/dev/null | grep --line-buffered "Event 'change' on sink" | (
    prev_vol=""
    prev_mute=""
    while read -r _; do
        current_vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)
        is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes')
        
        # Only show OSD if the absolute volume or mute status ACTUALLY changed
        if [ "$current_vol" = "$prev_vol" ] && [ "$is_muted" = "$prev_mute" ]; then
            continue
        fi
        
        prev_vol="$current_vol"
        prev_mute="$is_muted"
        
        if [ "$is_muted" = "yes" ]; then
            dunstify -a "sysmenu_osd" -u low -h string:x-dunst-stack-tag:osd "󰖁 Volume: Muted"
        else
            val=$current_vol
            if [ "$val" -gt 100 ]; then val=100; fi
            dunstify -a "sysmenu_osd" -u low -h string:x-dunst-stack-tag:osd -h int:value:"$val" " Volume: ${current_vol}%"
        fi
    done
) &

# 2. Brightness Change Listener
udevadm monitor --subsystem-match=backlight 2>/dev/null | grep --line-buffered "change" | while read -r _; do
    current_br=$(brightnessctl i | grep -Po '(?<=\()\d+(?=\%\))')
    dunstify -a "sysmenu_osd" -u low -h string:x-dunst-stack-tag:osd -h int:value:"$current_br" "󰃠 Brightness: ${current_br}%"
done &

# 3. USB Connection Listener
udisksctl monitor 2>/dev/null | while read -r line; do
    if echo "$line" | grep -q "Added /org/freedesktop/UDisks2/block_devices/"; then
        device=$(echo "$line" | awk -F'/' '{print $NF}' | tr -d "'") 
        if [[ "$device" =~ ^sd[a-z]$ ]]; then
            notify-send -u normal -t 4000 "USB Connected 󰪹" "Device ($device) has been plugged in."
        fi
    elif echo "$line" | grep -q "Removed /org/freedesktop/UDisks2/block_devices/"; then
        device=$(echo "$line" | awk -F'/' '{print $NF}' | tr -d "'")
        if [[ "$device" =~ ^sd[a-z]$ ]]; then
            notify-send -u normal -t 4000 "USB Disconnected 󰪺" "Device ($device) has been unplugged."
        fi
    fi
done &

# 4. Network Connection Listener
nmcli monitor 2>/dev/null | while read -r line; do
    if echo "$line" | grep -q "connected to"; then
        network=$(echo "$line" | awk -F'connected to ' '{print $2}')
        notify-send -u low -t 4000 "󰤨 Network Connected" "$network"
    elif echo "$line" | grep -q "disconnected"; then
        iface=$(echo "$line" | awk '{print $1}' | tr -d ':')
        notify-send -u low -t 4000 "󰤭 Network Disconnected" "$iface"
    fi
done &

# 5. Bluetooth Connection Listener
dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',arg0='org.bluez.Device1'" 2>/dev/null | while read -r line; do
    if echo "$line" | grep -q "path=/org/bluez/hci0/dev_"; then
        mac=$(echo "$line" | grep -o "dev_[A-Z0-9_]*" | sed 's/dev_//;s/_/:/g')
    elif echo "$line" | grep -q 'string "Connected"'; then
        read -r next_line
        if echo "$next_line" | grep -q 'boolean true'; then
            name=$(bluetoothctl info "$mac" 2>/dev/null | grep "Name:" | awk -F': ' '{print $2}')
            [ -z "$name" ] && name="Device ($mac)"
            notify-send -u low -t 4000 "󰂱 Bluetooth Connected" "$name"
        elif echo "$next_line" | grep -q 'boolean false'; then
            name=$(bluetoothctl info "$mac" 2>/dev/null | grep "Name:" | awk -F': ' '{print $2}')
            [ -z "$name" ] && name="Device ($mac)"
            notify-send -u low -t 4000 "󰂲 Bluetooth Disconnected" "$name"
        fi
    fi
done &

wait
