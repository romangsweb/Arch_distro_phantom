#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  ROFI — Quick Actions / Cheatsheet                           ║
# ║  SUPER + / to launch                                         ║
# ╚══════════════════════════════════════════════════════════════╝

ACTIONS="  New Kitty terminal
  Kitty Dev session (F1)
  Kitty Monitor session (F2)
  ML session (F3)
  Server session (F4)
  Btop system monitor
  Audio visualizer (cava)
  File manager (Ranger)
  File manager (Thunar)
  LazyGit
  LazyDocker
  Docker stats
  K9s Kubernetes
  Neovim
  JupyterLab
  Screenshot (region)
  Record screen
  Clipboard history
  Color picker
  WiFi settings
  Bluetooth settings
  Volume mixer
  Power menu"

CHOSEN=$(echo -e "$ACTIONS" | rofi -dmenu \
    -theme ~/.config/rofi/phantom.rasi \
    -p "ACTION" \
    -mesg "Quick Actions" \
    -no-custom)

case "$CHOSEN" in
    *"New Kitty"*)          kitty ;;
    *"Dev session"*)        kitty --session ~/.config/kitty/sessions/dev.conf ;;
    *"Monitor session"*)    kitty --session ~/.config/kitty/sessions/monitor.conf ;;
    *"ML session"*)         kitty --session ~/.config/kitty/sessions/ml.conf ;;
    *"Server session"*)     kitty --session ~/.config/kitty/sessions/server.conf ;;
    *"Btop"*)               kitty -e btop ;;
    *"Audio visualizer"*)   kitty -e cava ;;
    *"Ranger"*)             kitty -e ranger ;;
    *"Thunar"*)             thunar ;;
    *"LazyGit"*)            kitty -e lazygit ;;
    *"LazyDocker"*)         kitty -e lazydocker ;;
    *"Docker stats"*)       kitty -e docker stats ;;
    *"K9s"*)                kitty -e k9s ;;
    *"Neovim"*)             kitty -e nvim ;;
    *"JupyterLab"*)         kitty -e jupyter lab ;;
    *"Screenshot"*)         grim -g "$(slurp)" - | swappy -f - ;;
    *"Record screen"*)      wf-recorder -g "$(slurp)" -f ~/Videos/rec-$(date +%Y%m%d_%H%M%S).mp4 ;;
    *"Clipboard"*)          cliphist list | rofi -dmenu -theme ~/.config/rofi/phantom.rasi | cliphist decode | wl-copy ;;
    *"Color picker"*)       hyprpicker -a ;;
    *"WiFi"*)               kitty -e nmtui ;;
    *"Bluetooth"*)          blueman-manager ;;
    *"Volume"*)             pavucontrol ;;
    *"Power"*)              ~/.config/rofi/scripts/powermenu.sh ;;
esac
