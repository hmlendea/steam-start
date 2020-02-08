#!/bin/bash

IS_LAPTOP=0
HAS_OPTIMUS_SUPPORT=0
BATT_STATE="Unknown"
STEAM_FRAME_FORCE_CLOSE=1
ALLOW_VSYNC_OFF=0
GPU_VENDOR="intel"
STEAM_EXECUTABLE="/usr/lib/steam/steam"

# Fix for loosing focus in BPM after exiting a game
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

export VERSION_ID="1"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-/usr/lib}:/usr/lib32"

if [ -d "/sys/class/power_supply/BAT0" ]; then
    IS_LAPTOP=1
    BATT_STATE=$(cat /sys/class/power_supply/BAT0/status)

    echo "Battery state is '$BATT_STATE'"

    if [ "$GPU_VENDOR" == "nvidia" ]; then
        if [ -d "/usr/bin/bumblebeed" ]; then
            HAS_OPTIMUS_SUPPORT=1
        fi

        if [ "$BATT_STATE" == "Unknown" ] && [ $ALLOW_VSYNC_OFF == 1 ]; then
            export vblank_mode=0
            echo "Framelimit (vblank) turned off"
        else
            export vblank_mode=1
            echo "Framelimit (vblank) turned on"
        fi
    fi
fi


if [ "$STEAM_RUNTIME" != "0" ]; then
    export SSL_CERT_DIR="/etc/ssl/certs"
    #export LD_PRELOAD='/usr/$LIB/libstdc++.so.6 /usr/$LIB/libgcc_s.so.1 /usr/$LIB/libxcb.so.1 /usr/$LIB/libgpg-error.so'
    #export LD_PRELOAD='./libcxxrt.so:/usr/$LIB/libstdc++.so.6'

    echo "SSL_CERT_DIR set to '$SSL_CERT_DIR'"
    #echo "LD_PRELOAD set to '$LD_PRELOAD'"
fi

if [ $IS_LAPTOP ] && [ $HAS_OPTIMUS_SUPPORT ]; then
    if [ "$BATT_STATE" == "Unknown" ] && [ $STEAM_RUNTIME = 0 ]; then
        optiprime $STEAM_EXECUTABLE
    fi
else
    $STEAM_EXECUTABLE $* -fulldesktopres
fi

exit

