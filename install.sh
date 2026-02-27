#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  install.sh — Instalador de entorno BSPWM Pentesting para Parrot OS        ║
# ║  Uso: git clone <repo> ~/Dotfiles && cd ~/Dotfiles && ./install.sh         ║
# ║  Flags: --skip-update  salta la actualización del sistema                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ─── Variables globales ──────────────────────────────────────────────────────
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
FONT_VERSION="v3.3.0"
SKIP_UPDATE=false

# Parsear flags
for arg in "$@"; do
    case "$arg" in
        --skip-update) SKIP_UPDATE=true ;;
    esac
done

# ─── Colores ─────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Funciones de log ────────────────────────────────────────────────────────
log_info()  { echo -e "${BLUE}[→]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${CYAN}${BOLD}═══ $1 ═══${NC}\n"; }

# ─── Trap para errores ───────────────────────────────────────────────────────
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo ""
        log_error "La instalación falló en la línea $BASH_LINENO con código $exit_code"
        log_error "Revisa el error de arriba. El script es re-ejecutable: corrígelo y vuelve a lanzar."
    fi
}
trap cleanup EXIT

# ─── Backup de archivos existentes ───────────────────────────────────────────
backup_if_exists() {
    local target="$1"
    if [ -f "$target" ]; then
        local backup="${target}.bak.$(date +%Y%m%d_%H%M%S)"
        cp "$target" "$backup"
        log_warn "Backup: $target → $(basename $backup)"
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 0 — Validaciones previas
# ══════════════════════════════════════════════════════════════════════════════

log_section "VALIDACIONES"

# No ejecutar como root
if [ "$(id -u)" -eq 0 ]; then
    log_error "No ejecutar como root. Usa: ./install.sh"
    log_error "El script pide sudo solo cuando lo necesita."
    exit 1
fi

# Verificar que estamos en el directorio del repo
if [ ! -d "$DOTFILES_DIR/config/bspwm" ] || [ ! -d "$DOTFILES_DIR/scripts" ]; then
    log_error "Ejecuta este script desde la raíz del repo Dotfiles/"
    log_error "Directorio actual: $DOTFILES_DIR"
    exit 1
fi

# Verificar que es Debian/Parrot
if ! command -v apt &>/dev/null; then
    log_error "Este script requiere apt (Parrot/Debian)"
    exit 1
fi

log_ok "Ejecutando como: $USER"
log_ok "Home: $HOME"
log_ok "Repo: $DOTFILES_DIR"

# ─── Resumen y confirmación ──────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Se va a instalar:${NC}"
echo "  • 40+ paquetes apt (bspwm, sxhkd, picom, polybar, rofi, kitty, zsh...)"
echo "  • i3lock-color (compilado desde source)"
echo "  • betterlockscreen (desde GitHub)"
echo "  • Hack Nerd Font $FONT_VERSION"
echo "  • Oh-My-Zsh + Powerlevel10k + plugins"
echo "  • Configs copiados a ~/ y /root/"
if [ "$SKIP_UPDATE" = true ]; then
    echo -e "  • ${YELLOW}Actualización del sistema: SALTADA (--skip-update)${NC}"
fi
echo ""
read -rp "¿Continuar? [s/N]: " confirm
if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    log_warn "Instalación cancelada."
    exit 0
fi

# Cachear sudo
sudo -v
# Mantener sudo vivo durante la instalación
while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done &
SUDO_KEEPALIVE_PID=$!

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 1 — Actualización del sistema
# ══════════════════════════════════════════════════════════════════════════════

log_section "PASO 1/10 — Actualización del sistema"

if [ "$SKIP_UPDATE" = true ]; then
    log_warn "Saltando actualización (--skip-update)"
else
    log_info "Actualizando sistema (esto puede tardar)..."
    sudo apt update -y
    sudo parrot-upgrade -y || sudo apt upgrade -y
    log_ok "Sistema actualizado"
fi

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 2 — Paquetes apt
# ══════════════════════════════════════════════════════════════════════════════

log_section "PASO 2/10 — Paquetes apt"

PACKAGES=(
    # Core WM
    bspwm sxhkd picom polybar rofi feh xterm
    # Shell
    zsh
    # CLI tools
    lsd bat fzf xclip scrot
    # Sistema
    net-tools psmisc xorg x11-xserver-utils xdg-utils
    # Iconos y fuentes
    papirus-icon-theme fonts-font-awesome
    # betterlockscreen runtime deps
    imagemagick bc x11-utils
    # Compilación i3lock-color
    build-essential git curl wget autoconf pkg-config
    libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev
    libxcb-keysyms1-dev libxcb-xinerama0-dev libxcb-xtest0-dev
    libxcb-shape0-dev libxcb1-dev
    libx11-dev libxcomposite-dev libxfixes-dev libxdamage-dev
    libxrender-dev libxrandr-dev libxext-dev
    libpam0g-dev libcairo2-dev libfontconfig1-dev
    libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev
    libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev
    libxkbcommon-dev libxkbcommon-x11-dev
    libjpeg-dev libgif-dev
)

log_info "Instalando ${#PACKAGES[@]} paquetes..."
sudo apt install -y "${PACKAGES[@]}"
log_ok "Paquetes instalados"

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 3 — Compilar i3lock-color
# ══════════════════════════════════════════════════════════════════════════════

log_section "PASO 3/10 — i3lock-color"

# Check: si i3lock existe y NO es del paquete apt, es nuestro i3lock-color compilado
if command -v i3lock &>/dev/null && ! dpkg -l i3lock 2>/dev/null | grep -q "^ii"; then
    log_ok "i3lock-color ya instalado (compilado desde source)"
else
    log_info "Eliminando i3lock estándar si existe..."
    sudo apt remove -y i3lock 2>/dev/null || true

    log_info "Compilando i3lock-color desde source..."
    cd /tmp
    sudo rm -rf i3lock-color
    git clone https://github.com/Raymo111/i3lock-color.git
    cd i3lock-color
    ./build.sh
    sudo ./install-i3lock-color.sh
    cd "$DOTFILES_DIR"

    log_ok "i3lock-color compilado e instalado"
fi

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 4 — betterlockscreen
# ══════════════════════════════════════════════════════════════════════════════

log_section "PASO 4/10 — betterlockscreen"

if command -v betterlockscreen &>/dev/null; then
    log_ok "betterlockscreen ya instalado: $(betterlockscreen --version 2>&1 | head -1)"
else
    log_info "Instalando betterlockscreen desde GitHub..."
    cd /tmp
    rm -rf betterlockscreen
    git clone https://github.com/betterlockscreen/betterlockscreen.git
    cd betterlockscreen
    sudo cp betterlockscreen /usr/local/bin/
    sudo chmod +x /usr/local/bin/betterlockscreen
    cd "$DOTFILES_DIR"

    log_ok "betterlockscreen instalado"
fi

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 5 — Hack Nerd Font
# ══════════════════════════════════════════════════════════════════════════════

log_section "PASO 5/10 — Hack Nerd Font"

FONT_DIR_USER="$HOME/.local/share/fonts/HackNerdFont"
FONT_DIR_ROOT="/root/.local/share/fonts/HackNerdFont"

if fc-list | grep -qi "Hack Nerd Font" && [ -d "$FONT_DIR_USER" ]; then
    log_ok "Hack Nerd Font ya instalada"
else
    log_info "Descargando Hack Nerd Font ${FONT_VERSION}..."
    cd /tmp
    rm -rf hack_font Hack.zip
    wget -q --show-progress \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/Hack.zip" \
        -O Hack.zip
    mkdir -p hack_font && cd hack_font
    unzip -oq ../Hack.zip

    # Eliminar variantes Mono y Propo — solo queremos Regular
    rm -f HackNerdFontMono-* HackNerdFontPropo-*

    # Instalar para usuario
    log_info "Instalando fuentes para $USER..."
    mkdir -p "$FONT_DIR_USER"
    cp HackNerdFont-*.ttf "$FONT_DIR_USER/"

    # Instalar para root
    log_info "Instalando fuentes para root..."
    sudo mkdir -p "$FONT_DIR_ROOT"
    sudo cp HackNerdFont-*.ttf "$FONT_DIR_ROOT/"
    sudo chown -R root:root "$FONT_DIR_ROOT"

    # Cleanup
    cd /tmp && rm -rf hack_font Hack.zip

    log_ok "Hack Nerd Font instalada (Regular, Bold, Italic, BoldItalic)"
fi

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 6 — Instalar entorno para usuario normal
# ══════════════════════════════════════════════════════════════════════════════

log_section "PASO 6/10 — Entorno de $USER"

# ─── 6a. Kitty ───────────────────────────────────────────────────────────────
log_info "Kitty..."
if [ -d "$HOME/.local/kitty.app" ]; then
    log_ok "Kitty ya instalada para $USER"
else
    log_info "Instalando Kitty via installer oficial..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
fi

# Symlinks Kitty
mkdir -p "$HOME/.local/bin"
ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
ln -sf "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten"

# Desktop file Kitty
mkdir -p "$HOME/.local/share/applications"
if [ -f "$HOME/.local/kitty.app/share/applications/kitty.desktop" ]; then
    cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" \
       "$HOME/.local/share/applications/"
fi
log_ok "Kitty configurada para $USER"

# ─── 6b. Oh-My-Zsh ──────────────────────────────────────────────────────────
log_info "Oh-My-Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    log_ok "Oh-My-Zsh ya instalado para $USER"
else
    log_info "Instalando Oh-My-Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended
    log_ok "Oh-My-Zsh instalado para $USER"
fi

# ─── 6c. Plugins ZSH ────────────────────────────────────────────────────────
log_info "Plugins ZSH..."
ZSH_CUSTOM_USER="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM_USER/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM_USER/plugins/zsh-autosuggestions"
    log_ok "zsh-autosuggestions clonado"
else
    log_ok "zsh-autosuggestions ya existe"
fi

if [ ! -d "$ZSH_CUSTOM_USER/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
        "$ZSH_CUSTOM_USER/plugins/zsh-syntax-highlighting"
    log_ok "zsh-syntax-highlighting clonado"
else
    log_ok "zsh-syntax-highlighting ya existe"
fi

# ─── 6d. Powerlevel10k ──────────────────────────────────────────────────────
log_info "Powerlevel10k..."
if [ ! -d "$ZSH_CUSTOM_USER/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$ZSH_CUSTOM_USER/themes/powerlevel10k"
    log_ok "Powerlevel10k clonado"
else
    log_ok "Powerlevel10k ya existe"
fi

# ─── 6e. Symlink bat → batcat ───────────────────────────────────────────────
ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
log_ok "Symlink bat → batcat"

# ─── 6f. Copiar configs ─────────────────────────────────────────────────────
log_info "Copiando configuraciones..."

CONFIG_DIRS=(bspwm sxhkd kitty picom polybar rofi)
for dir in "${CONFIG_DIRS[@]}"; do
    mkdir -p "$HOME/.config/$dir"
    # Backup archivos existentes
    for file in "$DOTFILES_DIR/config/$dir/"*; do
        [ -f "$file" ] || continue
        local_name="$HOME/.config/$dir/$(basename "$file")"
        backup_if_exists "$local_name"
    done
    cp -r "$DOTFILES_DIR/config/$dir/." "$HOME/.config/$dir/"
    log_ok "  ~/.config/$dir/"
done

# ─── 6g. Copiar scripts de bspwm ────────────────────────────────────────────
mkdir -p "$HOME/.config/bspwm/scripts"
cp "$DOTFILES_DIR/scripts/"*.sh "$HOME/.config/bspwm/scripts/"
log_ok "  ~/.config/bspwm/scripts/"

# ─── 6h. Copiar wallpaper ───────────────────────────────────────────────────
cp "$DOTFILES_DIR/wallpaper/wallpaper.jpg" "$HOME/.config/bspwm/wallpaper.jpg"
log_ok "  ~/.config/bspwm/wallpaper.jpg"

# ─── 6i. Copiar dotfiles de home ────────────────────────────────────────────
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.p10k.zsh"
cp "$DOTFILES_DIR/home/.zshrc" "$HOME/.zshrc"
cp "$DOTFILES_DIR/home/.p10k.zsh" "$HOME/.p10k.zsh"
log_ok "  ~/.zshrc y ~/.p10k.zsh"

# ─── 6j. Permisos de ejecución ──────────────────────────────────────────────
chmod +x "$HOME/.config/bspwm/bspwmrc"
chmod +x "$HOME/.config/bspwm/scripts/"*.sh
chmod +x "$HOME/.config/polybar/launch.sh"
log_ok "Permisos +x aplicados"

# ─── 6k. Crear ~/Pictures ───────────────────────────────────────────────────
mkdir -p "$HOME/Pictures"

log_ok "Entorno de $USER completado"

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 7 — Instalar entorno para root
# ══════════════════════════════════════════════════════════════════════════════

log_section "PASO 7/10 — Entorno de root"

# ─── 7a. Kitty para root ────────────────────────────────────────────────────
log_info "Kitty para root..."
if sudo test -d /root/.local/kitty.app; then
    log_ok "Kitty ya instalada para root"
else
    sudo -H bash -c 'curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n'
fi

sudo mkdir -p /root/.local/bin
sudo ln -sf /root/.local/kitty.app/bin/kitty /root/.local/bin/kitty
sudo ln -sf /root/.local/kitty.app/bin/kitten /root/.local/bin/kitten
sudo mkdir -p /root/.local/share/applications
sudo cp /root/.local/kitty.app/share/applications/kitty.desktop \
    /root/.local/share/applications/ 2>/dev/null || true
log_ok "Kitty configurada para root"

# ─── 7b. Oh-My-Zsh para root ────────────────────────────────────────────────
log_info "Oh-My-Zsh para root..."
if sudo test -d /root/.oh-my-zsh; then
    log_ok "Oh-My-Zsh ya instalado para root"
else
    sudo -H bash -c 'RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
    log_ok "Oh-My-Zsh instalado para root"
fi

# ─── 7c. Plugins ZSH para root ──────────────────────────────────────────────
log_info "Plugins ZSH para root..."
ZSH_CUSTOM_ROOT="/root/.oh-my-zsh/custom"

if ! sudo test -d "$ZSH_CUSTOM_ROOT/plugins/zsh-autosuggestions"; then
    sudo git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM_ROOT/plugins/zsh-autosuggestions"
    log_ok "zsh-autosuggestions (root)"
else
    log_ok "zsh-autosuggestions ya existe (root)"
fi

if ! sudo test -d "$ZSH_CUSTOM_ROOT/plugins/zsh-syntax-highlighting"; then
    sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting \
        "$ZSH_CUSTOM_ROOT/plugins/zsh-syntax-highlighting"
    log_ok "zsh-syntax-highlighting (root)"
else
    log_ok "zsh-syntax-highlighting ya existe (root)"
fi

# ─── 7d. Powerlevel10k para root ────────────────────────────────────────────
log_info "Powerlevel10k para root..."
if ! sudo test -d "$ZSH_CUSTOM_ROOT/themes/powerlevel10k"; then
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$ZSH_CUSTOM_ROOT/themes/powerlevel10k"
    log_ok "Powerlevel10k (root)"
else
    log_ok "Powerlevel10k ya existe (root)"
fi

# ─── 7e. Symlink bat para root ──────────────────────────────────────────────
sudo ln -sf /usr/bin/batcat /root/.local/bin/bat

# ─── 7f. Copiar configs para root ───────────────────────────────────────────
log_info "Copiando configuraciones para root..."

for dir in "${CONFIG_DIRS[@]}"; do
    sudo mkdir -p "/root/.config/$dir"
    sudo cp -r "$DOTFILES_DIR/config/$dir/." "/root/.config/$dir/"
    log_ok "  /root/.config/$dir/"
done

# Scripts de bspwm
sudo mkdir -p /root/.config/bspwm/scripts
sudo cp "$DOTFILES_DIR/scripts/"*.sh /root/.config/bspwm/scripts/
log_ok "  /root/.config/bspwm/scripts/"

# Wallpaper
sudo cp "$DOTFILES_DIR/wallpaper/wallpaper.jpg" /root/.config/bspwm/wallpaper.jpg
log_ok "  /root/.config/bspwm/wallpaper.jpg"

# Dotfiles de home
sudo cp "$DOTFILES_DIR/home/.zshrc" /root/.zshrc
sudo cp "$DOTFILES_DIR/home/.p10k.zsh" /root/.p10k.zsh
log_ok "  /root/.zshrc y /root/.p10k.zsh"

# ─── 7g. Permisos para root ─────────────────────────────────────────────────
# Nota: los globs sobre /root/ deben expandirse en contexto de root
# porque el usuario normal no puede leer /root/
sudo bash -c 'chmod +x /root/.config/bspwm/bspwmrc /root/.config/bspwm/scripts/*.sh /root/.config/polybar/launch.sh'

# Pictures para root
sudo mkdir -p /root/Pictures

# Ownership
sudo chown -R root:root /root/.config /root/.local /root/.oh-my-zsh \
    /root/.zshrc /root/.p10k.zsh /root/Pictures 2>/dev/null || true

log_ok "Entorno de root completado"

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 8 — Archivo de sesión BSPWM
# ══════════════════════════════════════════════════════════════════════════════

log_section "PASO 8/10 — Sesión BSPWM"

if [ -f /usr/share/xsessions/bspwm.desktop ]; then
    log_ok "bspwm.desktop ya existe"
else
    sudo cp "$DOTFILES_DIR/system/bspwm.desktop" /usr/share/xsessions/bspwm.desktop
    log_ok "bspwm.desktop creado en /usr/share/xsessions/"
fi

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 9 — fc-cache y shell
# ══════════════════════════════════════════════════════════════════════════════

log_section "PASO 9/10 — Fuentes y shell"

# fc-cache para ambos usuarios
log_info "Actualizando caché de fuentes..."
fc-cache -fv "$HOME/.local/share/fonts" 2>/dev/null || true
sudo fc-cache -fv /root/.local/share/fonts 2>/dev/null || true
log_ok "Caché de fuentes actualizado"

# Cambiar shell a zsh
if [ "$SHELL" = "/usr/bin/zsh" ]; then
    log_ok "Shell de $USER ya es zsh"
else
    chsh -s /usr/bin/zsh
    log_ok "Shell de $USER cambiado a zsh"
fi

if sudo grep -q "^root:.*:/usr/bin/zsh$" /etc/passwd; then
    log_ok "Shell de root ya es zsh"
else
    sudo chsh -s /usr/bin/zsh root
    log_ok "Shell de root cambiado a zsh"
fi

# Detectar VM para el mensaje final + instalar VMware tools si necesario
IS_VM=false
VM_TYPE=""
if systemd-detect-virt --quiet 2>/dev/null; then
    IS_VM=true
    VM_TYPE=$(systemd-detect-virt 2>/dev/null || echo "desconocida")

    # Si es VMware, asegurar que open-vm-tools-desktop está instalado
    # (necesario para copy-paste, drag-and-drop y autoajuste de resolución)
    if [ "$VM_TYPE" = "vmware" ]; then
        if dpkg -l open-vm-tools-desktop 2>/dev/null | grep -q "^ii"; then
            log_ok "open-vm-tools-desktop ya instalado (copy-paste/drag-and-drop)"
        else
            log_info "Instalando open-vm-tools-desktop para VMware..."
            sudo apt install -y open-vm-tools-desktop
            log_ok "open-vm-tools-desktop instalado"
        fi
    fi
fi

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 10/10 — Verificación final
# ══════════════════════════════════════════════════════════════════════════════

log_section "PASO 10/10 — Verificación"

ALL_OK=true

# Añadir ~/.local/bin al PATH para detectar kitty y bat
export PATH="$HOME/.local/bin:$PATH"

# Binarios
BINS=(bspwm sxhkd picom polybar rofi feh kitty zsh scrot lsd batcat fzf xclip betterlockscreen i3lock)
for bin in "${BINS[@]}"; do
    if command -v "$bin" &>/dev/null; then
        printf "  ${GREEN}✓${NC} %-20s %s\n" "$bin" "$(which $bin)"
    else
        printf "  ${RED}✗${NC} %-20s %s\n" "$bin" "NO ENCONTRADO"
        ALL_OK=false
    fi
done

# Fuentes (comprobar archivos directamente, fc-list puede no estar actualizado aún)
echo ""
if [ -d "$HOME/.local/share/fonts/HackNerdFont" ] && ls "$HOME/.local/share/fonts/HackNerdFont/"*.ttf &>/dev/null; then
    log_ok "Hack Nerd Font instalada ($(ls $HOME/.local/share/fonts/HackNerdFont/*.ttf | wc -l) archivos)"
else
    log_error "Hack Nerd Font NO encontrada en ~/.local/share/fonts/HackNerdFont/"
    ALL_OK=false
fi

# Oh-My-Zsh + plugins (usuario)
DIRS_CHECK=(
    "$HOME/.oh-my-zsh"
    "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
)
for dir in "${DIRS_CHECK[@]}"; do
    if [ -d "$dir" ]; then
        log_ok "$(basename "$dir") ($USER)"
    else
        log_error "$(basename "$dir") NO encontrado ($USER)"
        ALL_OK=false
    fi
done

# Configs (usuario)
CONFIGS_CHECK=(
    "$HOME/.config/bspwm/bspwmrc"
    "$HOME/.config/sxhkd/sxhkdrc"
    "$HOME/.config/kitty/kitty.conf"
    "$HOME/.config/picom/picom.conf"
    "$HOME/.config/polybar/config.ini"
    "$HOME/.config/polybar/launch.sh"
    "$HOME/.config/rofi/config.rasi"
    "$HOME/.zshrc"
    "$HOME/.p10k.zsh"
)
for f in "${CONFIGS_CHECK[@]}"; do
    if [ -f "$f" ]; then
        log_ok "$(echo "$f" | sed "s|$HOME|~|")"
    else
        log_error "$(echo "$f" | sed "s|$HOME|~|") NO encontrado"
        ALL_OK=false
    fi
done

# Session file
if [ -f /usr/share/xsessions/bspwm.desktop ]; then
    log_ok "bspwm.desktop"
else
    log_error "bspwm.desktop NO encontrado"
    ALL_OK=false
fi

# Matar el sudo keepalive
kill $SUDO_KEEPALIVE_PID 2>/dev/null || true

# ══════════════════════════════════════════════════════════════════════════════
#  Mensaje final
# ══════════════════════════════════════════════════════════════════════════════

echo ""
if [ "$ALL_OK" = true ]; then
    echo -e "${GREEN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              ✓ INSTALACIÓN COMPLETADA                      ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║                                                            ║"
    echo "║  Pasos manuales después de reiniciar:                      ║"
    echo "║                                                            ║"
    echo "║  1. En LightDM, seleccionar sesión \"bspwm\"                 ║"
    echo "║  2. Abrir un terminal (super + Return) y ejecutar:         ║"
    echo "║     betterlockscreen -u ~/.config/bspwm/wallpaper.jpg      ║"
    echo "║     (genera el cache para la pantalla de bloqueo con blur) ║"
    echo "║                                                            ║"
    echo "║  Reiniciar ahora:  sudo reboot                             ║"
    echo "║                                                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
else
    echo -e "${YELLOW}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║          ⚠ INSTALACIÓN COMPLETADA CON ADVERTENCIAS         ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║                                                            ║"
    echo "║  Revisa los errores marcados con ✗ arriba.                 ║"
    echo "║  El script es re-ejecutable: corrige y vuelve a lanzar.    ║"
    echo "║                                                            ║"
    echo "║  Si todo funciona correctamente después de reiniciar:      ║"
    echo "║  1. En LightDM, seleccionar sesión \"bspwm\"                 ║"
    echo "║  2. Ejecutar: betterlockscreen -u ~/.config/bspwm/wall...  ║"
    echo "║                                                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
fi

# Aviso de VM después del cuadro
if [ "$IS_VM" = true ]; then
    echo -e "${YELLOW}${BOLD}  ⚠ Máquina virtual detectada: $VM_TYPE${NC}"
    echo -e "${YELLOW}  Si experimentas lag gráfico, parpadeo o pantalla negra:${NC}"
    echo -e "${YELLOW}    1. Verifica que la aceleración 3D está activada en la VM${NC}"
    echo -e "${YELLOW}    2. Asigna un mínimo de 128 MB de VRAM${NC}"
    echo -e "${YELLOW}    3. Si sigue fallando, cambia en ~/.config/picom/picom.conf:${NC}"
    echo -e "${YELLOW}       backend = \"glx\";  →  backend = \"xrender\";${NC}"
    echo ""
fi
