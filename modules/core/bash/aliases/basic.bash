#!/bin/bash
# =====================================================
# 📂 ALIASES BÁSICOS PARA BASH - ARCH DREAM v4.3
# =====================================================

# Navegación esencial
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'
alias ~='cd ~'

# Listado de archivos (prioridad: eza > exa > ls tradicional)
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first --git'
    alias la='eza -la --icons --group-directories-first --git'
    alias tree='eza --tree --icons'
elif command -v exa &>/dev/null; then
    alias ls='exa --icons --group-directories-first'
    alias ll='exa -l --icons --group-directories-first --git'
    alias la='exa -la --icons --group-directories-first --git'
    alias tree='exa --tree --icons'
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -l --color=auto'
    alias la='ls -la --color=auto'
fi

# Operaciones de archivos con confirmación (seguridad)
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -I --preserve-root'
alias mkdir='mkdir -pv'

# Herramientas básicas del sistema
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'

# Herramientas modernas (solo si están disponibles)
if command -v bat &>/dev/null; then
    alias cat='bat --style=auto --paging=never'
fi

if command -v htop &>/dev/null; then
    alias top='htop'
fi

if command -v rg &>/dev/null; then
    alias grep='rg --smart-case'
fi

# Aliases de productividad esenciales
alias c='clear'
alias h='history'
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'

# Editor principal
if command -v nvim &>/dev/null; then
    alias vim='nvim'
    alias vi='nvim'
elif command -v vim &>/dev/null; then
    alias vi='vim'
fi

# Git básico
alias g='git'
alias gst='git status'
alias gl='git log --oneline -10'

# Compresión
alias tgz='tar -czf'
alias untgz='tar -xzf'

# Red básica
alias ports='ss -tuln'
alias ping='ping -c 5'

# Memoria y CPU
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3 | head -10'

# Systemctl (solo aliases esenciales)
alias sc='systemctl'
alias scu='systemctl --user'
alias scs='sudo systemctl start'
alias sct='sudo systemctl stop'
alias scr='sudo systemctl restart'
alias scstat='systemctl status'

# Gestor de paquetes
if command -v yay &>/dev/null; then
    alias install='yay -S'
    alias search='yay -Ss'
    alias remove='yay -R'
    alias update='yay -Syu'
elif command -v pacman &>/dev/null; then
    alias install='sudo pacman -S'
    alias search='pacman -Ss'
    alias remove='sudo pacman -R'
    alias update='sudo pacman -Syu'
fi

# Reload simple
alias reload='source ~/.bashrc'
