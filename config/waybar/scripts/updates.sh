#!/usr/bin/env bash
# System updates available for Waybar
UPDATES=$(checkupdates 2>/dev/null | wc -l)
AUR_UPDATES=$(paru -Qua 2>/dev/null | wc -l)
TOTAL=$((UPDATES + AUR_UPDATES))
if [[ "$TOTAL" -gt 0 ]]; then
    echo "{\"text\": \"  $TOTAL\", \"tooltip\": \"Pacman: $UPDATES\nAUR: $AUR_UPDATES\", \"class\": \"updates\"}"
else
    echo "{\"text\": \"\", \"tooltip\": \"System up to date\", \"class\": \"none\"}"
fi
