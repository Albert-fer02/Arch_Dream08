#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM - UNIFIED MODULE MANAGER
# =====================================================
# Sistema unificado de gestión de módulos optimizado
# Reemplaza duplicaciones y simplifica instalaciones
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# =====================================================
# 🔧 CONFIGURACIÓN GLOBAL
# =====================================================

# Cargar configuración base
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shell-base.sh" 2>/dev/null || true

# Directorios del sistema
PROJECT_ROOT="${SCRIPT_DIR%/*}"
MODULES_ROOT="$PROJECT_ROOT/modules"
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/arch-dream"
CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/arch-dream"
STATE_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/arch-dream"

# Archivos de estado
MODULES_STATE="$STATE_ROOT/modules.json"
INSTALL_LOG="$STATE_ROOT/install.log"
DEPENDENCIES_GRAPH="$STATE_ROOT/dependencies.json"

# Configuración de módulos
PARALLEL_INSTALLS=${PARALLEL_INSTALLS:-4}
INSTALL_TIMEOUT=${INSTALL_TIMEOUT:-300}
VERIFY_INTEGRITY=${VERIFY_INTEGRITY:-true}
BACKUP_BEFORE_INSTALL=${BACKUP_BEFORE_INSTALL:-true}

# =====================================================
# 🔧 FUNCIONES DE INICIALIZACIÓN
# =====================================================

# Inicializar sistema de gestión de módulos
init_module_manager() {
    debug "Inicializando gestor de módulos..."
    
    # Crear estructura de directorios
    mkdir -p "$CONFIG_ROOT" "$CACHE_ROOT" "$STATE_ROOT"
    chmod 755 "$CONFIG_ROOT" "$CACHE_ROOT" "$STATE_ROOT"
    
    # Inicializar archivos de estado
    [[ -f "$MODULES_STATE" ]] || echo '{"modules": {}, "last_update": "", "version": "1.0"}' > "$MODULES_STATE"
    [[ -f "$INSTALL_LOG" ]] || echo "# Arch Dream Module Installation Log" > "$INSTALL_LOG"
    [[ -f "$DEPENDENCIES_GRAPH" ]] || echo '{"dependencies": {}}' > "$DEPENDENCIES_GRAPH"
    
    success "✅ Gestor de módulos inicializado"
}

# =====================================================
# 🔍 DISCOVERY Y ANÁLISIS DE MÓDULOS
# =====================================================

# Descubrir módulos disponibles
discover_modules() {
    local modules=()
    local cache_file="$CACHE_ROOT/available_modules.cache"
    local cache_ttl=3600  # 1 hora
    
    # Usar cache si es válido
    if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -c %Y "$cache_file"))) -lt $cache_ttl ]]; then
        cat "$cache_file"
        return 0
    fi
    
    # Escanear módulos disponibles
    for category_dir in "$MODULES_ROOT"/*; do
        [[ -d "$category_dir" ]] || continue
        local category=$(basename "$category_dir")
        
        for module_dir in "$category_dir"/*; do
            [[ -d "$module_dir" && -f "$module_dir/install.sh" ]] || continue
            local module=$(basename "$module_dir")
            modules+=("$category:$module")
        done
    done
    
    # Guardar en cache
    printf '%s\n' "${modules[@]}" > "$cache_file"
    printf '%s\n' "${modules[@]}"
}

# Obtener información de módulo
get_module_info() {
    local module_id="$1"
    local category="${module_id%:*}"
    local module="${module_id#*:}"
    local module_path="$MODULES_ROOT/$category/$module"
    
    [[ -d "$module_path" ]] || return 1
    
    # Extraer información del script de instalación
    local name description dependencies files
    if [[ -f "$module_path/install.sh" ]]; then
        name=$(grep '^MODULE_NAME=' "$module_path/install.sh" | head -1 | cut -d'"' -f2 || echo "$module")
        description=$(grep '^MODULE_DESCRIPTION=' "$module_path/install.sh" | head -1 | cut -d'"' -f2 || echo "")
        dependencies=$(grep '^MODULE_DEPENDENCIES=' "$module_path/install.sh" | head -1 | sed 's/.*(\([^)]*\)).*/\1/' | tr '"' ' ' || echo "")
        files=$(grep '^MODULE_FILES=' "$module_path/install.sh" | head -1 | sed 's/.*(\([^)]*\)).*/\1/' | tr '"' ' ' || echo "")
    fi
    
    # Retornar información estructurada
    cat << EOF
{
  "id": "$module_id",
  "category": "$category",
  "module": "$module",
  "name": "${name:-$module}",
  "description": "${description:-No description}",
  "dependencies": [$(echo "$dependencies" | sed 's/\([^ ]*\)/"\1"/g' | tr ' ' ',')],
  "files": [$(echo "$files" | sed 's/\([^ ]*\)/"\1"/g' | tr ' ' ',')],
  "path": "$module_path",
  "status": "$(get_module_status "$module_id")"
}
EOF
}

# =====================================================
# 🔗 GESTIÓN DE DEPENDENCIAS
# =====================================================

# Resolver dependencias de módulos
resolve_dependencies() {
    local modules=("$@")
    local resolved=()
    local processing=()
    local processed=()
    
    # Función recursiva para resolver dependencias
    resolve_recursive() {
        local module="$1"
        
        # Evitar ciclos infinitos
        if [[ " ${processing[*]} " =~ " $module " ]]; then
            warn "Dependencia circular detectada: $module"
            return 1
        fi
        
        # Si ya fue procesado, saltar
        if [[ " ${processed[*]} " =~ " $module " ]]; then
            return 0
        fi
        
        processing+=("$module")
        
        # Obtener dependencias del módulo
        local module_info
        module_info=$(get_module_info "$module" 2>/dev/null) || {
            warn "Módulo no encontrado: $module"
            return 1
        }
        
        # Procesar dependencias primero
        local deps
        deps=$(echo "$module_info" | jq -r '.dependencies[]?' 2>/dev/null || true)
        while IFS= read -r dep; do
            [[ -n "$dep" ]] && resolve_recursive "$dep"
        done <<< "$deps"
        
        # Agregar módulo actual
        if [[ ! " ${resolved[*]} " =~ " $module " ]]; then
            resolved+=("$module")
        fi
        
        processed+=("$module")
        processing=("${processing[@]/$module}")
    }
    
    # Resolver cada módulo solicitado
    for module in "${modules[@]}"; do
        resolve_recursive "$module" || continue
    done
    
    printf '%s\n' "${resolved[@]}"
}

# =====================================================
# 🚀 INSTALACIÓN UNIFICADA
# =====================================================

# Instalar módulo individual
install_module() {
    local module_id="$1"
    local force="${2:-false}"
    local dry_run="${3:-false}"
    
    log "📦 Instalando módulo: $module_id"
    
    # Verificar si ya está instalado
    if [[ "$force" != "true" ]] && [[ "$(get_module_status "$module_id")" == "installed" ]]; then
        success "✅ Módulo $module_id ya está instalado"
        return 0
    fi
    
    # Obtener información del módulo
    local module_info
    module_info=$(get_module_info "$module_id") || {
        error "❌ Módulo no encontrado: $module_id"
        return 1
    }
    
    local module_path
    module_path=$(echo "$module_info" | jq -r '.path')
    
    # Crear backup si está habilitado
    if [[ "$BACKUP_BEFORE_INSTALL" == "true" ]] && [[ "$dry_run" != "true" ]]; then
        create_module_backup "$module_id"
    fi
    
    # Ejecutar instalación
    if [[ "$dry_run" == "true" ]]; then
        success "🔍 DRY-RUN: Módulo $module_id sería instalado"
        return 0
    fi
    
    # Cambiar al directorio del módulo y ejecutar instalación
    local start_time=$(date +%s)
    local install_result=0
    
    (
        cd "$module_path"
        timeout "$INSTALL_TIMEOUT" bash install.sh
    ) || install_result=$?
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Registrar resultado
    if [[ $install_result -eq 0 ]]; then
        update_module_status "$module_id" "installed" "$duration"
        log_installation "$module_id" "success" "$duration"
        success "✅ Módulo $module_id instalado exitosamente (${duration}s)"
    else
        update_module_status "$module_id" "failed" "$duration"
        log_installation "$module_id" "failed" "$duration"
        error "❌ Fallo al instalar módulo $module_id"
        return 1
    fi
}

