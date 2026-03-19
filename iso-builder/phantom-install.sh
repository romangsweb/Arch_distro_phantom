#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  PHANTOM — One-Shot Automated Arch Installer                  ║
# ║  Boot from USB → Answer questions → Walk away                 ║
# ║                                                                ║
# ║  This script runs from the LIVE USB environment.               ║
# ║  It partitions, installs base Arch, chroots, and deploys       ║
# ║  the Phantom rice automatically.                               ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Colors ──────────────────────────────────────────────────────
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
die()  { warn "$1"; echo -e "\n${RED}   Instalación abortada.${NC}\n"; exit 1; }

# ── Trap errors ─────────────────────────────────────────────────
trap 'warn "Error en línea $LINENO. Comando: $BASH_COMMAND"' ERR

# ══════════════════════════════════════════════════════════════════
# SCREEN 1: Welcome + User Info
# ══════════════════════════════════════════════════════════════════
clear
echo -e "
${GREEN} ██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗${NC}
${GREEN} ██╔══██║██║  ██║██╔══██╗████╗  ██║╚══██╔══╝${NC}
${GREEN} ███████║███████║███████║██╔██╗ ██║   ██║   ${NC}
${DIM} ██╔════╝██╔══██║██╔══██║██║╚██╗██║   ██║   ${NC}
${DIM} ██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ${NC}
${DIM} ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ${NC}
            ${PURPLE}Arch Linux Installer${NC}
"
echo -e "${DIM}─────────────────────────────────────────${NC}"
echo -e "  Contesta las preguntas y espera."
echo -e "  Todo se instala automáticamente."
echo -e "${DIM}─────────────────────────────────────────${NC}"
echo ""

ask "Tu nombre completo"; read -r USER_FULLNAME
[[ -z "$USER_FULLNAME" ]] && USER_FULLNAME="Phantom User"

ask "Email"; read -r USER_EMAIL
[[ -z "$USER_EMAIL" ]] && USER_EMAIL="user@phantom.arch"

