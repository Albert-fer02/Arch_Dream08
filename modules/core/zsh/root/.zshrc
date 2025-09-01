#!/bin/zsh
# =====================================================
# 🚀 ROOT USER OPTIMIZED ZSH CONFIGURATION
# =====================================================
# Configuración optimizada y minimalista para root
# Basada en Arch Dream v4.3 con optimizaciones específicas
# =====================================================

# =====================================================
# 🔧 CONFIGURACIÓN BASE OPTIMIZADA PARA ROOT
# =====================================================

# Variables de entorno esenciales para root
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

# Configuración de idioma
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Variables específicas de Arch Dream
export ARCH_DREAM_ROOT="/home/dreamcoder08/Documentos/PROYECTOS/Arch_Dream08"
export ARCH_DREAM_VERSION="5.0.0"
export ARCH_DREAM_PROFILE="admin"

# PATH optimizado para root con integración Arch Dream
typeset -U path
path=(
    "$ARCH_DREAM_ROOT"
    "/usr/local/sbin"
    "/usr/local/bin"
    "/usr/sbin"
    "/usr/bin"
    "/sbin"
    "/bin"
    $path
)
export PATH

# Variables XDG para root
export XDG_CONFIG_HOME="/root/.config"
export XDG_DATA_HOME="/root/.local/share"
export XDG_CACHE_HOME="/root/.cache"

# Crear directorios necesarios
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" 2>/dev/null

# =====================================================
# 📊 CONFIGURACIÓN DE HISTORIAL OPTIMIZADA
# =====================================================

HISTFILE=/root/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt appendhistory
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify

# =====================================================
# ⚡ CONFIGURACIÓN ZSH OPTIMIZADA
# =====================================================

# Autocompletado optimizado
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zcompdump"

# Configuración de corrección (más conservadora para root)
setopt correct

# Navegación optimizada
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

# =====================================================
# 🎨 PROMPT OPTIMIZADO PARA ROOT
# =====================================================

# Prompt minimalista y claro para root
autoload -Uz colors && colors
PS1='%{$fg[red]%}[ROOT]%{$reset_color%} %{$fg[blue]%}%~%{$reset_color%} %{$fg[red]%}#%{$reset_color%} '
RPS1='%{$fg[yellow]%}%D{%H:%M:%S}%{$reset_color%}'

# =====================================================
# 🛠️ ALIASES OPTIMIZADOS PARA ROOT
# =====================================================

# Navegación
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Operaciones de archivos con confirmación (crítico para root)
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -I --preserve-root'
alias mkdir='mkdir -pv'
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'

# Listado optimizado
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias la='eza -la --icons --group-directories-first'
else
    alias ll='ls -l --color=auto'
    alias la='ls -la --color=auto'
fi

# Herramientas modernas
if command -v bat &>/dev/null; then
    alias cat='bat --style=plain --paging=never'
fi

if command -v btop &>/dev/null; then
    alias top='btop'
elif command -v htop &>/dev/null; then
    alias top='htop'
fi

# Editor
if command -v nvim &>/dev/null; then
    alias vim='nvim'
    alias vi='nvim'
fi

# Sistema crítico
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias ports='ss -tuln'
alias services='systemctl list-units --type=service'

# Pacman optimizado para root
alias pac='pacman'
alias pacs='pacman -Ss'
alias paci='pacman -S'
alias pacu='pacman -Syu'
alias pacr='pacman -Rs'

# Yay (si está disponible)
if command -v yay &>/dev/null; then
    alias yayi='yay -S'
    alias yays='yay -Ss'
    alias yayu='yay -Syu'
fi

# Alias específicos de Arch Dream
alias ad='arch-dream'
alias ad-status='arch-dream status'
alias ad-doctor='arch-dream doctor'
alias ad-update='arch-dream update'
alias ad-clean='arch-dream clean'
alias ad-list='arch-dream list'
alias ad-install='arch-dream install'
alias ad-profile='arch-dream profile'

