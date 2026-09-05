#!/bin/bash

options="  Audio\n  Network\n  Bluetooth\n  Monitors\n  Keyboard\n  Brightness\n  Night Light\n  Power\n  Notifications\n  DNS\n  Firewall\n  Tools\n  Configure DWM"

chosen="$(echo -e "$options" | rofi -normal-window -dmenu -p "System Menu")"

if [ -z "$chosen" ]; then
  exit 0
fi

case "$chosen" in
*"Audio"*)
  while true; do
    audio_options="  Open Pavucontrol\n  Volume Up (+5%)\n  Volume Down (-5%)\n󰝟  Mute Toggle\n  Back"
    audio_chosen="$(echo -e "$audio_options" | rofi -normal-window -dmenu -p "Audio Menu")"

    case "$audio_chosen" in
    *"Open Pavucontrol"*)
      if ! pacman -Q pavucontrol &>/dev/null; then
        alacritty -e sh -c "sudo pacman -S --noconfirm pavucontrol && pavucontrol"
      else
        pavucontrol &
      fi
      ;;
    *"Volume Up"*)
      pactl set-sink-volume @DEFAULT_SINK@ +5%
      ;;
    *"Volume Down"*)
      pactl set-sink-volume @DEFAULT_SINK@ -5%
      ;;
    *"Mute Toggle"*)
      pactl set-sink-mute @DEFAULT_SINK@ toggle
      ;;
    "" | *"Back"*)
      break
      ;;
    esac
  done
  exec "$0"
  ;;
*"Network"*)
  while true; do
    net_options="  Show Networks\n  Enable Network\n  Disable Network\n  Remove Network\n  Back"
    net_chosen="$(echo -e "$net_options" | rofi -normal-window -dmenu -p "Network Menu")"

    case "$net_chosen" in
    *"Show Networks"*)
      wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d")
      chosen_network=$(echo -e "  Back\n$wifi_list" | uniq -u | rofi -normal-window -dmenu -i -p "Wi-Fi SSID: ")

      if [ -z "$chosen_network" ] || [[ "$chosen_network" == *"Back"* ]]; then
        continue
      else
        read -r chosen_id <<<"${chosen_network:3}"
        saved_connections=$(nmcli -g NAME connection)
        if [[ $(echo "$saved_connections" | grep -w "$chosen_id") = "$chosen_id" ]]; then
          nmcli connection up id "$chosen_id"
        else
          if [[ "$chosen_network" =~ "" ]]; then
            wifi_password=$(rofi -normal-window -dmenu -p "Password: ")
          fi
          nmcli device wifi connect "$chosen_id" password "$wifi_password"
        fi
      fi
      ;;
    *"Enable Network"*)
      if ! pacman -Q networkmanager &>/dev/null; then
        alacritty -e sh -c "sudo pacman -S --noconfirm networkmanager && sudo systemctl enable --now NetworkManager"
      else
        alacritty -e sh -c "sudo systemctl enable --now NetworkManager"
      fi
      ;;
    *"Disable Network"*)
      alacritty -e sh -c "sudo systemctl disable --now NetworkManager"
      ;;
    *"Remove Network"*)
      alacritty -e sh -c "sudo systemctl disable --now NetworkManager; sudo pacman -Rdd --noconfirm networkmanager"
      ;;
    "" | *"Back"*)
      break
      ;;
    esac
  done
  exec "$0"
  ;;
