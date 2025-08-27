#!/bin/zsh
# =====================================================
# 🔌 PLUGINS ESENCIALES - Configuración Mínima
# =====================================================

# zsh-autosuggestions - Sugerencias automáticas
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c6c6c'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# zsh-syntax-highlighting - Resaltado de sintaxis
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# FZF - Configuración minimalista unificada
if [[ -f "${ARCH_DREAM_ROOT:-$HOME/.config/arch-dream}/modules/core/zsh/plugins/fzf.zsh" ]]; then
    source "${ARCH_DREAM_ROOT:-$HOME/.config/arch-dream}/modules/core/zsh/plugins/fzf.zsh"
fi

# Completions FZF del sistema (opcional)
if command -v fzf &>/dev/null && [[ -f /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
fi

# Zoxide - Navegación inteligente
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
    alias z='__zoxide_z'
fi

# Atuin - Historial mejorado
if command -v atuin &>/dev/null; then
    eval "$(atuin init zsh --disable-up-arrow)"
    bindkey '^r' _atuin_search_widget
fi
