-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ◈ AUTOSTART (Core Daemons, Shell & Look-and-Feel)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

hl.on("hyprland.start", function()
    local home = os.getenv("HOME")
    local autostart_list = {
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_THEME XCURSOR_THEME XCURSOR_SIZE",
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_THEME XCURSOR_THEME XCURSOR_SIZE",
        "/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1",
        "swww-daemon",
        "hypridle",
        "playerctld",
        "wl-paste --type text --watch cliphist store",
        "wl-paste --type image --watch cliphist store",
        "command -v easyeffects >/dev/null 2>&1 && systemctl --user enable --now easyeffects",
        home .. "/.config/hypr/scripts/volume_listener.sh",
        "gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'",
        "gsettings set org.gnome.desktop.interface cursor-size 24",
        "gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'",
        "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'",
        "hyprctl setcursor Bibata-Modern-Classic 24",
        "quickshell -p " .. home .. "/.config/hypr/scripts/quickshell/Shell.qml",
        "python3 " .. home .. "/.config/hypr/scripts/quickshell/focustime/focus_daemon.py &",
        "kdeconnect-indicator &",
        "xsettingsd &",
        "python3 " .. home .. "/.config/hypr/scripts/gesture_daemon.py &",
        "sleep 1 && hyprctl dismissnotify",
    }

    for _, cmd in ipairs(autostart_list) do
        hl.exec_cmd(cmd)
    end
end)
