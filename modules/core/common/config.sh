#!/usr/bin/env bash
# =====================================================
# ⚙️ CONFIGURACIÓN SIMPLE - ARCH DREAM
# =====================================================

# Configuración básica
export ARCH_DREAM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/arch-dream"

# Crear directorio de configuración
mkdir -p "$ARCH_DREAM_CONFIG_DIR" 2>/dev/null || true

# Función simple para obtener configuración
config_get() {
    local key="$1"
    local default_value="${2:-}"
    
    # Buscar en archivo de configuración local
    local config_file="$ARCH_DREAM_CONFIG_DIR/config.sh"
    if [[ -f "$config_file" ]]; then
        source "$config_file" 2>/dev/null || true
        if [[ -n "${(P)key:-}" ]]; then
            echo "${(P)key}"
            return 0
        fi
    fi
    
    # Devolver valor por defecto
    echo "$default_value"
}

# Función simple para establecer configuración
config_set() {
    local key="$1"
    local value="$2"
    local config_file="$ARCH_DREAM_CONFIG_DIR/config.sh"
    
    # Crear archivo si no existe
    if [[ ! -f "$config_file" ]]; then
        echo "# Arch Dream Configuration" > "$config_file"
        echo "# Generated on: $(date)" >> "$config_file"
        echo "" >> "$config_file"
    fi
    
    # Agregar o actualizar configuración
    if grep -q "^export $key=" "$config_file" 2>/dev/null; then
        sed -i "s/^export $key=.*/export $key=\"$value\"/" "$config_file"
    else
        echo "export $key=\"$value\"" >> "$config_file"
    fi
    
    echo "✅ Configuración actualizada: $key=$value"
}