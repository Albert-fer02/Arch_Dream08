#!/bin/bash
# =====================================================
# 📝 LOGGING SIMPLE - ARCH DREAM
# =====================================================

# Configuración básica de logging
export ARCH_DREAM_LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/arch-dream/logs"

# Crear directorio de logs
mkdir -p "$ARCH_DREAM_LOG_DIR" 2>/dev/null || true

# Función simple de logging
log() {
    local level="$1"; shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$ARCH_DREAM_LOG_DIR/arch-dream.log"
    
    # Solo loggear ERROR y FATAL por defecto
    case "$level" in
        "ERROR"|"FATAL")
            echo "[$timestamp] [$level] $message" >> "$log_file"
            ;;
    esac
}

# Funciones de conveniencia
log_error() { log "ERROR" "$@"; }
log_fatal() { log "FATAL" "$@"; }

# Función para limpiar logs antiguos
log_cleanup() {
    find "$ARCH_DREAM_LOG_DIR" -name "*.log" -mtime +7 -delete 2>/dev/null || true
    echo "✅ Logs antiguos limpiados"
}