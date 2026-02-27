# ⌨️ Guía Completa de Atajos de Teclado

Todos los atajos están definidos en `config/sxhkd/sxhkdrc`.  
**Win** = Tecla Super (Windows/Command)

---

## Aplicaciones

| Atajo | Acción |
|---|---|
| **Win + Return** | Abrir terminal (Kitty) |
| **Win + Shift + Return** | Terminal de emergencia (xterm) |
| **Win + D** | Launcher de aplicaciones (Rofi) |
| **Win + Escape** | Recargar configuración de sxhkd |

## Gestión de Ventanas

| Atajo | Acción |
|---|---|
| **Win + W** | Cerrar ventana |
| **Win + Shift + W** | Matar ventana forzosamente |
| **Win + M** | Alternar modo monocle (una ventana ocupa todo) |
| **Win + G** | Intercambiar ventana con la más grande |

## Estados de Ventana

| Atajo | Acción |
|---|---|
| **Win + T** | Tiling (mosaico) |
| **Win + Shift + T** | Pseudo-tiling |
| **Win + S** | Floating (flotante) |
| **Win + F** | Fullscreen (pantalla completa) |

## Flags de Ventana

| Atajo | Acción |
|---|---|
| **Win + Ctrl + M** | Marcar ventana (para mover) |
| **Win + Ctrl + X** | Bloquear ventana (no se puede cerrar) |
| **Win + Ctrl + Y** | Sticky (visible en todos los workspaces) |
| **Win + Ctrl + Z** | Privado (no se intercambia) |

## Navegación entre Ventanas

| Atajo | Acción |
|---|---|
| **Win + H / ←** | Enfocar ventana a la izquierda |
| **Win + J / ↓** | Enfocar ventana abajo |
| **Win + K / ↑** | Enfocar ventana arriba |
| **Win + L / →** | Enfocar ventana a la derecha |
| **Win + Shift + H/J/K/L** | Mover/intercambiar ventana en esa dirección |
| **Win + C** | Siguiente ventana en el workspace |
| **Win + Shift + C** | Ventana anterior en el workspace |
| **Win + Tab** | Último workspace visitado |

## Workspaces

| Atajo | Acción |
|---|---|
| **Win + [1-9]** | Ir al workspace N |
| **Win + Shift + [1-9]** | Mover ventana al workspace N |
| **Win + [** | Workspace anterior |
| **Win + ]** | Workspace siguiente |

## Preselección

Permite elegir **dónde** se abrirá la siguiente ventana antes de abrirla.

| Atajo | Acción |
|---|---|
| **Win + Ctrl + ←/↓/↑/→** | Preseleccionar dirección |
| **Win + Ctrl + [1-9]** | Establecer proporción (1=10% ... 9=90%) |
| **Win + Ctrl + Space** | Cancelar preselección del nodo |
| **Win + Ctrl + Shift + Space** | Cancelar preselección del escritorio |

## Redimensionar Ventanas

| Atajo | Acción |
|---|---|
| **Win + Alt + ←** | Redimensionar hacia la izquierda |
| **Win + Alt + ↓** | Redimensionar hacia abajo |
| **Win + Alt + ↑** | Redimensionar hacia arriba |
| **Win + Alt + →** | Redimensionar hacia la derecha |

## Sistema

| Atajo | Acción |
|---|---|
| **Win + Alt + Q** | Salir de BSPWM |
| **Win + Alt + R** | Reiniciar BSPWM |
| **Win + Shift + X** | Bloquear pantalla (betterlockscreen) |
| **Win + Shift + E** | Power menu (apagar/reiniciar/bloquear/salir) |
| **Print** | Screenshot pantalla completa → `~/Pictures/` |
| **Win + Print** | Screenshot área seleccionada → `~/Pictures/` |

## Kitty (Terminal)

| Atajo | Acción |
|---|---|
| **Ctrl + Shift + Enter** | Nuevo split dentro de Kitty |
| **Ctrl + Shift + R** | Redimensionar splits |
| **Ctrl + Shift + Z** | Zoom en terminal activa |
| **Ctrl + Shift + T** | Nueva pestaña |
| **Ctrl + Shift + Alt + T** | Renombrar pestaña |
| **Ctrl + Shift + ← / →** | Cambiar de pestaña |

## Atajos ZSH (fzf)

| Atajo | Acción |
|---|---|
| **Ctrl + R** | Buscar en historial de comandos |
| **Ctrl + T** | Buscar archivos/rutas |
| **Alt + C** | Cambiar de directorio |

## Funciones Custom

| Comando | Acción |
|---|---|
| `settarget <IP>` | Establecer target (se muestra en Polybar) |
| `cleartarget` | Limpiar target |
| `mkt <nombre>` | Crear directorios para CTF (content/exploits/nmap/scripts) |
| `extractPorts <file>` | Extraer puertos de nmap y copiar al clipboard |