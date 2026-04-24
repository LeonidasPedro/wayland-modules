# Pomodoro Timer for Waybar (HyDe)

Um timer Pomodoro integrado ao Waybar, feito para HyDe.

Baseado em: https://github.com/Tejas242/pomodoro-for-waybar

## Requisitos

- **Python 3** (padrão no HyDe)
- **notify-send** (para notificações desktop)
- **rofi** (já vem no HyDe)

## Arquivos e onde vão

| Arquivo backup | Destino |
|---|---|
| `pomodoro_timer.py` | `~/.local/bin/pomodoro_timer.py` (chmod +x) |
| `pomodoro.jsonc` | `~/.config/waybar/modules/pomodoro.jsonc` |
| `pomodoro.css` | `~/.config/waybar/styles/pomodoro.css` (opcional) |

## Configuração no HyDe

1. **config.ctl** — adicionar `custom/pomodoro` ao grupo central:
   ```
   ...|( custom/gtasks custom/nextmeeting custom/pomodoro clock )|...
   ```

2. **Regenerar waybar**:
   ```bash
   rm ~/.config/waybar/config.jsonc && wbarconfgen.sh
   ```

3. **CSS styling** (opcional) — copiar `pomodoro.css` para `~/.config/waybar/styles/` se quiser cores temáticas:
   ```bash
   cp pomodoro.css ~/.config/waybar/styles/
   ```

## Como funciona

- **Estado:** Persiste em `~/.cache/pomodoro_state.json`
- **Ícone:** Muda conforme a fase (inativo, trabalho, pausa, pausa longa, pausado)
- **Cliques:**
  - **Click esquerdo:** Toggle (start/pausa)
  - **Click direito:** Skip (pular para próxima fase)
  - **Click meio:** Reset (voltar ao inativo)
- **Notificações:** Desktop alerts ao completar trabalho/pausa
- **Ciclo:** 25min trabalho → 5min pausa → 15min pausa longa (a cada 4 pomodoros)

## Cores (CSS)

- **Inativo:** Cinza
- **Trabalho:** Vermelho (#ff6b6b)
- **Pausa curta:** Verde (#7eca9c)
- **Pausa longa:** Azul (#89b4fa)
- **Pausado:** Rosa itálico (#f5c2e7)

## Customização

Editar `pomodoro_timer.py` linhas 10-12 para ajustar durações:
```python
POMODORO = 25 * 60      # Trabalho (segundos)
SHORT_BREAK = 5 * 60    # Pausa curta
LONG_BREAK = 15 * 60    # Pausa longa
```
