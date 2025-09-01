# =====================================================
# 🚀 ARCH DREAM - BASH CONFIGURATION
# =====================================================
# Configuración optimizada para Arch Linux
# Simple, rápida y práctica
# =====================================================

# Return if not interactive
[[ $- != *i* ]] && return

# =====================================================
# 🔧 BASH OPTIONS
# =====================================================

# History
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend
shopt -s histverify

# Navigation
shopt -s autocd
shopt -s cdspell
shopt -s dirspell
shopt -s globstar

# Completion
shopt -s checkwinsize
shopt -s expand_aliases

# =====================================================
# 🌐 ENVIRONMENT VARIABLES
# =====================================================

export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export BROWSER='firefox'

# Arch Dream specific
export ARCH_DREAM_PROFILE="${ARCH_DREAM_PROFILE:-user}"
export ARCH_DREAM_VERSION="6.0"

# Colors
export GREP_COLOR='1;32'
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# =====================================================
# 🎨 PROMPT
# =====================================================

# Simple, clean prompt
if [[ "$EUID" -eq 0 ]]; then
    # Root prompt (red)
    PS1='\[\e[1;31m\][\u@\h \W]\$\[\e[0m\] '
else
    # User prompt (green/blue)
    PS1='\[\e[1;32m\][\u@\h\[\e[0m\] \[\e[1;34m\]\W\[\e[1;32m\]]\$\[\e[0m\] '
fi

# =====================================================
# 📂 ALIASES
# =====================================================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias -- -='cd -'

# File operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'
alias mkdir='mkdir -pv'

# Listing (prefer eza if available)
if command -v eza &>/dev/null; then
    alias ls='eza --group-directories-first'
    alias ll='eza -l --group-directories-first'
    alias la='eza -la --group-directories-first'
    alias tree='eza --tree'
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -l'
    alias la='ls -la'
fi

# Modern tools
command -v bat &>/dev/null && alias cat='bat --style=plain'
command -v btop &>/dev/null && alias top='btop' || {
    command -v htop &>/dev/null && alias top='htop'
}
command -v rg &>/dev/null && alias grep='rg'
command -v fd &>/dev/null && alias find='fd'

# System
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ports='ss -tuln'
alias services='systemctl list-units --type=service --state=running'

# Pacman (Arch Linux)
alias pac='sudo pacman'
alias pacs='pacman -Ss'
alias paci='sudo pacman -S'
alias pacu='sudo pacman -Syu'
alias pacr='sudo pacman -Rs'
alias paco='sudo pacman -Rns $(pacman -Qtdq)'  # Remove orphans

# AUR (if yay is available)
if command -v yay &>/dev/null; then
    alias yayi='yay -S'
    alias yays='yay -Ss'
    alias yayu='yay -Syu'
fi

# Git
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

# Utilities
alias c='clear'
alias h='history'
alias j='jobs -l'
alias which='type -a'
alias reload='source ~/.bashrc'
alias edit='$EDITOR'

# =====================================================
# 🔧 FUNCTIONS
# =====================================================

# Create directory and enter it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive types
extract() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"   ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1";;
            *.7z)        7z x "$1"      ;;
            *)           echo "Cannot extract '$1'" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick backup with timestamp
backup() {
    cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"
}

# System info
sysinfo() {
    echo "🖥️  System Information"
    echo "===================="
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3"/"$2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $3"/"$2" ("$5")"}')"
}

# =====================================================
# 🚀 COMPLETION & PLUGINS
# =====================================================

# Enable programmable completion
if ! shopt -oq posix; then
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
        source /etc/bash_completion
    fi
fi

# FZF integration (if available)
if [[ -f /usr/share/fzf/key-bindings.bash ]]; then
    source /usr/share/fzf/key-bindings.bash
    source /usr/share/fzf/completion.bash
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

# =====================================================
# 🎉 WELCOME MESSAGE
# =====================================================

# Show welcome message (only on first shell)
if [[ -z "$ARCH_DREAM_SHELL_LOADED" ]]; then
    export ARCH_DREAM_SHELL_LOADED=1
    
    # Show fastfetch if available
    if command -v fastfetch &>/dev/null && [[ -z "$TMUX" ]]; then
        fastfetch --config ~/.config/fastfetch/config.jsonc 2>/dev/null || fastfetch 2>/dev/null
    fi
    
    echo "🚀 Arch Dream v$ARCH_DREAM_VERSION - Bash configured"
fi