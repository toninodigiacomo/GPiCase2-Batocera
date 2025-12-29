> [!CAUTION]
> Do not use ***system.power.switch=RETROFLAG_GPI***

### Here is the concept :
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
           |         |             |         |
           |    +--- v -------+    |    +--- v -------+
           |    |   REBOOT    |    |    |   REBOOT    |
           |    +-------------+    |    +-------------+
           |                       | 
  +------- v --------------------- v ------------------------+
  |               LAUNCH EMULATION STATION                   |
  |           (Display is now correctly set)                 |
  +----------------------------------------------------------+
```

#### Quick Key:
- HDMI Detected: The script checks if the Dock is connected to a powered-on TV.
- Compare (cmp -s): This is the safety check. It prevents an infinite reboot loop. If the file is already correct, it skips the copy and the reboot.
- Reboot: Necessary because the Raspberry Pi only reads config.txt at the very first stage of the hardware boot process.
