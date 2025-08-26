#!/bin/bash
# =====================================================
# 🔍 FZF INTEGRATION PARA BASH - ARCH DREAM v4.3
# =====================================================

# Variables de configuración
FZF_LOADED=false

# Configuración de colores por tema
setup_fzf_colors() {
    local theme="${ARCH_DREAM_THEME:-catppuccin}"
    
    case "$theme" in
        "catppuccin")
            export FZF_DEFAULT_OPTS="--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 --height=60% --layout=reverse --border --margin=1 --padding=1"
            ;;
        "dracula")
            export FZF_DEFAULT_OPTS="--color=bg+:#44475a,bg:#282a36,spinner:#f1fa8c,hl:#50fa7b --color=fg:#f8f8f2,header:#ff79c6,info:#8be9fd,pointer:#f1fa8c --color=marker:#f1fa8c,fg+:#f8f8f2,prompt:#ff79c6,hl+:#50fa7b --height=60% --layout=reverse --border --margin=1 --padding=1"
            ;;
        "nord")
            export FZF_DEFAULT_OPTS="--color=bg+:#3b4252,bg:#2e3440,spinner:#88c0d0,hl:#a3be8c --color=fg:#d8dee9,header:#bf616a,info:#5e81ac,pointer:#88c0d0 --color=marker:#88c0d0,fg+:#eceff4,prompt:#bf616a,hl+:#a3be8c --height=60% --layout=reverse --border --margin=1 --padding=1"
            ;;
        *)
            # Tema por defecto
            export FZF_DEFAULT_OPTS="--height=60% --layout=reverse --border --margin=1 --padding=1"
            ;;
    esac
}

# Configuración de comandos con fallback inteligente
setup_fzf_commands() {
    # Comando por defecto con fallbacks
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .cache'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules'
    elif command -v rg >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*" --glob "!node_modules/*"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='find . -type d -name ".git" -prune -o -type d -name "node_modules" -prune -o -type d -print 2>/dev/null | sed "s|^./||"'
    else
        # Fallback a find estándar
        export FZF_DEFAULT_COMMAND='find . -type f -name ".*" -prune -o -type f -print 2>/dev/null | sed "s|^./||"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='find . -type d -name ".*" -prune -o -type d -print 2>/dev/null | sed "s|^./||"'
    fi
}

# Configuración completa de FZF
setup_fzf() {
    if [[ "$FZF_LOADED" == "true" ]]; then
        return 0
    fi
    
    if ! command -v fzf >/dev/null 2>&1; then
        echo "⚠️ FZF no está instalado" >&2
        return 1
    fi
    
    # Log si está disponible
    if command -v log_debug >/dev/null 2>&1; then
        log_debug "Setting up FZF integration"
    fi
    
    # Configurar colores
    setup_fzf_colors
    
    # Configurar comandos
    setup_fzf_commands
    
    # Cargar key bindings y completion
    local key_bindings_loaded=false
    local completion_loaded=false
    
    # Intentar cargar desde diferentes ubicaciones
    local fzf_locations=(
        "/usr/share/fzf"
        "/usr/local/share/fzf/shell"
        "$HOME/.fzf/shell"
        "/opt/homebrew/opt/fzf/shell"  # macOS Homebrew
    )
    
    for location in "${fzf_locations[@]}"; do
        if [[ -f "$location/key-bindings.bash" && "$key_bindings_loaded" == "false" ]]; then
            source "$location/key-bindings.bash"
            key_bindings_loaded=true
        fi
        
        if [[ -f "$location/completion.bash" && "$completion_loaded" == "false" ]]; then
            source "$location/completion.bash"
            completion_loaded=true
        fi
        
        if [[ "$key_bindings_loaded" == "true" && "$completion_loaded" == "true" ]]; then
            break
        fi
    done
    
    # Verificar que se cargaron correctamente
    if [[ "$key_bindings_loaded" == "false" ]]; then
        echo "⚠️ FZF key bindings no encontrados" >&2
    fi
    
    if [[ "$completion_loaded" == "false" ]]; then
        echo "⚠️ FZF completion no encontrado" >&2
    fi
    
    FZF_LOADED=true
    
    # Log si está disponible
    if command -v log_info >/dev/null 2>&1; then
        log_info "FZF integration loaded successfully"
    fi
}

# Funciones personalizadas de FZF
fzf_git_log() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "❌ No estás en un repositorio Git" >&2
        return 1
    fi
    
    git log --oneline --color=always | \
    fzf --ansi --preview 'git show --color=always {1}' \
        --preview-window 'right:60%' \
        --bind 'enter:execute(git show {1} | less -R)'
}

fzf_git_branch() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "❌ No estás en un repositorio Git" >&2
        return 1
    fi
    
    local branch
    branch=$(git branch -a --color=always | \
        grep -v '/HEAD\s' | \
        fzf --ansi --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {}) | head -20' \
            --bind 'enter:become(git checkout $(sed "s/.* //" <<< {}))'
    )
}

fzf_kill_process() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m --header='[kill:process]' | awk '{print $2}')
    
    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs kill -"${1:-9}"
    fi
}

fzf_cd_recent() {
    local dir
    # Usar historial de directorios si está disponible
    if command -v dirs >/dev/null 2>&1; then
        dir=$(dirs -p | fzf --preview 'ls -la {}' --preview-window 'right:60%')
    else
        # Fallback a directorios comunes
        dir=$(find . -type d -not -path '*/.*' | fzf --preview 'ls -la {}' --preview-window 'right:60%')
    fi
    
    if [[ -n "$dir" ]]; then
        cd "$dir" || return 1
    fi
}

# Aliases útiles
setup_fzf_aliases() {
    if command -v fzf >/dev/null 2>&1; then
        alias fzf-log='fzf_git_log'
        alias fzf-branch='fzf_git_branch'
        alias fzf-kill='fzf_kill_process'
        alias fzf-cd='fzf_cd_recent'
        
        # Preview con diferentes herramientas
        if command -v bat >/dev/null 2>&1; then
            export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=header,grid --line-range :300 {}'"
        elif command -v cat >/dev/null 2>&1; then
            export FZF_CTRL_T_OPTS="--preview 'head -300 {}'"
        fi
        
        if command -v tree >/dev/null 2>&1; then
            export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
        elif command -v ls >/dev/null 2>&1; then
            export FZF_ALT_C_OPTS="--preview 'ls -la {}'"
        fi
    fi
}

# Inicialización lazy
fzf_lazy_init() {
    if [[ "$FZF_LOADED" == "false" ]]; then
        setup_fzf && setup_fzf_aliases
    fi
}

# Key binding personalizado para inicialización lazy
if [[ $- == *i* ]]; then
    # Bind Ctrl+T a inicialización lazy + función original
    bind '"\C-t": "\C-e\C-ufzf_lazy_init && \C-m"'
fi

# Exportar funciones
export -f setup_fzf setup_fzf_colors setup_fzf_commands setup_fzf_aliases
export -f fzf_git_log fzf_git_branch fzf_kill_process fzf_cd_recent fzf_lazy_init
