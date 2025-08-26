#!/bin/zsh
# =====================================================
# 🔧 FUNCIONES ESENCIALES PARA PRODUCTIVIDAD DIARIA
# =====================================================

# =====================================================
# 🚀 NAVEGACIÓN Y ARCHIVOS
# =====================================================

# Crear directorio y entrar
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extraer archivos
extract() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"   ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1";;
            *.7z)        7z x "$1"      ;;
            *)           echo "'$1' no se puede extraer" ;;
        esac
    else
        echo "'$1' no es un archivo válido"
    fi
}

# Búsqueda de archivos
find_file() {
    local filename="$1"
    local search_dir="${2:-.}"
    
    if [[ -z "$filename" ]]; then
        echo "Uso: find_file <nombre> [directorio]"
        return 1
    fi
    
    if command -v fd >/dev/null 2>&1; then
        fd "$filename" "$search_dir" --type f 2>/dev/null
    else
        find "$search_dir" -name "*$filename*" -type f 2>/dev/null | head -20
    fi
}

# =====================================================
# 🧹 UTILIDADES DEL SISTEMA
# =====================================================

# Limpiar pantalla
cls() {
    clear
    echo "📁 $(pwd)"
}

# Backup con timestamp
backup() {
    local filename="$1"
    local backup_name="${filename}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$filename" "$backup_name"
    echo "✅ Backup creado: $backup_name"
}

# Recargar configuración
reload_config() {
    source ~/.zshrc
    echo "✅ Configuración recargada"
}

# =====================================================
# 🐧 ARCH LINUX
# =====================================================

# Actualizar Arch
arch-update() {
    echo "🔄 Actualizando sistema..."
    sudo pacman -Syu && {
        echo "✅ Sistema actualizado"
        if command -v yay &>/dev/null; then
            echo "🔄 Actualizando AUR..."
            yay -Syu --noconfirm
        fi
    }
}

# Buscar paquetes
arch-search() {
    [[ -z "$1" ]] && { echo "Uso: arch-search <paquete>"; return 1; }
    echo "🔍 Búsqueda en repositorios oficiales:"
    pacman -Ss "$1"
    if command -v yay &>/dev/null; then
        echo "🔍 Búsqueda en AUR:"
        yay -Ss "$1"
    fi
}
