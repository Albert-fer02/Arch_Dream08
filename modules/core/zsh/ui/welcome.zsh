#!/bin/zsh
# =====================================================
# 🎨 WELCOME MESSAGE OPTIMIZADO
# =====================================================

# Solo mostrar welcome message una vez por sesión
if [[ "${FASTFETCH_SHOWN:-0}" == "0" && -z "${TMUX:-}${STY:-}" ]]; then
    # Usar XDG paths para configuración
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch"
    local config_file="$config_dir/config.jsonc"
    
    if command -v fastfetch &>/dev/null; then
        # Intentar con configuración personalizada, fallback a default
        fastfetch --config "$config_file" 2>/dev/null || fastfetch
        export FASTFETCH_SHOWN=1
    elif command -v neofetch &>/dev/null; then
        neofetch
        export FASTFETCH_SHOWN=1
    fi
fi
