#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM MACHINE - MÓDULO BASH
# =====================================================
# Script de instalación del módulo Bash
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# =====================================================
# 🔧 CONFIGURACIÓN DEL MÓDULO
# =====================================================

MODULE_NAME="Bash Fallback"
MODULE_DESCRIPTION="Configuración de fallback para sistemas sin Zsh"
MODULE_DEPENDENCIES=("bash")
MODULE_FILES=("bashrc")

# =====================================================
# 🔧 FUNCIONES DEL MÓDULO
# =====================================================

# Instalar dependencias del módulo
install_module_dependencies() {
    log "Instalando dependencias del módulo $MODULE_NAME..."
    
    # Verificar que Bash esté instalado
    if command -v bash &>/dev/null; then
        success "✓ Bash ya está instalado"
    else
        install_package "bash"
    fi
}

# Configurar archivos del módulo
configure_module_files() {
    log "Configurando archivos del módulo $MODULE_NAME..."
    
    # Crear symlink para .bashrc
    create_symlink "$CONFIG_DIR/bashrc" "$HOME/.bashrc" ".bashrc"
    
    # Crear symlink para .bash_profile si no existe
    if [[ ! -e "$HOME/.bash_profile" ]]; then
        create_symlink "$CONFIG_DIR/bashrc" "$HOME/.bash_profile" ".bash_profile"
    fi
}

# Verificar instalación del módulo
verify_module_installation() {
    log "Verificando instalación del módulo $MODULE_NAME..."
    
    local checks_passed=0
    local total_checks=3
    
    # Verificar Bash instalado
    if command -v bash &>/dev/null; then
        success "✓ Bash instalado"
        ((checks_passed++))
    else
        error "✗ Bash no está instalado"
    fi
    
    # Verificar .bashrc
    if [[ -L "$HOME/.bashrc" ]] && [[ -e "$HOME/.bashrc" ]]; then
        success "✓ .bashrc configurado"
        ((checks_passed++))
    else
        error "✗ .bashrc no está configurado"
    fi
    
    # Verificar .bash_profile
    if [[ -L "$HOME/.bash_profile" ]] && [[ -e "$HOME/.bash_profile" ]]; then
        success "✓ .bash_profile configurado"
        ((checks_passed++))
    else
        success "✓ .bash_profile no es necesario (opcional)"
        ((checks_passed++))
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
    echo -e "${YELLOW}💡 Para usar Bash: bash${COLOR_RESET}"
}

# Ejecutar función principal
main "$@" 