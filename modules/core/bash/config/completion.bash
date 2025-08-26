#!/bin/bash
# =====================================================
# ⚡ COMPLETION SYSTEM PARA BASH
# =====================================================

# Función para cargar completions de manera lazy
load_bash_completion() {
    if ! shopt -oq posix; then
        if [[ -f /usr/share/bash-completion/bash_completion ]]; then
            source /usr/share/bash-completion/bash_completion
        elif [[ -f /etc/bash_completion ]]; then
            source /etc/bash_completion
        fi
    fi
}

# Cargar completions solo en shells interactivos
[[ $- == *i* ]] && load_bash_completion

# Completions adicionales
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
