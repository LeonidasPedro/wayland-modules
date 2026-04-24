# Google Calendar + Waybar (HyDe)

Integração do Google Calendar com Waybar usando `gcalcli` + `nextmeeting` + `rofi`.

## Requisitos

- **gcalcli** e **nextmeeting** instalados via `pipx` (não use pacman, conflita):
  ```bash
  pipx install gcalcli nextmeeting
  ```
- **rofi** (já vem no HyDe)
- Autenticação do Google Calendar:
  ```bash
  ~/.local/bin/gcalcli --config-folder ~/.config/gcalcli init
  ```

## Arquivos e onde vão

| Arquivo backup | Destino |
|---|---|
| `nextmeeting.jsonc` | `~/.config/waybar/modules/nextmeeting.jsonc` |
| `calendar_popup.sh` | `~/.config/waybar/scripts/calendar_popup.sh` (chmod +x) |
| `gcalcli_notify.sh` | `~/.config/waybar/scripts/gcalcli_notify.sh` (chmod +x) |
| `calendar.rasi` | `~/.config/rofi/calendar.rasi` |
| `config.toml` | `~/.config/nextmeeting/config.toml` |

## Configuração no HyDe

1. **config.ctl** — adicionar `custom/nextmeeting` ao grupo central:
   ```
   ...|( custom/nextmeeting clock )|...
   ```

2. **Regenerar waybar**:
   ```bash
   rm ~/.config/waybar/config.jsonc && wbarconfgen.sh
   ```

3. **hyprland.conf** — iniciar notificações automáticas:
   ```
   exec-once = ~/.config/waybar/scripts/gcalcli_notify.sh
   ```

## Como funciona

- Módulo `custom/nextmeeting` mostra próximo evento no centro da barra (📅)
- Atualiza a cada 30s
- Clicar abre popup rofi (tema HyDe) listando eventos dos próximos 7 dias
- Clicar em um evento abre ele direto no Google Calendar
- Notificações desktop 15 min antes de cada evento (via script gcalcli_notify)

## Troubleshooting

- **"No meeting" mas tenho eventos**: Verifique qual calendário está no `nextmeeting.jsonc` (`--calendar=...`). Liste com `gcalcli list`.
- **Erro "ModuleNotFoundError: gcalcli"**: Conflito entre versão pacman e pipx. Use sempre `~/.local/bin/gcalcli` ou garanta que `~/.local/bin` está antes de `/usr/bin` no PATH.
- **Rofi com caracteres quebrados**: O script já filtra códigos ANSI com `sed`.
- **Tema rofi não aplica**: Verifique se `~/.config/rofi/theme.rasi` existe (vem do HyDe). O `calendar.rasi` depende dele para as cores.

## Dependências de tema

O `calendar.rasi` importa `~/.config/rofi/theme.rasi` do HyDe, que define:
- `@main-bg`, `@main-fg`, `@main-br`, `@select-bg`, `@select-fg`

Se o HyDe atualizar e mudar esses nomes, só ajustar no `calendar.rasi`.
