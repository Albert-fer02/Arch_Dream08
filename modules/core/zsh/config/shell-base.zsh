#!/bin/zsh
# =====================================================
# 🏗️ BASE SHELL PARA ZSH - ARCH DREAM
# =====================================================

# Variables básicas del módulo
export ARCH_DREAM_CORE_DIR="${0:A:h}/../.."
export ARCH_DREAM_ZSH_DIR="${0:A:h}/.."
export ARCH_DREAM_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/arch-dream"

# Crear directorios necesarios
mkdir -p "$ARCH_DREAM_CACHE_DIR"/{logs,cache,tmp} 2>/dev/null || true

# Función simple para cargar archivos
safe_source() {
    local file="$1"
    if [[ -f "$file" && -r "$file" ]]; then
        source "$file" 2>/dev/null || true
    fi
}

# Función para verificar comandos
check_command() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
}