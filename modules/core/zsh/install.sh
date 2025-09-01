#!/bin/bash
# =====================================================
# 🚀 ARCH DREAM - ZSH MODULE INSTALLER
# =====================================================
# Instalador del módulo ZSH con configuración completa
# =====================================================

set -euo pipefail

MODULE_NAME="core:zsh"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${MODULE_DIR}/../../.."

# =====================================================
# 🔧 FUNCTIONS
# =====================================================

info() {
    echo -e "\033[38;5;87m[INFO]\033[0m $*"
}

success() {
    echo -e "\033[38;5;118m[OK]\033[0m $*"
}

error() {
    echo -e "\033[38;5;196m[ERROR]\033[0m $*" >&2
}

install_dependencies() {
    info "Instalando dependencias de ZSH..."
    
    # Instalar ZSH si no está instalado
    if ! command -v zsh &>/dev/null; then
        sudo pacman -S --noconfirm zsh
    fi
    
    # Instalar Oh My Zsh si no existe
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        info "Instalando Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Instalar Powerlevel10k
    local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [[ ! -d "$p10k_dir" ]]; then
        info "Instalando Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    fi
    
    # Instalar plugins
    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    fi
    
    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
    fi
    
    if [[ ! -d "$plugins_dir/zsh-completions" ]]; then
        git clone https://github.com/zsh-users/zsh-completions "$plugins_dir/zsh-completions"
    fi
    
    success "Dependencias instaladas"
}

backup_existing_config() {
    if [[ -f "$HOME/.zshrc" ]]; then
        local backup_file="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        info "Creando backup: $backup_file"
        cp "$HOME/.zshrc" "$backup_file"
    fi
}

install_config() {
    info "Instalando configuración ZSH..."
    
    # Copiar configuración principal
    cp "$MODULE_DIR/.zshrc" "$HOME/.zshrc"
    
    # Copiar configuración de Powerlevel10k
    cp "$MODULE_DIR/p10k.zsh" "$HOME/.p10k.zsh"
    
    # Instalar configuración root si se solicita
    if [[ "${INSTALL_ROOT:-}" == "true" ]]; then
        info "Instalando configuración para root..."
        "$MODULE_DIR/install-root-config.sh"
    fi
    
    success "Configuración ZSH instalada"
}

set_default_shell() {
    info "Configurando ZSH como shell predeterminado..."
    
    local zsh_path=$(which zsh)
    if [[ "$SHELL" != "$zsh_path" ]]; then
        chsh -s "$zsh_path"
        success "ZSH configurado como shell predeterminado"
    else
        success "ZSH ya es el shell predeterminado"
    fi
}

# =====================================================
# 🚀 MAIN INSTALLATION
# =====================================================

main() {
    info "Instalando módulo: $MODULE_NAME"
    
    install_dependencies
    backup_existing_config
    install_config
    set_default_shell
    
    success "✅ Módulo $MODULE_NAME instalado exitosamente"
    info "💡 Ejecuta 'exec zsh' para aplicar los cambios"
}

main "$@"