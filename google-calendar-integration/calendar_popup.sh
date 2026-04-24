#!/bin/bash

# Google Calendar popup — HyDe style
# Lists upcoming events, click opens in browser

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/google-integration.conf"

tmpfile=$(mktemp)
trap "rm -f $tmpfile /tmp/calendar_display.txt" EXIT

tsv_data=$(gcalcli agenda today "$(date -d "+${GCAL_DAYS_AHEAD} days" '+%Y-%m-%d')" --tsv --details=url 2>/dev/null | tail -n +2)

if [ -z "$tsv_data" ]; then
    rofi -dmenu \
        -theme "${ROFI_THEME}" \
        -mesg "  Google Calendar — Sem eventos nos próximos ${GCAL_DAYS_AHEAD} dias  " \
        -no-custom \
        -theme-str 'inputbar { enabled: false; }' \
        -i <<< ""
    exit 0
fi

echo "$tsv_data" | awk -F'\t' -v tmpfile="$tmpfile" '
{
    start_date = $1
    start_time = $2
    html_link  = $5
    title      = $7

    cmd_day = "LC_TIME=pt_BR.UTF-8 date -d \"" start_date "\" \"+%a\" | tr [:lower:] [:upper:]"
    cmd_day | getline dia_semana
    close(cmd_day)

    cmd_date = "date -d \"" start_date "\" \"+%d/%m\""
    cmd_date | getline dia
    close(cmd_date)

    if (start_time != "") {
        line = "󰃭  " dia_semana " " dia "  󰥔 " start_time "    " title
    } else {
        line = "󰃭  " dia_semana " " dia "  󰃶 Dia todo     " title
    }

    print line
    print line "|" html_link >> tmpfile
}' > /tmp/calendar_display.txt

selected=$(cat /tmp/calendar_display.txt | rofi -dmenu \
    -theme "${ROFI_THEME}" \
    -mesg "  Google Calendar — Próximos ${GCAL_DAYS_AHEAD} dias  " \
    -no-custom \
    -theme-str 'inputbar { enabled: false; }' \
    -i)

if [ -n "$selected" ]; then
    url=$(grep -F "$selected|" "$tmpfile" | head -1 | cut -d'|' -f2)
    if [ -n "$url" ]; then
        xdg-open "$url" &
    fi
fi
