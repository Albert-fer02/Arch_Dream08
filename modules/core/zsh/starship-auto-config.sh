#!/bin/bash
# =====================================================
# 🚀 STARSHIP AUTO-CONFIGURATION SCRIPT
# =====================================================
# Detecta automáticamente el entorno y configura Starship
# =====================================================

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Silencio por defecto: solo mostrar logs si STARSHIP_VERBOSE=1 o --verbose
QUIET=1
for arg in "$@"; do
    if [[ "$arg" == "--verbose" ]]; then
        QUIET=0
    fi
done
if [[ -n "${STARSHIP_VERBOSE:-}" ]]; then
    QUIET=0
fi

# Funciones de log (silenciables)
log() {
    [[ "$QUIET" -eq 1 ]] && return
    echo -e "${CYAN}[INFO]${NC} $1"
}

success() {
    [[ "$QUIET" -eq 1 ]] && return
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    [[ "$QUIET" -eq 1 ]] && return
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    [[ "$QUIET" -eq 1 ]] && return
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para configurar variables de entorno faltantes
setup_environment_variables() {
    log "Configurando variables de entorno..."
    
    # Configurar TERM_PROGRAM si no está definido
    if [[ -z "${TERM_PROGRAM:-}" ]]; then
        if [[ -n "${KITTY_WINDOW_ID:-}" ]]; then
            export TERM_PROGRAM="kitty"
            log "TERM_PROGRAM configurado como 'kitty'"
        elif [[ "${TERM:-}" == "xterm-256color" ]]; then
            export TERM_PROGRAM="xterm"
            log "TERM_PROGRAM configurado como 'xterm'"
        else
            export TERM_PROGRAM="unknown"
            log "TERM_PROGRAM configurado como 'unknown'"
        fi
    fi
    
    # Configurar LS_COLORS si no está definido
    if [[ -z "${LS_COLORS:-}" ]]; then
        export LS_COLORS=""
        log "LS_COLORS configurado como vacío"
    fi
    
    # Configurar STARSHIP_CMD_STATUS si no está definido
    if [[ -z "${STARSHIP_CMD_STATUS:-}" ]]; then
        export STARSHIP_CMD_STATUS="0"
        log "STARSHIP_CMD_STATUS configurado como '0'"
    fi
    
    success "Variables de entorno configuradas"
}

# Función para detectar el entorno
detect_environment() {
    log "Detectando entorno..."
    
    # Detectar terminal
    if [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
        ENV_TYPE="vscode"
        log "Entorno detectado: VS Code Terminal"
    elif [[ -n "${KITTY_WINDOW_ID:-}" ]]; then
        ENV_TYPE="kitty"
        log "Entorno detectado: Kitty Terminal"
    elif [[ "${TERM_PROGRAM:-}" == "WarpTerminal" ]]; then
        ENV_TYPE="warp"
        log "Entorno detectado: Warp Terminal"
    elif [[ "${TERM:-}" == "xterm-256color" && -z "${TERM_PROGRAM:-}" ]]; then
        ENV_TYPE="xterm"
        log "Entorno detectado: XTerm compatible"
    else
        ENV_TYPE="unknown"
        log "Entorno detectado: Desconocido (${TERM:-unknown})"
    fi
    
    # Detectar soporte de colores
    if [[ "${COLORTERM:-}" == "truecolor" || "${COLORTERM:-}" == "24bit" ]]; then
        COLOR_SUPPORT="truecolor"
        log "Soporte de colores: True Color (24-bit)"
    elif [[ "${TERM:-}" == *"256color"* ]]; then
        COLOR_SUPPORT="256color"
        log "Soporte de colores: 256 colores"
    else
        COLOR_SUPPORT="basic"
        log "Soporte de colores: Básico"
    fi
    
    success "Entorno: $ENV_TYPE, Colores: $COLOR_SUPPORT"
}

# Función para configurar tema apropiado
configure_theme() {
    log "Configurando tema de Starship..."
    
    local theme_dir="$HOME/.config"
    local repo_dir="$HOME/Documentos/PROYECTOS/Arch_Dream08"
    
    # Crear directorio de configuración si no existe
    mkdir -p "$theme_dir"
    
    case "$ENV_TYPE" in
        "vscode")
            if [[ "$COLOR_SUPPORT" == "truecolor" ]]; then
                # VS Code con soporte de colores completo - usar tema simplificado
                local theme_source="$repo_dir/modules/themes/catppuccin/catppuccin-mocha-vscode-simple.toml"
                if [[ -f "$theme_source" ]]; then
                    ln -sf "$theme_source" "$theme_dir/starship.toml"
                    success "Tema Catppuccin Mocha VS Code simplificado configurado"
                else
                    # Fallback al tema completo
                    local fallback_theme="$repo_dir/modules/themes/catppuccin/catppuccin-mocha.toml"
                    if [[ -f "$fallback_theme" ]]; then
                        ln -sf "$fallback_theme" "$theme_dir/starship.toml"
                        success "Tema Catppuccin Mocha completo configurado para VS Code"
                    else
                        warn "Tema Catppuccin Mocha no encontrado, usando tema simple"
                        create_simple_theme "$theme_dir"
                    fi
                fi
            else
                # VS Code con soporte limitado de colores
                create_simple_theme "$theme_dir"
            fi
            ;;
        "kitty"|"warp")
            # Terminales modernos con soporte completo
            local theme_source="$repo_dir/modules/themes/catppuccin/catppuccin-mocha.toml"
            if [[ -f "$theme_source" ]]; then
                ln -sf "$theme_source" "$theme_dir/starship.toml"
                success "Tema Catppuccin Mocha configurado para terminal moderno"
            else
                warn "Tema Catppuccin Mocha no encontrado, usando tema simple"
                create_simple_theme "$theme_dir"
            fi
            ;;
        "xterm"|"unknown")
            # Terminales básicos
            create_simple_theme "$theme_dir"
            ;;
    esac
}

