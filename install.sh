#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║  PHANTOM RICE — Hyper-Personalized Installer                    ║
# ║  MacBook Pro A1706 (2016 Touch Bar) — AI/ML + DevOps Station    ║
# ║                                                                  ║
# ║  Usage: chmod +x install.sh && ./install.sh                      ║
# ╚══════════════════════════════════════════════════════════════════╝

set -euo pipefail
IFS=$'\n\t'

# ── Colors ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[38;2;126;200;160m'
PURPLE='\033[38;2;180;142;173m'
BLUE='\033[38;2;129;161;193m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# ── Logging ─────────────────────────────────────────────────────────
log_info()    { echo -e "${PURPLE}   ▸${NC} $1"; }
log_success() { echo -e "${GREEN}   ✓${NC} $1"; }
log_error()   { echo -e "${RED}   ✖${NC} $1"; }
log_step()    { echo -e "\n${GREEN}━━━${NC} ${BOLD}$1${NC} ${GREEN}━━━${NC}\n"; }
log_dim()     { echo -e "${DIM}     $1${NC}"; }

# ── Safety Check ────────────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
    log_error "Do not run as root. Script will escalate when needed."
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"

# ──────────────────────────────────────────────────────────────────
# Banner
# ──────────────────────────────────────────────────────────────────
clear
echo -e "
${GREEN}
    ██████  ██   ██  █████  ███    ██ ████████  ██████  ███    ███
    ██   ██ ██   ██ ██   ██ ████   ██    ██    ██    ██ ████  ████
    ██████  ███████ ███████ ██ ██  ██    ██    ██    ██ ██ ████ ██
    ██      ██   ██ ██   ██ ██  ██ ██    ██    ██    ██ ██  ██  ██
    ██      ██   ██ ██   ██ ██   ████    ██     ██████  ██      ██
