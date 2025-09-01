#!/bin/bash
# =====================================================
# 🚀 ARCH DREAM - BASH MODULE INSTALLER
# =====================================================
# Instalador simple y eficiente para configuración Bash
# =====================================================

set -euo pipefail

MODULE_NAME="core:bash"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

warn() {
    echo -e "\033[38;5;226m[WARN]\033[0m $*"
}

# =====================================================
# 🚀 INSTALLATION FUNCTIONS
# =====================================================

install_dependencies() {
    info "Verificando dependencias..."
    
    # Bash should already be available on Arch Linux
    if ! command -v bash &>/dev/null; then
        error "Bash no está disponible - esto es inusual en Arch Linux"
        return 1
    fi
    
    success "✓ Bash está disponible"
    
    # Optional modern tools (install if not present)
    local optional_tools=("eza" "bat" "btop" "rg" "fd")
    local missing_tools=()
    
    for tool in "${optional_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        info "Herramientas opcionales faltantes: ${missing_tools[*]}"
        info "Se pueden instalar posteriormente con: sudo pacman -S ${missing_tools[*]}"
    fi
}

backup_existing_config() {
    if [[ -f "$HOME/.bashrc" ]]; then
        local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        info "Creando backup: $backup_file"
        cp "$HOME/.bashrc" "$backup_file"
        success "Backup creado"
    fi
}

install_config() {
    info "Instalando configuración Bash optimizada..."
    
    # Copy main configuration
    cp "$MODULE_DIR/.bashrc" "$HOME/.bashrc"
    chmod 644 "$HOME/.bashrc"
    
    success "✅ Configuración Bash instalada"
}

configure_bash_completion() {
    info "Configurando bash completion..."
    
    # Bash completion should be available by default on Arch
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        success "✓ Bash completion disponible"
    else
        warn "Bash completion no encontrado - instalar con: sudo pacman -S bash-completion"
    fi
}

setup_fzf_integration() {
    info "Configurando integración FZF..."
    
    if command -v fzf &>/dev/null; then
        if [[ -f /usr/share/fzf/key-bindings.bash ]]; then
            success "✓ FZF integración configurada"
        else
            info "FZF encontrado pero archivos de integración no disponibles"
        fi
    else
        info "FZF no instalado - se puede instalar con: sudo pacman -S fzf"
    fi
}

set_default_shell() {
    info "Configurando Bash como shell predeterminado..."
    
    local bash_path
    bash_path=$(which bash)
    
    if [[ "$SHELL" == "$bash_path" ]]; then
        success "✓ Bash ya es el shell predeterminado"
    else
        info "Para cambiar a Bash como shell predeterminado:"
        info "  chsh -s $bash_path"
        warn "Se requiere logout/login para aplicar el cambio"
    fi
}

# =====================================================
# 🧪 VERIFICATION
# =====================================================

verify_installation() {
    info "Verificando instalación..."
    
    local checks_passed=0
    local total_checks=3
    
    # Check if .bashrc exists and is readable
    if [[ -f "$HOME/.bashrc" && -r "$HOME/.bashrc" ]]; then
        success "✓ .bashrc instalado y legible"
        checks_passed=$((checks_passed + 1))
    else
        error "✗ .bashrc no está instalado o no es legible"
    fi
    
    # Check if .bashrc has Arch Dream signature
    if grep -q "ARCH DREAM" "$HOME/.bashrc" 2>/dev/null; then
        success "✓ Configuración Arch Dream detectada"
        checks_passed=$((checks_passed + 1))
    else
        error "✗ Configuración Arch Dream no detectada"
    fi
    
    # Check if .bashrc is syntactically correct
    if bash -n "$HOME/.bashrc" 2>/dev/null; then
        success "✓ Sintaxis de .bashrc es correcta"
        checks_passed=$((checks_passed + 1))
    else
        error "✗ Error de sintaxis en .bashrc"
    fi
    
    if [[ $checks_passed -eq $total_checks ]]; then
        success "✅ Instalación verificada correctamente ($checks_passed/$total_checks)"
        return 0
    else
        error "❌ Instalación parcialmente exitosa ($checks_passed/$total_checks)"
        return 1
    fi
}

show_next_steps() {
    echo
    echo "🎉 ¡Instalación completada!"
    echo
    echo "📋 Próximos pasos:"
    echo "  1. Ejecuta: source ~/.bashrc"
    echo "  2. O reinicia tu terminal: exec bash"
    echo "  3. Para cambiar shell predeterminado: chsh -s $(which bash)"
    echo
    echo "💡 Comandos útiles:"
    echo "  - sysinfo: Información del sistema"
    echo "  - extract <archivo>: Extraer archivos comprimidos"
    echo "  - backup <archivo>: Crear backup con timestamp"
    echo "  - mkcd <directorio>: Crear directorio y entrar"
    echo
    echo "🔧 Herramientas opcionales recomendadas:"
    echo "  sudo pacman -S eza bat btop ripgrep fd fzf"
}

# =====================================================
# 🚀 MAIN INSTALLATION
# =====================================================

main() {
    echo "🚀 Instalando módulo: $MODULE_NAME"
    echo "====================================="
    echo
    
    install_dependencies
    backup_existing_config
    install_config
    configure_bash_completion
    setup_fzf_integration
    set_default_shell
    
    echo
    if verify_installation; then
        show_next_steps
    else
        error "La instalación tuvo algunos problemas"
        return 1
    fi
}

main "$@"