#!/bin/bash

apps=("firefox" "kitty" "thunar" "obsidian" "spotify")
icons=("" "" "" "" "")
launch_commands=(
    "firefox"
    "kitty"
    "thunar"
    "flatpak run md.obsidian.Obsidian"
    "flatpak run com.spotify.Client"
)

to_superscript() {
    echo "$1" | sed 'y/0123456789/⁰¹²³⁴⁵⁶⁷⁸⁹/'
}

count_windows() {
    local app="$1"
    hyprctl clients -j | jq --arg app "$app" '[.[] | select(.class | ascii_downcase | contains($app | ascii_downcase))] | length'
}

get_focused_app() {
    local focused_info=$(hyprctl activewindow -j)
    local focused_class=$(echo "$focused_info" | jq -r '.class | ascii_downcase')
    local focused_title=$(echo "$focused_info" | jq -r '.title | ascii_downcase')
    local focused_initial_class=$(echo "$focused_info" | jq -r '.initialClass | ascii_downcase')

    for app in "${apps[@]}"; do
        app_lower="${app,,}"
        if [[ "$focused_class" == *"$app_lower"* ]] || 
           [[ "$focused_title" == *"$app_lower"* ]] || 
           [[ "$focused_initial_class" == *"$app_lower"* ]]; then
            echo "$app"
            return
        fi
    done

    # If no match found, return the focused class as a fallback
    echo "$focused_class"
}

generate_dock_info() {
    local focused_app=$(get_focused_app)
    local dock_info="["
    for i in "${!apps[@]}"; do
        app="${apps[$i]}"
        icon="${icons[$i]}"
        launch_command="${launch_commands[$i]}"
        window_count=$(count_windows "$app")
        
        if [ $i -ne 0 ]; then
            dock_info+=","
        fi
        
        dock_info+=$(jq -n \
                      --arg app "$app" \
                      --arg icon "$icon" \
                      --arg launch "$launch_command" \
                      --argjson count "$window_count" \
                      --argjson index "$i" \
                      --arg focused "$([ "${focused_app,,}" == "${app,,}" ] && echo "true" || echo "false")" \
                      '{app: $app, icon: $icon, launch: $launch, count: $count, index: $index, focused: $focused}')
    done
    dock_info+="]"
    echo "$dock_info"
}

focus_app() {
    local app="$1"
    local address=$(hyprctl clients -j | jq -r --arg app "$app" '.[] | select(.class | ascii_downcase | contains($app | ascii_downcase)) | .address' | head -n1)
    
    if [ -n "$address" ]; then
        hyprctl dispatch focuswindow address:$address
        echo "Focused $app (address: $address)"
    else
        echo "No window found for $app"
    fi
}

case "$1" in
    "get_info")
        generate_dock_info
        ;;
    "launch")
        eval "${launch_commands[$2]} &"
        echo "Launched ${apps[$2]}"
        ;;
    "focus")
        focus_app "${apps[$2]}"
        ;;
    *)
        echo "Usage: $0 {get_info|launch <index>|focus <index>}"
        exit 1
        ;;
esac