${NC}
${DIM}    Arch Linux · MacBook Pro A1706 · Hyprland · Flat Minimal${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
"

# ──────────────────────────────────────────────────────────────────
# Interactive Setup — User Personalization
# ──────────────────────────────────────────────────────────────────
log_step "User Configuration"

if [[ -n "${PHANTOM_NONINTERACTIVE:-}" ]]; then
    echo -e "${PURPLE}  Running in non-interactive mode (ISO Builder).${NC}\n"
    # Map HOSTNAME from ISO builder to USER_HOSTNAME
    USER_HOSTNAME="${HOSTNAME:-phantom}"
    # Use existing variables exported by the ISO builder
    # Fallbacks just in case
    CURRENT_USER=$(whoami)
    USER_FULLNAME="${USER_FULLNAME:-$CURRENT_USER}"
    USER_EMAIL="${USER_EMAIL:-user@phantom.arch}"
    ML_SERVER_IP="${ML_SERVER_IP:-skip}"
    ML_SERVER_USER="${ML_SERVER_USER:-$CURRENT_USER}"
    GITHUB_USER="${GITHUB_USER:-skip}"
    USER_LAT="${USER_LAT:-19.4}"
    USER_LON="${USER_LON:--99.1}"
else
    echo -e "${PURPLE}  Let's personalize your system.${NC}\n"

    # Username (pre-filled)
    CURRENT_USER=$(whoami)
    read -rp "$(echo -e "${GREEN}  ❯${NC} Full name [${DIM}$CURRENT_USER${NC}]: ")" USER_FULLNAME
    USER_FULLNAME="${USER_FULLNAME:-$CURRENT_USER}"

    read -rp "$(echo -e "${GREEN}  ❯${NC} Email: ")" USER_EMAIL
    USER_EMAIL="${USER_EMAIL:-user@phantom.arch}"

    read -rp "$(echo -e "${GREEN}  ❯${NC} Hostname [${DIM}phantom${NC}]: ")" USER_HOSTNAME
    USER_HOSTNAME="${USER_HOSTNAME:-phantom}"

    read -rp "$(echo -e "${GREEN}  ❯${NC} ML server IP [${DIM}skip${NC}]: ")" ML_SERVER_IP
    ML_SERVER_IP="${ML_SERVER_IP:-skip}"

    read -rp "$(echo -e "${GREEN}  ❯${NC} ML server user [${DIM}$CURRENT_USER${NC}]: ")" ML_SERVER_USER
    ML_SERVER_USER="${ML_SERVER_USER:-$CURRENT_USER}"

    read -rp "$(echo -e "${GREEN}  ❯${NC} GitHub username [${DIM}skip${NC}]: ")" GITHUB_USER
    GITHUB_USER="${GITHUB_USER:-skip}"

    # Timezone for gammastep
    read -rp "$(echo -e "${GREEN}  ❯${NC} Latitude [${DIM}19.4${NC}]: ")" USER_LAT
    USER_LAT="${USER_LAT:-19.4}"

    read -rp "$(echo -e "${GREEN}  ❯${NC} Longitude [${DIM}-99.1${NC}]: ")" USER_LON
    USER_LON="${USER_LON:-99.1}"
fi
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "
  ${BOLD}Configuration Summary:${NC}

  ${PURPLE}User${NC}        $USER_FULLNAME <$USER_EMAIL>
  ${PURPLE}Hostname${NC}    $USER_HOSTNAME
  ${PURPLE}ML Server${NC}   $ML_SERVER_IP (user: $ML_SERVER_USER)
  ${PURPLE}GitHub${NC}      $GITHUB_USER
  ${PURPLE}Location${NC}    $USER_LAT, $USER_LON
"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

read -rp "$(echo -e "\n${GREEN}  ❯${NC} Continue? [Y/n]: ")" CONFIRM
CONFIRM="${CONFIRM:-Y}"
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${DIM}  Aborted.${NC}"
    exit 0
fi

# Set hostname
log_info "Setting hostname to '$USER_HOSTNAME'..."
sudo hostnamectl set-hostname "$USER_HOSTNAME" 2>/dev/null || true

# ──────────────────────────────────────────────────────────────────
# Phase 0: AUR Helper
# ──────────────────────────────────────────────────────────────────
log_step "Phase 0/14 — AUR Helper"

if ! command -v paru &>/dev/null; then
    log_info "Installing paru..."
    sudo pacman -S --needed --noconfirm base-devel git
    cd /tmp && rm -rf paru
    git clone https://aur.archlinux.org/paru.git
    cd paru && makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
    log_success "paru installed"
else
    log_success "paru already installed"
fi

# ──────────────────────────────────────────────────────────────────
# Phase 1: MacBook Pro A1706 Hardware
# ──────────────────────────────────────────────────────────────────
log_step "Phase 1/14 — MacBook A1706 Hardware"

MACBOOK_PKGS=(
    # Wi-Fi — Broadcom BCM43602
    broadcom-wl-dkms
    # Trackpad & keyboard
    libinput
    # Intel Iris 550 GPU
    mesa intel-media-driver vulkan-intel intel-gpu-tools
    # Power management
    tlp tlp-rdw powertop thermald
    # Audio — PipeWire full stack
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
    # Brightness & sensors
    brightnessctl iio-sensor-proxy
    # Bluetooth
    bluez bluez-utils blueman
    # Firmware
    linux-firmware linux-headers dkms
    # Suspend/resume fixes
    acpid
)

log_info "Installing MacBook A1706 hardware support..."
sudo pacman -S --needed --noconfirm "${MACBOOK_PKGS[@]}" 2>/dev/null || true

# Touch Bar (AUR)
log_info "Installing Touch Bar driver..."
paru -S --needed --noconfirm tiny-dfr-git 2>/dev/null || log_dim "tiny-dfr skipped"

# Facetime camera (AUR)
paru -S --needed --noconfirm bcwc-pcie-git 2>/dev/null || log_dim "bcwc-pcie skipped"

# Enable hardware services
for svc in tlp bluetooth thermald acpid; do
    sudo systemctl enable --now "$svc.service" 2>/dev/null || true
done
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true

log_success "Hardware support configured"

# ──────────────────────────────────────────────────────────────────
# Phase 2: Login Manager (greetd + tuigreet)
# ──────────────────────────────────────────────────────────────────
log_step "Phase 2/14 — Login Manager"

sudo pacman -S --needed --noconfirm greetd 2>/dev/null || true
paru -S --needed --noconfirm greetd-tuigreet 2>/dev/null || log_dim "tuigreet skipped"

log_info "Configuring greetd..."
sudo mkdir -p /etc/greetd
sudo cp "$DOTFILES_DIR/config/greetd/config.toml" /etc/greetd/config.toml 2>/dev/null || true
sudo systemctl enable greetd.service 2>/dev/null || true

# Disable other display managers if present
for dm in gdm sddm lightdm lxdm; do
    sudo systemctl disable "$dm.service" 2>/dev/null || true
done

log_success "Login manager configured (greetd + tuigreet)"

# ──────────────────────────────────────────────────────────────────
# Phase 3: Desktop Environment (Hyprland)
# ──────────────────────────────────────────────────────────────────
log_step "Phase 3/14 — Desktop Environment"

DESKTOP_PKGS=(
    # Compositor
    hyprland hyprpaper hyprlock hypridle
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    # Bar & widgets
    waybar
    # Notifications
    mako
    # Launcher
    rofi-wayland
    # Auth
    polkit-gnome
    # Screenshots & recording
    grim slurp wl-clipboard swappy
    # Screen recording
    wf-recorder
    # Clipboard manager
    cliphist wl-clip-persist
    # Display
    wlr-randr
    # Blue light filter
    gammastep
    # Theme & cursor
    lxappearance papirus-icon-theme adwaita-cursors nwg-look
    # Qt theming
    qt5ct qt6ct
)

log_info "Installing desktop environment..."
sudo pacman -S --needed --noconfirm "${DESKTOP_PKGS[@]}" 2>/dev/null || true

# Eww widgets (AUR)
paru -S --needed --noconfirm eww-git 2>/dev/null || log_dim "eww skipped"

log_success "Desktop installed"

# ──────────────────────────────────────────────────────────────────
# Phase 4: Terminal & Shell
# ──────────────────────────────────────────────────────────────────
log_step "Phase 4/14 — Terminal & Shell"

SHELL_PKGS=(
    kitty zsh starship fastfetch
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji
    ttf-font-awesome otf-font-awesome
)

log_info "Installing terminal & fonts..."
sudo pacman -S --needed --noconfirm "${SHELL_PKGS[@]}" 2>/dev/null || true

# Default shell
if [[ "$SHELL" != *"zsh"* ]]; then
    log_info "Setting Zsh as default shell..."
    chsh -s "$(which zsh)"
fi

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
declare -A ZSH_PLUGINS=(
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
    ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
)

for plugin in "${!ZSH_PLUGINS[@]}"; do
    [[ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]] && \
        git clone "${ZSH_PLUGINS[$plugin]}" "$ZSH_CUSTOM/plugins/$plugin" 2>/dev/null || true
done

log_success "Shell configured"

# ──────────────────────────────────────────────────────────────────
# Phase 5: Modern CLI Power Tools
# ──────────────────────────────────────────────────────────────────
log_step "Phase 5/14 — CLI Power Tools"

CLI_PKGS=(
    # Core replacements
    bat eza fd ripgrep fzf zoxide jq yq
    # System monitoring
    btop htop bandwhich dust duf procs
    # Git
    lazygit git-delta
    # Network
    nmap httpie aria2 rsync mtr whois wget
    # File management
    ranger thunar thunar-archive-plugin thunar-volman tumbler gvfs gvfs-mtp
    # Multiplexers
    tmux zellij
    # Audio visualizer
    cava
    # Docs & media
    glow mpv imv ffmpeg
    # Archive
    unzip p7zip unrar
    # Security
    gnupg pass age
    # Misc productivity
    man-db man-pages tldr trash-cli xdg-utils playerctl wtype
    tree neofetch bc calc
)

log_info "Installing 60+ CLI tools..."
sudo pacman -S --needed --noconfirm "${CLI_PKGS[@]}" 2>/dev/null || true

# AUR CLI tools
AUR_CLI=(nvtop curlie dog ttop yt-dlp-git)
for pkg in "${AUR_CLI[@]}"; do
    paru -S --needed --noconfirm "$pkg" 2>/dev/null || log_dim "Skipped: $pkg"
done

log_success "CLI tools installed"

# ──────────────────────────────────────────────────────────────────
# Phase 6: Browser — Firefox (Themed)
# ──────────────────────────────────────────────────────────────────
log_step "Phase 6/14 — Firefox (Custom Theme)"

sudo pacman -S --needed --noconfirm firefox 2>/dev/null || true

# Deploy Firefox theme after first launch creates profile
log_info "Firefox theme will be deployed after first launch."
log_dim "userChrome.css & user.js ready in dotfiles"

log_success "Firefox installed"

# ──────────────────────────────────────────────────────────────────
# Phase 7: Editor — Neovim + NvChad
# ──────────────────────────────────────────────────────────────────
log_step "Phase 7/14 — Neovim + NvChad"

sudo pacman -S --needed --noconfirm neovim python-pynvim nodejs npm 2>/dev/null || true

if [[ ! -d "$CONFIG_DIR/nvim" ]]; then
    log_info "Installing NvChad..."
    git clone https://github.com/NvChad/starter "$CONFIG_DIR/nvim"
    log_success "NvChad installed (run nvim to complete)"
else
    log_dim "Neovim config exists, skipping"
fi

# Molten dependencies
pip install --user --break-system-packages pynvim jupyter_client cairosvg plotly kaleido 2>/dev/null || true

log_success "Editor configured"

# ──────────────────────────────────────────────────────────────────
# Phase 8: Containers & DevOps
# ──────────────────────────────────────────────────────────────────
log_step "Phase 8/14 — Containers & DevOps"

DEVOPS_PKGS=(
    docker docker-compose docker-buildx podman
    kubectl helm
    terraform ansible
    openssh mosh sshfs
)

log_info "Installing DevOps stack..."
sudo pacman -S --needed --noconfirm "${DEVOPS_PKGS[@]}" 2>/dev/null || true

AUR_DEVOPS=(lazydocker k9s)
for pkg in "${AUR_DEVOPS[@]}"; do
    paru -S --needed --noconfirm "$pkg" 2>/dev/null || log_dim "Skipped: $pkg"
done

sudo systemctl enable docker.service 2>/dev/null || true
sudo usermod -aG docker "$USER" 2>/dev/null || true

log_success "DevOps stack installed"

# ──────────────────────────────────────────────────────────────────
# Phase 9: Database Tools
# ──────────────────────────────────────────────────────────────────
log_step "Phase 9/14 — Database Tools"

sudo pacman -S --needed --noconfirm postgresql mariadb-clients redis sqlite 2>/dev/null || true
paru -S --needed --noconfirm pgcli mycli 2>/dev/null || {
    pip install --user --break-system-packages pgcli mycli 2>/dev/null || true
}
paru -S --needed --noconfirm mongosh-bin 2>/dev/null || log_dim "mongosh skipped"

log_success "Database tools installed"

# ──────────────────────────────────────────────────────────────────
# Phase 10: Python & AI/ML
# ──────────────────────────────────────────────────────────────────
log_step "Phase 10/14 — Python & AI/ML"

sudo pacman -S --needed --noconfirm python python-pip python-virtualenv ipython 2>/dev/null || true

# pyenv
if [[ ! -d "$HOME/.pyenv" ]]; then
    log_info "Installing pyenv..."
    curl -fsSL https://pyenv.run | bash
fi

# Mambaforge
if [[ ! -d "$HOME/mambaforge" ]]; then
    log_info "Installing Mambaforge..."
    curl -fsSL -o /tmp/mambaforge.sh \
        "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh"
    bash /tmp/mambaforge.sh -b -p "$HOME/mambaforge"
    rm -f /tmp/mambaforge.sh
fi

# uv
if ! command -v uv &>/dev/null; then
    log_info "Installing uv (Astral)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# ML packages
log_info "Installing ML Python packages..."
pip install --user --break-system-packages \
    numpy pandas matplotlib seaborn scikit-learn scipy \
    jupyterlab notebook ipykernel ipywidgets \
    torch --index-url https://download.pytorch.org/whl/cpu \
    transformers datasets tokenizers accelerate \
    tensorboard wandb mlflow \
    httpx requests rich typer click \
    black ruff mypy pytest \
    2>/dev/null || log_dim "Some pip packages may need manual install"

log_success "Python & AI/ML configured"

# ──────────────────────────────────────────────────────────────────
# Phase 11: AI Chat & LLM Tools
# ──────────────────────────────────────────────────────────────────
log_step "Phase 11/14 — AI Chat & LLM"

if ! command -v ollama &>/dev/null; then
    log_info "Installing Ollama..."
    curl -fsSL https://ollama.ai/install.sh | sh 2>/dev/null || true
fi

if ! command -v claude &>/dev/null; then
    log_info "Installing Claude Code CLI..."
    npm install -g @anthropic-ai/claude-code 2>/dev/null || true
fi

AUR_AI=(aichat tgpt)
for pkg in "${AUR_AI[@]}"; do
    paru -S --needed --noconfirm "$pkg" 2>/dev/null || log_dim "Skipped: $pkg"
done

log_success "AI tools installed"

# ──────────────────────────────────────────────────────────────────
# Phase 12: Daily Apps & Productivity
# ──────────────────────────────────────────────────────────────────
log_step "Phase 12/14 — Daily Apps & Productivity"

APP_PKGS=(
    # Browser (already installed above)
    pavucontrol nm-connection-editor networkmanager
    # Office / productivity
    libreoffice-fresh
    # Image editing
    gimp
    # PDF viewer
    zathura zathura-pdf-mupdf
    # Torrents
    transmission-gtk
    # System backup
    timeshift
    # File sync
    syncthing
    # Disk utility
    gnome-disk-utility
    # Calculator
    gnome-calculator
    # Password manager GUI
    keepassxc
    # Video calls (for meetings)
    # obs-studio — uncomment if needed
)

log_info "Installing productivity apps..."
sudo pacman -S --needed --noconfirm "${APP_PKGS[@]}" 2>/dev/null || true

# AUR apps
AUR_APPS=(
    spotify-launcher         # Spotify
    visual-studio-code-bin   # VS Code (backup editor)
    obs-studio-git           # Screen recording/streaming
)
for pkg in "${AUR_APPS[@]}"; do
    paru -S --needed --noconfirm "$pkg" 2>/dev/null || log_dim "Skipped: $pkg"
done

# Enable services
sudo systemctl enable --now NetworkManager.service 2>/dev/null || true
sudo systemctl enable --now syncthing@"$USER".service 2>/dev/null || true

log_success "Daily apps installed"

# ──────────────────────────────────────────────────────────────────
# Phase 13: Deploy All Configs
# ──────────────────────────────────────────────────────────────────
log_step "Phase 13/14 — Deploying Configuration"

deploy_config() {
    local src="$1"
    local dst="$2"
    local dirname
    dirname=$(dirname "$dst")

    if [[ -e "$dst" ]] && [[ ! -L "$dst" ]]; then
        mkdir -p "$BACKUP_DIR/$(dirname "${dst#$HOME/}")"
        cp -r "$dst" "$BACKUP_DIR/${dst#$HOME/}" 2>/dev/null || true
    fi

    mkdir -p "$dirname"
    ln -sf "$src" "$dst"
    log_success "$(basename "$src")"
}

echo -e "\n${DIM}   Linking dotfiles...${NC}\n"

# ── Hyprland
deploy_config "$DOTFILES_DIR/config/hypr/hyprland.conf"    "$CONFIG_DIR/hypr/hyprland.conf"
deploy_config "$DOTFILES_DIR/config/hypr/hyprlock.conf"    "$CONFIG_DIR/hypr/hyprlock.conf"
deploy_config "$DOTFILES_DIR/config/hypr/hyprpaper.conf"   "$CONFIG_DIR/hypr/hyprpaper.conf"
deploy_config "$DOTFILES_DIR/config/hypr/hypridle.conf"    "$CONFIG_DIR/hypr/hypridle.conf"

# ── Waybar
deploy_config "$DOTFILES_DIR/config/waybar/config.jsonc"   "$CONFIG_DIR/waybar/config.jsonc"
deploy_config "$DOTFILES_DIR/config/waybar/style.css"      "$CONFIG_DIR/waybar/style.css"

# ── Eww
deploy_config "$DOTFILES_DIR/config/eww/eww.yuck"         "$CONFIG_DIR/eww/eww.yuck"
deploy_config "$DOTFILES_DIR/config/eww/eww.scss"         "$CONFIG_DIR/eww/eww.scss"

# ── Kitty
deploy_config "$DOTFILES_DIR/config/kitty/kitty.conf"      "$CONFIG_DIR/kitty/kitty.conf"
deploy_config "$DOTFILES_DIR/config/kitty/tab_bar.py"      "$CONFIG_DIR/kitty/tab_bar.py"
mkdir -p "$CONFIG_DIR/kitty/sessions"
for session in dev monitor ml server; do
    deploy_config "$DOTFILES_DIR/config/kitty/sessions/${session}.conf" "$CONFIG_DIR/kitty/sessions/${session}.conf"
done

# ── Rofi
deploy_config "$DOTFILES_DIR/config/rofi/config.rasi"      "$CONFIG_DIR/rofi/config.rasi"
deploy_config "$DOTFILES_DIR/config/rofi/phantom.rasi"     "$CONFIG_DIR/rofi/phantom.rasi"
mkdir -p "$CONFIG_DIR/rofi/scripts"
for script in powermenu launcher quickactions; do
    cp "$DOTFILES_DIR/config/rofi/scripts/${script}.sh" "$CONFIG_DIR/rofi/scripts/${script}.sh"
    chmod +x "$CONFIG_DIR/rofi/scripts/${script}.sh"
done
log_success "rofi scripts (power, launcher, quick actions)"

# ── Waybar scripts
mkdir -p "$CONFIG_DIR/waybar/scripts"
for script in docker updates keyboard; do
    cp "$DOTFILES_DIR/config/waybar/scripts/${script}.sh" "$CONFIG_DIR/waybar/scripts/${script}.sh"
    chmod +x "$CONFIG_DIR/waybar/scripts/${script}.sh"
done
log_success "waybar scripts (docker, updates, keyboard)"

# ── Tmux
mkdir -p "$CONFIG_DIR/tmux"
deploy_config "$DOTFILES_DIR/config/tmux/tmux.conf" "$CONFIG_DIR/tmux/tmux.conf"

# ── Mako
deploy_config "$DOTFILES_DIR/config/mako/config"           "$CONFIG_DIR/mako/config"

# ── Ranger
deploy_config "$DOTFILES_DIR/config/ranger/rc.conf"        "$CONFIG_DIR/ranger/rc.conf"

# ── Fastfetch
deploy_config "$DOTFILES_DIR/config/fastfetch/config.jsonc" "$CONFIG_DIR/fastfetch/config.jsonc"

# ── btop
mkdir -p "$CONFIG_DIR/btop/themes"
deploy_config "$DOTFILES_DIR/config/btop/vesper.theme"     "$CONFIG_DIR/btop/themes/phantom.theme"

# ── Cava
deploy_config "$DOTFILES_DIR/config/cava/config"           "$CONFIG_DIR/cava/config"

# ── Gammastep (personalized lat/lon)
mkdir -p "$CONFIG_DIR/gammastep"
sed "s/lat=19.4/lat=$USER_LAT/; s/lon=-99.1/lon=$USER_LON/" \
    "$DOTFILES_DIR/config/gammastep/config.ini" > "$CONFIG_DIR/gammastep/config.ini"
log_success "gammastep (lat: $USER_LAT, lon: $USER_LON)"

# ── tiny-dfr (Touch Bar)
sudo mkdir -p /etc/tiny-dfr
sudo cp "$DOTFILES_DIR/config/tiny-dfr/config.toml" /etc/tiny-dfr/config.toml 2>/dev/null || true
sudo systemctl enable tiny-dfr.service 2>/dev/null || true
log_success "tiny-dfr Touch Bar config"

# ── Touch Bar helper script
mkdir -p "$HOME/.local/bin"
cp "$DOTFILES_DIR/config/tiny-dfr/touchbar-ctl.sh" "$HOME/.local/bin/touchbar-ctl"
chmod +x "$HOME/.local/bin/touchbar-ctl"
log_success "touchbar-ctl helper"

# ── Starship
deploy_config "$DOTFILES_DIR/config/starship/starship.toml" "$CONFIG_DIR/starship.toml"

# ── Zsh
deploy_config "$DOTFILES_DIR/config/zsh/.zshrc"            "$HOME/.zshrc"

# ── Neovim (NvChad custom layer)
if [[ -d "$CONFIG_DIR/nvim" ]]; then
    mkdir -p "$CONFIG_DIR/nvim/lua/custom/configs"
    for f in plugins.lua mappings.lua init.lua; do
        cp "$DOTFILES_DIR/config/nvim/lua/custom/$f" "$CONFIG_DIR/nvim/lua/custom/$f" 2>/dev/null || true
    done
    cp "$DOTFILES_DIR/config/nvim/lua/custom/configs/lspconfig.lua" "$CONFIG_DIR/nvim/lua/custom/configs/lspconfig.lua" 2>/dev/null || true
    log_success "neovim custom config (LSP, formatters, AI, debug)"
else
    log_info "Neovim config not found — install NvChad first, then re-run"
fi

# ── Zellij
mkdir -p "$CONFIG_DIR/zellij/layouts"
deploy_config "$DOTFILES_DIR/config/zellij/config.kdl" "$CONFIG_DIR/zellij/config.kdl"
for layout in dev ml; do
    deploy_config "$DOTFILES_DIR/config/zellij/layouts/${layout}.kdl" "$CONFIG_DIR/zellij/layouts/${layout}.kdl"
done
log_success "zellij (config + dev/ml layouts)"

# ── System Level (requires sudo)
log_info "Deploying system-level configs..."

# Pacman
sudo cp "$DOTFILES_DIR/config/pacman/pacman.conf" /etc/pacman.conf 2>/dev/null || true
log_success "pacman.conf (ILoveCandy, 10 parallel, multilib)"

# Plymouth boot splash
if command -v plymouth &>/dev/null || pacman -Qi plymouth &>/dev/null 2>&1; then
    bash "$DOTFILES_DIR/config/plymouth/install-theme.sh" 2>/dev/null || true
    log_success "plymouth boot splash"
else
    sudo pacman -S --needed --noconfirm plymouth 2>/dev/null || true
    bash "$DOTFILES_DIR/config/plymouth/install-theme.sh" 2>/dev/null || true
    log_success "plymouth installed + theme"
fi

# GRUB theme
if [[ -d /boot/grub ]]; then
    bash "$DOTFILES_DIR/config/grub/install-theme.sh" 2>/dev/null || true
    sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
    log_success "grub theme"
fi

# System maintenance
bash "$DOTFILES_DIR/config/systemd/setup-maintenance.sh" 2>/dev/null || true

# ── Git config (personalized)
mkdir -p "$HOME/.config/git"
sed "s/PHANTOM_USER_NAME/$USER_FULLNAME/; s/PHANTOM_USER_EMAIL/$USER_EMAIL/" \
    "$DOTFILES_DIR/config/git/.gitconfig" > "$HOME/.gitconfig"
log_success "gitconfig ($USER_FULLNAME <$USER_EMAIL>)"

# ── SSH config (personalized)
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [[ "$ML_SERVER_IP" != "skip" ]]; then
    sed "s/YOUR_ML_SERVER_IP/$ML_SERVER_IP/g; s/YOUR_USERNAME/$ML_SERVER_USER/g; s/YOUR_DEV_SERVER_IP/skip/g; s/YOUR_BASTION_IP/skip/g" \
        "$DOTFILES_DIR/config/ssh/config" > "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    log_success "ssh config (ML: $ML_SERVER_IP)"
else
    log_dim "SSH config skipped (no ML server)"
fi

# ── Generate SSH key if none exists
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    log_info "Generating SSH key..."
    ssh-keygen -t ed25519 -C "$USER_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""
    log_success "SSH key generated"
fi

# ── Wallpaper
mkdir -p "$CONFIG_DIR/wallpapers"
[[ -f "$DOTFILES_DIR/wallpapers/arch-vesper.png" ]] && \
    deploy_config "$DOTFILES_DIR/wallpapers/arch-vesper.png" "$CONFIG_DIR/wallpapers/arch-vesper.png"

# ── Screenshots directory
mkdir -p "$HOME/Pictures/Screenshots"

echo ""
log_success "All configs deployed"

# ──────────────────────────────────────────────────────────────────
# Phase 14: Post-Install
# ──────────────────────────────────────────────────────────────────
log_step "Phase 14/14 — Post-Install"

# btop config
mkdir -p "$CONFIG_DIR/btop"
cat > "$CONFIG_DIR/btop/btop.conf" << 'EOF'
color_theme = "/home/$USER/.config/btop/themes/phantom.theme"
theme_background = False
truecolor = True
rounded_corners = False
graph_symbol = braille
shown_boxes = "cpu mem net proc"
update_ms = 1000
EOF

# GTK dark theme
mkdir -p "$CONFIG_DIR/gtk-3.0"
cat > "$CONFIG_DIR/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-font-name=Noto Sans 11
gtk-application-prefer-dark-theme=true
EOF

# HiDPI env
mkdir -p "$CONFIG_DIR/environment.d"
cat > "$CONFIG_DIR/environment.d/hidpi.conf" << EOF
GDK_SCALE=2
GDK_DPI_SCALE=0.5
QT_AUTO_SCREEN_SCALE_FACTOR=1
XCURSOR_SIZE=24
MOZ_ENABLE_WAYLAND=1
EOF

# Firefox theme deploy helper script
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/phantom-firefox-theme" << 'SCRIPT'
#!/usr/bin/env bash
# Deploy Phantom theme to Firefox profile
FF_DIR="$HOME/.mozilla/firefox"
if [[ -d "$FF_DIR" ]]; then
    PROFILE=$(find "$FF_DIR" -maxdepth 1 -name "*.default-release" -type d | head -1)
    if [[ -n "$PROFILE" ]]; then
        mkdir -p "$PROFILE/chrome"
        DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        cp "$DOTFILES_DIR/Antigravity/Arch_distro_phantom/config/firefox/userChrome.css" "$PROFILE/chrome/"
        cp "$DOTFILES_DIR/Antigravity/Arch_distro_phantom/config/firefox/user.js" "$PROFILE/"
        echo "Phantom theme applied to Firefox. Restart Firefox."
    else
        echo "No Firefox profile found. Launch Firefox first, then run this again."
    fi
else
    echo "Firefox not yet launched. Start it once, close it, then run this."
fi
SCRIPT
chmod +x "$HOME/.local/bin/phantom-firefox-theme"

# Hyprland autostart additions — update hyprland.conf
if ! grep -q "hypridle" "$CONFIG_DIR/hypr/hyprland.conf" 2>/dev/null; then
    sed -i '/exec-once = mako/a exec-once = hypridle\nexec-once = gammastep\nexec-once = wl-paste --type text --watch cliphist store\nexec-once = wl-paste --type image --watch cliphist store' \
        "$CONFIG_DIR/hypr/hyprland.conf" 2>/dev/null || true
fi

# Clipboard keybinding
if ! grep -q "cliphist" "$CONFIG_DIR/hypr/hyprland.conf" 2>/dev/null; then
    echo -e '\n# Clipboard manager\nbind = $mainMod, C, exec, cliphist list | rofi -dmenu -theme ~/.config/rofi/phantom.rasi | cliphist decode | wl-copy' \
        >> "$CONFIG_DIR/hypr/hyprland.conf" 2>/dev/null || true
fi

# Screen recording keybinding
if ! grep -q "wf-recorder" "$CONFIG_DIR/hypr/hyprland.conf" 2>/dev/null; then
    echo -e '\n# Screen recording\nbind = $mainMod SHIFT, R, exec, wf-recorder -g "$(slurp)" -f ~/Videos/recording-$(date +%Y%m%d_%H%M%S).mp4\nbind = $mainMod SHIFT, S, exec, grim -g "$(slurp)" - | swappy -f -' \
        >> "$CONFIG_DIR/hypr/hyprland.conf" 2>/dev/null || true
fi

# Cava keybinding
if ! grep -q "cava" "$CONFIG_DIR/hypr/hyprland.conf" 2>/dev/null; then
    echo -e '\n# Audio visualizer\nbind = $mainMod, A, exec, kitty -e cava' \
        >> "$CONFIG_DIR/hypr/hyprland.conf" 2>/dev/null || true
fi

log_success "Post-install complete"

# ──────────────────────────────────────────────────────────────────
# Summary
# ──────────────────────────────────────────────────────────────────
TOTAL_PKGS=$(pacman -Q 2>/dev/null | wc -l || echo "?")

echo -e "
${GREEN}
    ██████  ██   ██  █████  ███    ██ ████████  ██████  ███    ███
    ██   ██ ██   ██ ██   ██ ████   ██    ██    ██    ██ ████  ████
    ██████  ███████ ███████ ██ ██  ██    ██    ██    ██ ██ ████ ██
    ██      ██   ██ ██   ██ ██  ██ ██    ██    ██    ██ ██  ██  ██
    ██      ██   ██ ██   ██ ██   ████    ██     ██████  ██      ██
${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
  ${BOLD}${GREEN}✓${NC} ${BOLD}Installation Complete${NC}  ·  ${DIM}$TOTAL_PKGS packages installed${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  ${BOLD}User:${NC}       $USER_FULLNAME <$USER_EMAIL>
  ${BOLD}Machine:${NC}    $USER_HOSTNAME
  ${BOLD}Backup:${NC}     ${DIM}$BACKUP_DIR${NC}

${PURPLE}  Next Steps:${NC}

  1. Log out → select ${CYAN}Hyprland${NC} at greetd login
  2. ${CYAN}SUPER + Return${NC} → open terminal
  3. ${CYAN}fastfetch${NC} → verify setup
  4. ${CYAN}SUPER + D${NC} → Rofi launcher
  5. Launch Firefox → close → run ${CYAN}phantom-firefox-theme${NC}
  6. ${CYAN}nvim${NC} → complete NvChad setup
  7. ${CYAN}ollama pull llama3${NC} → download local AI model
  8. Read ${CYAN}commands-reference.sh${NC} for the full cheatsheet

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
"
