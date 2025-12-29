#!/bin/bash

BOOT_DIR="/boot"
CONFIG_CURRENT="$BOOT_DIR/config.txt"
CONFIG_LCD="$BOOT_DIR/config_lcd.txt"
CONFIG_HDMI="$BOOT_DIR/config_hdmi.txt"

# On remonte la partition de boot en lecture/écriture
mount -o remount,rw $BOOT_DIR

# Détection de la présence d'un écran HDMI
# On utilise /sys/class/drm car c'est plus fiable sur CM4 que tvservice
HDMI_STATUS=$(cat /sys/class/drm/card0-HDMI-A-1/status)

if [ "$HDMI_STATUS" == "connected" ]; then
    echo "--- Dock HDMI détecté ---"
    # On compare le fichier actuel avec le modèle HDMI (via checksum)
    if ! cmp -s "$CONFIG_CURRENT" "$CONFIG_HDMI"; then
        cp "$CONFIG_HDMI" "$CONFIG_CURRENT"
        echo "Configuration HDMI appliquée. Redémarrage..."
        reboot
    fi
else
    echo "--- Mode Portable détecté ---"
    # On compare le fichier actuel avec le modèle LCD
    if ! cmp -s "$CONFIG_CURRENT" "$CONFIG_LCD"; then
        cp "$CONFIG_LCD" "$CONFIG_CURRENT"
        echo "Configuration LCD appliquée. Redémarrage..."
        reboot
    fi
fi