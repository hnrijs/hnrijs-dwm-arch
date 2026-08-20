#!/bin/bash

PLATFORMS="YouTube\nReddit\nGitHub\nGemini\nMaps\nTranslate\nWindy"

INPUT=$(echo -e "$PLATFORMS" | rofi -normal-window -dmenu -p "Web" -i)

[ -z "$INPUT" ] && exit 1

TARGET=$(echo "$INPUT" | awk '{print $1}')
QUERY=$(echo "$INPUT" | cut -d' ' -f2-)

ENCODED_QUERY=$(echo -n "$QUERY" | tr ' ' '+')

if [ "$TARGET" = "$INPUT" ]; then
    case "$TARGET" in
        "YouTube")   librewolf "https://youtube.com" & ;;
        "Reddit")    librewolf "https://reddit.com" & ;;
        "GitHub")    librewolf "https://github.com" & ;;
        "Gemini")    librewolf "https://gemini.google.com/" & ;;
        "Maps")      librewolf "https://google.com/maps" & ;;
        "Translate") librewolf "https://translate.google.com" & ;;
        "Windy") librewolf "https://windy.com" & ;;
    esac
else
    case "$TARGET" in
        "YouTube")   librewolf "https://youtube.com" & ;;
        "Reddit")    librewolf "https://reddit.com" & ;;
        "GitHub")    librewolf "https://github.com" & ;;
        "Gemini")    librewolf "https://gemini.google.com/" & ;;
        "Maps")      librewolf "https://google.com/maps" & ;;
        "Translate") librewolf "https://translate.google.com" & ;;
        "Windy") librewolf "https://windy.com" & ;;
    esac
fi
