#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM MACHINE - MÓDULO NANO
# =====================================================
# Script de instalación del módulo Nano
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# =====================================================
# 🔧 CONFIGURACIÓN DEL MÓDULO
# =====================================================

MODULE_NAME="Nano Editor"
MODULE_DESCRIPTION="Editor de texto con configuración avanzada"
MODULE_DEPENDENCIES=("nano")
MODULE_FILES=("nano/nanorc.conf")

# =====================================================
# 🔧 FUNCIONES DEL MÓDULO
# =====================================================

# Instalar dependencias del módulo
install_module_dependencies() {
    log "Instalando dependencias del módulo $MODULE_NAME..."
    
    # Instalar Nano
    install_package "nano"
    
    # Instalar herramientas adicionales opcionales
    local optional_packages=("aspell" "python-pip")
    for pkg in "${optional_packages[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            if confirm "¿Instalar $pkg (opcional)?"; then
                install_package "$pkg"
            fi
        fi
    done
}

# Configurar archivos del módulo
configure_module_files() {
    log "Configurando archivos del módulo $MODULE_NAME..."
    
    # Crear directorio de backups
    mkdir -p "$HOME/.nano/backups"
    
    # Crear symlink para .nanorc
    create_symlink "$CONFIG_DIR/nano/nanorc.conf" "$HOME/.nanorc" ".nanorc"
    
    # Crear directorio de sintaxis si no existe
    mkdir -p "$HOME/.nano/syntax"
}

# Verificar instalación del módulo
verify_module_installation() {
    log "Verificando instalación del módulo $MODULE_NAME..."
    
    local checks_passed=0
    local total_checks=3
    
    # Verificar Nano instalado
    if command -v nano &>/dev/null; then
        success "✓ Nano instalado"
        ((checks_passed++))
    else
        error "✗ Nano no está instalado"
    fi
    
    # Verificar .nanorc
    if [[ -L "$HOME/.nanorc" ]] && [[ -e "$HOME/.nanorc" ]]; then
        success "✓ .nanorc configurado"
        ((checks_passed++))
    else
        error "✗ .nanorc no está configurado"
    fi
    
    # Verificar directorio de backups
    if [[ -d "$HOME/.nano/backups" ]]; then
        success "✓ Directorio de backups creado"
        ((checks_passed++))
    else
        error "✗ Directorio de backups no creado"
    fi
    
    if [[ $checks_passed -eq $total_checks ]]; then
        success "Módulo $MODULE_NAME instalado correctamente ($checks_passed/$total_checks)"
        return 0
    else
        warn "Módulo $MODULE_NAME instalado parcialmente ($checks_passed/$total_checks)"
        return 1
    fi
}

# =====================================================
# 🏁 FUNCIÓN PRINCIPAL
# =====================================================

main() {
    # Inicializar biblioteca
    init_library
    
    # Banner
    echo -e "${BOLD}${CYAN}🧩 INSTALANDO MÓDULO: $MODULE_NAME${COLOR_RESET}"
    echo -e "${CYAN}$MODULE_DESCRIPTION${COLOR_RESET}\n"
    
    # Instalar dependencias
    install_module_dependencies
    
    # Configurar archivos
    configure_module_files
    
    # Verificar instalación
    verify_module_installation
    
    echo -e "\n${BOLD}${GREEN}✅ Módulo $MODULE_NAME instalado exitosamente${COLOR_RESET}"
    echo -e "${YELLOW}💡 Para probar Nano: nano archivo.txt${COLOR_RESET}"
}

# Ejecutar función principal
main "$@" 