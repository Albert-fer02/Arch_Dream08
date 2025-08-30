#!/bin/zsh
# =====================================================
# 🚀 FZF AVANZADO - ARCH DREAM
# =====================================================
# Productivo, elegante, sin sobre-ingeniería

[[ ! -x "$(command -v fzf)" ]] && { echo "⚠️ fzf required" >&2; return 1; }

# Limpiar aliases y funciones conflictivas
unalias ff fcd fh fg fs fk fb fp fe fhelp 2>/dev/null || true
unfunction ff fcd fh fg fs fk fb fp fe fzf_help 2>/dev/null || true

# Configurar bat theme
export BAT_THEME="Catppuccin Macchiato"

# =====================================================
# 🎨 CONFIGURACIÓN BASE
# =====================================================
export FZF_DEFAULT_OPTS="
    --height=70%
    --layout=reverse
    --border=rounded
    --info=inline
    --prompt='› '
    --pointer='▶'
    --marker='✓'
    --cycle
    --scroll-off=3
    --color=fg:#dee3e5,bg:#0e1416,hl:#83d3e3
    --color=fg+:#ffffff,bg+:#1c3439,hl+:#83d3e3
    --color=info:#e0c180,prompt:#d49a7a,pointer:#7fb3a8
    --color=marker:#c5a5d4,spinner:#6ab3c4,header:#a292d4
    --preview-window=right:55%:wrap
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-a:select-all,ctrl-d:deselect-all'
    --bind='ctrl-y:execute-silent(echo {} | wl-copy 2>/dev/null || echo {} | xclip -sel clip 2>/dev/null)'
"

# Comandos base optimizados
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob="!{.git,node_modules,.cache,target,dist}/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='find . -type d -not -path "*/\.*" -not -path "*/node_modules*" -not -path "*/target*" 2>/dev/null'

# =====================================================
# 🦇 PREVIEW INLINE
# =====================================================
export FZF_CTRL_T_OPTS='--preview "
    if [[ -f {} ]]; then
        echo \"📄 $(basename {}) ($(wc -l < {} 2>/dev/null || echo \"?\") lines)\"
        echo \"─────────────────────────────────────────────────────\"
        bat --style=numbers,header --color=always --line-range=:50 {} 2>/dev/null ||
        nl -ba {} | head -50 2>/dev/null ||
        head -50 {}
    else
        eza -la --icons --git {} 2>/dev/null || ls -la {}
    fi
"'

export FZF_ALT_C_OPTS='--preview "eza -la --icons --git {} 2>/dev/null || ls -la {}"'

# =====================================================
# 📁 FUNCIONES PRINCIPALES
# =====================================================

