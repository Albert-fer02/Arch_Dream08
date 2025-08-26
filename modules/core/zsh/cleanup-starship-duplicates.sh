#!/bin/zsh
# =====================================================
# 🧹 LIMPIADOR DE CONFIGURACIONES DUPLICADAS DE STARSHIP
# =====================================================
# Este script elimina todas las configuraciones duplicadas
# y mantiene solo la configuración unificada
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

# Función para limpiar enlaces simbólicos rotos
cleanup_broken_symlinks() {
    print_status "INFO" "Limpiando enlaces simbólicos rotos..."
    
    local broken_links=(
        "$HOME/.config/starship-catppuccin-latte.toml"
        "$HOME/.config/starship-catppuccin-mocha.toml"
        "$HOME/.config/starship-catppuccin-mocha-vscode.toml"
        "$HOME/.config/starship-catppuccin-mocha-vscode-simple.toml"
        "$HOME/.config/starship-simple.toml"
        "$HOME/.config/starship-vscode.toml"
    )
    
    for link in "${broken_links[@]}"; do
        if [[ -L "$link" ]] && [[ ! -e "$link" ]]; then
            rm -f "$link"
            print_status "OK" "Enlace roto eliminado: $(basename "$link")"
        fi
    done
}

# Función para verificar configuración unificada
verify_unified_config() {
    print_status "INFO" "Verificando configuración unificada..."
    
    local config_file="$HOME/.config/starship.toml"
    
    if [[ ! -f "$config_file" ]]; then
        print_status "ERROR" "Configuración unificada no encontrada"
        return 1
    fi
    
    # Verificar que sea la configuración correcta
    if grep -q "ARCH DREAM UNIFIED v4.3" "$config_file"; then
        print_status "OK" "Configuración unificada verificada"
    else
        print_status "ERROR" "Archivo no es la configuración unificada"
        return 1
    fi
    
    # Verificar sintaxis
    if command -v starship &>/dev/null; then
        if starship init zsh --print-full-init > /dev/null 2>&1; then
            print_status "OK" "Sintaxis de configuración válida"
        else
            print_status "ERROR" "Error de sintaxis en la configuración"
            return 1
        fi
    else
        print_status "WARN" "Starship no está instalado, no se puede verificar la sintaxis"
    fi
}

# Función para mostrar estado final
show_final_status() {
    print_status "INFO" "Estado final de la configuración de Starship:"
    echo ""
    
    local config_file="$HOME/.config/starship.toml"
    local symlink_file="$HOME/.starship.toml"
    
    echo "📁 Configuración principal:"
    if [[ -f "$config_file" ]]; then
        echo "   ✅ $config_file"
        echo "   📊 Tamaño: $(du -h "$config_file" | cut -f1)"
        echo "   🔒 Permisos: $(ls -l "$config_file" | awk '{print $1}')"
    else
        echo "   ❌ $config_file (NO ENCONTRADO)"
    fi
    
    echo ""
    echo "🔗 Enlace simbólico:"
    if [[ -L "$symlink_file" ]]; then
        echo "   ✅ $symlink_file"
        echo "   ➡️  Apunta a: $(readlink "$symlink_file")"
    else
        echo "   ❌ $symlink_file (NO ENCONTRADO)"
    fi
    
    echo ""
    echo "📋 Archivos de backup:"
    local backup_count=$(find "$HOME/.config/starship" -name "backup-*" -type d 2>/dev/null | wc -l)
    if [[ $backup_count -gt 0 ]]; then
        echo "   📦 $backup_count directorios de backup encontrados"
        echo "   📍 Ubicación: $HOME/.config/starship/backup-*/"
    else
        echo "   ℹ️  No se encontraron backups"
    fi
}

# Función principal
main() {
    echo -e "${BLUE}🧹 LIMPIADOR DE CONFIGURACIONES DUPLICADAS DE STARSHIP${NC}"
    echo "=================================================="
    echo ""
    
    print_status "INFO" "Iniciando limpieza..."
    
    # Limpiar enlaces simbólicos rotos
    cleanup_broken_symlinks
    
    # Verificar configuración unificada
    if verify_unified_config; then
        print_status "OK" "Configuración unificada verificada correctamente"
    else
        print_status "ERROR" "Problemas con la configuración unificada"
        return 1
    fi
    
    # Mostrar estado final
    show_final_status
    
    echo ""
    echo "=================================================="
    print_status "OK" "Limpieza completada exitosamente!"
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
