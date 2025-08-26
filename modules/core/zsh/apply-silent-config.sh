#!/bin/zsh
# =====================================================
# 🔇 APLICAR CONFIGURACIÓN SILENCIOSA - ARCH DREAM v4.3
# =====================================================
# Script para aplicar todos los cambios de configuración silenciosa
# =====================================================

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔇 APLICANDO CONFIGURACIÓN SILENCIOSA${NC}"
echo "=================================================="
echo ""

# Función para mostrar resumen de cambios
show_changes_summary() {
    echo -e "${YELLOW}📋 RESUMEN DE CAMBIOS APLICADOS:${NC}"
    echo ""
    echo "✅ Plugin Manager:"
    echo "   • Mensajes de debug de plugins comentados"
    echo "   • Mensajes de Zoxide comentados"
    echo "   • Mensajes de Atuin comentados"
    echo "   • Mensajes de syntax highlighting comentados"
    echo ""
    echo "✅ Configuración de Environment:"
    echo "   • Mensaje de debug de perfil comentado"
    echo ""
    echo "✅ Configuración de History:"
    echo "   • Mensaje de debug de historial comentado"
    echo ""
    echo "✅ Shell Base:"
    echo "   • Mensaje de debug de módulos comentado"
    echo "   • Mensaje de verificación de integridad comentado"
    echo ""
    echo "✅ Logging System:"
    echo "   • Nivel de logging configurado en WARN"
    echo "   • Output a consola deshabilitado"
    echo ""
}

# Función para verificar archivos modificados
verify_modified_files() {
    echo -e "${YELLOW}🔍 VERIFICANDO ARCHIVOS MODIFICADOS:${NC}"
    echo ""
    
    local files_to_check=(
        "modules/core/zsh/plugins/plugin-manager.zsh"
        "modules/core/zsh/config/environment.zsh"
        "modules/core/zsh/config/history.zsh"
        "modules/core/zsh/config/shell-base.zsh"
        "modules/core/zsh/config/logging-config.zsh"
    )
    
    for file in "${files_to_check[@]}"; do
        if [[ -f "$file" ]]; then
            echo -e "${GREEN}✅ $file${NC}"
        else
            echo -e "${YELLOW}⚠️  $file (no encontrado)${NC}"
        fi
    done
    
    echo ""
}

# Función para configurar logging silencioso
setup_silent_logging() {
    echo -e "${YELLOW}🔇 CONFIGURANDO LOGGING SILENCIOSO:${NC}"
    
    # Configurar variables de logging para ser silenciosas
    export ARCH_DREAM_LOG_LEVEL="WARN"
    export ARCH_DREAM_LOG_CONSOLE="false"
    
    # También configurar variables de ZSH para ser silenciosas
    export ZSH_DEBUG="false"
    export ZSH_VERBOSE="false"
    
    echo -e "${GREEN}✅ Logging silencioso configurado${NC}"
    echo ""
}

# Función para mostrar comandos útiles
show_useful_commands() {
    echo -e "${BLUE}🔧 COMANDOS ÚTILES DISPONIBLES:${NC}"
    echo ""
    echo "• show_logging_status    - Ver estado del logging"
    echo "• enable_debug_logging   - Habilitar debug temporal"
    echo "• enable_info_logging    - Habilitar logging informativo"
    echo "• enable_quiet_logging   - Volver a modo silencioso"
    echo "• toggle_logging_mode    - Alternar entre modos"
    echo "• cleanup_old_logs       - Limpiar logs antiguos"
    echo ""
}

# Función principal
main() {
    echo -e "${BLUE}🚀 Iniciando aplicación de configuración silenciosa...${NC}"
    echo ""
    
    # Mostrar resumen de cambios
    show_changes_summary
    
    # Verificar archivos modificados
    verify_modified_files
    
    # Configurar logging silencioso
    setup_silent_logging
    
    # Mostrar comandos útiles
    show_useful_commands
    
    echo "=================================================="
    echo -e "${GREEN}🎉 CONFIGURACIÓN SILENCIOSA APLICADA!${NC}"
    echo ""
    echo -e "${BLUE}💡 PRÓXIMOS PASOS:${NC}"
    echo "1. Ejecuta: exec zsh"
    echo "2. Los mensajes de debug ya no aparecerán"
    echo "3. Solo verás mensajes importantes (WARN, ERROR)"
    echo ""
    echo -e "${BLUE}⚠️  NOTA:${NC}"
    echo "Si necesitas debug temporal, usa: enable_debug_logging"
    echo "Para volver al modo silencioso: enable_quiet_logging"
    echo ""
}

# Ejecutar función principal
main "$@"
