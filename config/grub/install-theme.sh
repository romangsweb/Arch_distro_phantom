#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  GRUB — Phantom Bootloader Theme Installer                    ║
# ║  Minimal dark theme with green/purple accents                  ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Run as root:
#   sudo bash config/grub/install-theme.sh

set -euo pipefail

THEME_DIR="/boot/grub/themes/phantom"
echo "Installing GRUB Phantom theme..."

sudo mkdir -p "$THEME_DIR"

# Theme definition
sudo tee "$THEME_DIR/theme.txt" > /dev/null << 'EOF'
# ── Phantom GRUB Theme ──────────────────────────────────────

# Desktop
desktop-color: "#0a0a0a"
terminal-font: "JetBrains Mono Regular 14"

# Title
title-text: "PHANTOM"
title-font: "JetBrains Mono Bold 24"
title-color: "#7EC8A0"

# Boot menu
+ boot_menu {
    left = 30%
    top = 35%
    width = 40%
    height = 40%
    item_font = "JetBrains Mono Regular 14"
    item_color = "#555555"
    selected_item_font = "JetBrains Mono Bold 14"
    selected_item_color = "#0a0a0a"
    selected_item_extcorner_factor = 0
    selected_item_pixmap_style = "select_*.png"
    item_height = 32
    item_padding = 8
    item_spacing = 4
    item_icon_space = 0
    icon_width = 0
    icon_height = 0
    scrollbar = false
}

# Countdown
+ label {
    left = 30%
    top = 80%
    width = 40%
    text = "Auto-boot in %d seconds"
    font = "JetBrains Mono Regular 12"
    color = "#555555"
    align = "center"
}

# System info
+ label {
    left = 30%
    top = 28%
    width = 40%
    text = "Arch Linux · MacBook Pro A1706"
    font = "JetBrains Mono Regular 11"
    color = "#333333"
    align = "center"
}
EOF

# Create a simple selection highlight image (1x1 green pixel, stretched)
# Using printf to create a minimal PPM image
sudo python3 -c "
import struct
# Create a simple 1x32 green bar PNG-like PPM
width, height = 800, 32
header = f'P6\n{width} {height}\n255\n'.encode()
# Green (#7EC8A0) = R:126 G:200 B:160
pixel = bytes([126, 200, 160])
data = header + pixel * (width * height)
with open('$THEME_DIR/select_c.ppm', 'wb') as f:
    f.write(data)
" 2>/dev/null || true

# Update GRUB config
if [[ -f /etc/default/grub ]]; then
    sudo sed -i 's|^#\?GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/phantom/theme.txt"|' /etc/default/grub
    sudo sed -i 's|^#\?GRUB_GFXMODE=.*|GRUB_GFXMODE=1920x1200,auto|' /etc/default/grub
    sudo sed -i 's|^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' /etc/default/grub
    
    # Add Plymouth support
    if ! grep -q "splash" /etc/default/grub; then
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
    fi
    
    echo "Regenerate GRUB: sudo grub-mkconfig -o /boot/grub/grub.cfg"
else
    echo "GRUB config not found. If using systemd-boot, skip this."
fi

echo "GRUB theme installed."
