#!/bin/zsh
# =====================================================
# 🚀 INSTALADOR DE STARSHIP UNIFICADO - ARCH DREAM v4.3
# =====================================================
# Este script unifica todas las configuraciones de Starship
# en un solo archivo para evitar conflictos
# =====================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    local status_type="$1"
    local message="$2"
    
    case "$status_type" in
        "OK")     echo -e "${GREEN}✅ $message${NC}" ;;
        "WARN")   echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR")  echo -e "${RED}❌ $message${NC}" ;;
        "INFO")   echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Función para crear directorios si no existen
create_directories() {
    local dirs=(
        "$HOME/.config"
        "$HOME/.config/starship"
        "$HOME/.cache/arch-dream"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            print_status "OK" "Directorio creado: $dir"
        else
            print_status "INFO" "Directorio ya existe: $dir"
        fi
    done
}

# Función para hacer backup de configuraciones existentes
backup_existing_configs() {
    local backup_dir="$HOME/.config/starship/backup-$(date +%Y%m%d_%H%M%S)"
    local existing_configs=(
        "$HOME/.config/starship.toml"
        "$HOME/.starship.toml"
        "$HOME/.config/starship/config.toml"
    )
    
    mkdir -p "$backup_dir"
    print_status "INFO" "Creando backup en: $backup_dir"
    
    for config in "${existing_configs[@]}"; do
        if [[ -f "$config" ]]; then
            cp "$config" "$backup_dir/"
            print_status "OK" "Backup creado: $(basename "$config")"
        fi
    done
    
    # Backup de configuraciones del proyecto
    local project_backup_dir="$backup_dir/project-configs"
    mkdir -p "$project_backup_dir"
    
    local project_configs=(
        "lib/starship.toml"
        "modules/core/bash/starship.toml"
        "modules/themes/catppuccin/catppuccin-mocha.toml"
        "modules/themes/catppuccin/catppuccin-latte.toml"
        "modules/themes/catppuccin/catppuccin-mocha-vscode.toml"
        "modules/themes/catppuccin/catppuccin-mocha-vscode-simple.toml"
    )
    
    for config in "${project_configs[@]}"; do
        if [[ -f "$config" ]]; then
            cp "$config" "$project_backup_dir/"
            print_status "OK" "Backup del proyecto: $(basename "$config")"
        fi
    done
    
    print_status "OK" "Backup completado en: $backup_dir"
}

# Función para instalar configuración unificada
install_unified_config() {
    local source_config="modules/core/zsh/starship-unified.toml"
    local target_config="$HOME/.config/starship.toml"
    
    if [[ ! -f "$source_config" ]]; then
        print_status "ERROR" "Archivo de configuración unificada no encontrado: $source_config"
        return 1
    fi
    
    # Instalar configuración unificada
    cp "$source_config" "$target_config"
    print_status "OK" "Configuración unificada instalada en: $target_config"
    
    # Verificar que se instaló correctamente
    if [[ -f "$target_config" ]]; then
        print_status "OK" "Verificación exitosa de la instalación"
    else
        print_status "ERROR" "Error en la instalación"
        return 1
    fi
}

# Función para limpiar configuraciones duplicadas del proyecto
cleanup_duplicate_configs() {
    print_status "INFO" "Limpiando configuraciones duplicadas del proyecto..."
    
    local duplicate_configs=(
        "lib/starship.toml"
        "modules/core/bash/starship.toml"
        "modules/themes/catppuccin/catppuccin-mocha.toml"
        "modules/themes/catppuccin/catppuccin-latte.toml"
        "modules/themes/catppuccin/catppuccin-mocha-vscode.toml"
        "modules/themes/catppuccin/catppuccin-mocha-vscode-simple.toml"
    )
    
    for config in "${duplicate_configs[@]}"; do
        if [[ -f "$config" ]]; then
            # Renombrar con .backup en lugar de eliminar
            mv "$config" "${config}.backup"
            print_status "WARN" "Archivo renombrado: $config → ${config}.backup"
        fi
    done
}

# Función para actualizar referencias en el código
update_code_references() {
    print_status "INFO" "Actualizando referencias en el código..."
    
    # Actualizar referencia en starship.zsh
    local starship_zsh="modules/core/zsh/config/starship.zsh"
    if [[ -f "$starship_zsh" ]]; then
        # Buscar y reemplazar la referencia a la configuración
        sed -i 's|export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"|export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"|g' "$starship_zsh"
        print_status "OK" "Referencias actualizadas en: $starship_zsh"
    fi
    
    # Crear enlace simbólico para compatibilidad
    if [[ ! -L "$HOME/.starship.toml" ]]; then
        ln -sf "$HOME/.config/starship.toml" "$HOME/.starship.toml"
        print_status "OK" "Enlace simbólico creado: $HOME/.starship.toml"
    fi
}

# Función para verificar la instalación
verify_installation() {
    print_status "INFO" "Verificando la instalación..."
    
    local target_config="$HOME/.config/starship.toml"
    
    if [[ ! -f "$target_config" ]]; then
        print_status "ERROR" "Configuración no encontrada en: $target_config"
        return 1
    fi
    
    # Verificar sintaxis de TOML
    if command -v starship &>/dev/null; then
        if starship init zsh --print-config &>/dev/null; then
            print_status "OK" "Sintaxis de configuración válida"
        else
            print_status "WARN" "Posible problema de sintaxis en la configuración"
        fi
    else
        print_status "WARN" "Starship no está instalado, no se puede verificar la sintaxis"
    fi
    
    # Verificar que las variables críticas estén definidas
    local critical_sections=(
        "username"
        "hostname"
        "directory"
        "git_branch"
        "character"
    )
    
    for section in "${critical_sections[@]}"; do
        if grep -q "^\[$section\]" "$target_config"; then
            print_status "OK" "Sección $section encontrada"
        else
            print_status "WARN" "Sección $section no encontrada"
        fi
    done
    
    print_status "OK" "Verificación completada"
}

# Función principal
main() {
    echo -e "${BLUE}🚀 INSTALADOR DE STARSHIP UNIFICADO - ARCH DREAM v4.3${NC}"
    echo "=================================================="
    echo ""
    
    print_status "INFO" "Iniciando proceso de unificación..."
    
    # Crear directorios necesarios
    create_directories
    
    # Hacer backup de configuraciones existentes
    backup_existing_configs
    
    # Instalar configuración unificada
    install_unified_config
    
    # Limpiar configuraciones duplicadas
    cleanup_duplicate_configs
    
    # Actualizar referencias en el código
    update_code_references
    
    # Verificar la instalación
    verify_installation
    
    echo ""
    echo "=================================================="
    print_status "OK" "Instalación de Starship unificado completada exitosamente!"
    echo ""
    echo -e "${BLUE}📋 RESUMEN DE LA INSTALACIÓN:${NC}"
    echo "• Configuración unificada instalada en: $HOME/.config/starship.toml"
    echo "• Backup creado en: $HOME/.config/starship/backup-*/"
    echo "• Archivos duplicados renombrados con .backup"
    echo "• Enlace simbólico creado en: $HOME/.starship.toml"
    echo ""
    echo -e "${BLUE}💡 PRÓXIMOS PASOS:${NC}"
    echo "1. Reinicia tu terminal"
    echo "2. Ejecuta: starship-restart"
    echo "3. Verifica que no hay errores de STARSHIP_CMD_STATUS"
    echo ""
    echo -e "${BLUE}🔧 COMANDOS ÚTILES:${NC}"
    echo "• run_diagnosis - Para verificar el sistema"
    echo "• perform_cleanup - Para limpiar conflictos"
    echo "• starship-restart - Para reiniciar Starship"
}

# Ejecutar función principal
main "$@"
