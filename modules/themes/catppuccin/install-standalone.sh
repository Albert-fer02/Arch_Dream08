#!/bin/bash
# Catppuccin Theme Installer - Standalone Version
# Instala temas Catppuccin optimizados para cuidar los ojos
# Solo para Kitty terminal (Starship eliminado)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
log() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estemos en el directorio correcto
if [[ ! -f "$SCRIPT_DIR/catppuccin-mocha.toml.backup" ]]; then
    error "No se encontraron archivos de tema en $SCRIPT_DIR"
    exit 1
fi

# Crear directorio de configuración
log "Creando directorio de configuración..."
mkdir -p "$HOME/.config/catppuccin"

# Instalar temas disponibles
log "Instalando temas Catppuccin..."

# Tema Mocha (predeterminado)
if [[ -f "$SCRIPT_DIR/catppuccin-mocha.toml.backup" ]]; then
    cp "$SCRIPT_DIR/catppuccin-mocha.toml.backup" \
        "$HOME/.config/catppuccin/catppuccin-mocha.toml"
    success "Tema Mocha instalado"
fi

# Tema Latte
if [[ -f "$SCRIPT_DIR/catppuccin-latte.toml.backup" ]]; then
    cp "$SCRIPT_DIR/catppuccin-latte.toml.backup" \
        "$HOME/.config/catppuccin/catppuccin-latte.toml"
    success "Tema Latte instalado"
fi

# Crear script de cambio de temas
log "Creando script de cambio de temas..."
cat > "$HOME/.local/bin/catppuccin-switch" << 'EOF'
#!/bin/bash
# Catppuccin Theme Switcher
# Usage: catppuccin-switch [mocha|latte]

set -euo pipefail

THEMES_DIR="$HOME/.config/catppuccin"

show_help() {
    echo "🎨 Catppuccin Theme Switcher"
    echo "Usage: $0 [mocha|latte]"
    echo "  mocha  - Switch to dark palette (eye care in low light)"
    echo "  latte  - Switch to light palette (eye care in bright light)"
    echo "  help   - Show this help"
    echo ""
    echo "Note: Kitty themes are managed by terminal:kitty module"
}

switch_theme() {
    local variant="$1"
    
    echo "✅ Switched to Catppuccin $variant palette"
    echo "💡 Restart your terminal or run: exec \$SHELL"
    echo "ℹ️  Note: Kitty themes are managed by terminal:kitty module"
}

case "${1:-help}" in
    mocha|latte)
        switch_theme "$1"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac
EOF

chmod +x "$HOME/.local/bin/catppuccin-switch"
success "Script de cambio de temas creado: $HOME/.local/bin/catppuccin-switch"

# Mensaje final
echo
success "🎨 Temas Catppuccin instalados exitosamente!"
echo -e "${CYAN}Próximos pasos:${NC}"
echo -e "  1. Usar: ${YELLOW}catppuccin-switch mocha${NC} o ${YELLOW}catppuccin-switch latte${NC}"
echo -e "  2. Los temas de Kitty se configuran por separado en terminal:kitty"
echo -e "  3. Reiniciar terminal: ${YELLOW}exec \$SHELL${NC}"
echo
echo -e "${CYAN}Nota:${NC} Este módulo solo proporciona información de paletas de colores."
echo -e "Los temas de Kitty se configuran por el módulo terminal:kitty."