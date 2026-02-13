# 🚀 Quick Start

Guía rápida para configurar y usar este repositorio de dotfiles.

## Instalación en un sistema nuevo

```bash
# Clonar el repositorio
git clone https://github.com/TU_USUARIO/dotfiles.git ~/dotfiles

# Ejecutar instalador
cd ~/dotfiles
chmod +x install.sh
./install.sh

# Reiniciar sesión y seleccionar BSPWM
```

## Configurar el repositorio con tus archivos

```bash
# Clonar/crear repo
git clone https://github.com/TU_USUARIO/dotfiles.git ~/dotfiles
# O crear uno nuevo:
# mkdir ~/dotfiles && cd ~/dotfiles && git init

# Copiar configuraciones (ejecutar desde ~/dotfiles)
mkdir -p config/{bspwm/scripts,sxhkd,polybar,picom,rofi,kitty,nvim,zsh} wallpapers

cp ~/.config/bspwm/bspwmrc config/bspwm/
cp ~/.config/bspwm/scripts/* config/bspwm/scripts/
cp ~/.config/sxhkd/sxhkdrc config/sxhkd/
cp -r ~/.config/polybar/* config/polybar/
cp ~/.config/picom/picom.conf config/picom/
cp ~/.config/rofi/config.rasi config/rofi/
cp ~/.config/kitty/kitty.conf config/kitty/
cp ~/.zshrc config/zsh/.zshrc
cp ~/.p10k.zsh config/zsh/.p10k.zsh
cp -r ~/.config/nvim/* config/nvim/
cp ~/fondos/* wallpapers/

# Verificar archivos
chmod +x verify.sh
./verify.sh

# Commit y push
git add .
git commit -m "Initial commit: My BSPWM dotfiles"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/dotfiles.git
git push -u origin main
```

## Comandos útiles incluidos

```bash
# Establecer target de máquina
settarget 10.10.10.123

# Limpiar target
cleartarget

# Crear estructura de directorios para CTF
mkt nombre_maquina
```

## Estructura de carpetas creada por mkt

```
nombre_maquina/
├── content/     # Contenido descargado
├── exploits/    # Exploits utilizados
├── nmap/        # Resultados de nmap
└── scripts/     # Scripts personalizados
```

## Archivos importantes

- `install.sh` - Instalador automático
- `README.md` - Documentación completa
- `SETUP_GUIDE.md` - Guía detallada de configuración
- `verify.sh` - Verificar archivos antes de commit

## Personalización post-instalación

```bash
# Cambiar wallpaper
feh --bg-fill ~/fondos/nuevo_wallpaper.jpg

# Reconfigurar Powerlevel10k
p10k configure

# Editar Polybar
nvim ~/.config/polybar/config.ini

# Editar atajos
nvim ~/.config/sxhkd/sxhkdrc
```

## Solución rápida de problemas

```bash
# Reiniciar BSPWM
Super + Alt + r

# Reiniciar SXHKD
killall sxhkd && sxhkd &

# Reiniciar Polybar
~/.config/polybar/launch.sh

# Actualizar fuentes
fc-cache -fv
```

## Mantener actualizado

```bash
# En tu sistema actual
cd ~/dotfiles
git add .
git commit -m "Update configs"
git push

# En otro sistema
cd ~/dotfiles
git pull
./install.sh  # Para aplicar cambios
```

---

Para más detalles, lee el [README.md](README.md) completo.
