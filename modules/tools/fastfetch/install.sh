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
# 🧩 ARCH DREAM MACHINE - MÓDULO FASTFETCH
# =====================================================
# Script de instalación del módulo Fastfetch
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# =====================================================
# 🔧 CONFIGURACIÓN DEL MÓDULO
# =====================================================

MODULE_NAME="Fastfetch"
MODULE_DESCRIPTION="Información del sistema con temas personalizados"
MODULE_DEPENDENCIES=("fastfetch")
MODULE_FILES=("fastfetch/config.jsonc" "fastfetch/*.jpg")

# =====================================================
# 🔧 FUNCIONES DEL MÓDULO
# =====================================================

# Instalar dependencias del módulo
install_module_dependencies() {
    log "Instalando dependencias del módulo $MODULE_NAME..."
    
    # Instalar Fastfetch
    install_package "fastfetch"
}

# Configurar archivos del módulo
configure_module_files() {
    log "Configurando archivos del módulo $MODULE_NAME..."
    
    # Crear directorio de configuración
    mkdir -p "$HOME/.config"
    
    # Crear symlink para la configuración de Fastfetch
    create_symlink "$CONFIG_DIR/fastfetch" "$HOME/.config/fastfetch" "fastfetch"
}

# Verificar instalación del módulo
verify_module_installation() {
    log "Verificando instalación del módulo $MODULE_NAME..."
    
    local checks_passed=0
    local total_checks=2
    
    # Verificar Fastfetch instalado
    if command -v fastfetch &>/dev/null; then
        success "✓ Fastfetch instalado"
        ((checks_passed++))
    else
        error "✗ Fastfetch no está instalado"
    fi
    
    # Verificar symlink
    if [[ -L "$HOME/.config/fastfetch" ]] && [[ -e "$HOME/.config/fastfetch" ]]; then
        success "✓ Configuración de Fastfetch enlazada"
        ((checks_passed++))
    else
        error "✗ Configuración de Fastfetch no está enlazada"
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
    echo -e "${YELLOW}💡 Para probar Fastfetch, ejecuta: fastfetch${COLOR_RESET}"
}

# Ejecutar función principal
main "$@" 