#!/bin/bash
if command -v pwvucontrol >/dev/null; then
  exec pwvucontrol
elif command -v flatpak >/dev/null && flatpak info com.saivert.pwvucontrol >/dev/null 2>&1; then
  exec flatpak run com.saivert.pwvucontrol
else
  exec pavucontrol
fi
