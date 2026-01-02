#!/bin/bash
case "$1" in
    start)
        [ -f /boot/boot-custom.sh ] && /boot/boot-custom.sh start
        ;;
esac
