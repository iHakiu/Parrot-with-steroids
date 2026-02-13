# ====================================
# ZSH Configuration
# ====================================

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ====================================
# Custom Functions for Pentesting
# ====================================

# Function: settarget
# Description: Set target IP for current pentesting session
# Usage: settarget 10.10.10.123
function settarget() {
    if [ $# -eq 0 ]; then
        echo "Usage: settarget <IP>"
        return 1
    fi
    
    ip_address=$1
    
    # Validate IP format
    if [[ ! $ip_address =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "Error: Invalid IP address format"
        return 1
    fi
    
    # Save target to file for polybar
    echo $ip_address > /tmp/target
    
    # Export as environment variable
    export TARGET=$ip_address
    
    echo "[+] Target set to: $ip_address"
}

# Function: cleartarget
# Description: Clear the current target
# Usage: cleartarget
function cleartarget() {
    rm -f /tmp/target 2>/dev/null
    unset TARGET
    echo "[+] Target cleared"
}

# Function: mkt
# Description: Create directory structure for CTF/pentesting
# Usage: mkt machine_name
function mkt() {
    if [ $# -eq 0 ]; then
        echo "Usage: mkt <directory_name>"
        return 1
    fi
    
    dir_name=$1
    
    # Create main directory
    mkdir -p "$dir_name"
    cd "$dir_name" || return
    
    # Create subdirectories
    mkdir -p content exploits nmap scripts
    
    echo "[+] Directory structure created:"
    echo "    $dir_name/"
    echo "    ├── content/"
    echo "    ├── exploits/"
    echo "    ├── nmap/"
    echo "    └── scripts/"
}

# ====================================
# Aliases
# ====================================

# ls aliases using lsd
alias ls='lsd'
alias ll='lsd -lh'
alias la='lsd -lah'
alias lt='lsd --tree'

# cat alias using bat (si necesitas el cat original usa /bin/cat)
alias cat='batcat --paging=never'
alias bathelp='batcat --help'

# System aliases
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias q='exit'

# Network aliases
alias myip='curl ifconfig.me'
alias ports='netstat -tulanp'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'

# HTB/Pentesting aliases
alias hping='ping -c 1'  # Single ping
alias webserver='python3 -m http.server 8000'
alias phpserver='php -S 0.0.0.0:8080'

# ====================================
# Environment Variables
# ====================================

# Path
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR='nvim'
export VISUAL='nvim'

# Colors for man pages
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# ====================================
# Powerlevel10k Configuration
# ====================================

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ====================================
# Additional Configurations
# ====================================

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# Auto cd
setopt AUTO_CD

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ====================================
# Welcome Message
# ====================================

# Optional: Show system info on terminal start
# neofetch
