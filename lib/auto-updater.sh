#!/bin/bash
# =====================================================
# 🔄 ARCH DREAM - SISTEMA DE AUTO-ACTUALIZACIÓN
# =====================================================
# Sistema inteligente de actualización automática
# Mantiene el proyecto optimizado y actualizado
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# =====================================================
# 🔧 CONFIGURACIÓN
# =====================================================

# Directorios y archivos
UPDATE_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/arch-dream/updates"
UPDATE_LOG="$UPDATE_ROOT/update.log"
UPDATE_CONFIG="$UPDATE_ROOT/config.json"
LAST_CHECK_FILE="$UPDATE_ROOT/last_check"

# Configuración por defecto
DEFAULT_UPDATE_INTERVAL=86400  # 24 horas
DEFAULT_AUTO_UPDATE=false
DEFAULT_BACKUP_BEFORE_UPDATE=true
DEFAULT_NOTIFICATION_ENABLED=true

# URLs y versiones
GITHUB_REPO="Albert-fer02/arch-dream"
CURRENT_VERSION="4.0.0"
VERSION_CHECK_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"

# =====================================================
# 🔧 INICIALIZACIÓN
# =====================================================

init_auto_updater() {
    debug "Inicializando sistema de auto-actualización..."
    
    mkdir -p "$UPDATE_ROOT"
    chmod 755 "$UPDATE_ROOT"
    
    # Crear configuración por defecto si no existe
    if [[ ! -f "$UPDATE_CONFIG" ]]; then
        create_default_config
    fi
    
    # Crear log si no existe
    [[ -f "$UPDATE_LOG" ]] || echo "# Arch Dream Auto-Update Log" > "$UPDATE_LOG"
    
    success "✅ Sistema de auto-actualización inicializado"
}

create_default_config() {
    cat > "$UPDATE_CONFIG" << EOF
{
  "auto_update": $DEFAULT_AUTO_UPDATE,
  "update_interval": $DEFAULT_UPDATE_INTERVAL,
  "backup_before_update": $DEFAULT_BACKUP_BEFORE_UPDATE,
  "notification_enabled": $DEFAULT_NOTIFICATION_ENABLED,
  "current_version": "$CURRENT_VERSION",
  "last_update": "",
  "update_branch": "main"
}
EOF
    debug "Configuración de auto-actualización creada"
}

# =====================================================
# 🔍 VERIFICACIÓN DE ACTUALIZACIONES
# =====================================================

