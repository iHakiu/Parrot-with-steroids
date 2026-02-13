#!/bin/bash

#####################################
# Script para copiar configuraciones
# desde tu sistema al repositorio
#####################################

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Copiando configuraciones            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# Función para copiar archivo
copy_file() {
    local source=$1
    local dest=$2
    local description=$3
    
    if [ -f "$source" ]; then
        mkdir -p "$(dirname $DOTFILES_DIR/$dest)"
        cp "$source" "$DOTFILES_DIR/$dest"
        echo -e "${GREEN}✓${NC} Copiado: $description"
    else
        echo -e "${YELLOW}⊘${NC} No encontrado: $description"
    fi
}

# Función para copiar directorio
copy_dir() {
    local source=$1
    local dest=$2
    local description=$3
    
    if [ -d "$source" ]; then
        mkdir -p "$DOTFILES_DIR/$dest"
        cp -r "$source"/* "$DOTFILES_DIR/$dest/" 2>/dev/null
        echo -e "${GREEN}✓${NC} Copiado: $description"
    else
        echo -e "${YELLOW}⊘${NC} No encontrado: $description"
    fi
}

echo -e "${BLUE}[*] Creando estructura de directorios...${NC}"
mkdir -p "$DOTFILES_DIR/config"/{bspwm/scripts,sxhkd,polybar,picom,rofi,kitty,nvim,zsh}
mkdir -p "$DOTFILES_DIR/wallpapers"
echo ""

echo -e "${BLUE}[*] Copiando configuraciones de BSPWM...${NC}"
copy_file "$HOME/.config/bspwm/bspwmrc" "config/bspwm/bspwmrc" "bspwmrc"
copy_dir "$HOME/.config/bspwm/scripts" "config/bspwm/scripts" "Scripts de BSPWM"
echo ""

echo -e "${BLUE}[*] Copiando configuración de SXHKD...${NC}"
copy_file "$HOME/.config/sxhkd/sxhkdrc" "config/sxhkd/sxhkdrc" "sxhkdrc"
echo ""

echo -e "${BLUE}[*] Copiando configuración de Polybar...${NC}"
copy_dir "$HOME/.config/polybar" "config/polybar" "Polybar completo"
echo ""

echo -e "${BLUE}[*] Copiando configuración de Picom...${NC}"
copy_file "$HOME/.config/picom/picom.conf" "config/picom/picom.conf" "picom.conf"
echo ""

echo -e "${BLUE}[*] Copiando configuración de Rofi...${NC}"
copy_file "$HOME/.config/rofi/config.rasi" "config/rofi/config.rasi" "config.rasi"
if [ -d "$HOME/.config/rofi/themes" ]; then
    copy_dir "$HOME/.config/rofi/themes" "config/rofi/themes" "Temas de Rofi"
fi
echo ""

echo -e "${BLUE}[*] Copiando configuración de Kitty...${NC}"
copy_dir "$HOME/.config/kitty" "config/kitty" "Kitty completo (kitty.conf, color.ini, etc.)"
echo ""

echo -e "${BLUE}[*] Copiando configuración de ZSH...${NC}"
copy_file "$HOME/.zshrc" "config/zsh/.zshrc" ".zshrc"
copy_file "$HOME/.p10k.zsh" "config/zsh/.p10k.zsh" ".p10k.zsh"
echo ""

echo -e "${BLUE}[*] Copiando configuración de NvChad...${NC}"
copy_dir "$HOME/.config/nvim" "config/nvim" "NvChad completo"
echo ""

echo -e "${BLUE}[*] Copiando wallpapers...${NC}"
if [ -d "$HOME/fondos" ]; then
    find "$HOME/fondos" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) \
        -exec cp {} "$DOTFILES_DIR/wallpapers/" \;
    count=$(find "$DOTFILES_DIR/wallpapers" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | wc -l)
    if [ "$count" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} $count wallpaper(s) copiados"
    else
        echo -e "${YELLOW}⊘${NC} No se encontraron imágenes en ~/fondos"
    fi
else
    echo -e "${YELLOW}⊘${NC} Carpeta ~/fondos no encontrada"
fi
echo ""

echo -e "${BLUE}[*] Haciendo scripts ejecutables...${NC}"
chmod +x "$DOTFILES_DIR"/config/bspwm/scripts/*.sh 2>/dev/null
chmod +x "$DOTFILES_DIR"/config/polybar/*.sh 2>/dev/null
echo -e "${GREEN}✓${NC} Permisos aplicados"
echo ""

echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ ¡Copiado completado!              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Siguiente paso:${NC} Ejecuta ./verify.sh para verificar"
echo ""
