> [!CAUTION]
> Do not use ***system.power.switch=RETROFLAG_GPI*** in batocera.conf. Use the custom script provided below.

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

### Quick Keys:
- HDMI Detected: The script checks if the Dock is connected to a powered-on TV.
- Compare (cmp -s): This is the safety check. It prevents an infinite reboot loop. If the file is already correct, it skips the copy and the reboot.
- Reboot: Necessary because the Raspberry Pi only reads config.txt at the very first stage of the hardware boot process.

## Installation Steps

### 1. Prepare Configuration Templates
Create two specific configuration files in the `/boot` partition:
- `/boot/config_lcd.txt`: Optimized for the handheld screen (DPI timings, PWM audio).
- `/boot/config_hdmi.txt`: Optimized for the Dock (HDMI resolution, HDMI audio).

**Note:** both file are attached to this git.

**2. The detection script (Bash)**
- In Batocera, to ensure that the script runs before the EmulationStation interface launches, it must be placed it in ```/boot/```.
- Create the file: ```nano /boot/boot-custom.sh```

**3. Make the script executable**
- Give the script execution rights: ```chmod +x /boot/boot-custom.sh```

**4. Automation at startup**
- To ensure that this script runs at every boot, we will create an initialization script.
- Create the file: ```detectdock.sh```.
```
mkdir -p /userdata/system/services
nano /userdata/system/services/detectdock.sh
chmod +x /userdata/system/services/detectdock.sh
```

Unlike Recalbox, which is starting to integrate these media natively, Batocera is designed for a standard Raspberry Pi 4. For the GPi Case 2, two essential elements are missing:
- The Overlay file (.dtbo): This is the ___driver___ that tells the processor how to send the image to the GPIO pins rather than to HDMI.
- Timing configuration: Without precise settings, the screen will remain black or display white lines.

Here's how to finalize your installation so that the config_lcd.txt and config_hdmi.txt files actually work.

**5. Download the "Display Patch"**
- Get the Retroflag-specific dpi24.dtbo file.
  - Go to the official Retroflag website and download the patch for GPi Case 2.
  - Inside the archive, look for the **patch_files/overlays/** folder.
  - Copy the dpi24.dtbo file (and pwm-audio-pi-zero.dtbo if present) to the ```/boot/overlays/```folder on Batocera.
  - **Warning:** The Raspberry Pi already has a file named dpi24.dtbo by default, but it does not work with this screen. It must be overwritenby the the one from Retroflag.
 
**6. Installing the Shutdown script**
- Connect via SSH and run this command (this is the official script adapted for Batocera):
```
mkdir /userdata/RetroFlag
wget -O /userdata/RetroFlag/SafeShutdown.py "https://raw.githubusercontent.com/RetroFlag/GPiCase2-Script/main/batocera_SafeShutdown_gpi2.py"
```
