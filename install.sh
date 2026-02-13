#!/bin/bash

#####################################
# Dotfiles Auto-Installer
# Compatible with Parrot OS
# v3.0 - Robusto, sin symlinks, portable
#####################################

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Rutas base (siempre relativas al script, funciona con cualquier usuario)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_USER="$(whoami)"
USER_HOME="$HOME"

# Log de instalación
LOG_FILE="/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"

# Helpers
print_message() { echo -e "${BLUE}[*]${NC} $1" | tee -a "$LOG_FILE"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"; }
print_error()   { echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }

# ─────────────────────────────────────────
# Bloquear ejecución como root
# ─────────────────────────────────────────
check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "No ejecutes este script como root o con sudo."
        print_error "Ejecútalo como tu usuario normal: ./install.sh"
        exit 1
    fi
}

# ─────────────────────────────────────────
# Verificar conexión a internet
# ─────────────────────────────────────────
check_internet() {
    print_message "Verificando conexión a internet..."
    if ! curl -s --max-time 5 https://github.com > /dev/null 2>&1; then
        print_error "Sin conexión a internet. El instalador necesita descargar paquetes."
        exit 1
    fi
    print_success "Conexión a internet OK"
}

# ─────────────────────────────────────────
# Verificar Parrot OS
# ─────────────────────────────────────────
check_parrot() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "parrot" ]]; then
            print_success "Parrot OS detectado (usuario: $CURRENT_USER)"
            return 0
        fi
    fi
    print_warning "No se detectó Parrot OS."
    read -p "¿Deseas continuar igualmente? (s/n): " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Ss]$ ]] && exit 1
}

# ─────────────────────────────────────────
# Backup de configuraciones existentes
# ─────────────────────────────────────────
backup_configs() {
    print_message "Creando backup de configuraciones existentes..."
    BACKUP_DIR="$USER_HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    [ -f "$USER_HOME/.zshrc" ]    && cp "$USER_HOME/.zshrc"    "$BACKUP_DIR/"
    [ -f "$USER_HOME/.p10k.zsh" ] && cp "$USER_HOME/.p10k.zsh" "$BACKUP_DIR/"

    for dir in bspwm sxhkd polybar picom rofi kitty nvim; do
        [ -d "$USER_HOME/.config/$dir" ] && cp -r "$USER_HOME/.config/$dir" "$BACKUP_DIR/"
    done

    print_success "Backup creado en: $BACKUP_DIR"
}

# ─────────────────────────────────────────
# Instalar paquetes base
# ─────────────────────────────────────────
install_packages() {
    print_message "Actualizando repositorios..."
    sudo apt update -qq

    # Paquetes instalables via apt
    PACKAGES=(
        bspwm sxhkd polybar picom rofi kitty feh zsh bat
        git curl wget unzip build-essential neovim net-tools
        libxcb-xinerama0-dev libxcb-icccm4-dev libxcb-randr0-dev
        libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev
    )

    print_message "Instalando paquetes..."
    for pkg in "${PACKAGES[@]}"; do
        if dpkg -s "$pkg" &>/dev/null; then
            print_success "$pkg ya instalado"
        else
            print_message "Instalando $pkg..."
            if ! sudo apt install -y "$pkg" >> "$LOG_FILE" 2>&1; then
                print_warning "No se pudo instalar $pkg, continuando..."
            fi
        fi
    done

    # lsd: no está en repos de Parrot, hay que bajarlo de GitHub
    install_lsd

    print_success "Paquetes instalados"
}

# ─────────────────────────────────────────
# Instalar lsd desde GitHub (no está en repos de Parrot)
# ─────────────────────────────────────────
install_lsd() {
    if command -v lsd &>/dev/null; then
        print_success "lsd ya instalado"
        return 0
    fi

    print_message "Instalando lsd desde GitHub..."

    # Detectar arquitectura
    ARCH=$(dpkg --print-architecture)
    LSD_VERSION=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest \
        | grep '"tag_name"' | grep -oP '[\d.]+' | head -n1)

    if [ -z "$LSD_VERSION" ]; then
        print_warning "No se pudo detectar la versión de lsd, intentando con v1.1.5..."
        LSD_VERSION="1.1.5"
    fi

    LSD_URL="https://github.com/lsd-rs/lsd/releases/download/v${LSD_VERSION}/lsd_${LSD_VERSION}_${ARCH}.deb"

    cd /tmp
    if wget -q "$LSD_URL" -O lsd.deb; then
        sudo dpkg -i lsd.deb >> "$LOG_FILE" 2>&1
        rm -f lsd.deb
        print_success "lsd instalado (v$LSD_VERSION)"
    else
        print_error "No se pudo descargar lsd. Instálalo manualmente desde: https://github.com/lsd-rs/lsd/releases"
    fi
    cd "$DOTFILES_DIR"
}

