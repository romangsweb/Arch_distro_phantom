#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  ROFI — Power Menu (Phantom)                                 ║
# ║  SUPER + X to launch                                         ║
# ╚══════════════════════════════════════════════════════════════╝

OPTIONS="  Lock\n  Logout\n  Suspend\n⏻  Reboot\n⏼  Shutdown"

CHOSEN=$(echo -e "$OPTIONS" | rofi -dmenu \
    -theme ~/.config/rofi/phantom.rasi \
    -p "POWER" \
    -mesg "System Power Menu" \
    -lines 5 \
    -no-custom)

case "$CHOSEN" in
    *Lock*)     hyprlock ;;
    *Logout*)   hyprctl dispatch exit ;;
    *Suspend*)  systemctl suspend ;;
    *Reboot*)   systemctl reboot ;;
    *Shutdown*) systemctl poweroff ;;
esac
