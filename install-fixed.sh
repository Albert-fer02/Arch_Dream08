#!/bin/bash
# =====================================================
# 🚀 ARCH DREAM - INSTALADOR MODERNO v6.0 (ARREGLADO)
# =====================================================
# Instalador funcional con dependencias resueltas
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# =====================================================
# 🔧 CONFIGURACIÓN Y COLORES
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_VERSION="6.0.0"

# Colores modernos
AQUA='\033[38;5;51m'
GREEN='\033[38;5;118m'
CYAN='\033[38;5;87m'
PURPLE='\033[38;5;147m'
YELLOW='\033[38;5;226m'
RED='\033[38;5;196m'
BLUE='\033[38;5;33m'
BOLD='\033[1m'
DIM='\033[2m'
COLOR_RESET='\033[0m'

# Variables globales
FORCE_INSTALL=false
DRY_RUN=false
QUIET_MODE=false
VERBOSE_MODE=false
SKIP_BACKUP=false
PARALLEL_INSTALL=false

# =====================================================
# 🔧 FUNCIONES BÁSICAS
# =====================================================

info() {
    [[ "$QUIET_MODE" != "true" ]] && echo -e "${CYAN}[INFO]${COLOR_RESET} $*"
}

success() {
    [[ "$QUIET_MODE" != "true" ]] && echo -e "${GREEN}[OK]${COLOR_RESET} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${COLOR_RESET} $*" >&2
}

error() {
    echo -e "${RED}[ERROR]${COLOR_RESET} $*" >&2
}

debug() {
    [[ "$VERBOSE_MODE" == "true" ]] && echo -e "${PURPLE}[DEBUG]${COLOR_RESET} $*"
}

# =====================================================
# 🎨 UI FUNCTIONS
# =====================================================

show_banner() {
    clear
    echo -e "${BOLD}${AQUA}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════════════╗
    ║     🚀 ARCH DREAM MACHINE - INSTALADOR MODERNO v6.0        ║
    ║           ⚡ Digital Dream Architect ⚡                       ║
    ║                                                             ║
    ║        Arquitectura limpia • UI moderna • Funcional        ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${COLOR_RESET}${CYAN}"
    echo "    🎯 Instalador simplificado y funcional"
    echo "    ⚡ Sin dependencias complejas"
    echo -e "${COLOR_RESET}"
    echo
}

show_help() {
    show_banner
    
    echo -e "${BOLD}${BLUE}COMANDOS PRINCIPALES:${COLOR_RESET}"
    echo -e "  ${GREEN}install [módulos...]${COLOR_RESET}  Instalar módulos específicos"
    echo -e "  ${GREEN}profile <tipo>${COLOR_RESET}       Aplicar perfil preconfigurado"
    echo -e "  ${GREEN}list${COLOR_RESET}                 Mostrar módulos disponibles"
    echo -e "  ${GREEN}status${COLOR_RESET}               Estado de instalaciones"
    echo -e "  ${GREEN}doctor${COLOR_RESET}               Diagnóstico del sistema"
    echo
    echo -e "${BOLD}${BLUE}PERFILES DISPONIBLES:${COLOR_RESET}"
    echo -e "  ${CYAN}developer${COLOR_RESET}  - Entorno completo de desarrollo"
    echo -e "  ${CYAN}minimal${COLOR_RESET}    - Configuración básica y limpia"
    echo -e "  ${CYAN}gaming${COLOR_RESET}     - Optimizado para gaming"
    echo -e "  ${CYAN}server${COLOR_RESET}     - Configuración para servidor"
    echo
    echo -e "${BOLD}${BLUE}OPCIONES:${COLOR_RESET}"
    echo -e "  ${PURPLE}-f, --force${COLOR_RESET}       Forzar reinstalación"
    echo -e "  ${PURPLE}-q, --quiet${COLOR_RESET}       Modo silencioso"
    echo -e "  ${PURPLE}-d, --dry-run${COLOR_RESET}     Simulación (no instalar)"
    echo -e "  ${PURPLE}--no-backup${COLOR_RESET}       Saltar backup"
    echo -e "  ${PURPLE}--verbose${COLOR_RESET}         Modo verboso"
    echo
    echo -e "${BOLD}${BLUE}EJEMPLOS:${COLOR_RESET}"
    echo -e "  ${DIM}$0 profile developer${COLOR_RESET}"
    echo -e "  ${DIM}$0 install core:zsh terminal:kitty${COLOR_RESET}"
    echo -e "  ${DIM}$0 list${COLOR_RESET}"
    echo -e "  ${DIM}$0 doctor${COLOR_RESET}"
}

# =====================================================
# 🔍 MODULE DISCOVERY & VALIDATION
# =====================================================

discover_modules() {
    find "$SCRIPT_DIR/modules" -name "install.sh" 2>/dev/null | \
    sed "s|$SCRIPT_DIR/modules/||g; s|/install.sh||g; s|/|:|g" | \
    sort -V
}

validate_module() {
    local module="$1"
    local module_path="$SCRIPT_DIR/modules/${module/:/\/}"
    
    [[ -f "$module_path/install.sh" ]] || return 1
    bash -n "$module_path/install.sh" || return 1
    [[ -x "$module_path/install.sh" ]] || return 1
    return 0
}

is_module_installed() {
    local module="$1"
    
    case "$module" in
        "core:zsh") [[ -f ~/.zshrc ]] ;;
        "core:bash") [[ -f ~/.bashrc ]] ;;
        "development:nvim") [[ -d ~/.config/nvim ]] ;;
        "terminal:kitty") [[ -f ~/.config/kitty/kitty.conf ]] ;;
        "tools:fastfetch") command -v fastfetch &>/dev/null ;;
        "tools:nano") [[ -f ~/.nanorc ]] ;;
        "themes:catppuccin") [[ -f ~/.config/kitty/colors-dreamcoder.conf ]] ;;
        *) false ;;
    esac
}

# =====================================================
# 📦 INSTALLATION FUNCTIONS
# =====================================================

install_module() {
    local module="$1"
    local module_path="$SCRIPT_DIR/modules/${module/:/\/}"
    
    validate_module "$module" || {
        error "❌ Módulo inválido: $module"
        return 1
    }
    
    info "📦 Instalando: $module"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        success "🔍 DRY RUN: $module sería instalado"
        return 0
    fi
    
    local install_start=$(date +%s)
    
    if timeout 300 bash -c "cd '$module_path' && bash install.sh" &>/dev/null; then
        local install_time=$(($(date +%s) - install_start))
        success "✅ $module instalado (${install_time}s)"
        return 0
    else
        local install_time=$(($(date +%s) - install_start))
        error "❌ Fallo al instalar $module (${install_time}s)"
        return 1
    fi
}

create_backup() {
    [[ "$SKIP_BACKUP" == "true" ]] && return 0
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$HOME/.arch-dream-backup-$timestamp"
    
    info "💾 Creando backup de configuraciones..."
    mkdir -p "$backup_dir" || return 1
    
    local configs=(".bashrc" ".zshrc" ".gitconfig" ".config/kitty" ".config/nvim")
    local backed_up=0
    
    for config in "${configs[@]}"; do
        if [[ -e "$HOME/$config" ]]; then
            if cp -r "$HOME/$config" "$backup_dir/" 2>/dev/null; then
                backed_up=$((backed_up + 1))
            fi
        fi
    done
    
    if [[ $backed_up -gt 0 ]]; then
        success "✅ Backup creado: $backup_dir ($backed_up archivos)"
        echo "$backup_dir" > "$HOME/.arch-dream-last-backup"
    else
        info "ℹ️  No se encontraron configuraciones para respaldar"
        rmdir "$backup_dir" 2>/dev/null || true
    fi
}

# =====================================================
# 🎯 COMMAND HANDLERS
# =====================================================

cmd_list() {
    echo -e "${BOLD}${BLUE}📦 MÓDULOS DISPONIBLES${COLOR_RESET}"
    echo
    
    local modules=()
    mapfile -t modules < <(discover_modules)
    
    local current_category=""
    for i in "${!modules[@]}"; do
        local module="${modules[i]}"
        local category="${module%%:*}"
        local name="${module#*:}"
        
        if [[ "$category" != "$current_category" ]]; then
            [[ -n "$current_category" ]] && echo
            echo -e "${BOLD}${PURPLE}  📁 $category:${COLOR_RESET}"
            current_category="$category"
        fi
        
        local status="○"
        if is_module_installed "$module"; then
            status="${GREEN}✅${COLOR_RESET}"
        else
            status="${DIM}○${COLOR_RESET}"
        fi
        
        printf "     ${CYAN}%2d)${COLOR_RESET} %-20s %s\n" "$((i+1))" "$name" "$status"
    done
    
    echo
    echo -e "${YELLOW}💡 Opciones de instalación:${COLOR_RESET}"
    echo -e "  • ${BOLD}./install.sh install <números>${COLOR_RESET} - Instalar módulos específicos"
    echo -e "  • ${BOLD}./install.sh profile <tipo>${COLOR_RESET} - Instalar perfil completo"
}

