#!/bin/bash
command -v awww >/dev/null && command -v awww-daemon >/dev/null || exit 0
awww query >/dev/null 2>&1 || awww-daemon &
for ((attempt=0; attempt<50; attempt++)); do
  if awww query >/dev/null 2>&1; then
    exec awww img "$NIRICONF/wallpapers/backdrop.jpg"
  fi
  sleep 0.1
done
exit 1
