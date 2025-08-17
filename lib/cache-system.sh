#!/bin/bash
# =====================================================
# 💾 ARCH DREAM MACHINE - SISTEMA DE CACHE UNIFICADO
# =====================================================
# Sistema centralizado de cache para optimizar instalaciones
# Version 1.0 - Ultra Performance Cache System
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# =====================================================
# 🔧 CONFIGURACIÓN DEL SISTEMA DE CACHE
# =====================================================

# Directorios de cache
CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/arch-dream"
PACKAGES_CACHE="$CACHE_ROOT/packages"
COMMANDS_CACHE="$CACHE_ROOT/commands"
DEPENDENCIES_CACHE="$CACHE_ROOT/dependencies"
SYSTEM_CACHE="$CACHE_ROOT/system"
MODULES_CACHE="$CACHE_ROOT/modules"

# Tiempos de expiración (en segundos)
PACKAGES_TTL=3600      # 1 hora
COMMANDS_TTL=21600     # 6 horas
DEPENDENCIES_TTL=7200  # 2 horas
SYSTEM_TTL=1800        # 30 minutos
MODULES_TTL=43200      # 12 horas

# Archivos de cache
PACKAGES_FILE="$PACKAGES_CACHE/installed.cache"
COMMANDS_FILE="$COMMANDS_CACHE/available.cache"
DEPENDENCIES_FILE="$DEPENDENCIES_CACHE/resolved.cache"
SYSTEM_FILE="$SYSTEM_CACHE/info.cache"
MODULES_FILE="$MODULES_CACHE/status.cache"

# =====================================================
# 🔧 FUNCIONES DE INICIALIZACIÓN
# =====================================================

# Inicializar sistema de cache
init_cache_system() {
    debug "Inicializando sistema de cache..."
    
    # Crear directorios de cache
    mkdir -p "$PACKAGES_CACHE" "$COMMANDS_CACHE" "$DEPENDENCIES_CACHE" "$SYSTEM_CACHE" "$MODULES_CACHE"
    
    # Establecer permisos
    chmod 755 "$CACHE_ROOT" "$PACKAGES_CACHE" "$COMMANDS_CACHE" "$DEPENDENCIES_CACHE" "$SYSTEM_CACHE" "$MODULES_CACHE"
    
    success "✅ Sistema de cache inicializado"
}

# Verificar si un cache ha expirado
is_cache_expired() {
    local cache_file="$1"
    local ttl="$2"
    
    if [[ ! -f "$cache_file" ]]; then
        return 0  # No existe, considerado expirado
    fi
    
    local file_time=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
    local current_time=$(date +%s)
    local age=$((current_time - file_time))
    
    if [[ $age -gt $ttl ]]; then
        debug "Cache expirado: $cache_file (edad: ${age}s, TTL: ${ttl}s)"
        return 0  # Expirado
    else
        debug "Cache válido: $cache_file (edad: ${age}s, TTL: ${ttl}s)"
        return 1  # Válido
    fi
}

# =====================================================
# 📦 CACHE DE PAQUETES
# =====================================================

# Actualizar cache de paquetes instalados
update_packages_cache() {
    debug "Actualizando cache de paquetes..."
    
    local temp_file="$PACKAGES_FILE.tmp"
    
    # Obtener lista de paquetes instalados
    pacman -Qq > "$temp_file" 2>/dev/null || {
        warn "No se pudo obtener lista de paquetes"
        return 1
    }
    
    # Mover archivo temporal al definitivo
    mv "$temp_file" "$PACKAGES_FILE"
    
    # Crear índice hash para búsquedas rápidas
    sort "$PACKAGES_FILE" > "$PACKAGES_FILE.sorted"
    
    debug "Cache de paquetes actualizado ($(wc -l < "$PACKAGES_FILE") paquetes)"
}

