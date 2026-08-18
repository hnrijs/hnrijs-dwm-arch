#!/bin/bash

# Monitor udisks2 system events
udisksctl monitor | while read -r line; do
    
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
    
done
