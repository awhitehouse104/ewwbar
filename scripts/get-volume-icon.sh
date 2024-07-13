#!/bin/bash

volume=$(pamixer --get-volume)
muted=$(pamixer --get-mute)

if [[ $muted == "true" ]]; then
    echo ""
elif [[ $volume -ge 50 ]]; then
    echo ""
else
    echo ""
fi
