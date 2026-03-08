#!/bin/bash

START_DIR="$HOME/Pictures/Wallpapers"

# Get monitor list (Wayland/Hyprland/Qtile etc. usually expose via xrandr or hyprctl)
MONITORS=$(xrandr --query | grep " connected" | cut -d" " -f1)

# Convert monitors into Zenity list arguments
LIST_ARGS=()
for m in $MONITORS; do
    LIST_ARGS+=("$m")
done

DISPLAY=$(zenity --list \
    --title="Select Display" \
    --column="Monitor" \
    "${LIST_ARGS[@]}" \
    --height=300 \
    --width=300 2>/dev/null)

# User cancelled
[ -z "$DISPLAY" ] && echo "null" && exit

FILE=$(zenity --file-selection \
    --title="Select Wallpaper for $DISPLAY" \
    --filename="$START_DIR/" \
    --file-filter="Images/Videos | *.png *.jpg *.jpeg *.webp *.bmp *.svg *.mp4 *.mkv *.webm *.mov *.avi *.m4v" \
    2>/dev/null)

[ -z "$FILE" ] && echo "null" && exit

# Output format: monitor|wallpaper
echo "$DISPLAY|file://$FILE"