> [!CAUTION]
> Do not use ***system.power.switch=RETROFLAG_GPI***

###Here is the concept :
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
+------------- v ----------+  +--------- v -------------+
|  Compare Current Config  |  |  Compare Current Config  |
|    with config_hdmi.txt  |  |    with config_lcd.txt   |
+--------------------------+  +--------------------------+
               |                         |
      +------- v -------+       +------- v -------+
      |   Is it Equal?  |       |   Is it Equal?  |
      +-----------------+       +-----------------+
           |         |             |         |
        [ YES ]    [ NO ]       [ YES ]    [ NO ]
          |          |             |           |
          |    +-------------+     |     +-------------+
          |    | Copy HDMI   |     |     | Copy LCD    |
          |    | File to     |     |     | File to     |
          |    | config.txt  |     |     | config.txt  |
          |    +-------------+     |     +-------------+
          |          |             |           |
          |    +-------------+     |     +-------------+
          |    |   REBOOT    |     |     |   REBOOT    |
          |    +-------------+     |     +-------------+
          |                        |
  +------ v ---------------------- v ------------------------+
  |               LAUNCH EMULATION STATION                   |
  |           (Display is now correctly set)                 |
  +----------------------------------------------------------+
```


