#!/bin/bash

# Script para mostrar la IP del target actual
# Usado en Polybar
# Se actualiza con el comando 'settarget <IP>'

TARGET_FILE="/tmp/target"

if [ -f "$TARGET_FILE" ]; then
    TARGET_IP=$(cat "$TARGET_FILE")
    if [ ! -z "$TARGET_IP" ]; then
        echo "%{F#ff6b6b}  $TARGET_IP%{F-}"
        exit 0
    fi
fi

# No hay target establecido
echo "%{F#6b6b6b}  No target%{F-}"
