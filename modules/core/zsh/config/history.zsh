#!/bin/zsh
# =====================================================
# 📚 CONFIGURACIÓN DE HISTORIAL ESENCIAL
# =====================================================

# Configuración básica del historial
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# Opciones de historial esenciales
setopt HIST_IGNORE_DUPS          # No duplicar comandos consecutivos
setopt HIST_IGNORE_ALL_DUPS      # Eliminar duplicados en todo el historial
setopt HIST_IGNORE_SPACE         # Ignorar comandos que empiecen con espacio
setopt HIST_REDUCE_BLANKS        # Eliminar espacios extras
setopt HIST_VERIFY               # Verificar antes de ejecutar !!
setopt SHARE_HISTORY             # Compartir historial entre sesiones
setopt APPEND_HISTORY            # Agregar al historial
setopt INC_APPEND_HISTORY        # Escribir inmediatamente
setopt EXTENDED_HISTORY          # Incluir timestamps

# Navegación de directorios
setopt AUTO_CD                   # cd automático
setopt AUTO_PUSHD                # push automático al directorio stack
setopt PUSHD_IGNORE_DUPS         # No duplicar en stack
