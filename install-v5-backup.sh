#!/bin/bash
# =====================================================
# 🚀 ARCH DREAM - INSTALADOR MODERNO V6.0
# =====================================================
# Arquitectura modular limpia usando librerías existentes
# UI moderna • Separación de responsabilidades • Optimizado
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Bootstrap: Load core libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/shell-base.sh" 
source "$SCRIPT_DIR/lib/module-manager.sh"
source "$SCRIPT_DIR/lib/simple-backup.sh"
source "$SCRIPT_DIR/lib/ui-framework.sh"

PROJECT_VERSION="6.0.0"

# =====================================================
# 🔧 CONFIGURACIÓN SIMPLIFICADA
# =====================================================

# Variables de control (simplificadas - las librerías manejan el resto)
INSTALL_ALL=false
SELECTED_MODULES=()
DRY_RUN=false
FORCE_INSTALL=false
PARALLEL_INSTALL=false
SKIP_BACKUP=false
QUIET_MODE=false
VERBOSE_MODE=false

# =====================================================
# 🎯 COMMAND HANDLERS (Usando librerías)
# =====================================================

cmd_list() {
    ui_show_section_header "MÓDULOS DISPONIBLES" "$ICON_PACKAGE"
    echo
    
    local modules=()
    mapfile -t modules < <(discover_modules)
    ui_show_module_list "${modules[@]}"
    
    echo
    ui_show_selection_help
}

cmd_status() {
    ui_show_system_status
    
    local modules=()
    mapfile -t modules < <(discover_modules)
    ui_show_modules_status "${modules[@]}"
}

cmd_doctor() {
    ui_show_diagnostic_header
    
    local issues=0
    
    # Check dependencies
    ui_show_diagnostic_category "Dependencias básicas" "$ICON_GEAR"
    for cmd in git curl sudo pacman; do
        if command -v "$cmd" &>/dev/null; then
            ui_show_diagnostic_item "success" "$cmd"
        else
            ui_show_diagnostic_item "error" "$cmd" "requerido"
            issues=$((issues + 1))
        fi
    done
    echo
    
    # Check disk space
    ui_show_diagnostic_category "Recursos del sistema" "$ICON_INFO"
    local space_kb=$(df "$HOME" | awk 'NR==2 {print $4}')
    local space_gb=$((space_kb / 1024 / 1024))
    
    if [[ $space_gb -ge 2 ]]; then
        ui_show_diagnostic_item "success" "Espacio en disco" "${space_gb}GB disponibles"
    else
        ui_show_diagnostic_item "error" "Espacio en disco" "Solo ${space_gb}GB (mínimo 2GB)"
        issues=$((issues + 1))
    fi
    echo
    
    # Check connectivity
    ui_show_diagnostic_category "Conectividad" "$ICON_LIGHTNING"
    if ping -c 1 -W 3 archlinux.org &>/dev/null; then
        ui_show_diagnostic_item "success" "Conectividad a repositorios"
    else
        ui_show_diagnostic_item "warning" "Conectividad limitada"
        issues=$((issues + 1))
    fi
    echo
    
    # Final result
    if [[ $issues -eq 0 ]]; then
        echo -e "${UI_SUCCESS}${ICON_SUCCESS} Sistema listo para instalar Arch Dream${UI_RESET}"
        return 0
    else
        echo -e "${UI_WARNING}${ICON_WARNING} Se encontraron $issues problemas${UI_RESET}"
        return 1
    fi
}

cmd_profile() {
    local profile="$1"
    
    echo -e "${UI_BOLD}${UI_PRIMARY}${ICON_ROCKET} INSTALANDO PERFIL: $profile${UI_RESET}"
    echo
    
    local modules=()
    case "$profile" in
        developer|dev)
            modules=("core:zsh" "development:nvim" "terminal:kitty" "tools:fastfetch")
            ;;
        minimal|min)
            modules=("core:zsh" "tools:nano")
            ;;
        gaming)
            modules=("core:zsh" "terminal:kitty" "themes:catppuccin" "tools:fastfetch")
            ;;
        server)
            modules=("core:bash" "tools:nano")
            ;;
        *)
            error "Perfil desconocido: $profile"
            info "Perfiles disponibles: developer, minimal, gaming, server"
            return 1
            ;;
    esac
    
    info "Módulos del perfil $profile: ${modules[*]}"
    echo
    
    cmd_install_modules "${modules[@]}"
}

