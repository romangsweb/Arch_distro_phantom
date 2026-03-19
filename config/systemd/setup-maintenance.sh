#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  SYSTEM MAINTENANCE — Automated Timers & Hardening            ║
# ║  Run after install to enable system health automation          ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

GREEN='\033[38;2;126;200;160m'
PURPLE='\033[38;2;180;142;173m'
NC='\033[0m'

log() { echo -e "${GREEN}   ✓${NC} $1"; }
info() { echo -e "${PURPLE}   ▸${NC} $1"; }

echo -e "\n${GREEN}━━━${NC} System Maintenance Setup ${GREEN}━━━${NC}\n"

# ── Reflector (auto-update mirrors weekly) ─────────────────
info "Configuring Reflector..."
sudo cp /home/$USER/Antigravity/Arch_distro_phantom/config/systemd/reflector.conf /etc/xdg/reflector/reflector.conf 2>/dev/null || true
sudo systemctl enable --now reflector.timer 2>/dev/null || true
log "Reflector timer (weekly mirror optimization)"

# ── Paccache (auto-clean package cache weekly) ─────────────
info "Enabling paccache timer..."
sudo systemctl enable --now paccache.timer 2>/dev/null || true
log "Paccache timer (keep 3 recent versions)"

# ── fstrim (SSD TRIM weekly) ──────────────────────────────
info "Enabling fstrim timer..."
sudo systemctl enable --now fstrim.timer 2>/dev/null || true
log "fstrim timer (weekly SSD TRIM)"

# ── systemd-timesyncd (NTP sync) ──────────────────────────
info "Enabling time sync..."
sudo systemctl enable --now systemd-timesyncd.service 2>/dev/null || true
log "systemd-timesyncd (NTP sync)"

# ── systemd-oomd (Out-of-Memory daemon) ───────────────────
info "Enabling OOM daemon..."
sudo systemctl enable --now systemd-oomd.service 2>/dev/null || true
log "systemd-oomd (OOM protection)"

# ── Firewall (nftables basic) ─────────────────────────────
info "Setting up basic firewall..."
sudo pacman -S --needed --noconfirm nftables 2>/dev/null || true
sudo systemctl enable nftables.service 2>/dev/null || true
log "nftables firewall enabled"

# ── Fail2ban (SSH protection) ─────────────────────────────
info "Setting up Fail2ban..."
sudo pacman -S --needed --noconfirm fail2ban 2>/dev/null || true
sudo systemctl enable fail2ban.service 2>/dev/null || true
log "Fail2ban (SSH brute-force protection)"

# ── Arch Linux Security Hardening ─────────────────────────
# Disable core dumps
info "Hardening system..."
echo 'kernel.core_pattern=|/bin/false' | sudo tee /etc/sysctl.d/50-coredump.conf > /dev/null 2>/dev/null || true

# Restrict dmesg
echo 'kernel.dmesg_restrict=1' | sudo tee /etc/sysctl.d/50-dmesg.conf > /dev/null 2>/dev/null || true

# Apply sysctl
sudo sysctl --system > /dev/null 2>/dev/null || true
log "Kernel hardening (core dumps disabled, dmesg restricted)"

echo -e "\n${GREEN}━━━${NC} Maintenance setup complete ${GREEN}━━━${NC}\n"
