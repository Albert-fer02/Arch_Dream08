#!/bin/bash
# =====================================================
# 🚀 ARCH DREAM - MODERN INSTALLER v6.0
# =====================================================
# Instalador modular que usa librerías existentes
# Arquitectura limpia y separación de responsabilidades
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# =====================================================
# 🔧 BOOTSTRAP & CORE INITIALIZATION
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_VERSION="6.0.0"

# Core libraries loading
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/shell-base.sh"
source "$SCRIPT_DIR/lib/module-manager.sh"
source "$SCRIPT_DIR/lib/simple-backup.sh"
source "$SCRIPT_DIR/lib/config-validator.sh"

# =====================================================
# 🎨 MODERN UI FRAMEWORK
# =====================================================

show_welcome_banner() {
    clear
    echo -e "${BOLD}${AQUA}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════════════╗
    ║     🚀 ARCH DREAM MACHINE - INSTALADOR MODERNO v6.0        ║
    ║           ⚡ Digital Dream Architect ⚡                       ║
    ║                                                             ║
    ║        Arquitectura modular • UI moderna • Rápido          ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${COLOR_RESET}${CYAN}"
    echo "    🎯 Usando librerías optimizadas del proyecto"
    echo "    ⚡ Separación de responsabilidades"
    echo -e "${COLOR_RESET}"
    echo
}

show_help_modern() {
    echo -e "${BOLD}${BLUE}🚀 Arch Dream Machine v$PROJECT_VERSION${COLOR_RESET}"
    echo
    echo -e "${YELLOW}COMANDOS PRINCIPALES:${COLOR_RESET}"
    echo -e "  ${GREEN}install [módulos...]${COLOR_RESET}  Instalar módulos específicos"
    echo -e "  ${GREEN}profile <tipo>${COLOR_RESET}       Aplicar perfil preconfigurado"
    echo -e "  ${GREEN}list${COLOR_RESET}                 Mostrar módulos disponibles"
    echo -e "  ${GREEN}status${COLOR_RESET}               Estado de instalaciones"
    echo -e "  ${GREEN}doctor${COLOR_RESET}               Diagnóstico del sistema"
    echo
    echo -e "${YELLOW}PERFILES DISPONIBLES:${COLOR_RESET}"
    echo -e "  ${CYAN}developer${COLOR_RESET}  - Entorno completo de desarrollo"
    echo -e "  ${CYAN}minimal${COLOR_RESET}    - Configuración básica y limpia"
    echo -e "  ${CYAN}gaming${COLOR_RESET}     - Optimizado para gaming"
    echo -e "  ${CYAN}server${COLOR_RESET}     - Configuración para servidor"
    echo
    echo -e "${YELLOW}OPCIONES:${COLOR_RESET}"
    echo -e "  ${PURPLE}-f, --force${COLOR_RESET}       Forzar reinstalación"
    echo -e "  ${PURPLE}-q, --quiet${COLOR_RESET}       Modo silencioso"
    echo -e "  ${PURPLE}-d, --dry-run${COLOR_RESET}     Simulación (no instalar)"
    echo -e "  ${PURPLE}-p, --parallel${COLOR_RESET}    Instalación paralela"
    echo -e "  ${PURPLE}--no-backup${COLOR_RESET}       Saltar backup"
    echo -e "  ${PURPLE}--verbose${COLOR_RESET}         Modo verboso"
    echo
    echo -e "${YELLOW}EJEMPLOS:${COLOR_RESET}"
    echo -e "  ${DIM}$0 profile developer${COLOR_RESET}"
    echo -e "  ${DIM}$0 install core:zsh terminal:kitty${COLOR_RESET}"
    echo -e "  ${DIM}$0 list${COLOR_RESET}"
    echo -e "  ${DIM}$0 doctor${COLOR_RESET}"
}

# =====================================================
# 🔍 INTERACTIVE MODULE SELECTION
# =====================================================

