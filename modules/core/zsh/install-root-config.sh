#!/bin/bash
# =====================================================
# 🚀 INSTALADOR AUTOMÁTICO DE CONFIGURACIÓN ROOT ZSH
# =====================================================
# Script para aplicar automáticamente la configuración
# optimizada de zsh al usuario root
# =====================================================

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar que se ejecuta con privilegios de root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script debe ejecutarse como root o con sudo"
        exit 1
    fi
}

# Crear backup de configuración existente
backup_existing_config() {
    if [[ -f /root/.zshrc ]]; then
        local backup_file="/root/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Creando backup de configuración existente: $backup_file"
        cp /root/.zshrc "$backup_file"
        log_success "Backup creado correctamente"
    fi
}

# Instalar zsh si no está instalado
install_zsh() {
    if ! command -v zsh &> /dev/null; then
        log_info "Zsh no encontrado. Instalando..."
        if command -v pacman &> /dev/null; then
            pacman -S --noconfirm zsh
        elif command -v apt &> /dev/null; then
            apt update && apt install -y zsh
        elif command -v yum &> /dev/null; then
            yum install -y zsh
        else
            log_error "No se pudo detectar el gestor de paquetes para instalar zsh"
            exit 1
        fi
        log_success "Zsh instalado correctamente"
    else
        log_success "Zsh ya está instalado"
    fi
}

# Copiar configuración optimizada
install_config() {
    local source_config="$(dirname "$0")/root/.zshrc"
    
    if [[ ! -f "$source_config" ]]; then
        log_error "No se encontró el archivo de configuración: $source_config"
        exit 1
    fi
    
    log_info "Instalando configuración optimizada para root..."
    cp "$source_config" /root/.zshrc
    chown root:root /root/.zshrc
    chmod 644 /root/.zshrc
    log_success "Configuración instalada correctamente"
}

# Configurar zsh como shell predeterminado para root
set_default_shell() {
    local current_shell=$(getent passwd root | cut -d: -f7)
    local zsh_path=$(which zsh)
    
    if [[ "$current_shell" != "$zsh_path" ]]; then
        log_info "Configurando zsh como shell predeterminado para root..."
        chsh -s "$zsh_path" root
        log_success "Shell predeterminado configurado: $zsh_path"
    else
        log_success "Zsh ya es el shell predeterminado para root"
    fi
}

# Crear directorios necesarios
create_directories() {
    log_info "Creando directorios necesarios..."
    mkdir -p /root/.config /root/.local/share /root/.cache
    chown -R root:root /root/.config /root/.local /root/.cache
    log_success "Directorios creados correctamente"
}

# Instalar herramientas opcionales recomendadas
install_optional_tools() {
    log_info "Instalando herramientas opcionales recomendadas..."
    
    local tools=("eza" "bat" "btop" "nvim" "ripgrep" "fd")
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_info "Instalando $tool..."
            if command -v pacman &> /dev/null; then
                pacman -S --noconfirm "$tool" 2>/dev/null || log_warning "No se pudo instalar $tool"
            fi
        else
            log_success "$tool ya está instalado"
        fi
    done
}

# Función principal
main() {
    echo "================================================="
    echo "🚀 INSTALADOR DE CONFIGURACIÓN ROOT ZSH"
    echo "================================================="
    echo ""
    
    check_root
    backup_existing_config
    install_zsh
    create_directories
    install_config
    set_default_shell
    
    # Preguntar sobre herramientas opcionales
    read -p "¿Deseas instalar herramientas opcionales recomendadas? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_optional_tools
    fi
    
    echo ""
    echo "================================================="
    log_success "¡Instalación completada!"
    echo "================================================="
    echo ""
    log_info "Para aplicar los cambios inmediatamente:"
    echo "  sudo -i  # o su -"
    echo ""
    log_info "O cierra y abre una nueva sesión root"
    echo ""
}

# Ejecutar función principal
main "$@"