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
# ⚡ ARCH DREAM ULTRA FAST INSTALLER v2.0
# =====================================================
# Script ultra optimizado para instalación rápida
# de herramientas de productividad en Arch Linux
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

# Variables de configuración
SCRIPT_NAME="Arch Dream Ultra Fast Installer"
SCRIPT_VERSION="2.0"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="$SCRIPT_DIR"
MODULES_DIR="$SCRIPT_DIR/modules"

# Variables de control
FORCE_INSTALL=${FORCE_INSTALL:-false}
SKIP_BACKUP=${SKIP_BACKUP:-false}
DRY_RUN=${DRY_RUN:-false}
VERBOSE=${VERBOSE:-false}

# Configurar nivel de logging basado en verbose
if [[ "$VERBOSE" == "true" ]]; then
    LOG_LEVEL="DEBUG"
fi

# =====================================================
# 🔧 FUNCIONES PRINCIPALES MEJORADAS
# =====================================================

# Función para mostrar ayuda
show_help() {
    cat << EOF
${BOLD}${CYAN}$SCRIPT_NAME v$SCRIPT_VERSION${COLOR_RESET}

${PURPLE}Uso:${COLOR_RESET} $0 [OPCIONES]

${PURPLE}Opciones:${COLOR_RESET}
  -h, --help          Mostrar esta ayuda
  -f, --force         Instalación forzada (sin confirmaciones)
  -v, --verbose       Modo verbose con más información
  -d, --dry-run       Simular instalación sin hacer cambios
  -s, --skip-backup   Saltar creación de backups
  --root              Configurar también entorno de root
  --modules=LIST      Lista de módulos específicos (separados por coma)

${PURPLE}Variables de entorno:${COLOR_RESET}
  FORCE_INSTALL=true  Instalación forzada
  SKIP_BACKUP=true    Saltar backups
  DRY_RUN=true        Modo simulación
  VERBOSE=true        Modo verbose
  LOG_LEVEL=DEBUG     Nivel de logging

${PURPLE}Ejemplos:${COLOR_RESET}
  $0                    # Instalación normal
  $0 --force           # Instalación forzada
  $0 --modules=zsh,kitty  # Solo módulos específicos
  $0 --dry-run         # Simular instalación

${PURPLE}Módulos disponibles:${COLOR_RESET}
  zsh, bash, kitty, fastfetch, nano, git, neovim

EOF
}

# Función para parsear argumentos
parse_arguments() {
    local modules_list=""
    
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
            -v|--verbose)
                VERBOSE=true
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -s|--skip-backup)
                SKIP_BACKUP=true
                shift
                ;;
            --root)
                SETUP_ROOT=true
                shift
                ;;
            --modules=*)
                modules_list="${1#*=}"
                shift
                ;;
            *)
                error "Opción desconocida: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Procesar lista de módulos
    if [[ -n "$modules_list" ]]; then
        IFS=',' read -ra SELECTED_MODULES <<< "$modules_list"
        debug "Módulos seleccionados: ${SELECTED_MODULES[*]}"
    fi
}

# Función para crear backup del sistema
create_system_backup() {
    if [[ "$SKIP_BACKUP" == "true" ]]; then
        warn "Saltando creación de backups"
        return 0
    fi
    
    log "Creando backup del sistema..."
    
    local backup_items=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.config/kitty"
        "$HOME/.config/fastfetch"
        "$HOME/.config/nvim"
        "$HOME/.gitconfig"
    )
    
    local backup_count=0
    for item in "${backup_items[@]}"; do
        if [[ -e "$item" ]]; then
            if create_backup "$item" "$BACKUP_DIR"; then
                ((backup_count++))
            fi
        fi
    done
    
    if [[ $backup_count -gt 0 ]]; then
        success "Backup creado en: $BACKUP_DIR ($backup_count elementos)"
    else
        warn "No se encontraron archivos para hacer backup"
    fi
}

# Función para instalar paquete rápidamente (mejorada)
install_fast() {
    local package="$1"
    local description="$2"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY-RUN] Instalando $description..."
        return 0
    fi
    
    if pacman -Q "$package" &>/dev/null; then
        success "$description ya instalado"
        return 0
    fi
    
    log "Instalando $description..."
    
    # Verificar si el paquete existe
    if ! pacman -Ss "^$package$" &>/dev/null; then
        warn "Paquete $package no encontrado en repositorios"
        return 1
    fi
    
    if sudo pacman -S --noconfirm --needed "$package" &>/dev/null; then
        success "$description instalado"
        return 0
    else
        warn "No se pudo instalar $description, continuando..."
        return 1
    fi
}

# Función para instalar AUR rápidamente (mejorada)
install_aur_fast() {
    local package="$1"
    local description="$2"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY-RUN] Instalando $description desde AUR..."
        return 0
    fi
    
    if pacman -Q "$package" &>/dev/null; then
        success "$description ya instalado"
        return 0
    fi
    
    local aur_helper=""
    if command -v yay &>/dev/null; then
        aur_helper="yay"
    elif command -v paru &>/dev/null; then
        aur_helper="paru"
    else
        warn "AUR helper no detectado, saltando $description"
        return 1
    fi
    
    log "Instalando $description desde AUR usando $aur_helper..."
    
    if $aur_helper -S --noconfirm --needed "$package" &>/dev/null; then
        success "$description instalado desde AUR"
        return 0
    else
        warn "No se pudo instalar $description desde AUR, continuando..."
        return 1
    fi
}

# Función para instalar herramientas principales
install_core_tools() {
    log "Instalando herramientas principales..."
    
    local core_packages=(
        "zsh:Shell Zsh"
        "git:Control de versiones"
        "curl:Cliente HTTP"
        "wget:Descargador web"
        "unzip:Extractor de archivos"
        "tree:Visualizador de directorios"
    )
    
    local installed_count=0
    local total_count=${#core_packages[@]}
    
    for package_info in "${core_packages[@]}"; do
        IFS=':' read -r package description <<< "$package_info"
        
        if install_fast "$package" "$description"; then
            ((installed_count++))
        fi
        
        show_progress "$installed_count" "$total_count" "Herramientas principales"
    done
    
    success "Herramientas principales instaladas ($installed_count/$total_count)"
}

# Función para instalar herramientas modernas
install_modern_tools() {
    log "Instalando herramientas modernas..."
    
    local modern_packages=(
        "eza:Listador moderno"
        "bat:Cat moderno"
        "ripgrep:Grep moderno"
        "fd:Buscador moderno"
        "duf:DF moderno"
        "btop:Monitor de sistema"
        "fastfetch:Información del sistema"
    )
    
    local installed_count=0
    local total_count=${#modern_packages[@]}
    
    for package_info in "${modern_packages[@]}"; do
        IFS=':' read -r package description <<< "$package_info"
        
        if install_fast "$package" "$description"; then
            ((installed_count++))
        fi
        
        show_progress "$installed_count" "$total_count" "Herramientas modernas"
    done
    
    success "Herramientas modernas instaladas ($installed_count/$total_count)"
}

# Función para instalar terminales
install_terminals() {
    log "Instalando terminales..."
    
    local terminals=(
        "kitty:Terminal con aceleración GPU"
        "alacritty:Terminal rápido en Rust"
    )
    
    for terminal_info in "${terminals[@]}"; do
        IFS=':' read -r package description <<< "$terminal_info"
        install_fast "$package" "$description"
    done
}

# Función para instalar editores
install_editors() {
    log "Instalando editores..."
    
    local editors=(
        "neovim:Editor avanzado"
        "nano:Editor simple"
        "micro:Editor moderno"
    )
    
    for editor_info in "${editors[@]}"; do
        IFS=':' read -r package description <<< "$editor_info"
        install_fast "$package" "$description"
    done
}

# Función para instalar herramientas de desarrollo
install_dev_tools() {
    log "Instalando herramientas de desarrollo..."
    
    local dev_packages=(
        "nodejs:Runtime de JavaScript"
        "npm:Gestor de paquetes de Node.js"
        "python:Interprete de Python"
        "pip:Gestor de paquetes de Python"
        "rust:Rust programming language"
        "cargo:Gestor de paquetes de Rust"
        "go:Go programming language"
    )
    
    for package_info in "${dev_packages[@]}"; do
        IFS=':' read -r package description <<< "$package_info"
        install_fast "$package" "$description"
    done
}

# Función para instalar AUR helpers
install_aur_helpers() {
    log "Instalando AUR helpers..."
    
    # Verificar si ya hay un AUR helper
    if command -v yay &>/dev/null || command -v paru &>/dev/null; then
        success "AUR helper ya instalado"
        return 0
    fi
    
    # Intentar instalar yay primero
    if install_aur_fast "yay" "AUR Helper (yay)"; then
        return 0
    fi
    
    # Si falla, intentar con paru
    if install_aur_fast "paru" "AUR Helper (paru)"; then
        return 0
    fi
    
    warn "No se pudo instalar ningún AUR helper"
    return 1
}

# Función para configurar módulos
configure_modules() {
    log "Configurando módulos..."
    
    # Lista de módulos disponibles
    local available_modules=("zsh" "bash" "kitty" "fastfetch" "nano" "git" "neovim")
    
    # Si hay módulos seleccionados, usar solo esos
    if [[ ${#SELECTED_MODULES[@]} -gt 0 ]]; then
        local modules_to_configure=("${SELECTED_MODULES[@]}")
    else
        local modules_to_configure=("${available_modules[@]}")
    fi
    
    for module in "${modules_to_configure[@]}"; do
        local module_script="$MODULES_DIR/${module}/install.sh"
        
        if [[ -f "$module_script" ]]; then
            log "Configurando módulo: $module"
            
            if [[ "$DRY_RUN" == "true" ]]; then
                log "[DRY-RUN] Ejecutando: $module_script"
            else
                if bash "$module_script"; then
                    success "Módulo $module configurado"
                else
                    warn "Error configurando módulo $module"
                fi
            fi
        else
            warn "Script de instalación no encontrado para módulo: $module"
        fi
    done
}

# Función para configurar entorno de root
configure_root_environment() {
    if [[ "${SETUP_ROOT:-false}" != "true" ]]; then
        return 0
    fi
    
    log "Configurando entorno de root..."
    
    local root_script="$MODULES_DIR/core/zsh/setup-root.sh"
    
    if [[ -f "$root_script" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log "[DRY-RUN] Configurando entorno de root"
        else
            if sudo bash "$root_script"; then
                success "Entorno de root configurado"
            else
                warn "Error configurando entorno de root"
            fi
        fi
    else
        warn "Script de configuración de root no encontrado"
    fi
}

# Función para limpiar sistema
cleanup_system() {
    log "Limpiando sistema..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY-RUN] Limpiando caché de paquetes"
        return 0
    fi
    
    # Limpiar caché de paquetes
    if clean_package_cache; then
        success "Sistema limpiado"
    else
        warn "No se pudo limpiar completamente el sistema"
    fi
}

# Función para mostrar resumen final
show_final_summary() {
    local summary_items=(
        "✅ Instalación completada exitosamente"
        "📦 Herramientas principales instaladas"
        "🚀 Herramientas modernas configuradas"
        "🎨 Módulos personalizados aplicados"
        "🔧 Sistema optimizado para productividad"
    )
    
    if [[ "$DRY_RUN" == "true" ]]; then
        summary_items=(
            "🔍 Simulación completada"
            "📋 Cambios que se realizarían:"
            "   • Instalación de herramientas principales"
            "   • Configuración de módulos"
            "   • Optimización del sistema"
        )
    fi
    
    if [[ "$SKIP_BACKUP" != "true" ]] && [[ -d "$BACKUP_DIR" ]]; then
        summary_items+=("💾 Backup creado en: $BACKUP_DIR")
    fi
    
    show_summary "🎉 Resumen de la instalación" "${summary_items[@]}"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        echo -e "${GREEN}🚀 ¡Tu sistema Arch Linux está listo para la productividad máxima!${COLOR_RESET}"
        echo -e "${CYAN}💡 Tip: Reinicia tu terminal para aplicar todos los cambios${COLOR_RESET}"
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
    show_banner "$SCRIPT_NAME v$SCRIPT_VERSION" "Instalación ultra rápida de herramientas de productividad"
    
    # Mostrar información del sistema
    debug "Sistema: $(get_arch_version)"
    debug "Usuario: $USER"
    debug "Directorio: $SCRIPT_DIR"
    debug "Modo DRY-RUN: $DRY_RUN"
    debug "Modo FORCE: $FORCE_INSTALL"
    debug "Modo VERBOSE: $VERBOSE"
    
    # Crear backup del sistema
    create_system_backup
    
    # Instalar herramientas principales
    install_core_tools
    
    # Instalar AUR helpers
    install_aur_helpers
    
    # Instalar herramientas modernas
    install_modern_tools
    
    # Instalar terminales
    install_terminals
    
    # Instalar editores
    install_editors
    
    # Instalar herramientas de desarrollo
    install_dev_tools
    
    # Configurar módulos
    configure_modules
    
    # Configurar entorno de root si se solicita
    configure_root_environment
    
    # Limpiar sistema
    cleanup_system
    
    # Mostrar resumen final
    show_final_summary
}

# =====================================================
# 🚀 EJECUCIÓN
# =====================================================

# Ejecutar función principal
main "$@" 