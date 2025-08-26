#!/bin/zsh
# =====================================================
# 🔇 REINICIO SILENCIOSO DE ZSH - ARCH DREAM v4.3
# =====================================================
# Script para reiniciar ZSH sin mensajes de debug
# =====================================================

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔇 REINICIO SILENCIOSO DE ZSH${NC}"
echo "=================================================="
echo ""

# Función para configurar logging silencioso
setup_silent_logging() {
    echo -e "${BLUE}🔇 Configurando logging silencioso...${NC}"
    
    # Configurar variables de logging para ser silenciosas
    export ARCH_DREAM_LOG_LEVEL="WARN"
    export ARCH_DREAM_LOG_CONSOLE="false"
    
    # También configurar variables de ZSH para ser silenciosas
    export ZSH_DEBUG="false"
    export ZSH_VERBOSE="false"
    
    echo -e "${GREEN}✅ Logging silencioso configurado${NC}"
}

# Función para limpiar variables de debug
cleanup_debug_vars() {
    echo -e "${BLUE}🧹 Limpiando variables de debug...${NC}"
    
    # Limpiar variables que pueden causar output no deseado
    unset ZSH_DEBUG ZSH_VERBOSE ZSH_PROFILE 2>/dev/null || true
    unset ARCH_DREAM_DEBUG ARCH_DREAM_VERBOSE 2>/dev/null || true
    
    echo -e "${GREEN}✅ Variables de debug limpiadas${NC}"
}

# Función para reiniciar ZSH de forma silenciosa
restart_zsh_silently() {
    echo -e "${BLUE}🔄 Reiniciando ZSH de forma silenciosa...${NC}"
    
    # Configurar logging silencioso
    setup_silent_logging
    
    # Limpiar variables de debug
    cleanup_debug_vars
    
    echo ""
    echo "=================================================="
    echo -e "${GREEN}🎉 Configuración completada!${NC}"
    echo ""
    echo -e "${BLUE}💡 PRÓXIMOS PASOS:${NC}"
    echo "• Ejecuta: exec zsh"
    echo "• O reinicia tu terminal"
    echo "• Los mensajes de debug ya no aparecerán"
    echo ""
    echo -e "${BLUE}🔧 COMANDOS ÚTILES:${NC}"
    echo "• show_logging_status - Ver estado del logging"
    echo "• enable_debug_logging - Habilitar debug temporal"
    echo "• enable_quiet_logging - Volver a modo silencioso"
    echo "• toggle_logging_mode - Alternar entre modos"
}

# Función principal
main() {
    echo -e "${BLUE}🚀 Iniciando configuración de reinicio silencioso...${NC}"
    echo ""
    
    # Configurar reinicio silencioso
    restart_zsh_silently
}

# Ejecutar función principal
main "$@"
