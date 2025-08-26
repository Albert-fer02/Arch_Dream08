#!/bin/bash
# =====================================================
# 👤 PERFILES SIMPLES - ARCH DREAM
# =====================================================

# Configuración básica de perfiles
export ARCH_DREAM_PROFILES_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/arch-dream/profiles"
export ARCH_DREAM_ACTIVE_PROFILE="${ARCH_DREAM_ACTIVE_PROFILE:-default}"

# Crear directorio de perfiles si no existe
mkdir -p "$ARCH_DREAM_PROFILES_DIR" 2>/dev/null || true

# Función simple para cambiar perfil
profile_switch() {
    local profile="$1"
    
    if [[ -z "$profile" ]]; then
        echo "❌ Uso: profile_switch <perfil>"
        return 1
    fi
    
    # Verificar si el perfil existe
    local profile_file="$ARCH_DREAM_PROFILES_DIR/$profile.sh"
    if [[ ! -f "$profile_file" ]]; then
        echo "❌ Perfil no encontrado: $profile"
        return 1
    fi
    
    # Cargar perfil
    source "$profile_file" 2>/dev/null || true
    export ARCH_DREAM_ACTIVE_PROFILE="$profile"
    
    echo "✅ Perfil cambiado a: $profile"
}

# Función simple para listar perfiles
profile_list() {
    echo "👤 Perfiles disponibles:"
    echo "======================="
    
    for profile_file in "$ARCH_DREAM_PROFILES_DIR"/*.sh; do
        if [[ -f "$profile_file" ]]; then
            local profile_name=$(basename "$profile_file" .sh)
            if [[ "$profile_name" == "$ARCH_DREAM_ACTIVE_PROFILE" ]]; then
                echo "  ✅ $profile_name (ACTIVO)"
            else
                echo "  📁 $profile_name"
            fi
        fi
    done
}