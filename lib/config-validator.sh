#!/bin/bash
# =====================================================
# ✅ ARCH DREAM - SISTEMA DE VALIDACIÓN CENTRALIZADO
# =====================================================
# Sistema unificado para validar configuraciones y detectar problemas
# Previene errores, detecta configuraciones rotas, sugiere optimizaciones
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# =====================================================
# 🔧 CONFIGURACIÓN DEL VALIDADOR
# =====================================================

# Directorios de validación
VALIDATOR_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/arch-dream/validator"
VALIDATION_CACHE="$VALIDATOR_ROOT/cache"
VALIDATION_REPORTS="$VALIDATOR_ROOT/reports"
VALIDATION_LOG="$VALIDATOR_ROOT/validation.log"

# Configuración
VALIDATION_TIMEOUT=30
PARALLEL_VALIDATION=true
DETAILED_REPORTS=true
AUTO_FIX_ISSUES=false

# Definiciones de validación
declare -A SHELL_CONFIGS=(
    ["bashrc"]="$HOME/.bashrc"
    ["zshrc"]="$HOME/.zshrc"
    ["bash_profile"]="$HOME/.bash_profile"
    ["zprofile"]="$HOME/.zprofile"

)

declare -A APP_CONFIGS=(
    ["nvim"]="$HOME/.config/nvim"
    ["kitty"]="$HOME/.config/kitty"
    ["git"]="$HOME/.gitconfig"
    ["ssh"]="$HOME/.ssh/config"
    ["fastfetch"]="$HOME/.config/fastfetch"
)

declare -A CRITICAL_PATHS=(
    ["shell_base"]="$HOME/../lib/shell-base.sh"
    ["common"]="$HOME/../lib/common.sh"
    ["module_manager"]="$HOME/../lib/module-manager.sh"
)

# =====================================================
# 🔧 FUNCIONES DE INICIALIZACIÓN
# =====================================================

init_validator() {
    debug "Inicializando sistema de validación..."
    
    mkdir -p "$VALIDATOR_ROOT" "$VALIDATION_CACHE" "$VALIDATION_REPORTS"
    chmod 755 "$VALIDATOR_ROOT" "$VALIDATION_CACHE" "$VALIDATION_REPORTS"
    
    [[ -f "$VALIDATION_LOG" ]] || echo "# Arch Dream Configuration Validation Log" > "$VALIDATION_LOG"
    
    success "✅ Sistema de validación inicializado"
}

# =====================================================
# 🔍 VALIDADORES ESPECÍFICOS
# =====================================================

# Validar configuraciones de shell
validate_shell_configs() {
    local issues=()
    local warnings=()
    local suggestions=()
    
    log "🐚 Validando configuraciones de shell..."
    
    for config_name in "${!SHELL_CONFIGS[@]}"; do
        local config_path="${SHELL_CONFIGS[$config_name]}"
        
        if [[ ! -e "$config_path" ]]; then
            warnings+=("$config_name: Archivo no existe ($config_path)")
            continue
        fi
        
        case "$config_name" in
            bashrc|zshrc)
                # Verificar sintaxis básica
                if [[ -f "$config_path" ]]; then
                    if ! bash -n "$config_path" 2>/dev/null; then
                        issues+=("$config_name: Error de sintaxis en $config_path")
                    fi
                    
                    # Verificar que carga shell-base
                    if ! grep -q "shell-base.sh" "$config_path"; then
                        suggestions+=("$config_name: Considerar usar arquitectura unificada (shell-base.sh)")
                    fi
                    
                    # Verificar duplicaciones
                    local alias_count=$(grep -c "^alias " "$config_path" 2>/dev/null || echo 0)
                    if [[ $alias_count -gt 50 ]]; then
                        suggestions+=("$config_name: Muchos aliases ($alias_count), considerar centralizar")
                    fi
                fi
                ;;

        esac
    done
    
    # Verificar conflictos entre shells
    if [[ -f "${SHELL_CONFIGS[bashrc]}" && -f "${SHELL_CONFIGS[zshrc]}" ]]; then
        local bash_aliases=$(grep "^alias " "${SHELL_CONFIGS[bashrc]}" 2>/dev/null | wc -l)
        local zsh_aliases=$(grep "^alias " "${SHELL_CONFIGS[zshrc]}" 2>/dev/null | wc -l)
        
        if [[ $bash_aliases -gt 10 && $zsh_aliases -gt 10 ]]; then
            suggestions+=("shell: Detectada duplicación de aliases entre bash y zsh")
        fi
    fi
    
    # Retornar resultados
    create_validation_report "shell" "${issues[@]}" "${warnings[@]}" "${suggestions[@]}"
}