ask "Username para login (minúsculas)"; read -r USERNAME
[[ -z "$USERNAME" ]] && USERNAME="phantom"
# Sanitize username
USERNAME=$(echo "$USERNAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_-')

ask "Hostname [phantom]"; read -r P_HOSTNAME
[[ -z "$P_HOSTNAME" ]] && P_HOSTNAME="phantom"

echo ""
while true; do
    ask "Password para $USERNAME"
    read -rs USER_PASS
    echo ""
    ask "Confirma password"
    read -rs USER_PASS2
    echo ""
    if [[ "$USER_PASS" == "$USER_PASS2" ]] && [[ -n "$USER_PASS" ]]; then
        log "Password confirmado"
        break
    fi
    warn "No coinciden o están vacíos. Intenta de nuevo."
    echo ""
done

echo ""
ask "IP servidor ML (Enter para skip)"; read -r ML_SERVER_IP
[[ -z "$ML_SERVER_IP" ]] && ML_SERVER_IP="skip"

ML_SERVER_USER="skip"
if [[ "$ML_SERVER_IP" != "skip" ]]; then
    ask "Usuario SSH del ML server"; read -r ML_SERVER_USER
    [[ -z "$ML_SERVER_USER" ]] && ML_SERVER_USER="$USERNAME"
fi

ask "GitHub username (Enter para skip)"; read -r GITHUB_USER
[[ -z "$GITHUB_USER" ]] && GITHUB_USER="skip"

ask "Latitud [19.4]"; read -r USER_LAT
[[ -z "$USER_LAT" ]] && USER_LAT="19.4"

ask "Longitud [-99.1]"; read -r USER_LON
[[ -z "$USER_LON" ]] && USER_LON="-99.1"

# ══════════════════════════════════════════════════════════════════
# SCREEN 2: Network check
# ══════════════════════════════════════════════════════════════════
clear
echo -e "\n${PURPLE}━━━ Paso 1: Conexión a Internet ━━━${NC}\n"

if ping -c 1 -W 3 archlinux.org &>/dev/null; then
    log "Conectado a Internet"
else
    warn "Sin conexión a Internet"
    info "Conectando WiFi..."
    echo ""

    # List available WiFi networks
    if command -v iwctl &>/dev/null; then
        # Get the WiFi device name
        WIFI_DEV=$(iwctl device list 2>/dev/null | grep station | awk '{print $2}' | head -1)
        if [[ -n "$WIFI_DEV" ]]; then
            info "Dispositivo WiFi: $WIFI_DEV"
            iwctl station "$WIFI_DEV" scan 2>/dev/null
            sleep 2
            echo -e "\n${PURPLE}   Redes disponibles:${NC}"
            iwctl station "$WIFI_DEV" get-networks 2>/dev/null | head -15
            echo ""
            ask "Nombre de tu red WiFi"; read -r WIFI_SSID
            ask "Password de WiFi"; read -rs WIFI_PASS
            echo ""

            iwctl --passphrase "$WIFI_PASS" station "$WIFI_DEV" connect "$WIFI_SSID" 2>/dev/null
            sleep 3

            if ping -c 1 -W 3 archlinux.org &>/dev/null; then
                log "Conectado a $WIFI_SSID"
            else
                die "No se pudo conectar al WiFi. Verifica SSID/password."
            fi
        else
            die "No se encontró dispositivo WiFi. Conecta ethernet."
        fi
    else
        die "iwctl no disponible. Conecta un cable ethernet."
    fi
fi

# ══════════════════════════════════════════════════════════════════
# SCREEN 3: Disk selection
# ══════════════════════════════════════════════════════════════════
clear
echo -e "\n${PURPLE}━━━ Paso 2: Seleccionar disco ━━━${NC}\n"

echo -e "   ${DIM}Discos detectados:${NC}\n"

# Show disks with numbers for easy selection
DISKS=()
i=1
while IFS= read -r line; do
    name=$(echo "$line" | awk '{print $1}')
    size=$(echo "$line" | awk '{print $2}')
    model=$(echo "$line" | awk '{$1=$2=$3=""; print $0}' | sed 's/^ *//')
    DISKS+=("/dev/$name")
    echo -e "   ${GREEN}[$i]${NC}  /dev/$name  ${BOLD}$size${NC}  $model"
    ((i++))
done < <(lsblk -d -n -o NAME,SIZE,TYPE,MODEL | grep -E "disk")

echo ""
if [[ ${#DISKS[@]} -eq 0 ]]; then
    die "No se detectaron discos."
fi

ask "Número del disco (1-${#DISKS[@]})"; read -r DISK_NUM

# Validate selection
if ! [[ "$DISK_NUM" =~ ^[0-9]+$ ]] || (( DISK_NUM < 1 || DISK_NUM > ${#DISKS[@]} )); then
    die "Selección inválida: $DISK_NUM"
fi

DISK="${DISKS[$((DISK_NUM-1))]}"
DISK_SIZE=$(lsblk -d -n -o SIZE "$DISK" 2>/dev/null)

echo ""
echo -e "   ${RED}╔════════════════════════════════════════╗${NC}"
echo -e "   ${RED}║  ⚠  SE BORRARÁ TODO EN:               ║${NC}"
echo -e "   ${RED}║     $DISK ($DISK_SIZE)                  ${NC}"
echo -e "   ${RED}╚════════════════════════════════════════╝${NC}"
echo ""
ask "Escribe SI en mayúsculas para continuar"; read -r CONFIRM

if [[ "$CONFIRM" != "SI" ]]; then
    echo -e "\n   Abortado por el usuario.\n"
    exit 0
fi

# ══════════════════════════════════════════════════════════════════
# PHASE 1: Partitioning
# ══════════════════════════════════════════════════════════════════
clear
echo -e "\n${PURPLE}━━━ Paso 3: Particionando disco ━━━${NC}\n"

info "Limpiando $DISK..."
wipefs --all --force "$DISK" 2>/dev/null || true
sgdisk --zap-all "$DISK" 2>/dev/null || true
sleep 1

info "Creando particiones..."

# 1: 512M EFI  |  2: 8G swap  |  3: rest root
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI"  "$DISK" || die "Error creando partición EFI"
sgdisk -n 2:0:+8G   -t 2:8200 -c 2:"swap" "$DISK" || die "Error creando partición SWAP"
sgdisk -n 3:0:0     -t 3:8300 -c 3:"root" "$DISK" || die "Error creando partición ROOT"

# Refresh kernel partition table
partprobe "$DISK" 2>/dev/null || true
sleep 2

# Determine partition naming (nvme uses 'p' separator)
if [[ "$DISK" == *"nvme"* ]] || [[ "$DISK" == *"mmcblk"* ]]; then
    PART1="${DISK}p1"
    PART2="${DISK}p2"
    PART3="${DISK}p3"
else
    PART1="${DISK}1"
    PART2="${DISK}2"
    PART3="${DISK}3"
fi

# Verify partitions exist
for part in "$PART1" "$PART2" "$PART3"; do
    if [[ ! -b "$part" ]]; then
        die "Partición $part no encontrada. Algo falló al particionar."
    fi
done

log "Particiones creadas: EFI=$PART1 SWAP=$PART2 ROOT=$PART3"

info "Formateando..."
mkfs.fat -F32 "$PART1"  || die "Error formateando EFI"
mkswap "$PART2"          || die "Error formateando SWAP"
mkfs.ext4 -F "$PART3"   || die "Error formateando ROOT"
log "Formateado OK"

info "Montando..."
mount "$PART3" /mnt                || die "Error montando ROOT"
mkdir -p /mnt/boot
mount "$PART1" /mnt/boot           || die "Error montando EFI"
swapon "$PART2"                    || die "Error activando SWAP"
log "Disco montado en /mnt"

# ══════════════════════════════════════════════════════════════════
# PHASE 2: Base system install
# ══════════════════════════════════════════════════════════════════
echo ""
echo -e "${PURPLE}━━━ Paso 4: Instalando sistema base ━━━${NC}\n"
info "Esto toma ~5-10 minutos dependiendo de tu internet..."

pacstrap -K /mnt base linux linux-firmware base-devel \
    intel-ucode networkmanager sudo vim git zsh \
    || die "Error en pacstrap. Revisa tu conexión a internet."

genfstab -U /mnt >> /mnt/etc/fstab
log "Sistema base instalado"

# ══════════════════════════════════════════════════════════════════
# PHASE 3: Copy Phantom files into the new system
# ══════════════════════════════════════════════════════════════════
echo ""
echo -e "${PURPLE}━━━ Paso 5: Copiando Phantom configs ━━━${NC}\n"

if [[ -d /root/phantom ]]; then
    cp -r /root/phantom "/mnt/root/phantom"
    log "Configs copiadas"
else
    warn "Directorio /root/phantom no encontrado en la ISO"
    warn "Las configs se instalarán manualmente después"
fi

# ══════════════════════════════════════════════════════════════════
# PHASE 4: Chroot configuration
# ══════════════════════════════════════════════════════════════════
echo ""
echo -e "${PURPLE}━━━ Paso 6: Configurando sistema ━━━${NC}\n"

# Write the chroot script as a separate file
# Using single-quoted heredoc where we DON'T want expansion,
# and injecting variables via environment instead.
cat > /mnt/root/chroot-setup.sh << 'CHROOT_SCRIPT'
#!/usr/bin/env bash
# ── Chroot configuration script ──
# Variables are passed via environment

echo "[1/9] Timezone..."
ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
hwclock --systohc 2>/dev/null || true

echo "[2/9] Locale..."
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#es_MX.UTF-8/es_MX.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "[3/9] Hostname: $CHROOT_HOSTNAME..."
echo "$CHROOT_HOSTNAME" > /etc/hostname
cat > /etc/hosts << HOSTS_EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${CHROOT_HOSTNAME}.localdomain $CHROOT_HOSTNAME
HOSTS_EOF

echo "[4/9] Users..."
echo "root:${CHROOT_PASS}" | chpasswd
useradd -m -G wheel,video,audio,input,docker -s /bin/zsh "$CHROOT_USER"
echo "${CHROOT_USER}:${CHROOT_PASS}" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "[5/9] GRUB bootloader..."
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable 2>/dev/null || \
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "[6/9] Enabling services..."
systemctl enable NetworkManager
systemctl enable bluetooth 2>/dev/null || true
systemctl enable docker 2>/dev/null || true

echo "[7/9] Deploying Phantom configs..."
if [[ -d /root/phantom ]]; then
    TARGET_HOME="/home/$CHROOT_USER"
    cp -r /root/phantom "$TARGET_HOME/Arch_distro_phantom"
    chown -R "$CHROOT_USER:$CHROOT_USER" "$TARGET_HOME/Arch_distro_phantom"

    # Deploy Phantom configs to user's home
    CONFIG_SRC="$TARGET_HOME/Arch_distro_phantom/config"
    if [[ -d "$CONFIG_SRC" ]]; then
        mkdir -p "$TARGET_HOME/.config"

        # Copy each config directory
        for dir in hypr kitty waybar rofi eww mako starship fastfetch btop ranger cava zellij nvim; do
            [[ -d "$CONFIG_SRC/$dir" ]] && cp -r "$CONFIG_SRC/$dir" "$TARGET_HOME/.config/$dir"
        done

        # Special locations
        [[ -f "$CONFIG_SRC/zsh/.zshrc" ]]       && cp "$CONFIG_SRC/zsh/.zshrc" "$TARGET_HOME/.zshrc"
        [[ -f "$CONFIG_SRC/git/.gitconfig" ]]   && cp "$CONFIG_SRC/git/.gitconfig" "$TARGET_HOME/.gitconfig"
        [[ -f "$CONFIG_SRC/ssh/config" ]]       && { mkdir -p "$TARGET_HOME/.ssh"; cp "$CONFIG_SRC/ssh/config" "$TARGET_HOME/.ssh/config"; chmod 700 "$TARGET_HOME/.ssh"; }
        [[ -f "$CONFIG_SRC/tmux/tmux.conf" ]]   && cp "$CONFIG_SRC/tmux/tmux.conf" "$TARGET_HOME/.tmux.conf"

        # Wallpapers
        WALL_SRC="$TARGET_HOME/Arch_distro_phantom/wallpapers"
        [[ -d "$WALL_SRC" ]] && { mkdir -p "$TARGET_HOME/.config/wallpapers"; cp -r "$WALL_SRC/"* "$TARGET_HOME/.config/wallpapers/"; }

        # Fix ownership
        chown -R "$CHROOT_USER:$CHROOT_USER" "$TARGET_HOME"

        echo "    Configs deployed to $TARGET_HOME/.config/"
    fi
fi

echo "[8/9] Personalizing git & configs..."
# Substitute placeholders in gitconfig
if [[ -f "/home/$CHROOT_USER/.gitconfig" ]]; then
    sed -i "s/YOUR_NAME/$CHROOT_FULLNAME/g" "/home/$CHROOT_USER/.gitconfig" 2>/dev/null || true
    sed -i "s/YOUR_EMAIL/$CHROOT_EMAIL/g" "/home/$CHROOT_USER/.gitconfig" 2>/dev/null || true
fi

# Substitute in SSH config
if [[ -f "/home/$CHROOT_USER/.ssh/config" ]]; then
    sed -i "s/ML_SERVER_IP/$CHROOT_ML_IP/g" "/home/$CHROOT_USER/.ssh/config" 2>/dev/null || true
    sed -i "s/ML_SERVER_USER/$CHROOT_ML_USER/g" "/home/$CHROOT_USER/.ssh/config" 2>/dev/null || true
fi

# Gammastep location
if [[ -f "/home/$CHROOT_USER/.config/gammastep/config.ini" ]]; then
    sed -i "s/^lat=.*/lat=$CHROOT_LAT/" "/home/$CHROOT_USER/.config/gammastep/config.ini" 2>/dev/null || true
    sed -i "s/^lng=.*/lng=$CHROOT_LON/" "/home/$CHROOT_USER/.config/gammastep/config.ini" 2>/dev/null || true
fi

echo "[9/9] Rebuilding initramfs..."
mkinitcpio -P

echo ""
echo "Chroot configuration complete."
CHROOT_SCRIPT

chmod +x /mnt/root/chroot-setup.sh

# Pass variables into chroot via environment
arch-chroot /mnt /usr/bin/env \
    CHROOT_USER="$USERNAME" \
    CHROOT_PASS="$USER_PASS" \
    CHROOT_HOSTNAME="$P_HOSTNAME" \
    CHROOT_FULLNAME="$USER_FULLNAME" \
    CHROOT_EMAIL="$USER_EMAIL" \
    CHROOT_ML_IP="$ML_SERVER_IP" \
    CHROOT_ML_USER="$ML_SERVER_USER" \
    CHROOT_GITHUB="$GITHUB_USER" \
    CHROOT_LAT="$USER_LAT" \
    CHROOT_LON="$USER_LON" \
    /bin/bash /root/chroot-setup.sh \
    || die "Error durante la configuración chroot"

log "Sistema configurado"

# ══════════════════════════════════════════════════════════════════
# DONE
# ══════════════════════════════════════════════════════════════════
clear
echo -e "
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  ${GREEN}✓${NC} ${BOLD}Instalación completa${NC}

  ${PURPLE}▸${NC} Usuario:   ${BOLD}$USERNAME${NC}
  ${PURPLE}▸${NC} Hostname:  ${BOLD}$P_HOSTNAME${NC}
  ${PURPLE}▸${NC} Disco:     ${BOLD}$DISK${NC}

${DIM}  Siguiente:${NC}

    1. Quita el USB
    2. Escribe: ${GREEN}reboot${NC}
    3. En GRUB selecciona Arch Linux
    4. Login con tu usuario y password
    5. Escribe: ${GREEN}Hyprland${NC}

${DIM}  Post-install (ya dentro de Hyprland):${NC}

    ${GREEN}cd ~/Arch_distro_phantom && bash install.sh${NC}

${DIM}  Eso instalará los paquetes extra y AUR.${NC}

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
"

# Cleanup
umount -R /mnt 2>/dev/null || true
swapoff -a 2>/dev/null || true

echo -e "  Escribe ${GREEN}reboot${NC} cuando estés listo.\n"
