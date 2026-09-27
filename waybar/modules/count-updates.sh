#!/bin/bash
# DNF returns 100 when updates exist, 0 when current, and another code on error.
output=$(LC_ALL=C dnf -q check-upgrade 2>/dev/null)
status=$?
case $status in
  0) updates=0 ;;
  100) updates=$(awk '$1 ~ /\.[[:alnum:]_]+$/ && NF >= 3 {count++} END {print count+0}' <<< "$output") ;;
  *) printf '{"text":"?","alt":"error","tooltip":"Unable to check Fedora updates"}\n'; exit 0 ;;
esac
printf '{"text":"%s","alt":"%s","tooltip":"%s Fedora package updates"}\n' "$updates" "$updates" "$updates"
