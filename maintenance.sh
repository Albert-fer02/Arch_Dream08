#!/bin/bash
# My Powerlevel10k Configuration
# ---------------------------------------------------------------------
# ╔═════════════════════════════════════════════════════════════
# ║                     𓂀 DreamCoder 08 𓂀                     ║
# ║                ⚡ Digital Dream Architect ⚡                 ║
# ║                                                            ║
# ║        Author: https://github.com/Albert-fer02             ║
# ╚══════════════════════════════════════════════════════════════╝
# ---------------------------------------------------------------------    
# =====================================================
# 🔧 ARCH DREAM MAINTENANCE TOOL v1.0
# =====================================================
# Script de mantenimiento para el sistema Arch Dream
# Incluye limpieza, actualización y optimización
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común mejorada
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# =====================================================
# 🔧 CONFIGURACIÓN Y VARIABLES
# =====================================================

SCRIPT_NAME="Arch Dream Maintenance Tool"
SCRIPT_VERSION="1.0"

# Variables de control
FORCE_UPDATE=${FORCE_UPDATE:-false}
SKIP_BACKUP=${SKIP_BACKUP:-false}
DRY_RUN=${DRY_RUN:-false}
VERBOSE=${VERBOSE:-false}
CLEAN_ONLY=${CLEAN_ONLY:-false}
UPDATE_ONLY=${UPDATE_ONLY:-false}

# Configurar nivel de logging
if [[ "$VERBOSE" == "true" ]]; then
    LOG_LEVEL="DEBUG"
fi

# =====================================================
# 🔧 FUNCIONES DE MANTENIMIENTO
# =====================================================

# Función para mostrar ayuda
show_help() {
    cat << EOF
${BOLD}${CYAN}$SCRIPT_NAME v$SCRIPT_VERSION${COLOR_RESET}

${PURPLE}Uso:${COLOR_RESET} $0 [OPCIONES]

${PURPLE}Opciones:${COLOR_RESET}
  -h, --help          Mostrar esta ayuda
  -f, --force         Forzar actualizaciones sin confirmación
  -v, --verbose       Modo verbose con más información
  -d, --dry-run       Simular mantenimiento sin hacer cambios
  -s, --skip-backup   Saltar creación de backups
  -c, --clean-only    Solo limpieza del sistema
  -u, --update-only   Solo actualización del sistema

${PURPLE}Variables de entorno:${COLOR_RESET}
  FORCE_UPDATE=true   Forzar actualizaciones
  SKIP_BACKUP=true    Saltar backups
  DRY_RUN=true        Modo simulación
  VERBOSE=true        Modo verbose
  CLEAN_ONLY=true     Solo limpieza
  UPDATE_ONLY=true    Solo actualización

${PURPLE}Ejemplos:${COLOR_RESET}
  $0                    # Mantenimiento completo
  $0 --clean-only      # Solo limpieza
  $0 --update-only     # Solo actualización
  $0 --dry-run         # Simular mantenimiento

EOF
}

# Función para parsear argumentos
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--force)
                FORCE_UPDATE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -s|--skip-backup)
                SKIP_BACKUP=true
                shift
                ;;
            -c|--clean-only)
                CLEAN_ONLY=true
                shift
                ;;
            -u|--update-only)
                UPDATE_ONLY=true
                shift
                ;;
            *)
                error "Opción desconocida: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Función para crear backup de mantenimiento
create_maintenance_backup() {
    if [[ "$SKIP_BACKUP" == "true" ]]; then
        warn "Saltando creación de backups"
        return 0
    fi
    
    log "Creando backup de mantenimiento..."
    
    local backup_dir="$HOME/.maintenance_backup_$(date +%Y%m%d_%H%M%S)"
    local backup_items=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.p10k.zsh"
        "$HOME/.config/kitty"
        "$HOME/.config/fastfetch"
        "$HOME/.config/nvim"
        "$HOME/.gitconfig"
        "$HOME/.nanorc"
    )
    
    local backup_count=0
    for item in "${backup_items[@]}"; do
        if [[ -e "$item" ]]; then
            if create_backup "$item" "$backup_dir"; then
                ((backup_count++))
            fi
        fi
    done
    
    if [[ $backup_count -gt 0 ]]; then
        success "Backup de mantenimiento creado en: $backup_dir ($backup_count elementos)"
    else
        warn "No se encontraron archivos para hacer backup"
    fi
}

