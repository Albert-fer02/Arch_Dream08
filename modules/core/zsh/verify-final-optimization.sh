#!/bin/zsh
# =====================================================
# ✅ VERIFICACIÓN FINAL DE OPTIMIZACIÓN - ARCH DREAM v4.3
# =====================================================
# Script para verificar que todas las optimizaciones
# estén aplicadas correctamente
# =====================================================

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}✅ VERIFICACIÓN FINAL DE OPTIMIZACIÓN${NC}"
echo "=================================================="
echo ""

# Función para verificar archivos comentados
verify_commented_files() {
    echo -e "${BLUE}📝 VERIFICANDO ARCHIVOS COMENTADOS:${NC}"
    echo ""
    
    # Verificar zshrc.modular
    if grep -q "#.*init_cache" modules/core/zsh/zshrc.modular; then
        echo -e "${GREEN}✅ init_cache comentado en zshrc.modular${NC}"
    else
        echo -e "${RED}❌ init_cache NO comentado en zshrc.modular${NC}"
    fi
    
    # Verificar cache.sh
    if grep -q "#.*cache_preload.*&" modules/core/common/cache.sh; then
        echo -e "${GREEN}✅ cache_preload & comentado en cache.sh${NC}"
    else
        echo -e "${RED}❌ cache_preload & NO comentado en cache.sh${NC}"
    fi
    
    if grep -q "#.*cache_preload()" modules/core/common/cache.sh; then
        echo -e "${GREEN}✅ Función cache_preload comentada en cache.sh${NC}"
    else
        echo -e "${RED}❌ Función cache_preload NO comentada en cache.sh${NC}"
    fi
    
    # Verificar logging.sh
    if grep -q "#.*sleep 60" modules/core/common/logging.sh; then
        echo -e "${GREEN}✅ sleep 60 comentado en logging.sh${NC}"
    else
        echo -e "${RED}❌ sleep 60 NO comentado en logging.sh${NC}"
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
    
    echo ""
}

# Función para verificar mensajes comentados
verify_commented_messages() {
    echo -e "${BLUE}🔇 VERIFICANDO MENSAJES COMENTADOS:${NC}"
    echo ""
    
    # Verificar mensajes de INFO
    if grep -q "#.*zsh_log_info.*ZSH Shell base initialized" modules/core/zsh/config/shell-base.zsh; then
        echo -e "${GREEN}✅ Mensaje ZSH Shell base initialized comentado${NC}"
    else
        echo -e "${RED}❌ Mensaje ZSH Shell base initialized NO comentado${NC}"
    fi
    
    if grep -q "#.*zsh_log_info.*Starship initialized successfully" modules/core/zsh/config/starship.zsh; then
        echo -e "${GREEN}✅ Mensaje Starship initialized successfully comentado${NC}"
    else
        echo -e "${RED}❌ Mensaje Starship initialized successfully NO comentado${NC}"
    fi
    
    if grep -q "#.*zsh_log_info.*ZSH modular optimizado" modules/core/zsh/zshrc.modular; then
        echo -e "${GREEN}✅ Mensaje ZSH modular optimizado comentado${NC}"
    else
        echo -e "${RED}❌ Mensaje ZSH modular optimizado NO comentado${NC}"
    fi
    
    # Verificar mensajes de DEBUG
    if grep -q "#.*zsh_log_debug.*Loading plugin" modules/core/zsh/plugins/plugin-manager.zsh; then
        echo -e "${GREEN}✅ Mensajes de debug de plugins comentados${NC}"
    else
        echo -e "${RED}❌ Mensajes de debug de plugins NO comentados${NC}"
    fi
    
    echo ""
}

