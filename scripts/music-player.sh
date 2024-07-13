#!/bin/bash

get_status() {
    playerctl status 2> /dev/null || echo "Stopped"
}

get_icon() {
    status=$(get_status)
    if [[ $status == "Playing" ]]; then
        echo ""
    else
        echo ""
    fi
}

get_title() {
    status=$(get_status)
    if [[ $status == "Playing" || $status == "Paused" ]]; then
        playerctl metadata --format "{{ title }}"
    else
        echo "No player active"
    fi
}

case "$1" in
    icon)
        get_icon
        ;;
    title)
        get_title
        ;;
    status)
        get_status
        ;;
    *)
        echo "{\"icon\": \"$(get_icon)\", \"title\": \"$(get_title)\", \"status\": \"$(get_status)\"}"
        ;;
esac
