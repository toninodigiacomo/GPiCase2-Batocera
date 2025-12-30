#!/bin/bash

case "$1" in
    start)
        BOOT_DIR="/boot"
        CONFIG_FILE="$BOOT_DIR/config.txt"
        CONFIG_LCD="$BOOT_DIR/config_lcd.txt"
        CONFIG_HDMI="$BOOT_DIR/config_hdmi.txt"

        # Remonter /boot en lecture-écriture
        mount -o remount,rw $BOOT_DIR

        # Détection HDMI
        HDMI_STATUS=$(cat /sys/class/drm/card0-HDMI-A-1/status)

        if [ "$HDMI_STATUS" == "connected" ]; then
            if ! cmp -s "$CONFIG_FILE" "$CONFIG_HDMI"; then
                cp "$CONFIG_HDMI" "$CONFIG_FILE"
                reboot
            fi
        else
            if ! cmp -s "$CONFIG_FILE" "$CONFIG_LCD"; then
                cp "$CONFIG_LCD" "$CONFIG_FILE"
                reboot
            fi
        fi
        ;;
esac
