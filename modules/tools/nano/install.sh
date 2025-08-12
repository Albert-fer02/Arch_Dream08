#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM MACHINE - MÓDULO NANO
# =====================================================
# Script de instalación del módulo Nano Editor
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

MODULE_NAME="Nano Editor"
MODULE_DESCRIPTION="Editor de texto con configuración avanzada"
MODULE_DEPENDENCIES=("nano" "git" "curl")
MODULE_FILES=("nanorc.conf")
MODULE_AUR_PACKAGES=()
MODULE_OPTIONAL=true

# Directorios de instalación
NANO_CONFIG_DIR="$HOME/.config/nano"
NANO_SYNTAX_DIR="$NANO_CONFIG_DIR/syntax"
NANO_THEMES_DIR="$NANO_CONFIG_DIR/themes"

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

# Instalar Nano si no está instalado
install_nano() {
    log "Verificando instalación de Nano..."
    
    if command -v nano &>/dev/null; then
        success "✓ Nano ya está instalado"
        return 0
    fi
    
    log "Instalando Nano..."
    install_package "nano"
    
    success "✅ Nano instalado correctamente"
}

# Configurar directorios de Nano
setup_nano_directories() {
    log "Configurando directorios de Nano..."
    
    # Crear directorios necesarios
    mkdir -p "$NANO_CONFIG_DIR" "$NANO_SYNTAX_DIR" "$NANO_THEMES_DIR"
    
    # Establecer permisos correctos
    chmod 755 "$NANO_CONFIG_DIR" "$NANO_SYNTAX_DIR" "$NANO_THEMES_DIR"
    
    success "✅ Directorios de Nano configurados"
}

# Configurar archivos del módulo
configure_module_files() {
    log "Configurando archivos del módulo $MODULE_NAME..."
    
    # Crear symlink para archivo de configuración principal
    create_symlink "$SCRIPT_DIR/nanorc.conf" "$HOME/.nanorc" ".nanorc"
    
    # Crear archivo de configuración local si no existe
    if [[ ! -f "$NANO_CONFIG_DIR/nanorc.local" ]]; then
        cat > "$NANO_CONFIG_DIR/nanorc.local" << 'EOF'
# =====================================================
# 🧩 CONFIGURACIÓN LOCAL DE NANO
# =====================================================
# Personalizaciones específicas del usuario
# Este archivo NO se sobrescribe con actualizaciones
# =====================================================

# Agregar aquí tus personalizaciones
# Ejemplo:
# set linenumbers
# set mouse
# set softwrap

EOF
        success "✅ Archivo de configuración local creado: $NANO_CONFIG_DIR/nanorc.local"
    fi
    
    # Crear archivo de configuración principal en ~/.config/nano
    if [[ ! -f "$NANO_CONFIG_DIR/nanorc" ]]; then
        cat > "$NANO_CONFIG_DIR/nanorc" << 'EOF'
# =====================================================
# 🧩 CONFIGURACIÓN PRINCIPAL DE NANO
# =====================================================
# Configuración global de Nano
# =====================================================

# Incluir configuración principal
include "~/.nanorc"

# Incluir configuración local
include "~/.config/nano/nanorc.local"

# Configuraciones adicionales
set constantshow
set titlecolor brightwhite,blue
set statuscolor brightwhite,green
set keycolor cyan
set functioncolor green
EOF
        success "✅ Archivo de configuración principal creado: $NANO_CONFIG_DIR/nanorc"
    fi
    
    # Crear archivo de configuración para diferentes tipos de archivos
    create_file_type_configs
    
    success "✅ Archivos del módulo configurados"
}

