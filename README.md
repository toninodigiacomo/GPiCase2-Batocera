> [!CAUTION]
> Do not use ***system.power.switch=RETROFLAG_GPI***

## Here is the concept :
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

1. Preparing the files
- First, create two configuration templates in the ```/boot``` folder. Log in via SSH and prepare files:
  - The LCD file: Create ```/boot/config_lcd.txt``` with appropriate settings for the laptop screen (including DPI settings and the Retroflag patch).
  - The HDMI file: Create ```/boot/config_hdmi.txt``` with the appropriate settings for the Dock (TV resolution, HDMI audio, etc.).

2. The detection script (Bash)
- In Batocera, to ensure that the script runs before the EmulationStation interface launches, it must be placed it in ```/userdata/system/scripts/```.
- Create the file: nano ```/userdata/system/scripts/check_dock.sh```

3. Make the script executable
- Give the script execution rights: ```chmod +x /userdata/system/scripts/check_dock.sh```

4. Automation at startup
- To ensure that this script runs at every boot, we will create an SXX initialization script.
- Create the file: ```nano /etc/init.d/S01detectdock``` (Note: If /etc/ is read-only, use the /userdata/system/custom.sh folder or create a symbolic link).

