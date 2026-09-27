#!/bin/bash
set -euo pipefail
mode=fill
if [[ -f "$NIRICONF/wallpapers/mode" ]]; then
  read -r mode < "$NIRICONF/wallpapers/mode"
fi
case "$mode" in stretch|fill|fit|center|tile) ;; *) mode=fill ;; esac
exec swaybg -i "$NIRICONF/wallpapers/workspace.jpg" -m "$mode" -c '#010102'
