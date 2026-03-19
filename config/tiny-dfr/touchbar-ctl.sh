#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  TOUCH BAR HELPER — Maps Touch Bar actions to Hyprland       ║
# ║  Run as a service or via exec-once in hyprland.conf          ║
# ╚══════════════════════════════════════════════════════════════╝
#
# tiny-dfr sends XKB keycodes. Some special keys (LaunchA, etc.)
# need to be mapped to actual Hyprland actions via this script
# and hyprland keybindings.
#
# The Touch Bar "Search" button sends XF86LaunchA.
# We map it in hyprland.conf:
#   bind = , XF86LaunchA, exec, rofi -show drun -theme ~/.config/rofi/phantom.rasi
#
# This script provides additional Touch Bar utilities:

# ── Toggle Touch Bar Layer ──────────────────────────────────────
# Manually switch between media and function keys
toggle_layer() {
    # tiny-dfr handles Fn key natively, but you can also
    # use xdotool/wtype to send Fn keypress programmatically
    echo "Layer toggle handled by Fn key on Touch Bar"
}

# ── Touch Bar Brightness Override ───────────────────────────────
set_touchbar_brightness() {
    local level="${1:-180}"
    # tiny-dfr config sets ActiveBrightness, but you can
    # modify at runtime by editing config and restarting service
    sudo sed -i "s/ActiveBrightness = .*/ActiveBrightness = $level/" /etc/tiny-dfr/config.toml
    sudo systemctl restart tiny-dfr.service
    echo "Touch Bar brightness set to $level"
}

# ── Quick System Status (for scripts/notifications) ────────────
system_status() {
    local cpu=$(awk '{print int($1*100/'"$(nproc)"')}' /proc/loadavg)
    local mem=$(free -m | awk '/^Mem:/{printf "%.0f", $3/$2*100}')
    local bat=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "?")
    local temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{printf "%.0f", $1/1000}')

    echo "CPU:${cpu}% MEM:${mem}% BAT:${bat}% TEMP:${temp}°C"
}

# ── Usage ───────────────────────────────────────────────────────
case "${1:-status}" in
    toggle)     toggle_layer ;;
    brightness) set_touchbar_brightness "$2" ;;
    status)     system_status ;;
    *)          echo "Usage: touchbar-ctl {toggle|brightness <0-255>|status}" ;;
esac