# Función para crear tema simple
create_simple_theme() {
    local theme_dir="$1"
    local simple_theme="$theme_dir/starship-simple.toml"
    
    cat > "$simple_theme" << 'EOF'
# =====================================================
# 🚀 STARSHIP PROMPT - SIMPLE & COMPATIBLE
# =====================================================
# Configuración ultra-simple para máxima compatibilidad
# =====================================================

# Formato básico sin colores complejos
format = "$username@$hostname $directory $git_branch$git_status $character"

# Sin formato derecho
right_format = ""

# Configuración básica
add_newline = true
command_timeout = 1000
scan_timeout = 30

# Usuario y hostname - sin colores
[username]
format = "$user"

[hostname]
format = "@$hostname "

# Directorio - sin colores
[directory]
format = "$path "
truncation_length = 3
truncation_symbol = "..."

# Git - sin colores
[git_branch]
symbol = " "
format = "$symbol$branch "

[git_status]
format = "($all_status$ahead_behind) "

# Prompt character - sin colores
[character]
success_symbol = "❯"
error_symbol = "❯"
vicmd_symbol = "❮"

# Deshabilitar todos los módulos problemáticos
[python]
disabled = true

[nodejs]
disabled = true

[rust]
disabled = true

[memory_usage]
disabled = true

[battery]
disabled = true

[time]
disabled = true

[cmd_duration]
disabled = true

[package]
disabled = true

[docker_context]
disabled = true
EOF
    
    ln -sf "$simple_theme" "$theme_dir/starship.toml"
    success "Tema simple creado y configurado"
}

# Función para verificar configuración
verify_configuration() {
    log "Verificando configuración..."
    
    if [[ -L "$HOME/.config/starship.toml" ]]; then
        local target=$(readlink -f "$HOME/.config/starship.toml")
        success "Configuración de Starship: $target"
        
        # Verificar que el tema funciona
        if command -v starship &>/dev/null; then
            if [[ "$QUIET" -eq 0 ]]; then
                # Establecer variables de entorno por defecto para la prueba (solo en modo verbose)
                local test_output=$(STARSHIP_CMD_STATUS=0 STARSHIP_DURATION=0 starship prompt --status=0 --cmd-duration=0 --terminal-width=60 2>/dev/null | head -n 2)
                if [[ -n "$test_output" ]]; then
                    success "Tema de Starship funciona correctamente"
                    echo "Preview del prompt:"
                    echo "$test_output"
                else
                    warn "Tema de Starship no produce output"
                fi
            fi
        else
            warn "Starship no está instalado"
        fi
    else
        error "Configuración de Starship no encontrada"
        return 1
    fi
}

# Función para crear alias de configuración
create_config_alias() {
    log "Creando alias de configuración..."
    
    local zsh_local="$HOME/.zshrc.local"
    
    # Crear archivo si no existe
    touch "$zsh_local"
    
    # Agregar función de configuración automática si no existe
    if ! grep -q "starship-auto-config" "$zsh_local"; then
        cat >> "$zsh_local" << 'EOF'

# =====================================================
# 🚀 CONFIGURACIÓN AUTOMÁTICA DE STARSHIP
# =====================================================

# Función para reconfigurar Starship automáticamente
starship-reconfig() {
    if [[ -f "$HOME/Documentos/PROYECTOS/Arch_Dream08/modules/core/zsh/starship-auto-config.sh" ]]; then
        bash "$HOME/Documentos/PROYECTOS/Arch_Dream08/modules/core/zsh/starship-auto-config.sh"
    else
        echo "Script de configuración automática no encontrado"
    fi
}

# Configurar Starship automáticamente al cargar (solo si no está configurado)
if [[ -f "$HOME/Documentos/PROYECTOS/Arch_Dream08/modules/core/zsh/starship-auto-config.sh" ]]; then
    # Solo ejecutar si no está ya configurado y no estamos en modo interactivo
    if [[ ! -L "$HOME/.config/starship.toml" && -t 0 ]]; then
        echo "Configurando Starship automáticamente..."
        bash "$HOME/Documentos/PROYECTOS/Arch_Dream08/modules/core/zsh/starship-auto-config.sh" >/dev/null 2>&1 &
    fi
fi
EOF
        success "Alias y configuración automática agregados a ~/.zshrc.local"
    else
        success "Configuración automática ya existe"
    fi
}

# Función principal
main() {
    if [[ "$QUIET" -eq 0 ]]; then
        echo -e "${BOLD}${BLUE}🚀 CONFIGURACIÓN AUTOMÁTICA DE STARSHIP${NC}"
        echo -e "${CYAN}Detectando entorno y configurando tema apropiado${NC}\n"
    fi
    
    # Configurar variables de entorno
    setup_environment_variables
    
    # Detectar entorno
    detect_environment
    
    # Configurar tema
    configure_theme
    
    # Verificar configuración
    verify_configuration
    
    # Crear alias
    create_config_alias
    
    if [[ "$QUIET" -eq 0 ]]; then
        echo
        success "✅ Configuración automática de Starship completada"
        echo -e "${CYAN}💡 Para reconfigurar manualmente: ${YELLOW}starship-reconfig${NC}"
        echo -e "${CYAN}🔄 Recarga tu terminal o ejecuta: ${YELLOW}source ~/.zshrc${NC}"
    fi
}

# Ejecutar si se llama directamente
if [[ "${0}" == *"starship-auto-config.sh" ]]; then
    main "$@"
fi
