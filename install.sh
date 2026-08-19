#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting minimal automated DWM installation for Arch Linux..."

# 0. Ensure git is installed first
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    sudo pacman -Sy --noconfirm git
fi

# 1. Create standard home directories
echo "Creating user directories..."
mkdir -p "$HOME/Documents" "$HOME/Music" "$HOME/Downloads" "$HOME/Pictures/Wallpapers" "$HOME/Videos" "$HOME/.config"

# 2. Update system and install official pacman packages
echo "Installing official pacman packages..."
sudo pacman -S --needed --noconfirm \
    base-devel wget xorg-server xorg-xinit libx11 libxft libxinerama \
    thunar rofi imv btop playerctl alacritty zip unzip polkit-gnome \
    xclip maim ttf-jetbrains-mono-nerd noto-fonts-emoji ttf-nerd-fonts-symbols \
    gtk3 pavucontrol nwg-look mpv brightnessctl xsettingsd nano vim \
    xorg-xrandr power-profiles-daemon python-gobject arandr picom \
    lightdm lightdm-gtk-greeter materia-theme dunst xorg-xinput qalculate-gtk \
    curl jq xdg-utils libnotify xorg-xset librewolf imagemagick audacious \
    clipmenu xsel xdotool tumbler ttf-dejavu ttf-font-awesome noto-fonts \
    noto-fonts-cjk gvfs udisks2 thunar-volman switcheroo xwallpaper redshift \
    signal-desktop obs-studio

# 3. Check and install yay AUR helper
if ! command -v yay &> /dev/null; then
    echo "Installing yay AUR helper..."
    mkdir -p /tmp/yay-build
    git clone https://aur.archlinux.org/yay.git /tmp/yay-build/yay
    cd /tmp/yay-build/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay-build
fi

# 4. Install AUR packages
echo "Installing AUR packages..."
yay -S --noconfirm xautolock

# 5. Copy configuration files (.config directory)
echo "Copying config files to $HOME/.config/..."
if [ -d "$SCRIPT_DIR/config" ]; then
    cp -r "$SCRIPT_DIR/config/"* "$HOME/.config/"
else
    echo "Warning: No config folder found in repository!"
fi

# 6. Compile and install DWM
echo "Copying and compiling DWM in $HOME..."
if [ -d "$SCRIPT_DIR/dwm" ]; then
    rm -rf "$HOME/dwm"
    cp -r "$SCRIPT_DIR/dwm" "$HOME/"
    cd "$HOME/dwm"
    sudo make clean install
    sudo chown -R "$USER:$USER" "$HOME/dwm"
else
    echo "Error: dwm directory not found in repository!"
fi
cd "$SCRIPT_DIR"

# 7. Compile and install custom slock
echo "Copying and compiling slock in $HOME..."
if [ -d "$SCRIPT_DIR/slock" ]; then
    rm -rf "$HOME/slock"
    cp -r "$SCRIPT_DIR/slock" "$HOME/"
    cd "$HOME/slock"
    sudo make clean install
    sudo chmod u+s /usr/local/bin/slock
    sudo chown -R "$USER:$USER" "$HOME/slock"
else
    echo "Error: slock directory not found in repository!"
fi
cd "$SCRIPT_DIR"

# 8. Compile and install custom slstatus
echo "Copying and compiling slstatus in $HOME..."
if [ -d "$SCRIPT_DIR/slstatus" ]; then
    rm -rf "$HOME/slstatus"
    cp -r "$SCRIPT_DIR/slstatus" "$HOME/"
    cd "$HOME/slstatus"
    sudo make clean install
    sudo chown -R "$USER:$USER" "$HOME/slstatus"
else
    echo "Error: slstatus directory not found in repository!"
fi
cd "$SCRIPT_DIR"

# 9. Disable mouse acceleration globally
echo "Disabling mouse acceleration globally..."
sudo mkdir -p /etc/X11/xorg.conf.d
cat << 'EOF' | sudo tee /etc/X11/xorg.conf.d/50-mouse-acceleration.conf > /dev/null
Section "InputClass"
    Identifier "My Mouse"
    MatchIsPointer "yes"
    Option "AccelProfile" "flat"
    Option "AccelSpeed" "0"
EndSection
EOF

