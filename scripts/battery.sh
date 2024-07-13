#!/bin/bash

battery_status=$(cat /sys/class/power_supply/BAT0/status)
battery_percent=$(cat /sys/class/power_supply/BAT0/capacity)

if [ $battery_percent -ge 80 ]; then
    icon=""
elif [ $battery_percent -ge 60 ]; then
    icon=""
elif [ $battery_percent -ge 40 ]; then
    icon=""
elif [ $battery_percent -ge 20 ]; then
    icon=""
else
    icon=""
fi

color="#a9b1d6"  # default color

if [ $battery_percent -ge 80 ]; then
    color="#73daca"  # green (highest priority)
elif [ "$battery_status" = "Charging" ]; then
    color="#7aa2f7"  # blue (second priority)
elif [ $battery_percent -le 15 ]; then
    color="#f7768e"  # red (lowest priority)
fi

if [ "$battery_status" = "Charging" ]; then
    status="Charging"
else
    status="Discharging"
fi

echo '{"icon": "'"$icon"'", "percentage": '"$battery_percent"', "status": "'"$status"'", "color": "'"$color"'"}'
