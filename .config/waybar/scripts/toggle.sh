#!/usr/bin/env bash

if pgrep -x "waybar" >/dev/null || pgrep -x "waybar.real" >/dev/null; then
    killall -9 waybar waybar.real 2>/dev/null || true
    pkill -9 -x waybar 2>/dev/null || true
    pkill -9 -x waybar.real 2>/dev/null || true
else
    ~/.config/waybar/scripts/launch.sh
fi
