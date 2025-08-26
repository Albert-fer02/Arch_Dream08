#!/bin/bash
# =====================================================
# 🎨 WELCOME MESSAGE PARA BASH
# =====================================================

# Solo mostrar welcome message una vez por sesión
if [[ -z "${BASH_WELCOME_SHOWN:-}" && -z "${TMUX:-}${STY:-}" ]]; then
    if command -v fastfetch &>/dev/null; then
        fastfetch --config ~/.config/fastfetch/config.jsonc 2>/dev/null || fastfetch
        export BASH_WELCOME_SHOWN=1
    elif command -v neofetch &>/dev/null; then
        neofetch
        export BASH_WELCOME_SHOWN=1
    fi
fi
