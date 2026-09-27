#!/bin/bash
set -euo pipefail
wallpaper_dir="$HOME/Pictures/wallpapers"
mkdir -p "$wallpaper_dir"
for dep in fuzzel magick swaybg; do
  command -v "$dep" >/dev/null || { echo "Missing dependency: $dep" >&2; exit 1; }
done
image=$(find "$wallpaper_dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort | fuzzel --dmenu --prompt 'Wallpaper: ') || exit 0
[[ -f $image ]] || exit 0
# Use fixed filenames so the choice persists without editing KDL or shell commands.
magick "$image" "$NIRICONF/wallpapers/workspace.jpg"
magick "$image" -scale 10% -blur 0x2.5 -resize 1000% "$NIRICONF/wallpapers/backdrop.jpg"
pkill -x swaybg || true
nohup swaybg -i "$NIRICONF/wallpapers/workspace.jpg" -m fill -c '#010102' >/dev/null 2>&1 &
"$NIRICONF/scripts/start-backdrop.sh"
