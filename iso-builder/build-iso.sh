#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  PHANTOM ISO BUILDER                                          ║
# ║  Crea una ISO personalizada de Arch Linux con todo incluido   ║
# ║                                                                ║
# ║  REQUISITOS: Ejecutar en Arch Linux (VM, container, live USB) ║
# ║  USO:  sudo ./build-iso.sh                                    ║
# ║  OUTPUT: out/phantom-archlinux-YYYY.MM.DD-x86_64.iso          ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

GREEN='\033[38;2;126;200;160m'
PURPLE='\033[38;2;180;142;173m'
DIM='\033[90m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${GREEN}   ✓${NC} $1"; }
info() { echo -e "${PURPLE}   ▸${NC} $1"; }
step() { echo -e "\n${GREEN}━━━${NC} ${BOLD}$1${NC} ${GREEN}━━━${NC}"; }

# ── Must be root ────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo ./build-iso.sh"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
WORK_DIR="/tmp/phantom-iso-build"
PROFILE_DIR="$WORK_DIR/profile"
OUT_DIR="$SCRIPT_DIR/out"

echo -e "
${GREEN} ██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗${NC}
${GREEN} ██╔══██║██║  ██║██╔══██╗████╗  ██║╚══██╔══╝${NC}
${GREEN} ███████║███████║███████║██╔██╗ ██║   ██║   ${NC}
${DIM} ██╔════╝██╔══██║██╔══██║██║╚██╗██║   ██║   ${NC}
${DIM} ██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ${NC}
${DIM} ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ${NC}
              ${PURPLE}ISO BUILDER${NC}
"

# ══════════════════════════════════════════════════════════════════
# STEP 1: Install archiso
# ══════════════════════════════════════════════════════════════════
step "1/5 — Installing archiso"

pacman -S --needed --noconfirm archiso
log "archiso installed"

# ══════════════════════════════════════════════════════════════════
# STEP 2: Copy base profile and customize
# ══════════════════════════════════════════════════════════════════
step "2/5 — Creating custom profile"

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

cp -r /usr/share/archiso/configs/releng "$PROFILE_DIR"
log "Base profile copied"

# ── Remove conflicting packages from the base profile ───────────
# NOTE: The base releng profile already includes broadcom-wl (pre-compiled)
# which is needed for WiFi during the live USB install on MacBooks.
# broadcom-wl-dkms will be installed on the TARGET system by install.sh
# (they conflict, so we can only have one at a time).

# ── Add Phantom packages to the ISO ─────────────────────────────
info "Adding Phantom packages..."

cat >> "$PROFILE_DIR/packages.x86_64" << 'PACKAGES'

# ── PHANTOM RICE ─────────────────────────────────────
# MacBook A1706 hardware (broadcom-wl already in base profile)
libinput
mesa
intel-media-driver
iwd
linux-headers
dkms
acpi
acpid

# Hyprland + Wayland
hyprland
xdg-desktop-portal-hyprland
xdg-desktop-portal-gtk
xdg-utils
qt5-wayland
qt6-wayland
polkit-gnome

# UI
waybar
mako
rofi-wayland
hyprpaper
hyprlock
hypridle
kitty
wl-clipboard
grim
slurp
swappy
wf-recorder
cliphist
brightnessctl
gammastep
playerctl
pavucontrol
nm-connection-editor

# Terminal tools
zsh
starship
bat
eza
fd
ripgrep
fzf
btop
fastfetch
htop
ranger
tmux
zellij
lazygit
jq
yq
tree
dust
duf
procs
sd
choose
hyperfine

# Development
neovim
git
git-delta
python
python-pip
go
rust
nodejs
npm
docker
docker-compose
kubectl

# Files + Media
thunar
gvfs
mpv

# Apps
firefox
libreoffice-fresh
gimp
zathura
transmission-gtk
keepassxc
obs-studio
gnome-disk-utility
gnome-calculator

# System
greetd
nftables
fail2ban
reflector
networkmanager
bluez
bluez-utils
blueman
pipewire
pipewire-alsa
pipewire-pulse
wireplumber
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
papirus-icon-theme
gnome-themes-extra
syncthing
timeshift
PACKAGES

log "Package list updated"

