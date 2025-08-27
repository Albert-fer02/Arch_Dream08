#!/bin/zsh
# =====================================================
# 🎨 WELCOME MESSAGE OPTIMIZADO
# =====================================================

# Función simple para mostrar welcome message
show_welcome_message() {
    # Solo ejecutar si no estamos en TMUX/screen
    if [[ -z "${TMUX:-}${STY:-}" ]]; then
        
        # Verificar si fastfetch está disponible
        if command -v fastfetch &>/dev/null; then
            # Configuración de fastfetch
            local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch"
            local config_file="$config_dir/config.jsonc"
            
            # Ejecutar fastfetch de forma completamente silenciosa
            if [[ -f "$config_file" ]]; then
                fastfetch --config "$config_file" 2>/dev/null || fastfetch 2>/dev/null || true
            else
                fastfetch 2>/dev/null || true
            fi
            
        elif command -v neofetch &>/dev/null; then
            # Fallback a neofetch
            neofetch 2>/dev/null || true
        fi
    fi
}

# Ejecutar automáticamente
show_welcome_message
