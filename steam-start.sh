#!/bin/bash

CHASSIS_TYPE="Desktop"
HAS_OPTIMUS_SUPPORT=0
AC_POWER="on"

echo " >>> Determining the settings..."

# Check if it' a LAPTOP
if [ -d "/sys/module/battery" ]; then
    CHASSIS_TYPE="Laptop"
    AC_POWER=$(acpi -a | cut -d' ' -f3 | cut -d- -f1)
fi

if [ -d "/usr/bin/bumblebeed" ]; then
    HAS_OPTIMUS_SUPPORT=1
fi

if [ $AC_POWER = "on" ]; then
    vblank_mode=0
fi

if [ -z "$STEAM_RUNTIME" ]; then
    STEAM_RUNTIME=0
fi

### PRINT THE OPTIONS

if [ $vblank_mode == 0 ]; then
    echo " >>> VSync is turned OFF"
else
    echo " >>> VSync is turned ON"
fi

if [ $STEAM_RUNTIME == 0 ]; then
    echo " >>> Using the NATIVE runtime libraries"
else
    echo " >>> Using the STEAM runtime libraries"
fi

echo " >>> LD_PRELOAD=$LD_PRELOAD"

if [ $CHASSIS_TYPE = "Laptop" ] && [ $AC_POWER = "on" ]; then
    echo " >>> Running Steam with the dedicated NVIDIA graphics card"
    optiprime steam
else
    echo " >>> Running Steam with the default graphics card"
    steam
fi

exit
