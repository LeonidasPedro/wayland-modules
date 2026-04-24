#!/bin/bash

# Google Tasks popup — HyDe style
# List tasks, mark complete, add new

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/google-integration.conf"

get_token() {
    python3 -c "
import pickle
with open('${GTASKS_TOKEN_FILE}', 'rb') as f:
    creds = pickle.load(f)
if creds.expired and creds.refresh_token:
    from google.auth.transport.requests import Request
    creds.refresh(Request())
    with open('${GTASKS_TOKEN_FILE}', 'wb') as f:
        pickle.dump(creds, f)
print(creds.token)
" 2>/dev/null
}

add_task_input() {
    rofi -dmenu \
        -theme "${ROFI_THEME}" \
        -mesg "  Nova tarefa  " \
        -p "" \
        -theme-str 'mainbox { children: [ "message", "inputbar" ]; }' \
        -theme-str 'inputbar { enabled: true; padding: 0.5em 0.8em; background-color: transparent; text-color: @main-fg; border-radius: 0.4em; }' \
        -theme-str 'entry { enabled: true; placeholder: "Digite o título..."; background-color: transparent; text-color: @main-fg; cursor: text; }' \
        -theme-str 'prompt { enabled: false; }' \
        -theme-str 'window { height: 8em; }' \
        <<< ""
}

create_task() {
    local title="$1"
    local payload
    payload=$(python3 -c "import json,sys; print(json.dumps({'title': sys.argv[1]}))" "$title")
    local result
    result=$(curl -s -X POST \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "${GTASKS_API}/lists/${GTASKS_LIST_ID}/tasks")

    if echo "$result" | grep -q '"title"'; then
        notify-send "Google Tasks" "Adicionada: $title" -i dialog-information
    else
        notify-send "Google Tasks" "Erro ao adicionar" -u critical
    fi
}

TOKEN=$(get_token)
if [ -z "$TOKEN" ]; then
    notify-send "Google Tasks" "Erro: não foi possível obter token" -u critical
    exit 1
fi

# Fetch pending tasks
tmpfile=$(mktemp)
trap "rm -f $tmpfile" EXIT

curl -s -H "Authorization: Bearer $TOKEN" \
    "${GTASKS_API}/lists/${GTASKS_LIST_ID}/tasks?showCompleted=false&showHidden=false" | \
    python3 -c "
import json, sys
data = json.load(sys.stdin)
items = [t for t in data.get('items', []) if t.get('status') == 'needsAction']
for t in items:
    title = t.get('title', '').strip()
    tid = t.get('id', '')
    if title:
        print(f'{title}\t{tid}')
" > "$tmpfile" 2>/dev/null

task_count=$(wc -l < "$tmpfile" | tr -d ' ')

if [ "$task_count" -eq 0 ]; then
    action=$(printf "  Nova tarefa" | rofi -dmenu \
        -theme "${ROFI_THEME}" \
        -mesg "  Google Tasks — Sem tarefas pendentes  " \
        -no-custom \
        -theme-str 'inputbar { enabled: false; }' \
        -theme-str 'window { height: 8em; }' \
        -i)

    if echo "$action" | grep -q "Nova tarefa"; then
        new_title=$(add_task_input)
        [ -n "$new_title" ] && create_task "$new_title"
    fi
    exit 0
fi

# Build list: tasks + separator + add new
display=""
while IFS=$'\t' read -r title tid; do
    display+="  $title"$'\n'
done < "$tmpfile"
display+="───────────────────"$'\n'
display+="  Nova tarefa"

selected=$(echo -n "$display" | rofi -dmenu \
    -theme "${ROFI_THEME}" \
    -mesg "  Google Tasks — $task_count pendentes  " \
    -no-custom \
    -theme-str 'inputbar { enabled: false; }' \
    -i)

[ -z "$selected" ] && exit 0

# Separator ignored
echo "$selected" | grep -q "────" && exit 0

# Add new task
if echo "$selected" | grep -q "Nova tarefa"; then
    new_title=$(add_task_input)
    [ -n "$new_title" ] && create_task "$new_title"
    exit 0
fi

# Task selected — action submenu
task_title=$(echo "$selected" | sed 's/^[[:space:]]*//')
task_id=$(grep "^$task_title	" "$tmpfile" | head -1 | cut -f2)

[ -z "$task_id" ] && exit 0

action=$(printf "✓  Marcar concluída\n  Abrir no Google Tasks" | rofi -dmenu \
    -theme "${ROFI_THEME}" \
    -mesg "  $task_title  " \
    -no-custom \
    -theme-str 'inputbar { enabled: false; }' \
    -theme-str 'window { height: 8em; }' \
    -i)

[ -z "$action" ] && exit 0

if echo "$action" | grep -q "concluída"; then
    result=$(curl -s -X PATCH \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"status": "completed"}' \
        "${GTASKS_API}/lists/${GTASKS_LIST_ID}/tasks/$task_id")

    if echo "$result" | grep -q '"completed"'; then
        notify-send "Google Tasks" "Concluída: $task_title" -i dialog-information
    else
        notify-send "Google Tasks" "Erro ao completar" -u critical
    fi
elif echo "$action" | grep -q "Abrir"; then
    xdg-open "https://tasks.google.com/" &
fi
