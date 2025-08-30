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

# Configuración preparada para Powerlevel10k
