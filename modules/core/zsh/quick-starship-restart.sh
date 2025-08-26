#!/bin/zsh
# =====================================================
# ⚡ REINICIO RÁPIDO DE STARSHIP - ARCH DREAM v4.3
# =====================================================
# Script para reiniciar Starship y aplicar cambios
# sin necesidad de reiniciar la terminal
# =====================================================

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}⚡ REINICIO RÁPIDO DE STARSHIP${NC}"
echo "=================================================="
echo ""

# Función para limpiar variables de Starship
cleanup_starship_vars() {
    echo -e "${YELLOW}🧹 Limpiando variables de Starship...${NC}"
    
    # Unset variables que pueden causar conflictos
    unset STARSHIP_CMD_STATUS STARSHIP_DURATION STARSHIP_JOBS STARSHIP_START_TIME 2>/dev/null || true
    
    # Limpiar funciones de Starship si existen
    if (( $+functions[starship_precmd] )); then
        unset -f starship_precmd 2>/dev/null || true
    fi
    
    if (( $+functions[starship_preexec] )); then
        unset -f starship_preexec 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✅ Variables limpiadas${NC}"
}

# Función para limpiar hooks de ZSH
cleanup_zsh_hooks() {
    echo -e "${YELLOW}🔗 Limpiando hooks de ZSH...${NC}"
    
    # Cargar add-zsh-hook si no está disponible
    autoload -Uz add-zsh-hook 2>/dev/null || true
    
    # Limpiar hooks específicos de Starship
    if (( $+functions[add-zsh-hook] )); then
        add-zsh-hook -D precmd starship_precmd 2>/dev/null || true
        add-zsh-hook -D preexec starship_preexec 2>/dev/null || true
        add-zsh-hook -D precmd _arch_dream_starship_precmd 2>/dev/null || true
        add-zsh-hook -D preexec _arch_dream_starship_preexec 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✅ Hooks limpiados${NC}"
}

# Función para reinicializar Starship
reinit_starship() {
    echo -e "${YELLOW}🔄 Reinicializando Starship...${NC}"
    
    # Verificar que Starship esté disponible
    if ! command -v starship &>/dev/null; then
        echo -e "${YELLOW}⚠️  Starship no está instalado${NC}"
        return 1
    fi
    
    # Verificar configuración
    if [[ ! -f "$HOME/.config/starship.toml" ]]; then
        echo -e "${YELLOW}⚠️  Configuración de Starship no encontrada${NC}"
        return 1
    fi
    
    # Inicializar Starship
    if starship_init=$(starship init zsh 2>/dev/null); then
        # Evaluar la inicialización
        eval "$starship_init"
        echo -e "${GREEN}✅ Starship reinicializado${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Error al reinicializar Starship${NC}"
        return 1
    fi
}

# Función para configurar hooks personalizados
setup_custom_hooks() {
    echo -e "${YELLOW}🎣 Configurando hooks personalizados...${NC}"
    
    # Verificar que las funciones estén disponibles
    if (( $+functions[starship_precmd] )) && (( $+functions[starship_preexec] )); then
        # Configurar hooks de Starship
        autoload -Uz add-zsh-hook
        
        # Limpiar hooks existentes primero
        add-zsh-hook -D precmd starship_precmd 2>/dev/null || true
        add-zsh-hook -D preexec starship_preexec 2>/dev/null || true
        
        # Agregar hooks nuevos
        add-zsh-hook precmd starship_precmd
        add-zsh-hook preexec starship_preexec
        
        echo -e "${GREEN}✅ Hooks de Starship configurados${NC}"
    else
        echo -e "${YELLOW}⚠️  Funciones de Starship no disponibles${NC}"
        return 1
    fi
}

# Función para verificar el estado final
verify_final_state() {
    echo -e "${YELLOW}🔍 Verificando estado final...${NC}"
    
    local success=true
    
    # Verificar funciones de Starship
    if (( $+functions[starship_precmd] )); then
        echo -e "${GREEN}✅ starship_precmd disponible${NC}"
    else
        echo -e "${YELLOW}⚠️  starship_precmd no disponible${NC}"
        success=false
    fi
    
    if (( $+functions[starship_preexec] )); then
        echo -e "${GREEN}✅ starship_preexec disponible${NC}"
    else
        echo -e "${YELLOW}⚠️  starship_preexec no disponible${NC}"
        success=false
    fi
    
    # Verificar hooks
    autoload -Uz add-zsh-hook
    local precmd_hooks=$(add-zsh-hook -L precmd 2>/dev/null | grep -c "starship" || echo "0")
    local preexec_hooks=$(add-zsh-hook -L preexec 2>/dev/null | grep -c "starship" || echo "0")
    
    if [[ $precmd_hooks -gt 0 ]]; then
        echo -e "${GREEN}✅ Hook precmd configurado (${precmd_hooks})${NC}"
    else
        echo -e "${YELLOW}⚠️  Hook precmd no configurado${NC}"
        success=false
    fi
    
    if [[ $preexec_hooks -gt 0 ]]; then
        echo -e "${GREEN}✅ Hook preexec configurado (${preexec_hooks})${NC}"
    else
        echo -e "${YELLOW}⚠️  Hook preexec no configurado${NC}"
        success=false
    fi
    
    return $([[ "$success" == "true" ]] && echo 0 || echo 1)
}

# Función principal
main() {
    echo -e "${BLUE}🚀 Iniciando reinicio rápido de Starship...${NC}"
    echo ""
    
    # Limpiar estado anterior
    cleanup_starship_vars
    cleanup_zsh_hooks
    
    # Reinicializar Starship
    if reinit_starship; then
        # Configurar hooks personalizados
        setup_custom_hooks
        
        # Verificar estado final
        if verify_final_state; then
            echo ""
            echo "=================================================="
            echo -e "${GREEN}🎉 REINICIO COMPLETADO EXITOSAMENTE!${NC}"
            echo ""
            echo -e "${BLUE}💡 PRÓXIMOS PASOS:${NC}"
            echo "• El prompt debería actualizarse automáticamente"
            echo "• Si no ves cambios, ejecuta: exec zsh"
            echo "• Para verificar: run_diagnosis"
            echo ""
            echo -e "${BLUE}🔧 COMANDOS ÚTILES:${NC}"
            echo "• run_diagnosis - Verificar sistema"
            echo "• perform_cleanup - Limpiar conflictos"
            echo "• exec zsh - Reiniciar shell completo"
        else
            echo ""
            echo "=================================================="
            echo -e "${YELLOW}⚠️  REINICIO COMPLETADO CON ADVERTENCIAS${NC}"
            echo ""
            echo -e "${BLUE}💡 RECOMENDACIONES:${NC}"
            echo "• Ejecuta: exec zsh"
            echo "• O reinicia tu terminal"
            echo "• Para diagnóstico: run_diagnosis"
        fi
    else
        echo ""
        echo "=================================================="
        echo -e "${YELLOW}⚠️  REINICIO FALLÓ${NC}"
        echo ""
        echo -e "${BLUE}💡 SOLUCIONES:${NC}"
        echo "• Verifica que Starship esté instalado"
        echo "• Verifica la configuración: cat ~/.config/starship.toml"
        echo "• Ejecuta: exec zsh"
    fi
}

# Ejecutar función principal
main "$@"
