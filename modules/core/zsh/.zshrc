# Ejecutar fastfetch ANTES del prompt instantáneo si no estamos en TMUX/screen
if [[ -z "${TMUX:-}${STY:-}" ]]; then
    if command -v fastfetch &>/dev/null; then
        local config_file="$HOME/.config/fastfetch/config.jsonc"
        if [[ -f "$config_file" ]]; then
            fastfetch --config "$config_file" 2>/dev/null || fastfetch 2>/dev/null || true
        else
            fastfetch 2>/dev/null || true
        fi
    elif command -v neofetch &>/dev/null; then
        neofetch 2>/dev/null || true
    fi
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# Función para crear directorios de cache solo cuando sea necesario
ensure_cache_dirs() {
    if [[ ! -d "$HOME/.cache/arch-dream" ]]; then
        mkdir -p "$HOME/.cache/arch-dream"/{logs,cache,tmp} 2>/dev/null || true
    fi
}

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

# Plugins recomendados para productividad (solo los instalados)
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    fzf
    zoxide
)

# Cargar Oh-my-zsh
source $ZSH/oh-my-zsh.sh

# =====================================================
# 🎨 POWERLEVEL10K MAXIMALIST MASTERPIECE
# =====================================================

# NOTA: La configuración personalizada se carga DESPUÉS de p10k.zsh
# para sobrescribir la configuración por defecto

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
# Warp aliases integrados en fzf-unified.zsh

# Cargar funciones personalizadas
safe_source "$ARCH_DREAM_ZSH_DIR/functions/basic.zsh"
safe_source "$ARCH_DREAM_ZSH_DIR/functions/arch.zsh"
safe_source "$ARCH_DREAM_ZSH_DIR/functions/redteam.zsh"
safe_source "$ARCH_DREAM_ZSH_DIR/functions/fzf-zsh-extensions.zsh"

# Cargar configuración de plugins
safe_source "$ARCH_DREAM_ZSH_DIR/plugins/plugin-manager.zsh"

# Cargar configuración de keybindings
safe_source "$ARCH_DREAM_ZSH_DIR/keybindings/keybindings.zsh"

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =====================================================
# 🎨 POWERLEVEL10K DREAMCODER CUSTOM SOFT CONTRAST
# =====================================================

# Cargar configuración personalizada DESPUÉS de p10k.zsh
# para sobrescribir la configuración por defecto con nuestros colores
safe_source "$ARCH_DREAM_ZSH_DIR/powerlevel10k-maximalist.zsh"

# Asegurar que los directorios de cache existan (solo si es necesario)
ensure_cache_dirs

# =====================================================
# 🎨 FASTFETCH AUTOMÁTICO - DESPUÉS DE POWERLEVEL10K
# =====================================================

# Welcome message ya no es necesario - fastfetch se ejecuta al inicio