# ─────────────────────────────────────────
# Instalar Oh-My-Zsh
# ─────────────────────────────────────────
install_ohmyzsh() {
    print_message "Instalando Oh-My-Zsh..."

    if [ -d "$USER_HOME/.oh-my-zsh" ]; then
        print_success "Oh-My-Zsh ya está instalado"
        return 0
    fi

    # RUNZSH=no evita que lance zsh al terminar
    # CHSH=no evita que cambie el shell (lo hacemos nosotros después)
    # KEEP_ZSHRC=yes evita que sobreescriba el .zshrc que pondremos luego
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        >> "$LOG_FILE" 2>&1

    print_success "Oh-My-Zsh instalado"
}

# ─────────────────────────────────────────
# Instalar plugins de ZSH
# ─────────────────────────────────────────
install_zsh_plugins() {
    print_message "Instalando plugins de ZSH..."

    ZSH_CUSTOM="$USER_HOME/.oh-my-zsh/custom"

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
            "$ZSH_CUSTOM/plugins/zsh-autosuggestions" >> "$LOG_FILE" 2>&1
        print_success "zsh-autosuggestions instalado"
    else
        print_success "zsh-autosuggestions ya instalado"
    fi

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
            "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" >> "$LOG_FILE" 2>&1
        print_success "zsh-syntax-highlighting instalado"
    else
        print_success "zsh-syntax-highlighting ya instalado"
    fi
}

# ─────────────────────────────────────────
# Instalar Powerlevel10k
# ─────────────────────────────────────────
install_powerlevel10k() {
    print_message "Instalando Powerlevel10k..."

    P10K_DIR="$USER_HOME/.oh-my-zsh/custom/themes/powerlevel10k"

    if [ ! -d "$P10K_DIR" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$P10K_DIR" >> "$LOG_FILE" 2>&1
        print_success "Powerlevel10k instalado"
    else
        print_success "Powerlevel10k ya instalado"
    fi
}

# ─────────────────────────────────────────
# Instalar Hack Nerd Font
# ─────────────────────────────────────────
install_fonts() {
    print_message "Instalando Hack Nerd Font..."

    FONT_DIR="$USER_HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"

    # Buscar específicamente "Hack Nerd Font", no solo "hack"
    if fc-list | grep -qi "Hack Nerd Font\|HackNerdFont"; then
        print_success "Hack Nerd Font ya está instalada"
        return 0
    fi

    cd /tmp
    if wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip \
        -O Hack.zip; then
        unzip -q Hack.zip -d "$FONT_DIR"
        rm -f Hack.zip
        fc-cache -fv > /dev/null 2>&1
        print_success "Hack Nerd Font instalada"
    else
        print_error "No se pudo descargar Hack Nerd Font"
    fi
    cd "$DOTFILES_DIR"
}

# ─────────────────────────────────────────
# Instalar NvChad
# ─────────────────────────────────────────
install_nvchad() {
    print_message "Instalando NvChad..."

    if [ -d "$USER_HOME/.config/nvim" ] && [ -f "$USER_HOME/.config/nvim/init.lua" ]; then
        print_success "NvChad ya está instalado"
        return 0
    fi

    git clone https://github.com/NvChad/NvChad \
        "$USER_HOME/.config/nvim" --depth 1 >> "$LOG_FILE" 2>&1
    print_success "NvChad instalado"
    print_warning "Recuerda: abre nvim y ejecuta :MasonInstallAll"
}

# ─────────────────────────────────────────
# Crear directorios necesarios
# ─────────────────────────────────────────
create_directories() {
    print_message "Creando directorios necesarios..."
    mkdir -p "$USER_HOME/.config"/{bspwm/scripts,sxhkd,polybar,picom,rofi,kitty}
    mkdir -p "$USER_HOME/fondos"
    print_success "Directorios creados"
}

# ─────────────────────────────────────────
# Preguntar backend de Picom
# ─────────────────────────────────────────
choose_picom_backend() {
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║   Configuración de Picom (compositor)        ║${NC}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║  1) glx   → Mejor rendimiento (PC físico)   ║${NC}"
    echo -e "${YELLOW}║  2) xrender → Más compatible (VMs, básico)  ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "¿En qué entorno vas a usar esto? Elige 1 o 2: " -n 1 -r PICOM_CHOICE
    echo ""

    if [[ "$PICOM_CHOICE" == "2" ]]; then
        PICOM_BACKEND="xrender"
        print_success "Backend seleccionado: xrender (compatible)"
    else
        PICOM_BACKEND="glx"
        print_success "Backend seleccionado: glx (rendimiento)"
    fi
}

