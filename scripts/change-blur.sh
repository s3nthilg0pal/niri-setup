#!/bin/bash
set -euo pipefail
if (( $# > 1 )); then
  echo 'Usage: change-blur.sh [off|low|medium|high]' >&2
  exit 1
fi
choice=${1:-}
if [[ -z $choice ]]; then
  choice=$(printf '%s\n' Off Low Medium High | fuzzel --dmenu --prompt 'Background blur: ') || exit 0
fi
case "${choice,,}" in
  off) enabled=false; passes=3; offset=3.0 ;;
  low) enabled=true; passes=2; offset=2.0 ;;
  medium) enabled=true; passes=3; offset=3.0 ;;
  high) enabled=true; passes=4; offset=4.0 ;;
  *) echo 'Choose off, low, medium, or high.' >&2; exit 1 ;;
esac
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/niri"
[[ -f "$config_dir/blur.kdl" ]] || { echo 'Blur controls are not installed.' >&2; exit 1; }
stage=$(mktemp "$config_dir/.blur.XXXXXX")
trap 'rm -f -- "$stage"' EXIT
cat > "$stage" <<KDL
// Managed by change-blur.sh. Requires niri 26.04 or newer.
// Xray blurs the wallpaper; use xray false below for the contents behind a window.
blur {
$(if [[ $enabled == false ]]; then echo '    off'; fi)
    passes $passes
    offset $offset
    noise 0.02
    saturation 1.0
}
window-rule {
    match app-id="^Alacritty$"
    background-effect {
        blur $enabled
        xray $enabled
    }
}
layer-rule {
    match namespace="^waybar$"
    background-effect {
        blur $enabled
        xray $enabled
    }
}
layer-rule {
    match namespace="^launcher$"
    geometry-corner-radius 10
    background-effect {
        blur $enabled
        xray $enabled
    }
}
KDL
niri validate --config "$stage"
mv -- "$stage" "$config_dir/blur.kdl"
printf 'Background blur: %s\n' "${choice,,}"
