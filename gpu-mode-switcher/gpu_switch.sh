#!/bin/bash

# GPU mode status for waybar custom/gpu module
# Queries envycontrol, reports current mode + pending-restart state

PENDING_FLAG="/tmp/gpu_pending_restart"

mode=$(envycontrol --query 2>/dev/null)

case "$mode" in
    integrated)
        icon="󰾅"
        label="Integrada"
        ;;
    nvidia)
        icon="󰾲"
        label="Nvidia"
        ;;
    hybrid)
        icon="󰾲"
        label="Híbrida"
        ;;
    *)
        icon="󰟃"
        label="Desconhecido"
        mode="unknown"
        ;;
esac

if [[ -f "$PENDING_FLAG" ]]; then
    text="${icon} ${label} 󰀦"
    tooltip="Modo atual: ${label}\n<b>Reinicie o computador</b> para aplicar a mudança"
    class="${mode} pending"
else
    text="${icon} ${label}"
    tooltip="Modo atual: ${label}\nClique para alternar entre integrada e Nvidia"
    class="${mode}"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s","alt":"%s"}\n' \
    "$text" "$tooltip" "$class" "$mode"
