#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (via sudo or pkexec)." >&2
    exit 1
fi

SRC_DIR="/home/hero/.gemini/antigravity-cli/brain/ee061e04-e261-4034-89fc-e9a276ab1c09/scratch/CyberGRUB-2077"
THEME_DIR="/boot/grub/themes/CyberGRUB-2077"

echo "Creating theme directory: $THEME_DIR..."
mkdir -p /boot/grub/themes
rm -rf "$THEME_DIR"
cp -r "$SRC_DIR/CyberGRUB-2077" "$THEME_DIR"

# Copy samurai logo as default
cp "$SRC_DIR/img/logos/samurai.png" "$THEME_DIR/logo.png"

# Icon aliases
cd "$THEME_DIR/icons"
[ -f windows.png ] && cp -n windows.png windows11.png || true
[ -f windows.png ] && cp -n windows.png windows10.png || true
[ -f uefi.png ] && cp -n uefi.png uefi-firmware.png || true

# Update /usr/share/icons/default/index.theme for breeze_cursors
if [ -f /usr/share/icons/default/index.theme ]; then
    sed -i 's/Inherits=.*/Inherits=breeze_cursors/' /usr/share/icons/default/index.theme
    echo "Updated /usr/share/icons/default/index.theme to breeze_cursors"
fi

# Update /etc/default/grub.d/99_breeze-grub.cfg if it exists
if [ -f /etc/default/grub.d/99_breeze-grub.cfg ]; then
    cp /etc/default/grub.d/99_breeze-grub.cfg /etc/default/grub.d/99_breeze-grub.cfg.bak
    sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/CyberGRUB-2077/theme.txt"|' /etc/default/grub.d/99_breeze-grub.cfg
    echo "Updated /etc/default/grub.d/99_breeze-grub.cfg"
fi

# Update /etc/default/grub
GRUB_CFG="/etc/default/grub"
cp "$GRUB_CFG" "${GRUB_CFG}.bak.$(date +%s)"

# Ensure GRUB_THEME
if grep -q "^#\?GRUB_THEME=" "$GRUB_CFG"; then
    sed -i 's|^#\?GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/CyberGRUB-2077/theme.txt"|' "$GRUB_CFG"
else
    echo 'GRUB_THEME="/boot/grub/themes/CyberGRUB-2077/theme.txt"' >> "$GRUB_CFG"
fi

# Ensure GFXMODE
if grep -q "^#\?GRUB_GFXMODE=" "$GRUB_CFG"; then
    sed -i 's|^#\?GRUB_GFXMODE=.*|GRUB_GFXMODE=1920x1080,auto|' "$GRUB_CFG"
else
    echo 'GRUB_GFXMODE=1920x1080,auto' >> "$GRUB_CFG"
fi

# Ensure GFXPAYLOAD
if grep -q "^#\?GRUB_GFXPAYLOAD_LINUX=" "$GRUB_CFG"; then
    sed -i 's|^#\?GRUB_GFXPAYLOAD_LINUX=.*|GRUB_GFXPAYLOAD_LINUX=keep|' "$GRUB_CFG"
else
    echo 'GRUB_GFXPAYLOAD_LINUX=keep' >> "$GRUB_CFG"
fi

# Ensure timeout settings remain 5s
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' "$GRUB_CFG"
sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' "$GRUB_CFG"
if grep -q "^GRUB_RECORDFAIL_TIMEOUT=" "$GRUB_CFG"; then
    sed -i 's/^GRUB_RECORDFAIL_TIMEOUT=.*/GRUB_RECORDFAIL_TIMEOUT=5/' "$GRUB_CFG"
else
    echo "GRUB_RECORDFAIL_TIMEOUT=5" >> "$GRUB_CFG"
fi

# Disable console terminal override if active
sed -i 's/^GRUB_TERMINAL=/#GRUB_TERMINAL=/' "$GRUB_CFG"

echo "Running update-grub..."
update-grub

echo "CyberGRUB-2077 installed successfully!"
