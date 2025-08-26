#!/bin/zsh
# =====================================================
# 🚀 ZSH MODULAR + OH-MY-ZSH - ARCH DREAM v4.3
# =====================================================
# Configuración híbrida ordenada: Arch Dream + Oh-my-zsh
# Powerlevel10k Maximalist Masterpiece integrado
# Sistema completamente organizado y modular
# =====================================================

# =====================================================
# 🏗️ CONFIGURACIÓN BASE DEL SISTEMA
# =====================================================

# Directorio base del proyecto Arch Dream
export ARCH_DREAM_ROOT="$HOME/Documentos/PROYECTOS/Arch_Dream08"
export ARCH_DREAM_ZSH_DIR="$ARCH_DREAM_ROOT/modules/core/zsh"
export ARCH_DREAM_CONFIG_DIR="$HOME/.config/zsh"

# Crear directorios de cache si no existen
mkdir -p "$HOME/.cache/arch-dream"/{logs,cache,tmp} 2>/dev/null || true

# =====================================================
# 🛡️ INICIALIZACIÓN SEGURA ARCH DREAM
# =====================================================

# Función simple para cargar archivos de manera segura
safe_source() {
    local file="$1"
    if [[ -f "$file" && -r "$file" ]]; then
        source "$file" 2>/dev/null || true
    fi
}

# Cargar configuración base de Arch Dream si existe
safe_source "$ARCH_DREAM_CONFIG_DIR/config/shell-base.zsh"
safe_source "$ARCH_DREAM_CONFIG_DIR/common/error-handling.sh"

# =====================================================
# 🎯 OH-MY-ZSH CONFIGURATION
# =====================================================

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Tema de Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins recomendados para productividad
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    fzf
    zoxide
    atuin
)

# Cargar Oh-my-zsh
source $ZSH/oh-my-zsh.sh

# =====================================================
# 🎨 POWERLEVEL10K MAXIMALIST MASTERPIECE
# =====================================================

# Cargar configuración maximalista personalizada
safe_source "$ARCH_DREAM_ZSH_DIR/powerlevel10k-maximalist.zsh"

# =====================================================
# 🚀 CONFIGURACIÓN MODULAR ARCH DREAM
# =====================================================

# Cargar configuración de entorno
safe_source "$ARCH_DREAM_CONFIG_DIR/config/environment.zsh"
safe_source "$ARCH_DREAM_CONFIG_DIR/config/history.zsh"
safe_source "$ARCH_DREAM_CONFIG_DIR/config/completion.zsh"

# Cargar aliases personalizados
safe_source "$ARCH_DREAM_ZSH_DIR/aliases/basic.zsh"
safe_source "$ARCH_DREAM_ZSH_DIR/aliases/git.zsh"
safe_source "$ARCH_DREAM_ZSH_DIR/aliases/system.zsh"

# Cargar funciones personalizadas
safe_source "$ARCH_DREAM_ZSH_DIR/functions/basic.zsh"
safe_source "$ARCH_DREAM_ZSH_DIR/functions/arch.zsh"
safe_source "$ARCH_DREAM_ZSH_DIR/functions/redteam.zsh"

# Cargar configuración de plugins
safe_source "$ARCH_DREAM_ZSH_DIR/plugins/plugin-manager.zsh"

# Cargar configuración de keybindings
safe_source "$ARCH_DREAM_ZSH_DIR/keybindings/keybindings.zsh"

# Cargar configuración de UI
safe_source "$ARCH_DREAM_ZSH_DIR/ui/welcome.zsh"

# =====================================================
# 🔧 CONFIGURACIÓN ADICIONAL DEL SISTEMA
# =====================================================

# Configuración de historial
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Configuración de completado
autoload -Uz compinit
compinit

# Configuración de corrección de comandos
setopt correct
setopt correct_all

# Configuración de navegación
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

# Configuración de búsqueda en historial
bindkey '^R' history-incremental-search-backward

# =====================================================
# 🌟 CONFIGURACIÓN FINAL Y MENSAJE DE BIENVENIDA
# =====================================================

# Configuración de variables de entorno adicionales
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

# Configuración de colores para ls
export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

# Mensaje de confirmación
echo "🚀 Arch Dream + Oh-my-zsh + Powerlevel10k Maximalist activado!"
echo "🌟 Sistema completamente organizado y modular"
echo "📁 Configuración ubicada en: $ARCH_DREAM_ZSH_DIR"
