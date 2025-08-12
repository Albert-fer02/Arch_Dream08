#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM MACHINE - MÓDULO ZSH
# =====================================================
# Script de instalación del módulo Zsh con Starship y Zinit (Red Team Optimized)
# Versión 3.0 - Instalación idempotente y ultra-optimizada
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# =====================================================
# 🔧 CONFIGURACIÓN DEL MÓDULO
# =====================================================

MODULE_NAME="Zsh Red Team Configuration"
MODULE_DESCRIPTION="Configuración ultra-optimizada de Zsh con Starship y Zinit para Red Team"
MODULE_DEPENDENCIES=("zsh" "git" "curl" "wget" "starship")
MODULE_FILES=("zshrc" "zshrc.root")
MODULE_AUR_PACKAGES=("starship-bin")
MODULE_OPTIONAL=false

# URLs de instalación
ZINIT_URL="https://github.com/zdharma-continuum/zinit.git"
STARSHIP_INSTALL_URL="https://starship.rs/install.sh"

# Directorios de instalación
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"
ZSH_CACHE_DIR="$HOME/.zsh"
ZSH_COMPDUMP_DIR="$ZSH_CACHE_DIR/compdump"
STARSHIP_CONFIG_DIR="$HOME/.config"

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

# Instalar Starship
install_starship() {
    log "Instalando Starship..."
    
    if command -v starship &>/dev/null; then
        success "✓ Starship ya está instalado"
        return 0
    fi
    
    # Intentar instalar desde repositorios de Arch primero
    if install_package "starship"; then
        success "✅ Starship instalado desde repositorio"
        return 0
    fi
    
    # Si falla, instalar desde AUR
    log "Instalando Starship desde AUR..."
    if command -v yay &>/dev/null; then
        yay -S --noconfirm starship-bin
    elif command -v paru &>/dev/null; then
        paru -S --noconfirm starship-bin
    else
        # Último recurso: instalación manual
        log "Instalando Starship manualmente..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
    fi
    
    if command -v starship &>/dev/null; then
        success "✅ Starship instalado correctamente"
    else
        error "❌ Fallo al instalar Starship"
        return 1
    fi
}

# Instalar Zinit
install_zinit() {
    log "Instalando Zinit plugin manager..."
    
    if [[ -d "$ZINIT_HOME/zinit.git" ]]; then
        success "✓ Zinit ya está instalado"
        return 0
    fi
    
    # Crear directorio de Zinit
    mkdir -p "$(dirname "$ZINIT_HOME")"
    
    # Clonar Zinit
    if git clone --depth=1 "$ZINIT_URL" "$ZINIT_HOME/zinit.git"; then
        success "✅ Zinit instalado correctamente"
    else
        error "❌ Fallo al instalar Zinit"
        return 1
    fi
}

