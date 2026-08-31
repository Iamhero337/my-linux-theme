#!/usr/bin/env bash

# Reload Kitty instances
killall -USR1 kitty 2>/dev/null || killall -USR1 .kitty-wrapped 2>/dev/null || true


# Reload CAVA
if pgrep -x "cava" > /dev/null; then
    # Rebuild the final config file from the base and newly generated colors
    cat ~/.config/cava/config_base ~/.config/cava/colors > ~/.config/cava/config 2>/dev/null
    # Tell CAVA to reload the config
    killall -USR1 cava
fi

# Reload SwayNC CSS styling dynamically without killing the daemon
if command -v swaync-client &> /dev/null; then
    timeout 1 swaync-client -rs 2>/dev/null || true
fi

# Restarting swayosd.service is currently the ONLY way to reload its CSS.
# WARNING: This is what causes the sound problems. Because swayosd-server 
# forcefully reconnects to an audio server on boot, restarting it causes audio drops/pops.
if systemctl --user is-active --quiet swayosd.service; then
    systemctl --user restart swayosd.service &
fi

# Reload Waybar CSS styling dynamically
if pgrep -x "waybar" > /dev/null || pgrep -x "waybar.real" > /dev/null; then
    killall -SIGUSR2 waybar 2>/dev/null || killall -SIGUSR2 waybar.real 2>/dev/null || true
fi


# ==============================================================================
# GTK Live-Reload Hack
# Rapidly toggles the global theme to force GTK3 and GTK4 apps to flush 
# their caches and read the newly generated Matugen CSS.
# ==============================================================================
if command -v gsettings &> /dev/null; then
    # GTK3 apps
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    sleep 0.05
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
    
    # GTK4 / Libadwaita apps
    gsettings set org.gnome.desktop.interface color-scheme 'default'
    sleep 0.05
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
fi

wait
