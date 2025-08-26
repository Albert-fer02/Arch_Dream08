#!/bin/bash
# =====================================================
# 🎨 STARSHIP PROMPT PARA BASH
# =====================================================

# Configuración básica de Starship
export STARSHIP_LOG="error"
export STARSHIP_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/starship"
export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"

# Crear directorio de caché si no existe
[[ ! -d "$STARSHIP_CACHE" ]] && mkdir -p "$STARSHIP_CACHE"

# Inicializar Starship prompt para bash
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi
