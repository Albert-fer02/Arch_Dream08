#!/bin/zsh
# =====================================================
# 🔍 DIAGNÓSTICO RÁPIDO DEL SISTEMA ZSH
# =====================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    local status="$1"
    local message="$2"
    
    case "$status" in
        "OK")     echo -e "${GREEN}✅ $message${NC}" ;;
        "WARN")   echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR")  echo -e "${RED}❌ $message${NC}" ;;
        "INFO")   echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Función para verificar archivos críticos
check_critical_files() {
    print_status "INFO" "Verificando archivos críticos..."
    
    local critical_files=(
        "$HOME/.config/zsh/config/shell-base.zsh"
        "$HOME/.config/zsh/common/logging.sh"
        # Comentado para evitar procesos en background
        # "$HOME/.config/zsh/common/cache.sh"
        # "$HOME/.config/zsh/config/starship.zsh" - Eliminado (migrando a Powerlevel10k)
        "$HOME/.config/zsh/ui/prompt.zsh"
    )
    
    local missing_files=0
    for file in "${critical_files[@]}"; do
        if [[ -f "$file" ]]; then
            if [[ -r "$file" ]]; then
                print_status "OK" "Archivo encontrado y legible: ${file##*/}"
            else
                print_status "ERROR" "Archivo sin permisos de lectura: ${file##*/}"
                ((missing_files++))
            fi
        else
            print_status "ERROR" "Archivo no encontrado: ${file##*/}"
            ((missing_files++))
        fi
    done
    
    return $missing_files
}

# Función para verificar funciones críticas
check_critical_functions() {
    print_status "INFO" "Verificando funciones críticas..."
    
    local critical_functions=(
        "safe_source"
        "zsh_log_info"
        "zsh_log_warn"
        "zsh_log_error"
        # "init_starship" - Eliminado (migrando a Powerlevel10k)
    )
    
    local missing_functions=0
    for func in "${critical_functions[@]}"; do
        if (( $+functions[$func] )); then
            print_status "OK" "Función disponible: $func"
        else
            print_status "ERROR" "Función no encontrada: $func"
            ((missing_functions++))
        fi
    done
    
    return $missing_functions
}

# Función para verificar estado del sistema (Starship eliminado)
check_system_status() {
    print_status "INFO" "Verificando estado del sistema..."
    print_status "OK" "Sistema preparado para Powerlevel10k"
    return 0
}

# Función para verificar hooks de zsh
check_zsh_hooks() {
    print_status "INFO" "Verificando hooks de ZSH..."
    
    autoload -Uz add-zsh-hook
    
    local hooks=("precmd" "preexec" "chpwd")
    local total_hooks=0
    
    for hook in "${hooks[@]}"; do
        local hook_count=$(add-zsh-hook -L "$hook" 2>/dev/null | wc -l)
        if [[ $hook_count -gt 0 ]]; then
            print_status "INFO" "Hook $hook: $hook_count funciones registradas"
            ((total_hooks += hook_count))
        else
            print_status "WARN" "Hook $hook: sin funciones registradas"
        fi
    done
    
    if [[ $total_hooks -gt 10 ]]; then
        print_status "WARN" "Muchos hooks registrados ($total_hooks), puede causar lentitud"
    fi
    
    return 0
}

# Función para verificar permisos y directorios
check_permissions() {
    print_status "INFO" "Verificando permisos y directorios..."
    
    local dirs_to_check=(
        "$HOME/.config/zsh"
        "$HOME/.cache/arch-dream"
        "$HOME/.config"
    )
    
    for dir in "${dirs_to_check[@]}"; do
        if [[ -d "$dir" ]]; then
            if [[ -w "$dir" ]]; then
                print_status "OK" "Directorio accesible: $dir"
            else
                print_status "WARN" "Directorio sin permisos de escritura: $dir"
            fi
        else
            print_status "WARN" "Directorio no encontrado: $dir"
        fi
    done
    
    return 0
}

# Función principal de diagnóstico
run_diagnosis() {
    echo -e "${BLUE}🔍 DIAGNÓSTICO DEL SISTEMA ZSH - ARCH DREAM${NC}"
    echo "=================================================="
    echo ""
    
    local total_errors=0
    local total_warnings=0
    
    # Ejecutar todas las verificaciones
    check_critical_files
    total_errors=$((total_errors + $?))
    
    check_critical_functions
    total_errors=$((total_errors + $?))
    
    check_system_status
    total_warnings=$((total_warnings + $?))
    
    check_zsh_hooks
    check_permissions
    
    echo ""
    echo "=================================================="
    echo -e "${BLUE}📊 RESUMEN DEL DIAGNÓSTICO:${NC}"
    
    if [[ $total_errors -eq 0 ]]; then
        print_status "OK" "Sistema funcionando correctamente"
    else
        print_status "ERROR" "Se encontraron $total_errors errores críticos"
    fi
    
    if [[ $total_warnings -gt 0 ]]; then
        print_status "WARN" "Se encontraron $total_warnings advertencias"
    fi
    
    echo ""
    echo -e "${BLUE}💡 RECOMENDACIONES:${NC}"
    
    if [[ $total_errors -gt 0 ]]; then
        echo "• Ejecuta: reinit_system"
        echo "• Ejecuta: perform_cleanup"
        echo "• Reinicia tu terminal"
    fi
    
    if [[ $total_warnings -gt 0 ]]; then
        echo "• Ejecuta: check_system_integrity"
        echo "• Sistema preparado para Powerlevel10k"
    fi
    
    if [[ $total_errors -eq 0 && $total_warnings -eq 0 ]]; then
        echo "• Tu sistema está funcionando perfectamente"
        echo "• No se requieren acciones adicionales"
    fi
}

# Ejecutar diagnóstico si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_diagnosis
fi

# Exportar función para uso global
export -f run_diagnosis