# Verificar si un paquete está instalado (con cache)
is_package_installed() {
    local package="$1"
    
    # Verificar si el cache es válido
    if is_cache_expired "$PACKAGES_FILE" "$PACKAGES_TTL"; then
        update_packages_cache
    fi
    
    # Búsqueda rápida en el archivo ordenado
    if [[ -f "$PACKAGES_FILE.sorted" ]]; then
        if grep -q "^${package}$" "$PACKAGES_FILE.sorted"; then
            debug "Paquete $package encontrado en cache"
            return 0
        else
            debug "Paquete $package NO encontrado en cache"
            return 1
        fi
    else
        # Fallback a verificación directa
        pacman -Q "$package" &>/dev/null
    fi
}

# Obtener información de paquete (con cache)
get_package_info() {
    local package="$1"
    local info_file="$PACKAGES_CACHE/${package}.info"
    
    # Verificar si el cache de información es válido
    if is_cache_expired "$info_file" "$PACKAGES_TTL"; then
        # Actualizar información del paquete
        pacman -Qi "$package" > "$info_file" 2>/dev/null || {
            rm -f "$info_file"
            return 1
        }
    fi
    
    cat "$info_file"
}

# =====================================================
# 🔧 CACHE DE COMANDOS
# =====================================================

# Actualizar cache de comandos disponibles
update_commands_cache() {
    debug "Actualizando cache de comandos..."
    
    local temp_file="$COMMANDS_FILE.tmp"
    
    # Obtener comandos del PATH
    {
        echo "# Cache de comandos - $(date)"
        # Buscar en todos los directorios del PATH
        echo "$PATH" | tr ':' '\n' | while read -r dir; do
            [[ -d "$dir" ]] && find "$dir" -maxdepth 1 -executable -type f -printf '%f\n' 2>/dev/null
        done | sort -u
    } > "$temp_file"
    
    mv "$temp_file" "$COMMANDS_FILE"
    
    debug "Cache de comandos actualizado ($(tail -n +2 "$COMMANDS_FILE" | wc -l) comandos)"
}

# Verificar si un comando está disponible (con cache)
is_command_available() {
    local command="$1"
    
    # Verificar si el cache es válido
    if is_cache_expired "$COMMANDS_FILE" "$COMMANDS_TTL"; then
        update_commands_cache
    fi
    
    # Búsqueda rápida en cache
    if [[ -f "$COMMANDS_FILE" ]]; then
        if tail -n +2 "$COMMANDS_FILE" | grep -q "^${command}$"; then
            debug "Comando $command encontrado en cache"
            return 0
        else
            debug "Comando $command NO encontrado en cache"
            return 1
        fi
    else
        # Fallback a verificación directa
        command -v "$command" &>/dev/null
    fi
}

# =====================================================
# 🔗 CACHE DE DEPENDENCIAS
# =====================================================

# Actualizar cache de dependencias de módulo
update_module_dependencies_cache() {
    local module="$1"
    shift
    local dependencies=("$@")
    
    local deps_file="$DEPENDENCIES_CACHE/${module}.deps"
    
    # Guardar dependencias en archivo
    printf '%s\n' "${dependencies[@]}" > "$deps_file"
    
    debug "Dependencias de $module guardadas en cache"
}

# Obtener dependencias de módulo (con cache)
get_module_dependencies() {
    local module="$1"
    local deps_file="$DEPENDENCIES_CACHE/${module}.deps"
    
    if [[ -f "$deps_file" ]]; then
        cat "$deps_file"
    fi
}

# Resolver todas las dependencias de una lista de módulos
resolve_all_dependencies() {
    local modules=("$@")
    local resolved=()
    local seen=()
    
    debug "Resolviendo dependencias para: ${modules[*]}"
    
    # Función recursiva para resolver dependencias
    resolve_deps_recursive() {
        local module="$1"
        
        # Evitar ciclos
        if [[ " ${seen[*]} " =~ " ${module} " ]]; then
            return
        fi
        seen+=("$module")
        
        # Obtener dependencias del módulo
        local deps
        mapfile -t deps < <(get_module_dependencies "$module")
        
        # Resolver dependencias recursivamente
        for dep in "${deps[@]}"; do
            [[ -n "$dep" ]] && resolve_deps_recursive "$dep"
        done
        
        # Agregar el módulo actual si no está ya en la lista
        if [[ ! " ${resolved[*]} " =~ " ${module} " ]]; then
            resolved+=("$module")
        fi
    }
    
    # Resolver cada módulo
    for module in "${modules[@]}"; do
        resolve_deps_recursive "$module"
    done
    
    # Devolver lista ordenada
    printf '%s\n' "${resolved[@]}"
}