# 10. Copy wallpaper and setup LightDM greeter background
echo "Setting up wallpapers for user and LightDM..."
if [ -f "$SCRIPT_DIR/main.png" ]; then
    cp "$SCRIPT_DIR/main.png" "$HOME/Pictures/Wallpapers/main.png"
    sudo cp "$SCRIPT_DIR/main.png" /usr/share/pixmaps/main-wallpaper.png
fi

# If repository has a Wallpapers directory, copy all of them
if [ -d "$SCRIPT_DIR/Wallpapers" ]; then
    cp -r "$SCRIPT_DIR/Wallpapers/"* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
fi

# Allow non-root users to overwrite the LightDM wallpaper on demand
sudo touch /usr/share/pixmaps/main-wallpaper.png
sudo chmod 666 /usr/share/pixmaps/main-wallpaper.png

sudo bash -c 'cat << EOF > /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
background = /usr/share/pixmaps/main-wallpaper.png
theme-name = Materia-dark
icon-theme-name = Adwaita
font-name = JetBrainsMono Nerd Font 11
EOF'

# 11. Setup .xprofile with DPMS and xautolock
echo "Setting up X11 startup script (.xprofile)..."
cat << 'EOF' > "$HOME/.xprofile"
#!/bin/bash
export XCURSOR_SIZE=24
export XCURSOR_THEME="Adwaita"
export CM_LAUNCHER=rofi
export CM_SELECTIONS="clipboard"

if [ -f "$HOME/.Xresources" ]; then
    xrdb -merge "$HOME/.Xresources"
fi

xset +dpms
xset dpms 120 120 120
xautolock -time 1 -locker "slock" -killtime 4 -killer "systemctl suspend" &

xwallpaper --zoom "$HOME/Pictures/Wallpapers/main.png" &
slstatus &
dunst &
clipmenud &
picom &
$HOME/.config/scripts/screen.sh &
$HOME/.config/scripts/notifier.sh &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
EOF
chmod +x "$HOME/.xprofile"

# 12. Setup .xinitrc (Fallback if using startx)
echo "Setting up X11 startup script (.xinitrc)..."
cat << 'EOF' > "$HOME/.xinitrc"
#!/bin/sh
if [ -f "$HOME/.xprofile" ]; then
    . "$HOME/.xprofile"
fi
exec dbus-run-session dwm
EOF
chmod +x "$HOME/.xinitrc"

# 13. Create xsessions entry for LightDM
echo "Creating DWM desktop session for LightDM..."
sudo mkdir -p /usr/share/xsessions
cat << EOF | sudo tee /usr/share/xsessions/dwm.desktop > /dev/null
[Desktop Entry]
Name=DWM
Comment=Dynamic Window Manager
Exec=dbus-run-session dwm
Type=Application
X-LightDM-DesktopName=dwm
DesktopNames=dwm
EOF

# 14. Make custom scripts executable and generate toggle script
mkdir -p "$HOME/.config/scripts"

echo "Creating idle-toggle.sh script..."
cat << 'EOF' > "$HOME/.config/scripts/idle-toggle.sh"
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
EOF

if [ -d "$HOME/.config/scripts" ]; then
    chmod +x "$HOME/.config/scripts/"*
fi

# 15. Dynamically fix home paths in configs
echo "Fixing home paths in configurations for $USER..."
find "$HOME/.config" -type f -exec sed -i "s|/home/[^/]*|$HOME|g" {} + 2>/dev/null || true

# 16. Add dwm update alias to .bashrc
echo "Adding aliases to .bashrc..."
cat << 'EOF' >> "$HOME/.bashrc"
alias udwm='cd "$HOME/dwm" && sudo make clean install'
alias uslock='cd "$HOME/slock" && sudo make clean install'
alias uslstatus='cd "$HOME/slstatus" && sudo make clean install'
EOF

# 17. Fix Micro text editor default terminal
echo "Setting Alacritty as default terminal for external apps..."
sudo ln -sf /usr/bin/alacritty /usr/bin/xterm

# 18. Enable system services
echo "Enabling services..."
sudo systemctl enable --now power-profiles-daemon
sudo systemctl enable lightdm

echo "Installation complete! Rebooting system in 5 seconds..."
sleep 5
sudo reboot
