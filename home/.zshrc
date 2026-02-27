# ─── Powerlevel10k instant prompt ─────────────────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── Oh-My-ZSH ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    sudo
    command-not-found
    extract
    colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# ─── Historial ────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt AUTO_CD

# ─── Completado ───────────────────────────────────────────────────────────────
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ─── Colores man pages ────────────────────────────────────────────────────────
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Añadir ~/.local/bin al PATH solo si no está ya
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# ─── Editor (activar cuando se instale Neovim en Fase 6) ──────────────────────
# export EDITOR='nvim'
# export VISUAL='nvim'

# ─── Aliases sistema ──────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias now='date +"%d-%m-%Y %T"'

# ─── Aliases lsd/bat (activar en Fase 7) ─────────────────────────────────────
alias ls='lsd'
alias ll='lsd -lh'
alias la='lsd -lah'
alias lt='lsd --tree'
alias cat='batcat --paging=never'

# ─── Aliases red ──────────────────────────────────────────────────────────────
alias myip='curl ifconfig.me'
alias ports='netstat -tulanp'

# ─── Aliases pentesting ───────────────────────────────────────────────────────
alias hping='ping -c 1'
alias webserver='python3 -m http.server 8000'
alias phpserver='php -S 0.0.0.0:8080'

# ─── Aliases git ──────────────────────────────────────────────────────────────
alias gs='git status'
alias gl='git log --oneline --graph'

# ─── Listados con colores ────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'

# ─────────────────────────────────────────────────────────────────────────────
# FUNCIONES PENTESTING PERSONALIZADAS
# ─────────────────────────────────────────────────────────────────────────────

# settarget — Establece el target actual (IP con nombre opcional)
# Uso: settarget <IP>              → guarda solo IP
#      settarget <nombre> <IP>     → guarda "nombre - IP"
function settarget() {
    local target_file="/tmp/target"
    
    if [ $# -eq 0 ]; then
        echo "Usage: settarget <IP> o settarget <nombre> <IP>"
        return 1
    fi
    
    # Si solo hay 1 argumento, validar que sea una IP
    if [ $# -eq 1 ]; then
        if [[ ! $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            echo "Error: '$1' no es una IP válida"
            return 1
        fi
        echo "$1" > "$target_file"
        export TARGET="$1"
        echo "[+] Target: $1"
    
    # Si hay 2 argumentos, el segundo debe ser la IP
    elif [ $# -eq 2 ]; then
        if [[ ! $2 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            echo "Error: '$2' no es una IP válida"
            return 1
        fi
        echo "$1 - $2" > "$target_file"
        export TARGET="$2"
        echo "[+] Target: $1 - $2"
    
    else
        echo "Error: Demasiados argumentos"
        echo "Usage: settarget <IP> o settarget <nombre> <IP>"
        return 1
    fi
}

# cleartarget — Limpia el target actual
function cleartarget() {
    rm -f /tmp/target 2>/dev/null
    unset TARGET
    echo "[+] Target cleared"
}

# mkt — Crea estructura de directorios para una máquina CTF/HTB
# Uso: mkt <nombre_maquina>
function mkt() {
    if [ $# -eq 0 ]; then
        echo "Usage: mkt <directory_name>"
        return 1
    fi
    
    mkdir -p "$1"
    cd "$1" || return
    mkdir -p content exploits nmap scripts
    
    echo "[+] Directory structure created:"
    echo "    $PWD/"
    echo "    ├── content/"
    echo "    ├── exploits/"
    echo "    ├── nmap/"
    echo "    └── scripts/"
}

# extractPorts — Extrae puertos de archivo grepeable de nmap
# Uso: extractPorts <archivo.gnmap>
function extractPorts() {
    if [ $# -eq 0 ]; then
        echo "Usage: extractPorts <nmap_grepable_file>"
        return 1
    fi
    
    ports="$(cat "$1" | grep -oP '\d{1,5}/open' | awk -F'/' '{print $1}' | xargs | tr ' ' ',')"
    
    if [ -z "$ports" ]; then
        echo "[-] No open ports found in $1"
        return 1
    fi
    
    ip_address="$(cat "$1" | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
    
    echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
    echo -e "\t[*] IP Address: $ip_address" >> extractPorts.tmp
    echo -e "\t[*] Open ports: $ports\n" >> extractPorts.tmp
    echo -e "[*] Ports copied to clipboard\n" >> extractPorts.tmp
    
    cat extractPorts.tmp
    echo "$ports" | tr -d '\n' | xclip -sel clip
    rm extractPorts.tmp
}

# ─── Powerlevel10k config ─────────────────────────────────────────────────────
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh


# ─── fzf fuzzy finder ────────────────────────────────────────────────────────
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && \
    source /usr/share/doc/fzf/examples/key-bindings.zsh

[ -f /usr/share/doc/fzf/examples/completion.zsh ] && \
    source /usr/share/doc/fzf/examples/completion.zsh
