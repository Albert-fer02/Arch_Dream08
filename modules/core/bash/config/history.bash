#!/bin/bash
# =====================================================
# 📚 HISTORIAL OPTIMIZADO PARA BASH - ARCH DREAM v4.3
# =====================================================

# Configuración del historial con valores dinámicos
setup_history() {
    # Configuración desde sistema de configuración si está disponible
    local hist_size=50000
    local hist_file_size=100000
    
    if command -v config_get >/dev/null 2>&1; then
        hist_size=$(config_get "performance.history_limit" "50000")
        hist_file_size=$((hist_size * 2))
    fi
    
    # Variables de historial
    export HISTCONTROL="ignoreboth:erasedups"
    export HISTSIZE="$hist_size"
    export HISTFILESIZE="$hist_file_size"
    export HISTTIMEFORMAT="%Y-%m-%d %T "
    
    # Patrones a ignorar (dinámico según perfil)
    local ignore_patterns="ls:ll:la:cd:pwd:clear:history:exit:h:cls"
    
    # Patrones adicionales según perfil
    if [[ "${ARCH_DREAM_PROFILE:-}" == "pentester" ]]; then
        ignore_patterns="$ignore_patterns:nmap:hydra:john:hashcat"
    fi
    
    # Agregar patrones sensibles si están configurados
    if command -v config_get >/dev/null 2>&1; then
        local sensitive=$(config_get "security.sensitive_patterns" "")
        if [[ -n "$sensitive" ]]; then
            ignore_patterns="$ignore_patterns:*password*:*secret*:*token*:*key*"
        fi
    fi
    
    export HISTIGNORE="$ignore_patterns"
    
    # Configurar archivo de historial
    local hist_file="${XDG_CACHE_HOME:-$HOME/.cache}/bash/history"
    if command -v config_is_enabled >/dev/null 2>&1 && config_is_enabled "performance.separate_history"; then
        mkdir -p "$(dirname "$hist_file")"
        export HISTFILE="$hist_file"
    else
        # Fallback al historial estándar
        export HISTFILE="${HISTFILE:-$HOME/.bash_history}"
    fi
}

# Opciones del shell para historial
setup_history_options() {
    # Opciones básicas
    shopt -s histappend     # Añadir al historial, no sobrescribir
    shopt -s checkwinsize   # Actualizar LINES y COLUMNS
    shopt -s cmdhist        # Comandos multi-línea en una sola entrada
    shopt -s histreedit     # Re-editar comando fallido
    shopt -s histverify     # Verificar expansión de historial
    
    # Configuraciones adicionales si están disponibles
    if [[ "$BASH_VERSINFO" -ge 4 ]]; then
        shopt -s globstar   # Habilitar **
        shopt -s extglob    # Habilitar patrones extendidos
    fi
}

# Función para limpiar historial automáticamente
clean_history_auto() {
    if command -v config_is_enabled >/dev/null 2>&1 && config_is_enabled "security.auto_clean_history"; then
        # Obtener patrones sensibles
        local sensitive_patterns=()
        if command -v config_get >/dev/null 2>&1; then
            local patterns=$(config_get "security.sensitive_patterns")
            if [[ -n "$patterns" ]]; then
                IFS=',' read -ra sensitive_patterns <<< "$patterns"
            fi
        else
            sensitive_patterns=("password" "passwd" "secret" "token" "api_key" "private_key")
        fi
        
        # Limpiar patrones del historial
        for pattern in "${sensitive_patterns[@]}"; do
            if [[ -n "$pattern" ]]; then
                history -d "$(history | grep -n "$pattern" | cut -d: -f1 | tail -1)" 2>/dev/null || true
            fi
        done
        
        # Log si está disponible
        if command -v log_debug >/dev/null 2>&1; then
            log_debug "History auto-cleaned for sensitive patterns"
        fi
    fi
}

# Función para backup del historial
backup_history() {
    local backup_dir="${XDG_CACHE_HOME:-$HOME/.cache}/bash/history-backups"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    mkdir -p "$backup_dir"
    
    if [[ -f "$HISTFILE" ]]; then
        cp "$HISTFILE" "$backup_dir/bash_history_$timestamp"
        
        # Mantener solo los últimos 7 backups
        find "$backup_dir" -name "bash_history_*" -type f | sort | head -n -7 | xargs rm -f 2>/dev/null || true
        
        if command -v log_debug >/dev/null 2>&1; then
            log_debug "History backup created: bash_history_$timestamp"
        fi
    fi
}

# Hook para limpiar historial al salir
history_exit_hook() {
    # Limpiar patrones sensibles antes de salir
    clean_history_auto
    
    # Backup si está habilitado
    if command -v config_is_enabled >/dev/null 2>&1 && config_is_enabled "backup.auto_history"; then
        backup_history
    fi
    
    # Sincronizar historial
    history -w
}

# Configurar trap para salida limpia
trap history_exit_hook EXIT

# Función para mostrar estadísticas de historial
history_stats() {
    echo "📚 Estadísticas del Historial"
    echo "=========================="
    echo "Archivo: $HISTFILE"
    echo "Tamaño máximo: $HISTSIZE entradas"
    echo "Archivo máximo: $HISTFILESIZE líneas"
    echo "Entradas actuales: $(history | wc -l)"
    
    if [[ -f "$HISTFILE" ]]; then
        echo "Líneas en archivo: $(wc -l < "$HISTFILE")"
        echo "Tamaño del archivo: $(du -h "$HISTFILE" | cut -f1)"
        echo "Última modificación: $(stat -c %y "$HISTFILE" | cut -d. -f1)"
    fi
    
    echo ""
    echo "Comandos más usados:"
    if [[ -f "$HISTFILE" ]]; then
        # Extraer comandos (primera palabra después del timestamp)
        awk '{print $4}' "$HISTFILE" 2>/dev/null | sort | uniq -c | sort -nr | head -10 | \
            awk '{printf "  %-3d %s\n", $1, $2}'
    else
        echo "  (archivo de historial no encontrado)"
    fi
}

# Inicializar configuración
setup_history
setup_history_options

# Programar limpieza automática cada 100 comandos
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }if [[ \$(history | wc -l) -gt 0 && \$(( \$(history | wc -l) % 100 )) -eq 0 ]]; then clean_history_auto; fi"

# Exportar funciones
export -f clean_history_auto backup_history history_stats history_exit_hook