check_for_updates() {
    log "🔍 Verificando actualizaciones disponibles..."
    
    # Verificar conexión a internet
    if ! ping -c 1 -W 2 github.com &>/dev/null; then
        warn "⚠️  Sin conexión a internet, saltando verificación"
        return 1
    fi
    
    # Obtener última versión desde GitHub
    local latest_version=""
    if command -v curl &>/dev/null; then
        latest_version=$(curl -s "$VERSION_CHECK_URL" | grep '"tag_name"' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/' 2>/dev/null || echo "")
    elif command -v wget &>/dev/null; then
        latest_version=$(wget -qO- "$VERSION_CHECK_URL" | grep '"tag_name"' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/' 2>/dev/null || echo "")
    fi
    
    if [[ -z "$latest_version" ]]; then
        warn "⚠️  No se pudo obtener información de la última versión"
        return 1
    fi
    
    # Comparar versiones
    if [[ "$latest_version" != "$CURRENT_VERSION" ]]; then
        log "🆕 Nueva versión disponible: $latest_version (actual: $CURRENT_VERSION)"
        echo "$latest_version"
        return 0
    else
        debug "Sistema actualizado (versión: $CURRENT_VERSION)"
        return 1
    fi
}

# =====================================================
# 📥 DESCARGA Y APLICACIÓN
# =====================================================

download_update() {
    local version="$1"
    local download_dir="$UPDATE_ROOT/downloads/$version"
    local archive_url="https://github.com/$GITHUB_REPO/archive/refs/tags/$version.tar.gz"
    
    log "📥 Descargando actualización $version..."
    
    mkdir -p "$download_dir"
    
    # Descargar archivo
    local archive_file="$download_dir/update.tar.gz"
    if command -v curl &>/dev/null; then
        curl -L -o "$archive_file" "$archive_url" || return 1
    elif command -v wget &>/dev/null; then
        wget -O "$archive_file" "$archive_url" || return 1
    else
        error "❌ No se encontró curl o wget para descargar"
        return 1
    fi
    
    # Extraer archivo
    if tar -xzf "$archive_file" -C "$download_dir" --strip-components=1; then
        success "✅ Actualización descargada y extraída"
        echo "$download_dir"
    else
        error "❌ Error extrayendo actualización"
        return 1
    fi
}

apply_update() {
    local update_dir="$1"
    local version="$2"
    
    log "🔄 Aplicando actualización $version..."
    
    # Crear backup antes de actualizar
    if get_config_value "backup_before_update"; then
        create_pre_update_backup "$version"
    fi
    
    # Verificar que los archivos críticos existen en la actualización
    local critical_files=(
        "lib/shell-base.sh"
        "lib/module-manager.sh"
        "install-simple.sh"
    )
    
    for file in "${critical_files[@]}"; do
        if [[ ! -f "$update_dir/$file" ]]; then
            error "❌ Archivo crítico faltante en actualización: $file"
            return 1
        fi
    done
    
    # Aplicar actualización
    local project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    
    # Copiar archivos nuevos (preservando configuraciones locales)
    rsync -av --exclude="*.local" --exclude="backups/" --exclude=".git/" \
          "$update_dir/" "$project_root/" || {
        error "❌ Error aplicando actualización"
        return 1
    }
    
    # Actualizar permisos
    chmod +x "$project_root"/*.sh
    chmod +x "$project_root/lib"/*.sh
    
    # Actualizar versión en configuración
    update_config_value "current_version" "$version"
    update_config_value "last_update" "$(date -Iseconds)"
    
    # Log de actualización
    echo "$(date -Iseconds) | UPDATE | $CURRENT_VERSION -> $version | success" >> "$UPDATE_LOG"
    
    success "✅ Actualización $version aplicada exitosamente"
}

# =====================================================
# 💾 BACKUP PRE-ACTUALIZACIÓN
# =====================================================

create_pre_update_backup() {
    local version="$1"
    local backup_name="pre_update_${version}_$(date +%Y%m%d_%H%M%S)"
    
    log "💾 Creando backup pre-actualización..."
    
    # Usar sistema de backup simple si está disponible
    if [[ -f "lib/simple-backup.sh" ]]; then
        source "lib/simple-backup.sh"
        simple_backup_main create "$backup_name" "Backup antes de actualizar a $version" &>/dev/null
    else
        # Backup manual básico
        local backup_dir="$UPDATE_ROOT/backups/$backup_name"
        mkdir -p "$backup_dir"
        
        local important_files=(
            "$HOME/.bashrc" "$HOME/.zshrc"
            "$HOME/.config/starship.toml"
            "$HOME/.config/kitty/kitty.conf"
            "$HOME/.config/nvim/init.lua"
        )
        
        for file in "${important_files[@]}"; do
            if [[ -e "$file" ]]; then
                local target_dir="$backup_dir/$(dirname "${file#$HOME/}")"
                mkdir -p "$target_dir"
                cp -r "$file" "$target_dir/"
            fi
        done
    fi
    
    success "✅ Backup pre-actualización creado"
}

# =====================================================
# ⚙️ GESTIÓN DE CONFIGURACIÓN
# =====================================================

get_config_value() {
    local key="$1"
    
    if [[ -f "$UPDATE_CONFIG" ]] && command -v jq &>/dev/null; then
        jq -r ".$key" "$UPDATE_CONFIG" 2>/dev/null || echo "null"
    else
        # Fallback simple sin jq
        case "$key" in
            auto_update) echo "$DEFAULT_AUTO_UPDATE" ;;
            update_interval) echo "$DEFAULT_UPDATE_INTERVAL" ;;
            backup_before_update) echo "$DEFAULT_BACKUP_BEFORE_UPDATE" ;;
            *) echo "null" ;;
        esac
    fi
}

update_config_value() {
    local key="$1"
    local value="$2"
    
    if [[ -f "$UPDATE_CONFIG" ]] && command -v jq &>/dev/null; then
        local temp_file=$(mktemp)
        jq --arg key "$key" --arg value "$value" '.[$key] = $value' "$UPDATE_CONFIG" > "$temp_file"
        mv "$temp_file" "$UPDATE_CONFIG"
    else
        # Recrear configuración básica
        create_default_config
    fi
}

# =====================================================
# 🔔 NOTIFICACIONES
# =====================================================

send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    
    # Verificar si las notificaciones están habilitadas
    if [[ "$(get_config_value "notification_enabled")" != "true" ]]; then
        return 0
    fi
    
    # Enviar notificación si notify-send está disponible
    if command -v notify-send &>/dev/null; then
        notify-send -u "$urgency" "$title" "$message"
    else
        # Fallback a echo con colores
        case "$urgency" in
            critical) error "🚨 $title: $message" ;;
            normal) log "🔔 $title: $message" ;;
            low) debug "ℹ️ $title: $message" ;;
        esac
    fi
}

# =====================================================
# ⏰ GESTIÓN DE INTERVALOS
# =====================================================

should_check_for_updates() {
    local update_interval=$(get_config_value "update_interval")
    
    if [[ ! -f "$LAST_CHECK_FILE" ]]; then
        return 0  # Primera vez, verificar
    fi
    
    local last_check=$(cat "$LAST_CHECK_FILE" 2>/dev/null || echo "0")
    local current_time=$(date +%s)
    local time_diff=$((current_time - last_check))
    
    if [[ $time_diff -gt $update_interval ]]; then
        return 0  # Es hora de verificar
    else
        return 1  # Aún no es hora
    fi
}

update_last_check_time() {
    echo "$(date +%s)" > "$LAST_CHECK_FILE"
}

# =====================================================
# 🏁 FUNCIONES PRINCIPALES
# =====================================================

run_update_check() {
    local force="${1:-false}"
    
    # Verificar si debe chequear actualizaciones
    if [[ "$force" != "true" ]] && ! should_check_for_updates; then
        debug "No es hora de verificar actualizaciones"
        return 0
    fi
    
    # Actualizar tiempo de última verificación
    update_last_check_time
    
    # Verificar actualizaciones
    local latest_version=""
    if latest_version=$(check_for_updates); then
        # Nueva versión disponible
        send_notification "Arch Dream" "Nueva versión disponible: $latest_version" "normal"
        
        # Auto-actualizar si está habilitado
        if [[ "$(get_config_value "auto_update")" == "true" ]]; then
            run_auto_update "$latest_version"
        else
            log "💡 Para actualizar manualmente: auto_updater_main update"
        fi
    fi
}

run_auto_update() {
    local version="$1"
    
    log "🚀 Iniciando auto-actualización a $version..."
    
    # Descargar actualización
    local update_dir=""
    if update_dir=$(download_update "$version"); then
        # Aplicar actualización
        if apply_update "$update_dir" "$version"; then
            send_notification "Arch Dream" "Actualizado exitosamente a $version" "normal"
            success "🎉 Sistema actualizado a $version"
        else
            send_notification "Arch Dream" "Error aplicando actualización" "critical"
            error "❌ Error aplicando actualización"
        fi
        
        # Limpiar archivos temporales
        rm -rf "$update_dir"
    else
        send_notification "Arch Dream" "Error descargando actualización" "critical"
        error "❌ Error descargando actualización"
    fi
}

show_update_status() {
    log "📊 Estado del sistema de actualización..."
    
    echo -e "${BOLD}${BLUE}📊 Estado de Actualización${COLOR_RESET}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Versión actual: $CURRENT_VERSION"
    echo -e "${CYAN}│${COLOR_RESET} Auto-actualización: $(get_config_value "auto_update")"
    echo -e "${CYAN}│${COLOR_RESET} Intervalo: $(get_config_value "update_interval")s"
    echo -e "${CYAN}│${COLOR_RESET} Backup automático: $(get_config_value "backup_before_update")"
    
    if [[ -f "$LAST_CHECK_FILE" ]]; then
        local last_check=$(cat "$LAST_CHECK_FILE")
        local last_check_date=$(date -d "@$last_check" 2>/dev/null || echo "Desconocido")
        echo -e "${CYAN}│${COLOR_RESET} Última verificación: $last_check_date"
    fi
    
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${COLOR_RESET}"
}

# =====================================================
# 🏁 INTERFAZ PRINCIPAL
# =====================================================

auto_updater_main() {
    local action="${1:-help}"
    shift || true
    
    # Inicializar si es necesario
    [[ -d "$UPDATE_ROOT" ]] || init_auto_updater
    
    case "$action" in
        init)
            init_auto_updater
            ;;
        check)
            run_update_check true
            ;;
        update)
            local latest_version=""
            if latest_version=$(check_for_updates); then
                run_auto_update "$latest_version"
            else
                success "✅ Sistema ya está actualizado"
            fi
            ;;
        status)
            show_update_status
            ;;
        enable)
            update_config_value "auto_update" "true"
            success "✅ Auto-actualización habilitada"
            ;;
        disable)
            update_config_value "auto_update" "false"
            success "✅ Auto-actualización deshabilitada"
            ;;
        config)
            [[ -f "$UPDATE_CONFIG" ]] && cat "$UPDATE_CONFIG" || echo "No configurado"
            ;;
        help|*)
            cat << 'EOF'
🔄 Sistema de Auto-Actualización - Arch Dream

Uso: auto_updater_main <acción> [argumentos]

Acciones:
  init                Inicializar sistema de actualización
  check               Verificar actualizaciones manualmente
  update              Actualizar a la última versión
  status              Mostrar estado del sistema
  enable              Habilitar auto-actualización
  disable             Deshabilitar auto-actualización
  config              Mostrar configuración actual
  help                Mostrar esta ayuda

Variables de entorno:
  AUTO_UPDATE_INTERVAL=86400    Intervalo en segundos (default: 24h)
  AUTO_UPDATE_ENABLED=true     Habilitar auto-actualización

Ejemplos:
  auto_updater_main check
  auto_updater_main enable
  auto_updater_main update
EOF
            ;;
    esac
}

# Exportar funciones principales
export -f init_auto_updater check_for_updates run_update_check
export -f run_auto_update show_update_status auto_updater_main

# Variables exportadas
export UPDATE_ROOT UPDATE_LOG UPDATE_CONFIG CURRENT_VERSION