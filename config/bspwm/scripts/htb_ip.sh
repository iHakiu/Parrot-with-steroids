#!/bin/bash

# Script para mostrar la IP de la VPN de HackTheBox
# Usado en Polybar

# Buscar interfaz tun (VPN)
VPN_IP=$(ip -4 addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)

if [ -z "$VPN_IP" ]; then
    # No hay conexión a VPN
    echo "%{F#ff0000}  Disconnected%{F-}"
else
    # Conectado a VPN
    echo "%{F#00ff00}  $VPN_IP%{F-}"
fi