*"Bluetooth"*)
  while true; do
    bt_options="  Open Bluetui\n  Enable Bluetooth\n  Disable Bluetooth\n  Remove Bluetooth\n  Back"
    bt_chosen="$(echo -e "$bt_options" | rofi -normal-window -dmenu -p "Bluetooth Menu")"

    case "$bt_chosen" in
    *"Open Bluetui"*)
      if ! pacman -Q bluez bluez-utils bluetui &>/dev/null; then
        alacritty -e sh -c "sudo pacman -S --noconfirm bluez bluez-utils bluetui && sudo systemctl enable --now bluetooth && sleep 1 && bluetui"
      else
        if ! systemctl is-active --quiet bluetooth; then
          alacritty -e sh -c "sudo systemctl enable --now bluetooth && sleep 1 && bluetui"
        else
          alacritty -e bluetui
        fi
      fi
      ;;
    *"Enable Bluetooth"*)
      if ! pacman -Q bluez bluez-utils bluetui &>/dev/null; then
        alacritty -e sh -c "sudo pacman -S --noconfirm bluez bluez-utils bluetui && sudo systemctl enable --now bluetooth"
      else
        alacritty -e sh -c "sudo systemctl enable --now bluetooth"
      fi
      ;;
    *"Disable Bluetooth"*)
      alacritty -e sh -c "sudo systemctl disable --now bluetooth"
      ;;
    *"Remove Bluetooth"*)
      alacritty -e sh -c "sudo systemctl disable --now bluetooth; sudo pacman -Rdd --noconfirm bluez bluez-utils bluetui"
      ;;
    "" | *"Back"*)
      break
      ;;
    esac
  done
  exec "$0"
  ;;
*"Monitors"*)
  while true; do
    mon_options="  Open ARandR (GUI)\n  List Monitors (CLI)\n  Back"
    mon_chosen="$(echo -e "$mon_options" | rofi -normal-window -dmenu -p "Monitor Menu")"

    case "$mon_chosen" in
    *"Open ARandR"*)
      if ! pacman -Q arandr &>/dev/null; then
        alacritty -e sudo pacman -S --noconfirm arandr
      fi
      arandr &
      ;;
    *"List Monitors"*)
      alacritty -e sh -c "xrandr; echo ''; echo 'Press enter to close'; read"
      ;;
    "" | *"Back"*)
      break
      ;;
    esac
  done
  exec "$0"
  ;;
*"Keyboard"*)
  while true; do
    kbd_options="  Set US Layout\n  Set LV Layout\n  Custom Localectl Status\n  Back"
    kbd_chosen="$(echo -e "$kbd_options" | rofi -normal-window -dmenu -p "Keyboard Menu")"

    case "$kbd_chosen" in
    *"Set US Layout"*)
      localectl set-x11-keymap us
      ;;
    *"Set LV Layout"*)
      localectl set-x11-keymap lv
      ;;
    *"Custom Localectl Status"*)
      alacritty -e sh -c "localectl status; echo ''; echo 'Press enter to close'; read"
      ;;
    "" | *"Back"*)
      break
      ;;
    esac
  done
  exec "$0"
  ;;
*"Brightness"*)
  while true; do
    bright_options="  Brightness Up (+5%)\n  Brightness Down (-5%)\n  Max Brightness (100%)\n  Min Brightness (10%)\n  Back"
    bright_chosen="$(echo -e "$bright_options" | rofi -normal-window -dmenu -p "Brightness Menu")"

    case "$bright_chosen" in
    *"Brightness Up"*)
      brightnessctl set +5%
      ;;
    *"Brightness Down"*)
      brightnessctl set 5%-
      ;;
    *"Max Brightness"*)
      brightnessctl set 100%
      ;;
    *"Min Brightness"*)
      brightnessctl set 10%
      ;;
    "" | *"Back"*)
      break
      ;;
    esac
  done
  exec "$0"
  ;;
*"Night Light"*)
  while true; do
    nl_options="  Toggle Night Light (4500K)\n  Reset to Daylight (6500K)\n  Custom Temp (CLI)\n  Back"
    nl_chosen="$(echo -e "$nl_options" | rofi -normal-window -dmenu -p "Night Light Menu")"

    case "$nl_chosen" in
    *"Toggle Night Light"*)
      if ! pacman -Q redshift &>/dev/null; then
        alacritty -e sh -c "sudo pacman -S --noconfirm redshift"
      fi
      pkill redshift
      redshift -O 4500 &
      dunstify -u normal "Night Light" "Enabled (4500K)"
      ;;
    *"Reset to Daylight"*)
      pkill redshift
      redshift -x
      dunstify -u normal "Night Light" "Reset to Daylight (6500K)"
      ;;
    *"Custom Temp"*)
      alacritty -e sh -c "echo 'Enter desired temperature (e.g., 4000): '; read temp; pkill redshift; redshift -O \$temp; echo 'Applied!'; sleep 2"
      ;;
    "" | *"Back"*)
      break
      ;;
    esac
  done
  exec "$0"
  ;;
