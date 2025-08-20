#!/bin/bash
# Dracula Theme - Essential only

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

main() {
    log "Installing Dracula theme..."
    
    # Terminal colors
    create_symlink "$SCRIPT_DIR/dracula.toml" "$HOME/.config/starship-dracula.toml"
    
    # Kitty theme
    if [[ -d ~/.config/kitty ]]; then
        create_symlink "$SCRIPT_DIR/dracula-kitty.conf" "$HOME/.config/kitty/dracula.conf"
        echo "include dracula.conf" >> ~/.config/kitty/kitty.conf
    fi
    
    success "Dracula theme installed"
}

main "$@"