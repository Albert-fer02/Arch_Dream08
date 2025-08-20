#!/bin/bash
# =====================================================
# ⚙️  ARCH DREAM - GESTOR DE CONFIGURACIONES
# =====================================================
# Sistema de gestión de configuraciones y archivos
# Backup, symlinks y gestión inteligente de archivos
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# =====================================================
# 🔧 CONFIGURACIÓN DEL GESTOR DE CONFIGURACIONES
# =====================================================

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh" 2>/dev/null || {
    echo "Error: No se pudo cargar common.sh" >&2
    exit 1
}

# Directorios de configuración
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}"
BACKUP_ROOT="$HOME/.arch-dream-backups"

# Configuración de backup
BACKUP_TIMESTAMP_FORMAT="%Y%m%d_%H%M%S"
BACKUP_MAX_COUNT=10
BACKUP_COMPRESSION=true

# =====================================================
# 💾 FUNCIONES DE BACKUP Y RESTAURACIÓN
# =====================================================

# Crear backup de archivo o directorio
create_backup() {
    local source="$1"
    local backup_name="${2:-$(basename "$source")}"
    
    [[ -e "$source" ]] || return 0
    
    local timestamp=$(date +"$BACKUP_TIMESTAMP_FORMAT")
    local backup_path="$BACKUP_ROOT/${backup_name}.${timestamp}"
    
    # Crear directorio de backup si no existe
    mkdir -p "$BACKUP_ROOT"
    
    log "💾 Creando backup: $source -> $backup_path"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        success "DRY RUN: Backup sería creado: $backup_path"
        return 0
    fi
    
    # Crear backup
    if cp -r "$source" "$backup_path" 2>/dev/null; then
        # Comprimir si está habilitado
        if [[ "$BACKUP_COMPRESSION" == "true" && -d "$backup_path" ]]; then
            if tar -czf "$backup_path.tar.gz" -C "$(dirname "$backup_path")" "$(basename "$backup_path")" 2>/dev/null; then
                rm -rf "$backup_path"
                backup_path="$backup_path.tar.gz"
            fi
        fi
        
        success "✅ Backup creado: $backup_path"
        
        # Limpiar backups antiguos
        cleanup_old_backups "$backup_name"
        
        return 0
    else
        error "❌ Fallo al crear backup de $source"
        return 1
    fi
}

