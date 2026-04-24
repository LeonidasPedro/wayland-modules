#!/bin/bash

# GPU mode toggle for waybar custom/gpu module
# Swaps between integrated and nvidia via envycontrol (requires sudoers NOPASSWD)

PENDING_FLAG="/tmp/gpu_pending_restart"

current=$(envycontrol --query 2>/dev/null)

case "$current" in
    integrated) target="nvidia" ;;
    nvidia)     target="integrated" ;;
    hybrid)     target="nvidia" ;;
    *)
        notify-send -u critical "GPU Toggle" "Modo atual desconhecido: $current"
        exit 1
        ;;
esac

if sudo -n envycontrol -s "$target" >/dev/null 2>&1; then
    touch "$PENDING_FLAG"
    notify-send -u normal "GPU Mode" "Trocado para <b>${target}</b>. Reinicie o computador para aplicar."
    pkill -RTMIN+21 waybar
else
    notify-send -u critical "GPU Toggle" "Falha ao alternar para ${target}.\nVerifique sudoers NOPASSWD para envycontrol."
    exit 1
fi
