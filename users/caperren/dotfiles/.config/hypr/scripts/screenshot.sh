#!/usr/bin/env bash

# Unashamedly taken from: https://www.reddit.com/r/hyprland/comments/13ivh0c/comment/jkgk65k
# Small edits made for my particular needs

# Flags:

# r: region
# s: screen
#
# c: clipboard
# f: file
# i: interactive

# p: pixel

# Example hyprland bindings
#bind = CTRL, SUPER, ALT, PRINT, exec, ~/.config/hypr/scripts/screenshot.sh
#bind = , PRINT, exec, ~/.config/hypr/scripts/screenshot.sh rc
#bind = SUPER, PRINT, exec, ~/.config/hypr/scripts/screenshot.sh rf
#bind = CTRL, PRINT, exec, ~/.config/hypr/scripts/screenshot.sh ri
#bind = SHIFT, PRINT, exec, ~/.config/hypr/scripts/screenshot.sh sc
#bind = SUPER SHIFT, PRINT, exec, ~/.config/hypr/scripts/screenshot.sh sf
#bind = CTRL SHIFT, PRINT, exec, ~/.config/hypr/scripts/screenshot.sh si
#bind = ALT, PRINT, exec, ~/.config/hypr/scripts/screenshot.sh p

screenshotPath=~/Pictures/screenshots

hyprpicker_launch(){
  # Start hyprpicker with screen render (freeze), no fancy, no zoom
  # We're just using this to lock the screen in place for grim ingest
  hyprpicker -r -n -z -d >/dev/null 2>&1 &
  sleep 0.5
}

hyprpicker_kill(){
  killall hyprpicker >/dev/null 2>&1
}

trap hyprpicker_kill EXIT

generate_filename(){
  # Make sure screenshots path exists first
  if [ ! -d "$screenshotPath" ]; then
    mkdir -p "$screenshotPath"
  fi

  echo "$screenshotPath/$(date +%Y-%m-%d_%H-%M-%S).png"
}

active_screen_grim_region(){
  hyprctl -j monitors | jq -r '.[] | select(.focused) | "\(.x),\(.y) \(.width)x\(.height)"' -
}

grim_from_region() {
  local filename="${1:-}"
  local region="${2:-}"

  hyprpicker_launch

  # Get region of screen to capture, if not passed in
  if [ -z "$region" ]; then
    region=$(slurp -b '#000000b0' -c '#00000000') || exit 1
  fi

  # Start grim while screen is still frozen, kill hyprpicker, and pass through data
  if [ -z "$filename" ]; then
    grim -g "$region" - | {
      hyprpicker_kill || true
      cat
    }
  else
    grim -g "$region" "$filename" | {
      hyprpicker_kill || true
      cat
    }
  fi
}

if [[ $1 == rc ]]; then
    grim_from_region | wl-copy
    notify-send 'Copied to Clipboard' Screenshot

elif [[ $1 == rf ]]; then
    grim_from_region "$(generate_filename)"
    notify-send 'Screenshot Taken' "$filename"

elif [[ $1 == ri ]]; then
    grim_from_region | swappy -f - -o "$(generate_filename)"

elif [[ $1 == sc ]]; then
    grim_from_region "" "$(active_screen_grim_region)" | wl-copy
    notify-send 'Copied to Clipboard' Screenshot

elif [[ $1 == sf ]]; then
    grim_from_region "$(generate_filename)" "$(active_screen_grim_region)"
    notify-send 'Screenshot Taken' "$filename"

elif [[ $1 == si ]]; then
    grim_from_region "" "$(active_screen_grim_region)" | swappy -f - -o "$(generate_filename)"

elif [[ $1 == p ]]; then
    color=$(hyprpicker -a -r)
    wl-copy "$color"
    notify-send 'Copied to Clipboard' "$color"

else
  notify-send 'Screenshot Shortcuts' "Print:\t\t\tRegion to clip
Super+Print:\t\tRegion to file
Ctrl+Print:\t\tRegion to editor
Shift+Print:\t\t\Screen to clip
Shift+Super+Print:\tScreen to file
Ctrl+Shift+Print:\tScreen to editor
Alt+Print:\t\tColor picker to clip" -t 20000

fi