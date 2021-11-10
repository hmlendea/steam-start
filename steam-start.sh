#!/bin/bash


#####################################
### Retrieve hardware information ###
#####################################

CHASSIS_TYPE="Desktop"
BATT_STATE="Unknown"
HAS_OPTIMUS_SUPPORT=false
ALLOW_VSYNC_OFF=false

if [ -d "/sys/module/battery" ] \
&& [ -d "/proc/acpi/button/lid" ]; then
    CHASSIS_TYPE="Laptop"
    BATTERY_STATE=$(cat /sys/class/power_supply/BAT0/status)
fi

if [ -f "/usr/bin/lscpu" ]; then
    CPU_MODEL=$(lscpu | \
        grep "^Model name:" | \
        awk -F: '{print $2}')
elif [ -f "/proc/cpuinfo" ]; then
    CPU_MODEL=$(cat "/proc/cpuinfo" | \
        grep "^model name" | \
        awk -F: '{print $2}')
fi

CPU_MODEL=$(echo "${CPU_MODEL}" | head -n 1 | sed \
    -e 's/^\s*\(.*\)\s*$/\1/g' \
    -e 's/(TM)//g' \
    -e 's/(R)//g' \
    -e 's/ [48][ -][Cc]ore//g' \
    -e 's/ \(CPU\|Processor\)//g' \
    -e 's/@ .*//g' \
    -e 's/^[ \t]*//g' \
    -e 's/[ \t]*$//g')

echo "${CPU_MODEL}" | grep -q "AMD" && CPU_FAMILY="AMD"
echo "${CPU_MODEL}" | grep -q "Intel" && CPU_FAMILY="Intel"

CPU_MODEL=$(echo "${CPU_MODEL}" | sed 's/\(AMD\|Intel\) //g')
CPU_NAME=$(echo "${CPU_FAMILY} ${CPU_MODEL}" | sed 's/^\s*//g')

if [ -f "/usr/bin/lspci" ]; then
    LSPCI_VGA_PRIMARY="$(lspci | grep VGA | tail -n 1)"
    echo "${LSPCI_VGA_PRIMARY}" | grep -q "AMD"      && GPU_FAMILY="AMD"
    echo "${LSPCI_VGA_PRIMARY}" | grep -q "Intel"    && GPU_FAMILY="Intel"
    echo "${LSPCI_VGA_PRIMARY}" | grep -q "NVIDIA"   && GPU_FAMILY="Nvidia"
    
    GPU_MODEL=$(echo "${LSPCI_VGA_PRIMARY}" | sed 's/^[^\[]*\[\([a-zA-Z0-9 ]*\)].*/\1/g')
    GPU_NAME=$(echo "${GPU_FAMILY} ${GPU_MODEL}" | sed 's/^\s*//g')
fi

if [[ "${GPU_FAMILY}" == "Nvidia" ]]; then
    if [ -f "/usr/bin/bumblebeed" ]; then
        HAS_OPTIMUS_SUPPORT=true
    fi
fi

### Print hardware information
echo "Detected hardware:"
echo " - Chassis: ${CHASSIS_TYPE}"
[[ "${CHASSIS_TYPE}" == "Laptop" ]] && echo " - Battery: ${BATTERY_STATE}"
echo " - CPU: ${CPU_NAME}"
echo " - GPU: ${GPU_NAME}"
[[ "${GPU_FAMILY}" == "Nvidia" ]] && echo " - Supports OPTIMUS: ${HAS_OPTIMUS_SUPPORT}"
[ -n "${STEAM_RUNTIME}" ] && echo "Steam Runtime: ${STEAM_RUNTIME}"

### Functions

function set_var() {
    local VARIABLE_NAME="${1}"
    local VARIABLE_VALUE="${@:2}"
    local CURRENT_VALUE=""

    eval CURRENT_VALUE=\$"${VARIABLE_NAME}"

    [[ "${CURRENT_VALUE}" == "${VARIABLE_VALUE}" ]] && return

    export ${VARIABLE_NAME}="${VARIABLE_VALUE}"

    echo "Variable '${VARIABLE_NAME}' set to '${VARIABLE_VALUE}'"
}

### Set environment variables

if [[ "${CHASSIS_TYPE}" == "Laptop" ]]; then
    if [ "$BATTERY_STATE" == "Unknown" ] && ${ALLOW_VSYNC_OFF}; then
        set_var vblank_mode 0
    else
        set_var vblank_mode 1
    fi
fi

set_var SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS 0 # Fix for loosing focus in BPM after exiting a game
set_var VERSION_ID 1
set_var LD_LIBRARY_PATH "${LD_LIBRARY_PATH:-/usr/lib}:/usr/lib32"

if [ "$STEAM_RUNTIME" != "0" ]; then
    set_var SSL_CERT_DIR "/etc/ssl/certs"

    # Fixes some games (e.g. Insurgency)
    set_var LD_PRELOAD '/usr/$LIB/libstdc++.so.6 /usr/$LIB/libgcc_s.so.1 /usr/$LIB/libxcb.so.1 /usr/$LIB/libgpg-error.so'

    #set_var LD_PRELOAD './libcxxrt.so:/usr/$LIB/libstdc++.so.6'
fi

if [ "${CPU_FAMILY}" == "Intel" ] && [ "${CPU_MODEL}" == "Core i7-3610QM" ]; then
    echo "DXVK does not work on this CPU"
    set_var PROTON_USE_WINED3D 1
fi

### Run Steam

if ${HAS_OPTIMUS_SUPPORT} && [ ${BATTERY_STATE} != "Discharging" ]; then # && [ $STEAM_RUNTIME = 0 ]; then
    optiprime $STEAM_EXECUTABLE
else
    $STEAM_EXECUTABLE $* -fulldesktopres
fi

exit
