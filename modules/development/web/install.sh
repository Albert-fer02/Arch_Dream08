#!/bin/bash
# Web Development Module - Essential Only

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

MODULE_NAME="Web Development"
MODULE_DEPENDENCIES=("core:bash")

main() {
    log "Installing $MODULE_NAME..."
    
    # Essential packages only
    ensure_installed nodejs npm typescript
    
    # Global tools - just the essentials
    if ! npm list -g pnpm &>/dev/null; then
        npm install -g pnpm
        success "pnpm installed"
    fi
    
    if ! npm list -g prettier &>/dev/null; then
        npm install -g prettier eslint
        success "prettier/eslint installed"
    fi
    
    # Basic configurations
    create_symlink "$SCRIPT_DIR/npmrc" "$HOME/.npmrc"
    create_symlink "$SCRIPT_DIR/prettierrc" "$HOME/.prettierrc"
    
    success "$MODULE_NAME installed"
}

main "$@"