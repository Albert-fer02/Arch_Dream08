#!/bin/bash
# =====================================================
# 🔧 VARIABLES DE ENTORNO PARA BASH - ARCH DREAM v4.3
# =====================================================

# Cargar configuración dinámica si está disponible
if command -v config_get >/dev/null 2>&1; then
    EDITOR=$(config_get "environment.variables.EDITOR" "nvim")
    BROWSER=$(config_get "environment.variables.BROWSER" "firefox")
    TERMINAL=$(config_get "environment.variables.TERMINAL" "kitty")
else
    # Fallback a valores por defecto
    EDITOR='nvim'
    BROWSER='firefox'
    TERMINAL='kitty'
fi

# Variables de entorno básicas con fallback inteligente
export EDITOR="${EDITOR:-nano}"
export VISUAL="$EDITOR"
export BROWSER="${BROWSER:-firefox}"
export TERMINAL="${TERMINAL:-gnome-terminal}"

# Configuración de locale con validación
setup_locale() {
    local desired_locale="${ARCH_DREAM_LOCALE:-en_US.UTF-8}"
    
    # Validar que el locale existe en el sistema
    if locale -a 2>/dev/null | grep -q "^${desired_locale%.*}"; then
        export LANG="$desired_locale"
        export LC_ALL="$desired_locale"
    else
        # Fallback a C.UTF-8 si está disponible
        if locale -a 2>/dev/null | grep -q "C.UTF-8"; then
            export LANG="C.UTF-8"
            export LC_ALL="C.UTF-8"
        else
            # Último fallback a C
            export LANG="C"
            export LC_ALL="C"
        fi
    fi
}

setup_locale

# Configuración de PATH dinámica
setup_path() {
    local additional_paths=()
    
    # Cargar paths adicionales desde configuración
    if command -v config_get >/dev/null 2>&1; then
        local config_paths=$(config_get "environment.paths.additional" "")
        if [[ -n "$config_paths" ]]; then
            # Convertir array de configuración a array bash
            readarray -t additional_paths <<< "$config_paths"
        fi
    fi
    
    # Paths comunes por defecto
    local default_paths=(
        "$HOME/.local/bin"
        "$HOME/.cargo/bin"
        "$HOME/go/bin"
        "$HOME/.npm-global/bin"
        "/opt/homebrew/bin"  # macOS compatibility
    )
    
    # Combinar paths
    local all_paths=("${additional_paths[@]}" "${default_paths[@]}")
    
    # Agregar al PATH solo si el directorio existe y no está ya en PATH
    for path_dir in "${all_paths[@]}"; do
        # Expandir variables
        path_dir=$(eval echo "$path_dir")
        
        if [[ -d "$path_dir" && ":$PATH:" != *":$path_dir:"* ]]; then
            export PATH="$path_dir:$PATH"
        fi
    done
}

setup_path

# Variables de configuración de Arch Dream
export ARCH_DREAM_DEBUG="${ARCH_DREAM_DEBUG:-false}"
export ARCH_DREAM_PROFILE="${ARCH_DREAM_PROFILE:-default}"
export ARCH_DREAM_THEME="${ARCH_DREAM_THEME:-catppuccin}"

# Variables para herramientas de desarrollo
setup_dev_env_vars() {
    # Node.js
    export NODE_ENV="${NODE_ENV:-development}"
    export NPM_CONFIG_PROGRESS="${NPM_CONFIG_PROGRESS:-true}"
    
    # Python
    export PYTHONDONTWRITEBYTECODE="${PYTHONDONTWRITEBYTECODE:-1}"
    export PYTHONUNBUFFERED="${PYTHONUNBUFFERED:-1}"
    
    # Rust
    export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
    export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"
    
    # Go
    export GOPATH="${GOPATH:-$HOME/go}"
    export GOPROXY="${GOPROXY:-https://proxy.golang.org,direct}"
    
    # Docker
    export DOCKER_BUILDKIT="${DOCKER_BUILDKIT:-1}"
    export COMPOSE_DOCKER_CLI_BUILD="${COMPOSE_DOCKER_CLI_BUILD:-1}"
}

setup_dev_env_vars

# Variables de cache y configuración
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Configuración de herramientas comunes
setup_tool_env() {
    # FZF
    export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height=60% --layout=reverse --border --margin=1}"
    
    # Bat (better cat)
    export BAT_THEME="${BAT_THEME:-Catppuccin-macchiato}"
    
    # Less
    export LESS="${LESS:--R --use-color -Dd+r -Du+b}"
    export LESSHISTFILE="${LESSHISTFILE:-$XDG_CACHE_HOME/less/history}"
    
    # Ripgrep
    export RIPGREP_CONFIG_PATH="${RIPGREP_CONFIG_PATH:-$XDG_CONFIG_HOME/ripgrep/config}"
}

setup_tool_env

# Configuración de terminal
setup_terminal_env() {
    # Mejorar colores y soporte
    if [[ "$TERM" == "xterm" ]]; then
        export TERM="xterm-256color"
    fi
    
    # Configuración de GPG para terminal
    export GPG_TTY=$(tty)
    
    # SSH Agent
    if [[ -z "${SSH_AUTH_SOCK:-}" ]] && command -v ssh-agent >/dev/null 2>&1; then
        eval "$(ssh-agent -s)" >/dev/null 2>&1
    fi
}

setup_terminal_env

# Log de configuración si debug está habilitado
if [[ "$ARCH_DREAM_DEBUG" == "true" ]] && command -v log_debug >/dev/null 2>&1; then
    log_debug "Environment setup completed - Editor: $EDITOR, Locale: $LANG, Profile: $ARCH_DREAM_PROFILE"
fi
