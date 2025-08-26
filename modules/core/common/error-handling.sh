#!/usr/bin/env bash
# =====================================================
# 🛡️ MANEJO DE ERRORES SIMPLE - ARCH DREAM
# =====================================================

# Función simple para verificar dependencias
check_dependency() {
    local cmd="$1"
    local optional="${2:-false}"
    
    if ! command -v "$cmd" >/dev/null 2>&1; then
        if [[ "$optional" == "true" ]]; then
            echo "⚠️ Dependencia opcional '$cmd' no encontrada" >&2
            return 1
        else
            echo "❌ Dependencia requerida '$cmd' no encontrada" >&2
            return 1
        fi
    fi
    return 0
}

# Función simple para verificar archivos
check_file() {
    local file="$1"
    local required="${2:-true}"
    
    if [[ ! -f "$file" ]]; then
        if [[ "$required" == "true" ]]; then
            echo "❌ Archivo requerido no encontrado: $file" >&2
            return 1
        else
            echo "⚠️ Archivo opcional no encontrado: $file" >&2
            return 1
        fi
    fi
    return 0
}

# Función simple para cargar archivos de forma segura
safe_source() {
    local file="$1"
    if [[ -f "$file" && -r "$file" ]]; then
        source "$file" 2>/dev/null || true
    fi
}