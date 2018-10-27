#!/bin/bash

CHASSIS_TYPE="Desktop"
HAS_OPTIMUS_SUPPORT=0
AC_POWER="on"

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

echo " >>> Steam launch options:"
echo " >>> STEAM_RUNTIME=$STEAM_RUNTIME"
echo " >>> LD_PRELOAD=$LD_PRELOAD"
echo " >>> vblank_mode=$vblank_mode"

if [ $CHASSIS_TYPE = "Laptop" ] && [ $AC_POWER = "on" ]; then
    echo " >>> Running Steam with the dedicated NVIDIA graphics card"
    optiprime steam
else
    echo " >>> Running Steam with the default graphics card"
    steam
fi

exit