cmd_install_modules() {
    local modules=("$@")
    
    [[ ${#modules[@]} -eq 0 ]] && {
        error "No se especificaron módulos para instalar"
        return 1
    }
    
    ui_show_section_header "INICIANDO INSTALACIÓN" "$ICON_ROCKET"
    echo
    
    # Validate all modules first (using module-manager.sh)
    info "Validando módulos..."
    for module in "${modules[@]}"; do
        if validate_module "$module"; then
            success "✓ $module"
        else
            error "❌ Módulo inválido: $module"
            return 1
        fi
    done
    echo
    
    # Create backup if needed (using simple-backup.sh)
    if [[ "$SKIP_BACKUP" != "true" ]]; then
        info "Creando backup de configuraciones..."
        create_backup || warn "No se pudo crear backup"
        echo
    fi
    
    # Resolve dependencies (using module-manager.sh)
    info "Resolviendo dependencias..."
    local resolved_modules=()
    mapfile -t resolved_modules < <(resolve_dependencies "${modules[@]}")
    
    ui_show_installation_plan "${resolved_modules[@]}"
    
    # Confirmation
    if [[ "$DRY_RUN" != "true" && "$FORCE_INSTALL" != "true" ]]; then
        if ! ui_confirm "¿Continuar con la instalación?" "n"; then
            info "Instalación cancelada por el usuario"
            return 0
        fi
        echo
    fi
    
    # Install modules
    local start_time=$(date +%s)
    local installed=0
    local failed=0
    
    for module in "${resolved_modules[@]}"; do
        if [[ "$DRY_RUN" == "true" ]]; then
            success "🔍 DRY RUN: $module sería instalado"
            installed=$((installed + 1))
        else
            if install_module "$module"; then
                installed=$((installed + 1))
            else
                failed=$((failed + 1))
                [[ "$FORCE_INSTALL" != "true" ]] && break
            fi
        fi
    done
    
    local total_time=$(($(date +%s) - start_time))
    
    # Show results using UI framework
    ui_show_installation_results $installed $failed ${#resolved_modules[@]} $total_time
    
    if [[ $failed -eq 0 ]]; then
        ui_show_success_message
        return 0
    else
        ui_show_error_message $failed
        return 1
    fi
}

cmd_interactive_install() {
    local selected_modules=()
    local modules=()
    mapfile -t modules < <(discover_modules)
    
    ui_show_module_list "${modules[@]}"
    ui_show_selection_help
    
    ui_prompt "Selección"
    read -r selection
    
    case "$selection" in
        "all")
            selected_modules=("${modules[@]}")
            ;;
        *:*)
            local pattern="${selection%:*}"
            mapfile -t selected_modules < <(printf '%s\n' "${modules[@]}" | grep "^${pattern}:")
            ;;
        *)
            IFS=',' read -ra indices <<< "$selection"
            for idx in "${indices[@]}"; do
                idx=$(echo "$idx" | xargs)  # trim whitespace
                if [[ "$idx" =~ ^[0-9]+$ && $idx -ge 1 && $idx -le ${#modules[@]} ]]; then
                    selected_modules+=("${modules[$((idx-1))]}")
                fi
            done
            ;;
    esac
    
    [[ ${#selected_modules[@]} -eq 0 ]] && {
        error "No se seleccionaron módulos válidos"
        return 1
    }
    
    cmd_install_modules "${selected_modules[@]}"
}

# =====================================================
# 📋 HELP SYSTEM
# =====================================================

show_help() {
    ui_show_main_banner
    
    echo -e "${UI_BOLD}${UI_ACCENT}COMANDOS PRINCIPALES:${UI_RESET}"
    echo -e "  ${UI_SUCCESS}install [módulos...]${UI_RESET}  Instalar módulos específicos"
    echo -e "  ${UI_SUCCESS}profile <tipo>${UI_RESET}       Aplicar perfil preconfigurado"
    echo -e "  ${UI_SUCCESS}list${UI_RESET}                 Mostrar módulos disponibles"
    echo -e "  ${UI_SUCCESS}status${UI_RESET}               Estado de instalaciones"
    echo -e "  ${UI_SUCCESS}doctor${UI_RESET}               Diagnóstico del sistema"
    echo
    echo -e "${UI_BOLD}${UI_ACCENT}PERFILES DISPONIBLES:${UI_RESET}"
    echo -e "  ${UI_PRIMARY}developer${UI_RESET}  - Entorno completo de desarrollo"
    echo -e "  ${UI_PRIMARY}minimal${UI_RESET}    - Configuración básica y limpia"
    echo -e "  ${UI_PRIMARY}gaming${UI_RESET}     - Optimizado para gaming"
    echo -e "  ${UI_PRIMARY}server${UI_RESET}     - Configuración para servidor"
    echo
    echo -e "${UI_BOLD}${UI_ACCENT}OPCIONES:${UI_RESET}"
    echo -e "  ${UI_MUTED}-f, --force${UI_RESET}       Forzar reinstalación"
    echo -e "  ${UI_MUTED}-q, --quiet${UI_RESET}       Modo silencioso"
    echo -e "  ${UI_MUTED}-d, --dry-run${UI_RESET}     Simulación (no instalar)"
    echo -e "  ${UI_MUTED}-p, --parallel${UI_RESET}    Instalación paralela"
    echo -e "  ${UI_MUTED}--no-backup${UI_RESET}       Saltar backup"
    echo -e "  ${UI_MUTED}--verbose${UI_RESET}         Modo verboso"
    echo
    echo -e "${UI_BOLD}${UI_ACCENT}EJEMPLOS:${UI_RESET}"
    echo -e "  ${UI_DIM}$0 profile developer${UI_RESET}"
    echo -e "  ${UI_DIM}$0 install core:zsh terminal:kitty${UI_RESET}" 
    echo -e "  ${UI_DIM}$0 list${UI_RESET}"
    echo -e "  ${UI_DIM}$0 doctor${UI_RESET}"
}

# =====================================================
# 🎮 MAIN FUNCTION (Simplificada)
# =====================================================

main() {
    # Initialize system (using module-manager.sh)
    init_module_manager
    
    # Parse global options
    local command=""
    local args=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--force)
                FORCE_INSTALL=true
                export FORCE_INSTALL=true
                shift
                ;;
            -q|--quiet)
                QUIET_MODE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -p|--parallel)
                PARALLEL_INSTALL=true
                shift
                ;;
            --no-backup)
                SKIP_BACKUP=true
                shift
                ;;
            --verbose)
                VERBOSE_MODE=true
                export LOG_LEVEL=DEBUG
                shift
                ;;
            install|profile|list|status|doctor)
                command="$1"
                shift
                break
                ;;
            *)
                # If no command specified, assume 'install'
                command="install"
                break
                ;;
        esac
    done
    
    # Collect remaining arguments
    args=("$@")
    
    # Show banner for interactive commands
    [[ "$QUIET_MODE" != "true" && "$command" != "list" ]] && ui_show_main_banner
    
    # Route to appropriate handler
    case "$command" in
        install)
            if [[ ${#args[@]} -eq 0 ]]; then
                cmd_interactive_install
            else
                cmd_install_modules "${args[@]}"
            fi
            ;;
        profile)
            [[ ${#args[@]} -eq 0 ]] && {
                error "Especifica un perfil: developer, minimal, gaming, server"
                exit 1
            }
            cmd_profile "${args[0]}"
            ;;
        list)
            cmd_list
            ;;
        status)
            cmd_status
            ;;
        doctor)
            cmd_doctor
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

# =====================================================
# 🚀 ENTRY POINT
# =====================================================

main "$@"