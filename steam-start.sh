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

[ $(lspci | grep "VGA" | grep "NVIDIA" -c) -ge 1 ] && GPU_VENDOR="nvidia"

echo "GPU Vendor: ${GPU_VENDOR}"

if [ -d "/sys/class/power_supply/BAT0" ]; then
    IS_LAPTOP=1
    BATT_STATE=$(cat /sys/class/power_supply/BAT0/status)

    echo "Battery state is '$BATT_STATE'"

    if [ "$GPU_VENDOR" == "nvidia" ]; then
        if [ -f "/usr/bin/bumblebeed" ]; then
            echo "OPTIMUS support detected..."
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

[ ! -z "${STEAM_RUNTIME}" ] && echo "STEAM_RUNTIME=${STEAM_RUNTIME}"

if [ "$STEAM_RUNTIME" != "0" ]; then
    export SSL_CERT_DIR="/etc/ssl/certs"
    #export LD_PRELOAD='/usr/$LIB/libstdc++.so.6 /usr/$LIB/libgcc_s.so.1 /usr/$LIB/libxcb.so.1 /usr/$LIB/libgpg-error.so'
    #export LD_PRELOAD='./libcxxrt.so:/usr/$LIB/libstdc++.so.6'

    echo "SSL_CERT_DIR set to '$SSL_CERT_DIR'"
    #echo "LD_PRELOAD set to '$LD_PRELOAD'"
fi

if [ $IS_LAPTOP ] && [ $HAS_OPTIMUS_SUPPORT ] && [ "$BATT_STATE" != "Discharging" ] && [ $STEAM_RUNTIME = 0 ]; then
    echo optiprime
    optiprime $STEAM_EXECUTABLE
else
    echo steam
    $STEAM_EXECUTABLE $* -fulldesktopres
fi

exit
