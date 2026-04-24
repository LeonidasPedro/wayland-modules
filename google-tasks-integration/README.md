# Google Tasks + Waybar (HyDe)

Integração do Google Tasks com Waybar usando API REST direta + `rofi`.

## Requisitos

- **gtasks-cli** instalado via `pipx` (apenas para auth inicial):
  ```bash
  pipx install gtasks-cli
  ```
- **rofi** (já vem no HyDe)
- **python3** com `google-auth` (vem com gtasks-cli)
- Credenciais Google em `~/.gtasks/credentials.json` (reusadas do gcalcli)
- Token em `~/.gtasks/token.pickle`
- Autenticação:
  ```bash
  ~/.local/bin/gtasks auth
  ```

## Arquivos e onde vão

| Arquivo backup | Destino |
|---|---|
| `gtasks.jsonc` | `~/.config/waybar/modules/gtasks.jsonc` |
| `gtasks_popup.sh` | `~/.config/waybar/scripts/gtasks_popup.sh` (chmod +x) |
| `gtasks_count.sh` | `~/.config/waybar/scripts/gtasks_count.sh` (chmod +x) |

## Configuração no HyDe

1. **config.ctl** — adicionar `custom/gtasks` ao grupo central:
   ```
   ...|( custom/gtasks custom/nextmeeting clock )|...
   ```

2. **Regenerar waybar**:
   ```bash
   rm ~/.config/waybar/config.jsonc && wbarconfgen.sh
   ```

3. **Google Tasks API** — deve estar habilitada no Google Cloud Console:
   ```
   https://console.developers.google.com/apis/api/tasks.googleapis.com/overview
   ```

## Como funciona

- Módulo `custom/gtasks` mostra contagem de tarefas pendentes (✓ N)
- Atualiza a cada 60s via `gtasks_count.sh` (API REST direta)
- Clicar abre popup rofi (tema HyDe) listando tarefas pendentes
- Clicar em uma tarefa: submenu com "Marcar concluída" ou "Abrir no Google Tasks"
- Opção "Nova tarefa" no fim da lista: abre input rofi para digitar título
- Tudo via Google Tasks REST API (criar, completar, listar)
- Reutiliza o tema `calendar.rasi` do rofi (mesma integração do Calendar)

## Credenciais

O `credentials.json` foi gerado a partir do OAuth do gcalcli:
```bash
python3 -c "
import pickle, json
with open('$HOME/.local/share/gcalcli/oauth', 'rb') as f:
    d = pickle.load(f)
creds = {'installed': {'client_id': d.client_id, 'client_secret': d.client_secret,
    'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
    'token_uri': d.token_uri,
    'redirect_uris': ['http://localhost']}}
with open('$HOME/.gtasks/credentials.json', 'w') as f:
    json.dump(creds, f, indent=2)
"
```

## Dependências

- Reutiliza `~/.config/rofi/calendar.rasi` (da integração Google Calendar)
- Depende de `~/.config/rofi/theme.rasi` do HyDe para cores
- LIST_ID hardcoded nos scripts: `your-list-id` ("Minhas tarefas")
