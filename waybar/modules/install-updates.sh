#!/bin/bash
sudo dnf upgrade --refresh
status=$?
if (( status == 0 )); then
  echo '[INFO] Updates completed.'
else
  echo "[ERROR] Update failed (exit $status)."
fi
read -n 1 -s -r -p 'Press any key to finish...'
exit "$status"
