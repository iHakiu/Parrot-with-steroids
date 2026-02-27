#!/bin/bash
ip_addr=$(ip -4 addr show tun0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)

if [ -n "$ip_addr" ]; then
    echo " $ip_addr"
else
    echo " VPN OFF "
fi
