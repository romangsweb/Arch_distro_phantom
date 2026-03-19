#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  PHANTOM ISO BUILDER                                          ║
# ║  Crea una ISO personalizada de Arch Linux con todo incluido   ║
# ║                                                                ║
# ║  REQUISITOS: Ejecutar en una máquina Arch Linux existente     ║
# ║  (puede ser VM, container, o live USB)                         ║
# ║                                                                ║
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
${GREEN}███████╗██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗${NC}
${GREEN}██╔══██║██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║${NC}
${GREEN}███████║███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║${NC}
${DIM}██╔════╝██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║${NC}
${DIM}██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║${NC}
${DIM}╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝${NC}
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

# Start from the releng (installer) profile
cp -r /usr/share/archiso/configs/releng "$PROFILE_DIR"

log "Base profile copied"

# ── Add ALL packages to the ISO ─────────────────────────────────
info "Adding Phantom packages..."

cat >> "$PROFILE_DIR/packages.x86_64" << 'PACKAGES'

# ── PHANTOM RICE PACKAGES ────────────────────────────────
# MacBook A1706 hardware
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

# Display + UI
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

# Eww (from AUR — will be handled post-install)
# tiny-dfr-git (AUR)

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

log "Package list updated (150+ packages)"

# ── Inject auto-installer into the ISO ──────────────────────────
info "Embedding Phantom installer..."

# Create directory for our files inside the ISO
mkdir -p "$PROFILE_DIR/airootfs/root/phantom"

# Copy ALL config files
cp -r "$PROJECT_DIR/config" "$PROFILE_DIR/airootfs/root/phantom/"
cp -r "$PROJECT_DIR/wallpapers" "$PROFILE_DIR/airootfs/root/phantom/"
cp "$PROJECT_DIR/install.sh" "$PROFILE_DIR/airootfs/root/phantom/"
cp "$PROJECT_DIR/commands-reference.sh" "$PROFILE_DIR/airootfs/root/phantom/"
chmod +x "$PROFILE_DIR/airootfs/root/phantom/install.sh"

log "Phantom configs embedded in ISO"

# ── Create the automated installer ─────────────────────────────
info "Creating automated installer..."

cat > "$PROFILE_DIR/airootfs/root/phantom-install.sh" << 'AUTOINSTALL'
#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  PHANTOM — One-Shot Automated Arch Installer                  ║
# ║  Boot from USB → Answer questions → Walk away                 ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

GREEN='\033[38;2;126;200;160m'
PURPLE='\033[38;2;180;142;173m'
RED='\033[38;2;191;97;106m'
DIM='\033[90m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${GREEN}   ✓${NC} $1"; }
info() { echo -e "${PURPLE}   ▸${NC} $1"; }
warn() { echo -e "${RED}   ⚠${NC} $1"; }
ask()  { echo -ne "${GREEN}   ?${NC} $1: "; }

echo -e "
${GREEN}███████╗██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗${NC}
${GREEN}██╔══██║██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║${NC}
${GREEN}███████║███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║${NC}
${DIM}██╔════╝██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║${NC}
${DIM}██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║${NC}
${DIM}╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝${NC}
              ${PURPLE}Automated Arch Installer${NC}
"

echo -e "${DIM}────────────────────────────────────────────────${NC}"
echo -e "  Este instalador configurará TODO automáticamente."
echo -e "  Solo contesta unas preguntas y espera."
echo -e "${DIM}────────────────────────────────────────────────${NC}\n"

# ══════════════════════════════════════════════════════════════
# USER INPUT
# ══════════════════════════════════════════════════════════════
ask "Tu nombre completo"; read -r USER_FULLNAME
ask "Email"; read -r USER_EMAIL
ask "Username (login)"; read -r USERNAME
ask "Hostname [phantom]"; read -r HOSTNAME
HOSTNAME="${HOSTNAME:-phantom}"

echo ""
ask "Password para $USERNAME"
read -rs USER_PASS
echo ""
ask "Confirma password"
read -rs USER_PASS2
echo ""

if [[ "$USER_PASS" != "$USER_PASS2" ]]; then
    warn "Passwords no coinciden. Abortando."
    exit 1
fi

echo ""
ask "IP del servidor ML (o 'skip')"; read -r ML_SERVER_IP
if [[ "$ML_SERVER_IP" != "skip" ]]; then
    ask "Usuario SSH del ML server"; read -r ML_SERVER_USER
