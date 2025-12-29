#!/bin/bash
case "$1" in
    start)
        /userdata/system/scripts/check_dock.sh &
        ;;
esac
exit 0