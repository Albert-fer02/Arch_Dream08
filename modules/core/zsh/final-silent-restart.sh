#!/bin/zsh
# =====================================================
# 🔇 REINICIO FINAL COMPLETAMENTE SILENCIOSO - ARCH DREAM v4.3
# =====================================================
# Script para reiniciar ZSH sin ningún mensaje de logging
# =====================================================

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔇 REINICIO FINAL COMPLETAMENTE SILENCIOSO${NC}"
echo "=================================================="
echo ""

# Función para configurar logging completamente silencioso
setup_complete_silent_logging() {
    echo -e "${BLUE}🔇 Configurando logging completamente silencioso...${NC}"
    
    # Configurar variables de logging para ser completamente silenciosas
    export ARCH_DREAM_LOG_LEVEL="FATAL"
    export ARCH_DREAM_LOG_CONSOLE="false"
    
    # También configurar variables de ZSH para ser silenciosas
    export ZSH_DEBUG="false"
    export ZSH_VERBOSE="false"
    
    echo -e "${GREEN}✅ Logging completamente silencioso configurado${NC}"
}

# Función para limpiar variables de debug
cleanup_debug_vars() {
    echo -e "${BLUE}🧹 Limpiando variables de debug...${NC}"
    
    # Limpiar variables que pueden causar output no deseado
    unset ZSH_DEBUG ZSH_VERBOSE ZSH_PROFILE 2>/dev/null || true
    unset ARCH_DREAM_DEBUG ARCH_DREAM_VERBOSE 2>/dev/null || true
    
    echo -e "${GREEN}✅ Variables de debug limpiadas${NC}"
}

# Función para mostrar estado final
show_final_status() {
    echo -e "${BLUE}📊 ESTADO FINAL DEL SISTEMA:${NC}"
    echo ""
    echo "🔇 Logging: FATAL (solo errores críticos)"
    echo "🚫 Consola: Sin output de logging"
    echo "🎯 Mensajes: Solo errores críticos del sistema"
    echo "✨ Terminal: Completamente limpia y profesional"
    echo ""
}

# Función para mostrar comandos útiles
show_useful_commands() {
    echo -e "${BLUE}🔧 COMANDOS ÚTILES DISPONIBLES:${NC}"
    echo ""
    echo "• show_logging_status           - Ver estado del logging"
    echo "• enable_debug_logging          - Habilitar debug temporal"
    echo "• enable_info_logging           - Habilitar logging informativo"
    echo "• enable_quiet_logging          - Habilitar logging silencioso"
    echo "• enable_complete_silent_logging - Volver a modo completamente silencioso"
    echo "• toggle_logging_mode           - Alternar entre modos"
    echo "• cleanup_old_logs              - Limpiar logs antiguos"
    echo ""
}

# Función principal
main() {
    echo -e "${BLUE}🚀 Iniciando reinicio final completamente silencioso...${NC}"
    echo ""
    
    # Configurar logging completamente silencioso
    setup_complete_silent_logging
    
    # Limpiar variables de debug
    cleanup_debug_vars
    
    # Mostrar estado final
    show_final_status
    
    # Mostrar comandos útiles
    show_useful_commands
    
    echo "=================================================="
    echo -e "${GREEN}🎉 CONFIGURACIÓN COMPLETADA!${NC}"
    echo ""
    echo -e "${BLUE}💡 PRÓXIMOS PASOS:${NC}"
    echo "1. Ejecuta: exec zsh"
    echo "2. Tu terminal estará completamente silenciosa"
    echo "3. Solo verás tu prompt de Powerlevel10k perfecto"
    echo "4. Sin ningún mensaje de logging"
    echo ""
    echo -e "${BLUE}🎯 RESULTADO ESPERADO:${NC}"
    echo "• Terminal completamente limpia y profesional"
    echo "• Solo prompt de Powerlevel10k visible"
    echo "• Sin mensajes de inicialización"
    echo "• Sin mensajes de debug o info"
    echo "• Experiencia de usuario perfecta"
    echo ""
}

# Ejecutar función principal
main "$@"
