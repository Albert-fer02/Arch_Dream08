#!/bin/bash
# =====================================================
# 🚀 SETUP ZSH OPTIMIZADO - ARCH DREAM
# =====================================================
# Script para configurar y optimizar ZSH
# =====================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}=====================================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}=====================================================${NC}"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para instalar paquetes si no están disponibles
install_package() {
    local package="$1"
    local package_name="${2:-$1}"
    
    if ! command_exists "$package"; then
        print_warning "$package_name no está instalado. Instalando..."
        if command_exists "yay"; then
            yay -S "$package_name" --noconfirm
        elif command_exists "pacman"; then
            sudo pacman -S "$package_name" --noconfirm
        else
            print_error "No se pudo instalar $package_name. Instálalo manualmente."
            return 1
        fi
        print_success "$package_name instalado exitosamente"
    else
        print_status "$package_name ya está instalado"
    fi
}

# Función para crear directorios necesarios
create_directories() {
    print_header "Creando directorios necesarios"
    
    local dirs=(
        "$HOME/.zsh"
        "$HOME/.zsh/cache"
        "$HOME/.config/starship"
        "$HOME/backups"
        "$HOME/Developer"
        "$HOME/Projects"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            print_success "Directorio creado: $dir"
        else
            print_status "Directorio ya existe: $dir"
        fi
    done
}

# Función para instalar plugins de ZSH
install_zsh_plugins() {
    print_header "Instalando plugins de ZSH"
    
    local plugins_dir="/usr/share/zsh/plugins"
    
    # Crear directorio si no existe
    if [[ ! -d "$plugins_dir" ]]; then
        sudo mkdir -p "$plugins_dir"
    fi
    
    # zsh-autosuggestions
    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        print_status "Instalando zsh-autosuggestions..."
        if command_exists "yay"; then
            yay -S zsh-autosuggestions --noconfirm
        elif command_exists "pacman"; then
            sudo pacman -S zsh-autosuggestions --noconfirm
        fi
    else
        print_status "zsh-autosuggestions ya está instalado"
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        print_status "Instalando zsh-syntax-highlighting..."
        if command_exists "yay"; then
            yay -S zsh-syntax-highlighting --noconfirm
        elif command_exists "pacman"; then
            sudo pacman -S zsh-syntax-highlighting --noconfirm
        fi
    else
        print_status "zsh-syntax-highlighting ya está instalado"
    fi
    
    # zsh-completions
    if [[ ! -d "$plugins_dir/zsh-completions" ]]; then
        print_status "Instalando zsh-completions..."
        if command_exists "yay"; then
            yay -S zsh-completions --noconfirm
        elif command_exists "pacman"; then
            sudo pacman -S zsh-completions --noconfirm
        fi
    else
        print_status "zsh-completions ya está instalado"
    fi
}

# Función para instalar herramientas modernas
install_modern_tools() {
    print_header "Instalando herramientas modernas"
    
    local tools=(
        "eza:exa"           # Mejor ls
        "bat:bat"           # Mejor cat
        "btop:btop"         # Mejor htop
        "ripgrep:ripgrep"   # Mejor grep
        "fd:fd"             # Mejor find
        "fzf:fzf"           # Fuzzy finder
        "zoxide:zoxide"     # Mejor cd
        "atuin:atuin"       # Historial mejorado
    )
    
    for tool in "${tools[@]}"; do
        IFS=':' read -r package package_name <<< "$tool"
        install_package "$package" "$package_name"
    done
}

# Función para configurar Starship
setup_starship() {
    print_header "Configurando Starship"
    
    if ! command_exists "starship"; then
        print_status "Instalando Starship..."
        curl -sS https://starship.rs/install.sh | sh
        print_success "Starship instalado exitosamente"
    else
        print_status "Starship ya está instalado"
    fi
    
    # Crear enlace simbólico a la configuración
    local starship_config="$HOME/.config/starship.toml"
    local project_config="$(dirname "$0")/../../../lib/starship.toml"
    
    if [[ -f "$project_config" ]]; then
        ln -sf "$project_config" "$starship_config"
        print_success "Configuración de Starship enlazada"
    else
        print_warning "No se encontró la configuración de Starship del proyecto"
    fi
}

# Función para configurar NVM
setup_nvm() {
    print_header "Configurando NVM"
    
    if [[ ! -d "$HOME/.nvm" ]]; then
        print_status "Instalando NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        print_success "NVM instalado exitosamente"
    else
        print_status "NVM ya está instalado"
    fi
}

# Función para crear backup de configuración actual
backup_current_config() {
    print_header "Creando backup de configuración actual"
    
    local backup_dir="$HOME/backups/zsh-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup de archivos existentes
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$backup_dir/"
    [[ -f "$HOME/.zshrc.local" ]] && cp "$HOME/.zshrc.local" "$backup_dir/"
    [[ -d "$HOME/.zsh" ]] && cp -r "$HOME/.zsh" "$backup_dir/"
    
    print_success "Backup creado en: $backup_dir"
}

# Función para instalar la nueva configuración
install_new_config() {
    print_header "Instalando nueva configuración"
    
    local script_dir="$(dirname "$0")"
    local zshrc_source="$script_dir/zshrc"
    local zshrc_local_source="$script_dir/zshrc.local"
    
    # Instalar zshrc principal
    if [[ -f "$zshrc_source" ]]; then
        cp "$zshrc_source" "$HOME/.zshrc"
        print_success "zshrc instalado"
    else
        print_error "No se encontró el archivo zshrc"
        return 1
    fi
    
    # Instalar zshrc.local
    if [[ -f "$zshrc_local_source" ]]; then
        cp "$zshrc_local_source" "$HOME/.zshrc.local"
        print_success "zshrc.local instalado"
    else
        print_error "No se encontró el archivo zshrc.local"
        return 1
    fi
    
    # Hacer el archivo ejecutable
    chmod +x "$HOME/.zshrc"
}

# Función para configurar el shell por defecto
setup_default_shell() {
    print_header "Configurando shell por defecto"
    
    local current_shell=$(echo $SHELL)
    local zsh_path=$(which zsh)
    
    if [[ "$current_shell" != "$zsh_path" ]]; then
        print_status "Cambiando shell por defecto a ZSH..."
        chsh -s "$zsh_path"
        print_success "Shell por defecto cambiado a ZSH"
        print_warning "Reinicia la sesión para aplicar el cambio"
    else
        print_status "ZSH ya es el shell por defecto"
    fi
}

# Función para mostrar información final
show_final_info() {
    print_header "Configuración Completada"
    
    echo -e "${GREEN}✅ ZSH ha sido configurado exitosamente!${NC}"
    echo ""
    echo -e "${CYAN}🚀 Nuevas funcionalidades disponibles:${NC}"
    echo "  • Prompt optimizado con Starship"
    echo "  • Completión inteligente"
    echo "  • Historial mejorado"
    echo "  • Aliases y funciones para Red Team"
    echo "  • Herramientas modernas (eza, bat, btop, etc.)"
    echo "  • Lazy loading para mejor performance"
    echo ""
    echo -e "${CYAN}🔧 Comandos útiles:${NC}"
    echo "  • create-project - Crear proyectos rápidamente"
    echo "  • quick-backup - Backup rápido de archivos"
    echo "  • search-files - Búsqueda en archivos"
    echo "  • system-status - Estado del sistema"
    echo "  • pentest-context - Configurar contexto de pentesting"
    echo "  • clear-context - Limpiar contexto"
    echo ""
    echo -e "${YELLOW}⚠️  Para aplicar todos los cambios:${NC}"
    echo "  1. Reinicia tu terminal"
    echo "  2. O ejecuta: source ~/.zshrc"
    echo ""
    echo -e "${PURPLE}📚 Documentación:${NC}"
    echo "  • Archivo principal: ~/.zshrc"
    echo "  • Configuración local: ~/.zshrc.local"
    echo "  • Configuración Starship: ~/.config/starship.toml"
    echo "  • Cache de completiones: ~/.zsh/cache/"
}

# Función principal
main() {
    print_header "🚀 SETUP ZSH OPTIMIZADO - ARCH DREAM"
    
    print_status "Iniciando configuración de ZSH..."
    
    # Verificar que estamos en Arch Linux
    if ! command_exists "pacman"; then
        print_error "Este script está diseñado para Arch Linux"
        exit 1
    fi
    
    # Crear directorios
    create_directories
    
    # Crear backup
    backup_current_config
    
    # Instalar plugins
    install_zsh_plugins
    
    # Instalar herramientas modernas
    install_modern_tools
    
    # Configurar Starship
    setup_starship
    
    # Configurar NVM
    setup_nvm
    
    # Instalar nueva configuración
    install_new_config
    
    # Configurar shell por defecto
    setup_default_shell
    
    # Mostrar información final
    show_final_info
    
    print_success "¡Configuración completada exitosamente!"
}

# Ejecutar función principal
main "$@"
