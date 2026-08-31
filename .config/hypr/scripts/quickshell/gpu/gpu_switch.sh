#!/usr/bin/env bash
TARGET_MODE="$1"

if [ -n "$TARGET_MODE" ]; then
    case "$TARGET_MODE" in
        nvidia|hybrid|integrated)
            sudo envycontrol -s "$TARGET_MODE" >/tmp/envycontrol_switch.log 2>&1
            notify-send -i "video-display" "GPU Graphics Mode" "Switched to ${TARGET_MODE^^} mode.\nPlease reboot or re-login to apply hardware mux." -u normal
            ;;
        performance|balanced|power-saver)
            powerprofilesctl set "$TARGET_MODE" 2>/dev/null || true
            notify-send -i "power-profile" "Power Profile" "Active profile: ${TARGET_MODE}" -u low
            ;;
        nvidia-settings)
            hyprctl dispatch exec "nvidia-settings" 2>/dev/null || nvidia-settings &
            ;;
    esac
fi
