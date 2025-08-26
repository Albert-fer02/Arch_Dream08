#!/bin/zsh
# =====================================================
# 🎨 CONFIGURACIÓN DE STARSHIP ESENCIAL
# =====================================================

# Verificar si starship está disponible
if command -v starship >/dev/null 2>&1; then
    # Configurar variables necesarias para starship
    export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
    
    # Inicializar Starship
    eval "$(starship init zsh)"
else
    # Prompt personalizado simple si starship no está disponible
    PROMPT='%F{green}%n%f@%F{blue}%m%f %F{cyan}%~%f %# '
    RPROMPT='%F{yellow}[%D{%H:%M:%S}]%f'
fi
