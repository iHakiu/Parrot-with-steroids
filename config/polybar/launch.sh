#!/usr/bin/env bash

# Matar instancias anteriores
killall -q polybar

# Esperar a que mueran
while pgrep -u $UID -x polybar > /dev/null; do sleep 0.1; done

# Separador en el log para identificar cada arranque
echo "---" | tee -a /tmp/polybar.log

# Lanzar todas las barras — disown las desvincula del terminal
polybar local_ip    --config="$HOME/.config/polybar/config.ini" 2>&1 | tee -a /tmp/polybar.log & disown
polybar htb_ip      --config="$HOME/.config/polybar/config.ini" 2>&1 | tee -a /tmp/polybar.log & disown
polybar workspaces  --config="$HOME/.config/polybar/config.ini" 2>&1 | tee -a /tmp/polybar.log & disown
polybar target      --config="$HOME/.config/polybar/config.ini" 2>&1 | tee -a /tmp/polybar.log & disown
polybar date        --config="$HOME/.config/polybar/config.ini" 2>&1 | tee -a /tmp/polybar.log & disown

echo "Polybar lanzado"
