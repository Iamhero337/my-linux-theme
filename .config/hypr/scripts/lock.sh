#!/usr/bin/env bash

# Source and initialize quickshell dynamic caching
source "$(dirname "${BASH_SOURCE[0]}")/caching.sh"
qs_ensure_cache "lock"

if command -v quickshell &>/dev/null && [ -f "$HOME/.config/hypr/scripts/quickshell/Lock.qml" ]; then
    quickshell -p "$HOME/.config/hypr/scripts/quickshell/Lock.qml" || hyprlock
elif command -v hyprlock &>/dev/null; then
    hyprlock
fi
