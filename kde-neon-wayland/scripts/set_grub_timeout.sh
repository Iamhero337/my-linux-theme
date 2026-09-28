#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (via sudo or pkexec)." >&2
    exit 1
fi

GRUB_FILE="/etc/default/grub"

if [ -f "$GRUB_FILE" ]; then
    cp "$GRUB_FILE" "${GRUB_FILE}.bak"
    sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' "$GRUB_FILE"
    sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' "$GRUB_FILE"

    if grep -q "^GRUB_RECORDFAIL_TIMEOUT=" "$GRUB_FILE"; then
        sed -i 's/^GRUB_RECORDFAIL_TIMEOUT=.*/GRUB_RECORDFAIL_TIMEOUT=5/' "$GRUB_FILE"
    else
        echo "GRUB_RECORDFAIL_TIMEOUT=5" >> "$GRUB_FILE"
    fi

    echo "Updated $GRUB_FILE successfully:"
    grep -E "GRUB_TIMEOUT|GRUB_RECORDFAIL_TIMEOUT" "$GRUB_FILE"

    echo "Running update-grub..."
    update-grub
    echo "GRUB timeout successfully set to 5 seconds."
else
    echo "Error: $GRUB_FILE not found!" >&2
    exit 1
fi
