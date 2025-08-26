#!/usr/bin/env zsh

# Configuración temprana para inicio silencioso
export QUIET_STARTUP=true
export ARCH_DREAM_LOG_LEVEL="ERROR"

# Desactivar mensajes innecesarios
setopt NO_BEEP
setopt NO_NOTIFY
setopt NO_CHECK_JOBS
skip_global_compinit=1

# Redirigir errores estándar para comandos específicos
for cmd in compinit compdef; do
    which $cmd >/dev/null 2>&1 && eval "function $cmd { command $cmd \"\$@\" 2>/dev/null }"
done

# Configuración de completion silenciosa
zstyle ':completion:*' quiet true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# Configuración de Starship (consolidada desde bash)
export STARSHIP_LOG="error"
export STARSHIP_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/starship"
export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"

# Crear directorio de caché si no existe
[[ ! -d "$STARSHIP_CACHE" ]] && mkdir -p "$STARSHIP_CACHE"

# Inicializar Starship para zsh
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi
