#!/bin/zsh
# =====================================================
# 🔌 PLUGINS ESENCIALES - Configuración Mínima
# =====================================================

# zsh-autosuggestions - Sugerencias automáticas
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c6c6c'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# zsh-syntax-highlighting - Resaltado de sintaxis
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# FZF - Búsqueda de archivos avanzada y optimizada
if command -v fzf &>/dev/null; then
    # Configuración del comando por defecto
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .venv --exclude .cache --exclude .local'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules --exclude .venv'
    else
        export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*" -not -path "*/node_modules/*" -not -path "*/.venv/*" -not -path "*/.cache/*" -not -path "*/.local/*"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='find . -type d -not -path "*/\.git/*" -not -path "*/node_modules/*" -not -path "*/.venv/*"'
    fi
    
    # Configuración de la interfaz
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --margin=1,2 --info=inline --prompt="❯ " --pointer="▶" --marker="✓"'
    export FZF_CTRL_T_OPTS='--preview "bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}"'
    export FZF_ALT_C_OPTS='--preview "ls -la {}"'
    
    # Colores personalizados
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#a6e3a1,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
    
    # Key bindings y completion
    if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
        source /usr/share/fzf/key-bindings.zsh
    fi
    
    if [[ -f /usr/share/fzf/completion.zsh ]]; then
        source /usr/share/fzf/completion.zsh
    fi
    
    # Funciones FZF optimizadas
    fzf_open() {
        local file
        file=$(fzf --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}')
        [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
    }
    
    fzf_cd() {
        local dir
        dir=$(fzf --preview 'ls -la {}')
        [[ -n "$dir" ]] && cd "$dir"
    }
    
    fzf_kill() {
        local pid
        pid=$(ps -ef | sed 1d | fzf -m --preview 'echo {}' --preview-window=down:3:wrap | awk '{print $2}')
        [[ -n "$pid" ]] && kill -9 "$pid"
    }
    
    # Key bindings personalizados
    bindkey '^[f' fzf_open
    bindkey '^[d' fzf_cd
    bindkey '^[k' fzf_kill
fi

# Zoxide - Navegación inteligente
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
    alias z='__zoxide_z'
fi

# Atuin - Historial mejorado
if command -v atuin &>/dev/null; then
    eval "$(atuin init zsh --disable-up-arrow)"
    bindkey '^r' _atuin_search_widget
fi
