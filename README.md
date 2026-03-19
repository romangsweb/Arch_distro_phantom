# PHANTOM RICE — Arch Linux · MacBook Pro A1706

> Flat minimal · Green/Purple · AI/ML + DevOps workstation

```
███████╗██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗
██╔══██║██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║
███████║███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║
██╔════╝██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║
██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝
```

---

## 🎯 Stack completo

| Capa | Herramienta |
|---|---|
| Bootloader | GRUB (themed) |
| Boot splash | Plymouth (PHANTOM text) |
| Login | greetd + tuigreet |
| Compositor | Hyprland (Wayland) |
| Bar | Waybar (Docker, updates, system) |
| Widgets | Eww (ML dashboard, sliders) |
| Terminal | Kitty (sessions, tab_bar.py, kittens) |
| Shell | Zsh + Oh My Zsh + Starship |
| Multiplexer | Tmux + Zellij (Phantom theme) |
| Editor | Neovim + NvChad (17 LSPs, Copilot, DAP) |
| Launcher | Rofi (power menu, quick actions, calculator) |
| Browser | Firefox (userChrome.css themed) |
| Files | Ranger (TUI) + Thunar (GUI) |
| Notifications | Mako |
| Lock | Hyprlock |
| Idle | Hypridle (dim→lock→dpms→suspend) |
| Clipboard | cliphist |
| Recording | wf-recorder + swappy |
| Audio viz | cava |
| Blue light | gammastep |
| Touch Bar | tiny-dfr (media/F-keys/clock) |
| Monitoring | btop, nvtop, lazydocker, k9s |
| AI | Ollama, Claude Code, aichat |
| Firewall | nftables + fail2ban |

---

## 📦 Instalación

Hay dos formas de instalar Phantom: el **Método Express** (creando una ISO pre-cargada con todo) y el **Método Manual** (sobre una instalación base de Arch).

### Método 1: Express (ISO Personalizada) 🔥 RECOMENDADO

Este método crea una ISO de Arch Linux que ya contiene todos los programas y configuraciones de Phantom, junto con un instalador automático.

**1. Construir la ISO (Requiere un Linux existente, VM o Live USB):**
```bash
git clone https://github.com/TU_USUARIO/Arch_distro_phantom.git
cd Arch_distro_phantom/iso-builder
sudo ./build-iso.sh
```
*Esto generará `out/phantom-archlinux-YYYY.MM.DD-x86_64.iso` (Toma ~15 mins).*

**2. Grabar en USB y Bootear:**
- **Desde Linux:** `sudo dd if=out/phantom-*.iso of=/dev/sdX bs=4M status=progress`
- **Desde Mac:** `sudo dd if=out/phantom-*.iso of=/dev/rdiskN bs=4m status=progress`
- Conecta el USB a la MacBook, enciende manteniendo ⌥ (Option) y elige EFI Boot.

**3. Instalar (Un solo comando):**
Cuando cargue la pantalla negra de Phantom, escribe:
```bash
phantom-install
```
*Responde 8 preguntas simples (nombre, disco, contraseñas), y el instalador formateará, instalará Arch base, y configurará TODA la arrozada automáticamente en 10 minutos. Luego solo sacas el USB y reinicias.*

---

### Método 2: Manual (Instalar Arch paso a paso)

Si prefieres instalar Arch Linux a mano y luego aplicar la capa Phantom:

**Paso 1: Instalar Arch Linux base**

```bash
# 1. Descarga la ISO de Arch Linux
# https://archlinux.org/download/
# Descarga el archivo: archlinux-YYYY.MM.DD-x86_64.iso

# 2. Identifica tu USB (CUIDADO — selecciona el disco correcto)
diskutil list
# Busca tu USB, por ejemplo: /dev/disk2

# 3. Desmonta el USB
diskutil unmountDisk /dev/disk2

# 4. Escribe la ISO al USB (cambia disk2 por tu disco)
# ADVERTENCIA: dd borra TODO en el disco
sudo dd if=~/Downloads/archlinux-*.iso of=/dev/rdisk2 bs=4m status=progress

# 5. Expulsa
diskutil eject /dev/disk2
```

> ⚠️ **IMPORTANTE**: Usa `/dev/rdisk2` (con 'r') no `/dev/disk2` — es ~20x más rápido.

### Paso 2: Arrancar desde USB en MacBook

