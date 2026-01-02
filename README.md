# GPi Case 2 - Auto Dock Detection & Safe Shutdown for Batocera

> [!INFORMATION]
> This project provides a reliable way to automatically switch between LCD (handheld) and HDMI (dock) configurations on Batocera for the Retroflag GPi Case 2, using the hardware GPIO 18 pin for detection. It also includes a Safe Shutdown script.

## Concept & Workflow
The system detects the HDMI connection status very early in the boot process and swaps the `config.txt` file accordingly to ensure the correct display driver (DPI for LCD or KMS for HDMI) is loaded.

```
         +---------------------------------------+
         |           POWER ON (Cold Boot)        |
         +---------------------------------------+
                             |
                             |
         +------------------ v ------------------+
         |    (Early Init - S01detectdock)       |
         +---------------------------------------+
                             |
                             |
              +------------- v -------------+
              |   Is HDMI Cable Detected?   |
              |  (Check /sys/class/drm/...) |
              +-----------------------------+
                |                         |
          [ YES | DOCKED ]           [ NO | HANDHELD ]
                |                         |
+-------------- v ---------+   +--------- v --------------+
|  Compare Current Config  |   |  Compare Current Config  |
|    with config_hdmi.txt  |   |    with config_lcd.txt   |
+--------------------------+   +--------------------------+
                |                         |
       +------- v -------+       +------- v -------+
       |   Is it Equal?  |       |   Is it Equal?  |
       +-----------------+       +-----------------+
           |         |             |         |
        [ YES ]    [ NO ]       [ YES ]    [ NO ]
           |         |             |         |
           |   +---- v ------+     |   +---- v ------+
           |   | Copy HDMI   |     |   | Copy LCD    |
           |   | File to     |     |   | File to     |
           |   | config.txt  |     |   | config.txt  |
           |   +-------------+     |   +-------------+
           |        |              |        |
           |   +--- v -------+     |   +--- v -------+
           |   |   REBOOT    |     |   |   REBOOT    |
           |   +-------------+     |   +-------------+
           |                       | 
  +------- v --------------------- v ------------------------+
  |               LAUNCH EMULATION STATION                   |
  |           (Display is now correctly set)                 |
  +----------------------------------------------------------+
```

## Quick Keys:
- HDMI Detected: The script checks if the Dock is connected to a powered-on TV.
- Compare (cmp -s): This is the safety check. It prevents an infinite reboot loop. If the file is already correct, it skips the copy and the reboot.
- Reboot: Necessary because the Raspberry Pi only reads config.txt at the very first stage of the hardware boot process.

## Features
- Zero-latency detection: Uses hardware Pin 18 (Dock sensor) instead of slow USB polling.
- Smart Switch: Only reboots if the configuration file needs to be changed.
- Safe Shutdown: Protects your SD card by closing emulators properly before powering off.

## File Structure
- **/boot/config_lcd.txt** Handheld display configuration.
- **/boot/config_hdmi.txt** Dock/TV display configuration.
- **/boot/boot-custom.sh** The logic script that swaps config.txt.
- **/etc/init.d/S01detectdock** The service that triggers the check at boot.
- **/userdata/system/shutdown_gpi.py** Python script for the power button.
- **/userdata/system/custom.sh** Starts the shutdown script.

## Installation
### 1. Prepare Configuration Files
Ensure you have two template files in your /boot partition:
  - **config_lcd.txt** (DPI settings enabled)
  - **config_hdmi.txt** (KMS driver enabled, hdmi_force_hotplug=1)

### 2. Setup the Boot Switch Script
Create **/boot/boot-custom.sh**

```nano /boot/boot-custom.sh```

```
bin/bash
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
```

```chmod +x /boot/boot-custom.sh```

### 3. Register the Boot Service

Create /etc/init.d/S01detectdock:
Bash

#!/bin/bash
case "$1" in
    start)
        [ -f /boot/boot-custom.sh ] && /boot/boot-custom.sh start
        ;;
esac

chmod +x /etc/init.d/S01detectdock
### 4. Setup Safe Shutdown

Create /userdata/system/shutdown_gpi.py:
Python

import RPi.GPIO as GPIO
import os
import time

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(26, GPIO.IN, pull_up_down=GPIO.PUD_UP) # Power Pin
GPIO.setup(27, GPIO.OUT, initial=GPIO.HIGH)      # Power Enable

while True:
    if GPIO.input(26) == GPIO.LOW:
        os.system("batocera-es-swissknife --emukill")
        time.sleep(1)
        os.system("poweroff")
    time.sleep(0.5)

Enable it in /userdata/system/custom.sh:
Bash

python3 /userdata/system/shutdown_gpi.py &

chmod +x /userdata/system/custom.sh
5. Final Step: Save Changes

Run this command to make the /etc/ changes permanent:
Bash

batocera-save-overlay
