#!/bin/zsh
# =====================================================
# ⚡ COMPLETION BÁSICO OPTIMIZADO
# =====================================================

# Cache de completiones para mejor performance
[[ ! -d ~/.zsh/cache ]] && mkdir -p ~/.zsh/cache
autoload -Uz compinit
compinit -d ~/.zsh/cache/.zcompdump

setopt COMPLETE_IN_WORD          # Completar en medio de palabras
setopt ALWAYS_TO_END             # Cursor al final después de completar
setopt AUTO_MENU                 # Mostrar menu de completions
setopt AUTO_LIST                 # Listar opciones automáticamente

# Opciones adicionales útiles
setopt CORRECT                   # Corregir comandos mal escritos
setopt EXTENDED_GLOB             # Globbing extendido
setopt NO_BEEP                   # Sin sonidos

# =====================================================
# 🎨 COMPLETION STYLING OPTIMIZADO
# =====================================================

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS:-}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Completions adicionales
if [[ -d /usr/share/zsh/plugins/zsh-completions ]]; then
    fpath=(/usr/share/zsh/plugins/zsh-completions/src $fpath)
fi
