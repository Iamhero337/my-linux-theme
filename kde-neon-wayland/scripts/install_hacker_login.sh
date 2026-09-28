#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (via pkexec or sudo)." >&2
    exit 1
fi

echo "=== 1. Installing SDDM and Qt6 VirtualKeyboard ==="
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y --no-install-recommends sddm qt6-virtualkeyboard-plugin

echo "/usr/bin/sddm" > /etc/X11/default-display-manager

echo "=== 2. Installing SDDM Astronaut Theme (Post-Apocalyptic Hacker) ==="
SRC_DIR="/home/hero/.gemini/antigravity-cli/brain/ee061e04-e261-4034-89fc-e9a276ab1c09/scratch/sddm-astronaut-theme"
THEME_DEST="/usr/share/sddm/themes/sddm-astronaut-theme"

mkdir -p "$THEME_DEST"
cp -r "$SRC_DIR"/* "$THEME_DEST/"

# Copy Hacker theme configuration
cp "$SRC_DIR/Themes/post-apocalyptic_hacker.conf" "$THEME_DEST/theme.conf"
cp "$SRC_DIR/Themes/post-apocalyptic_hacker.conf" "$THEME_DEST/theme.conf.user"

# Enable system buttons (Shutdown, Reboot) on login screen
sed -i 's/^HideSystemButtons=.*/HideSystemButtons="false"/' "$THEME_DEST/theme.conf"
sed -i 's/^HideSystemButtons=.*/HideSystemButtons="false"/' "$THEME_DEST/theme.conf.user"
sed -i 's/^ScreenWidth=.*/ScreenWidth="1920"/' "$THEME_DEST/theme.conf"
sed -i 's/^ScreenHeight=.*/ScreenHeight="1080"/' "$THEME_DEST/theme.conf"

echo "=== 3. Installing Theme Fonts ==="
FONT_DEST="/usr/local/share/fonts/sddm-astronaut-theme"
mkdir -p "$FONT_DEST"
cp -r "$SRC_DIR/Fonts"/* "$FONT_DEST/"
fc-cache -f

echo "=== 4. Configuring SDDM to use Astronaut Theme & NumLock ==="
mkdir -p /etc/sddm.conf.d

cat << 'EOF' > /etc/sddm.conf.d/kde_settings.conf
[Autologin]
Relogin=false
Session=plasma
User=

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot
Numlock=on

[Theme]
Current=sddm-astronaut-theme

[Users]
MaximumUid=60000
MinimumUid=1000
EOF

if [ -f /etc/sddm.conf ]; then
    sed -i 's/^Current=.*/Current=sddm-astronaut-theme/' /etc/sddm.conf || true
fi

echo "=== 5. Switching Display Manager to SDDM ==="
systemctl disable plasmalogin.service 2>/dev/null || true
systemctl enable sddm.service

echo "SDDM and Post-Apocalyptic Hacker theme installed successfully!"
