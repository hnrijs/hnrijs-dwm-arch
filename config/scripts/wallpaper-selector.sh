#!/bin/bash

# Set paths
wall_dir="${HOME}/Pictures/Wallpapers"
cache_dir="${HOME}/.cache/thumbnails/wal_selector"
lightdm_wall="/usr/share/pixmaps/main-wallpaper.png"

# Create directories if they do not exist
mkdir -p "${cache_dir}"
mkdir -p "${wall_dir}"

# Enable nullglob to avoid literal string processing if no files are found
shopt -s nullglob

# Generate thumbnails for all images in the directory
for imagen in "$wall_dir"/*.{jpg,jpeg,png,webp,JPG,JPEG,PNG,WEBP}; do
    if [ -f "$imagen" ]; then
        filename=$(basename "$imagen")
        
        # Create thumbnail if it doesn't exist
        if [ ! -f "${cache_dir}/${filename}" ] ; then
            magick "$imagen" -strip -thumbnail 500x500^ -gravity center -extent 500x500 "${cache_dir}/${filename}"
        fi
    fi
done

# Rofi theme overrides to create a nice, fixed Grid Layout with a scrollbar
rofi_override="window { width: 880px; border-radius: 8px; } listview { columns: 4; lines: 3; spacing: 15px; fixed-height: true; fixed-columns: true; scrollbar: true; } scrollbar { handle-width: 5px; handle-color: #FFFFFF; background-color: #151515; border: 0px; } element { orientation: vertical; padding: 15px; border-radius: 6px; } element-icon { size: 150px; horizontal-align: 0.5; } element-text { horizontal-align: 0.5; padding: 10px 0 0 0; }"

# Select a picture with rofi (Sorted logically with sort -V)
wall_selection=$(find "$wall_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort -V | while read -r A ; do
    echo -en "$A\0icon\x1f${cache_dir}/$A\n"
done | rofi -normal-window -dmenu -theme-str "${rofi_override}" -p "Wallpapers")

# Apply the wallpaper, update configs, and sync to LightDM
if [[ -n "$wall_selection" ]]; then
    selected_wp="${wall_dir}/${wall_selection}"
    
    # 1. Apply wallpaper instantly to current session
    xwallpaper --zoom "$selected_wp"
    
    # 2. Sync to LightDM login background
    if [ -w "$lightdm_wall" ]; then
        # File is writable (chmod 666 was applied), overwrite directly
        cat "$selected_wp" > "$lightdm_wall"
    else
        # File is protected, prompt for graphical sudo password using pkexec
        pkexec cp "$selected_wp" "$lightdm_wall"
    fi

    # 3. Dynamically update .xprofile
    if [ -f "$HOME/.xprofile" ]; then
        sed -i "s|xwallpaper --zoom .*|xwallpaper --zoom \"$selected_wp\" \&|g" "$HOME/.xprofile"
    fi

    # 4. Dynamically update .xinitrc (if xwallpaper exists there)
    if [ -f "$HOME/.xinitrc" ]; then
        if grep -q "xwallpaper" "$HOME/.xinitrc"; then
            sed -i "s|xwallpaper --zoom .*|xwallpaper --zoom \"$selected_wp\" \&|g" "$HOME/.xinitrc"
        fi
    fi
    
    # Send notification via Dunst
    dunstify -a "sysmenu_osd" -u low -h string:x-dunst-stack-tag:wallpaper "Wallpaper Changed" "Applied: $wall_selection"
fi

exit 0