# Files - Navegador de archivos
ff() {
    local selected
    selected=$(eval "$FZF_DEFAULT_COMMAND" | fzf \
        --multi \
        --prompt="Files › " \
        --header="⏎ Edit | ⌃O Open | ⌃D Delete | Tab Multi-select" \
        --preview='
            if [[ -f {} ]]; then
                echo "📄 $(basename {}) ($(wc -l < {} 2>/dev/null || echo \"?\") lines)"
                echo "─────────────────────────────────────────────────────"
                bat --style=numbers,header --color=always --line-range=:50 {} 2>/dev/null ||
                nl -ba {} | head -50 2>/dev/null ||
                head -50 {}
            else
                eza -la --icons --git {} 2>/dev/null || ls -la {}
            fi' \
        --bind="ctrl-o:execute(xdg-open {} &)" \
        --bind="ctrl-d:execute(rm -i {})")
    
    [[ -n "$selected" ]] && echo "$selected"
}

# Directories - Cambio de directorio
fcd() {
    local dir
    dir=$(eval "$FZF_ALT_C_COMMAND" | fzf \
        --prompt="Dirs › " \
        --header="⏎ Change directory" \
        --preview="eza -la --icons --git {} 2>/dev/null || ls -la {}")
    
    [[ -n "$dir" ]] && { cd "$dir" && pwd && eza -la --icons 2>/dev/null || ls -la; }
}

# History - Historia de comandos
fh() {
    fc -rl 1 | awk '{$1=""; print substr($0,2)}' | awk '!seen[$0]++' | head -1000 | fzf \
        --prompt="History › " \
        --header="⏎ Execute | ⌃Y Copy" \
        --preview="echo 'Command: {}' | bat --language=bash --style=plain --color=always 2>/dev/null || echo 'Command: {}'"
}

# Git - Commits y workflow
fg() {
    git rev-parse --git-dir >/dev/null 2>&1 || { echo "❌ Not a git repo"; return 1; }
    
    git log --oneline --color=always --graph --max-count=200 | fzf \
        --ansi \
        --prompt="Git › " \
        --header="⏎ Show | ⌃D Diff" \
        --preview="echo {} | grep -o '[a-f0-9]\\{7,\\}' | head -1 | xargs git show --color=always --stat --no-patch" \
        --bind="ctrl-d:execute(echo {} | grep -o '[a-f0-9]\\{7,\\}' | head -1 | xargs git show | bat --language=diff --color=always 2>/dev/null || less)" |
    while IFS= read -r commit; do
        local hash=$(echo "$commit" | grep -o '[a-f0-9]\{7,\}' | head -1)
        [[ -n "$hash" ]] && git show --stat --no-patch "$hash"
    done
}

# Search - Buscar contenido
fs() {
    local query="${1:-}"
    rg --color=always --line-number --no-heading --smart-case "${query}" . 2>/dev/null | fzf \
        --ansi \
        --prompt="Search › " \
        --header="⏎ Edit at line | ⌃O Open file" \
        --delimiter : \
        --preview="bat --style=numbers --color=always --highlight-line {2} --line-range={2}:$((({2}+10))) {1} 2>/dev/null || nl -ba {1} | head -20" \
        --preview-window="right:55%:wrap:+{2}-5" \
        --bind="enter:execute(${EDITOR:-vim} {1} +{2})" \
        --bind="ctrl-o:execute(xdg-open {1} &)"
}

# Kill - Gestión de procesos
fk() {
    ps -ef | sed 1d | fzf \
        --multi \
        --prompt="Kill › " \
        --header="⏎ Kill | ⌃K Force kill | Tab Multi-select" \
        --preview="echo 'PID: {2} | USER: {1} | CMD: {8}'" \
        --bind="ctrl-k:execute(kill -9 {2} && echo Force killed: {2})" |
    while IFS= read -r process; do
        echo "$process" | awk '{print $2}' | xargs -r kill -TERM
    done
}

# Branches - Git branches
fb() {
    git rev-parse --git-dir >/dev/null 2>&1 || { echo "❌ Not a git repo"; return 1; }
    
    local branch
    branch=$(git branch -a --color=always | grep -v '/HEAD\s' | sort | fzf \
        --ansi \
        --prompt="Branch › " \
        --header="⏎ Checkout | ⌃D Delete" \
        --preview="git log --oneline --graph --color=always --max-count=20 {}" \
        --bind="ctrl-d:execute(git branch -d {} 2>/dev/null || git branch -D {})")
    
    [[ -n "$branch" ]] && git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Projects - Finder de proyectos
fp() {
    find "$HOME/Documentos/PROYECTOS" "$HOME/Projects" "$HOME/Code" "$HOME" -maxdepth 3 -type d -name ".git" 2>/dev/null |
    sed 's|/.git$||' | fzf \
        --prompt="Projects › " \
        --header="⏎ Open project" \
        --preview="eza -la --icons --git {} 2>/dev/null || ls -la {}" |
    while IFS= read -r project; do
        [[ -n "$project" ]] && { cd "$project" && pwd && eza -la --icons 2>/dev/null || ls -la; }
    done
}

# Edit - Archivos de configuración
fe() {
    printf "%s\n" \
        "$HOME/.zshrc" \
        "$HOME/.bashrc" \
        "$HOME/.vimrc" \
        "$HOME/.config/nvim/init.vim" \
        "$HOME/.config/kitty/kitty.conf" \
        "$HOME/.gitconfig" | 
    fzf \
        --prompt="Config › " \
        --header="⏎ Edit config file" \
        --preview='
            if [[ -f {} ]]; then
                echo "📄 $(basename {}) ($(wc -l < {} 2>/dev/null || echo \"?\") lines)"
                echo "─────────────────────────────────────────────────────"
                bat --style=numbers,header --color=always --line-range=:30 {} 2>/dev/null ||
                nl -ba {} | head -30 2>/dev/null ||
                head -30 {}
            else
                echo "File not found: {}"
            fi' | 
    xargs -r "${EDITOR:-vim}"
}

# =====================================================
# ⌨️ WIDGETS Y KEYBINDINGS
# =====================================================
if [[ -n "$ZSH_VERSION" ]]; then
    # Widgets
    _fzf_files_widget() { local result=$(ff); [[ -n "$result" ]] && LBUFFER="${EDITOR:-vim} $result" && zle accept-line; zle reset-prompt; }
    _fzf_history_widget() { local cmd=$(fh); [[ -n "$cmd" ]] && LBUFFER="$cmd" && zle reset-prompt; }
    _fzf_dirs_widget() { fcd; zle reset-prompt; }
    _fzf_search_widget() { fs; zle reset-prompt; }
    _fzf_git_widget() { fg; zle reset-prompt; }

    # Registrar widgets
    zle -N _fzf_files_widget
    zle -N _fzf_history_widget
    zle -N _fzf_dirs_widget
    zle -N _fzf_search_widget
    zle -N _fzf_git_widget

    # Keybindings
    bindkey '^T' _fzf_files_widget      # Ctrl+T - Files
    bindkey '^R' _fzf_history_widget    # Ctrl+R - History  
    bindkey '^[c' _fzf_dirs_widget      # Alt+C - Directories
    bindkey '^[s' _fzf_search_widget    # Alt+S - Search
    bindkey '^[g' _fzf_git_widget       # Alt+G - Git
fi

# =====================================================
# 📚 HELP
# =====================================================
fzf_help() {
    cat << 'EOF'
🚀 FZF Avanzado - Arch Dream

FUNCIONES:
  ff     - 📁 Files (multi-select, edit, open, delete)
  fcd    - 📂 Change directory with preview
  fh     - 📜 History (deduplicated, syntax highlight)
  fg     - 🌳 Git commits (show, diff)
  fs     - 🔍 Search content (jump to line)
  fb     - 🌿 Git branches (checkout, delete)
  fk     - 💀 Kill processes (multi-select)
  fp     - 🚀 Projects (Git repos finder)
  fe     - ⚙️  Edit config files

KEYBINDINGS:
  Ctrl+T    - Files | Ctrl+R - History | Alt+C - Dirs
  Alt+S     - Search | Alt+G - Git

CONTROLS:
  Ctrl+/ - Toggle preview | Ctrl+Y - Copy | Tab - Multi-select
  Ctrl+A - Select all | Ctrl+D - Deselect all

🦇 Bat preview | 🎯 Workflow optimizado | 🧹 Sin sobre-ingeniería
EOF
}

alias fhelp='fzf_help'