# Limpiar backups antiguos
cleanup_old_backups() {
    local backup_name="$1"
    local max_count="${2:-$BACKUP_MAX_COUNT}"
    
    # Encontrar todos los backups del archivo
    local backups=()
    mapfile -t backups < <(find "$BACKUP_ROOT" -name "${backup_name}.*" -type f | sort -r)
    
    # Mantener solo los más recientes
    if [[ ${#backups[@]} -gt $max_count ]]; then
        local to_remove=("${backups[@]:$max_count}")
        log "🧹 Limpiando ${#to_remove[@]} backups antiguos..."
        
        for backup in "${to_remove[@]}"; do
            rm -f "$backup" && debug "Eliminado: $backup"
        done
        
        success "✅ Limpieza de backups completada"
    fi
}

# Restaurar desde backup
restore_from_backup() {
    local backup_path="$1"
    local target_path="$2"
    
    [[ -e "$backup_path" ]] || {
        error "❌ Backup no encontrado: $backup_path"
        return 1
    }
    
    log "🔄 Restaurando desde backup: $backup_path -> $target_path"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        success "DRY RUN: Restauración sería realizada: $target_path"
        return 0
    fi
    
    # Crear backup del archivo actual si existe
    [[ -e "$target_path" ]] && create_backup "$target_path" "$(basename "$target_path").pre_restore"
    
    # Restaurar
    if [[ "$backup_path" == *.tar.gz ]]; then
        # Backup comprimido
        local temp_dir=$(mktemp -d)
        if tar -xzf "$backup_path" -C "$temp_dir"; then
            local extracted_name=$(ls "$temp_dir")
            if mv "$temp_dir/$extracted_name" "$target_path"; then
                success "✅ Restauración completada desde backup comprimido"
                rm -rf "$temp_dir"
                return 0
            fi
        fi
        rm -rf "$temp_dir"
        error "❌ Fallo al restaurar desde backup comprimido"
        return 1
    else
        # Backup normal
        if cp -r "$backup_path" "$target_path"; then
            success "✅ Restauración completada desde backup"
            return 0
        else
            error "❌ Fallo al restaurar desde backup"
            return 1
        fi
    fi
}

# Listar backups disponibles
list_backups() {
    local backup_name="${1:-}"
    
    if [[ -n "$backup_name" ]]; then
        local backups=()
        mapfile -t backups < <(find "$BACKUP_ROOT" -name "${backup_name}.*" -type f | sort -r)
        
        if [[ ${#backups[@]} -eq 0 ]]; then
            echo "No se encontraron backups para: $backup_name"
            return 0
        fi
        
        echo -e "${CYAN}📋 Backups disponibles para $backup_name:${NC}"
        for i in "${!backups[@]}"; do
            local size=$(du -h "$backups[$i]" | cut -f1)
            local date=$(stat -c %y "$backups[$i]" | cut -d' ' -f1)
            printf "  %2d) %s (%s, %s)\n" "$((i+1))" "$(basename "$backups[$i]")" "$size" "$date"
        done
    else
        local backups=()
        mapfile -t backups < <(find "$BACKUP_ROOT" -type f | sort -r)
        
        if [[ ${#backups[@]} -eq 0 ]]; then
            echo "No se encontraron backups"
            return 0
        fi
        
        echo -e "${CYAN}📋 Todos los backups disponibles:${NC}"
        for i in "${!backups[@]}"; do
            local size=$(du -h "$backups[$i]" | cut -f1)
            local date=$(stat -c %y "$backups[$i]" | cut -d' ' -f1)
            printf "  %2d) %s (%s, %s)\n" "$((i+1))" "$(basename "$backups[$i]")" "$size" "$date"
        done
    fi
}

# =====================================================
# 🔗 FUNCIONES DE SYMLINKS Y CONFIGURACIÓN
# =====================================================

# Crear symlink inteligente
create_symlink() {
    local source="$1"
    local target="$2"
    local description="${3:-$(basename "$target")}"
    
    [[ -e "$source" ]] || {
        error "❌ Archivo fuente no existe: $source"
        return 1
    }
    
    log "🔗 Creando symlink: $description"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        success "DRY RUN: Symlink sería creado: $target -> $source"
        return 0
    fi
    
    # Crear backup si existe el archivo objetivo
    [[ -e "$target" ]] && create_backup "$target" "$(basename "$target")"
    
    # Crear directorio padre si no existe
    mkdir -p "$(dirname "$target")"
    
    # Crear symlink
    if ln -sf "$source" "$target"; then
        success "✅ $description creado: $target -> $source"
        return 0
    else
        error "❌ Fallo al crear $description"
        return 1
    fi
}

# Crear symlink con modo copia
create_copy_link() {
    local source="$1"
    local target="$2"
    local description="${3:-$(basename "$target")}"
    
    [[ -e "$source" ]] || {
        error "❌ Archivo fuente no existe: $source"
        return 1
    }
    
    log "📋 Copiando archivo: $description"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        success "DRY RUN: Archivo sería copiado: $source -> $target"
        return 0
    fi
    
    # Crear backup si existe el archivo objetivo
    [[ -e "$target" ]] && create_backup "$target" "$(basename "$target")"
    
    # Crear directorio padre si no existe
    mkdir -p "$(dirname "$target")"
    
    # Copiar archivo
    if cp -r "$source" "$target"; then
        success "✅ $description copiado: $target"
        return 0
    else
        error "❌ Fallo al copiar $description"
        return 1
    fi
}

# Verificar integridad de symlinks
verify_symlinks() {
    local config_dir="$1"
    local broken_links=()
    
    [[ -d "$config_dir" ]] || return 0
    
    log "🔍 Verificando symlinks en: $config_dir"
    
    while IFS= read -r -d '' link; do
        if [[ -L "$link" ]] && [[ ! -e "$link" ]]; then
            broken_links+=("$link")
        fi
    done < <(find "$config_dir" -type l -print0)
    
    if [[ ${#broken_links[@]} -eq 0 ]]; then
        success "✅ No se encontraron symlinks rotos"
        return 0
    else
        warn "⚠️  Se encontraron ${#broken_links[@]} symlinks rotos:"
        for link in "${broken_links[@]}"; do
            echo "  - $link"
        done
        return 1
    fi
}

# Reparar symlinks rotos
repair_symlinks() {
    local config_dir="$1"
    local repaired=0
    
    [[ -d "$config_dir" ]] || return 0
    
    log "🔧 Reparando symlinks rotos en: $config_dir"
    
    while IFS= read -r -d '' link; do
        if [[ -L "$link" ]] && [[ ! -e "$link" ]]; then
            local target=$(readlink "$link")
            local source_dir=$(dirname "$link")
            
            # Buscar archivo fuente en directorios comunes
            local found=false
            for search_dir in "$SCRIPT_DIR/modules" "$HOME/.config" "$HOME"; do
                if [[ -e "$search_dir/$target" ]]; then
                    if ln -sf "$search_dir/$target" "$link"; then
                        success "✅ Reparado: $link -> $search_dir/$target"
                        ((repaired++))
                        found=true
                        break
                    fi
                fi
            done
            
            if [[ "$found" == "false" ]]; then
                warn "⚠️  No se pudo reparar: $link"
            fi
        fi
    done < <(find "$config_dir" -type l -print0)
    
    if [[ $repaired -gt 0 ]]; then
        success "✅ $repaired symlinks reparados"
    else
        log "ℹ️  No se encontraron symlinks para reparar"
    fi
}

# =====================================================
# 📁 FUNCIONES DE GESTIÓN DE DIRECTORIOS
# =====================================================

# Crear estructura de directorios
create_directory_structure() {
    local base_dir="$1"
    local structure=("${@:2}")
    
    log "📁 Creando estructura de directorios en: $base_dir"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        success "DRY RUN: Estructura sería creada en $base_dir"
        return 0
    fi
    
    local created=0
    for dir in "${structure[@]}"; do
        local full_path="$base_dir/$dir"
        if [[ ! -d "$full_path" ]]; then
            if mkdir -p "$full_path"; then
                success "✅ Directorio creado: $full_path"
                ((created++))
            else
                warn "⚠️  No se pudo crear: $full_path"
            fi
        else
            debug "✓ Directorio ya existe: $full_path"
        fi
    done
    
    success "✅ Estructura de directorios creada ($created nuevos)"
}

# Establecer permisos de directorios
set_directory_permissions() {
    local dir="$1"
    local permissions="${2:-755}"
    
    [[ -d "$dir" ]] || return 0
    
    log "🔐 Estableciendo permisos $permissions en: $dir"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        success "DRY RUN: Permisos serían establecidos: $permissions"
        return 0
    fi
    
    if chmod -R "$permissions" "$dir"; then
        success "✅ Permisos establecidos: $dir"
        return 0
    else
        warn "⚠️  No se pudieron establecer permisos en: $dir"
        return 1
    fi
}

# =====================================================
# 🔍 FUNCIONES DE VALIDACIÓN Y VERIFICACIÓN
# =====================================================

# Verificar configuración de módulo
verify_module_config() {
    local module_name="$1"
    local config_files=("${@:2}")
    
    log "🔍 Verificando configuración del módulo: $module_name"
    
    local verified=0
    local total=${#config_files[@]}
    
    for config in "${config_files[@]}"; do
        if [[ -e "$config" ]]; then
            success "✓ $config verificado"
            ((verified++))
        else
            warn "⚠️  $config no encontrado"
        fi
    done
    
    if [[ $verified -eq $total ]]; then
        success "✅ Módulo $module_name completamente configurado ($verified/$total)"
        return 0
    elif [[ $verified -gt 0 ]]; then
        warn "⚠️  Módulo $module_name parcialmente configurado ($verified/$total)"
        return 1
    else
        error "❌ Módulo $module_name no configurado ($verified/$total)"
        return 1
    fi
}

# Validar archivos de configuración
validate_config_files() {
    local config_dir="$1"
    local file_patterns=("${@:2}")
    
    [[ -d "$config_dir" ]] || return 0
    
    log "🔍 Validando archivos de configuración en: $config_dir"
    
    local valid=0
    local total=${#file_patterns[@]}
    
    for pattern in "${file_patterns[@]}"; do
        if find "$config_dir" -name "$pattern" -type f | grep -q .; then
            success "✓ $pattern encontrado"
            ((valid++))
        else
            warn "⚠️  $pattern no encontrado"
        fi
    done
    
    if [[ $valid -eq $total ]]; then
        success "✅ Todos los archivos de configuración válidos ($valid/$total)"
        return 0
    else
        warn "⚠️  Algunos archivos de configuración faltan ($valid/$total)"
        return 1
    fi
}

# =====================================================
# 🚀 FUNCIÓN PRINCIPAL DEL GESTOR DE CONFIGURACIONES
# =====================================================

# Inicializar gestor de configuraciones
init_config_manager() {
    log "🚀 Inicializando gestor de configuraciones..."
    
    # Crear directorios base
    local base_dirs=("$CONFIG_ROOT" "$CACHE_ROOT" "$STATE_ROOT" "$BACKUP_ROOT")
    create_directory_structure "$HOME" "${base_dirs[@]}"
    
    # Establecer permisos
    set_directory_permissions "$BACKUP_ROOT" "700"
    
    # Verificar permisos de escritura
    for dir in "${base_dirs[@]}"; do
        [[ -w "$dir" ]] || {
            warn "⚠️  Sin permisos de escritura en: $dir"
        }
    done
    
    success "✅ Gestor de configuraciones inicializado correctamente"
}

# =====================================================
# 📋 FUNCIONES DE UTILIDAD
# =====================================================

# Función de ayuda
show_config_manager_help() {
    cat << EOF
⚙️  Arch Dream Config Manager

${BOLD}FUNCIONES DISPONIBLES:${NC}
    create_backup <fuente> [nombre]        # Crear backup de archivo/directorio
    restore_from_backup <backup> <destino> # Restaurar desde backup
    list_backups [nombre]                  # Listar backups disponibles
    create_symlink <fuente> <destino>      # Crear symlink inteligente
    create_copy_link <fuente> <destino>    # Copiar archivo con backup
    verify_symlinks <directorio>           # Verificar symlinks
    repair_symlinks <directorio>           # Reparar symlinks rotos
    create_directory_structure <base> <dirs> # Crear estructura de directorios
    set_directory_permissions <dir> [perm] # Establecer permisos
    verify_module_config <módulo> <archivos> # Verificar configuración de módulo
    validate_config_files <dir> <patrones> # Validar archivos de configuración

${BOLD}EJEMPLOS:${NC}
    create_backup ~/.zshrc                 # Backup de .zshrc
    create_symlink ~/config/zshrc ~/.zshrc # Crear symlink
    verify_symlinks ~/.config              # Verificar symlinks en .config
    create_directory_structure ~/.config "nvim" "kitty" # Crear directorios

${BOLD}VARIABLES DE ENTORNO:${NC}
    DRY_RUN=true                           # Modo simulación
    BACKUP_COMPRESSION=true                # Comprimir backups
    BACKUP_MAX_COUNT=10                    # Máximo número de backups
EOF
}

# Exportar funciones principales
export -f create_backup restore_from_backup list_backups
export -f create_symlink create_copy_link verify_symlinks repair_symlinks
export -f create_directory_structure set_directory_permissions
export -f verify_module_config validate_config_files
export -f init_config_manager show_config_manager_help

# Si se ejecuta directamente, mostrar ayuda
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
    show_config_manager_help
    exit 0
}
