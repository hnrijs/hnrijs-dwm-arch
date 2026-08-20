# hnrijs-dwm-arch
<img width="1919" height="1077" alt="scr_1787183978" src="https://github.com/user-attachments/assets/1801f25a-02f4-4092-a7fb-8076cda65be2" />
<img width="1914" height="1075" alt="scr_1787184115" src="https://github.com/user-attachments/assets/73211cbc-f4e0-44b8-a557-1515f5f942fb" />




## Actually functional Dwm.

## Rofi-Based Control Centers
* **System Menu:** Manage Audio, Wi-Fi, Bluetooth, Monitors, Keyboard layouts, Mouse acceleration, Brightness, Night Light, DNS, Firewall, and DWM source files directly from a GUI.
* **Media Player:** Visual media controller with automatic album art fetching.
* **Notification Manager:** Control Dunst notifications, toggle Do Not Disturb, and view notification history.

## Dynamic System Modes
* **Caffeine / Idle Mode:** Instantly toggle between auto-lock/sleep (via `xidlehook` locking at 1m, sleeping at 5m) and awake mode, synced with a dynamic status bar indicator.
* **Power Profiles:** Cycle between Power-Saver, Balanced, and Performance modes.
* **Do Not Disturb:** Quickly silence system-wide notifications with a dedicated keybind.

## Integrated Utilities
* **Advanced Screenshots & Lens:** Select areas to copy to the clipboard or perform a reverse image Screen Search (Google Lens equivalent).
* **Color Picker:** Grab any hex color from your screen directly to your clipboard.
* **Clipboard History:** Never lose copied text with integrated `clipmenu`.
* **Maintenance Scripts:** Built-in tools for system updates, cache cleaning, and dynamic wallpaper management.

## Dynamic Status Bar (`slstatus`)
* Custom dynamic icons reflecting current system states: DND status, current power profile, caffeine status, battery, volume, brightness, and date/time.


## Installation

To install this dwm setup automatically, clone the repository, make the installer executable, run it, and then reboot your system.

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

### Applications

| Keybinding | Action |
| :--- | :--- |
| `$mod + Return` | Open Alacritty Terminal |
| `$mod + F` | Open Thunar File Manager |
| `$mod + B` | Open LibreWolf |
| `$mod + T` | Open Signal |
| `$mod + K` | Open Krita |
| `$mod + G` | Open Gimp |
| `$mod + C` | Open Gnome Calendar |
| `$mod + L` | Open Libre Office |
| `$mod + O` | Open OBS Studio |
| `$mod + R` | Open Davinci Resolve |
| `$mod + U` | Open Audacious |
| `$mod + P` | Open Proton VPN |
| `$mod + Shift + A` | Open Pavu Control |
| `$mod + Shift + T` | Btop |


### App Launcher

| Keybinding | Action |
| :--- | :--- |
| `$mod + Space` | Open App Launcher |
| `$mod + Shift + Space` | Open System Menu |
| `$mod + Escape` | Power Menu |
| `$mod + N` | Open Notification Manager |
| `$mod + V` | Open Dmenu Clipboard History |
| `$mod + M` | Open Media Player |
| `$mod + I` | Open Quick Web |
| `$mod + Shift + W` | Open Wallpaper Selector |



### Utilities

| Keybinding | Action |
| :--- | :--- |
| `$mod + Shift + L` | Lock Session |
| `$mod + Shift + P` | Toggle Power Profiles (S / B / P) |
| `$mod + Shift + I` | Toggle Idle / Caffeine |
| `$mod + Shift + S` | Take Screenshot (Select area to Clipboard) |
| `$mod + Shift + X` | Take Screenshot (All Screens) |
| `$mod + Shift + E` | Screen Search (Select area to Clipboard) |
| `$mod + Shift + N` | Toggle Do Not Disturb |
| `$mod + Shift + H` | Color Picker |
| `$mod + Shift + C` | Run System Cleanup Script |
| `$mod + Shift + U` | Run Full System Update (Pacman + AUR) |
| `$mod + Shift + Q` | Exit |

### Window Management & Layouts

| Keybinding | Action |
| :--- | :--- |
| `$mod + [1-9]` | Switch To Workspace |
| `$mod + Shift + [1-9]` | Move Window To Workspace |
| `$mod + Q` | Kill Focused Window |
| `$mod + S` | Change Layout to Tile |
| `$mod + W` | Change Layout to Tabbed |
| `$mod + Shift + Z` |  Change Layout to Floating |
| `$mod + Z` | Toggle Floating  |
| `$mod + E` | Zoom / Swap Master Window |
| `$mod + A` | Window To Left Stack |
| `$mod + D` | Window To Right Stack |
| `$mod + Left / Down / Up / Right` | Change Window Focus |
| `$mod + Shift + Left / Down / Up / Right` | Resize Focused Window |
| `$mod + Shift + Q` | Exit |





