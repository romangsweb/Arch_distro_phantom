#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  ROFI — Quick Launcher (All-in-One)                          ║
# ║  SUPER + Space                                                ║
# ╚══════════════════════════════════════════════════════════════╝
# Combines: apps, calculator, web search, SSH, file browser

MODES="drun,run,window,ssh,filebrowser,calc"

rofi -show drun \
    -modi "$MODES" \
    -theme ~/.config/rofi/phantom.rasi \
    -show-icons \
    -calc-command "echo '{result}' | wl-copy" \
    -display-drun " Apps" \
    -display-run " Run" \
    -display-window " Win" \
    -display-ssh "󰣀 SSH" \
    -display-filebrowser " Files" \
    -display-calc "󰃬 Calc"