# Instalar múltiples módulos con dependencias
install_modules() {
    local modules=("$@")
    local force="${FORCE_INSTALL:-false}"
    local dry_run="${DRY_RUN:-false}"
    local parallel="${PARALLEL_INSTALL:-false}"
    
    # Resolver dependencias
    local resolved_modules=()
    mapfile -t resolved_modules < <(resolve_dependencies "${modules[@]}")
    
    if [[ ${#resolved_modules[@]} -eq 0 ]]; then
        error "❌ No se pudieron resolver las dependencias"
        return 1
    fi
    
    log "🚀 Instalando ${#resolved_modules[@]} módulos con dependencias resueltas"
    
    local installed=0
    local failed=0
    local skipped=0
    
    if [[ "$parallel" == "true" ]] && [[ ${#resolved_modules[@]} -gt 1 ]]; then
        # Instalación paralela (experimental)
        install_modules_parallel "${resolved_modules[@]}"
    else
        # Instalación secuencial
        for module in "${resolved_modules[@]}"; do
            if install_module "$module" "$force" "$dry_run"; then
                ((installed++))
            else
                ((failed++))
                # Decidir si continuar o abortar
                if [[ "$force" != "true" ]]; then
                    error "❌ Instalación abortada por error en: $module"
                    break
                fi
            fi
        done
    fi
    
    # Mostrar resumen
    show_installation_summary "$installed" "$failed" "$skipped"
}

# =====================================================
# 📊 GESTIÓN DE ESTADO
# =====================================================

# Actualizar estado de módulo
update_module_status() {
    local module_id="$1"
    local status="$2"
    local duration="${3:-0}"
    local timestamp=$(date -Iseconds)
    
    # Actualizar archivo de estado
    local temp_file=$(mktemp)
    jq --arg module "$module_id" \
       --arg status "$status" \
       --arg timestamp "$timestamp" \
       --arg duration "$duration" \
       '.modules[$module] = {
         "status": $status,
         "timestamp": $timestamp,
         "duration": ($duration | tonumber),
         "version": "1.0"
       } | .last_update = $timestamp' "$MODULES_STATE" > "$temp_file"
    
    mv "$temp_file" "$MODULES_STATE"
    debug "Estado actualizado: $module_id -> $status"
}

# Obtener estado de módulo
get_module_status() {
    local module_id="$1"
    jq -r --arg module "$module_id" '.modules[$module].status // "not_installed"' "$MODULES_STATE" 2>/dev/null
}

# Listar módulos por estado
list_modules_by_status() {
    local status="${1:-installed}"
    jq -r --arg status "$status" '
        .modules | 
        to_entries | 
        map(select(.value.status == $status)) | 
        .[].key
    ' "$MODULES_STATE" 2>/dev/null
}

# =====================================================
# 📝 LOGGING Y RESPALDO
# =====================================================

# Registrar instalación en log
log_installation() {
    local module_id="$1"
    local status="$2"
    local duration="$3"
    local timestamp=$(date -Iseconds)
    
    echo "$timestamp | $module_id | $status | ${duration}s" >> "$INSTALL_LOG"
}

# Crear backup antes de instalación
create_module_backup() {
    local module_id="$1"
    local backup_dir="$STATE_ROOT/backups/$(date +%Y%m%d_%H%M%S)_${module_id//[:\/]/_}"
    
    # Obtener información del módulo para conocer qué archivos afecta
    local module_info
    module_info=$(get_module_info "$module_id") || return 1
    
    # Crear backup de archivos que podrían ser modificados
    mkdir -p "$backup_dir"
    
    # Backup de configuraciones comunes
    local common_configs=(
        "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.vimrc"
        "$HOME/.config" "$HOME/.local/share"
    )
    
    for config in "${common_configs[@]}"; do
        if [[ -e "$config" ]]; then
            cp -r "$config" "$backup_dir/" 2>/dev/null || true
        fi
    done
    
    debug "Backup creado: $backup_dir"
}

# =====================================================
# 🔧 UTILIDADES Y COMANDOS
# =====================================================

# Mostrar resumen de instalación
show_installation_summary() {
    local installed="$1"
    local failed="$2"
    local skipped="$3"
    local total=$((installed + failed + skipped))
    
    echo
    echo -e "${BOLD}${BLUE}📊 RESUMEN DE INSTALACIÓN${COLOR_RESET}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Total: $total | Instalados: ${GREEN}$installed${COLOR_RESET} | Fallidos: ${RED}$failed${COLOR_RESET} | Omitidos: ${YELLOW}$skipped${COLOR_RESET}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────┘${COLOR_RESET}"
}

# Mostrar estadísticas del sistema
show_module_stats() {
    local total_modules
    total_modules=$(discover_modules | wc -l)
    local installed_count
    installed_count=$(list_modules_by_status "installed" | wc -l)
    local failed_count
    failed_count=$(list_modules_by_status "failed" | wc -l)
    
    echo -e "${BOLD}${BLUE}📊 ESTADÍSTICAS DE MÓDULOS${COLOR_RESET}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Módulos disponibles: $total_modules"
    echo -e "${CYAN}│${COLOR_RESET} Módulos instalados: ${GREEN}$installed_count${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Módulos fallidos: ${RED}$failed_count${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Estado: $(jq -r '.last_update' "$MODULES_STATE")"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${COLOR_RESET}"
}

# Limpiar estado y cache
clean_module_data() {
    local clean_type="${1:-cache}"
    
    case "$clean_type" in
        cache)
            rm -rf "$CACHE_ROOT"
            success "✅ Cache de módulos limpiado"
            ;;
        state)
            rm -rf "$STATE_ROOT"
            success "✅ Estado de módulos reseteado"
            init_module_manager
            ;;
        all)
            rm -rf "$CACHE_ROOT" "$STATE_ROOT"
            success "✅ Todos los datos de módulos limpiados"
            init_module_manager
            ;;
    esac
}

# =====================================================
# 🏁 INTERFAZ PRINCIPAL
# =====================================================

# Función principal del gestor de módulos
module_manager_main() {
    local action="${1:-help}"
    shift || true
    
    # Inicializar si es necesario
    [[ -d "$STATE_ROOT" ]] || init_module_manager
    
    case "$action" in
        init)
            init_module_manager
            ;;
        discover|list)
            discover_modules
            ;;
        info)
            get_module_info "$1"
            ;;
        install)
            if [[ $# -eq 0 ]]; then
                error "❌ Especifica módulos a instalar"
                return 1
            fi
            install_modules "$@"
            ;;
        status)
            [[ $# -gt 0 ]] && get_module_status "$1" || show_module_stats
            ;;
        stats)
            show_module_stats
            ;;
        clean)
            clean_module_data "${1:-cache}"
            ;;
        help|*)
            cat << 'EOF'
