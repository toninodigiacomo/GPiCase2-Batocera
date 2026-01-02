import RPi.GPIO as GPIO
import os
import time

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(26, GPIO.IN, pull_up_down=GPIO.PUD_UP) # Power Pin
GPIO.setup(27, GPIO.OUT, initial=GPIO.HIGH)       # Power Enable

while True:
    if GPIO.input(26) == GPIO.LOW:
        os.system("batocera-es-swissknife --emukill")
        time.sleep(1)
        os.system("poweroff")
    time.sleep(0.5)
