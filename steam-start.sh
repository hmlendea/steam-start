#!/bin/bash

IS_LAPTOP=false
HAS_OPTIMUS_SUPPORT=false
BATT_STATE="Unknown"
STEAM_FRAME_FORCE_CLOSE=1
ALLOW_VSYNC_OFF=0
GPU_VENDOR="intel"
CPU_VENDOR=$(cat /proc/cpuinfo | grep "^vendor_id" | head -n 1 | awk -F: '{print $2}' | sed 's/ //g' | sed 's/^Genuine//g')
CPU_MODEL_NUMBER=$(cat /proc/cpuinfo | grep "^model" | head -n 1 | awk -F: '{print $2}' | sed 's/ //g')
STEAM_EXECUTABLE="/usr/lib/steam/steam"

# Fix for loosing focus in BPM after exiting a game
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

export VERSION_ID="1"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-/usr/lib}:/usr/lib32"

[ $(lspci | grep "VGA" | grep "NVIDIA" -c) -ge 1 ] && GPU_VENDOR="nvidia"

echo "GPU Vendor: ${GPU_VENDOR}"

function set_var() {
    VARIABLE_NAME="${1}"
    VARIABLE_VALUE="${@:2}"

    export ${VARIABLE_NAME}="${VARIABLE_VALUE}"

    echo "Variable '${VARIABLE_NAME}' set to '${VARIABLE_VALUE}'"
}

if [ -d "/sys/class/power_supply/BAT0" ]; then
    IS_LAPTOP=true
    BATT_STATE=$(cat /sys/class/power_supply/BAT0/status)

    echo "Battery state is '$BATT_STATE'"

    if [ "$GPU_VENDOR" == "nvidia" ]; then
        if [ -f "/usr/bin/bumblebeed" ]; then
            echo "OPTIMUS support detected..."
            HAS_OPTIMUS_SUPPORT=true
        fi

        if [ "$BATT_STATE" == "Unknown" ] && [ $ALLOW_VSYNC_OFF == 1 ]; then
            set_var vblank_mode 0
        else
            set_var vblank_mode 1
        fi
    fi
fi

[ ! -z "${STEAM_RUNTIME}" ] && echo "STEAM_RUNTIME=${STEAM_RUNTIME}"

if [ "$STEAM_RUNTIME" != "0" ]; then
    set_var SSL_CERT_DIR "/etc/ssl/certs"

    # Fixes some games (e.g. Insurgency)
    set_var LD_PRELOAD '/usr/$LIB/libstdc++.so.6 /usr/$LIB/libgcc_s.so.1 /usr/$LIB/libxcb.so.1 /usr/$LIB/libgpg-error.so'

    #set_var LD_PRELOAD './libcxxrt.so:/usr/$LIB/libstdc++.so.6'
fi

if [ "${CPU_VENDOR}" == "Intel" ] && [ ${CPU_MODEL_NUMBER} -le 58 ]; then
    echo "DXVK disabled for this CPU (${CPU_VENDOR} model ${CPU_MODEL_NUMBER})"
    set_var PROTON_USE_WINED3D 1
fi

if ${IS_LAPTOP} && ${HAS_OPTIMUS_SUPPORT} && [ ${BATT_STATE} != "Discharging" ]; then # && [ $STEAM_RUNTIME = 0 ]; then
    optiprime $STEAM_EXECUTABLE
else
    $STEAM_EXECUTABLE $* -fulldesktopres
fi

exit
