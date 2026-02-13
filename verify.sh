#!/bin/bash

#####################################
# Script de Verificación de Dotfiles
# Verifica que todos los archivos necesarios estén presentes
#####################################

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Verificación de Dotfiles            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

missing_files=0
present_files=0

# Función para verificar archivo
check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$DOTFILES_DIR/$file" ]; then
        echo -e "${GREEN}✓${NC} $description"
        ((present_files++))
    else
        echo -e "${RED}✗${NC} $description"
        echo -e "  ${YELLOW}Falta:${NC} $file"
        ((missing_files++))
    fi
}

# Función para verificar directorio
check_dir() {
    local dir=$1
    local description=$2
    
    if [ -d "$DOTFILES_DIR/$dir" ] && [ "$(ls -A $DOTFILES_DIR/$dir)" ]; then
        echo -e "${GREEN}✓${NC} $description"
        ((present_files++))
    else
        echo -e "${RED}✗${NC} $description"
        echo -e "  ${YELLOW}Falta o vacío:${NC} $dir"
        ((missing_files++))
    fi
}

echo -e "${BLUE}[*] Verificando archivos principales...${NC}"
echo ""

check_file "install.sh" "Script de instalación"
check_file "README.md" "Documentación principal"
check_file ".gitignore" "Archivo gitignore"

echo ""
echo -e "${BLUE}[*] Verificando configuraciones de BSPWM...${NC}"
echo ""

check_file "config/bspwm/bspwmrc" "Configuración de BSPWM"
check_file "config/bspwm/scripts/ethernet_status.sh" "Script IP local"
check_file "config/bspwm/scripts/htb_ip.sh" "Script VPN HTB"
check_file "config/bspwm/scripts/target_hack.sh" "Script target"

echo ""
echo -e "${BLUE}[*] Verificando otras configuraciones...${NC}"
echo ""

check_file "config/sxhkd/sxhkdrc" "Configuración de SXHKD"
check_file "config/polybar/config.ini" "Configuración de Polybar"
check_file "config/polybar/launch.sh" "Script de lanzamiento de Polybar"
check_file "config/picom/picom.conf" "Configuración de Picom"
check_file "config/rofi/config.rasi" "Configuración de Rofi"
check_file "config/kitty/kitty.conf" "Configuración de Kitty"

echo ""
echo -e "${BLUE}[*] Verificando configuraciones de ZSH...${NC}"
echo ""

check_file "config/zsh/.zshrc" "Configuración de ZSH"
check_file "config/zsh/.p10k.zsh" "Configuración de Powerlevel10k"

echo ""
echo -e "${BLUE}[*] Verificando NvChad...${NC}"
echo ""

check_dir "config/nvim" "Configuración de NvChad"

echo ""
echo -e "${BLUE}[*] Verificando wallpapers...${NC}"
echo ""

check_dir "wallpapers" "Wallpapers"

echo ""
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"

if [ $missing_files -eq 0 ]; then
    echo -e "${GREEN}║  ✓ ¡Todo está listo!                 ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Archivos presentes: $present_files${NC}"
    echo ""
    echo -e "${GREEN}Puedes proceder a hacer commit:${NC}"
    echo "  git add ."
    echo "  git commit -m 'Initial commit: My BSPWM dotfiles'"
    echo "  git push"
else
    echo -e "${RED}║  ✗ Faltan archivos                   ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}Archivos faltantes: $missing_files${NC}"
    echo -e "${GREEN}Archivos presentes: $present_files${NC}"
    echo ""
    echo -e "${YELLOW}Lee SETUP_GUIDE.md para saber cómo copiar tus archivos.${NC}"
fi

echo ""
