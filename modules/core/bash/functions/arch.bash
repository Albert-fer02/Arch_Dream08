#!/bin/bash
# =====================================================
# 🐧 FUNCIONES DE ARCH LINUX PARA BASH
# =====================================================

# Función de actualización del sistema para usuario normal
sysupdate() {
    echo "🔄 Actualizando sistema..."
    sudo pacman -Syu && {
        echo "✅ Sistema actualizado"
        if command -v yay &>/dev/null; then
            echo "🔄 Actualizando AUR..."
            yay -Syu --noconfirm
        fi
    }
}

# Función de búsqueda de paquetes optimizada
arch-search() {
    [[ -z "$1" ]] && { echo "Uso: arch-search <paquete>"; return 1; }
    echo "🔍 Búsqueda en repositorios oficiales:"
    pacman -Ss "$1"
    if command -v yay &>/dev/null; then
        echo "🔍 Búsqueda en AUR:"
        yay -Ss "$1"
    fi
}

# Función de limpieza del sistema
cleanup() {
    echo "🧹 Limpiando sistema..."
    sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || echo "No hay paquetes huérfanos"
    sudo pacman -Sc
    echo "✅ Sistema limpiado"
}
