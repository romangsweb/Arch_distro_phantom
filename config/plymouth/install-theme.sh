#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  PLYMOUTH — Phantom Boot Splash Theme Installer               ║
# ║  Creates a minimal text-based boot animation                   ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Plymouth on Arch Linux renders during kernel boot.
# This script creates a custom "script" type theme.
#
# Run as root after install:
#   sudo bash config/plymouth/install-theme.sh

set -euo pipefail

THEME_NAME="phantom"
THEME_DIR="/usr/share/plymouth/themes/$THEME_NAME"

echo "Installing Plymouth Phantom theme..."

sudo mkdir -p "$THEME_DIR"

# Theme descriptor
sudo tee "$THEME_DIR/phantom.plymouth" > /dev/null << 'EOF'
[Plymouth Theme]
Name=Phantom
Description=Flat minimal boot splash for Phantom Rice
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/phantom
ScriptFile=/usr/share/plymouth/themes/phantom/phantom.script
EOF

# Boot script (Plymouth scripting language)
sudo tee "$THEME_DIR/phantom.script" > /dev/null << 'SCRIPT'
/* ── Phantom Boot Splash ─────────────────────────────────── */

/* Colors */
Window.SetBackgroundTopColor(0.04, 0.04, 0.04);     /* #0a0a0a */
Window.SetBackgroundBottomColor(0.04, 0.04, 0.04);   /* #0a0a0a */

/* ── Logo Text ──────────────────────────────────────────── */
logo.image = Image.Text("PHANTOM", 0.49, 0.78, 0.63); /* #7EC8A0 */
logo.sprite = Sprite(logo.image);
logo.sprite.SetX(Window.GetWidth() / 2 - logo.image.GetWidth() / 2);
logo.sprite.SetY(Window.GetHeight() / 2 - 40);

/* ── Subtitle ───────────────────────────────────────────── */
sub.image = Image.Text("Arch Linux", 0.33, 0.33, 0.33); /* #555555 */
sub.sprite = Sprite(sub.image);
sub.sprite.SetX(Window.GetWidth() / 2 - sub.image.GetWidth() / 2);
sub.sprite.SetY(Window.GetHeight() / 2 + 10);

/* ── Progress Indicator ─────────────────────────────────── */
progress = 0;

fun refresh_callback() {
    progress++;
    
    /* Animated dots: cycling through . .. ... */
    dots_count = Math.Int(progress / 15) % 4;
    dots_text = "";
    for (i = 0; i < dots_count; i++)
        dots_text += "·";
    
    dot.image = Image.Text(dots_text, 0.49, 0.78, 0.63);
    dot.sprite = Sprite(dot.image);
    dot.sprite.SetX(Window.GetWidth() / 2 - dot.image.GetWidth() / 2);
    dot.sprite.SetY(Window.GetHeight() / 2 + 50);
}

Plymouth.SetRefreshFunction(refresh_callback);

/* ── Boot Messages ──────────────────────────────────────── */
message_sprite = Sprite();
fun message_callback(text) {
    msg.image = Image.Text(text, 0.33, 0.33, 0.33);
    message_sprite.SetImage(msg.image);
    message_sprite.SetX(Window.GetWidth() / 2 - msg.image.GetWidth() / 2);
    message_sprite.SetY(Window.GetHeight() - 50);
}

Plymouth.SetMessageFunction(message_callback);

/* ── Password Prompt ────────────────────────────────────── */
fun display_password_callback(prompt, bullets) {
    pass_prompt.image = Image.Text(prompt, 0.71, 0.56, 0.68); /* #B48EAD */
    pass_prompt.sprite = Sprite(pass_prompt.image);
    pass_prompt.sprite.SetX(Window.GetWidth() / 2 - pass_prompt.image.GetWidth() / 2);
    pass_prompt.sprite.SetY(Window.GetHeight() / 2 + 80);
    
    bullet_string = "";
    for (i = 0; i < bullets; i++)
        bullet_string += "● ";
    
    pass_bullets.image = Image.Text(bullet_string, 0.49, 0.78, 0.63);
    pass_bullets.sprite = Sprite(pass_bullets.image);
    pass_bullets.sprite.SetX(Window.GetWidth() / 2 - pass_bullets.image.GetWidth() / 2);
    pass_bullets.sprite.SetY(Window.GetHeight() / 2 + 110);
}

Plymouth.SetDisplayPasswordFunction(display_password_callback);
SCRIPT

# Set as default theme
sudo plymouth-set-default-theme phantom 2>/dev/null || true

echo "Plymouth theme installed."
echo "Rebuild initramfs: sudo mkinitcpio -p linux"
echo "Add 'splash' to kernel parameters in bootloader config."