```
1. Apaga la MacBook completamente
2. Mantén presionada la tecla ⌥ (Option/Alt)
3. Enciende la Mac mientras mantienes ⌥
4. Aparecerá el menú de boot → selecciona "EFI Boot"
5. Selecciona "Arch Linux install medium"
```

### Paso 3: Instalar Arch Linux base

```bash
# ── Conectar WiFi (si no tienes ethernet) ─────────────────
iwctl
# Dentro de iwctl:
#   station wlan0 scan
#   station wlan0 get-networks
#   station wlan0 connect "TU_WIFI"
#   exit

# Verificar internet
ping -c 3 archlinux.org

# ── Particionado ──────────────────────────────────────────
# Para MacBook con dual boot (macOS + Arch):
# macOS ya creó la EFI partition. Solo necesitas Linux partitions.

lsblk  # Identifica tu disco (usualmente /dev/nvme0n1)

# Opción A: Solo Arch (borra todo)
# Opción B: Dual boot (redimensiona macOS primero desde macOS Disk Utility)

# Crear particiones con fdisk o cfdisk:
cfdisk /dev/nvme0n1

# Particiones recomendadas:
# /dev/nvme0n1p1  512M   EFI System (ya existe si dual boot)
# /dev/nvme0n1p3  32G    Linux swap
# /dev/nvme0n1p4  REST   Linux filesystem (root)

# ── Formatear ─────────────────────────────────────────────
mkfs.fat -F32 /dev/nvme0n1p1    # Solo si NO es dual boot
mkswap /dev/nvme0n1p3
mkfs.ext4 /dev/nvme0n1p4

# ── Montar ────────────────────────────────────────────────
mount /dev/nvme0n1p4 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot
swapon /dev/nvme0n1p3

# ── Instalar base ────────────────────────────────────────
pacstrap -K /mnt base linux linux-firmware base-devel \
    networkmanager vim git sudo intel-ucode

# ── Generar fstab ─────────────────────────────────────────
genfstab -U /mnt >> /mnt/etc/fstab

# ── Entrar al sistema ────────────────────────────────────
arch-chroot /mnt

# ── Configurar sistema ───────────────────────────────────
# Timezone
ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
hwclock --systohc

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "es_MX.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "phantom" > /etc/hostname

# Hosts
cat >> /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   phantom.localdomain phantom
EOF

# Root password
passwd

# Crear tu usuario
useradd -m -G wheel,video,audio,input -s /bin/bash TU_USUARIO
passwd TU_USUARIO

# Sudoers
echo "%wheel ALL=(ALL:ALL) ALL" | EDITOR="tee -a" visudo

# ── Bootloader (GRUB) ────────────────────────────────────
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# ── NetworkManager ────────────────────────────────────────
systemctl enable NetworkManager

# ── Salir y reiniciar ─────────────────────────────────────
exit
umount -R /mnt
reboot
# QUITA EL USB al reiniciar
```

### Paso 4: Primer boot — Instalar Phantom Rice

```bash
# Login con tu usuario

# 1. Conectar WiFi
nmcli device wifi connect "TU_WIFI" password "TU_PASSWORD"

# 2. Clonar el repositorio
git clone https://github.com/TU_USUARIO/Arch_distro_phantom.git ~/Arch_distro_phantom
# O si ya lo tienes en USB:
cp -r /ruta/al/usb/Arch_distro_phantom ~/Arch_distro_phantom

# 3. Ejecutar el instalador
cd ~/Arch_distro_phantom
chmod +x install.sh
./install.sh

# 4. El instalador te preguntará:
#    - Tu nombre completo
#    - Email
#    - Hostname
#    - IP del servidor ML (o 'skip')
#    - GitHub username
#    - Latitud/longitud (para gammastep)
#
# Luego corre las 14 fases automáticamente.

# 5. Al terminar:
#    - Reinicia: sudo reboot
#    - La pantalla de Plymouth aparece
#    - greetd/tuigreet te recibe
#    - Selecciona Hyprland
#    - SUPER + Return = terminal
#    - fastfetch = verificar setup
```

### Paso 5: Post-instalación

