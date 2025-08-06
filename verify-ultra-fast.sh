#!/bin/bash
# My Powerlevel10k Configuration
# ---------------------------------------------------------------------
# ╔═════════════════════════════════════════════════════════════
# ║                     𓂀 DreamCoder 08 𓂀                     ║
# ║                ⚡ Digital Dream Architect ⚡                 ║
# ║                                                            ║
# ║        Author: https://github.com/Albert-fer02             ║
# ╚══════════════════════════════════════════════════════════════╝
# ---------------------------------------------------------------------    
# =====================================================
# ⚡ VERIFICACIÓN ULTRA RÁPIDA v2.0
# =====================================================
# Script para verificar rápidamente que todas las
# herramientas de productividad estén funcionando
# Versión mejorada con validaciones avanzadas
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común mejorada
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# =====================================================
# 🔧 CONFIGURACIÓN Y VARIABLES
# =====================================================

SCRIPT_NAME="Arch Dream Verification Tool"
SCRIPT_VERSION="2.0"

# Variables de control
VERBOSE=${VERBOSE:-false}
QUIET=${QUIET:-false}
EXPORT_REPORT=${EXPORT_REPORT:-false}
REPORT_FILE="$HOME/arch_dream_verification_$(date +%Y%m%d_%H%M%S).txt"

# Configurar nivel de logging
if [[ "$VERBOSE" == "true" ]]; then
    LOG_LEVEL="DEBUG"
fi

if [[ "$QUIET" == "true" ]]; then
    LOG_LEVEL="ERROR"
fi

# Contadores
PASSED=0
FAILED=0
WARNINGS=0
TOTAL=0

# =====================================================
# 🔧 FUNCIONES DE VERIFICACIÓN MEJORADAS
# =====================================================

# Función para mostrar ayuda
show_help() {
    cat << EOF
${BOLD}${CYAN}$SCRIPT_NAME v$SCRIPT_VERSION${COLOR_RESET}

${PURPLE}Uso:${COLOR_RESET} $0 [OPCIONES]

${PURPLE}Opciones:${COLOR_RESET}
  -h, --help          Mostrar esta ayuda
  -v, --verbose       Modo verbose con más información
  -q, --quiet         Modo silencioso (solo errores)
  -e, --export        Exportar reporte a archivo
  -s, --system        Verificar solo sistema básico
  -t, --tools         Verificar solo herramientas
  -c, --configs       Verificar solo configuraciones

${PURPLE}Variables de entorno:${COLOR_RESET}
  VERBOSE=true        Modo verbose
  QUIET=true          Modo silencioso
  EXPORT_REPORT=true  Exportar reporte
  LOG_LEVEL=DEBUG     Nivel de logging

${PURPLE}Ejemplos:${COLOR_RESET}
  $0                    # Verificación completa
  $0 --verbose         # Verificación detallada
  $0 --export          # Exportar reporte
  $0 --tools           # Solo herramientas

EOF
}

# Función para parsear argumentos
parse_arguments() {
    local check_system=true
    local check_tools=true
    local check_configs=true
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -q|--quiet)
                QUIET=true
                LOG_LEVEL="ERROR"
                shift
                ;;
            -e|--export)
                EXPORT_REPORT=true
                shift
                ;;
            -s|--system)
                check_tools=false
                check_configs=false
                shift
                ;;
            -t|--tools)
                check_system=false
                check_configs=false
                shift
                ;;
            -c|--configs)
                check_system=false
                check_tools=false
                shift
                ;;
            *)
                error "Opción desconocida: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Configurar qué verificar
    VERIFY_SYSTEM=${check_system}
    VERIFY_TOOLS=${check_tools}
    VERIFY_CONFIGS=${check_configs}
}