# Crear configuraciones para diferentes tipos de archivos
create_file_type_configs() {
    log "Creando configuraciones para diferentes tipos de archivos..."
    
    # Configuración para archivos de código
    cat > "$NANO_CONFIG_DIR/code.nanorc" << 'EOF'
# Configuración para archivos de código
syntax "code" "\.(c|cpp|h|hpp|js|ts|py|sh|bash|zsh|php|html|css|scss|json|xml|yaml|yml|md|txt)$"

# Colores para código
color brightred "TODO|FIXME|XXX|HACK"
color brightyellow "WARNING|NOTE|INFO"
color brightgreen "DONE|OK|SUCCESS"
color brightblue "DEBUG|TEST|EXAMPLE"
color brightmagenta "FUNCTION|CLASS|METHOD"
color brightcyan "COMMENT|DOCS|HELP"
EOF
    
    # Configuración para archivos de configuración
    cat > "$NANO_CONFIG_DIR/config.nanorc" << 'EOF'
# Configuración para archivos de configuración
syntax "config" "\.(conf|config|ini|cfg|rc|env|properties)$"

# Colores para configuraciones
color brightgreen "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*="
color brightyellow "^[[:space:]]*#[[:space:]]*.*$"
color brightblue "^[[:space:]]*\[.*\]$"
color brightcyan "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*:"
EOF
    
    # Configuración para archivos de log
    cat > "$NANO_CONFIG_DIR/log.nanorc" << 'EOF'
# Configuración para archivos de log
syntax "log" "\.(log|out|err|debug|trace)$"

# Colores para logs
color brightred "ERROR|CRITICAL|FATAL|FAIL"
color brightyellow "WARN|WARNING|ATTENTION"
color brightgreen "INFO|SUCCESS|OK|PASS"
color brightblue "DEBUG|TRACE|VERBOSE"
color brightmagenta "[0-9]{4}-[0-9]{2}-[0-9]{2}"
color brightcyan "[0-9]{2}:[0-9]{2}:[0-9]{2}"
EOF
    
    success "✅ Configuraciones de tipos de archivo creadas"
}

# Configurar integración con el sistema
configure_system_integration() {
    log "Configurando integración con el sistema..."
    
    # Crear alias para Nano
    local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc")
    
    for config in "${shell_configs[@]}"; do
        if [[ -f "$config" ]]; then
            # Verificar si el alias ya existe
            if ! grep -q "alias nano=" "$config"; then
                echo "" >> "$config"
                echo "# Nano aliases" >> "$config"
                echo 'alias nano="nano --rcfile ~/.config/nano/nanorc"' >> "$config"
                echo 'alias nano-code="nano --rcfile ~/.config/nano/code.nanorc"' >> "$config"
                echo 'alias nano-config="nano --rcfile ~/.config/nano/config.nanorc"' >> "$config"
                echo 'alias nano-log="nano --rcfile ~/.config/nano/log.nanorc"' >> "$config"
                echo 'alias nano-edit="nano --rcfile ~/.config/nano/nanorc.local"' >> "$config"
                success "✅ Aliases agregados a $config"
            else
                success "✓ Aliases ya existen en $config"
            fi
        fi
    done
    
    # Crear script de configuración interactiva
    local config_script="$HOME/.local/bin/nano-config"
    mkdir -p "$(dirname "$config_script")"
    
    cat > "$config_script" << 'EOF'
#!/bin/bash
# Script para configurar Nano interactivamente
echo "🎨 Configurando Nano..."

# Mostrar opciones disponibles
echo "Configuraciones disponibles:"
echo "1. Código (sintaxis resaltada para programación)"
echo "2. Configuración (archivos .conf, .ini, etc.)"
echo "3. Logs (archivos .log con colores especiales)"
echo "4. Configuración local (personalizada)"
echo "5. Configuración por defecto"

read -p "Selecciona una configuración (1-5): " choice

case $choice in
    1)
        nano --rcfile ~/.config/nano/code.nanorc "$1"
        ;;
    2)
        nano --rcfile ~/.config/nano/config.nanorc "$1"
        ;;
    3)
        nano --rcfile ~/.config/nano/log.nanorc "$1"
        ;;
    4)
        nano --rcfile ~/.config/nano/nanorc.local "$1"
        ;;
    5)
        nano --rcfile ~/.config/nano/nanorc "$1"
        ;;
    *)
        echo "Opción inválida"
        ;;
esac
EOF
    
    chmod +x "$config_script"
    success "✅ Script de configuración creado: $config_script"
    
    # Crear script de limpieza de caché
    local cleanup_script="$HOME/.local/bin/clean-nano-cache"
    
    cat > "$cleanup_script" << 'EOF'
#!/bin/bash
# Script para limpiar caché de Nano
echo "🧹 Limpiando caché de Nano..."
rm -rf ~/.cache/nano
rm -rf ~/.local/share/nano
echo "✅ Caché de Nano limpiado"
EOF
    
    chmod +x "$cleanup_script"
    success "✅ Script de limpieza creado: $cleanup_script"
    
    success "✅ Integración con el sistema configurada"
}

