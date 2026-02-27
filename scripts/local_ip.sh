#!/bin/bash
# Detecta la primera interfaz activa que no sea lo ni tun0
iface=$(ip route | grep default | awk '{print $5}' | head -1)
ip_addr=$(ip -4 addr show "$iface" 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)

if [ -n "$ip_addr" ]; then
    echo " $ip_addr"
else
    echo " Sin red "
fi

