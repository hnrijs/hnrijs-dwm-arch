#!/bin/bash

while true; do
    is_paused=$(dunstctl is-paused)
    if [ "$is_paused" = "true" ]; then
        dnd_state="󰂛  Do Not Disturb: ON"
    else
        dnd_state="󰂚  Do Not Disturb: OFF"
    fi

    clear_btn="󰎟  Clear All Notifications"
    close_btn="󰅖  Close Menu"

    history=$(dunstctl history | jq -r '.data[0][] | "   \(.appname.data): \(.summary.data)"' 2>/dev/null)

    if [ -z "$history" ]; then
        options="$dnd_state\n$clear_btn\n$close_btn\n   (Empty)"
    else
        options="$dnd_state\n$clear_btn\n$close_btn\n$history"
    fi

    chosen="$(echo -e "$options" | rofi -dmenu -p " Notifications")"

    case "$chosen" in
        "$dnd_state")
            dunstctl set-paused toggle
            ;;
        "$clear_btn")
            dunstctl close-all
            dunstctl history-clear 2>/dev/null
            ;;
        "$close_btn"|"")
            break
            ;;
        *)
            break
            ;;
    esac
done