# Función para verificar herramienta (mejorada)
check_tool() {
    local tool="$1"
    local description="$2"
    local critical="${3:-false}"
    
    TOTAL=$((TOTAL + 1))
    
    if command -v "$tool" >/dev/null 2>&1; then
        if [[ "$critical" == "true" ]]; then
            success "$tool - $description (CRÍTICO)"
        else
            success "$tool - $description"
        fi
        PASSED=$((PASSED + 1))
        return 0
    else
        if [[ "$critical" == "true" ]]; then
            error "$tool - $description (CRÍTICO)"
        else
            error "$tool - $description"
        fi
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Función para verificar archivo (mejorada)
check_file() {
    local file="$1"
    local description="$2"
    local critical="${3:-false}"
    
    TOTAL=$((TOTAL + 1))
    
    if [[ -f "$file" ]]; then
        if [[ "$critical" == "true" ]]; then
            success "$description (CRÍTICO)"
        else
            success "$description"
        fi
        PASSED=$((PASSED + 1))
        return 0
    else
        if [[ "$critical" == "true" ]]; then
            error "$description (CRÍTICO)"
        else
            error "$description"
        fi
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Función para verificar directorio (mejorada)
check_dir() {
    local dir="$1"
    local description="$2"
    local critical="${3:-false}"
    
    TOTAL=$((TOTAL + 1))
    
    if [[ -d "$dir" ]]; then
        if [[ "$critical" == "true" ]]; then
            success "$description (CRÍTICO)"
        else
            success "$description"
        fi
        PASSED=$((PASSED + 1))
        return 0
    else
        if [[ "$critical" == "true" ]]; then
            error "$description (CRÍTICO)"
        else
            error "$description"
        fi
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Función para verificar symlink
check_symlink() {
    local symlink="$1"
    local description="$2"
    local critical="${3:-false}"
    
    TOTAL=$((TOTAL + 1))
    
    if [[ -L "$symlink" ]] && [[ -e "$symlink" ]]; then
        if [[ "$critical" == "true" ]]; then
            success "$description (CRÍTICO)"
        else
            success "$description"
        fi
        PASSED=$((PASSED + 1))
        return 0
    else
        if [[ "$critical" == "true" ]]; then
            error "$description (CRÍTICO)"
        else
            error "$description"
        fi
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Función para verificar configuración
check_config() {
    local config="$1"
    local description="$2"
    local critical="${3:-false}"
    
    TOTAL=$((TOTAL + 1))
    
    if [[ -e "$config" ]]; then
        if [[ "$critical" == "true" ]]; then
            success "$description (CRÍTICO)"
        else
            success "$description"
        fi
        PASSED=$((PASSED + 1))
        return 0
    else
        if [[ "$critical" == "true" ]]; then
            error "$description (CRÍTICO)"
        else
            error "$description"
        fi
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Función para verificar sistema básico
verify_system_basic() {
    log "Verificando sistema básico..."
    
    # Verificar sistema operativo
    check_tool "pacman" "Gestor de paquetes Pacman" "true"
    check_tool "sudo" "Permisos de superusuario" "true"
    check_tool "curl" "Cliente HTTP" "false"
    check_tool "wget" "Descargador web" "false"
    
    # Verificar shell
    check_tool "zsh" "Shell Zsh" "true"
    check_tool "bash" "Shell Bash" "false"
    
    # Verificar herramientas básicas
    check_tool "git" "Control de versiones" "false"
    check_tool "unzip" "Extractor de archivos" "false"
    check_tool "tree" "Visualizador de directorios" "false"
}

# Función para verificar herramientas principales
verify_core_tools() {
    log "Verificando herramientas principales..."
    
    # Terminales
    check_tool "kitty" "Terminal Kitty" "false"
    check_tool "alacritty" "Terminal Alacritty" "false"
    
    # Herramientas modernas
    check_tool "eza" "Listador moderno" "false"
    check_tool "bat" "Cat moderno" "false"
    check_tool "ripgrep" "Grep moderno" "false"
    check_tool "fd" "Buscador moderno" "false"
    check_tool "fzf" "Fuzzy finder" "false"
    
    # Monitores de sistema
    check_tool "btop" "Monitor de sistema" "false"
    check_tool "htop" "Monitor de sistema alternativo" "false"
    check_tool "duf" "DF moderno" "false"
    check_tool "dust" "DU moderno" "false"
    check_tool "fastfetch" "Información del sistema" "false"
    check_tool "neofetch" "Información del sistema alternativo" "false"
}

# Función para verificar editores
verify_editors() {
    log "Verificando editores..."
    
    check_tool "nvim" "Editor Neovim" "false"
    check_tool "vim" "Editor Vim" "false"
    check_tool "nano" "Editor Nano" "false"
    check_tool "micro" "Editor Micro" "false"
}

# Función para verificar herramientas de desarrollo
verify_dev_tools() {
    log "Verificando herramientas de desarrollo..."
    
    # Lenguajes de programación
    check_tool "python" "Python" "false"
    check_tool "python3" "Python 3" "false"
    check_tool "node" "Node.js" "false"
    check_tool "npm" "NPM" "false"
    check_tool "rustc" "Rust" "false"
    check_tool "cargo" "Cargo" "false"
    check_tool "go" "Go" "false"
    
    # Gestores de paquetes
    check_tool "pip" "Pip" "false"
    check_tool "pip3" "Pip 3" "false"
    check_tool "yay" "AUR Helper (yay)" "false"
    check_tool "paru" "AUR Helper (paru)" "false"
}

# Función para verificar configuraciones de shell
verify_shell_configs() {
    log "Verificando configuraciones de shell..."
    
    # Configuraciones de Zsh
    check_file "$HOME/.zshrc" "Configuración de Zsh" "true"
    check_file "$HOME/.p10k.zsh" "Configuración de Powerlevel10k" "false"
    check_dir "$HOME/.oh-my-zsh" "Oh My Zsh" "false"
    
    # Configuraciones de Bash
    check_file "$HOME/.bashrc" "Configuración de Bash" "false"
    
    # Configuraciones de root
    check_file "/root/.zshrc" "Configuración de Zsh (root)" "false"
    check_file "/root/.p10k.zsh" "Configuración de Powerlevel10k (root)" "false"
    check_file "/root/.bashrc" "Configuración de Bash (root)" "false"
}

# Función para verificar configuraciones de terminal
verify_terminal_configs() {
    log "Verificando configuraciones de terminal..."
    
    check_dir "$HOME/.config/kitty" "Configuración de Kitty" "false"
    check_file "$HOME/.config/kitty/kitty.conf" "Archivo de configuración de Kitty" "false"
    check_file "$HOME/.config/kitty/colors-dreamcoder.conf" "Tema de colores de Kitty" "false"
}

# Función para verificar configuraciones de herramientas
verify_tool_configs() {
    log "Verificando configuraciones de herramientas..."
    
    # Fastfetch
    check_dir "$HOME/.config/fastfetch" "Configuración de Fastfetch" "false"
    check_file "$HOME/.config/fastfetch/config.jsonc" "Configuración de Fastfetch" "false"
    
    # Nano
    check_file "$HOME/.nanorc" "Configuración de Nano" "false"
    
    # Neovim
    check_dir "$HOME/.config/nvim" "Configuración de Neovim" "false"
    check_file "$HOME/.config/nvim/init.lua" "Configuración de Neovim" "false"
    
    # Git
    check_file "$HOME/.gitconfig" "Configuración de Git" "false"
}

# Función para verificar fuentes
verify_fonts() {
    log "Verificando fuentes..."
    
    local font_paths=(
        "/usr/share/fonts/TTF/MesloLGS NF Regular.ttf"
        "/usr/share/fonts/nerd-fonts-meslo/MesloLGS NF Regular.ttf"
        "$HOME/.local/share/fonts/MesloLGS NF Regular.ttf"
        "/usr/share/fonts/ttf-meslo-nerd-font-powerlevel10k/MesloLGS NF Regular.ttf"
    )
    
    local font_found=false
    for font_path in "${font_paths[@]}"; do
        if [[ -f "$font_path" ]]; then
            success "Fuente Nerd Font encontrada: $(basename "$font_path")"
            font_found=true
            break
        fi
    done
    
    if [[ "$font_found" == "false" ]]; then
        warn "No se encontraron fuentes Nerd Font"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    TOTAL=$((TOTAL + 1))
    if [[ "$font_found" == "true" ]]; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
}

# Función para verificar permisos
verify_permissions() {
    log "Verificando permisos..."
    
    # Verificar permisos de archivos críticos
    local critical_files=(
        "$HOME/.zshrc:644"
        "$HOME/.bashrc:644"
        "$HOME/.p10k.zsh:644"
    )
    
    for file_perm in "${critical_files[@]}"; do
        IFS=':' read -r file expected_perm <<< "$file_perm"
        
        if [[ -f "$file" ]]; then
            local actual_perm=$(stat -c %a "$file")
            if [[ "$actual_perm" == "$expected_perm" ]]; then
                success "Permisos correctos: $file ($actual_perm)"
            else
                warn "Permisos incorrectos: $file ($actual_perm, esperado: $expected_perm)"
                WARNINGS=$((WARNINGS + 1))
            fi
        fi
    done
}

# Función para verificar variables de entorno
verify_environment() {
    log "Verificando variables de entorno..."
    
    local env_vars=(
        "EDITOR:Editor por defecto"
        "SHELL:Shell por defecto"
        "PATH:Variable PATH"
        "HOME:Directorio home"
    )
    
    for env_info in "${env_vars[@]}"; do
        IFS=':' read -r var description <<< "$env_info"
        
        if [[ -n "${!var:-}" ]]; then
            success "$description configurada: ${!var}"
        else
            warn "$description no configurada"
            WARNINGS=$((WARNINGS + 1))
        fi
    done
}

# Función para generar reporte
generate_report() {
    if [[ "$EXPORT_REPORT" != "true" ]]; then
        return 0
    fi
    
    log "Generando reporte en: $REPORT_FILE"
    
    {
        echo "=== ARCH DREAM VERIFICATION REPORT ==="
        echo "Fecha: $(date)"
        echo "Sistema: $(get_arch_version)"
        echo "Usuario: $USER"
        echo ""
        echo "=== RESUMEN ==="
        echo "Total de verificaciones: $TOTAL"
        echo "Exitosas: $PASSED"
        echo "Fallidas: $FAILED"
        echo "Advertencias: $WARNINGS"
        echo ""
        echo "=== DETALLES ==="
        echo "Porcentaje de éxito: $((PASSED * 100 / TOTAL))%"
        echo ""
        echo "=== RECOMENDACIONES ==="
        
        if [[ $FAILED -gt 0 ]]; then
            echo "- Revisar las herramientas que fallaron"
            echo "- Ejecutar el instalador principal si es necesario"
        fi
        
        if [[ $WARNINGS -gt 0 ]]; then
            echo "- Revisar las advertencias mostradas"
            echo "- Configurar manualmente si es necesario"
        fi
        
        if [[ $PASSED -eq $TOTAL ]]; then
            echo "- ¡Sistema completamente configurado!"
            echo "- Todo está funcionando correctamente"
        fi
    } > "$REPORT_FILE"
    
    success "Reporte generado: $REPORT_FILE"
}

# Función para mostrar resumen final
show_verification_summary() {
    local percentage=$((PASSED * 100 / TOTAL))
    local status_color="$GREEN"
    local status_icon="✅"
    local status_text="EXCELENTE"
    
    if [[ $percentage -lt 80 ]]; then
        status_color="$RED"
        status_icon="❌"
        status_text="CRÍTICO"
    elif [[ $percentage -lt 95 ]]; then
        status_color="$YELLOW"
        status_icon="⚠️"
        status_text="BUENO"
    fi
    
    echo
    echo -e "${BOLD}${CYAN}┌─────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "${BOLD}${CYAN}│                    📊 RESUMEN DE VERIFICACIÓN                    │${COLOR_RESET}"
    echo -e "${BOLD}${CYAN}└─────────────────────────────────────────────────────────────┘${COLOR_RESET}"
    echo
    echo -e "${BOLD}Total de verificaciones:${COLOR_RESET} $TOTAL"
    echo -e "${GREEN}✓ Exitosas:${COLOR_RESET} $PASSED"
    echo -e "${RED}✗ Fallidas:${COLOR_RESET} $FAILED"
    echo -e "${YELLOW}⚠ Advertencias:${COLOR_RESET} $WARNINGS"
    echo
    echo -e "${BOLD}Porcentaje de éxito:${COLOR_RESET} ${status_color}$percentage%${COLOR_RESET}"
    echo -e "${BOLD}Estado general:${COLOR_RESET} ${status_color}$status_icon $status_text${COLOR_RESET}"
    echo
    
    if [[ $FAILED -gt 0 ]]; then
        echo -e "${YELLOW}💡 Recomendaciones:${COLOR_RESET}"
        echo -e "   • Revisar las herramientas que fallaron"
        echo -e "   • Ejecutar: $SCRIPT_DIR/install-ultra-fast.sh"
        echo -e "   • Verificar conexión a internet"
    fi
    
    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  Advertencias:${COLOR_RESET}"
        echo -e "   • Revisar las configuraciones mostradas"
        echo -e "   • Configurar manualmente si es necesario"
    fi
    
    if [[ $PASSED -eq $TOTAL ]]; then
        echo -e "${GREEN}🎉 ¡Sistema completamente verificado!${COLOR_RESET}"
        echo -e "${CYAN}   Todo está funcionando correctamente${COLOR_RESET}"
    fi
    
    if [[ "$EXPORT_REPORT" == "true" ]]; then
        echo
        echo -e "${CYAN}📄 Reporte detallado: $REPORT_FILE${COLOR_RESET}"
    fi
}

# =====================================================
# 🏁 FUNCIÓN PRINCIPAL
# =====================================================

main() {
    # Inicializar biblioteca
    init_library
    
    # Parsear argumentos
    parse_arguments "$@"
    
    # Mostrar banner
    show_banner "$SCRIPT_NAME v$SCRIPT_VERSION" "Verificación completa del sistema Arch Dream"
    
    # Mostrar información del sistema
    debug "Sistema: $(get_arch_version)"
    debug "Usuario: $USER"
    debug "Directorio: $SCRIPT_DIR"
    debug "Modo VERBOSE: $VERBOSE"
    debug "Modo QUIET: $QUIET"
    debug "Exportar reporte: $EXPORT_REPORT"
    
    # Verificar sistema básico
    if [[ "$VERIFY_SYSTEM" == "true" ]]; then
        verify_system_basic
        verify_permissions
        verify_environment
        verify_fonts
    fi
    
    # Verificar herramientas
    if [[ "$VERIFY_TOOLS" == "true" ]]; then
        verify_core_tools
        verify_editors
        verify_dev_tools
    fi
    
    # Verificar configuraciones
    if [[ "$VERIFY_CONFIGS" == "true" ]]; then
        verify_shell_configs
        verify_terminal_configs
        verify_tool_configs
    fi
    
    # Generar reporte si se solicita
    generate_report
    
    # Mostrar resumen final
    show_verification_summary
    
    # Código de salida basado en resultados
    if [[ $FAILED -gt 0 ]]; then
        exit 1
    elif [[ $WARNINGS -gt 0 ]]; then
        exit 2
    else
        exit 0
    fi
}

# =====================================================
# 🚀 EJECUCIÓN
# =====================================================

# Ejecutar función principal
main "$@" 