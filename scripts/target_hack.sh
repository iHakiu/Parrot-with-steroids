#!/bin/bash
if [ -f /tmp/target ] && [ -s /tmp/target ]; then
    echo "$(cat /tmp/target)"
else
    echo "Sin target"
fi

