#!/bin/zsh
# =====================================================
# 🎯 KEY BINDINGS OPTIMIZADOS
# =====================================================

bindkey -e  # Emacs-style

# History search optimizado
bindkey '^R' history-incremental-search-backward
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

# Navegación mejorada
bindkey '^[[1;5C' forward-word      # Ctrl+Right
bindkey '^[[1;5D' backward-word     # Ctrl+Left
bindkey '^H' backward-kill-word     # Ctrl+Backspace
bindkey '^[[3;5~' kill-word         # Ctrl+Delete
