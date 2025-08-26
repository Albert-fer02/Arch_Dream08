#!/bin/bash
# =====================================================
# ⚡ SHELL BASE LOADER PARA BASH - ARCH DREAM v4.3
# =====================================================

# Configuraciones básicas de shell
setup_bash_base() {
    # Configuraciones básicas de bash
    set -o emacs  # Modo emacs por defecto
    shopt -s checkwinsize  # Verificar tamaño de ventana
    shopt -s histappend    # Agregar al historial, no sobrescribir
    shopt -s cmdhist       # Comandos multi-línea en una entrada
    shopt -s globstar      # Habilitar ** para recursión
    shopt -s extglob       # Habilitar patrones extendidos
    shopt -s nocaseglob    # Globbing insensible a mayúsculas
    
    # Configurar colores si está disponible
    if command -v dircolors >/dev/null 2>&1; then
        if [[ -r ~/.dircolors ]]; then
            eval "$(dircolors -b ~/.dircolors)"
        else
            eval "$(dircolors -b)"
        fi
        alias ls='ls --color=auto'
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    fi
}

# Configurar base del shell
setup_bash_base