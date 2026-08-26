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


^G Help           ^O Write Out      ^F Where Is       ^K Cut            ^T Execute        ^C Location       M-U Undo          M-A Set Mark      M-] To Bracket    M-B Previous      ◂ Back            ^◂ Prev Word      ^A Home
^X Exit           ^R Read File      ^\ Replace        ^U Paste          ^J Justify        ^