# Verificar instalación del módulo
verify_module_installation() {
    log "Verificando instalación del módulo $MODULE_NAME..."
    
    local checks_passed=0
    local total_checks=6
    
    # Verificar Nano instalado
    if command -v nano &>/dev/null; then
        success "✓ Nano instalado"
        ((++checks_passed))
    else
        error "✗ Nano no está instalado"
    fi
    
    # Verificar archivo de configuración principal
    if [[ -L "$HOME/.nanorc" ]] && [[ -e "$HOME/.nanorc" ]]; then
        success "✓ .nanorc configurado"
        ((++checks_passed))
    else
        error "✗ .nanorc no está configurado"
    fi
    
    # Verificar directorios
    if [[ -d "$NANO_CONFIG_DIR" ]] && [[ -d "$NANO_SYNTAX_DIR" ]]; then
        success "✓ Directorios de Nano configurados"
        ((++checks_passed))
    else
        error "✗ Directorios de Nano no están configurados"
    fi
    
    # Verificar archivo de configuración principal
    if [[ -f "$NANO_CONFIG_DIR/nanorc" ]]; then
        success "✓ nanorc principal configurado"
        ((++checks_passed))
    else
        error "✗ nanorc principal no está configurado"
    fi
    
    # Verificar configuraciones de tipos de archivo
    local config_files=("code.nanorc" "config.nanorc" "log.nanorc")
    local config_count=0
    for config in "${config_files[@]}"; do
        if [[ -f "$NANO_CONFIG_DIR/$config" ]]; then
            ((config_count++))
        fi
    done
    
    if [[ $config_count -eq ${#config_files[@]} ]]; then
        success "✓ Configuraciones de tipos de archivo creadas"
        ((++checks_passed))
    else
        error "✗ Configuraciones de tipos de archivo incompletas ($config_count/${#config_files[@]})"
    fi
    
    # Verificar que Nano puede ejecutarse
    if nano --version &>/dev/null; then
        success "✓ Nano puede ejecutarse correctamente"
        ((++checks_passed))
    else
        error "✗ Nano no puede ejecutarse"
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
    
    # Mostrar información de uso
    show_usage_info
}

# Mostrar información de uso
show_usage_info() {
    echo
    echo -e "${BOLD}${GREEN}🚀 NANO EDITOR CONFIGURADO EXITOSAMENTE${COLOR_RESET}"
    echo
    echo -e "${CYAN}📋 Próximos pasos:${COLOR_RESET}"
    echo -e "  1. Ejecuta: nano para usar el editor"
    echo -e "  2. Personaliza tu configuración en: $NANO_CONFIG_DIR/nanorc.local"
    echo -e "  3. Usa los aliases para diferentes tipos de archivo"
    echo
    echo -e "${YELLOW}💡 Comandos útiles:${COLOR_RESET}"
    echo -e "  - nano: Editor con configuración personalizada"
    echo -e "  - nano-code: Para archivos de código"
    echo -e "  - nano-config: Para archivos de configuración"
    echo -e "  - nano-log: Para archivos de log"
    echo -e "  - nano-edit: Para edición personalizada"
    echo -e "  - nano-config: Configuración interactiva"
    echo -e "  - clean-nano-cache: Limpiar caché"
    echo
    echo -e "${PURPLE}🌟 ¡Disfruta tu nuevo editor Nano!${COLOR_RESET}"
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
    
    # Instalar Nano
    install_nano
    
    # Configurar directorios
    setup_nano_directories
    
    # Configurar archivos
    configure_module_files
    
    # Configurar integración con el sistema
    configure_system_integration
    
    # Verificar instalación (no abortar si es parcial)
    if ! verify_module_installation; then
        warn "Continuando pese a verificación parcial del módulo $MODULE_NAME"
    fi
    
    # Configuración post-instalación
    post_installation_setup
    
    echo -e "\n${BOLD}${GREEN}✅ Módulo $MODULE_NAME instalado exitosamente${COLOR_RESET}"
    echo -e "${YELLOW}💡 Para usar Nano: nano${COLOR_RESET}"
}

# Ejecutar función principal
main "$@" 