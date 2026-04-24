# GPU Mode Switcher for Waybar (HyDe)

Módulo para alternar entre GPU integrada e Nvidia via envycontrol, com indicador visual de "reinício pendente".

## Requisitos

- **envycontrol** (`sudo pacman -S envycontrol` ou AUR)
- **sudoers NOPASSWD** para envycontrol (ver seção abaixo)
- **libnotify** para notificações (`notify-send`)

## Arquivos e destinos

| Arquivo backup | Destino |
|---|---|
| `gpu_switch.sh` | `~/.config/waybar/scripts/gpu_switch.sh` (chmod +x) |
| `gpu_toggle.sh` | `~/.config/waybar/scripts/gpu_toggle.sh` (chmod +x) |
| `gpu.jsonc` | `~/.config/waybar/modules/gpu.jsonc` |

## Configuração no HyDe

1. **config.ctl** — adicionar `custom/gpu` ao grupo direito:
   ```
   ...( privacy tray battery custom/gpu idle_inhibitor  )...
   ```

2. **Regenerar waybar**:
   ```bash
   rm ~/.config/waybar/config.jsonc && wbarconfgen.sh
   ```

3. **Sudoers NOPASSWD** — criar `/etc/sudoers.d/waybar-envycontrol`:
   ```bash
   echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/envycontrol" | sudo tee /etc/sudoers.d/waybar-envycontrol
   sudo chmod 440 /etc/sudoers.d/waybar-envycontrol
   ```

## Como funciona

- **Estado atual:** `envycontrol --query`
- **Flag de reinício pendente:** `/tmp/gpu_pending_restart` (limpo automaticamente no reboot)
- **Clique:** alterna entre `integrated` ↔ `nvidia` (`hybrid` vira `nvidia`)
- **Ícone de atenção** (`󰀦`) aparece após trocar e desaparece sozinho após reinício
- **Signal 21** — waybar é avisado após a troca para refresh imediato

## Ícones (Nerd Fonts)

| Modo | Ícone |
|---|---|
| Integrada | `󰾅` |
| Nvidia | `󰾲` |
| Híbrida | `󰣘` |
| Atenção (pendente) | `󰀦` |

## Classes CSS disponíveis

- `.integrated`
- `.nvidia`
- `.hybrid`
- `.pending` (adicionada quando há troca pendente — use para piscar/destacar)
