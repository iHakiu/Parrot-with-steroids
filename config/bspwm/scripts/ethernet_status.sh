#!/bin/bash

# Script para mostrar la IP de la interfaz ethernet/wifi activa
# Usado en Polybar

# Obtener la interfaz activa (excluyendo lo, tun, docker, etc.)
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)

if [ -z "$INTERFACE" ]; then
    echo " Disconnected"
    exit 0
fi

# Obtener IP de la interfaz
IP=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

if [ -z "$IP" ]; then
    echo " No IP"
else
    echo " $IP"
fi
