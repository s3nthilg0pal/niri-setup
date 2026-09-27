#!/bin/bash
niri msg action do-screen-transition --delay-ms 300
locker="${XDG_DATA_HOME:-$HOME/.local/share}/niri-extras/bin/swaylock-effects"
effects=()
if [[ -x $locker ]]; then
  effects=(--clock --screenshots --indicator --effect-scale 0.4
           --effect-vignette 0.2:0.5 --effect-blur 4x2
           --datestr '%A, %b %d' --timestr '%k:%M')
else
  locker=swaylock
fi
exec "$locker" "${effects[@]}" \
  --color 0b0b0c \
  --daemonize \
  --ignore-empty-password \
  --font "Ubuntu Bold" \
  --indicator-radius 150 \
  --key-hl-color 61768ff2 \
  --ring-color 61768ff2 \
  --text-color ffffffe6 \
  --inside-clear-color 0b0b0cf2 \
  --ring-clear-color 61768ff2 \
  --text-clear-color ffffffe6 \
  --inside-ver-color 0b0b0cf2 \
  --ring-ver-color 61768ff2 \
  --text-ver-color ffffffe6 \
  --bs-hl-color 3c3836ff \
  --inside-wrong-color c30505ff \
  --ring-wrong-color c30505ff \
  --text-wrong-color ffffffff
