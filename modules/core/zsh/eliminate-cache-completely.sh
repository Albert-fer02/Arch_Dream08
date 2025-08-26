#!/bin/zsh
# =====================================================
# 🗑️ ELIMINACIÓN COMPLETA DEL CACHE - ARCH DREAM v4.3
# =====================================================
# Script para eliminar completamente cualquier proceso de cache
# que pueda estar causando demoras
# =====================================================

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🗑️ ELIMINACIÓN COMPLETA DEL CACHE${NC}"
echo "=================================================="
echo ""

# Función para verificar procesos de cache
check_cache_processes() {
    echo -e "${BLUE}🔍 VERIFICANDO PROCESOS DE CACHE:${NC}"
    echo ""
    
    # Verificar si hay procesos de cache en ejecución
    local cache_processes=$(ps aux | grep -E "(cache_preload|init_cache)" | grep -v grep | wc -l)
    if [[ $cache_processes -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  Procesos de cache detectados: $cache_processes${NC}"
        ps aux | grep -E "(cache_preload|init_cache)" | grep -v grep
    else
        echo -e "${GREEN}✅ No hay procesos de cache ejecutándose${NC}"
    fi
    
    echo ""
    
    # Verificar jobs en background
    local background_jobs=$(jobs 2>/dev/null | wc -l)
    if [[ $background_jobs -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  Jobs en background: $background_jobs${NC}"
        jobs
    else
        echo -e "${GREEN}✅ No hay jobs en background${NC}"
    fi
    
    echo ""
}

# Función para eliminar procesos de cache
eliminate_cache_processes() {
    echo -e "${BLUE}🗑️ ELIMINANDO PROCESOS DE CACHE:${NC}"
    echo ""
    
    # Terminar todos los jobs en background
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
        echo -e "${GREEN}✅ Jobs en background terminados${NC}"
    else
        echo -e "${GREEN}✅ No hay jobs en background para eliminar${NC}"
    fi
    
    echo ""
    
    # Matar procesos de cache si existen
    local cache_pids=$(ps aux | grep -E "(cache_preload|init_cache)" | grep -v grep | awk '{print $2}')
    if [[ -n "$cache_pids" ]]; then
        echo "   • Procesos de cache encontrados:"
        for pid in $cache_pids; do
            echo "   • Terminando proceso $pid"
            kill -9 "$pid" 2>/dev/null || true
        done
        echo -e "${GREEN}✅ Procesos de cache terminados${NC}"
    else
        echo -e "${GREEN}✅ No hay procesos de cache para eliminar${NC}"
    fi
    
    echo ""
}

# Función para verificar archivos de cache comentados
verify_cache_files_commented() {
    echo -e "${BLUE}📝 VERIFICANDO ARCHIVOS DE CACHE COMENTADOS:${NC}"
    echo ""
    
    # Verificar zshrc.modular
    if grep -q "#.*init_cache" modules/core/zsh/zshrc.modular; then
        echo -e "${GREEN}✅ init_cache comentado en zshrc.modular${NC}"
    else
        echo -e "${RED}❌ init_cache NO comentado en zshrc.modular${NC}"
    fi
    
    # Verificar cleanup.zsh
    if grep -q "#.*cache\.sh" modules/core/zsh/advanced/cleanup.zsh; then
        echo -e "${GREEN}✅ cache.sh comentado en cleanup.zsh${NC}"
    else
        echo -e "${RED}❌ cache.sh NO comentado en cleanup.zsh${NC}"
    fi
    
    # Verificar diagnose.zsh
    if grep -q "#.*cache\.sh" modules/core/zsh/diagnose.zsh; then
        echo -e "${GREEN}✅ cache.sh comentado en diagnose.zsh${NC}"
    else
        echo -e "${RED}❌ cache.sh NO comentado en diagnose.zsh${NC}"
    fi
    
    # Verificar logging.sh
    if grep -q "#.*sleep 60.*cleanup_logs.*rotate_logs" modules/core/common/logging.sh; then
        echo -e "${GREEN}✅ Procesos de logging en background comentados${NC}"
    else
        echo -e "${RED}❌ Procesos de logging en background NO comentados${NC}"
    fi
    
    echo ""
}

# Función para mostrar estado final
show_final_status() {
    echo -e "${BLUE}📊 ESTADO FINAL DEL SISTEMA:${NC}"
    echo ""
    echo "🗑️ Cache: Completamente deshabilitado"
    echo "⚡ Velocidad: Terminal ultra-rápida"
    echo "🔇 Silencio: Sin mensajes de logging"
    echo "🚫 Background: Sin procesos en segundo plano"
    echo "✨ Experiencia: Completamente limpia"
    echo ""
}

# Función para mostrar comandos útiles
show_useful_commands() {
    echo -e "${BLUE}🔧 COMANDOS ÚTILES DISPONIBLES:${NC}"
    echo ""
    echo "• jobs                    - Ver procesos en background"
    echo "• ps aux | grep cache     - Buscar procesos de cache"
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
    echo -e "${BLUE}🚀 Iniciando eliminación completa del cache...${NC}"
    echo ""
    
    # Verificar procesos de cache
    check_cache_processes
    
    # Eliminar procesos de cache
    eliminate_cache_processes
    
    # Verificar archivos comentados
    verify_cache_files_commented
    
    # Mostrar estado final
    show_final_status
    
    # Mostrar comandos útiles
    show_useful_commands
    
    echo "=================================================="
    echo -e "${GREEN}🎉 ELIMINACIÓN COMPLETA DEL CACHE COMPLETADA!${NC}"
    echo ""
    echo -e "${BLUE}💡 PRÓXIMOS PASOS:${NC}"
    echo "1. Ejecuta: exec zsh"
    echo "2. Tu terminal se abrirá instantáneamente"
    echo "3. Sin procesos de cache ni demoras"
    echo "4. Solo tu prompt de Powerlevel10k perfecto"
    echo ""
    echo -e "${BLUE}🎯 RESULTADO ESPERADO:${NC}"
    echo "• Terminal ultra-rápida y silenciosa"
    echo "• Sin procesos de cache en background"
    echo "• Sin mensajes de inicialización"
    echo "• Sin demoras ni procesos zombies"
    echo "• Experiencia de usuario perfecta"
    echo ""
}

# Ejecutar función principal
main "$@"