```bash
# Aplicar tema de Firefox
phantom-firefox-theme

# Verificar Touch Bar
sudo systemctl status tiny-dfr

# Descargar modelo AI local
ollama pull llama3

# Instalar plugins de Neovim (primera vez)
nvim  # Espera a que NvChad instale plugins
# Luego: :MasonInstallAll

# Ver tus keybindings (dentro de Hyprland)
# SUPER + D        → Launcher
# SUPER + Space    → All-in-one launcher
# SUPER + /        → Quick actions (23 acciones)
# SUPER + X        → Power menu
# SUPER + Return   → Terminal
# SUPER + W        → Toggle ML panels
# SUPER + C        → Clipboard history
# SUPER + SHIFT+R  → Grabar pantalla
# SUPER + SHIFT+S  → Screenshot + anotar
# SUPER + A        → Audio visualizer
# SUPER + L        → Lock screen
# CTRL+SHIFT+F1    → Kitty sesión Dev
# CTRL+SHIFT+F2    → Kitty sesión Monitor
# CTRL+SHIFT+F3    → Kitty sesión ML
# CTRL+SHIFT+F4    → Kitty sesión Server
```

---

## 📁 Estructura del proyecto

```
Arch_distro_phantom/
├── install.sh                    ← Instalador interactivo (14 fases)
├── commands-reference.sh         ← 350+ comandos anotados
├── wallpapers/
│   ├── arch-vesper.png
│   └── desktop-preview.png
└── config/
    ├── hypr/
    │   ├── hyprland.conf         ← WM + keybindings (80+ binds)
    │   ├── hyprlock.conf         ← Lock screen
    │   ├── hyprpaper.conf        ← Wallpaper
    │   └── hypridle.conf         ← Auto-lock/suspend
    ├── waybar/
    │   ├── config.jsonc          ← Bar modules + Docker/Updates
    │   ├── style.css             ← Flat minimal styling
    │   └── scripts/              ← docker, updates, keyboard
    ├── eww/
    │   ├── eww.yuck              ← ML dashboard + controls
    │   └── eww.scss              ← Flat panel styles
    ├── kitty/
    │   ├── kitty.conf            ← 180+ line config
    │   ├── tab_bar.py            ← Custom Python tab renderer
    │   └── sessions/             ← dev, monitor, ml, server
    ├── rofi/
    │   ├── config.rasi
    │   ├── phantom.rasi          ← Theme
    │   └── scripts/              ← powermenu, launcher, quickactions
    ├── nvim/lua/custom/
    │   ├── plugins.lua           ← 20+ plugins (LSP, AI, Debug)
    │   ├── mappings.lua          ← 35+ keymaps
    │   ├── init.lua              ← Options + Phantom highlights
    │   └── configs/lspconfig.lua ← 15 language servers
    ├── zellij/
    │   ├── config.kdl            ← Phantom theme + keybinds
    │   └── layouts/              ← dev, ml
    ├── tmux/tmux.conf            ← Phantom theme
    ├── firefox/
    │   ├── userChrome.css        ← Browser chrome theme
    │   └── user.js               ← Privacy + performance
    ├── zsh/.zshrc                ← 300+ line config
    ├── starship/starship.toml    ← Prompt theme
    ├── fastfetch/config.jsonc    ← System info
    ├── btop/vesper.theme         ← Phantom colors
    ├── cava/config               ← Audio visualizer
    ├── mako/config               ← Notifications
    ├── ranger/rc.conf            ← File manager
    ├── greetd/config.toml        ← Login manager
    ├── tiny-dfr/
    │   ├── config.toml           ← Touch Bar layout
    │   └── touchbar-ctl.sh       ← Helper script
    ├── gammastep/config.ini      ← Blue light filter
    ├── git/.gitconfig            ← Delta diffs + aliases
    ├── ssh/config                ← ML server tunnels
    ├── pacman/pacman.conf        ← ILoveCandy + parallel
    ├── plymouth/install-theme.sh ← Boot splash
    ├── grub/install-theme.sh     ← Bootloader theme
    └── systemd/
        ├── reflector.conf        ← Mirror optimization
        └── setup-maintenance.sh  ← Firewall + hardening
```

---

## 🎨 Paleta

| Token | Color | Uso |
|---|---|---|
| Primary | `#7EC8A0` | Active elements, borders, accents |
| Secondary | `#B48EAD` | Highlights, labels, secondary info |
| Background | `#0a0a0a` | All backgrounds |
| Surface | `#141414` | Panels, cards |
| Border | `#1e1e1e` | 1px solid lines |
| Text | `#d4d4d4` | Primary text |
| Dim | `#555555` | Inactive, secondary text |