# ─────────────────────────────────────────
# Copiar configuraciones al sistema
# Usa cp (NO symlinks) → el usuario puede borrar el repo después
# ─────────────────────────────────────────
copy_configs() {
    print_message "Copiando configuraciones al sistema..."

    # BSPWM
    if [ -f "$DOTFILES_DIR/config/bspwm/bspwmrc" ]; then
        # Corregir rutas hardcodeadas SOLO en la copia, no en el repo
        sed "s|/home/[^/]*/|$USER_HOME/|g" \
            "$DOTFILES_DIR/config/bspwm/bspwmrc" > "$USER_HOME/.config/bspwm/bspwmrc"
        chmod +x "$USER_HOME/.config/bspwm/bspwmrc"
        print_success "bspwmrc copiado"
    fi

    # Scripts de BSPWM (polybar modules)
    if [ -d "$DOTFILES_DIR/config/bspwm/scripts" ]; then
        cp -r "$DOTFILES_DIR/config/bspwm/scripts/"* "$USER_HOME/.config/bspwm/scripts/"
        chmod +x "$USER_HOME/.config/bspwm/scripts/"*
        print_success "Scripts de polybar copiados"
    fi

    # SXHKD
    if [ -f "$DOTFILES_DIR/config/sxhkd/sxhkdrc" ]; then
        sed "s|/home/[^/]*/|$USER_HOME/|g" \
            "$DOTFILES_DIR/config/sxhkd/sxhkdrc" > "$USER_HOME/.config/sxhkd/sxhkdrc"
        print_success "sxhkdrc copiado"
    fi

    # Polybar (todos los archivos)
    if [ -d "$DOTFILES_DIR/config/polybar" ]; then
        cp -r "$DOTFILES_DIR/config/polybar/"* "$USER_HOME/.config/polybar/"
        chmod +x "$USER_HOME/.config/polybar/"*.sh 2>/dev/null
        # Corregir rutas en configs de polybar
        find "$USER_HOME/.config/polybar" -type f -name "*.ini" -o -name "*.conf" | while read f; do
            sed -i "s|/home/[^/]*/|$USER_HOME/|g" "$f"
        done
        print_success "Polybar copiado"
    fi

    # Picom (aplicar backend elegido por el usuario)
    if [ -f "$DOTFILES_DIR/config/picom/picom.conf" ]; then
        cp "$DOTFILES_DIR/config/picom/picom.conf" "$USER_HOME/.config/picom/picom.conf"
        # Reemplazar backend según la elección del usuario
        sed -i "s|^backend = .*|backend = \"$PICOM_BACKEND\";|" "$USER_HOME/.config/picom/picom.conf"
        print_success "picom.conf copiado (backend: $PICOM_BACKEND)"
    fi

    # Rofi
    if [ -f "$DOTFILES_DIR/config/rofi/config.rasi" ]; then
        cp "$DOTFILES_DIR/config/rofi/config.rasi" "$USER_HOME/.config/rofi/config.rasi"
        print_success "Rofi config copiado"
    fi
    if [ -d "$DOTFILES_DIR/config/rofi/themes" ]; then
        cp -r "$DOTFILES_DIR/config/rofi/themes" "$USER_HOME/.config/rofi/"
        print_success "Temas de Rofi copiados"
    fi

    # Kitty (todos los archivos: kitty.conf, color.ini, etc.)
    if [ -d "$DOTFILES_DIR/config/kitty" ]; then
        cp -r "$DOTFILES_DIR/config/kitty/"* "$USER_HOME/.config/kitty/"
        print_success "Kitty copiado"
    fi

    # ZSH
    if [ -f "$DOTFILES_DIR/config/zsh/.zshrc" ]; then
        cp "$DOTFILES_DIR/config/zsh/.zshrc" "$USER_HOME/.zshrc"
        print_success ".zshrc copiado"
    fi
    if [ -f "$DOTFILES_DIR/config/zsh/.p10k.zsh" ]; then
        cp "$DOTFILES_DIR/config/zsh/.p10k.zsh" "$USER_HOME/.p10k.zsh"
        print_success ".p10k.zsh copiado"
    fi

    # NvChad custom config (solo si hay archivos además del README)
    if [ -d "$DOTFILES_DIR/config/nvim" ]; then
        NVIM_FILES=$(find "$DOTFILES_DIR/config/nvim" -type f ! -name "README.md" | wc -l)
        if [ "$NVIM_FILES" -gt 0 ]; then
            cp -r "$DOTFILES_DIR/config/nvim/"* "$USER_HOME/.config/nvim/" 2>/dev/null
            print_success "NvChad custom config copiada"
        fi
    fi

    # Wallpapers
    if [ -d "$DOTFILES_DIR/wallpapers" ]; then
        find "$DOTFILES_DIR/wallpapers" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) \
            -exec cp {} "$USER_HOME/fondos/" \;
        print_success "Wallpapers copiados"
    fi

    print_success "Todas las configuraciones instaladas en el sistema"
}

