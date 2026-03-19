#!/usr/bin/env bash
# Keyboard layout indicator for Waybar
LAYOUT=$(hyprctl devices -j 2>/dev/null | jq -r '.keyboards[0].active_keymap' 2>/dev/null | head -c 2 | tr '[:lower:]' '[:upper:]')
echo "{\"text\": \"  ${LAYOUT:-US}\", \"tooltip\": \"Keyboard layout\"}"