# Función para limpiar caché de paquetes
clean_package_cache() {
    log "Limpiando caché de paquetes..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY-RUN] Limpiando caché de paquetes"
        return 0
    fi
    
    # Obtener tamaño del caché antes de limpiar
    local cache_size_before=$(du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1)
    debug "Tamaño del caché antes: $cache_size_before"
    
    # Limpiar caché
    if sudo pacman -Sc --noconfirm; then
        local cache_size_after=$(du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1)
        success "Caché de paquetes limpiado (antes: $cache_size_before, después: $cache_size_after)"
    else
        warn "No se pudo limpiar completamente el caché"
        return 1
    fi
}

# Función para limpiar paquetes huérfanos
clean_orphan_packages() {
    log "Limpiando paquetes huérfanos..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY-RUN] Limpiando paquetes huérfanos"
        return 0
    fi
    
    # Encontrar paquetes huérfanos
    local orphan_packages=$(pacman -Qtdq 2>/dev/null || true)
    
    if [[ -n "$orphan_packages" ]]; then
        local orphan_count=$(echo "$orphan_packages" | wc -l)
        log "Encontrados $orphan_count paquetes huérfanos"
        
        if [[ "$FORCE_UPDATE" == "true" ]] || confirm "¿Eliminar $orphan_count paquetes huérfanos?"; then
            if sudo pacman -Rns $orphan_packages; then
                success "Paquetes huérfanos eliminados"
            else
                warn "No se pudieron eliminar todos los paquetes huérfanos"
            fi
        else
            log "Eliminación de paquetes huérfanos cancelada"
        fi
    else
        success "No se encontraron paquetes huérfanos"
    fi
}

# Función para limpiar logs del sistema
clean_system_logs() {
    log "Limpiando logs del sistema..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY-RUN] Limpiando logs del sistema"
        return 0
    fi
    
    # Limpiar logs de journalctl
    if command -v journalctl &>/dev/null; then
        local journal_size_before=$(journalctl --disk-usage | awk '{print $1}')
        debug "Tamaño de logs antes: $journal_size_before"
        
        if sudo journalctl --vacuum-time=7d; then
            local journal_size_after=$(journalctl --disk-usage | awk '{print $1}')
            success "Logs del sistema limpiados (antes: $journal_size_before, después: $journal_size_after)"
        else
            warn "No se pudieron limpiar completamente los logs"
        fi
    fi
}

