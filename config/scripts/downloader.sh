#!/bin/bash

CONFIG_FILE="$HOME/.config/rofi/rofi-downloader.conf"
DEFAULT_DIR="$HOME/Downloads"

if [ -f "$CONFIG_FILE" ]; then
    SAVE_DIR=$(cat "$CONFIG_FILE")
else
    SAVE_DIR="$DEFAULT_DIR"
fi

if [ ! -d "$SAVE_DIR" ]; then
    SAVE_DIR="$DEFAULT_DIR"
fi

OPTIONS="MP3 Audio\nMP3 Playlist\nMP4 Video\nMP4 Playlist\nImage\nMagnet\nWeb Page HTML\nGit Clone Repository\nFile Download\nChange Download Path (Current: $SAVE_DIR)"
CHOICE=$(echo -e "$OPTIONS" | rofi -normal-window -dmenu -p "Action" -i)

if [ -z "$CHOICE" ]; then
    exit 0
fi

if [[ "$CHOICE" == *"Change Download Path"* ]]; then
    NEW_DIR=$(rofi -normal-window -dmenu -p "Enter Full Path" -i)
    if [ -n "$NEW_DIR" ]; then
        eval REAL_DIR="$NEW_DIR"
        mkdir -p "$REAL_DIR"
        echo "$REAL_DIR" > "$CONFIG_FILE"
        notify-send "Downloader" "Path updated to: $REAL_DIR"
    fi
    exit 0
fi

CLIP=$(xclip -selection clipboard -o 2>/dev/null || wl-paste 2>/dev/null)
if [[ "$CLIP" =~ ^(https?|magnet): ]]; then
    PREFILL="$CLIP"
else
    PREFILL=""
fi

URL=$(echo "$PREFILL" | rofi -normal-window -dmenu -p "URL / Link" -i)

if [ -z "$URL" ]; then
    exit 0
fi

case "$CHOICE" in
    "MP3 Audio")
        CMD="cd '$SAVE_DIR' && yt-dlp -x --audio-format mp3 --no-playlist '$URL'"
        ;;
    "MP3 Playlist")
        CMD="cd '$SAVE_DIR' && yt-dlp -x --audio-format mp3 --yes-playlist '$URL'"
        ;;
    "MP4 Video")
        CMD="cd '$SAVE_DIR' && yt-dlp -S ext:mp4:m4a --no-playlist '$URL'"
        ;;
    "MP4 Playlist")
        CMD="cd '$SAVE_DIR' && yt-dlp -S ext:mp4:m4a --yes-playlist '$URL'"
        ;;
    "Media / Images")
        CMD="cd '$SAVE_DIR' && yt-dlp '$URL'"
        ;;
    "Torrent / Magnet")
        CMD="cd '$SAVE_DIR' && aria2c --seed-time=0 '$URL'"
        ;;
    "Web Page HTML")
        FILENAME=$(echo "$URL" | sed -e 's/[^A-Za-z0-9]/_/g' | cut -c1-50)
        CMD="cd '$SAVE_DIR' && monolith '$URL' -o '${FILENAME}.html'"
        ;;
    "Git Clone Repository")
        CMD="cd '$SAVE_DIR' && git clone --recursive '$URL'"
        ;;
    "File Download")
        CMD="cd '$SAVE_DIR' && wget --content-disposition --show-progress '$URL'"
        ;;
esac

EXEC_CMD="$CMD; echo ''; echo 'Finished! Press Enter to exit.'; read"

alacritty -e sh -c "$EXEC_CMD"

notify-send "Download Complete"
