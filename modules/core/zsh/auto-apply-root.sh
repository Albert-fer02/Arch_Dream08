#!/bin/bash
# =====================================================
# 🔄 AUTO-APLICADOR DE CONFIGURACIÓN ROOT - ARCH DREAM
# =====================================================
# Script para aplicar automáticamente la configuración
# cada vez que se accede como root
# Integrado con el proyecto Arch Dream v5.0
# =====================================================

set -euo pipefail

# Variables del proyecto
ARCH_DREAM_ROOT="/home/dreamcoder08/Documentos/PROYECTOS/Arch_Dream08"
CONFIG_SOURCE="$ARCH_DREAM_ROOT/modules/core/zsh/root/.zshrc"
CONFIG_TARGET="/root/.zshrc"
LOG_FILE="$HOME/.cache/arch-dream-root.log"

# Función de logging
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Función para aplicar configuración automáticamente
auto_apply_root_config() {
    # Crear directorio de logs si no existe
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
    
    # Verificar que el proyecto Arch Dream existe
    if [[ ! -d "$ARCH_DREAM_ROOT" ]]; then
        log_action "ERROR: Arch Dream project directory not found: $ARCH_DREAM_ROOT"
        return 1
    fi
    
    # Verificar si existe la configuración fuente
    if [[ -f "$CONFIG_SOURCE" ]]; then
        # Verificar si necesita actualización
        if [[ ! -f "$CONFIG_TARGET" ]] || [[ "$CONFIG_SOURCE" -nt "$CONFIG_TARGET" ]]; then
            log_action "Applying Arch Dream root configuration..."
            echo "🔄 Aplicando configuración root optimizada Arch Dream v5.0..."
            
            # Crear backup de configuración existente
            if [[ -f "$CONFIG_TARGET" ]]; then
                local backup_file="${CONFIG_TARGET}.backup.$(date +%Y%m%d_%H%M%S)"
                cp "$CONFIG_TARGET" "$backup_file"
                log_action "Backup created: $backup_file"
            fi
            
            # Copiar nueva configuración
            cp "$CONFIG_SOURCE" "$CONFIG_TARGET"
            chown root:root "$CONFIG_TARGET"
            chmod 644 "$CONFIG_TARGET"
            
            log_action "Root configuration updated successfully"
            echo "✅ Configuración root Arch Dream actualizada"
            echo "🚀 Arch Dream CLI disponible como 'ad'"
        else
            log_action "Root configuration is up to date"
        fi
    else
        log_action "ERROR: Source configuration not found: $CONFIG_SOURCE"
        echo "❌ Error: Configuración fuente no encontrada"
        return 1
    fi
}

# Función para verificar integridad del proyecto
verify_arch_dream_integration() {
    local errors=0
    
    echo "🔍 Verificando integración con Arch Dream..."
    
    # Verificar CLI principal
    if [[ -x "$ARCH_DREAM_ROOT/arch-dream" ]]; then
        echo "  ✅ Arch Dream CLI encontrado"
    else
        echo "  ❌ Arch Dream CLI no encontrado o no ejecutable"
        errors=$((errors + 1))
    fi
    
    # Verificar instalador
    if [[ -x "$ARCH_DREAM_ROOT/install.sh" ]]; then
        echo "  ✅ Instalador principal encontrado"
    else
        echo "  ❌ Instalador principal no encontrado"
        errors=$((errors + 1))
    fi
    
    # Verificar módulos
    if [[ -d "$ARCH_DREAM_ROOT/modules" ]]; then
        echo "  ✅ Directorio de módulos encontrado"
    else
        echo "  ❌ Directorio de módulos no encontrado"
        errors=$((errors + 1))
    fi
    
    if [[ $errors -eq 0 ]]; then
        echo "✅ Integración verificada correctamente"
        return 0
    else
        echo "❌ Se encontraron $errors errores en la integración"
        return 1
    fi
}

# Función principal
main() {
    case "${1:-apply}" in
        apply)
            auto_apply_root_config
            ;;
        verify)
            verify_arch_dream_integration
            ;;
        status)
            echo "📊 Estado de la configuración root Arch Dream"
            echo "Fuente: $CONFIG_SOURCE"
            echo "Destino: $CONFIG_TARGET"
            echo "Log: $LOG_FILE"
            if [[ -f "$CONFIG_TARGET" ]]; then
                echo "Estado: ✅ Configurado"
                echo "Modificado: $(stat -c %y "$CONFIG_TARGET")"
            else
                echo "Estado: ❌ No configurado"
            fi
            ;;
        *)
            echo "Uso: $0 [apply|verify|status]"
            echo "  apply  - Aplicar configuración root (predeterminado)"
            echo "  verify - Verificar integración con Arch Dream"
            echo "  status - Mostrar estado de la configuración"
            ;;
    esac
}

# Ejecutar función principal si se invoca directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi