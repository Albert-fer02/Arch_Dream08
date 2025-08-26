#!/bin/zsh
# =====================================================
# 🔧 VARIABLES DE ENTORNO ESENCIALES - ZSH
# =====================================================

# Variables básicas del sistema
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export BROWSER='firefox'
export TERMINAL='kitty'

# Configuración de idioma
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Variables de ZSH
export ZDOTDIR="${HOME}"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
export ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump-${ZSH_VERSION}"

# Crear directorio de cache
mkdir -p "$ZSH_CACHE_DIR" 2>/dev/null

# Configuración de colores
export LS_COLORS="${LS_COLORS:-di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43}"
export GREP_COLOR='1;32'

# PATH inteligente (sin duplicados)
typeset -U path
path=(
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    $path
)
export PATH

# Variables de desarrollo
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export CARGO_HOME="$HOME/.cargo"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"

# Variables XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Configuración de herramientas
export MANPAGER='nvim +Man!'
export LESS='-R --use-color -Dd+r$Du+b$'
export HISTSIZE=50000
export SAVEHIST=10000

# Variables de Arch Dream
export ARCH_DREAM_VERSION="4.3"
export ARCH_DREAM_PROFILE="${ARCH_DREAM_PROFILE:-developer}"
