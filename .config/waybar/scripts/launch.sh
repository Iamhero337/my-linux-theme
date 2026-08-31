#!/usr/bin/env bash

# Terminate already running bar instances
killall -9 waybar waybar.real 2>/dev/null || true
pkill -9 -x waybar 2>/dev/null || true
pkill -9 -x waybar.real 2>/dev/null || true

# Wait until all waybar instances are gone
while pgrep -x "waybar" >/dev/null || pgrep -x "waybar.real" >/dev/null; do
    sleep 0.05
done

# Launch Waybar
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css >/dev/null 2>&1 &
disown
