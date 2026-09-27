#!/bin/bash
set -euo pipefail
wallpaper_dir="$HOME/Pictures/wallpapers"
export GUM_CHOOSE_HEADER_FOREGROUND='#d8dadd'
export GUM_CHOOSE_SELECTED_FOREGROUND='#758A9B'
export GUM_CHOOSE_CURSOR_FOREGROUND='#758A9B'
mkdir -p "$wallpaper_dir"
for dep in magick swaybg; do
  command -v "$dep" >/dev/null || { echo "Missing dependency: $dep" >&2; exit 1; }
done
choose() {
  if command -v gum >/dev/null; then
    gum choose --header "$1"
  else
    fuzzel --dmenu --prompt "$1 "
  fi
}
images=$(find "$wallpaper_dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort)
if [[ -z $images ]]; then
  echo "Place wallpapers in $wallpaper_dir first."
  read -r -n 1 -p 'Press any key to close...'
  exit 0
fi
image=$(printf '%s\n' "$images" | choose 'Choose your wallpaper:') || exit 0
[[ -f $image ]] || exit 0
mode=$(printf '%s\n' stretch fill fit center tile | choose 'Choose wallpaper mode:') || exit 0
case "$mode" in stretch|fill|fit|center|tile) ;; *) exit 0 ;; esac
# Fixed filenames keep choices persistent without embedding filenames into shell code.
magick "$image" "$NIRICONF/wallpapers/workspace.jpg"
magick "$image" -scale 10% -blur 0x2.5 -resize 1000% "$NIRICONF/wallpapers/backdrop.jpg"
printf '%s\n' "$mode" > "$NIRICONF/wallpapers/mode"
pkill -x swaybg || true
nohup "$NIRICONF/scripts/start-wallpaper.sh" >/dev/null 2>&1 &
"$NIRICONF/scripts/start-backdrop.sh"