# ─────────────────────────────────────────
# Configurar wallpaper en bspwmrc
# ─────────────────────────────────────────
setup_wallpaper() {
    print_message "Configurando wallpaper..."

    WALLPAPER=$(find "$USER_HOME/fondos" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) \
        | head -n1)

    if [ -z "$WALLPAPER" ]; then
        print_warning "No se encontró wallpaper en ~/fondos/"
        return
    fi

    if ! grep -q "feh --bg-fill" "$USER_HOME/.config/bspwm/bspwmrc" 2>/dev/null; then
        echo "feh --bg-fill \"$WALLPAPER\" &" >> "$USER_HOME/.config/bspwm/bspwmrc"
    fi

    [ -n "$DISPLAY" ] && feh --bg-fill "$WALLPAPER"

    print_success "Wallpaper configurado: $(basename $WALLPAPER)"
}

# ─────────────────────────────────────────
# Cambiar shell a ZSH
# ─────────────────────────────────────────
change_shell() {
    print_message "Cambiando shell a ZSH..."

    # Usar ruta directa en caso de que PATH no esté refrescado
    ZSH_PATH=$(command -v zsh || echo "/usr/bin/zsh")

    if [ ! -f "$ZSH_PATH" ]; then
        print_error "ZSH no encontrado en $ZSH_PATH"
        return 1
    fi

    if [ "$SHELL" == "$ZSH_PATH" ]; then
        print_success "ZSH ya es tu shell"
        return 0
    fi

    # chsh puede requerir contraseña en algunos sistemas
    if chsh -s "$ZSH_PATH" "$CURRENT_USER" 2>/dev/null; then
        print_success "Shell cambiado a ZSH (cierra sesión para aplicar)"
    else
        print_warning "No se pudo cambiar el shell automáticamente."
        print_warning "Ejecútalo manualmente: chsh -s $ZSH_PATH"
    fi
}

# ─────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────
main() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║   Instalador de Dotfiles - Parrot OS  v3.0  ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "  Usuario:  ${GREEN}$CURRENT_USER${NC}"
    echo -e "  Home:     ${GREEN}$USER_HOME${NC}"
    echo -e "  Dotfiles: ${GREEN}$DOTFILES_DIR${NC}"
    echo -e "  Log:      ${GREEN}$LOG_FILE${NC}"
    echo ""

    check_not_root
    check_internet
    check_parrot

    echo ""
    read -p "$(echo -e ${YELLOW}¿Hacer backup de configs existentes? [S/n]: ${NC})" -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Nn]$ ]] && backup_configs

    choose_picom_backend

    echo ""
    print_message "Iniciando instalación..."
    echo ""

    install_packages
    install_ohmyzsh
    install_zsh_plugins
    install_powerlevel10k
    install_fonts
    install_nvchad
    create_directories
    copy_configs
    setup_wallpaper
    change_shell

    echo ""
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║        ¡Instalación completada! 🚀           ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
    print_warning "Pasos finales:"
    echo "  1. Cierra sesión y vuelve a entrar (para aplicar ZSH)"
    echo "  2. Selecciona BSPWM como window manager"
    echo "  3. Abre nvim y ejecuta: :MasonInstallAll"
    echo "  4. Si quieres reconfigurar p10k: p10k configure"
    echo ""
    echo -e "  📋 Log completo en: ${BLUE}$LOG_FILE${NC}"
    echo ""
    print_message "¡Disfruta tu entorno! 😎"
    print_message "Ya puedes borrar la carpeta dotfiles si quieres."
}

main