# Validar configuraciones de aplicaciones
validate_app_configs() {
    local issues=()
    local warnings=()
    local suggestions=()
    
    log "📱 Validando configuraciones de aplicaciones..."
    
    for app_name in "${!APP_CONFIGS[@]}"; do
        local config_path="${APP_CONFIGS[$app_name]}"
        
        if [[ ! -e "$config_path" ]]; then
            if command -v "$app_name" &>/dev/null; then
                warnings+=("$app_name: Aplicación instalada pero sin configuración ($config_path)")
            fi
            continue
        fi
        
        case "$app_name" in
            nvim)
                if [[ -d "$config_path" ]]; then
                    # Verificar init.lua
                    if [[ ! -f "$config_path/init.lua" ]]; then
                        issues+=("nvim: Falta init.lua en $config_path")
                    else
                        # Verificar sintaxis Lua básica
                        if command -v lua &>/dev/null; then
                            if ! lua -e "dofile('$config_path/init.lua')" 2>/dev/null; then
                                issues+=("nvim: Error de sintaxis en init.lua")
                            fi
                        fi
                    fi
                    
                    # Verificar plugins desactualizados
                    if [[ -d "$config_path/lazy-lock.json" ]] && [[ -f "$config_path/lazy-lock.json" ]]; then
                        local lock_age=$(find "$config_path/lazy-lock.json" -mtime +30 2>/dev/null | wc -l)
                        if [[ $lock_age -gt 0 ]]; then
                            suggestions+=("nvim: lazy-lock.json no actualizado en más de 30 días")
                        fi
                    fi
                fi
                ;;
            kitty)
                if [[ -d "$config_path" ]]; then
                    if [[ ! -f "$config_path/kitty.conf" ]]; then
                        issues+=("kitty: Falta kitty.conf en $config_path")
                    else
                        # Verificar configuración válida
                        if command -v kitty &>/dev/null; then
                            if ! kitty --config="$config_path/kitty.conf" --version &>/dev/null; then
                                issues+=("kitty: Configuración inválida en kitty.conf")
                            fi
                        fi
                    fi
                fi
                ;;
            git)
                if [[ -f "$config_path" ]]; then
                    # Verificar configuración básica
                    if ! git config --file="$config_path" user.email &>/dev/null; then
                        warnings+=("git: Email no configurado")
                    fi
                    if ! git config --file="$config_path" user.name &>/dev/null; then
                        warnings+=("git: Nombre no configurado")
                    fi
                fi
                ;;
        esac
    done
    
    create_validation_report "apps" "${issues[@]}" "${warnings[@]}" "${suggestions[@]}"
}

