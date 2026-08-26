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

OPTIONS="MP3 Audio (yt-dlp)\nMP4 Video (yt-dlp)\nWeb Page HTML (monolith)\nGit Clone Repository\nStandard File Download (wget)\nChange Download Path (Current: $SAVE_DIR)"
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
if [[ "$CLIP" =~ ^https?:// ]]; then
    PREFILL="$CLIP"
else
    PREFILL=""
fi

URL=$(echo "$PREFILL" | rofi -normal-window -dmenu -p "URL / Link" -i)

if [ -z "$URL" ]; then
    exit 0
fi

case "$CHOICE" in
    "MP3 Audio (yt-dlp)")
        CMD="cd '$SAVE_DIR' && yt-dlp -x --audio-format mp3 --no-playlist '$URL'"
        ;;
    "MP4 Video (yt-dlp)")
        CMD="cd '$SAVE_DIR' && yt-dlp -S ext:mp4:m4a --no-playlist '$URL'"
        ;;
    "Web Page HTML (monolith)")
        FILENAME=$(echo "$URL" | sed -e 's/[^A-Za-z0-9]/_/g' | cut -c1-50)
        CMD="cd '$SAVE_DIR' && monolith '$URL' -o '${FILENAME}.html'"
        ;;
    "Git Clone Repository")
        CMD="cd '$SAVE_DIR' && git clone --recursive '$URL'"
        ;;
    "Standard File Download (wget)")
        CMD="cd '$SAVE_DIR' && wget --content-disposition --show-progress '$URL'"
        ;;
esac

EXEC_CMD="$CMD; echo ''; echo 'Finished! Press Enter to exit...'; read"

if command -v kitty &>/dev/null; then
    kitty sh -c "$EXEC_CMD"
elif command -v alacritty &>/dev/null; then
    alacritty -e sh -c "$EXEC_CMD"
elif command -v foot &>/dev/null; then
    foot sh -c "$EXEC_CMD"
elif command -v terminator &>/dev/null; then
    terminator -e "sh -c \"$EXEC_CMD\""
else
    xterm -e sh -c "$EXEC_CMD"
fi

notify-send "Downloader" "Task completed successfully."
