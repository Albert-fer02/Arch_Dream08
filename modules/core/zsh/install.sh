#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM MACHINE - MÓDULO ZSH
# =====================================================
# Script de instalación del módulo Zsh con Oh My Zsh y Powerlevel10k
# Versión 2.0 - Instalación optimizada y robusta
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# =====================================================
# 🔧 CONFIGURACIÓN DEL MÓDULO
# =====================================================

MODULE_NAME="Zsh Configuration"
MODULE_DESCRIPTION="Configuración completa de Zsh con Oh My Zsh y Powerlevel10k"
MODULE_DEPENDENCIES=("zsh" "git" "curl" "wget")
MODULE_FILES=("zshrc" "p10k.zsh" "p10k.root.zsh" "zshrc.root")
MODULE_AUR_PACKAGES=()
MODULE_OPTIONAL=false

# URLs de instalación
OH_MY_ZSH_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
POWERLEVEL10K_URL="https://github.com/romkatv/powerlevel10k.git"

# Directorios de instalación
ZSH_INSTALL_DIR="$HOME/.oh-my-zsh"
POWERLEVEL10K_DIR="$ZSH_INSTALL_DIR/custom/themes/powerlevel10k"
ZSH_CACHE_DIR="$HOME/.zsh"
ZSH_COMPDUMP_DIR="$ZSH_CACHE_DIR/compdump"

# =====================================================
# 🔧 FUNCIONES DEL MÓDULO
# =====================================================