*"Power"*)
  while true; do
    power_options="  Power Plan\n󰒲  Idle Toggle\n  Back"
    power_chosen="$(echo -e "$power_options" | rofi -normal-window -dmenu -p "Power Menu")"

    case "$power_chosen" in
    *"Power Plan"*)
      while true; do
        plan_options="  Performance\n  Balanced\n  Power Saver\n  Back"
        plan_chosen="$(echo -e "$plan_options" | rofi -normal-window -dmenu -p "Select Power Plan")"
        case "$plan_chosen" in
        *"Performance"*)
          powerprofilesctl set performance
          dunstify -u normal "Power Plan" "Performance Mode Enabled"
          ;;
        *"Balanced"*)
          powerprofilesctl set balanced
          dunstify -u normal "Power Plan" "Balanced Mode Enabled"
          ;;
        *"Power Saver"*)
          powerprofilesctl set power-saver
          dunstify -u normal "Power Plan" "Power Saver Mode Enabled"
          ;;
        "" | *"Back"*)
          break
          ;;
        esac
      done
      ;;
    *"Idle Toggle"*)
      sh -c "$HOME/.config/scripts/idle-toggle.sh"
      ;;
    "" | *"Back"*)
      break
      ;;
    esac
  done
  exec "$0"
  ;;
*"Notifications"*)
  while true; do
    if [ -f /tmp/dnd ]; then
      dnd_state="󰂛  Do Not Disturb: ON"
    else
      dnd_state="󰂚  Do Not Disturb: OFF"
    fi

    clear_btn="󰎟  Clear All Notifications"
    close_btn="  Back"

    history=$(dunstctl history 2>/dev/null | jq -r '.data[0][] | "   \(.appname.data): \(.summary.data)"' 2>/dev/null)

    if [ -z "$history" ]; then
      options="$dnd_state\n$clear_btn\n$close_btn\n   (Empty)"
    else
      options="$dnd_state\n$clear_btn\n$close_btn\n$history"
    fi

    chosen="$(echo -e "$options" | rofi -normal-window -dmenu -format i -p " Notifications")"

    case "$chosen" in
    0)
      if [ -f /tmp/dnd ]; then
        rm -f /tmp/dnd
        dunstctl set-paused false
      else
        touch /tmp/dnd
        dunstctl set-paused true
      fi
      sleep 0.1
      ;;
    1)
      dunstctl close-all
      dunstctl history-clear 2>/dev/null
      sleep 0.1
      ;;
    "" | 2 | *)
      break
      ;;
    esac
  done
  exec "$0"
  ;;
*"DNS"*)
  while true; do
    dns_options="  Set Cloudflare (1.1.1.1)\n  Set Google (8.8.8.8)\n  Reset to DHCP (Default)\n  Back"
    dns_chosen="$(echo -e "$dns_options" | rofi -normal-window -dmenu -p "DNS Menu")"

    case "$dns_chosen" in
    *"Set Cloudflare"*)
      alacritty -e sh -c "sudo chattr -i /etc/resolv.conf 2>/dev/null; sudo rm -f /etc/resolv.conf; echo 'nameserver 1.1.1.1' | sudo tee /etc/resolv.conf; echo 'nameserver 1.0.0.1' | sudo tee -a /etc/resolv.conf; sudo chattr +i /etc/resolv.conf; echo 'DNS locked to Cloudflare!'; sleep 2"
      ;;
    *"Set Google"*)
      alacritty -e sh -c "sudo chattr -i /etc/resolv.conf 2>/dev/null; sudo rm -f /etc/resolv.conf; echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf; echo 'nameserver 8.8.4.4' | sudo tee -a /etc/resolv.conf; sudo chattr +i /etc/resolv.conf; echo 'DNS locked to Google!'; sleep 2"
      ;;
    *"Reset to DHCP"*)
      alacritty -e sh -c "sudo chattr -i /etc/resolv.conf 2>/dev/null; sudo rm -f /etc/resolv.conf; sudo ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || sudo systemctl restart NetworkManager; echo 'DNS reset to System Defaults!'; sleep 2"
      ;;
    "" | *"Back"*)
      break
      ;;
    esac
  done
  exec "$0"
  ;;