# =====================================================
# 🖥️ CACHE DE INFORMACIÓN DEL SISTEMA
# =====================================================

# Actualizar cache de información del sistema
update_system_cache() {
    debug "Actualizando cache del sistema..."
    
    {
        echo "# Cache del sistema - $(date)"
        echo "ARCH_VERSION=$(cat /etc/arch-release 2>/dev/null || echo 'unknown')"
        echo "KERNEL_VERSION=$(uname -r)"
        echo "ARCH=$(uname -m)"
        echo "HOSTNAME=$(hostname)"
        echo "USER=$(whoami)"
        echo "SHELL=$(basename -- "$SHELL")"
        echo "TOTAL_MEMORY=$(free -b | awk 'NR==2{print $2}')"
        echo "AVAILABLE_MEMORY=$(free -b | awk 'NR==2{print $7}')"
        echo "CPU_CORES=$(nproc)"
        echo "DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')"
        echo "PACMAN_VERSION=$(pacman --version | head -1 | awk '{print $3}')"
        
        # Detectar AUR helpers
        echo "HAS_YAY=$(command -v yay &>/dev/null && echo 1 || echo 0)"
        echo "HAS_PARU=$(command -v paru &>/dev/null && echo 1 || echo 0)"
        
        # Estado de red
        echo "HAS_INTERNET=$(ping -c 1 -W 2 archlinux.org &>/dev/null && echo 1 || echo 0)"
    } > "$SYSTEM_FILE"
    
    debug "Cache del sistema actualizado"
}

# Obtener información del sistema (con cache)
get_system_info() {
    local key="$1"
    
    # Verificar si el cache es válido
    if is_cache_expired "$SYSTEM_FILE" "$SYSTEM_TTL"; then
        update_system_cache
    fi
    
    # Obtener valor específico
    if [[ -f "$SYSTEM_FILE" ]]; then
        grep "^${key}=" "$SYSTEM_FILE" | cut -d'=' -f2-
    fi
}

# =====================================================
# 🧩 CACHE DE ESTADO DE MÓDULOS
# =====================================================

# Actualizar estado de módulo
update_module_status() {
    local module="$1"
    local status="$2"  # installed, failed, pending
    local timestamp=$(date +%s)
    
    # Crear entrada en cache
    echo "${module}|${status}|${timestamp}" >> "$MODULES_FILE.tmp"
    
    # Limpiar entradas duplicadas y mantener la más reciente
    if [[ -f "$MODULES_FILE" ]]; then
        grep -v "^${module}|" "$MODULES_FILE" >> "$MODULES_FILE.tmp" || true
    fi
    
    # Ordenar por timestamp y eliminar duplicados
    sort -t'|' -k3 -n "$MODULES_FILE.tmp" | \
    awk -F'|' '!seen[$1]++' > "$MODULES_FILE"
    
    rm -f "$MODULES_FILE.tmp"
    
    debug "Estado de módulo $module actualizado: $status"
}

# Obtener estado de módulo
get_module_status() {
    local module="$1"
    
    if [[ -f "$MODULES_FILE" ]]; then
        grep "^${module}|" "$MODULES_FILE" | tail -1 | cut -d'|' -f2
    fi
}

# Listar módulos instalados
list_installed_modules() {
    if [[ -f "$MODULES_FILE" ]]; then
        grep "|installed|" "$MODULES_FILE" | cut -d'|' -f1
    fi
}

# =====================================================
# 🧹 GESTIÓN DE CACHE
# =====================================================