# Validar integridad del sistema
validate_system_integrity() {
    local issues=()
    local warnings=()
    local suggestions=()
    
    log "🔧 Validando integridad del sistema..."
    
    # Verificar archivos críticos
    for path_name in "${!CRITICAL_PATHS[@]}"; do
        local path="${CRITICAL_PATHS[$path_name]}"
        local expanded_path=$(eval echo "$path")  # Expandir variables
        
        if [[ ! -f "$expanded_path" ]]; then
            issues+=("system: Archivo crítico faltante - $path_name ($expanded_path)")
        else
            # Verificar permisos de ejecución para scripts
            if [[ "$expanded_path" == *.sh ]] && [[ ! -x "$expanded_path" ]]; then
                warnings+=("system: Script sin permisos de ejecución - $path_name")
            fi
        fi
    done
    
    # Verificar enlaces simbólicos rotos
    local broken_links=()
    for config_path in "${SHELL_CONFIGS[@]}" "${APP_CONFIGS[@]}"; do
        if [[ -L "$config_path" ]] && [[ ! -e "$config_path" ]]; then
            broken_links+=("$config_path")
        fi
    done
    
    if [[ ${#broken_links[@]} -gt 0 ]]; then
        issues+=("system: Enlaces simbólicos rotos detectados: ${broken_links[*]}")
    fi
    
    # Verificar permisos de directorios de configuración
    local config_dirs=("$HOME/.config" "$HOME/.local" "$HOME/.cache")
    for dir in "${config_dirs[@]}"; do
        if [[ -d "$dir" ]] && [[ ! -r "$dir" ]]; then
            issues+=("system: Directorio sin permisos de lectura - $dir")
        fi
    done
    
    # Verificar espacio en disco
    local available_space=$(df "$HOME" | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 1048576 ]]; then  # Menos de 1GB
        warnings+=("system: Poco espacio en disco: $(($available_space / 1024))MB disponible")
    fi
    
    # Verificar carga del sistema
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    if awk -v a="$load_avg" -v b="5.0" 'BEGIN{exit (a>b)?0:1}'; then
        warnings+=("system: Alta carga del sistema: $load_avg")
    fi
    
    create_validation_report "system" "${issues[@]}" "${warnings[@]}" "${suggestions[@]}"
}

# =====================================================
# 📊 REPORTES Y ANÁLISIS
# =====================================================

# Crear reporte de validación
create_validation_report() {
    local category="$1"
    shift
    local all_items=("$@")
    
    # Separar por tipo (issues, warnings, suggestions)
    local issues=()
    local warnings=()
    local suggestions=()
    local current_type="issues"
    
    for item in "${all_items[@]}"; do
        case "$item" in
            "--warnings-start")
                current_type="warnings"
                continue
                ;;
            "--suggestions-start")
                current_type="suggestions"
                continue
                ;;
        esac
        
        case "$current_type" in
            issues) issues+=("$item") ;;
            warnings) warnings+=("$item") ;;
            suggestions) suggestions+=("$item") ;;
        esac
    done
    
    local report_file="$VALIDATION_REPORTS/${category}_$(date +%Y%m%d_%H%M%S).json"
    local timestamp=$(date -Iseconds)
    
    # Crear reporte JSON
    cat > "$report_file" << EOF
{
  "category": "$category",
  "timestamp": "$timestamp",
  "summary": {
    "issues": ${#issues[@]},
    "warnings": ${#warnings[@]},
    "suggestions": ${#suggestions[@]}
  },
  "details": {
    "issues": [$(printf '"%s",' "${issues[@]}" | sed 's/,$//')],,
    "warnings": [$(printf '"%s",' "${warnings[@]}" | sed 's/,$//')],,
    "suggestions": [$(printf '"%s",' "${suggestions[@]}" | sed 's/,$//')]
  }
}
EOF
    
    # Log resumen
    echo "$timestamp | $category | ${#issues[@]} issues, ${#warnings[@]} warnings, ${#suggestions[@]} suggestions" >> "$VALIDATION_LOG"
    
    # Mostrar resumen en consola
    local total_problems=$((${#issues[@]} + ${#warnings[@]}))
    if [[ $total_problems -eq 0 ]]; then
        success "✅ $category: Sin problemas detectados"
    else
        if [[ ${#issues[@]} -gt 0 ]]; then
            error "❌ $category: ${#issues[@]} errores críticos"
        fi
        if [[ ${#warnings[@]} -gt 0 ]]; then
            warn "⚠️  $category: ${#warnings[@]} advertencias"
        fi
        if [[ ${#suggestions[@]} -gt 0 ]]; then
            log "💡 $category: ${#suggestions[@]} sugerencias de optimización"
        fi
    fi
    
    echo "$report_file"
}

# Mostrar reporte detallado
show_detailed_report() {
    local report_file="$1"
    
    if [[ ! -f "$report_file" ]]; then
        error "❌ Reporte no encontrado: $report_file"
        return 1
    fi
    
    local category=$(jq -r '.category' "$report_file")
    local timestamp=$(jq -r '.timestamp' "$report_file")
    local issues_count=$(jq -r '.summary.issues' "$report_file")
    local warnings_count=$(jq -r '.summary.warnings' "$report_file")
    local suggestions_count=$(jq -r '.summary.suggestions' "$report_file")
    
    echo -e "${BOLD}${BLUE}📋 Reporte Detallado - $category${COLOR_RESET}"
    echo -e "${CYAN}Generado: $timestamp${COLOR_RESET}"
    echo
    
    if [[ $issues_count -gt 0 ]]; then
        echo -e "${RED}❌ Errores Críticos ($issues_count):${COLOR_RESET}"
        jq -r '.details.issues[]' "$report_file" | sed 's/^/  • /'
        echo
    fi
    
    if [[ $warnings_count -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  Advertencias ($warnings_count):${COLOR_RESET}"
        jq -r '.details.warnings[]' "$report_file" | sed 's/^/  • /'
        echo
    fi
    
    if [[ $suggestions_count -gt 0 ]]; then
        echo -e "${BLUE}💡 Sugerencias de Optimización ($suggestions_count):${COLOR_RESET}"
        jq -r '.details.suggestions[]' "$report_file" | sed 's/^/  • /'
        echo
    fi
}

# Mostrar resumen de todos los reportes
show_validation_summary() {
    echo -e "${BOLD}${BLUE}📊 Resumen de Validación${COLOR_RESET}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    
    local total_issues=0
    local total_warnings=0
    local total_suggestions=0
    local categories=0
    
    for report_file in "$VALIDATION_REPORTS"/*.json; do
        [[ -f "$report_file" ]] || continue
        
        local category=$(jq -r '.category' "$report_file" 2>/dev/null || echo "unknown")
        local issues=$(jq -r '.summary.issues' "$report_file" 2>/dev/null || echo "0")
        local warnings=$(jq -r '.summary.warnings' "$report_file" 2>/dev/null || echo "0")
        local suggestions=$(jq -r '.summary.suggestions' "$report_file" 2>/dev/null || echo "0")
        
        echo -e "${CYAN}│${COLOR_RESET} $category: ${RED}$issues${COLOR_RESET} errores, ${YELLOW}$warnings${COLOR_RESET} advertencias, ${BLUE}$suggestions${COLOR_RESET} sugerencias"
        
        total_issues=$((total_issues + issues))
        total_warnings=$((total_warnings + warnings))
        total_suggestions=$((total_suggestions + suggestions))
        ((categories++))
    done
    
    echo -e "${CYAN}├─────────────────────────────────────────────────────────────┤${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} TOTAL: ${RED}$total_issues${COLOR_RESET} errores, ${YELLOW}$total_warnings${COLOR_RESET} advertencias, ${BLUE}$total_suggestions${COLOR_RESET} sugerencias"
    echo -e "${CYAN}│${COLOR_RESET} Categorías validadas: $categories"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${COLOR_RESET}"
    
    # Evaluación general
    if [[ $total_issues -eq 0 && $total_warnings -eq 0 ]]; then
        echo -e "${GREEN}🎉 ¡Sistema en perfecto estado!${COLOR_RESET}"
    elif [[ $total_issues -eq 0 ]]; then
        echo -e "${YELLOW}⚠️  Sistema funcional con advertencias menores${COLOR_RESET}"
    else
        echo -e "${RED}🚨 Errores críticos detectados - requiere atención${COLOR_RESET}"
    fi
}

# =====================================================
# 🏁 INTERFAZ PRINCIPAL
# =====================================================

config_validator_main() {
    local action="${1:-help}"
    shift || true
    
    # Inicializar si es necesario
    [[ -d "$VALIDATOR_ROOT" ]] || init_validator
    
    case "$action" in
        init)
            init_validator
            ;;
        validate)
            local category="${1:-all}"
            case "$category" in
                shell) validate_shell_configs ;;
                apps) validate_app_configs ;;
                system) validate_system_integrity ;;
                all)
                    validate_shell_configs
                    validate_app_configs
                    validate_system_integrity
                    ;;
                *) error "❌ Categoría desconocida: $category" ;;
            esac
            ;;
        report)
            local report_file="$1"
            show_detailed_report "$report_file"
            ;;
        summary)
            show_validation_summary
            ;;
        clean)
            rm -rf "$VALIDATION_REPORTS"/*
            success "✅ Reportes de validación limpiados"
            ;;
        help|*)
            cat << 'EOF'
✅ Sistema de Validación Centralizado - Arch Dream

Uso: config_validator_main <acción> [argumentos]

Acciones:
  init                    Inicializar sistema de validación
  validate [categoria]    Ejecutar validación (shell|apps|system|all)
  report <archivo>        Mostrar reporte detallado
  summary                 Mostrar resumen de todas las validaciones
  clean                   Limpiar reportes antiguos
  help                    Mostrar esta ayuda

Variables de entorno:
  AUTO_FIX_ISSUES=true    Intentar arreglar problemas automáticamente
  DETAILED_REPORTS=true   Generar reportes detallados

Ejemplos:
  config_validator_main validate all
  config_validator_main summary
  config_validator_main report "$VALIDATION_REPORTS/shell_*.json"
EOF
            ;;
    esac
}

# Exportar funciones principales
export -f init_validator validate_shell_configs validate_app_configs
export -f validate_system_integrity create_validation_report show_detailed_report
export -f show_validation_summary config_validator_main

# Variables exportadas
export VALIDATOR_ROOT VALIDATION_CACHE VALIDATION_REPORTS VALIDATION_LOG