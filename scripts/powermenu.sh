#!/usr/bin/env bash
# Powermenu — apagado, reinicio, bloqueo, cierre de sesión

# Opciones con iconos Nerd Font
shutdown="󰐥 Apagar"
reboot="󰜉 Reiniciar"
lock="󰌾 Bloquear"
logout="󰍃 Cerrar sesión"
cancel="󰅙 Cancelar"

# Lanzar rofi en modo dmenu
chosen=$(echo -e "$lock\n$logout\n$reboot\n$shutdown\n$cancel" | \
    rofi -dmenu \
         -p "Sistema" \
         -theme ~/.config/rofi/config.rasi \
         -theme-str 'window { width: 20%; y-offset: -60; } listview { lines: 5; }' \
         -no-custom)

# Ejecutar la opción elegida
case "$chosen" in
    "$shutdown")  systemctl poweroff ;;
    "$reboot")    systemctl reboot ;;
    "$lock")      betterlockscreen -l blur ;;
    "$logout")    bspc quit ;;
    "$cancel"|"") exit 0 ;;
esac
