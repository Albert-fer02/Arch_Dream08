#!/bin/zsh
# =====================================================
# �� ALIASES ESENCIALES PARA PRODUCTIVIDAD DIARIA
# =====================================================

# =====================================================
# 🚀 NAVEGACIÓN Y ARCHIVOS
# =====================================================

# Navegación rápida
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Operaciones de archivos con confirmación
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -I'
alias mkdir='mkdir -pv'

# Listado de archivos inteligente
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias la='eza -la --icons --group-directories-first'
    alias tree='eza --tree --icons'
elif command -v exa &>/dev/null; then
    alias ls='exa --icons --group-directories-first'
    alias ll='exa -l --icons --group-directories-first'
    alias la='exa -la --icons --group-directories-first'
    alias tree='exa --tree --icons'
else
    alias ll='ls -l --color=auto'
    alias la='ls -la --color=auto'
fi

# =====================================================
# 🛠️ HERRAMIENTAS MODERNAS
# =====================================================

# Mejoras de comandos básicos
if command -v bat &>/dev/null; then
    alias cat='bat --style=auto --paging=never'
fi

if command -v btop &>/dev/null; then
    alias htop='btop'
    alias top='btop'
elif command -v htop &>/dev/null; then
    alias top='htop'
fi

if command -v rg &>/dev/null; then
    alias grep='rg --smart-case'
fi

if command -v fd &>/dev/null; then
    alias find='fd --hidden --follow'
fi

# =====================================================
# 📝 EDITOR PRINCIPAL
# =====================================================

# Editor unificado
if command -v nvim &>/dev/null; then
    alias vim='nvim'
    alias vi='nvim'
elif command -v vim &>/dev/null; then
    alias vi='vim'
fi

# =====================================================
# 🐙 GIT ESENCIAL
# =====================================================

# Git básico (solo lo más usado)
alias g='git'
alias gs='git status -s'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline -10'

# =====================================================
# 🐳 DOCKER BÁSICO
# =====================================================

# Docker esencial
if command -v docker &>/dev/null; then
    alias d='docker'
    alias dc='docker-compose'
    alias dps='docker ps'
    alias di='docker images'
fi

# =====================================================
# 📦 GESTIÓN DE PAQUETES
# =====================================================

# Arch Linux esencial
if command -v pacman &>/dev/null; then
    alias pac='sudo pacman'
    alias pacs='pacman -Ss'
    alias paci='sudo pacman -S'
    alias pacu='sudo pacman -Syu'
fi

if command -v yay &>/dev/null; then
    alias yayi='yay -S'
    alias yays='yay -Ss'
    alias yayu='yay -Syu'
fi

# =====================================================
# 💻 SISTEMA Y RED
# =====================================================

# Comandos del sistema
alias c='clear'
alias h='history'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ports='ss -tuln'
alias myip='curl -s ifconfig.me'

# =====================================================
# 🔧 DESARROLLO BÁSICO
# =====================================================

# Python básico
alias py='python3'
alias serve='python3 -m http.server'

# Node.js básico
if command -v npm &>/dev/null; then
    alias ni='npm install'
    alias nr='npm run'
fi

# =====================================================
# 🧹 UTILIDADES
# =====================================================

# Limpieza y mantenimiento
alias reload='source ~/.zshrc'
alias now='date "+%Y-%m-%d %H:%M:%S"'
