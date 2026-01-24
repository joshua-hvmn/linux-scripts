#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark"

# Check if the file exists first
if [ ! -f "$FILE" ]; then
    echo "Error: COSMIC theme file not found. Are you using the COSMIC desktop?"
    exit 1
fi
MSG=""
if [ "$(cat "$FILE")" = "true" ]; then
    echo "false" > "$FILE"
    TITLE="Light Mode"
#    MSG="Day mode activated"
    ICON="weather-clear"
else
    echo "true" > "$FILE"
    TITLE="Dark Mode"
#    MSG="Night mode activated"
    ICON="weather-clear-night-symbolic"
fi

# The GDBus Notification Call
gdbus call --session \
    --dest org.freedesktop.Notifications \
    --object-path /org/freedesktop/Notifications \
    --method org.freedesktop.Notifications.Notify \
    "Theme Switched" \
    0 \
    "$ICON" \
    "$TITLE" \
    "$MSG" \
    [] \
    "{'transient': <true>}" \
    2000 >/dev/null 2>&1