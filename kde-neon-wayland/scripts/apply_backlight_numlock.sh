#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (via pkexec or sudo)." >&2
    exit 1
fi

echo "=== 1. Configuring Dell BIOS via dell-wmi-sysman ==="
SYS_ATTR="/sys/class/firmware-attributes/dell-wmi-sysman/attributes"

if [ -d "$SYS_ATTR/KbdBacklightTimeoutAc" ]; then
    echo "Never" > "$SYS_ATTR/KbdBacklightTimeoutAc/current_value" 2>/dev/null || true
    echo "KbdBacklightTimeoutAc set to: $(cat $SYS_ATTR/KbdBacklightTimeoutAc/current_value 2>/dev/null)"
fi

if [ -d "$SYS_ATTR/KbdBacklightTimeoutBatt" ]; then
    echo "Never" > "$SYS_ATTR/KbdBacklightTimeoutBatt/current_value" 2>/dev/null || true
    echo "KbdBacklightTimeoutBatt set to: $(cat $SYS_ATTR/KbdBacklightTimeoutBatt/current_value 2>/dev/null)"
fi

if [ -d "$SYS_ATTR/KeyboardIllumination" ]; then
    echo "Bright" > "$SYS_ATTR/KeyboardIllumination/current_value" 2>/dev/null || true
    echo "KeyboardIllumination set to: $(cat $SYS_ATTR/KeyboardIllumination/current_value 2>/dev/null)"
fi

if [ -d "$SYS_ATTR/NumLock" ]; then
    echo "Enabled" > "$SYS_ATTR/NumLock/current_value" 2>/dev/null || true
    echo "BIOS NumLock set to: $(cat $SYS_ATTR/NumLock/current_value 2>/dev/null)"
fi

echo "=== 2. Configuring Dell Keyboard Backlight Sysfs ==="
KBD_LED="/sys/class/leds/dell::kbd_backlight"
if [ -d "$KBD_LED" ]; then
    echo 2 > "$KBD_LED/brightness" 2>/dev/null || true
    echo "Current brightness: $(cat $KBD_LED/brightness 2>/dev/null)"
    echo "Current stop_timeout: $(cat $KBD_LED/stop_timeout 2>/dev/null)"
fi

echo "=== 3. Configuring SDDM Login Screen / Lock Screen NumLock ==="
mkdir -p /etc/sddm.conf.d
cat << 'EOF' > /etc/sddm.conf.d/10-numlock.conf
[General]
Numlock=on
EOF
echo "Created /etc/sddm.conf.d/10-numlock.conf"

if [ -d /var/lib/sddm ]; then
    mkdir -p /var/lib/sddm/.config
    cat << 'EOF' > /var/lib/sddm/.config/kcminputrc
[Keyboard]
NumLock=0
EOF
    chown -R sddm:sddm /var/lib/sddm/.config 2>/dev/null || true
    echo "Configured /var/lib/sddm/.config/kcminputrc"
fi

echo "=== 4. Configuring TTY / Early Boot NumLock ==="
mkdir -p /etc/systemd/system/getty@.service.d
cat << 'EOF' > /etc/systemd/system/getty@.service.d/activate-numlock.conf
[Service]
ExecStartPre=/bin/sh -c 'setleds -D +num < /dev/%I 2>/dev/null || true'
EOF

cat << 'EOF' > /etc/systemd/system/numlock-tty.service
[Unit]
Description=Turn on NumLock on TTYs
After=systemd-user-sessions.service

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'for tty in /dev/tty[1-6]; do [ -e "$tty" ] && setleds -D +num < "$tty" 2>/dev/null || true; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

cat << 'EOF' > /etc/systemd/system/keyboard-backlight-always-on.service
[Unit]
Description=Keep Dell Keyboard Backlight Always On
After=multi-user.target sleep.target
Wants=multi-user.target sleep.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo 2 > /sys/class/leds/dell::kbd_backlight/brightness 2>/dev/null || true; echo Never > /sys/class/firmware-attributes/dell-wmi-sysman/attributes/KbdBacklightTimeoutAc/current_value 2>/dev/null || true; echo Never > /sys/class/firmware-attributes/dell-wmi-sysman/attributes/KbdBacklightTimeoutBatt/current_value 2>/dev/null || true; echo Bright > /sys/class/firmware-attributes/dell-wmi-sysman/attributes/KeyboardIllumination/current_value 2>/dev/null || true'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target sleep.target
EOF

echo "=== 5. Enabling Services ==="
systemctl daemon-reload
systemctl enable --now numlock-tty.service
systemctl enable --now keyboard-backlight-always-on.service

echo "=== 6. Configuring System-wide KDE defaults ==="
mkdir -p /etc/xdg
if [ -f /etc/xdg/kcminputrc ]; then
    kwriteconfig6 --file /etc/xdg/kcminputrc --group Keyboard --key NumLock 0 2>/dev/null || true
else
    cat << 'EOF' > /etc/xdg/kcminputrc
[Keyboard]
NumLock=0
EOF
fi

echo "All configurations completed successfully!"