# Navegación rápida del proyecto
alias cd-ad='cd-arch-dream'
alias ls-ad='ls -la "$ARCH_DREAM_ROOT"'

# Utilidades
alias c='clear'
alias h='history'
alias reload='source /root/.zshrc'
alias now='date "+%Y-%m-%d %H:%M:%S"'

# =====================================================
# 🔧 FUNCIONES OPTIMIZADAS PARA ROOT
# =====================================================

# Integración con Arch Dream CLI
arch-dream() {
    if [[ -x "$ARCH_DREAM_ROOT/arch-dream" ]]; then
        "$ARCH_DREAM_ROOT/arch-dream" "$@"
    else
        echo "❌ Arch Dream CLI no encontrado en: $ARCH_DREAM_ROOT/arch-dream"
        return 1
    fi
}

# Función rápida para acceder al proyecto
cd-arch-dream() {
    cd "$ARCH_DREAM_ROOT"
    echo "📁 Arch Dream Root: $(pwd)"
}

# Crear directorio y entrar
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Backup con timestamp para archivos críticos
backup() {
    local filename="$1"
    [[ -z "$filename" ]] && { echo "Uso: backup <archivo>"; return 1; }
    local backup_name="${filename}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$filename" "$backup_name"
    echo "✅ Backup creado: $backup_name"
}

# Función de limpieza del sistema
system-cleanup() {
    echo "🧹 Limpiando sistema..."
    pacman -Sc --noconfirm
    journalctl --vacuum-time=7d
    echo "✅ Sistema limpiado"
}

# Función de información del sistema con integración Arch Dream
sysinfo() {
    echo "🖥️  INFORMACIÓN DEL SISTEMA - ARCH DREAM"
    echo "════════════════════════════════════════"
    echo "Usuario: $(whoami)"
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime -p)"
    echo "Kernel: $(uname -r)"
    echo "Memoria: $(free -h | awk '/^Mem:/ {print $3"/"$2}')"
    echo "Disco: $(df -h / | awk 'NR==2 {print $3"/"$2" ("$5")"}')"
    echo "────────────────────────────────────────"
    echo "Arch Dream: v$ARCH_DREAM_VERSION"
    echo "Perfil: $ARCH_DREAM_PROFILE"
    echo "Ruta: $ARCH_DREAM_ROOT"
    if [[ -x "$ARCH_DREAM_ROOT/arch-dream" ]]; then
        echo "CLI: ✅ Disponible"
    else
        echo "CLI: ❌ No encontrado"
    fi
}

# Función para servicios del sistema
service-status() {
    [[ -z "$1" ]] && { echo "Uso: service-status <servicio>"; return 1; }
    systemctl status "$1"
}

# Función de monitoreo de logs
logs() {
    local service="$1"
    if [[ -n "$service" ]]; then
        journalctl -u "$service" -f
    else
        journalctl -f
    fi
}

# =====================================================
# 🔍 CONFIGURACIÓN DE COMPLETADO AVANZADO
# =====================================================

# Completado inteligente
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' group-name ''

# =====================================================
# 🔒 CONFIGURACIÓN DE SEGURIDAD
# =====================================================

# Configuración de colores para ls con énfasis en permisos
export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

# Configuración de less con colores
export LESS='-R --use-color -Dd+r$Du+b$'

# =====================================================
# ⚡ CONFIGURACIÓN FINAL Y OPTIMIZACIONES
# =====================================================

# Keybindings esenciales
bindkey '^R' history-incremental-search-backward
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Mensaje de bienvenida para root con información de Arch Dream
echo "🔑 Root user session initiated - $(date '+%Y-%m-%d %H:%M:%S')"
echo "🚀 Arch Dream v$ARCH_DREAM_VERSION ($ARCH_DREAM_PROFILE profile)"
echo "⚠️  Remember: With great power comes great responsibility"
echo "💡 Usa 'ad' para acceder a Arch Dream CLI o 'sysinfo' para info del sistema"

# Función de salida segura
exit_root() {
    echo "👋 Saliendo de sesión root..."
    exit
}
alias quit='exit_root'