# Instalar dependencias del módulo
install_module_dependencies() {
    log "Instalando dependencias del módulo $MODULE_NAME..."
    
    local deps_to_install=()
    
    # Verificar dependencias
    for dep in "${MODULE_DEPENDENCIES[@]}"; do
        if command -v "$dep" &>/dev/null; then
            success "✓ $dep ya está instalado"
        else
            deps_to_install+=("$dep")
        fi
    done
    
    # Instalar dependencias faltantes
    if [[ ${#deps_to_install[@]} -gt 0 ]]; then
        log "Instalando dependencias faltantes: ${deps_to_install[*]}"
        for dep in "${deps_to_install[@]}"; do
            install_package "$dep"
        done
    fi
    
    success "✅ Todas las dependencias están instaladas"
}

# Instalar Oh My Zsh
install_oh_my_zsh() {
    log "Instalando Oh My Zsh..."
    
    if [[ -d "$ZSH_INSTALL_DIR" ]]; then
        success "✓ Oh My Zsh ya está instalado"
        return 0
    fi
    
    # Crear directorio temporal para la instalación
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Descargar script de instalación
    if curl -fsSL "$OH_MY_ZSH_URL" -o install.sh; then
        # Modificar script para instalación no interactiva
        sed -i 's/read -r "Would you like to change the default shell to zsh? \[Y/n\]? " YN/read -r "Would you like to change the default shell to zsh? \[Y/n\]? " YN || YN=Y/' install.sh
        sed -i 's/read -r "Would you like to change the default shell to zsh? \[Y/n\]? " YN/read -r "Would you like to change the default shell to zsh? \[Y/n\]? " YN || YN=Y/' install.sh
        
        # Ejecutar instalación
        if bash install.sh --unattended; then
            success "✅ Oh My Zsh instalado correctamente"
        else
            error "❌ Fallo al instalar Oh My Zsh"
            return 1
        fi
    else
        error "❌ No se pudo descargar Oh My Zsh"
        return 1
    fi
    
    # Limpiar directorio temporal
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# Instalar Powerlevel10k
install_powerlevel10k() {
    log "Instalando Powerlevel10k..."
    
    if [[ -d "$POWERLEVEL10K_DIR" ]]; then
        success "✓ Powerlevel10k ya está instalado"
        return 0
    fi
    
    # Crear directorio de temas personalizados
    mkdir -p "$ZSH_INSTALL_DIR/custom/themes"
    
    # Clonar Powerlevel10k
    if git clone --depth=1 "$POWERLEVEL10K_URL" "$POWERLEVEL10K_DIR"; then
        success "✅ Powerlevel10k instalado correctamente"
    else
        error "❌ Fallo al instalar Powerlevel10k"
        return 1
    fi
}

# Instalar plugins adicionales
install_additional_plugins() {
    log "Instalando plugins adicionales..."
    
    local plugins_dir="$ZSH_INSTALL_DIR/custom/plugins"
    mkdir -p "$plugins_dir"
    
    # zsh-autosuggestions
    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        log "Instalando zsh-autosuggestions..."
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        log "Instalando zsh-syntax-highlighting..."
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$plugins_dir/zsh-syntax-highlighting"
    fi
    
    # zsh-completions
    if [[ ! -d "$plugins_dir/zsh-completions" ]]; then
        log "Instalando zsh-completions..."
        git clone --depth=1 https://github.com/zsh-users/zsh-completions "$plugins_dir/zsh-completions"
    fi
    
    success "✅ Plugins adicionales instalados"
}

# Configurar directorios de Zsh
setup_zsh_directories() {
    log "Configurando directorios de Zsh..."
    
    # Crear directorios necesarios
    mkdir -p "$ZSH_CACHE_DIR" "$ZSH_COMPDUMP_DIR"
    
    # Establecer permisos correctos
    chmod 755 "$ZSH_CACHE_DIR" "$ZSH_COMPDUMP_DIR"
    
    success "✅ Directorios de Zsh configurados"
}

# Configurar archivos del módulo
configure_module_files() {
    log "Configurando archivos del módulo $MODULE_NAME..."
    
    # Crear directorio de configuración
    local config_dir="$HOME/.config/zshrc"
    mkdir -p "$config_dir"
    
    # Crear symlinks para archivos de configuración
    create_symlink "$SCRIPT_DIR/zshrc" "$HOME/.zshrc" ".zshrc"
    create_symlink "$SCRIPT_DIR/p10k.zsh" "$HOME/.p10k.zsh" ".p10k.zsh"
    
    # Asegurar archivos de inicio mínimos para evitar zsh-newuser-install
    for startup_file in ".zshenv" ".zprofile" ".zlogin"; do
        if [[ ! -f "$HOME/$startup_file" ]]; then
            printf "# Arch Dream: archivo creado para suprimir zsh-newuser-install\n" > "$HOME/$startup_file"
            chmod 644 "$HOME/$startup_file"
            success "✅ Archivo creado: ~/$startup_file"
        fi
    done
    
    # Configurar archivos root si es necesario
    if [[ "$EUID" -eq 0 ]]; then
        create_symlink "$SCRIPT_DIR/zshrc.root" "$HOME/.zshrc" ".zshrc (root)"
        create_symlink "$SCRIPT_DIR/p10k.root.zsh" "$HOME/.p10k.zsh" ".p10k.zsh (root)"
    fi
    
    # Crear archivo de configuración local si no existe
    if [[ ! -f "$HOME/.zshrc.local" ]]; then
        cat > "$HOME/.zshrc.local" << 'EOF'
# =====================================================
# 🧩 CONFIGURACIÓN LOCAL DE ZSH
# =====================================================
# Personalizaciones específicas del usuario
# Este archivo NO se sobrescribe con actualizaciones
# =====================================================

# Agregar aquí tus personalizaciones
# Ejemplo:
# export CUSTOM_VAR="valor"
# alias custom="comando personalizado"

EOF
        success "✅ Archivo de configuración local creado: ~/.zshrc.local"
    fi
    
    success "✅ Archivos del módulo configurados"
}

# Configurar shell por defecto
configure_default_shell() {
    log "Configurando shell por defecto..."
    
    local current_shell=$(getent passwd "$USER" | cut -d: -f7 | xargs basename || basename -- "$SHELL")
    local zsh_path=$(command -v zsh || true)
    
    if [[ "$current_shell" != "zsh" ]]; then
        if [[ -n "$zsh_path" ]]; then
            if confirm "¿Cambiar shell por defecto a Zsh?" true; then
                log "Cambiando shell por defecto a Zsh..."
                # En Arch, chsh requiere ruta absoluta del shell presente en /etc/shells
                if ! grep -q "^$zsh_path$" /etc/shells 2>/dev/null; then
                    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null || true
                fi
                if chsh -s "$zsh_path" "$USER"; then
                    success "✅ Shell cambiado a Zsh. Reinicia la sesión para aplicar"
                    warn "⚠️  IMPORTANTE: Reinicia tu terminal o ejecuta 'exec zsh'"
                else
                    warn "⚠️  No se pudo cambiar el shell por defecto"
                fi
            else
                log "Shell por defecto no cambiado"
            fi
        else
            warn "⚠️  Zsh no encontrado en PATH"
        fi
    else
        success "✓ Zsh ya es el shell por defecto"
    fi
}

# Verificar instalación del módulo
verify_module_installation() {
    log "Verificando instalación del módulo $MODULE_NAME..."
    
    local checks_passed=0
    local total_checks=6
    
    # Verificar Zsh instalado
    if command -v zsh &>/dev/null; then
        success "✓ Zsh instalado"
        ((++checks_passed))
    else
        error "✗ Zsh no está instalado"
    fi
    
    # Verificar Oh My Zsh
    if [[ -d "$ZSH_INSTALL_DIR" ]]; then
        success "✓ Oh My Zsh instalado"
        ((++checks_passed))
    else
        error "✗ Oh My Zsh no está instalado"
    fi
    
    # Verificar Powerlevel10k
    if [[ -d "$POWERLEVEL10K_DIR" ]]; then
        success "✓ Powerlevel10k instalado"
        ((++checks_passed))
    else
        error "✗ Powerlevel10k no está instalado"
    fi
    
    # Verificar .zshrc
    if [[ -L "$HOME/.zshrc" ]] && [[ -e "$HOME/.zshrc" ]]; then
        success "✓ .zshrc configurado"
        ((++checks_passed))
    else
        error "✗ .zshrc no está configurado"
    fi
    
    # Verificar .p10k.zsh
    if [[ -L "$HOME/.p10k.zsh" ]] && [[ -e "$HOME/.p10k.zsh" ]]; then
        success "✓ .p10k.zsh configurado"
        ((++checks_passed))
    else
        error "✗ .p10k.zsh no está configurado"
    fi
    
    # Verificar directorios de Zsh
    if [[ -d "$ZSH_CACHE_DIR" ]] && [[ -d "$ZSH_COMPDUMP_DIR" ]]; then
        success "✓ Directorios de Zsh configurados"
        ((++checks_passed))
    else
        error "✗ Directorios de Zsh no están configurados"
    fi
    
    if [[ $checks_passed -eq $total_checks ]]; then
        success "Módulo $MODULE_NAME instalado correctamente ($checks_passed/$total_checks)"
        return 0
    else
        warn "Módulo $MODULE_NAME instalado parcialmente ($checks_passed/$total_checks)"
        return 1
    fi
}

# Configuración post-instalación
post_installation_setup() {
    log "Configurando sistema post-instalación..."
    
    # Limpiar caché de completions
    if [[ -d "$ZSH_COMPDUMP_DIR" ]]; then
        rm -f "$ZSH_COMPDUMP_DIR"/*
        success "✅ Caché de completions limpiado"
    fi
    
    # Crear script de limpieza de caché
    local cleanup_script="$HOME/.local/bin/clean-zsh-cache"
    mkdir -p "$(dirname "$cleanup_script")"
    
    cat > "$cleanup_script" << 'EOF'
#!/bin/bash
# Script para limpiar caché de Zsh
echo "🧹 Limpiando caché de Zsh..."
rm -f ~/.zsh/compdump/*
rm -f ~/.zsh_history
echo "✅ Caché limpiado"
EOF
    
    chmod +x "$cleanup_script"
    success "✅ Script de limpieza creado: $cleanup_script"
    
    # Mostrar información de uso
    show_usage_info
}

# Mostrar información de uso
show_usage_info() {
    echo
    echo -e "${BOLD}${GREEN}🚀 ZSH CONFIGURADO EXITOSAMENTE${COLOR_RESET}"
    echo
    echo -e "${CYAN}📋 Próximos pasos:${COLOR_RESET}"
    echo -e "  1. Reinicia tu terminal o ejecuta: exec zsh"
    echo -e "  2. Configura Powerlevel10k ejecutando: p10k configure"
    echo -e "  3. Personaliza tu configuración en: ~/.zshrc.local"
    echo
    echo -e "${YELLOW}💡 Comandos útiles:${COLOR_RESET}"
    echo -e "  - clean-zsh-cache: Limpiar caché de Zsh"
    echo -e "  - omz update: Actualizar Oh My Zsh"
    echo -e "  - p10k configure: Reconfigurar Powerlevel10k"
    echo
    echo -e "${PURPLE}🌟 ¡Disfruta tu nueva configuración de Zsh!${COLOR_RESET}"
}

# =====================================================
# 🏁 FUNCIÓN PRINCIPAL
# =====================================================

main() {
    # Inicializar biblioteca
    init_library
    
    # Banner
    echo -e "${BOLD}${CYAN}🧩 INSTALANDO MÓDULO: $MODULE_NAME${COLOR_RESET}"
    echo -e "${CYAN}$MODULE_DESCRIPTION${COLOR_RESET}\n"
    
    # Instalar dependencias
    install_module_dependencies
    
    # Instalar Oh My Zsh
    install_oh_my_zsh
    
    # Instalar Powerlevel10k
    install_powerlevel10k
    
    # Instalar plugins adicionales
    install_additional_plugins
    
    # Configurar directorios
    setup_zsh_directories
    
    # Configurar archivos
    configure_module_files
    
    # Configurar shell por defecto
    configure_default_shell
    
    # Verificar instalación
    verify_module_installation
    
    # Configuración post-instalación
    post_installation_setup
    
    echo -e "\n${BOLD}${GREEN}✅ Módulo $MODULE_NAME instalado exitosamente${COLOR_RESET}"
    echo -e "${YELLOW}💡 Para usar Zsh: zsh o reinicia tu terminal${COLOR_RESET}"
}

# Ejecutar función principal
main "$@"
