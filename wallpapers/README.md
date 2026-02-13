# Wallpapers

Esta carpeta contiene los fondos de pantalla de tu setup.

## 📋 Cómo añadir tu wallpaper

```bash
# Copiar tu wallpaper favorito
cp ~/fondos/tu_wallpaper.jpg ~/dotfiles/wallpapers/fondo.jpg
```

## ⚙️ Configuración

El wallpaper se establece automáticamente durante la instalación mediante:
- El script `install.sh` copia el wallpaper a `~/fondos/`
- BSPWM ejecuta `feh --bg-fill ~/fondos/fondo.jpg` al iniciar

## 🎨 Cambiar wallpaper después de la instalación

### Método 1: Comando directo
```bash
feh --bg-fill ~/fondos/fondo.jpg
```

### Método 2: Modificar bspwmrc
Edita `~/.config/bspwm/bspwmrc` y cambia la línea:
```bash
feh --bg-fill ~/fondos/TU_WALLPAPER.jpg &
```

## 💡 Múltiples wallpapers

Si quieres añadir más wallpapers al repositorio:

1. Cópialos a esta carpeta
2. Crea un script para cambiar entre ellos:

```bash
#!/bin/bash
# ~/dotfiles/scripts/change_wallpaper.sh

WALLPAPERS_DIR=~/fondos
WALLPAPER=$(ls $WALLPAPERS_DIR | shuf -n 1)
feh --bg-fill "$WALLPAPERS_DIR/$WALLPAPER"
```

## 📐 Recomendaciones

- Usa imágenes en resolución Full HD (1920x1080) o superior
- Formatos soportados: .jpg, .png, .jpeg
- Considera el tamaño del archivo si subirás a GitHub (< 5MB recomendado)