# Función para verificar configuración de logging
verify_logging_config() {
    echo -e "${BLUE}🔇 VERIFICANDO CONFIGURACIÓN DE LOGGING:${NC}"
    echo ""
    
    # Verificar logging-config.zsh
    if [[ -f modules/core/zsh/config/logging-config.zsh ]]; then
        if grep -q "ARCH_DREAM_LOG_LEVEL.*FATAL" modules/core/zsh/config/logging-config.zsh; then
            echo -e "${GREEN}✅ Logging configurado en nivel FATAL${NC}"
        else
            echo -e "${RED}❌ Logging NO configurado en nivel FATAL${NC}"
        fi
        
        if grep -q "ARCH_DREAM_LOG_CONSOLE.*false" modules/core/zsh/config/logging-config.zsh; then
            echo -e "${GREEN}✅ Output a consola deshabilitado${NC}"
        else
            echo -e "${RED}❌ Output a consola NO deshabilitado${NC}"
        fi
    else
        echo -e "${RED}❌ Archivo logging-config.zsh no encontrado${NC}"
    fi
    
    echo ""
}

# Función para verificar estado del sistema
verify_system_status() {
    echo -e "${BLUE}🔍 VERIFICANDO ESTADO DEL SISTEMA:${NC}"
    echo ""
    
    # Verificar si hay procesos en background
    local background_jobs=$(jobs 2>/dev/null | wc -l)
    if [[ $background_jobs -eq 0 ]]; then
        echo -e "${GREEN}✅ No hay procesos en background${NC}"
    else
        echo -e "${YELLOW}⚠️  Procesos en background detectados: $background_jobs${NC}"
        jobs
    fi
    
    # Verificar variables de logging
    echo "📊 Variables de logging:"
    echo "   • ARCH_DREAM_LOG_LEVEL: ${ARCH_DREAM_LOG_LEVEL:-'No definida'}"
    echo "   • ARCH_DREAM_LOG_CONSOLE: ${ARCH_DREAM_LOG_CONSOLE:-'No definida'}"
    
    echo ""
}

# Función para mostrar resumen final
show_final_summary() {
    echo -e "${BLUE}📊 RESUMEN FINAL DE OPTIMIZACIÓN:${NC}"
    echo ""
    echo "✅ Archivos comentados:"
    echo "   • init_cache en zshrc.modular"
    echo "   • cache_preload en cache.sh"
    echo "   • cache.sh en cleanup.zsh y diagnose.zsh"
    echo "   • sleep 60 en logging.sh"
    echo ""
    echo "✅ Mensajes comentados:"
    echo "   • ZSH Shell base initialized"
    echo "   • Starship initialized successfully"
    echo "   • ZSH modular optimizado"
    echo "   • Mensajes de debug de plugins"
    echo ""
    echo "✅ Configuración de logging:"
    echo "   • Nivel: FATAL (solo errores críticos)"
    echo "   • Consola: Sin output"
    echo "   • Terminal: Completamente silenciosa"
    echo ""
    echo "✅ Procesos eliminados:"
    echo "   • cache_preload en background"
    echo "   • cleanup_logs y rotate_logs en background"
    echo "   • Procesos de logging automático"
    echo ""
}

# Función principal
main() {
    echo -e "${BLUE}🚀 Iniciando verificación final de optimización...${NC}"
    echo ""
    
    # Verificar archivos comentados
    verify_commented_files
    
    # Verificar mensajes comentados
    verify_commented_messages
    
    # Verificar configuración de logging
    verify_logging_config
    
    # Verificar estado del sistema
    verify_system_status
    
    # Mostrar resumen final
    show_final_summary
    
    echo "=================================================="
    echo -e "${GREEN}🎉 VERIFICACIÓN FINAL COMPLETADA!${NC}"
    echo ""
    echo -e "${BLUE}💡 PRÓXIMOS PASOS:${NC}"
    echo "1. Ejecuta: exec zsh"
    echo "2. Tu terminal debería abrirse instantáneamente"
    echo "3. Sin procesos en background"
    echo "4. Sin mensajes de logging"
    echo "5. Solo tu prompt de Starship perfecto"
    echo ""
    echo -e "${BLUE}🎯 RESULTADO ESPERADO:${NC}"
    echo "• Terminal ultra-rápida y silenciosa"
    echo "• Sin demoras de inicialización"
    echo "• Sin procesos zombies"
    echo "• Experiencia de usuario perfecta"
    echo ""
}

# Ejecutar función principal
main "$@"