interactive_module_selection() {
    echo -e "${BOLD}${CYAN}📦 SELECCIÓN INTERACTIVA DE MÓDULOS${COLOR_RESET}"
    echo
    
    local modules=()
    mapfile -t modules < <(discover_modules)
    
    echo -e "${YELLOW}Módulos disponibles:${COLOR_RESET}"
    echo
    
    local current_category=""
    for i in "${!modules[@]}"; do
        local module="${modules[i]}"
        local category="${module%%:*}"
        local name="${module#*:}"
        
        if [[ "$category" != "$current_category" ]]; then
            [[ -n "$current_category" ]] && echo
            echo -e "${BOLD}${PURPLE}  $category:${COLOR_RESET}"
            current_category="$category"
        fi
        
        printf "    ${CYAN}%2d)${COLOR_RESET} %-20s\n" "$((i+1))" "$name"
    done
    
    echo
    echo -e "${YELLOW}💡 Opciones especiales:${COLOR_RESET}"
    echo -e "  • ${BOLD}all${COLOR_RESET} - Todos los módulos"
    echo -e "  • ${BOLD}<categoria>:*${COLOR_RESET} - Toda una categoría"
    echo -e "  • ${BOLD}números separados por comas${COLOR_RESET} - Módulos específicos"
    echo
    
    read -p "$(echo -e "${CYAN}Selección: ${COLOR_RESET}")" selection
    
    case "$selection" in
        "all")
            printf '%s\n' "${modules[@]}"
            ;;
        *:*)
            local pattern="${selection%:*}"
            printf '%s\n' "${modules[@]}" | grep "^${pattern}:"
            ;;
        *)
            IFS=',' read -ra indices <<< "$selection"
            for idx in "${indices[@]}"; do
                idx=$(echo "$idx" | xargs)  # trim whitespace
                if [[ "$idx" =~ ^[0-9]+$ && $idx -ge 1 && $idx -le ${#modules[@]} ]]; then
                    echo "${modules[$((idx-1))]}"
                fi
            done
            ;;
    esac
}

# =====================================================
# 📊 STATUS & DIAGNOSTICS
# =====================================================

show_system_status() {
    echo -e "${BOLD}${BLUE}📊 ESTADO DEL SISTEMA ARCH DREAM${COLOR_RESET}"
    echo
    
    # System info
    echo -e "${CYAN}🖥️  Sistema:${COLOR_RESET}"
    echo "   • OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "   • Kernel: $(uname -r)"
    echo "   • Shell: $SHELL"
    echo
    
    # Installed modules status
    echo -e "${CYAN}📦 Módulos instalados:${COLOR_RESET}"
    local modules=()
    mapfile -t modules < <(discover_modules)
    local installed=0
    
    for module in "${modules[@]}"; do
        if is_module_installed "$module"; then
            echo -e "   ${GREEN}✓${COLOR_RESET} $module"
            installed=$((installed + 1))
        else
            echo -e "   ${RED}✗${COLOR_RESET} $module"
        fi
    done
    
    echo
    echo -e "${CYAN}📈 Resumen: ${GREEN}$installed${COLOR_RESET}/${#modules[@]} módulos instalados"
}

run_system_doctor() {
    echo -e "${BOLD}${BLUE}🔍 DIAGNÓSTICO DEL SISTEMA${COLOR_RESET}"
    echo
    
    local issues=0
    
    # Check core requirements
    echo -e "${CYAN}🔧 Verificando dependencias básicas...${COLOR_RESET}"
    for cmd in git curl sudo pacman; do
        if command -v "$cmd" &>/dev/null; then
            echo -e "   ${GREEN}✓${COLOR_RESET} $cmd"
        else
            echo -e "   ${RED}✗${COLOR_RESET} $cmd (requerido)"
            issues=$((issues + 1))
        fi
    done
    
    # Check disk space
    echo
    echo -e "${CYAN}💾 Verificando espacio en disco...${COLOR_RESET}"
    local space_kb=$(df "$HOME" | awk 'NR==2 {print $4}')
    local space_gb=$((space_kb / 1024 / 1024))
    
    if [[ $space_gb -ge 2 ]]; then
        echo -e "   ${GREEN}✓${COLOR_RESET} ${space_gb}GB disponibles"
    else
        echo -e "   ${RED}✗${COLOR_RESET} Solo ${space_gb}GB disponibles (mínimo 2GB)"
        issues=$((issues + 1))
    fi
    
    # Check internet connectivity
    echo
    echo -e "${CYAN}🌐 Verificando conectividad...${COLOR_RESET}"
    if ping -c 1 -W 3 archlinux.org &>/dev/null; then
        echo -e "   ${GREEN}✓${COLOR_RESET} Conectividad OK"
    else
        echo -e "   ${YELLOW}⚠${COLOR_RESET} Sin conectividad a repositorios"
        issues=$((issues + 1))
    fi
    
    # Final diagnosis
    echo
    if [[ $issues -eq 0 ]]; then
        echo -e "${GREEN}✨ Sistema listo para instalar Arch Dream${COLOR_RESET}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Se encontraron $issues problemas${COLOR_RESET}"
        return 1
    fi
}

# =====================================================
# 🎯 PROFILE MANAGEMENT
# =====================================================

install_profile() {
    local profile="$1"
    
    echo -e "${BOLD}${CYAN}🎯 INSTALANDO PERFIL: $profile${COLOR_RESET}"
    echo
    
    local modules=()
    case "$profile" in
        developer|dev)
            modules=(
                "core:zsh"
                "development:nvim"
                "terminal:kitty" 
                "tools:fastfetch"
            )
            ;;
        minimal|min)
            modules=(
                "core:zsh"
                "tools:nano"
            )
            ;;
        gaming)
            modules=(
                "core:zsh"
                "terminal:kitty"
                "themes:catppuccin"
                "tools:fastfetch"
            )
            ;;
        server)
            modules=(
                "core:bash"
                "tools:nano"
            )
            ;;
        *)
            error "Perfil desconocido: $profile"
            info "Perfiles disponibles: developer, minimal, gaming, server"
            return 1
            ;;
    esac
    
    info "Módulos del perfil $profile: ${modules[*]}"
    echo
    
    install_modules "${modules[@]}"
}

