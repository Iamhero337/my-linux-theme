#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ◈ MY-LINUX-THEME INSTALLER
#  Customized Hyprland + Quickshell Desktop Environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

DOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀 Installing My Linux Theme"
echo "  Base: Serpantinum by ilyamiro (Optimized & Customized)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p "$BACKUP_DIR"
echo "📁 Backup directory created at: $BACKUP_DIR"

# 1. Backup and copy configs
CONFIGS=("hypr" "kitty" "rofi" "waybar" "swayosd" "matugen" "cava")

for cfg in "${CONFIGS[@]}"; do
    if [ -d "$HOME/.config/$cfg" ]; then
        echo "📦 Backing up ~/.config/$cfg -> $BACKUP_DIR/$cfg"
        mv "$HOME/.config/$cfg" "$BACKUP_DIR/"
    fi
    echo "🔗 Installing ~/.config/$cfg..."
    cp -r "$DOTDIR/.config/$cfg" "$HOME/.config/"
done

# 2. Install systemd user service & autostart
mkdir -p "$HOME/.config/systemd/user" "$HOME/.config/autostart" "$HOME/.local/share"

if [ -f "$DOTDIR/.config/systemd/user/gesture-daemon.service" ]; then
    cp "$DOTDIR/.config/systemd/user/gesture-daemon.service" "$HOME/.config/systemd/user/"
    systemctl --user daemon-reload || true
    systemctl --user enable --now gesture-daemon.service || true
fi

if [ -f "$DOTDIR/.config/autostart/org.kde.kdeconnect.daemon.desktop" ]; then
    cp "$DOTDIR/.config/autostart/org.kde.kdeconnect.daemon.desktop" "$HOME/.config/autostart/"
fi

if [ -d "$DOTDIR/.local/share/hypr-shortcuts" ]; then
    cp -r "$DOTDIR/.local/share/hypr-shortcuts" "$HOME/.local/share/"
fi

# 3. Set executable permissions on scripts
chmod +x "$HOME/.config/hypr/scripts/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/hypr/scripts/"*.py 2>/dev/null || true
chmod +x "$HOME/.config/hypr/scripts/quickshell/volume/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/hypr/scripts/quickshell/volume/"*.py 2>/dev/null || true
chmod +x "$HOME/.config/hypr/scripts/quickshell/watchers/"*.sh 2>/dev/null || true

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Installation Complete!"
echo "  To load changes immediately, reload Hyprland: hyprctl reload"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