else
    ML_SERVER_USER="skip"
fi
ask "GitHub username"; read -r GITHUB_USER
ask "Latitud (ej: 19.43)"; read -r USER_LAT
ask "Longitud (ej: -99.13)"; read -r USER_LON

# ── Disk selection ──────────────────────────────────────────
echo -e "\n${PURPLE}Discos disponibles:${NC}"
lsblk -d -o NAME,SIZE,TYPE,MODEL | grep -E "disk"
echo ""
ask "Disco para instalar (ej: /dev/nvme0n1 o /dev/sda)"; read -r DISK

echo -e "\n${RED}   ⚠  ADVERTENCIA: Se borrará TODO en $DISK${NC}"
ask "¿Estás seguro? (escribe 'SI' en mayúsculas)"; read -r CONFIRM
if [[ "$CONFIRM" != "SI" ]]; then
    echo "Abortado."
    exit 1
fi

echo -e "\n${GREEN}━━━${NC} ${BOLD}Comenzando instalación...${NC} ${GREEN}━━━${NC}\n"

# ══════════════════════════════════════════════════════════════
# PHASE 1: Partitioning
# ══════════════════════════════════════════════════════════════
info "Particionando $DISK..."

# Wipe and create GPT
sgdisk --zap-all "$DISK"

# Create partitions:
#   1: 512M EFI
#   2: 8G  swap
#   3: rest root
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI" "$DISK"
sgdisk -n 2:0:+8G   -t 2:8200 -c 2:"swap" "$DISK"
sgdisk -n 3:0:0     -t 3:8300 -c 3:"root" "$DISK"

# Determine partition naming
if [[ "$DISK" == *"nvme"* ]]; then
    PART1="${DISK}p1"
    PART2="${DISK}p2"
    PART3="${DISK}p3"
else
    PART1="${DISK}1"
    PART2="${DISK}2"
    PART3="${DISK}3"
fi

# Format
mkfs.fat -F32 "$PART1"
mkswap "$PART2"
mkfs.ext4 -F "$PART3"

# Mount
mount "$PART3" /mnt
mount --mkdir "$PART1" /mnt/boot
swapon "$PART2"

log "Partitioned and mounted"

# ══════════════════════════════════════════════════════════════
# PHASE 2: Base install
# ══════════════════════════════════════════════════════════════
info "Instalando sistema base (esto toma ~10 min)..."

pacstrap -K /mnt base linux linux-firmware base-devel \
    intel-ucode networkmanager sudo vim git zsh

genfstab -U /mnt >> /mnt/etc/fstab

log "Base system installed"

# ══════════════════════════════════════════════════════════════
# PHASE 3: System configuration (inside chroot)
# ══════════════════════════════════════════════════════════════
info "Configurando sistema..."

# Copy Phantom files into the new system
cp -r /root/phantom /mnt/root/phantom

# Create the chroot script
cat > /mnt/root/chroot-setup.sh << CHROOT_EOF
#!/usr/bin/env bash
set -euo pipefail

# Timezone
ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
hwclock --systohc

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "es_MX.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << HOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain $HOSTNAME
HOSTS

# Root password (same as user)
echo "root:${USER_PASS}" | chpasswd

# Create user
useradd -m -G wheel,video,audio,input -s /bin/zsh "$USERNAME"
echo "${USERNAME}:${USER_PASS}" | chpasswd
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

# GRUB
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
# Add splash for Plymouth
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Enable services
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable docker
systemctl enable greetd

# Plymouth hook
if grep -q "^HOOKS=" /etc/mkinitcpio.conf; then
    sed -i 's/^HOOKS=(\(.*\)udev\(.*\))/HOOKS=(\1systemd plymouth\2)/' /etc/mkinitcpio.conf
fi

# Copy phantom installer to user home
cp -r /root/phantom /home/$USERNAME/Arch_distro_phantom
chown -R $USERNAME:$USERNAME /home/$USERNAME/Arch_distro_phantom

# Export variables for the Phantom installer
export USER_FULLNAME="$USER_FULLNAME"
export USER_EMAIL="$USER_EMAIL"
export HOSTNAME="$HOSTNAME"
export ML_SERVER_IP="$ML_SERVER_IP"
export ML_SERVER_USER="$ML_SERVER_USER"
export GITHUB_USER="$GITHUB_USER"
export USER_LAT="$USER_LAT"
export USER_LON="$USER_LON"

