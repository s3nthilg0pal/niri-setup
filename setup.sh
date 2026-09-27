#!/bin/bash
set -euo pipefail

skip_install=false
dry_run=false
for argument in "$@"; do
  case "$argument" in
    --skip-install) skip_install=true ;;
    --dry-run) dry_run=true ;;
    -h|--help) echo 'Usage: ./setup.sh [--skip-install] [--dry-run]'; exit 0 ;;
    *) echo "Unknown option: $argument" >&2; exit 1 ;;
  esac
done
if (( EUID == 0 )); then
  echo 'Run this script as your desktop user, without sudo.' >&2
  exit 1
fi
if [[ -e /run/ostree-booted ]]; then
  echo 'This installer targets DNF-based Fedora, not Fedora Atomic desktops.' >&2
  exit 1
fi
. /etc/os-release
if [[ $ID != fedora ]]; then
  echo 'This port requires Fedora.' >&2
  exit 1
fi

source_dir=$(cd -- "$(dirname -- "$0")" && pwd)
config_home=${XDG_CONFIG_HOME:-$HOME/.config}
# Paths are embedded in shell commands inside KDL/JSON configuration.
if [[ $config_home =~ [^a-zA-Z0-9_./-] ]]; then
  echo 'The configuration path must contain only letters, digits, /, ., _, or -.' >&2
  exit 1
fi

if ! "$skip_install"; then
  packages=(
    niri alacritty brightnessctl cliphist dunst fuzzel lxpolkit pavucontrol
    swaybg swayidle swaylock waybar wlogout xwayland-satellite wl-clipboard
    playerctl python3-gobject udiskie ImageMagick wireplumber pipewire-pulseaudio
    xdg-desktop-portal-gnome xdg-desktop-portal-gtk NetworkManager-tui
    firefox nautilus google-noto-sans-mono-fonts google-noto-sans-cjk-fonts
    fontawesome-fonts-all
  )
  # Preserve an existing power-profiles-daemon installation.
  if ! rpm -q power-profiles-daemon >/dev/null 2>&1; then
    packages+=(tuned-ppd)
  fi
  if "$dry_run"; then
    printf 'Would run:'
    printf ' %q' sudo dnf install "${packages[@]}"
    printf '\n'
  else
    sudo dnf install "${packages[@]}"
  fi
fi
if "$dry_run"; then
  echo "Would stage configuration from $source_dir and run niri validate."
  for path in "$config_home/niri-setup" "$config_home/niri"; do
    if [[ -e $path || -L $path ]]; then
      echo "Would back up $path with a timestamped .backup-* suffix."
    else
      echo "No existing $path; rollback would restore its absence."
    fi
  done
  echo "Would install files in $config_home/niri-setup and link $config_home/niri."
  echo 'Would record rollback metadata. No files or packages have been changed.'
  echo 'This preview does not resolve packages or validate the generated configuration.'
  exit 0
fi
command -v niri >/dev/null || { echo 'Install niri before configuring this setup.' >&2; exit 1; }

mkdir -p "$config_home" "${XDG_STATE_HOME:-$HOME/.local/state}"
target="$config_home/niri-setup"
stage=$(mktemp -d "$config_home/.niri-setup.XXXXXX")
trap 'rm -rf -- "$stage"' EXIT
for directory in niri alacritty dunst fuzzel scripts waybar wallpapers wlogout; do
  cp -a "$source_dir/$directory" "$stage/"
done
python3 - "$stage" "$target" <<'PY'
from pathlib import Path
import sys
root, target = Path(sys.argv[1]), sys.argv[2]
for path in root.rglob('*'):
    if path.is_file() and (path.suffix in {'.sh', '.kdl', '.jsonc'} or path.name in {'config', 'layout'}):
        path.write_text(path.read_text().replace('$NIRICONF', target))
PY
niri validate --config "$stage/niri/config.kdl"
# Preserve both previous generated files and an existing niri configuration.
backup_suffix="backup-$(date +%Y%m%d-%H%M%S)-$$"
# Keep rollback metadata with each generation, including first installs.
python3 - "$stage" "$config_home" "$backup_suffix" <<'PYMETA'
import json
import os
from pathlib import Path
import sys
stage, config, suffix = sys.argv[1:]
manifest = {'version': 1, 'suffix': suffix,
            'existed': {name: os.path.lexists(Path(config) / name)
                        for name in ('niri-setup', 'niri')}}
(Path(stage) / '.rollback.json').write_text(json.dumps(manifest) + '\n')
PYMETA
for path in "$target" "$config_home/niri"; do
  if [[ -e $path || -L $path ]]; then
    mv -- "$path" "$path.$backup_suffix"
    echo "Backed up $path to $path.$backup_suffix"
  fi
done
mv -- "$stage" "$target"
ln -s -- "$target/niri" "$config_home/niri"
echo 'Setup complete. Log out and select niri in your login screen, or run niri-session from a TTY.'