cmd_status() {
    echo -e "${BOLD}${BLUE}📊 ESTADO DEL SISTEMA ARCH DREAM${COLOR_RESET}"
    echo
    
    # System info
    echo -e "${CYAN}🖥️  Sistema:${COLOR_RESET}"
    echo "   • OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "   • Kernel: $(uname -r)"
    echo "   • Shell: $SHELL"
    echo
    
    # Installed modules
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

cmd_doctor() {
    echo -e "${BOLD}${BLUE}🔍 DIAGNÓSTICO DEL SISTEMA${COLOR_RESET}"
    echo
    
    local issues=0
    
    # Check dependencies
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
    
    # Check connectivity
    echo
    echo -e "${CYAN}🌐 Verificando conectividad...${COLOR_RESET}"
    if ping -c 1 -W 3 archlinux.org &>/dev/null; then
        echo -e "   ${GREEN}✓${COLOR_RESET} Conectividad OK"
    else
        echo -e "   ${YELLOW}⚠${COLOR_RESET} Sin conectividad a repositorios"
        issues=$((issues + 1))
    fi
    
    # Final result
    echo
    if [[ $issues -eq 0 ]]; then
        echo -e "${GREEN}✨ Sistema listo para instalar Arch Dream${COLOR_RESET}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Se encontraron $issues problemas${COLOR_RESET}"
        return 1
    fi
}

cmd_profile() {
    local profile="$1"
    
    echo -e "${BOLD}${CYAN}🎯 INSTALANDO PERFIL: $profile${COLOR_RESET}"
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

cmd_interactive_install() {
    local modules=()
    mapfile -t modules < <(discover_modules)
    
    echo -e "${BOLD}${CYAN}📦 SELECCIÓN INTERACTIVA DE MÓDULOS${COLOR_RESET}"
    echo
    
    local current_category=""
    for i in "${!modules[@]}"; do
        local module="${modules[i]}"
        local category="${module%%:*}"
        local name="${module#*:}"
        
        if [[ "$category" != "$current_category" ]]; then
            [[ -n "$current_category" ]] && echo
            echo -e "${BOLD}${PURPLE}  📁 $category:${COLOR_RESET}"
            current_category="$category"
        fi
        
        printf "     ${CYAN}%2d)${COLOR_RESET} %-20s\n" "$((i+1))" "$name"
    done
    
    echo
    echo -e "${YELLOW}💡 Opciones especiales:${COLOR_RESET}"
    echo -e "  • ${BOLD}all${COLOR_RESET} - Todos los módulos"
    echo -e "  • ${BOLD}<categoria>:*${COLOR_RESET} - Toda una categoría (ej: core:*)"
    echo -e "  • ${BOLD}números separados por comas${COLOR_RESET} - Módulos específicos"
    echo
    
    read -p "$(echo -e "${CYAN}Selección: ${COLOR_RESET}")" selection
    
    local selected_modules=()
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
    
    if [[ ${#selected_modules[@]} -eq 0 ]]; then
        error "No se seleccionaron módulos válidos"
        return 1
    fi
    
    cmd_install_modules "${selected_modules[@]}"
}

cmd_install_modules() {
    local modules=("$@")
    
    [[ ${#modules[@]} -eq 0 ]] && {
        error "No se especificaron módulos para instalar"
        return 1
    }
    
    echo -e "${BOLD}${CYAN}🚀 INICIANDO INSTALACIÓN${COLOR_RESET}"
    echo
    
    # Validate modules
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
    
    # Create backup
    create_backup
    echo
    
    # Show plan
    echo -e "${YELLOW}📋 Plan de instalación:${COLOR_RESET}"
    for module in "${modules[@]}"; do
        echo -e "   • $module"
    done
    echo
    
    # Confirmation
    if [[ "$DRY_RUN" != "true" && "$FORCE_INSTALL" != "true" ]]; then
        read -p "$(echo -e "${YELLOW}¿Continuar con la instalación? [y/N]: ${COLOR_RESET}")" -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || {
            info "Instalación cancelada por el usuario"
            return 0
        }
        echo
    fi
    
    # Install modules
    local start_time=$(date +%s)
    local installed=0
    local failed=0
    
    for module in "${modules[@]}"; do
        if install_module "$module"; then
            installed=$((installed + 1))
        else
            failed=$((failed + 1))
            [[ "$FORCE_INSTALL" != "true" ]] && break
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
# 🎮 MAIN FUNCTION
# =====================================================

main() {
    # Parse arguments
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
            --no-backup)
                SKIP_BACKUP=true
                shift
                ;;
            --verbose)
                VERBOSE_MODE=true
                shift
                ;;
            install|profile|list|status|doctor)
                command="$1"
                shift
                break
                ;;
            *)
                command="install"
                break
                ;;
        esac
    done
    
    # Collect remaining arguments
    args=("$@")
    
    # Show banner for interactive commands
    [[ "$QUIET_MODE" != "true" && "$command" != "list" ]] && show_banner
    
    # Route to handlers
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