#!/bin/zsh
# =====================================================
# 🚀 FZF MINIMALISTA - ARCH DREAM
# =====================================================
# Un solo archivo, ~150 líneas, solo lo esencial

# Verificar que FZF esté instalado
if ! command -v fzf >/dev/null 2>&1; then
    echo "⚠️ FZF no está instalado" >&2
    return 1
fi

# =====================================================
# 🎨 TEMA DREAMCODER
# =====================================================
export FZF_DEFAULT_OPTS="
    --height=50% 
    --layout=reverse 
    --border=rounded
    --margin=1
    --padding=1
    --info=inline
    --prompt='🔍 › '
    --pointer='▶'
    --marker='✓'
    --color=bg:#0e1416
    --color=fg:#dee3e5
    --color=hl:#83d3e3
    --color=fg+:#ffffff
    --color=bg+:#1c3439
    --color=hl+:#83d3e3
    --color=info:#e0c180
    --color=prompt:#d49a7a
    --color=pointer:#7fb3a8
    --color=marker:#c5a5d4
    --color=spinner:#6ab3c4
    --color=header:#a292d4
    --preview-window=right:50%:wrap:hidden
    --bind='ctrl-/:toggle-preview'
"

# =====================================================
# ⚡ COMANDOS BASE
# =====================================================
if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .cache'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules --exclude .cache'
elif command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*" --glob "!node_modules/*" --glob "!.cache/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='find . -type d \( -name ".git" -o -name "node_modules" -o -name ".cache" \) -prune -o -type d -print 2>/dev/null'
else
    export FZF_DEFAULT_COMMAND='find . -type f \( -path "*/\.git/*" -o -path "*/node_modules/*" -o -path "*/\.cache/*" \) -prune -o -type f -print 2>/dev/null'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='find . -type d \( -name ".git" -o -name "node_modules" -o -name ".cache" \) -prune -o -type d -print 2>/dev/null'
fi

# Preview commands
if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :100 {} 2>/dev/null'"
else
    export FZF_CTRL_T_OPTS="--preview 'head -100 {} 2>/dev/null'"
fi

if command -v exa >/dev/null 2>&1; then
    export FZF_ALT_C_OPTS="--preview 'exa -la --icons {} 2>/dev/null'"
else
    export FZF_ALT_C_OPTS="--preview 'ls -la {} 2>/dev/null'"
fi

# =====================================================
# 🔧 FUNCIONES ESENCIALES (Solo 5)
# =====================================================

# 1. Archivos con preview
fzf_files() {
    local selected
    selected=$(eval "${FZF_DEFAULT_COMMAND:-find . -type f}" 2>/dev/null | fzf \
        --multi \
        --prompt="📁 Files › " \
        --header="Enter: Seleccionar | Ctrl-O: Abrir" \
        --preview="bat --style=numbers --color=always --line-range :100 {} 2>/dev/null || head -100 {}" \
        --bind="ctrl-o:execute(xdg-open {} 2>/dev/null || open {} 2>/dev/null)")
    
    if [[ -n $selected ]]; then
        echo "$selected"
    fi
}

# 2. Navegación directorios  
fzf_dirs() {
    local selected
    selected=$(eval "${FZF_ALT_C_COMMAND:-find . -type d}" 2>/dev/null | fzf \
        --prompt="📂 Directories › " \
        --header="Enter: Cambiar directorio" \
        --preview="exa -la --icons {} 2>/dev/null || ls -la {} 2>/dev/null")
    
    if [[ -n $selected ]]; then
        cd "$selected" || return 1
        echo "📂 $(pwd)"
        command -v exa >/dev/null 2>&1 && exa -la --icons || ls -la --color=always
    fi
}

# 3. Historia comandos
fzf_history() {
    local selected
    if [[ -n "$ZSH_VERSION" ]]; then
        selected=$(fc -rl 1 2>/dev/null | awk '{$1=""; print substr($0,2)}' | awk '!seen[$0]++' | fzf \
            --prompt="📜 History › " \
            --header="Enter: Ejecutar | Ctrl-Y: Copiar" \
            --preview="echo 'Comando: {}' | bat --style=plain --color=always -l bash 2>/dev/null || echo 'Comando: {}'" \
            --bind="ctrl-y:execute-silent(echo {} | xclip -selection clipboard 2>/dev/null || true)")
    else
        selected=$(history | tail -1000 | awk '{$1=""; print substr($0,2)}' | awk '!seen[$0]++' | fzf \
            --prompt="📜 History › " \
            --header="Enter: Ejecutar" \
            --preview="echo 'Comando: {}'")
    fi
    
    if [[ -n $selected ]]; then
        echo "$selected"
    fi
}

# 4. Git log básico
fzf_git() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "❌ No estás en un repositorio Git" >&2
        return 1
    fi
    
    local selected
    selected=$(git log --oneline --color=always --graph --decorate --max-count=100 2>/dev/null | fzf \
        --ansi \
        --prompt="🌳 Git › " \
        --header="Enter: Show | Ctrl-D: Diff" \
        --preview="echo {} | grep -o '[a-f0-9]\\{7,\\}' | head -1 | xargs -I {} git show --color=always --stat {}" \
        --bind="ctrl-d:execute(echo {} | grep -o '[a-f0-9]\\{7,\\}' | head -1 | xargs -I {} git show --color=always {} | less -R)")
    
    if [[ -n $selected ]]; then
        local commit_hash=$(echo "$selected" | grep -o '[a-f0-9]\{7,\}' | head -1)
        if [[ -n $commit_hash ]]; then
            git show --stat "$commit_hash"
        fi
    fi
}

# 5. Kill procesos
fzf_processes() {
    local selected
    selected=$(ps aux 2>/dev/null | sed 1d | fzf \
        --multi \
        --prompt="⚡ Processes › " \
        --header="Enter: Seleccionar | Ctrl-K: Kill" \
        --preview="echo 'PID: {2} | USER: {1} | CPU: {3}% | MEM: {4}% | COMMAND: {11}' | fold -w 60" \
        --bind="ctrl-k:execute(kill -TERM {2} 2>/dev/null && echo 'Killed {2}' || echo 'Failed to kill {2}')")
    
    if [[ -n $selected ]]; then
        local pids=($(echo "$selected" | awk '{print $2}'))
        if [[ ${#pids[@]} -gt 0 ]]; then
            echo "🔄 Terminando procesos seleccionados..."
            for pid in "${pids[@]}"; do
                local cmd=$(ps -p "$pid" -o comm= 2>/dev/null || echo "unknown")
                echo "  Killing: $cmd (PID: $pid)"
                kill -TERM "$pid" 2>/dev/null && echo "    ✅ Done" || echo "    ❌ Error"
            done
        fi
    fi
}

# =====================================================
# 🎯 WIDGETS ZSH
# =====================================================

# Historia widget
fzf_history_widget() {
    local selected
    selected=$(fzf_history)
    if [[ -n $selected ]]; then
        LBUFFER="$selected"
        zle reset-prompt
    fi
}
zle -N fzf_history_widget

# Archivos widget
fzf_files_widget() {
    local selected
    selected=$(fzf_files)
    if [[ -n $selected ]]; then
        # Si múltiples archivos, separarlos correctamente
        if [[ $(echo "$selected" | wc -l) -gt 1 ]]; then
            LBUFFER="${EDITOR:-vim} $(echo "$selected" | tr '\n' ' ')"
        else
            LBUFFER="${EDITOR:-vim} $selected"
        fi
        zle accept-line
    fi
    zle reset-prompt
}
zle -N fzf_files_widget

# Directorios widget
fzf_dirs_widget() {
    local selected
    selected=$(eval "${FZF_ALT_C_COMMAND:-find . -type d}" 2>/dev/null | fzf \
        --prompt="📂 Directories › " \
        --header="Enter: Cambiar directorio" \
        --preview="exa -la --icons {} 2>/dev/null || ls -la {} 2>/dev/null")
    
    if [[ -n $selected ]]; then
        cd "$selected" 2>/dev/null
        zle reset-prompt
        # Mostrar contenido después del cambio
        command -v exa >/dev/null 2>&1 && exa -la --icons || ls -la --color=always
    fi
}
zle -N fzf_dirs_widget

# Procesos widget  
fzf_processes_widget() {
    local result
    result=$(fzf_processes)
    zle reset-prompt
}
zle -N fzf_processes_widget

# =====================================================
# ⌨️ KEYBINDINGS (Solo 4 esenciales)
# =====================================================
# Verificar que estamos en ZSH
if [[ -n "$ZSH_VERSION" ]]; then
    bindkey '^T' fzf_files_widget      # Ctrl+T - Archivos
    bindkey '^R' fzf_history_widget    # Ctrl+R - Historia  
    bindkey '^[c' fzf_dirs_widget      # Alt+C - Directorios
    bindkey '^[p' fzf_processes_widget # Alt+P - Procesos (evitar conflicto con Ctrl+P)
fi

# =====================================================
# 📝 ALIASES SIMPLES
# =====================================================
alias ff='fzf_files'
alias fd='fzf_dirs' 
alias fh='fzf_history'
alias fg='fzf_git'
alias fp='fzf_processes'

# =====================================================
# 📚 AYUDA MINIMALISTA
# =====================================================
fzf_help() {
    cat << 'EOF'
🚀 FZF Minimalista - Arch Dream

KEYBINDINGS:
  Ctrl+T  - 📁 Archivos con preview y edición
  Ctrl+R  - 📜 Historia comandos con ejecución  
  Alt+C   - 📂 Navegación directorios con cd
  Alt+P   - ⚡ Kill procesos multi-select

ALIASES:
  ff      - Find files (función standalone)
  fd      - Find directories (función standalone)
  fh      - Find history (función standalone)
  fg      - Find git commits (función standalone)
  fp      - Find processes (función standalone)

CONTROLES INTERNOS:
  Enter      - Seleccionar/ejecutar
  Tab        - Multi-select
  Ctrl+/     - Toggle preview
  Ctrl+Y     - Copiar al clipboard (donde disponible)
  Ctrl+O     - Abrir con app predeterminada
  Ctrl+K     - Kill proceso (en fp/Alt+P)
  Ctrl+D     - Git diff (en fg)

💡 Solo funcionalidades esenciales para productividad diaria
EOF
}

alias fzf-help='fzf_help'