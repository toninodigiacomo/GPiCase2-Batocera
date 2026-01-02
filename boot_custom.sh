#!/bin/bash
BOOT_DIR="/boot"
CONFIG_FILE="$BOOT_DIR/config.txt"
CONFIG_LCD="$BOOT_DIR/config_lcd.txt"
CONFIG_HDMI="$BOOT_DIR/config_hdmi.txt"

mount -o remount,rw $BOOT_DIR

# Check Dock status via GPIO 18
PIN_STATE=$(python3 -c "import RPi.GPIO as GPIO; GPIO.setmode(GPIO.BCM); GPIO.setup(18, GPIO.IN, pull_up_down=GPIO.PUD_DOWN); print(GPIO.input(18))" 2>/dev/null)

if [ "$PIN_STATE" == "1" ]; then
    # DOCK MODE
    if ! cmp -s "$CONFIG_FILE" "$CONFIG_HDMI"; then
        cp -f "$CONFIG_HDMI" "$CONFIG_FILE" && sync && reboot -f
    fi
else
    # HANDHELD MODE
    if ! cmp -s "$CONFIG_FILE" "$CONFIG_LCD"; then
        cp -f "$CONFIG_LCD" "$CONFIG_FILE" && sync && reboot -f
    fi
fi
