#!/usr/bin/env bash
# Toggle KDE Plasma Clipboard (plasmawindowed org.kde.plasma.clipboard)

# 1. If an instance is already running, toggle it off
if pgrep -f "plasmawindowed org.kde.plasma.clipboard" >/dev/null 2>&1; then
    pkill -f "plasmawindowed org.kde.plasma.clipboard"
    exit 0
fi

# 2. Sync latest clips from cliphist to Klipper database quickly
if [ -f "$HOME/.config/hypr/scripts/sync_cliphist_to_klipper.py" ]; then
    python3 "$HOME/.config/hypr/scripts/sync_cliphist_to_klipper.py" </dev/null >/dev/null 2>&1
fi

# 3. Launch plasmawindowed clipboard in a detached session
setsid -f plasmawindowed org.kde.plasma.clipboard >/dev/null 2>&1
