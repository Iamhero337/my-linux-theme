#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (via pkexec or sudo)." >&2
    exit 1
fi

THEME_DIR="/usr/share/sddm/themes/sddm-astronaut-theme"
HACKER_CONF="$THEME_DIR/Themes/post-apocalyptic_hacker.conf"

echo "=== 1. Ensuring hacker configuration is applied to all targets ==="
sed -i 's/^HideSystemButtons=.*/HideSystemButtons="false"/' "$HACKER_CONF"
sed -i 's/^ScreenWidth=.*/ScreenWidth="1920"/' "$HACKER_CONF"
sed -i 's/^ScreenHeight=.*/ScreenHeight="1080"/' "$HACKER_CONF"

# Overwrite astronaut.conf, default.conf, theme.conf, and theme.conf.user with hacker.conf
cp -f "$HACKER_CONF" "$THEME_DIR/Themes/astronaut.conf"
cp -f "$HACKER_CONF" "$THEME_DIR/theme.conf"
cp -f "$HACKER_CONF" "$THEME_DIR/theme.conf.user"

# Update metadata.desktop
sed -i 's|^ConfigFile=.*|ConfigFile=Themes/post-apocalyptic_hacker.conf|' "$THEME_DIR/metadata.desktop"
sed -i 's|^Screenshot=.*|Screenshot=Previews/post-apocalyptic_hacker.png|' "$THEME_DIR/metadata.desktop"

# Ensure fonts are installed in system directories
mkdir -p /usr/local/share/fonts/sddm-astronaut-theme /usr/share/fonts/truetype/sddm-astronaut-theme
cp -f "$THEME_DIR/Fonts"/* /usr/local/share/fonts/sddm-astronaut-theme/ 2>/dev/null || true
cp -f "$THEME_DIR/Fonts"/* /usr/share/fonts/truetype/sddm-astronaut-theme/ 2>/dev/null || true
fc-cache -f

echo "=== 2. Verifying metadata.desktop ==="
cat "$THEME_DIR/metadata.desktop"

echo "=== 3. SDDM Hacker Theme Fix Completed! ==="
