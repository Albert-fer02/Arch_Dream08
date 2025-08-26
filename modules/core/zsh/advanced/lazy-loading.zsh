#!/bin/zsh
# =====================================================
# ⚡ LAZY LOADING ESENCIAL
# =====================================================

# NVM lazy loading básico
if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    
    function nvm() {
        unset -f nvm node npm
        source "$NVM_DIR/nvm.sh"
        command nvm "$@"
    }
    
    function node() {
        unset -f nvm node npm
        source "$NVM_DIR/nvm.sh"
        command node "$@"
    }
    
    function npm() {
        unset -f nvm node npm
        source "$NVM_DIR/nvm.sh"
        command npm "$@"
    }
fi
