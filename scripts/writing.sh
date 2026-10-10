#!/bin/sh

root="$HOME/Documents/Writing"

project=$(find "$root" -mindepth 1 -maxdepth 1 -type d -not -name '.*' -printf '%f\n' \
  | sort \
  | rofi -dmenu -i -p "Writing") || exit 0

dir="$root/$project"
[ -d "$dir" ] || exit 1

# Open in chapters/ if the project has one, otherwise in the project root
[ -d "$dir/chapters" ] && dir="$dir/chapters"

cd "$dir" || exit 1
exec kitty nvim -c "ZenMode"
