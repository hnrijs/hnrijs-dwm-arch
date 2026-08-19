#!/bin/bash

pactl subscribe 2>/dev/null | grep --line-buffered "Event 'change' on sink" | (
    get_vol_state() {
        local vol_info mute_info
        vol_info=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null)
        mute_info=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null)
        
        if [[ $vol_info =~ ([0-9]+)% ]]; then
            current_vol="${BASH_REMATCH[1]}"
        else
            current_vol="0"
        fi
        
        if [[ $mute_info == *"yes"* ]]; then
            is_muted="yes"
        else
            is_muted="no"
        fi
    }

    get_vol_state
    prev_vol="$current_vol"
    prev_mute="$is_muted"

    while read -r _; do
        get_vol_state
        
        if [ "$current_vol" = "$prev_vol" ] && [ "$is_muted" = "$prev_mute" ]; then
            continue
        fi
        
        prev_vol="$current_vol"
        prev_mute="$is_muted"
        
        if [ "$is_muted" = "yes" ]; then
            dunstify -a "sysmenu_osd" -u low -h string:x-dunst-stack-tag:osd "   Volume: Muted"
        else
            val=$current_vol
            [ "$val" -gt 100 ] && val=100
            dunstify -a "sysmenu_osd" -u low -h string:x-dunst-stack-tag:osd -h int:value:"$val" " Volume: ${current_vol}%"
        fi
    done
) &

udevadm monitor --subsystem-match=backlight 2>/dev/null | grep --line-buffered "change" | while read -r _; do
    br_info=$(brightnessctl i)
    if [[ $br_info =~ \(([0-9]+)%\) ]]; then
        current_br="${BASH_REMATCH[1]}"
        dunstify -a "sysmenu_osd" -u low -h string:x-dunst-stack-tag:osd -h int:value:"$current_br" "   Brightness: ${current_br}%"
    fi
done &

udisksctl monitor 2>/dev/null | while read -r line; do
    if [[ "$line" == *"Added /org/freedesktop/UDisks2/block_devices/"* ]]; then
        device="${line##*/}"
        device="${device%\'}"
        if [[ "$device" =~ ^sd[a-z]$ ]]; then
            notify-send -u normal -t 4000 "USB Connected   " "Device ($device) has been plugged in."
        fi
    elif [[ "$line" == *"Removed /org/freedesktop/UDisks2/block_devices/"* ]]; then
        device="${line##*/}"
        device="${device%\'}"
        if [[ "$device" =~ ^sd[a-z]$ ]]; then
            notify-send -u normal -t 4000 "USB Disconnected   " "Device ($device) has been unplugged."
        fi
    fi
done &

nmcli monitor 2>/dev/null | while read -r line; do
    if [[ "$line" == *"connected to"* ]]; then
        network="${line#*connected to }"
        notify-send -u low -t 4000 "   Network Connected" "$network"
    elif [[ "$line" == *"disconnected"* ]]; then
        iface="${line%%:*}"
        iface="${iface%% *}"
        notify-send -u low -t 4000 "   Network Disconnected" "$iface"
    fi
done &

dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',arg0='org.bluez.Device1'" 2>/dev/null | while read -r line; do
    if [[ "$line" == *"path=/org/bluez/hci0/dev_"* ]]; then
        mac="${line##*dev_}"
        mac="${mac%%[\"\']*}"
        mac="${mac//_/:}"
    elif [[ "$line" == *'string "Connected"'* ]]; then
        read -r next_line
        if [[ "$next_line" == *'boolean true'* ]]; then
            name=$(bluetoothctl info "$mac" 2>/dev/null | grep "Name:" | awk -F': ' '{print $2}')
            [ -z "$name" ] && name="Device ($mac)"
            notify-send -u low -t 4000 "   Bluetooth Connected" "$name"
        elif [[ "$next_line" == *'boolean false'* ]]; then
            name=$(bluetoothctl info "$mac" 2>/dev/null | grep "Name:" | awk -F': ' '{print $2}')
            [ -z "$name" ] && name="Device ($mac)"
            notify-send -u low -t 4000 "   Bluetooth Disconnected" "$name"
        fi
    fi
done &

wait
