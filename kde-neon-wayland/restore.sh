#!/bin/bash
# ==============================================================================
# 🌌 KDE Neon Wayland Setup - Complete Restore Script
# Restores: GRUB CyberGRUB-2077, SDDM Hacker Theme, Dell Backlight Always On,
#           NumLock Always On, Breeze Dark Cursors, and KDE Plasma 6 configs.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

echo "==> Restoring KDE Neon Wayland configuration for user: $TARGET_USER"

# 1. Root check for system components
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo: sudo ./restore.sh" >&2
    exit 1
fi

# 2. Package Dependencies
echo "==> Installing SDDM and required packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y --no-install-recommends sddm qt6-virtualkeyboard-plugin

# 3. Restore GRUB Theme & Configuration
echo "==> Restoring CyberGRUB-2077 bootloader theme..."
mkdir -p /boot/grub/themes
rm -rf /boot/grub/themes/CyberGRUB-2077
cp -r "$SCRIPT_DIR/themes/grub/CyberGRUB-2077" /boot/grub/themes/

if [ -f "$SCRIPT_DIR/system/grub/default_grub" ]; then
    cp "$SCRIPT_DIR/system/grub/default_grub" /etc/default/grub
fi
if [ -f "$SCRIPT_DIR/system/grub/99_breeze-grub.cfg" ]; then
    mkdir -p /etc/default/grub.d
    cp "$SCRIPT_DIR/system/grub/99_breeze-grub.cfg" /etc/default/grub.d/
fi
update-grub

# 4. Restore SDDM Hacker Theme
echo "==> Restoring SDDM Post-Apocalyptic Hacker theme..."
mkdir -p /usr/share/sddm/themes
rm -rf /usr/share/sddm/themes/sddm-astronaut-theme
cp -r "$SCRIPT_DIR/themes/sddm/sddm-astronaut-theme" /usr/share/sddm/themes/

# Install Fonts
mkdir -p /usr/local/share/fonts/sddm-astronaut-theme /usr/share/fonts/truetype/sddm-astronaut-theme
cp -r "$SCRIPT_DIR/themes/sddm/sddm-astronaut-theme/Fonts"/* /usr/local/share/fonts/sddm-astronaut-theme/ 2>/dev/null || true
cp -r "$SCRIPT_DIR/themes/sddm/sddm-astronaut-theme/Fonts"/* /usr/share/fonts/truetype/sddm-astronaut-theme/ 2>/dev/null || true
fc-cache -f

# Restore SDDM config files
mkdir -p /etc/sddm.conf.d
cp "$SCRIPT_DIR/system/sddm/kde_settings.conf" /etc/sddm.conf.d/
cp "$SCRIPT_DIR/system/sddm/10-numlock.conf" /etc/sddm.conf.d/
echo "/usr/bin/sddm" > /etc/X11/default-display-manager

systemctl disable plasmalogin.service 2>/dev/null || true
systemctl enable sddm.service

# 5. Restore System Services (Backlight & NumLock)
echo "==> Restoring systemd services (Backlight & NumLock)..."
cp "$SCRIPT_DIR/system/systemd/keyboard-backlight-always-on.service" /etc/systemd/system/
cp "$SCRIPT_DIR/system/systemd/numlock-tty.service" /etc/systemd/system/
mkdir -p /etc/systemd/system/getty@.service.d
cp "$SCRIPT_DIR/system/systemd/getty@.service.d/activate-numlock.conf" /etc/systemd/system/getty@.service.d/

systemctl daemon-reload
systemctl enable --now keyboard-backlight-always-on.service
systemctl enable --now numlock-tty.service

# Apply Dell BIOS settings if dell-wmi-sysman is available
SYS_ATTR="/sys/class/firmware-attributes/dell-wmi-sysman/attributes"
if [ -d "$SYS_ATTR" ]; then
    echo "Never" > "$SYS_ATTR/KbdBacklightTimeoutAc/current_value" 2>/dev/null || true
    echo "Never" > "$SYS_ATTR/KbdBacklightTimeoutBatt/current_value" 2>/dev/null || true
    echo "Bright" > "$SYS_ATTR/KeyboardIllumination/current_value" 2>/dev/null || true
    echo "Enabled" > "$SYS_ATTR/NumLock/current_value" 2>/dev/null || true
fi

# 6. Bluetooth Configuration
if [ -f "$SCRIPT_DIR/system/bluetooth/main.conf" ]; then
    cp "$SCRIPT_DIR/system/bluetooth/main.conf" /etc/bluetooth/main.conf
fi

# 7. Restore User Configuration
echo "==> Restoring user configuration files..."
USER_CONFIG="$USER_HOME/.config"
mkdir -p "$USER_CONFIG/environment.d" "$USER_CONFIG/gtk-3.0" "$USER_CONFIG/gtk-4.0"
mkdir -p "$USER_HOME/.icons/default" "$USER_HOME/.local/share/icons/default"

cp -a "$SCRIPT_DIR/configs/dot-config"/* "$USER_CONFIG/"
cp -a "$SCRIPT_DIR/configs/dot-icons/default/index.theme" "$USER_HOME/.icons/default/"
cp -a "$SCRIPT_DIR/configs/dot-local-share-icons/default/index.theme" "$USER_HOME/.local/share/icons/default/"

# Restore scripts
mkdir -p "$USER_HOME/.local/bin"
cp -a "$SCRIPT_DIR/scripts"/* "$USER_HOME/.local/bin/"
chmod +x "$USER_HOME/.local/bin"/* 2>/dev/null || true

# Fix ownership
chown -R "$TARGET_USER:$TARGET_USER" "$USER_CONFIG" "$USER_HOME/.icons" "$USER_HOME/.local"

echo "==> Applying cursor and plasma settings live..."
sudo -u "$TARGET_USER" systemctl --user set-environment XCURSOR_THEME=breeze_cursors 2>/dev/null || true
sudo -u "$TARGET_USER" systemctl --user set-environment XCURSOR_SIZE=24 2>/dev/null || true

echo "✅ Restoration completed successfully! Reboot your system to see all changes in action."
