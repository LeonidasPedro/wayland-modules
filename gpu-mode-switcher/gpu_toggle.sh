#!/bin/bash

# GPU mode toggle for waybar custom/gpu module
# Swaps between integrated and hybrid via envycontrol (requires sudoers NOPASSWD)

PENDING_FLAG="/tmp/gpu_pending_restart"
LOCK_FILE="/tmp/gpu_toggle.lock"

(
    flock -n 9 || { notify-send -u low "GPU Toggle" "Operação em progresso, aguarde..."; exit 0; }

    current=$(envycontrol --query 2>/dev/null)

    case "$current" in
        integrated) target="hybrid" ;;
        hybrid)     target="integrated" ;;
        nvidia)     target="integrated" ;;
        *)
            notify-send -u critical "GPU Toggle" "Modo atual desconhecido: $current"
            exit 1
            ;;
    esac

    if sudo envycontrol -s "$target"; then
        touch "$PENDING_FLAG"
        notify-send -u normal "GPU Mode" "Trocado para <b>${target}</b>. Reinicie o computador para aplicar."
        pkill -RTMIN+21 waybar
    else
        notify-send -u critical "GPU Toggle" "Falha ao alternar para ${target}.\nVerifique sudoers NOPASSWD para envycontrol."
        exit 1
    fi
) 9>"$LOCK_FILE"
