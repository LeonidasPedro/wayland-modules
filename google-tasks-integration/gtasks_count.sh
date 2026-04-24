#!/bin/bash

# Google Tasks pending count for waybar module

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/google-integration.conf"

TOKEN=$(python3 -c "
import pickle
with open('${GTASKS_TOKEN_FILE}', 'rb') as f:
    creds = pickle.load(f)
if creds.expired and creds.refresh_token:
    from google.auth.transport.requests import Request
    creds.refresh(Request())
    with open('${GTASKS_TOKEN_FILE}', 'wb') as f:
        pickle.dump(creds, f)
print(creds.token)
" 2>/dev/null)

[ -z "$TOKEN" ] && echo '{"text": "!", "tooltip": "Erro de autenticação", "class": "error"}' && exit 0

count=$(curl -s -H "Authorization: Bearer $TOKEN" \
    "${GTASKS_API}/lists/${GTASKS_LIST_ID}/tasks?showCompleted=false&showHidden=false" | \
    python3 -c "import json,sys; d=json.load(sys.stdin); print(len([t for t in d.get('items',[]) if t.get('status')=='needsAction']))" 2>/dev/null)

count=${count:-0}

if [ "$count" -gt 0 ]; then
    echo "{\"text\": \"$count\", \"tooltip\": \"$count tarefas pendentes\", \"class\": \"has-tasks\"}"
else
    echo "{\"text\": \"\", \"tooltip\": \"Sem tarefas\", \"class\": \"empty\"}"
fi