# ── Embed Phantom files into the ISO ────────────────────────────
info "Embedding Phantom files..."

mkdir -p "$PROFILE_DIR/airootfs/root/phantom"
mkdir -p "$PROFILE_DIR/airootfs/usr/local/bin"

# Copy ALL project config files
cp -r "$PROJECT_DIR/config" "$PROFILE_DIR/airootfs/root/phantom/"
cp -r "$PROJECT_DIR/wallpapers" "$PROFILE_DIR/airootfs/root/phantom/"
cp "$PROJECT_DIR/install.sh" "$PROFILE_DIR/airootfs/root/phantom/"
cp "$PROJECT_DIR/commands-reference.sh" "$PROFILE_DIR/airootfs/root/phantom/"

# Copy the standalone installer script
cp "$SCRIPT_DIR/phantom-install.sh" "$PROFILE_DIR/airootfs/root/phantom-install.sh"

# Create symlink for easy access
ln -sf /root/phantom-install.sh "$PROFILE_DIR/airootfs/usr/local/bin/phantom-install"

log "Phantom files embedded in ISO"

# ── Welcome message on login ────────────────────────────────────
cat > "$PROFILE_DIR/airootfs/root/.zlogin" << 'ZLOGIN'
clear
echo ""
echo -e "\033[38;2;126;200;160m   PHANTOM ARCH INSTALLER\033[0m"
echo ""
echo "   Escribe uno de estos comandos:"
echo ""
echo -e "   \033[38;2;126;200;160mphantom-install\033[0m  — Instalar TODO automático"
echo -e "   \033[90marchinstall\033[0m      — Instalador oficial de Arch"
echo ""
ZLOGIN

log "Welcome message configured"

# ══════════════════════════════════════════════════════════════════
# STEP 3: Customize ISO metadata + permissions
# ══════════════════════════════════════════════════════════════════
step "3/5 — Customizing ISO metadata"

sed -i 's/iso_name="archlinux"/iso_name="phantom-archlinux"/' "$PROFILE_DIR/profiledef.sh"
sed -i 's/iso_label="ARCH_/iso_label="PHANTOM_/' "$PROFILE_DIR/profiledef.sh"
sed -i "s/iso_version=.*/iso_version=\"$(date +%Y.%m.%d)\"/" "$PROFILE_DIR/profiledef.sh"

# Set executable permissions for our scripts in the ISO
cat >> "$PROFILE_DIR/profiledef.sh" << 'PERMS'
file_permissions+=(["/root/phantom-install.sh"]="0:0:755")
file_permissions+=(["/root/phantom/install.sh"]="0:0:755")
PERMS

log "ISO metadata and permissions set"

# ══════════════════════════════════════════════════════════════════
# STEP 4: Build the ISO
# ══════════════════════════════════════════════════════════════════
step "4/5 — Building ISO (15-30 min)..."

mkdir -p "$OUT_DIR"
mkarchiso -v -w "$WORK_DIR/work" -o "$OUT_DIR" "$PROFILE_DIR"

log "ISO built"

# ══════════════════════════════════════════════════════════════════
# STEP 5: Summary
# ══════════════════════════════════════════════════════════════════
step "5/5 — Done"

ISO_FILE=$(ls -t "$OUT_DIR"/*.iso 2>/dev/null | head -1)
ISO_SIZE=$(du -h "$ISO_FILE" | awk '{print $1}')

echo -e "
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  ${GREEN}✓${NC} ISO lista: ${BOLD}$ISO_FILE${NC}
  ${PURPLE}▸${NC} Tamaño: ${BOLD}$ISO_SIZE${NC}

  ${DIM}Grabar en USB (Linux):${NC}
    ${GREEN}sudo dd if=$ISO_FILE of=/dev/sdX bs=4M status=progress${NC}

  ${DIM}Grabar en USB (macOS):${NC}
    ${GREEN}sudo dd if=$ISO_FILE of=/dev/rdiskN bs=4m status=progress${NC}

  ${DIM}Boot: ⌥ (Option) al encender → EFI Boot${NC}
  ${DIM}Luego escribe: phantom-install${NC}

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
"

# Cleanup
rm -rf "$WORK_DIR"
log "Build directory cleaned"
