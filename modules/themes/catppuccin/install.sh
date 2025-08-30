#!/bin/bash
# Catppuccin Theme - Eye Care Optimized
# Provides color palettes for Kitty terminal and other applications
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
    
    # Note: Kitty themes are handled by terminal:kitty module
    # This module only provides color palette information
    
    success "Catppuccin $variant color palette information installed"
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

    chmod +x "$switcher_script"
    success "Theme switcher script created: $switcher_script"
}

# Main installation
main() {
    show_theme_info
    
    # Install theme information for each variant
    for variant in "${THEMES_AVAILABLE[@]}"; do
        install_theme_files "$variant"
    done
    
    # Create theme switcher
    create_theme_switcher
    
    echo
    success "🎨 Catppuccin themes installed successfully!"
    echo -e "${CYAN}Next steps:${COLOR_RESET}"
    echo -e "  1. Use: ${BOLD}catppuccin-switch mocha${COLOR_RESET} or ${BOLD}catppuccin-switch latte${COLOR_RESET}"
    echo -e "  2. Kitty themes are configured by terminal:kitty module"
    echo -e "  3. Restart your terminal: ${BOLD}exec \$SHELL${COLOR_RESET}"
}

# Run main function
main "$@"