# Limpiar cache expirado
clean_expired_cache() {
    debug "Limpiando cache expirado..."
    
    local cleaned=0
    
    # Limpiar archivos expirados
    local cache_configs=(
        "$PACKAGES_FILE:$PACKAGES_TTL"
        "$COMMANDS_FILE:$COMMANDS_TTL"
        "$SYSTEM_FILE:$SYSTEM_TTL"
    )
    
    for config in "${cache_configs[@]}"; do
        local file="${config%:*}"
        local ttl="${config#*:}"
        
        if [[ -f "$file" ]] && is_cache_expired "$file" "$ttl"; then
            rm -f "$file" "$file.sorted" "$file.tmp"
            ((cleaned++))
            debug "Cache expirado eliminado: $file"
        fi
    done
    
    # Limpiar archivos de dependencias antiguos
    find "$DEPENDENCIES_CACHE" -name "*.deps" -mtime +1 -delete 2>/dev/null || true
    
    # Limpiar información de paquetes antigua
    find "$PACKAGES_CACHE" -name "*.info" -mtime +1 -delete 2>/dev/null || true
    
    if [[ $cleaned -gt 0 ]]; then
        success "✅ Cache limpiado ($cleaned archivos eliminados)"
    else
        debug "No hay cache expirado para limpiar"
    fi
}

# Limpiar todo el cache
clean_all_cache() {
    debug "Limpiando todo el cache..."
    
    if [[ -d "$CACHE_ROOT" ]]; then
        rm -rf "$CACHE_ROOT"
        success "✅ Todo el cache eliminado"
    fi
    
    # Reinicializar
    init_cache_system
}

# Mostrar estadísticas del cache
show_cache_stats() {
    echo -e "${BOLD}${BLUE}📊 ESTADÍSTICAS DEL CACHE${COLOR_RESET}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    
    if [[ -d "$CACHE_ROOT" ]]; then
        local cache_size=$(du -sh "$CACHE_ROOT" 2>/dev/null | cut -f1)
        echo -e "${CYAN}│${COLOR_RESET} Tamaño total: $cache_size"
        
        # Estadísticas por tipo
        if [[ -f "$PACKAGES_FILE" ]]; then
            local packages_count=$(wc -l < "$PACKAGES_FILE" 2>/dev/null || echo 0)
            echo -e "${CYAN}│${COLOR_RESET} Paquetes en cache: $packages_count"
        fi
        
        if [[ -f "$COMMANDS_FILE" ]]; then
            local commands_count=$(tail -n +2 "$COMMANDS_FILE" 2>/dev/null | wc -l || echo 0)
            echo -e "${CYAN}│${COLOR_RESET} Comandos en cache: $commands_count"
        fi
        
        if [[ -f "$MODULES_FILE" ]]; then
            local modules_count=$(wc -l < "$MODULES_FILE" 2>/dev/null || echo 0)
            echo -e "${CYAN}│${COLOR_RESET} Módulos rastreados: $modules_count"
        fi
        
        # Estado de los archivos de cache
        echo -e "${CYAN}│${COLOR_RESET}"
        echo -e "${CYAN}│${COLOR_RESET} Estado de cache:"
        
        local cache_files=(
            "$PACKAGES_FILE:Paquetes:$PACKAGES_TTL"
            "$COMMANDS_FILE:Comandos:$COMMANDS_TTL"
            "$SYSTEM_FILE:Sistema:$SYSTEM_TTL"
        )
        
        for config in "${cache_files[@]}"; do
            local file="${config%%:*}"
            local name="${config#*:}"
            name="${name%:*}"
            local ttl="${config##*:}"
            
            if [[ -f "$file" ]]; then
                if is_cache_expired "$file" "$ttl"; then
                    echo -e "${CYAN}│${COLOR_RESET}   - $name: ${RED}Expirado${COLOR_RESET}"
                else
                    local age=$(( $(date +%s) - $(stat -c %Y "$file" 2>/dev/null || echo 0) ))
                    echo -e "${CYAN}│${COLOR_RESET}   - $name: ${GREEN}Válido${COLOR_RESET} (${age}s)"
                fi
            else
                echo -e "${CYAN}│${COLOR_RESET}   - $name: ${YELLOW}No existe${COLOR_RESET}"
            fi
        done
    else
        echo -e "${CYAN}│${COLOR_RESET} Cache no inicializado"
    fi
    
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${COLOR_RESET}"
}

