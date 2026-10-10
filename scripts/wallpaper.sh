#!/bin/bash

WALLPAPER_DIR="$HOME/dotfiles/wallpapers"
MONITOR="eDP-1"
HYPRPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"
CURRENT_WALLPAPER="$HOME/Pictures/.current_wallpaper"

# Check wallpaper directory
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper" "Wallpaper directory not found"
    exit 1
fi

# Check dependencies
for cmd in nsxiv wal hyprctl hyprpaper notify-send; do
    if ! command -v "$cmd" &>/dev/null; then
        notify-send "Wallpaper" "$cmd is not installed"
        exit 1
    fi
done

# Pick wallpaper
SELECTED_IMG=$(nsxiv -to "$WALLPAPER_DIR" | head -n 1)


# Exit if nothing was selected
if [ -z "$SELECTED_IMG" ]; then
    exit 0
fi

echo "Selected wallpaper: $SELECTED_IMG"

# Change wallpaper immediately
hyprctl hyprpaper wallpaper "$MONITOR,$SELECTED_IMG"

# Generate Pywal colors
wal -i "$SELECTED_IMG"


# Reload Dunst with new Pywal colors
pkill dunst
dunst -config "$HOME/.cache/wal/dunstrc" &

# Reload Waybar with new Pywal colors
pkill waybar
waybar &

cp ~/.cache/wal/spotifast.json ~/.config/spotifast/themes/pywal.json

if pgrep -f "[q]utebrowser" >/dev/null; then
    qutebrowser ':config-source' &>/dev/null &
fi

if pgrep -x thunar >/dev/null; then
    thunar -q
    sleep 0.3
    thunar & disown
fi

# Save selected wallpaper
echo "$SELECTED_IMG" > "$CURRENT_WALLPAPER"

# Make wallpaper persistent
cat > "$HYPRPAPER_CONFIG" <<EOF
splash = false

wallpaper {
    monitor = $MONITOR
    path = $SELECTED_IMG
}
EOF

# Notify
notify-send "Wallpaper changed" "$(basename "$SELECTED_IMG")"
