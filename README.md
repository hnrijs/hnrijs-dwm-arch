# hnrijs-dwm-arch
<img width="1915" height="1078" alt="scr_1787176011" src="https://github.com/user-attachments/assets/237b12dd-1b3a-4c25-a1cb-0d8175cc4796" />
<img width="1915" height="1082" alt="scr_1787176141" src="https://github.com/user-attachments/assets/9a5e153a-8211-43b8-81d6-1564f3c4afe5" />
<img width="1087" height="894" alt="image" src="https://github.com/user-attachments/assets/362218bc-ffd5-4fb8-852b-8f22cfd06695" />

## Installation

To install this i3wm setup automatically, clone the repository, make the installer executable, run it, and then reboot your system.

```bash
# 1. Clone the repository and enter the directory
git clone https://github.com/hnrijs/hnrijs-dwm-arch
cd hnrijs-dwm-arch

# 2. Make the install script executable and run it
chmod +x install.sh
./install.sh

# 3. Reboot your system to apply all changes and services
sudo reboot
```

# Keybindings

Here are the essential shortcuts for managing this desktop environment (`$mod` refers to the **Super / Windows** key):

### Applications & Utilities

| Keybinding | Action |
| :--- | :--- |
| `$mod + Return` | Open Alacritty Terminal |
| `$mod + Space` | Open Rofi App Launcher |
| `$mod + V` | Open Dmenu Clipboard History (Rofi) |
| `$mod + F` | Open Thunar File Manager |
| `$mod + B` | Open LibreWolf |
| `$mod + T` | Open Signal |
| `$mod + K` | Open Krita |
| `$mod + G` | Open Gimp |
| `$mod + C` | Open Gnome Calendar |
| `$mod + L` | Open Libre Office |
| `$mod + O` | Open OBS Studio |
| `$mod + R` | Open Davinci Resolve |
| `$mod + M` | Open Audacious |
| `$mod + P` | Open Proton VPN |
| `$mod + Shift + A` | Open Pavu Control |
| `$mod + Shift + S` | Take Screenshot (Select area to Clipboard) |
| `$mod + Shift + C` | Run System Maintenance & Cleanup Script |
| `$mod + Shift + U` | Run Full System Update (Pacman + AUR) |
| `$mod + Shift + N` | Open Network Manager (nmtui) in Terminal ||
| `$mod + Shift + L` | Lock Session |
| `$mod + Escape` | Rofi Power Menu |
| `$mod + Shift + P` | Toggle Power Profiles (S / B / P) |
| `$mod + Shift + Q` | Exit |
| `$mod + Shift + T` | Task Manager (Btop) |
| `$mod + Shift + E` | Screen Search (Select area to Clipboard) |

### Window Management & Layouts

| Keybinding | Action |
| :--- | :--- |
| `$mod + Q` | Kill Focused Window |
| `$mod + Left / Down / Up / Right` | Change Window Focus |
| `$mod + Shift + Left / Down / Up / Right` | Reisze Focused Window |
| `$mod + S` | Change Layout to Tile |
| `$mod + W` | Change Layout to Tabbed |
| `$mod + Z` | Toggle Floating / Tiling Mode |