🧩 Gestor Unificado de Módulos - Arch Dream

Uso: module_manager_main <acción> [argumentos]

Acciones:
  init                     Inicializar gestor de módulos
  discover, list           Listar módulos disponibles
  info <module>           Mostrar información de módulo
  install <modules...>     Instalar módulos con dependencias
  status [module]         Mostrar estado (específico o general)
  stats                   Mostrar estadísticas del sistema
  clean [cache|state|all] Limpiar datos del gestor
  help                    Mostrar esta ayuda

Variables de entorno:
  PARALLEL_INSTALL=true   Instalación paralela (experimental)
  FORCE_INSTALL=true      Forzar reinstalación
  DRY_RUN=true           Simular instalación
  BACKUP_BEFORE_INSTALL=false  Deshabilitar backups

Ejemplos:
  module_manager_main install core:zsh development:nvim
  module_manager_main status core:bash
  module_manager_main clean cache
EOF
            ;;
    esac
}

# Exportar funciones principales
export -f init_module_manager discover_modules get_module_info
export -f resolve_dependencies install_module install_modules
export -f update_module_status get_module_status list_modules_by_status
export -f show_installation_summary show_module_stats clean_module_data
export -f module_manager_main

# Variables exportadas
export PROJECT_ROOT MODULES_ROOT CONFIG_ROOT CACHE_ROOT STATE_ROOT
export MODULES_STATE INSTALL_LOG DEPENDENCIES_GRAPH