# =====================================================
# 🚀 MAIN INSTALLATION ORCHESTRATOR
# =====================================================

install_modules() {
    local modules=("$@")
    
    [[ ${#modules[@]} -eq 0 ]] && {
        error "No se especificaron módulos para instalar"
        return 1
    }
    
    echo -e "${BOLD}${CYAN}🚀 INICIANDO INSTALACIÓN${COLOR_RESET}"
    echo
    
    # Validate all modules first
    info "Validando módulos..."
    for module in "${modules[@]}"; do
        if ! validate_module "$module"; then
            error "Módulo inválido: $module"
            return 1
        fi
        success "✓ $module"
    done
    
    # Create backup if needed
    if [[ "${SKIP_BACKUP:-}" != "true" ]]; then
        info "Creando backup de configuraciones..."
        create_backup || warn "No se pudo crear backup"
    fi
    
    # Resolve dependencies
    info "Resolviendo dependencias..."
    local resolved_modules=()
    mapfile -t resolved_modules < <(resolve_dependencies "${modules[@]}")
    
    echo -e "${YELLOW}📋 Plan de instalación:${COLOR_RESET}"
    for module in "${resolved_modules[@]}"; do
        if [[ " ${modules[*]} " =~ " $module " ]]; then
            echo -e "   • $module"
        else
            echo -e "   • $module ${DIM}(dependencia)${COLOR_RESET}"
        fi
    done
    echo
    
    # Install modules
    local start_time=$(date +%s)
    local installed=0
    local failed=0
    
    for module in "${resolved_modules[@]}"; do
        if install_module "$module"; then
            installed=$((installed + 1))
        else
            failed=$((failed + 1))
        fi
    done
    
    local total_time=$(($(date +%s) - start_time))
    
    # Show results
    echo
    echo -e "${BOLD}${BLUE}📊 RESULTADOS DE INSTALACIÓN${COLOR_RESET}"
    echo -e "${CYAN}┌─────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Instalados: ${GREEN}$installed${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Fallidos: ${RED}$failed${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Tiempo: ${total_time}s"
    echo -e "${CYAN}└─────────────────────────────────────────────┘${COLOR_RESET}"
    
    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}🎉 ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!${COLOR_RESET}"
        echo
        echo -e "${YELLOW}🚀 Próximos pasos:${COLOR_RESET}"
        echo -e "  • ${CYAN}exec \$SHELL${COLOR_RESET} - Reiniciar terminal"
        echo -e "  • ${CYAN}./arch-dream status${COLOR_RESET} - Ver estado"
        return 0
    else
        error "Instalación completada con $failed errores"
        return 1
    fi
}

# =====================================================
# 🎮 COMMAND ROUTER & ARGUMENT PARSER
# =====================================================

main() {
    # Initialize system
    init_module_manager
    
    # Parse global options
    local command=""
    local args=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help_modern
                exit 0
                ;;
            -f|--force)
                export FORCE_INSTALL=true
                shift
                ;;
            -q|--quiet)
                export QUIET_MODE=true
                shift
                ;;
            -d|--dry-run)
                export DRY_RUN=true
                shift
                ;;
            -p|--parallel)
                export PARALLEL_INSTALL=true
                shift
                ;;
            --no-backup)
                export SKIP_BACKUP=true
                shift
                ;;
            --verbose)
                export VERBOSE_MODE=true
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
    
    # Show banner
    show_welcome_banner
    
    # Route to appropriate handler
    case "$command" in
        install)
            if [[ ${#args[@]} -eq 0 ]]; then
                local selected_modules=()
                mapfile -t selected_modules < <(interactive_module_selection)
                install_modules "${selected_modules[@]}"
            else
                install_modules "${args[@]}"
            fi
            ;;
        profile)
            [[ ${#args[@]} -eq 0 ]] && {
                error "Especifica un perfil: developer, minimal, gaming, server"
                exit 1
            }
            install_profile "${args[0]}"
            ;;
        list)
            echo -e "${BOLD}${BLUE}📦 MÓDULOS DISPONIBLES${COLOR_RESET}"
            echo
            discover_modules | sed 's/^/  • /'
            ;;
        status)
            show_system_status
            ;;
        doctor)
            run_system_doctor
            ;;
        *)
            show_help_modern
            exit 1
            ;;
    esac
}

# =====================================================
# 🎯 ENTRY POINT
# =====================================================

main "$@"