# Función para limpiar caché de usuario
clean_user_cache() {
    log "Limpiando caché de usuario..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY-RUN] Limpiando caché de usuario"
        return 0
    fi
    
    local cache_dirs=(
        "$HOME/.cache"
        "$HOME/.local/share/Trash"
        "$HOME/.thumbnails"
        "$HOME/.mozilla/firefox/*/Cache"
        "$HOME/.config/Code/Cache"
        "$HOME/.config/Code/CachedData"
    )
    
    local cleaned_size=0
    for cache_dir in "${cache_dirs[@]}"; do
        if [[ -d "$cache_dir" ]]; then
            local dir_size=$(du -sb "$cache_dir" 2>/dev/null | cut -f1 || echo "0")
            if rm -rf "$cache_dir"/* 2>/dev/null; then
                cleaned_size=$((cleaned_size + dir_size))
                debug "Caché limpiado: $cache_dir"
            fi
        fi
    done
    
    if [[ $cleaned_size -gt 0 ]]; then
        local cleaned_mb=$((cleaned_size / 1024 / 1024))
        success "Caché de usuario limpiado: ${cleaned_mb}MB liberados"
    else
        success "Caché de usuario ya está limpio"
    fi
}

# Función para actualizar sistema
update_system() {
    log "Actualizando sistema..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY-RUN] Actualizando sistema"
        return 0
    fi
    
    # Verificar espacio antes de actualizar
    check_disk_space 2097152  # 2GB mínimo para actualizaciones
    
    # Actualizar base de datos de paquetes
    log "Actualizando base de datos de paquetes..."
    if sudo pacman -Sy; then
        success "Base de datos de paquetes actualizada"
    else
        error "Fallo al actualizar base de datos de paquetes"
        return 1
    fi
    
    # Verificar actualizaciones disponibles
    local updates_available=$(pacman -Qu 2>/dev/null | wc -l)
    
    if [[ $updates_available -gt 0 ]]; then
        log "Encontradas $updates_available actualizaciones disponibles"
        
        if [[ "$FORCE_UPDATE" == "true" ]] || confirm "¿Instalar $updates_available actualizaciones?"; then
            if sudo pacman -Syu --noconfirm; then
                success "Sistema actualizado correctamente"
            else
                error "Fallo al actualizar sistema"
                return 1
            fi
        else
            log "Actualización del sistema cancelada"
        fi
    else
        success "Sistema ya está actualizado"
    fi
}

# Función para actualizar AUR helpers
update_aur_helpers() {
    log "Actualizando AUR helpers..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY-RUN] Actualizando AUR helpers"
        return 0
    fi
    
    # Actualizar yay si está instalado
    if command -v yay &>/dev/null; then
        log "Actualizando yay..."
        if yay -Syu --noconfirm; then
            success "yay actualizado"
        else
            warn "Fallo al actualizar yay"
        fi
    fi
    
    # Actualizar paru si está instalado
    if command -v paru &>/dev/null; then
        log "Actualizando paru..."
        if paru -Syu --noconfirm; then
            success "paru actualizado"
        else
            warn "Fallo al actualizar paru"
        fi
    fi
}

# Función para optimizar base de datos de paquetes
optimize_package_database() {
    log "Optimizando base de datos de paquetes..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY-RUN] Optimizando base de datos de paquetes"
        return 0
    fi
    
    # Optimizar base de datos
    if sudo pacman-optimize; then
        success "Base de datos de paquetes optimizada"
    else
        warn "No se pudo optimizar la base de datos de paquetes"
    fi
}

# Función para verificar integridad del sistema
verify_system_integrity() {
    log "Verificando integridad del sistema..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY-RUN] Verificando integridad del sistema"
        return 0
    fi
    
    # Verificar paquetes rotos
    local broken_packages=$(pacman -Qk 2>&1 | grep -E "(missing|corrupted)" || true)
    
    if [[ -n "$broken_packages" ]]; then
        warn "Se encontraron paquetes con problemas:"
        echo "$broken_packages"
        
        if confirm "¿Intentar reparar paquetes rotos?"; then
            if sudo pacman -S --noconfirm $(echo "$broken_packages" | awk '{print $2}'); then
                success "Paquetes reparados"
            else
                warn "No se pudieron reparar todos los paquetes"
            fi
        fi
    else
        success "Integridad del sistema verificada"
    fi
}

# Función para limpiar configuraciones obsoletas
clean_obsolete_configs() {
    log "Limpiando configuraciones obsoletas..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY-RUN] Limpiando configuraciones obsoletas"
        return 0
    fi
    
    local obsolete_configs=(
        "$HOME/.config/obsolete_config"
        "$HOME/.local/share/obsolete_data"
    )
    
    local cleaned_count=0
    for config in "${obsolete_configs[@]}"; do
        if [[ -e "$config" ]]; then
            if rm -rf "$config"; then
                ((cleaned_count++))
                debug "Configuración obsoleta eliminada: $config"
            fi
        fi
    done
    
    if [[ $cleaned_count -gt 0 ]]; then
        success "$cleaned_count configuraciones obsoletas eliminadas"
    else
        success "No se encontraron configuraciones obsoletas"
    fi
}

# Función para mostrar estadísticas del sistema
show_system_stats() {
    log "Mostrando estadísticas del sistema..."
    
    echo -e "${BOLD}${BLUE}📊 ESTADÍSTICAS DEL SISTEMA${COLOR_RESET}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    
    # Información del sistema
    echo -e "${CYAN}│${COLOR_RESET} Sistema: $(get_arch_version)"
    echo -e "${CYAN}│${COLOR_RESET} Usuario: $USER"
    echo -e "${CYAN}│${COLOR_RESET} Fecha: $(date)"
    
    # Espacio en disco
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}')
    local disk_available=$(df -h / | awk 'NR==2 {print $4}')
    echo -e "${CYAN}│${COLOR_RESET} Uso de disco: $disk_usage (disponible: $disk_available)"
    
    # Memoria
    local mem_total=$(free -h | awk 'NR==2{print $2}')
    local mem_used=$(free -h | awk 'NR==2{print $3}')
    local mem_available=$(free -h | awk 'NR==2{print $7}')
    echo -e "${CYAN}│${COLOR_RESET} Memoria: $mem_used/$mem_total (disponible: $mem_available)"
    
    # Paquetes instalados
    local package_count=$(pacman -Qq | wc -l)
    echo -e "${CYAN}│${COLOR_RESET} Paquetes instalados: $package_count"
    
    # Tamaño del caché
    local cache_size=$(du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1 || echo "0B")
    echo -e "${CYAN}│${COLOR_RESET} Tamaño del caché: $cache_size"
    
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${COLOR_RESET}"
    echo
}

# Función para mostrar resumen de mantenimiento
show_maintenance_summary() {
    local summary_items=(
        "✅ Mantenimiento completado exitosamente"
        "🧹 Sistema limpiado y optimizado"
        "📦 Paquetes actualizados"
        "🔧 Configuraciones verificadas"
        "💾 Espacio liberado"
    )
    
    if [[ "$DRY_RUN" == "true" ]]; then
        summary_items=(
            "🔍 Simulación de mantenimiento completada"
            "📋 Operaciones que se realizarían:"
            "   • Limpieza de caché de paquetes"
            "   • Eliminación de paquetes huérfanos"
            "   • Actualización del sistema"
            "   • Optimización de base de datos"
        )
    fi
    
    show_summary "🎉 Resumen del mantenimiento" "${summary_items[@]}"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        echo -e "${GREEN}🚀 Tu sistema Arch Dream está optimizado y actualizado!${COLOR_RESET}"
        echo -e "${CYAN}💡 Tip: Ejecuta este script regularmente para mantener tu sistema${COLOR_RESET}"
    fi
}

# =====================================================
# 🏁 FUNCIÓN PRINCIPAL
# =====================================================

main() {
    # Inicializar biblioteca
    init_library
    
    # Parsear argumentos
    parse_arguments "$@"
    
    # Mostrar banner
    show_banner "$SCRIPT_NAME v$SCRIPT_VERSION" "Mantenimiento completo del sistema Arch Dream"
    
    # Mostrar información del sistema
    debug "Sistema: $(get_arch_version)"
    debug "Usuario: $USER"
    debug "Directorio: $SCRIPT_DIR"
    debug "Modo DRY-RUN: $DRY_RUN"
    debug "Modo FORCE: $FORCE_UPDATE"
    debug "Modo VERBOSE: $VERBOSE"
    
    # Mostrar estadísticas iniciales
    show_system_stats
    
    # Crear backup de mantenimiento
    create_maintenance_backup
    
    # Ejecutar mantenimiento según opciones
    if [[ "$CLEAN_ONLY" == "true" ]]; then
        # Solo limpieza
        clean_package_cache
        clean_orphan_packages
        clean_system_logs
        clean_user_cache
        clean_obsolete_configs
    elif [[ "$UPDATE_ONLY" == "true" ]]; then
        # Solo actualización
        update_system
        update_aur_helpers
        optimize_package_database
    else
        # Mantenimiento completo
        clean_package_cache
        clean_orphan_packages
        clean_system_logs
        clean_user_cache
        clean_obsolete_configs
        update_system
        update_aur_helpers
        optimize_package_database
        verify_system_integrity
    fi
    
    # Mostrar estadísticas finales
    show_system_stats
    
    # Mostrar resumen final
    show_maintenance_summary
}

# =====================================================
# 🚀 EJECUCIÓN
# =====================================================

# Ejecutar función principal
main "$@" 