# Run the Phantom installer as user
# This installs all packages and deploys configs
su - $USERNAME -c "cd ~/Arch_distro_phantom && \
    export USER_FULLNAME='$USER_FULLNAME' && \
    export USER_EMAIL='$USER_EMAIL' && \
    export HOSTNAME='$HOSTNAME' && \
    export ML_SERVER_IP='$ML_SERVER_IP' && \
    export ML_SERVER_USER='$ML_SERVER_USER' && \
    export GITHUB_USER='$GITHUB_USER' && \
    export USER_LAT='$USER_LAT' && \
    export USER_LON='$USER_LON' && \
    export PHANTOM_NONINTERACTIVE=1 && \
    bash install.sh"

# Rebuild initramfs with Plymouth
mkinitcpio -P

echo "Chroot setup complete."
CHROOT_EOF

chmod +x /mnt/root/chroot-setup.sh
arch-chroot /mnt /root/chroot-setup.sh

log "System configured"

# ══════════════════════════════════════════════════════════════
# DONE
# ══════════════════════════════════════════════════════════════
echo -e "
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  ${GREEN}✓${NC} Instalación completa

  ${PURPLE}▸${NC} Usuario:   ${BOLD}$USERNAME${NC}
  ${PURPLE}▸${NC} Hostname:  ${BOLD}$HOSTNAME${NC}
  ${PURPLE}▸${NC} Disco:     ${BOLD}$DISK${NC}

  ${DIM}Siguiente: quita el USB y reinicia${NC}

    ${GREEN}reboot${NC}

  ${DIM}Verás: GRUB → Plymouth → greetd → Hyprland${NC}

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
"

umount -R /mnt 2>/dev/null || true
swapoff -a 2>/dev/null || true
AUTOINSTALL

chmod +x "$PROFILE_DIR/airootfs/root/phantom-install.sh"

log "Auto-installer embedded"

# ── Add phantom-install to the live ISO menu ────────────────────
# Create a welcome script that runs on login
mkdir -p "$PROFILE_DIR/airootfs/root"
cat > "$PROFILE_DIR/airootfs/root/.zlogin" << 'ZLOGIN'
echo ""
echo -e "\033[38;2;126;200;160m   PHANTOM INSTALLER\033[0m"
echo ""
echo "   Comandos disponibles:"
echo ""
echo -e "   \033[38;2;126;200;160mphantom-install\033[0m  — Instalar Arch + Phantom (automático)"
echo -e "   \033[38;2;180;142;173marchinstall\033[0m      — Instalador guiado de Arch (manual)"
echo -e "   \033[90mbash\033[0m             — Shell normal"
echo ""
ZLOGIN

# Create symlink for easy access
mkdir -p "$PROFILE_DIR/airootfs/usr/local/bin"
ln -sf /root/phantom-install.sh "$PROFILE_DIR/airootfs/usr/local/bin/phantom-install"

log "Live environment configured"

# ══════════════════════════════════════════════════════════════════
# STEP 3: Customize ISO metadata
# ══════════════════════════════════════════════════════════════════
step "3/5 — Customizing ISO metadata"

# Update profiledef
sed -i 's/iso_name="archlinux"/iso_name="phantom-archlinux"/' "$PROFILE_DIR/profiledef.sh"
sed -i 's/iso_label="ARCH_/iso_label="PHANTOM_/' "$PROFILE_DIR/profiledef.sh"
sed -i "s/iso_version=.*/iso_version=\"$(date +%Y.%m.%d)\"/" "$PROFILE_DIR/profiledef.sh"

log "ISO metadata customized"

# ══════════════════════════════════════════════════════════════════
# STEP 4: Build the ISO
# ══════════════════════════════════════════════════════════════════
step "4/5 — Building ISO (this takes 15-30 min)..."

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

  ${DIM}Para grabar en USB (desde Arch/Linux):${NC}

    ${GREEN}sudo dd if=$ISO_FILE of=/dev/sdX bs=4M status=progress${NC}

  ${DIM}Para grabar en USB (desde macOS):${NC}

    ${GREEN}diskutil unmountDisk /dev/diskN${NC}
    ${GREEN}sudo dd if=$ISO_FILE of=/dev/rdiskN bs=4m status=progress${NC}

  ${DIM}Boot: ⌥ (Option) al encender → EFI Boot → phantom-install${NC}

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
"

# Cleanup
rm -rf "$WORK_DIR"
log "Build directory cleaned"
