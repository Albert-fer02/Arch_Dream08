#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM MACHINE - MÓDULO KITTY TERMINAL
# =====================================================
# Script de instalación del módulo Kitty Terminal
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

MODULE_NAME="Kitty Terminal"
MODULE_DESCRIPTION="Emulador de terminal con aceleración GPU y tema personalizado"
MODULE_DEPENDENCIES=("kitty" "fontconfig" "xorg-xlsfonts")
MODULE_FILES=("kitty.conf" "colors-dreamcoder.conf")
MODULE_AUR_PACKAGES=()
MODULE_OPTIONAL=false

# Directorios de instalación
KITTY_CONFIG_DIR="$HOME/.config/kitty"
KITTY_THEMES_DIR="$KITTY_CONFIG_DIR/themes"
KITTY_SESSIONS_DIR="$KITTY_CONFIG_DIR/sessions"

# =====================================================
# 🔧 FUNCIONES DEL MÓDULO
# =====================================================

# Instalar dependencias del módulo
install_module_dependencies() {
    log "Instalando dependencias del módulo $MODULE_NAME..."
    
    local deps_to_install=()
    
    # Verificar dependencias
    for dep in "${MODULE_DEPENDENCIES[@]}"; do
        if command -v "$dep" &>/dev/null || pacman -Q "$dep" &>/dev/null; then
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

# Instalar fuentes adicionales
install_additional_fonts() {
    log "Instalando fuentes adicionales para Kitty..."
    
    local fonts_to_install=()
    
    # Verificar fuentes populares para terminales
    # Mapear nombres posibles en repos vs AUR
    local fonts=("ttf-firacode-nerd" "ttf-jetbrains-mono-nerd" "ttf-hack-nerd" "noto-fonts-emoji")
    
    for font in "${fonts[@]}"; do
        if pacman -Q "$font" &>/dev/null; then
            success "✓ $font ya está instalado"
        else
            fonts_to_install+=("$font")
        fi
    done
    
    # Instalar fuentes faltantes
    if [[ ${#fonts_to_install[@]} -gt 0 ]]; then
        log "Instalando fuentes faltantes: ${fonts_to_install[*]}"
        for font in "${fonts_to_install[@]}"; do
            if pacman -Si "$font" &>/dev/null; then
                install_package "$font"
            else
                install_aur_package "$font"
            fi
        done
    fi
    
    # Actualizar caché de fuentes
    if command -v fc-cache &>/dev/null; then
        log "Actualizando caché de fuentes..."
        fc-cache -fv
        success "✅ Caché de fuentes actualizado"
    fi
    
    success "✅ Fuentes adicionales instaladas"
}

# Configurar directorios de Kitty
setup_kitty_directories() {
    log "Configurando directorios de Kitty..."
    
    # Normalizar si existe un symlink roto o archivo en la ruta de config
    if [[ -L "$KITTY_CONFIG_DIR" ]]; then
        local target
        target=$(readlink -f "$KITTY_CONFIG_DIR" || true)
        if [[ -z "$target" || ! -d "$target" ]]; then
            warn "Enlace roto detectado en $KITTY_CONFIG_DIR, corrigiendo..."
            rm -f "$KITTY_CONFIG_DIR"
        fi
    elif [[ -e "$KITTY_CONFIG_DIR" && ! -d "$KITTY_CONFIG_DIR" ]]; then
        warn "$KITTY_CONFIG_DIR es un archivo, moviendo a backup..."
        mv "$KITTY_CONFIG_DIR" "$KITTY_CONFIG_DIR.backup_$(date +%Y%m%d_%H%M%S)"
    fi

    # Crear directorios necesarios
    mkdir -p "$KITTY_CONFIG_DIR" "$KITTY_THEMES_DIR" "$KITTY_SESSIONS_DIR"
    
    # Establecer permisos correctos
    chmod 755 "$KITTY_CONFIG_DIR" "$KITTY_THEMES_DIR" "$KITTY_SESSIONS_DIR"
    
    success "✅ Directorios de Kitty configurados"
}

# Configurar archivos del módulo
configure_module_files() {
    log "Configurando archivos del módulo $MODULE_NAME..."
    
    # Crear symlinks para archivos de configuración
    create_symlink "$SCRIPT_DIR/kitty.conf" "$KITTY_CONFIG_DIR/kitty.conf" "kitty.conf"
    create_symlink "$SCRIPT_DIR/colors-dreamcoder.conf" "$KITTY_CONFIG_DIR/colors-dreamcoder.conf" "colors-dreamcoder.conf"
    
    # Crear archivo de configuración local si no existe
    if [[ ! -f "$KITTY_CONFIG_DIR/kitty.local.conf" ]]; then
        cat > "$KITTY_CONFIG_DIR/kitty.local.conf" << 'EOF'
# =====================================================
# 🧩 CONFIGURACIÓN LOCAL DE KITTY
# =====================================================
# Personalizaciones específicas del usuario
# Este archivo NO se sobrescribe con actualizaciones
# =====================================================

# Agregar aquí tus personalizaciones
# Ejemplo:
# font_family FiraCode Nerd Font
# font_size 12
# background_opacity 0.9

EOF
        success "✅ Archivo de configuración local creado: $KITTY_CONFIG_DIR/kitty.local.conf"
    fi
    
    # Crear archivo de sesiones personalizadas
    if [[ ! -f "$KITTY_SESSIONS_DIR/default.conf" ]]; then
        cat > "$KITTY_SESSIONS_DIR/default.conf" << 'EOF'
# =====================================================
# 🧩 SESIÓN POR DEFECTO DE KITTY
# =====================================================
# Configuración de la sesión principal
# =====================================================

new_tab
layout horizontal
cd ~
launch zsh

new_tab
layout vertical
cd ~/Documents
launch zsh

new_tab
layout grid
cd ~/Downloads
launch zsh
EOF
        success "✅ Archivo de sesiones creado: $KITTY_SESSIONS_DIR/default.conf"
    fi
    
    success "✅ Archivos del módulo configurados"
}

# Configurar integración con el sistema
configure_system_integration() {
    log "Configurando integración con el sistema..."
    
    # Crear entrada en aplicaciones si no existe
    local desktop_file="$HOME/.local/share/applications/kitty.desktop"
    if [[ ! -f "$desktop_file" ]]; then
        mkdir -p "$(dirname "$desktop_file")"
        cat > "$desktop_file" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Kitty
GenericName=Terminal emulator
Comment=Fast, feature-rich, GPU based terminal emulator
Exec=kitty
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;
EOF
        success "✅ Entrada de aplicación creada: $desktop_file"
    fi
    
    # Configurar como terminal por defecto si es posible
    if [[ -n "$TERMINAL" ]] && [[ "$TERMINAL" != "kitty" ]]; then
        if confirm "¿Configurar Kitty como terminal por defecto?" true; then
            echo 'export TERMINAL="kitty"' >> "$HOME/.bashrc"
            echo 'export TERMINAL="kitty"' >> "$HOME/.zshrc"
            success "✅ Kitty configurado como terminal por defecto"
        fi
    fi
    
    success "✅ Integración con el sistema configurada"
}

# Verificar instalación del módulo
verify_module_installation() {
    log "Verificando instalación del módulo $MODULE_NAME..."
    
    local checks_passed=0
    local total_checks=5
    
    # Verificar Kitty instalado
    if command -v kitty &>/dev/null; then
        success "✓ Kitty instalado"
        ((++checks_passed))
    else
        error "✗ Kitty no está instalado"
    fi
    
    # Verificar archivo de configuración principal
    if [[ -L "$KITTY_CONFIG_DIR/kitty.conf" ]] && [[ -e "$KITTY_CONFIG_DIR/kitty.conf" ]]; then
        success "✓ kitty.conf configurado"
        ((++checks_passed))
    else
        error "✗ kitty.conf no está configurado"
    fi
    
    # Verificar archivo de colores
    if [[ -L "$KITTY_CONFIG_DIR/colors-dreamcoder.conf" ]] && [[ -e "$KITTY_CONFIG_DIR/colors-dreamcoder.conf" ]]; then
        success "✓ colors-dreamcoder.conf configurado"
        ((++checks_passed))
    else
        error "✗ colors-dreamcoder.conf no está configurado"
    fi
    
    # Verificar directorios
    if [[ -d "$KITTY_CONFIG_DIR" ]] && [[ -d "$KITTY_THEMES_DIR" ]]; then
        success "✓ Directorios de Kitty configurados"
        ((++checks_passed))
    else
        error "✗ Directorios de Kitty no están configurados"
    fi
    
    # Verificar que Kitty puede ejecutarse
    if kitty --version &>/dev/null; then
        success "✓ Kitty puede ejecutarse correctamente"
        ((++checks_passed))
    else
        error "✗ Kitty no puede ejecutarse"
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
    
    # Crear script de limpieza de caché
    local cleanup_script="$HOME/.local/bin/clean-kitty-cache"
    mkdir -p "$(dirname "$cleanup_script")"
    
    cat > "$cleanup_script" << 'EOF'
#!/bin/bash
# Script para limpiar caché de Kitty
echo "🧹 Limpiando caché de Kitty..."
rm -rf ~/.cache/kitty
rm -rf ~/.local/share/kitty
echo "✅ Caché de Kitty limpiado"
EOF
    
    chmod +x "$cleanup_script"
    success "✅ Script de limpieza creado: $cleanup_script"
    
    # Mostrar información de uso
    show_usage_info
}

# Mostrar información de uso
show_usage_info() {
    echo
    echo -e "${BOLD}${GREEN}🚀 KITTY TERMINAL CONFIGURADO EXITOSAMENTE${COLOR_RESET}"
    echo
    echo -e "${CYAN}📋 Próximos pasos:${COLOR_RESET}"
    echo -e "  1. Reinicia tu terminal o ejecuta: kitty"
    echo -e "  2. Personaliza tu configuración en: $KITTY_CONFIG_DIR/kitty.local.conf"
    echo -e "  3. Crea sesiones personalizadas en: $KITTY_SESSIONS_DIR"
    echo
    echo -e "${YELLOW}💡 Comandos útiles:${COLOR_RESET}"
    echo -e "  - kitty: Abrir nueva ventana"
    echo -e "  - kitty --session $KITTY_SESSIONS_DIR/default.conf: Abrir con sesión"
    echo -e "  - clean-kitty-cache: Limpiar caché"
    echo -e "  - kitty +kitten themes: Cambiar temas"
    echo
    echo -e "${PURPLE}🌟 ¡Disfruta tu nuevo terminal Kitty!${COLOR_RESET}"
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
    
    # Instalar fuentes adicionales
    install_additional_fonts
    
    # Configurar directorios
    setup_kitty_directories
    
    # Configurar archivos
    configure_module_files
    
    # Configurar integración con el sistema
    configure_system_integration
    
    # Verificar instalación
    verify_module_installation
    
    # Configuración post-instalación
    post_installation_setup
    
    echo -e "\n${BOLD}${GREEN}✅ Módulo $MODULE_NAME instalado exitosamente${COLOR_RESET}"
    echo -e "${YELLOW}💡 Para usar Kitty: kitty${COLOR_RESET}"
}

# Ejecutar función principal
main "$@"