*"Firewall"*)
  while true; do
    fw_options="  Edit Custom Config\n  Enable UFW\n  Disable UFW\n  Remove UFW\n  Back"
    fw_chosen="$(echo -e "$fw_options" | rofi -normal-window -dmenu -p "Firewall Menu")"

    case "$fw_chosen" in
    *"Edit Custom Config"*)
      alacritty -e sh -c "sudo nano /etc/default/ufw"
      ;;
    *"Enable UFW"*)
      if ! pacman -Q ufw &>/dev/null; then
        alacritty -e sh -c "sudo pacman -S --noconfirm ufw && sudo systemctl enable --now ufw && sudo ufw enable; echo 'UFW is active!'; sleep 2"
      else
        alacritty -e sh -c "sudo systemctl enable --now ufw && sudo ufw enable; echo 'UFW is active!'; sleep 2"
      fi
      ;;
    *"Disable UFW"*)
      alacritty -e sh -c "sudo ufw disable && sudo systemctl disable --now ufw; echo 'UFW Disabled!'; sleep 2"
      ;;
    *"Remove UFW"*)
      alacritty -e sh -c "sudo ufw disable; sudo systemctl disable --now ufw; sudo pacman -Rdd --noconfirm ufw; echo 'UFW Removed!'; sleep 2"
      ;;
    "" | *"Back"*)
      break
      ;;
    esac
  done
  exec "$0"
  ;;
*"Tools"*)
  while true; do
    tools_options="  System\n  Disk Space\n  App Manager\n  File Search\n  Speed Test\n  Web Search\n  Color Picker\n  EXIF\n  Media\n  Downloader\n  IP Locator\n  Back"
    tools_chosen="$(echo -e "$tools_options" | rofi -normal-window -dmenu -p "Tools Menu")"

    case "$tools_chosen" in
    *"System"*)
      while true; do
        sys_options="  Update System\n  Clean System\n  Back"
        sys_chosen="$(echo -e "$sys_options" | rofi -normal-window -dmenu -p "System Menu")"
        case "$sys_chosen" in
        *"Update System"*)
          alacritty -e sh -c "$HOME/.config/scripts/system_update.sh; echo ''; echo 'Press enter to close...'; read"
          ;;
        *"Clean System"*)
          alacritty -e sh -c "$HOME/.config/scripts/system_clean.sh; echo ''; echo 'Press enter to close...'; read"
          ;;
        "" | *"Back"*)
          break
          ;;
        esac
      done
      ;;
    *"Disk Space"*)
      alacritty -e sudo ncdu /
      ;;
    *"App Manager"*)
      while true; do
        app_options="  Install\n  Remove\n  Back"
        app_chosen="$(echo -e "$app_options" | rofi -normal-window -dmenu -p "App Manager")"
        case "$app_chosen" in
        *"Install"*)
          alacritty -e sh -c "pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S"
          ;;
        *"Remove"*)
          alacritty -e sh -c "pacman -Qq | fzf --multi --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rns"
          ;;
        "" | *"Back"*)
          break
          ;;
        esac
      done
      ;;
    *"File Search"*)
      while true; do
        search_options="  Find File\n  Find File Contents\n  Back"
        search_chosen="$(echo -e "$search_options" | rofi -normal-window -dmenu -p "File Search")"
        case "$search_chosen" in
        *"Find File"*)
          alacritty -e sh -c "file=\$(fd --type f | fzf --prompt='Select File to View: '); [ -n \"\$file\" ] && less \"\$file\""
          ;;
        *"Find File Contents"*)
          rgt=$(rofi -normal-window -dmenu -p "Search Term:")
          [ -n "$rgt" ] && alacritty -e sh -c "rg \"$rgt\" | less"
          ;;
        "" | *"Back"*)
          break
          ;;
        esac
      done
      ;;
    *"Speed Test"*)
      alacritty -e sh -c "speedtest-cli; echo ''; echo 'Press enter to close...'; read"
      ;;
    *"Web Search"*)
      sh -c "$HOME/.config/scripts/rofi-web.sh"
      ;;
    *"Color Picker"*)
      xcolor -s clipboard &
      dunstify "Color Picker" "Hex code copied to clipboard!"
      ;;
    *"EXIF"*)
      img=$(fd -e jpg -e png -e jpeg | rofi -normal-window -dmenu -i -p "Select Image:")
      if [ -n "$img" ]; then
        act_options="  View\n  Remove"
        act=$(echo -e "$act_options" | rofi -normal-window -dmenu -p "Action:")
        if [[ "$act" == *"View"* ]]; then
          alacritty -e sh -c "exiftool \"$img\"; echo ''; echo 'Press enter to close...'; read"
        elif [[ "$act" == *"Remove"* ]]; then
          exiftool -all= "$img"
          dunstify "EXIF removed" "$img"
        fi
      fi
      ;;
    *"Media"*)
      while true; do
        media_options="  Video Rescaler\n  Image Switcheroo\n  Back"
        media_chosen="$(echo -e "$media_options" | rofi -normal-window -dmenu -p "Media Menu")"
        case "$media_chosen" in
        *"Video Rescaler"*)
          vf=$(fd -e mp4 -e mkv -e webm -e avi | rofi -normal-window -dmenu -i -p "Select Video:")
          if [ -n "$vf" ]; then
            res_options="󰨣  3840x2160 (4K)\n󰨣  2560x1440 (2K)\n󰨣  1920x1080 (1080p)\n󰨣  1280x720 (720p)\n  Custom\n  Back"
            res_chosen="$(echo -e "$res_options" | rofi -normal-window -dmenu -p "Select Resolution:")"

            if [[ "$res_chosen" == *"Custom"* ]]; then
              res=$(rofi -normal-window -dmenu -p "Enter Resolution (e.g. 1080x1080):")
            elif [[ "$res_chosen" != *"Back"* ]] && [ -n "$res_chosen" ]; then
              res=$(echo "$res_chosen" | awk '{print $2}')
            fi

            if [ -n "$res" ] && [[ "$res_chosen" != *"Back"* ]]; then
              alacritty -e sh -c "ffmpeg -i \"$vf\" -vf scale=$res \"${vf%.*}_$res.mp4\"; echo 'Done!'; sleep 2"
            fi
          fi
          ;;
        *"Image Switcheroo"*)
          switcheroo
          ;;
        "" | *"Back"*)
          break
          ;;
        esac
      done
      ;;
    *"Downloader"*)
      sh -c "$HOME/.config/scripts/downloader.sh"
      ;;
    *"IP Locator"*)
      alacritty -e sh -c "python3 $HOME/.config/iploc/iploc.py; echo ''; echo 'Press enter to close...'; read"
      ;;
    "" | *"Back"*)
      break
      ;;
    esac
  done
  exec "$0"
  ;;
