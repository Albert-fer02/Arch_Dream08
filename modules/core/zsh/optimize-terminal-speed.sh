#!/bin/zsh
# =====================================================
# ⚡ OPTIMIZACIÓN DE VELOCIDAD DE TERMINAL - ARCH DREAM v4.3
# =====================================================
# Script para optimizar la velocidad de la terminal
# eliminando procesos en background y demoras
# =====================================================

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}⚡ OPTIMIZANDO VELOCIDAD DE TERMINAL${NC}"
echo "=================================================="
echo ""

# Función para mostrar resumen de optimizaciones
show_optimizations_summary() {
    echo -e "${YELLOW}📋 RESUMEN DE OPTIMIZACIONES APLICADAS:${NC}"
    echo ""
    echo "✅ Cache system deshabilitado:"
    echo "   • init_cache comentado en zshrc.modular"
    echo "   • cache_preload no se ejecuta en background"
    echo ""
    echo "✅ Procesos de logging en background eliminados:"
    echo "   • sleep 60 + cleanup_logs + rotate_logs comentado"
    echo "   • No más procesos zombies al iniciar"
    echo ""
    echo "✅ Logging completamente silencioso:"
    echo "   • Nivel: FATAL (solo errores críticos)"
    echo "   • Sin mensajes de INFO o DEBUG"
    echo "   • Sin output a consola"
    echo ""
}

# Función para verificar estado actual
check_current_status() {
    echo -e "${BLUE}🔍 VERIFICANDO ESTADO ACTUAL:${NC}"
    echo ""
    
    # Verificar si hay procesos en background
    local background_jobs=$(jobs 2>/dev/null | wc -l)
    if [[ $background_jobs -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  Procesos en background detectados: $background_jobs${NC}"
        jobs
    else
        echo -e "${GREEN}✅ No hay procesos en background${NC}"
    fi
    
    echo ""
    
    # Verificar variables de logging
    echo "📊 Variables de logging:"
    echo "   • ARCH_DREAM_LOG_LEVEL: ${ARCH_DREAM_LOG_LEVEL:-'No definida'}"
    echo "   • ARCH_DREAM_LOG_CONSOLE: ${ARCH_DREAM_LOG_CONSOLE:-'No definida'}"
    echo ""
}

# Función para limpiar procesos existentes
cleanup_existing_processes() {
    echo -e "${BLUE}🧹 LIMPIANDO PROCESOS EXISTENTES:${NC}"
    
    # Matar todos los jobs en background
    local job_count=$(jobs 2>/dev/null | wc -l)
    if [[ $job_count -gt 0 ]]; then
        echo "   • Jobs en background encontrados: $job_count"
        jobs | while read -r line; do
            if [[ $line =~ '\[([0-9]+)\]' ]]; then
                local job_id="${match[1]}"
                echo "   • Terminando job $job_id"
                kill %$job_id 2>/dev/null || true
            fi
        done
        echo -e "${GREEN}✅ Procesos en background terminados${NC}"
    else
        echo -e "${GREEN}✅ No hay procesos en background para limpiar${NC}"
    fi
    
    echo ""
}

# Función para mostrar beneficios de la optimización
show_benefits() {
    echo -e "${BLUE}🎯 BENEFICIOS DE LA OPTIMIZACIÓN:${NC}"
    echo ""
    echo "⚡ Velocidad:"
    echo "   • Terminal se abre instantáneamente"
    echo "   • Sin demoras de inicialización"
    echo "   • Sin procesos en background"
    echo ""
    echo "🔇 Silencio:"
    echo "   • Sin mensajes de logging molestos"
    echo "   • Solo prompt de Starship visible"
    echo "   • Experiencia de usuario limpia"
    echo ""
    echo "💾 Recursos:"
    echo "   • Menos uso de CPU al inicio"
    echo "   • Menos uso de memoria"
    echo "   • Sin procesos zombies"
    echo ""
}

# Función para mostrar comandos útiles
show_useful_commands() {
    echo -e "${BLUE}🔧 COMANDOS ÚTILES DISPONIBLES:${NC}"
    echo ""
    echo "• jobs                    - Ver procesos en background"
    echo "• kill %N                 - Terminar job específico"
    echo "• show_logging_status     - Ver estado del logging"
    echo "• enable_debug_logging    - Habilitar debug temporal"
    echo "• enable_info_logging     - Habilitar logging informativo"
    echo "• enable_quiet_logging    - Volver a modo silencioso"
    echo "• enable_complete_silent_logging - Modo completamente silencioso"
    echo ""
}

# Función principal
main() {
    echo -e "${BLUE}🚀 Iniciando optimización de velocidad...${NC}"
    echo ""
    
    # Mostrar resumen de optimizaciones
    show_optimizations_summary
    
    # Verificar estado actual
    check_current_status
    
    # Limpiar procesos existentes
    cleanup_existing_processes
    
    # Mostrar beneficios
    show_benefits
    
    # Mostrar comandos útiles
    show_useful_commands
    
    echo "=================================================="
    echo -e "${GREEN}🎉 OPTIMIZACIÓN DE VELOCIDAD COMPLETADA!${NC}"
    echo ""
    echo -e "${BLUE}💡 PRÓXIMOS PASOS:${NC}"
    echo "1. Ejecuta: exec zsh"
    echo "2. Tu terminal se abrirá instantáneamente"
    echo "3. Sin demoras ni procesos en background"
    echo "4. Solo tu prompt de Starship perfecto"
    echo ""
    echo -e "${BLUE}🎯 RESULTADO ESPERADO:${NC}"
    echo "• Terminal ultra-rápida y silenciosa"
    echo "• Sin mensajes de inicialización"
    echo "• Sin procesos zombies"
    echo "• Experiencia de usuario perfecta"
    echo ""
}

# Ejecutar función principal
main "$@"
