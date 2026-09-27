#!/bin/bash
# Install the font used by Waybar and Fuzzel from the upstream Nerd Fonts release.
set -euo pipefail
fonts=("${@:-UbuntuMono}")
for font in "${fonts[@]}"; do
  case "$font" in UbuntuMono|JetBrainsMono|Ubuntu) ;; *) echo "Unsupported font: $font" >&2; exit 1 ;; esac
done
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
for font in "${fonts[@]}"; do
font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/niri-setup/$font"
curl --fail --location --retry 2 \
  "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/$font.zip" \
  --output "$stage/$font.zip"
python3 - "$stage/$font.zip" "$font_dir" <<'PY'
from pathlib import Path
import sys
import zipfile
with zipfile.ZipFile(sys.argv[1]) as archive:
    fonts = [entry for entry in archive.infolist() if entry.filename.endswith('.ttf')]
    if not fonts:
        raise SystemExit('No fonts found in download')
    target = Path(sys.argv[2])
    target.mkdir(parents=True, exist_ok=True)
    for entry in archive.infolist():
        name = Path(entry.filename).name
        if not entry.is_dir() and (name.endswith('.ttf') or 'LICENSE' in name.upper()):
            (target / name).write_bytes(archive.read(entry))
PY
fc-cache -f "$font_dir"
done
echo 'Fonts installed. Restart Waybar (Super+W twice) to refresh icons.'