*"Configure DWM"*)
  while true; do
    dwm_options="  Configure DWM (config.h)\n  Configure Slock (config.h)\n  Configure Slstatus (config.h)\n  Configure Startup (.xprofile)\n  Compile DWM\n  Compile Slock\n  Compile Slstatus\n  Back"
    dwm_chosen="$(echo -e "$dwm_options" | rofi -normal-window -dmenu -p "DWM Menu")"

    case "$dwm_chosen" in
    *"Configure DWM"*)
      alacritty -e nano "$HOME/dwm/config.h"
      ;;
    *"Configure Slock"*)
      alacritty -e nano "$HOME/slock/config.h"
      ;;
    *"Configure Slstatus"*)
      alacritty -e nano "$HOME/slstatus/config.h"
      ;;
    *"Configure Startup"*)
      alacritty -e nano "$HOME/.xprofile"
      ;;
    *"Compile DWM"*)
      alacritty -e sh -c "cd $HOME/dwm && sudo make clean install && echo 'DWM Compiled Successfully!' && sleep 2"
      ;;
    *"Compile Slock"*)
      alacritty -e sh -c "cd $HOME/slock && sudo make clean install && echo 'Slock Compiled Successfully!' && sleep 2"
      ;;
    *"Compile Slstatus"*)
      alacritty -e sh -c "cd $HOME/slstatus && sudo make clean install && echo 'Slstatus Compiled Successfully!' && sleep 2"
      ;;
    "" | *"Back"*)
      break
      ;;
    esac
  done
  exec "$0"
  ;;
esac
