#!/bin/bash

# Helper function to send OSD notifications with a progress bar
notify_osd() {
    local title="$1"
    local value="$2"
    local icon="$3"
    
    # Ensure value is between 0 and 100 for the progress bar
    local clean_val="${value%%%*}"
    if [ "$clean_val" -gt 100 ]; then clean_val=100; fi
    if [ "$clean_val" -lt 0 ]; then clean_val=0; fi

    dunstify -a "sysmenu_osd" -u low -h string:x-dunst-stack-tag:osd -h int:value:"$clean_val" "$icon $title: $value"
}


options="Configure DWM\nConfigure System\nConfigure Appearance\nSystem Tools"

chosen="$(echo -e "$options" | rofi -dmenu -p "System Menu")"

case "$chosen" in
    "Configure DWM")
        while true; do
            dwm_options="Configure DWM (config.h)\nConfigure Slock (config.h)\nConfigure Slstatus (config.h)\nConfigure Startup (.xprofile)\nCompile DWM\nCompile Slock\nCompile Slstatus\nBack"
            dwm_chosen="$(echo -e "$dwm_options" | rofi -dmenu -p "DWM Menu")"
            
            case "$dwm_chosen" in
                "Configure DWM (config.h)")
                    alacritty -e nano "$HOME/dwm/config.h"
                    ;;
                "Configure Slock (config.h)")
                    alacritty -e nano "$HOME/slock/config.h"
                    ;;
                "Configure Slstatus (config.h)")
                    alacritty -e nano "$HOME/slstatus/config.h"
                    ;;
                "Configure Startup (.xprofile)")
                    alacritty -e nano "$HOME/.xprofile"
                    ;;
                "Compile DWM")
                    alacritty -e sh -c "cd $HOME/dwm && sudo make clean install && echo 'DWM Compiled Successfully!' && sleep 2"
                    ;;
                "Compile Slock")
                    alacritty -e sh -c "cd $HOME/slock && sudo make clean install && echo 'Slock Compiled Successfully!' && sleep 2"
                    ;;
                "Compile Slstatus")
                    alacritty -e sh -c "cd $HOME/slstatus && sudo make clean install && echo 'Slstatus Compiled Successfully!' && sleep 2"
                    ;;
                "Back"|*)
                    break
                    ;;
            esac
        done
        exec "$0"
        ;;
    "Configure System")
        while true; do
            sys_options="Configure Audio\nConfigure Network\nConfigure Bluetooth\nConfigure Monitors\nConfigure Keyboard\nConfigure Mouse\nConfigure Brightness\nConfigure Night Light\nConfigure DNS\nConfigure Firewall\nBack"
            sys_chosen="$(echo -e "$sys_options" | rofi -dmenu -p "System Settings")"
            
            case "$sys_chosen" in
                "Configure Audio")
                    while true; do
                        audio_options="Open Pavucontrol\nVolume Up (+5%)\nVolume Down (-5%)\nMute Toggle\nBack"
                        audio_chosen="$(echo -e "$audio_options" | rofi -dmenu -p "Audio Menu")"
                        
                        case "$audio_chosen" in
                            "Open Pavucontrol")
                                if ! pacman -Q pavucontrol &>/dev/null; then
                                    alacritty -e sh -c "sudo pacman -S --noconfirm pavucontrol && pavucontrol"
                                else
                                    pavucontrol &
                                fi
                                ;;
                            "Volume Up (+5%)")
                                pactl set-sink-volume @DEFAULT_SINK@ +5%
                                current_vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)
                                notify_osd "Volume" "${current_vol}%" ""
                                ;;
                            "Volume Down (-5%)")
                                pactl set-sink-volume @DEFAULT_SINK@ -5%
                                current_vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)
                                notify_osd "Volume" "${current_vol}%" ""
                                ;;
                            "Mute Toggle")
                                pactl set-sink-mute @DEFAULT_SINK@ toggle
                                is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes')
                                if [ "$is_muted" = "yes" ]; then
                                    dunstify -a "sysmenu_osd" -u low -h string:x-dunst-stack-tag:osd "󰖁 Volume: Muted"
                                else
                                     current_vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)
                                     notify_osd "Volume" "${current_vol}%" ""
                                fi
                                ;;
                            "Back"|*)
                                break
                                ;;
                        esac
                    done
                    ;;
                "Configure Network")
                    while true; do
                        net_options="Open NMTUI\nEnable Network\nDisable Network\nRemove Network\nBack"
                        net_chosen="$(echo -e "$net_options" | rofi -dmenu -p "Network Menu")"
                        
                        case "$net_chosen" in
                            "Open NMTUI")
                                if ! pacman -Q networkmanager &>/dev/null; then
                                    alacritty -e sh -c "sudo pacman -S --noconfirm networkmanager && sudo systemctl enable --now NetworkManager && nmtui"
                                else
                                    if ! systemctl is-active --quiet NetworkManager; then
                                        alacritty -e sh -c "sudo systemctl enable --now NetworkManager && nmtui"
                                    else
                                        alacritty -e nmtui
                                    fi
                                fi
                                ;;
                            "Enable Network")
                                if ! pacman -Q networkmanager &>/dev/null; then
                                    alacritty -e sh -c "sudo pacman -S --noconfirm networkmanager && sudo systemctl enable --now NetworkManager"
                                else
                                    alacritty -e sh -c "sudo systemctl enable --now NetworkManager"
                                fi
                                ;;
                            "Disable Network")
                                alacritty -e sh -c "sudo systemctl disable --now NetworkManager"
                                ;;
                            "Remove Network")
                                alacritty -e sh -c "sudo systemctl disable --now NetworkManager; sudo pacman -Rdd --noconfirm networkmanager"
                                ;;
                            "Back"|*)
                                break
                                ;;
                        esac
                    done
                    ;;
                "Configure Bluetooth")
                    while true; do
                        bt_options="Open Bluetui\nEnable Bluetooth\nDisable Bluetooth\nRemove Bluetooth\nBack"
                        bt_chosen="$(echo -e "$bt_options" | rofi -dmenu -p "Bluetooth Menu")"
                        
                        case "$bt_chosen" in
                            "Open Bluetui")
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
                            "Enable Bluetooth")
                                if ! pacman -Q bluez bluez-utils bluetui &>/dev/null; then
                                    alacritty -e sh -c "sudo pacman -S --noconfirm bluez bluez-utils bluetui && sudo systemctl enable --now bluetooth"
                                else
                                    alacritty -e sh -c "sudo systemctl enable --now bluetooth"
                                fi
                                ;;
                            "Disable Bluetooth")
                                alacritty -e sh -c "sudo systemctl disable --now bluetooth"
                                ;;
                            "Remove Bluetooth")
                                alacritty -e sh -c "sudo systemctl disable --now bluetooth; sudo pacman -Rdd --noconfirm bluez bluez-utils bluetui"
                                ;;
                            "Back"|*)
                                break
                                ;;
                        esac
                    done
                    ;;
                "Configure Monitors")
                    while true; do
                        mon_options="Open ARandR (GUI)\nList Monitors (CLI)\nBack"
                        mon_chosen="$(echo -e "$mon_options" | rofi -dmenu -p "Monitor Menu")"
                        
                        case "$mon_chosen" in
                            "Open ARandR (GUI)")
                                if ! pacman -Q arandr &>/dev/null; then
                                    alacritty -e sudo pacman -S --noconfirm arandr
                                fi
                                arandr &
                                ;;
                            "List Monitors (CLI)")
                                alacritty -e sh -c "xrandr; echo ''; echo 'Press enter to close'; read"
                                ;;
                            "Back"|*)
                                break
                                ;;
                        esac
                    done
                    ;;
                "Configure Keyboard")
                    while true; do
                        kbd_options="Set US Layout\nSet LV Layout\nCustom Localectl Status\nBack"
                        kbd_chosen="$(echo -e "$kbd_options" | rofi -dmenu -p "Keyboard Menu")"
                        
                        case "$kbd_chosen" in
                            "Set US Layout")
                                localectl set-x11-keymap us
                                ;;
                            "Set LV Layout")
                                localectl set-x11-keymap lv
                                ;;
                            "Custom Localectl Status")
                                alacritty -e sh -c "localectl status; echo ''; echo 'Press enter to close'; read"
                                ;;
                            "Back"|*)
                                break
                                ;;
                        esac
                    done
                    ;;
                "Configure Mouse")
                    while true; do
                        mouse_options="Enable Mouse Accel\nDisable Mouse Accel\nBack"
                        mouse_chosen="$(echo -e "$mouse_options" | rofi -dmenu -p "Mouse Menu")"
                        
                        xprofile_file="$HOME/.xprofile"
                        
                        case "$mouse_chosen" in
                            "Enable Mouse Accel")
                                xinput --set-prop $(xinput list | grep -i "mouse" | head -n 1 | grep -o 'id=[0-9]*' | cut -d= -f2) "libinput Accel Profile Enabled" 1, 0, 0 2>/dev/null
                                if grep -q "libinput Accel Profile Enabled" "$xprofile_file"; then
                                    sed -i 's/libinput Accel Profile Enabled.*0, 1, 0/libinput Accel Profile Enabled" 1, 0, 0/g' "$xprofile_file"
                                    sed -i 's/libinput Accel Profile Enabled.*1, 0, 0/libinput Accel Profile Enabled" 1, 0, 0/g' "$xprofile_file"
                                else
                                    echo 'xinput --set-prop $(xinput list | grep -i "mouse" | head -n 1 | grep -o '\''id=[0-9]*'\'' | cut -d= -f2) "libinput Accel Profile Enabled" 1, 0, 0 &' >> "$xprofile_file"
                                fi
                                ;;
                            "Disable Mouse Accel")
                                xinput --set-prop $(xinput list | grep -i "mouse" | head -n 1 | grep -o 'id=[0-9]*' | cut -d= -f2) "libinput Accel Profile Enabled" 0, 1, 0 2>/dev/null
                                if grep -q "libinput Accel Profile Enabled" "$xprofile_file"; then
                                    sed -i 's/libinput Accel Profile Enabled.*1, 0, 0/libinput Accel Profile Enabled" 0, 1, 0/g' "$xprofile_file"
                                    sed -i 's/libinput Accel Profile Enabled.*0, 1, 0/libinput Accel Profile Enabled" 0, 1, 0/g' "$xprofile_file"
                                else
                                    echo 'xinput --set-prop $(xinput list | grep -i "mouse" | head -n 1 | grep -o '\''id=[0-9]*'\'' | cut -d= -f2) "libinput Accel Profile Enabled" 0, 1, 0 &' >> "$xprofile_file"
                                fi
                                ;;
                            "Back"|*)
                                break
                                ;;
                        esac
                    done
                    ;;
                "Configure Brightness")
                    while true; do
                        bright_options="Brightness Up (+5%)\nBrightness Down (-5%)\nMax Brightness (100%)\nMin Brightness (10%)\nBack"
                        bright_chosen="$(echo -e "$bright_options" | rofi -dmenu -p "Brightness Menu")"
                        
                        case "$bright_chosen" in
                            "Brightness Up (+5%)")
                                brightnessctl set +5%
                                current_br=$(brightnessctl i | grep -Po '(?<=\()\d+(?=%\))')
                                notify_osd "Brightness" "${current_br}%" "󰃠"
                                ;;
                            "Brightness Down (-5%)")
                                brightnessctl set 5%-
                                current_br=$(brightnessctl i | grep -Po '(?<=\()\d+(?=%\))')
                                notify_osd "Brightness" "${current_br}%" "󰃝"
                                ;;
                            "Max Brightness (100%)")
                                brightnessctl set 100%
                                notify_osd "Brightness" "100%" "󰃠"
                                ;;
                            "Min Brightness (10%)")
                                brightnessctl set 10%
                                notify_osd "Brightness" "10%" "󰃞"
                                ;;
                            "Back"|*)
                                break
                                ;;
                        esac
                    done
                    ;;
                "Configure Night Light")
                    while true; do
                        nl_options="Toggle Night Light (4500K)\nReset to Daylight (6500K)\nCustom Temp (CLI)\nBack"
                        nl_chosen="$(echo -e "$nl_options" | rofi -dmenu -p "Night Light Menu")"
                        
                        case "$nl_chosen" in
                            "Toggle Night Light (4500K)")
                                if ! pacman -Q redshift &>/dev/null; then
                                    alacritty -e sh -c "sudo pacman -S --noconfirm redshift"
                                fi
                                pkill redshift
                                redshift -O 4500 &
                                dunstify -u low "Night Light" "Enabled (4500K)"
                                ;;
                            "Reset to Daylight (6500K)")
                                pkill redshift
                                redshift -x
                                dunstify -u low "Night Light" "Reset to Daylight (6500K)"
                                ;;
                            "Custom Temp (CLI)")
                                alacritty -e sh -c "echo 'Enter desired temperature (e.g., 4000): '; read temp; pkill redshift; redshift -O \$temp; echo 'Applied!'; sleep 2"
                                ;;
                            "Back"|*)
                                break
                                ;;
                        esac
                    done
                    ;;
                "Configure DNS")
                    while true; do
                        dns_options="Set Cloudflare (1.1.1.1)\nSet Google (8.8.8.8)\nReset to DHCP (Default)\nBack"
                        dns_chosen="$(echo -e "$dns_options" | rofi -dmenu -p "DNS Menu")"
                        
                        case "$dns_chosen" in
                            "Set Cloudflare (1.1.1.1)")
                                alacritty -e sh -c "sudo chattr -i /etc/resolv.conf 2>/dev/null; echo 'nameserver 1.1.1.1' | sudo tee /etc/resolv.conf; echo 'nameserver 1.0.0.1' | sudo tee -a /etc/resolv.conf; sudo chattr +i /etc/resolv.conf; echo 'DNS locked to Cloudflare!'; sleep 2"
                                ;;
                            "Set Google (8.8.8.8)")
                                alacritty -e sh -c "sudo chattr -i /etc/resolv.conf 2>/dev/null; echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf; echo 'nameserver 8.8.4.4' | sudo tee -a /etc/resolv.conf; sudo chattr +i /etc/resolv.conf; echo 'DNS locked to Google!'; sleep 2"
                                ;;
                            "Reset to DHCP (Default)")
                                alacritty -e sh -c "sudo chattr -i /etc/resolv.conf 2>/dev/null; sudo systemctl restart NetworkManager; echo 'DNS reset to NetworkManager DHCP defaults!'; sleep 2"
                                ;;
                            "Back"|*)
                                break
                                ;;
                        esac
                    done
                    ;;
                "Configure Firewall")
                    while true; do
                        fw_options="Edit Custom Config\nEnable UFW\nDisable UFW\nRemove UFW\nBack"
                        fw_chosen="$(echo -e "$fw_options" | rofi -dmenu -p "Firewall Menu")"
                        
                        case "$fw_chosen" in
                         "Edit Custom Config")
                                alacritty -e sh -c "sudo nano /etc/default/ufw"
                                ;;
                            "Enable UFW")
                                if ! pacman -Q ufw &>/dev/null; then
                                    alacritty -e sh -c "sudo pacman -S --noconfirm ufw && sudo systemctl enable --now ufw && sudo ufw enable; echo 'UFW is active!'; sleep 2"
                                else
                                    alacritty -e sh -c "sudo systemctl enable --now ufw && sudo ufw enable; echo 'UFW is active!'; sleep 2"
                                fi
                                ;;
                            "Disable UFW")
                                alacritty -e sh -c "sudo ufw disable && sudo systemctl disable --now ufw; echo 'UFW Disabled!'; sleep 2"
                                ;;
                            "Remove UFW")
                                alacritty -e sh -c "sudo ufw disable; sudo systemctl disable --now ufw; sudo pacman -Rdd --noconfirm ufw; echo 'UFW Removed!'; sleep 2"
                                ;;
                            "Back"|*)
                                break
                                ;;
                        esac
                    done
                    ;;
                "Back"|*)
                    break
                    ;;
            esac
        done
        exec "$0"
        ;;
    "Configure Appearance")
        while true; do
            app_options="Alacritty\nRofi\nDunst\nAppearance (GUI)\nChange Wallpaper\nBack"
            app_chosen="$(echo -e "$app_options" | rofi -dmenu -p "Appearance Menu")"
            
            case "$app_chosen" in
                "Alacritty")
                    alacritty -e nano "$HOME/.config/alacritty/alacritty.toml"
                    ;;
                "Rofi")
                    alacritty -e nano "$HOME/.config/rofi/config.rasi"
                    ;;
                "Dunst")
                    alacritty -e nano "$HOME/.config/dunst/dunstrc"
                    ;;
                "Appearance (GUI)")
                    nwg-look &
                    ;;
                "Change Wallpaper")
                    pics_dir="$HOME/Pictures"
                    old_wp_dir="$pics_dir/old_wp"
                    mkdir -p "$old_wp_dir"
                    
                    selected_wp="$(find "$pics_dir" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) ! -name "main.png" | awk -F'/' '{print $NF}' | rofi -dmenu -p "Select Wallpaper")"
                    
                    if [ -n "$selected_wp" ]; then
                        new_wp_path="$pics_dir/$selected_wp"
                        main_path="$pics_dir/main.png"
                        
                        if [ -f "$main_path" ]; then
                            timestamp=$(date +%s)
                            mv "$main_path" "$old_wp_dir/old_$timestamp.png"
                        fi
                        
                        cp "$new_wp_path" "$main_path"
                        xwallpaper --zoom "$main_path"
                    fi
                    ;;
                "Back"|*)
                    break
                    ;;
            esac
        done
        exec "$0"
        ;;
    "System Tools")
        while true; do
            tools_options="Take Screenshot\nSystem Clean\nSystem Update\nTask Manager\nReload Slstatus\nReload Dunst\nToggle Idle Mode\nChange Power Plan\nBack"
            tools_chosen="$(echo -e "$tools_options" | rofi -dmenu -p "System Tools")"
            
            case "$tools_chosen" in
                "Take Screenshot")
                    while true; do
                        shot_options="Select Area (Copy to Clipboard)\nSelect Area (Save to Pictures)\nFull Screen (Copy to Clipboard)\nFull Screen (Save to Pictures)\nBack"
                        shot_chosen="$(echo -e "$shot_options" | rofi -dmenu -p "Screenshot Menu")"
                        
                        case "$shot_chosen" in
                            "Select Area (Copy to Clipboard)")
                                maim -s | xclip -selection clipboard -t image/png
                                notify-send "Screenshot Copied" "Area copied to clipboard"
                                break 2
                                ;;
                            "Select Area (Save to Pictures)")
                                maim -s "$HOME/Pictures/Screenshot_$(date +%s).png"
                                notify-send "Screenshot Saved" "Area saved to ~/Pictures"
                                break 2
                                ;;
                            "Full Screen (Copy to Clipboard)")
                                maim | xclip -selection clipboard -t image/png
                                notify-send "Screenshot Copied" "Full screen copied to clipboard"
                                break 2
                                ;;
                            "Full Screen (Save to Pictures)")
                                maim "$HOME/Pictures/Screenshot_$(date +%s).png"
                                notify-send "Screenshot Saved" "Full screen saved to ~/Pictures"
                                break 2
                                ;;
                            "Back"|*)
                                break
                                ;;
                        esac
                    done
                    ;;
                "System Clean")
                    alacritty -e sh -c "$HOME/.config/scripts/system_clean.sh"
                    ;;
                "System Update")
                    alacritty -e sh -c "$HOME/.config/scripts/system_update.sh"
                    ;;
                "Task Manager")
                    if ! pacman -Q btop &>/dev/null; then
                        alacritty -e sh -c "sudo pacman -S --noconfirm btop && btop"
                    else
                        alacritty -e btop
                    fi
                    ;;
                "Reload Slstatus")
                    pkill slstatus
                    slstatus &
                    ;;
                "Reload Dunst")
                    pkill dunst
                    dunst &
                    ;;
                 "Toggle Idle Mode")
                    $HOME/.config/scripts/idle-toggle.sh &
                    break
                    ;;
                "Change Power Plan")
                    while true; do
                        power_options="Power Save\nBalanced\nPerformance\nBack"
                        power_chosen="$(echo -e "$power_options" | rofi -dmenu -p "Power Profile")"
                        
                        case "$power_chosen" in
                            "Power Save")
                                powerprofilesctl set power-saver
                                ;;
                            "Balanced")
                                powerprofilesctl set balanced
                                ;;
                            "Performance")
                                powerprofilesctl set performance
                                ;;
                            "Back"|*)
                                break
                                ;;
                        esac
                    done
                    ;;
                "Back"|*)
                    break
                    ;;
            esac
        done
        exec "$0"
        ;;
esac