# =====================================================
# 🔧 FUNCIONES DE UTILIDAD
# =====================================================

# Precargar cache común
preload_cache() {
    debug "Precargando cache común..."
    
    # Precargar en paralelo
    {
        update_packages_cache &
        update_commands_cache &
        update_system_cache &
        wait
    } 2>/dev/null
    
    success "✅ Cache precargado"
}

# Verificar integridad del cache
verify_cache_integrity() {
    debug "Verificando integridad del cache..."
    
    local errors=0
    
    # Verificar permisos de directorios
    local dirs=("$CACHE_ROOT" "$PACKAGES_CACHE" "$COMMANDS_CACHE" "$DEPENDENCIES_CACHE" "$SYSTEM_CACHE" "$MODULES_CACHE")
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            warn "Directorio de cache faltante: $dir"
            mkdir -p "$dir"
            ((errors++))
        fi
    done
    
    # Verificar archivos corruptos
    if [[ -f "$PACKAGES_FILE" ]] && ! head -1 "$PACKAGES_FILE" &>/dev/null; then
        warn "Archivo de cache corrupto: $PACKAGES_FILE"
        rm -f "$PACKAGES_FILE" "$PACKAGES_FILE.sorted"
        ((errors++))
    fi
    
    if [[ $errors -eq 0 ]]; then
        success "✅ Integridad del cache verificada"
    else
        warn "⚠️ Se encontraron $errors problemas en el cache (corregidos)"
    fi
    
    return $errors
}

# =====================================================
# 🏁 FUNCIONES DE INTERFAZ
# =====================================================

# Inicializar cache si es necesario
ensure_cache_initialized() {
    if [[ ! -d "$CACHE_ROOT" ]]; then
        init_cache_system
    fi
}

# Función principal para uso en scripts
cache_main() {
    local action="${1:-help}"
    shift || true
    
    case "$action" in
        init)
            init_cache_system
            ;;
        preload)
            ensure_cache_initialized
            preload_cache
            ;;
        clean)
            clean_expired_cache
            ;;
        clean-all)
            clean_all_cache
            ;;
        stats)
            show_cache_stats
            ;;
        verify)
            verify_cache_integrity
            ;;
        package-installed)
            ensure_cache_initialized
            is_package_installed "$1" && echo "yes" || echo "no"
            ;;
        command-available)
            ensure_cache_initialized
            is_command_available "$1" && echo "yes" || echo "no"
            ;;
        system-info)
            ensure_cache_initialized
            get_system_info "$1"
            ;;
        help|*)
            cat << 'EOF'
Sistema de Cache Unificado - Arch Dream Machine

Uso: cache_main <acción> [argumentos]

Acciones:
  init              Inicializar sistema de cache
  preload           Precargar cache común
  clean             Limpiar cache expirado
  clean-all         Limpiar todo el cache
  stats             Mostrar estadísticas del cache
  verify            Verificar integridad del cache
  package-installed <pkg>   Verificar si paquete está instalado
  command-available <cmd>   Verificar si comando está disponible
  system-info <key>         Obtener información del sistema
  help              Mostrar esta ayuda

Ejemplos:
  cache_main package-installed firefox
  cache_main command-available git
  cache_main system-info ARCH_VERSION
EOF
            ;;
    esac
}

# Exportar funciones principales
export -f init_cache_system is_cache_expired
export -f is_package_installed get_package_info
export -f is_command_available update_commands_cache
export -f get_system_info update_system_cache
export -f update_module_status get_module_status list_installed_modules
export -f clean_expired_cache clean_all_cache show_cache_stats
export -f preload_cache verify_cache_integrity ensure_cache_initialized
export -f cache_main

# Variables de configuración exportadas
export CACHE_ROOT PACKAGES_CACHE COMMANDS_CACHE DEPENDENCIES_CACHE SYSTEM_CACHE MODULES_CACHE
export PACKAGES_TTL COMMANDS_TTL DEPENDENCIES_TTL SYSTEM_TTL MODULES_TTL