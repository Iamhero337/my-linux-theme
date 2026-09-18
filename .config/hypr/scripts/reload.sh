#!/usr/bin/env bash
qs -p ~/.config/hypr/scripts/quickshell/Shell.qml ipc call main forceReload 2>/dev/null || true
hyprctl reload 2>/dev/null || true
notify-send -u low -t 1500 -i view-refresh "Reloaded" "Hyprland and Quickshell reloaded successfully."
