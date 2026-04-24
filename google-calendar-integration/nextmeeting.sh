#!/bin/bash

# Google Calendar next meeting for waybar module

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/google-integration.conf"

raw=$(nextmeeting --waybar --calendar="${GCAL_CALENDAR}" 2>/dev/null)

if [ -z "$raw" ]; then
    echo '{"text": "", "tooltip": "Calendário indisponível", "class": "error"}'
    exit 0
fi

meeting_text=$(echo "$raw" | python3 -c "
import json, sys
d = json.load(sys.stdin)
text = d.get('text', '').strip()
tooltip = d.get('tooltip', '').strip()
result = tooltip if tooltip else text
print(result if result else 'Sem reuniões hoje')
" 2>/dev/null)

[ -z "$meeting_text" ] && meeting_text="Sem reuniões hoje"

tooltip_json=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$meeting_text")

echo "{\"text\": \"\", \"tooltip\": ${tooltip_json}, \"class\": \"meeting\"}"
