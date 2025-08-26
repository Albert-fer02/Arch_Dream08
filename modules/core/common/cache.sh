#!/bin/bash
# =====================================================
# 🚀 CACHE SIMPLE - ARCH DREAM
# =====================================================

# Configuración básica del cache
export ARCH_DREAM_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/arch-dream"

# Crear directorio de cache
mkdir -p "$ARCH_DREAM_CACHE_DIR" 2>/dev/null || true

# Función simple para guardar en cache
cache_set() {
    local key="$1"
    local value="$2"
    local cache_file="$ARCH_DREAM_CACHE_DIR/$key"
    
    echo "$value" > "$cache_file" 2>/dev/null || true
}

# Función simple para obtener del cache
cache_get() {
    local key="$1"
    local cache_file="$ARCH_DREAM_CACHE_DIR/$key"
    
    if [[ -f "$cache_file" ]]; then
        cat "$cache_file" 2>/dev/null || true
    fi
}

# Función simple para limpiar cache
cache_clear() {
    rm -rf "$ARCH_DREAM_CACHE_DIR"/* 2>/dev/null || true
    echo "✅ Cache limpiado"
}