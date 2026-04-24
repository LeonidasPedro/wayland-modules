#!/bin/bash

# Google Calendar desktop notifications
# Runs in background, alerts before events

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/google-integration.conf"

while true; do
    events=$(gcalcli --nocolor agenda today 30 --nodeclined --details=end --details=url --tsv 2>/dev/null | tail -n +2)

    while IFS=$'\t' read -r date start_time title location; do
        [ -z "$date" ] && continue

        event_time=$(date -d "$date $start_time" +%s 2>/dev/null || echo 0)
        current_time=$(date +%s)
        time_diff=$((event_time - current_time))
        remind_seconds=$((GCAL_NOTIFY_MINUTES * 60))

        if [ "$time_diff" -gt 0 ] && [ "$time_diff" -lt "$remind_seconds" ] && [ "$time_diff" -gt $((remind_seconds - 60)) ]; then
            notify-send \
                --urgency=normal \
                --app-name="Google Calendar" \
                --icon="appointment-soon" \
                "Evento em ${GCAL_NOTIFY_MINUTES} minutos" \
                "$title"
        fi
    done <<< "$events"

    sleep 60
done
