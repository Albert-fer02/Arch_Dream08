#!/bin/bash
# Catppuccin Theme - Standalone Install
# Instala el tema sin requerir permisos sudo ni verificaciones del sistema

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colores básicos
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
COLOR_RESET='\033[0m'

# Funciones básicas
log() { echo -e "${CYAN}[INFO]${COLOR_RESET} $*"; }
success() { echo -e "${GREEN}[OK]${COLOR_RESET} $*"; }

# Crear symlink seguro
create_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"
    
    if [[ ! -e "$source" ]]; then
        echo "❌ Origen no existe: $source"
        return 1
    fi
    
    # Crear backup si existe
    if [[ -e "$target" && ! -L "$target" ]]; then
        mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
        log "Backup creado para $description"
    fi
    
    # Crear directorio padre
    mkdir -p "$(dirname "$target")"
    
    # Crear symlink
    ln -sf "$source" "$target"
    success "$description configurado: $target -> $source"
}

# Instalar tema
install_catppuccin() {
    log "Instalando tema Catppuccin..."
    
    # Instalar Starship mocha (predeterminado)
    create_symlink \
        "$SCRIPT_DIR/catppuccin-mocha.toml" \
        "$HOME/.config/starship-catppuccin-mocha.toml" \
        "Starship Mocha"
    
    create_symlink \
        "$SCRIPT_DIR/catppuccin-mocha.toml" \
        "$HOME/.config/starship.toml" \
        "Starship por defecto"
    
    # Instalar Starship latte
    create_symlink \
        "$SCRIPT_DIR/catppuccin-latte.toml" \
        "$HOME/.config/starship-catppuccin-latte.toml" \
        "Starship Latte"
    
    # Crear switcher
    local switcher="$HOME/.local/bin/catppuccin-switch"
    mkdir -p "$(dirname "$switcher")"
    cp "$SCRIPT_DIR/install.sh" "$switcher" 2>/dev/null || {
        cat > "$switcher" << 'EOF'
#!/bin/bash
# Catppuccin Theme Switcher
case "${1:-help}" in
    mocha)
        ln -sf ~/.config/starship-catppuccin-mocha.toml ~/.config/starship.toml
        echo "✅ Switched to Catppuccin Mocha (dark)"
        ;;
    latte)
        ln -sf ~/.config/starship-catppuccin-latte.toml ~/.config/starship.toml
        echo "✅ Switched to Catppuccin Latte (light)"
        ;;
    *)
        echo "Usage: $0 [mocha|latte]"
        ;;
esac
EOF
    }
    chmod +x "$switcher"
    success "Theme switcher creado: $switcher"
    
    # Marcar como instalado
    mkdir -p "$HOME/.config/arch-dream/installed"
    echo "$(date)" > "$HOME/.config/arch-dream/installed/themes:catppuccin"
    
    echo -e "\n${BOLD}${GREEN}✅ Tema Catppuccin instalado exitosamente${COLOR_RESET}"
    echo -e "${YELLOW}💡 Para cambiar temas: catppuccin-switch [mocha|latte]${COLOR_RESET}"
}

install_catppuccin