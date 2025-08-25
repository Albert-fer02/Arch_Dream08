#!/bin/bash
# Catppuccin Theme - Eye Care Optimized
# Provides color palettes for Starship and other applications
# Note: Kitty configurations are handled by the terminal:kitty module

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# Theme configuration
THEME_VARIANT="${CATPPUCCIN_THEME:-mocha}"  # Default to mocha, can be set via environment
THEMES_AVAILABLE=("mocha" "latte")

show_theme_info() {
    echo -e "${BOLD}${CYAN}🎨 Catppuccin Theme - Eye Care Optimized${COLOR_RESET}"
    echo -e "${YELLOW}Available color palettes:${COLOR_RESET}"
    echo -e "  • ${BOLD}mocha${COLOR_RESET} - Dark palette (reduces eye strain in low light)"
    echo -e "  • ${BOLD}latte${COLOR_RESET} - Light palette (comfortable for bright environments)"
    echo -e "${CYAN}Set CATPPUCCIN_THEME=mocha or CATPPUCCIN_THEME=latte to choose${COLOR_RESET}"
    echo -e "${CYAN}Note: Kitty themes are configured separately in terminal:kitty module${COLOR_RESET}"
}

install_theme_files() {
    local variant="$1"
    log "Installing Catppuccin $variant color palette..."
    
    # Create theme directory
    mkdir -p "$HOME/.config/catppuccin"
    
    # Install Starship theme
    local starship_src="$SCRIPT_DIR/catppuccin-$variant.toml"
    local starship_dst="$HOME/.config/starship-catppuccin-$variant.toml"
    
    if [[ -f "$starship_src" ]]; then
        create_symlink "$starship_src" "$starship_dst" "Starship $variant palette"
        
        # Create default symlink if this is the selected theme
        if [[ "$variant" == "$THEME_VARIANT" ]]; then
            create_symlink "$starship_src" "$HOME/.config/starship.toml" "Default Starship theme"
        fi
    fi
    
    success "Catppuccin $variant color palette installed"
}

create_theme_switcher() {
    log "Creating theme switcher script..."
    
    local switcher_script="$HOME/.local/bin/catppuccin-switch"
    mkdir -p "$(dirname "$switcher_script")"
    
    cat > "$switcher_script" << 'EOF'
#!/bin/bash
# Catppuccin Theme Switcher
# Usage: catppuccin-switch [mocha|latte]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$HOME/.config/catppuccin"

show_help() {
    echo "🎨 Catppuccin Theme Switcher"
    echo "Usage: $0 [mocha|latte]"
    echo "  mocha  - Switch to dark palette (eye care in low light)"
    echo "  latte  - Switch to light palette (eye care in bright light)"
    echo "  help   - Show this help"
    echo ""
    echo "Note: This only changes Starship theme. Kitty themes are configured separately."
}

switch_theme() {
    local variant="$1"
    local starship_src="$THEMES_DIR/starship-catppuccin-$variant.toml"
    
    if [[ ! -f "$starship_src" ]]; then
        echo "❌ Theme $variant not found. Run install.sh first."
        exit 1
    fi
    
    # Switch Starship theme
    ln -sf "$starship_src" "$HOME/.config/starship.toml"
    
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
    
    chmod +x "$switcher_script"
    success "Theme switcher created: $switcher_script"
}

main() {
    # Solo inicializar funciones básicas sin sudo para tema
    source "$SCRIPT_DIR/../../../lib/common.sh" || true
    
    echo -e "${BOLD}${CYAN}🎨 INSTALANDO TEMA: Catppuccin Eye Care${COLOR_RESET}"
    echo -e "${CYAN}Paletas de colores optimizadas para cuidar los ojos${COLOR_RESET}\n"
    
    show_theme_info
    
    # Install all available color palettes
    for theme in "${THEMES_AVAILABLE[@]}"; do
        install_theme_files "$theme"
    done
    
    # Create theme switcher
    create_theme_switcher
    
    # Set default theme
    export CATPPUCCIN_THEME="$THEME_VARIANT"
    
    echo -e "\n${BOLD}${GREEN}✅ Paletas Catppuccin instaladas exitosamente${COLOR_RESET}"
    echo -e "${YELLOW}💡 Para cambiar paletas:${COLOR_RESET}"
    echo -e "  • ${CYAN}catppuccin-switch mocha${COLOR_RESET} - Paleta oscura (baja luz)"
    echo -e "  • ${CYAN}catppuccin-switch latte${COLOR_RESET} - Paleta clara (luz brillante)"
    echo -e "  • ${CYAN}export CATPPUCCIN_THEME=mocha${COLOR_RESET} - Variable de entorno"
    echo -e "${CYAN}🎨 Paleta actual: $THEME_VARIANT${COLOR_RESET}"
    echo -e "${CYAN}ℹ️  Kitty themes: Configurados por separado en terminal:kitty${COLOR_RESET}"
}

main "$@"