# Instalar herramientas adicionales para Red Team
install_redteam_tools() {
    log "Instalando herramientas adicionales para Red Team..."
    
    local tools=(
        "bat"           # Better cat
        "eza"           # Better ls
        "ripgrep"       # Better grep
        "fd"            # Better find
        "fzf"           # Fuzzy finder
        "btop"          # Better top
        "duf"           # Better df
        "dust"          # Better du
        "delta"         # Better diff
        "xh"            # Better curl/http
        "procs"         # Better ps
    )
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            success "✓ $tool ya está instalado"
        else
            log "Instalando $tool..."
            install_package "$tool" || warn "⚠️  No se pudo instalar $tool"
        fi
    done
    
    success "✅ Herramientas adicionales instaladas"
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
    
    # Crear directorio de configuración de Starship
    mkdir -p "$STARSHIP_CONFIG_DIR"
    
    # Crear symlinks para archivos de configuración
    create_symlink "$SCRIPT_DIR/zshrc" "$HOME/.zshrc" ".zshrc"
    
    # Copiar configuración de Starship si no existe o es diferente
    local starship_source="$SCRIPT_DIR/../bash/starship.toml"
    local starship_dest="$STARSHIP_CONFIG_DIR/starship.toml"
    
    if [[ ! -f "$starship_dest" ]] || ! cmp -s "$starship_source" "$starship_dest"; then
        cp "$starship_source" "$starship_dest"
        success "✅ Configuración de Starship copiada"
    else
        success "✅ Configuración de Starship ya está actualizada"
    fi
    
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
    fi
    
    # Crear archivo de configuración local si no existe
    if [[ ! -f "$HOME/.zshrc.local" ]]; then
        cat > "$HOME/.zshrc.local" << 'EOF'
# =====================================================
# 🧩 CONFIGURACIÓN LOCAL DE ZSH - RED TEAM
# =====================================================
# Personalizaciones específicas del usuario
# Este archivo NO se sobrescribe con actualizaciones
# =====================================================

# Variables de entorno personalizadas
# export TARGET=""
# export PROXY=""

# Aliases personalizados
# alias custom="comando personalizado"

# Funciones personalizadas
# custom_function() {
#     echo "Mi función personalizada"
# }

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
    
    # Verificar Starship instalado
    if command -v starship &>/dev/null; then
        success "✓ Starship instalado"
        ((++checks_passed))
    else
        error "✗ Starship no está instalado"
    fi
    
    # Verificar Zinit instalado
    if [[ -d "$ZINIT_HOME/zinit.git" ]]; then
        success "✓ Zinit instalado"
        ((++checks_passed))
    else
        error "✗ Zinit no está instalado"
    fi
    
    # Verificar .zshrc
    if [[ -L "$HOME/.zshrc" ]] && [[ -e "$HOME/.zshrc" ]]; then
        success "✓ .zshrc configurado"
        ((++checks_passed))
    else
        error "✗ .zshrc no está configurado"
    fi
    
    # Verificar configuración de Starship
    if [[ -f "$STARSHIP_CONFIG_DIR/starship.toml" ]]; then
        success "✓ Starship configurado"
        ((++checks_passed))
    else
        error "✗ Starship no está configurado"
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
    echo -e "${BOLD}${GREEN}🎯 ZSH RED TEAM CONFIGURADO EXITOSAMENTE${COLOR_RESET}"
    echo
    echo -e "${CYAN}📋 Próximos pasos:${COLOR_RESET}"
    echo -e "  1. Reinicia tu terminal o ejecuta: exec zsh"
    echo -e "  2. Personaliza tu configuración en: ~/.zshrc.local"
    echo -e "  3. Configura variables Red Team: set-target <ip>"
    echo
    echo -e "${YELLOW}💡 Comandos Red Team útiles:${COLOR_RESET}"
    echo -e "  - redteam-info: Mostrar información de red"
    echo -e "  - set-target <ip>: Configurar objetivo"
    echo -e "  - portscan <ip>: Escaneo rápido de puertos"
    echo -e "  - direnum <url>: Enumeración de directorios"
    echo
    echo -e "${RED}🔐 Funciones de seguridad:${COLOR_RESET}"
    echo -e "  - b64e/b64d: Codificar/decodificar base64"
    echo -e "  - urle/urld: Codificar/decodificar URL"
    echo -e "  - passgen: Generar contraseñas"
    echo
    echo -e "${PURPLE}🌟 ¡Disfruta tu nueva configuración Red Team!${COLOR_RESET}"
}

# =====================================================
# 🏁 FUNCIÓN PRINCIPAL
# =====================================================

main() {
    # Inicializar biblioteca
    init_library
    
    # Banner
    echo -e "${BOLD}${CYAN}🎯 INSTALANDO MÓDULO: $MODULE_NAME${COLOR_RESET}"
    echo -e "${CYAN}$MODULE_DESCRIPTION${COLOR_RESET}\n"
    
    # Instalar dependencias
    install_module_dependencies
    
    # Instalar Starship
    install_starship
    
    # Instalar Zinit
    install_zinit
    
    # Instalar herramientas Red Team
    install_redteam_tools
    
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
    echo -e "${YELLOW}🎯 Para usar Zsh Red Team: exec zsh${COLOR_RESET}"
}

# Ejecutar función principal
main "$@"
