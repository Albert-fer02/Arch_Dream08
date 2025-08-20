#!/bin/bash
# =====================================================
# 📦 ARCH DREAM - GESTOR DE PAQUETES OPTIMIZADO
# =====================================================
# Sistema de gestión de paquetes para Arch Linux
# Instalación inteligente con fallbacks y optimizaciones
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# =====================================================
# 🔧 CONFIGURACIÓN DEL GESTOR DE PAQUETES
# =====================================================

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh" 2>/dev/null || {
    echo "Error: No se pudo cargar common.sh" >&2
    exit 1
}

# Configuración de paquetes
PACMAN_CONF="/etc/pacman.conf"
PACMAN_CACHE_DIR="/var/cache/pacman/pkg"
AUR_HELPERS=("yay" "paru" "pikaur" "aurman")
PACKAGE_CACHE_FILE="/tmp/arch-dream-packages.cache"
CACHE_TTL=1800  # 30 minutos

# =====================================================
# 🔍 FUNCIONES DE DETECCIÓN Y VERIFICACIÓN
# =====================================================

# Detectar helper de AUR disponible
detect_aur_helper() {
    for helper in "${AUR_HELPERS[@]}"; do
        if command -v "$helper" &>/dev/null; then
            echo "$helper"
            return 0
        fi
    done
    return 1
}

# Verificar si un paquete está instalado
is_package_installed() {
    local package="$1"
    pacman -Q "$package" &>/dev/null
}

# Verificar si un paquete existe en repositorios oficiales
package_exists_official() {
    local package="$1"
    pacman -Ss "^$package$" &>/dev/null
}

# Verificar si un paquete existe en AUR
package_exists_aur() {
    local package="$1"
    local helper=$(detect_aur_helper)
    [[ -n "$helper" ]] || return 1
    
    case "$helper" in
        "yay") yay -Ss "^$package$" &>/dev/null ;;
        "paru") paru -Ss "^$package$" &>/dev/null ;;
        "pikaur") pikaur -Ss "^$package$" &>/dev/null ;;
        "aurman") aurman -Ss "^$package$" &>/dev/null ;;
    esac
}

# =====================================================
# 📦 FUNCIONES DE INSTALACIÓN DE PAQUETES
# =====================================================

# Instalar paquete desde repositorios oficiales
install_official_package() {
    local package="$1"
    local options="${2:-}"
    
    log "Instalando paquete oficial: $package"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        success "DRY RUN: $package sería instalado desde repositorios oficiales"
        return 0
    fi
    
    # Opciones de instalación
    local pacman_opts="--noconfirm --needed"
    [[ -n "$options" ]] && pacman_opts="$pacman_opts $options"
    
    if sudo pacman -S $pacman_opts "$package"; then
        success "✅ $package instalado desde repositorios oficiales"
        return 0
    else
        error "❌ Fallo al instalar $package desde repositorios oficiales"
        return 1
    fi
}

# Instalar paquete desde AUR
install_aur_package() {
    local package="$1"
    local options="${2:-}"
    
    local helper=$(detect_aur_helper)
    [[ -n "$helper" ]] || {
        error "❌ No hay helper de AUR disponible para instalar $package"
        return 1
    }
    
    log "Instalando paquete AUR: $package (usando $helper)"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        success "DRY RUN: $package sería instalado desde AUR usando $helper"
        return 0
    fi
    
    # Opciones de instalación
    local aur_opts="--noconfirm --needed"
    [[ -n "$options" ]] && aur_opts="$aur_opts $options"
    
    case "$helper" in
        "yay")
            if yay -S $aur_opts "$package"; then
                success "✅ $package instalado desde AUR usando yay"
                return 0
            fi
            ;;
        "paru")
            if paru -S $aur_opts "$package"; then
                success "✅ $package instalado desde AUR usando paru"
                return 0
            fi
            ;;
        "pikaur")
            if pikaur -S $aur_opts "$package"; then
                success "✅ $package instalado desde AUR usando pikaur"
                return 0
            fi
            ;;
        "aurman")
            if aurman -S $aur_opts "$package"; then
                success "✅ $package instalado desde AUR usando aurman"
                return 0
            fi
            ;;
    esac
    
    error "❌ Fallo al instalar $package desde AUR"
    return 1
}

# Instalar paquete con fallback inteligente
install_package() {
    local package="$1"
    local options="${2:-}"
    
    # Limpiar nombre del paquete
    package=$(echo "$package" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [[ -n "$package" ]] || return 1
    
    # Verificar si ya está instalado
    if is_package_installed "$package"; then
        success "✓ $package ya está instalado"
        return 0
    fi
    
    # Intentar desde repositorios oficiales primero
    if package_exists_official "$package"; then
        install_official_package "$package" "$options" && return 0
    fi
    
    # Fallback a AUR
    if package_exists_aur "$package"; then
        warn "⚠️  $package no encontrado en repositorios oficiales, intentando desde AUR..."
        install_aur_package "$package" "$options" && return 0
    fi
    
    # Si no se encuentra en ningún lado
    error "❌ $package no encontrado en repositorios oficiales ni en AUR"
    return 1
}

# Instalar múltiples paquetes de manera eficiente
install_packages() {
    local packages=("$@")
    local failed_packages=()
    local installed_count=0
    
    log "Instalando ${#packages[@]} paquetes..."
    
    # Agrupar paquetes por tipo (oficial vs AUR)
    local official_packages=()
    local aur_packages=()
    
    for package in "${packages[@]}"; do
        if package_exists_official "$package"; then
            official_packages+=("$package")
        elif package_exists_aur "$package"; then
            aur_packages+=("$package")
        else
            warn "⚠️  $package no encontrado en ningún repositorio"
            failed_packages+=("$package")
        fi
    done
    
    # Instalar paquetes oficiales en lote
    if [[ ${#official_packages[@]} -gt 0 ]]; then
        log "Instalando ${#official_packages[@]} paquetes oficiales..."
        if [[ "$DRY_RUN" != "true" ]]; then
            if sudo pacman -S --noconfirm --needed "${official_packages[@]}"; then
                installed_count=$((installed_count + ${#official_packages[@]}))
                success "✅ ${#official_packages[@]} paquetes oficiales instalados"
            else
                failed_packages+=("${official_packages[@]}")
            fi
        else
            success "DRY RUN: ${#official_packages[@]} paquetes oficiales serían instalados"
            installed_count=$((installed_count + ${#official_packages[@]}))
        fi
    fi
    
    # Instalar paquetes AUR uno por uno (más seguro)
    if [[ ${#aur_packages[@]} -gt 0 ]]; then
        log "Instalando ${#aur_packages[@]} paquetes AUR..."
        for package in "${aur_packages[@]}"; do
            if install_aur_package "$package"; then
                ((installed_count++))
            else
                failed_packages+=("$package")
            fi
        done
    fi
    
    # Resumen
    if [[ ${#failed_packages[@]} -eq 0 ]]; then
        success "✅ Todos los paquetes instalados correctamente ($installed_count total)"
        return 0
    else
        warn "⚠️  ${#failed_packages[@]} paquetes fallaron: ${failed_packages[*]}"
        return 1
    fi
}

# =====================================================
# 🔧 FUNCIONES DE MANTENIMIENTO DEL SISTEMA
# =====================================================

# Actualizar sistema
update_system() {
    log "🔄 Actualizando sistema..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        success "DRY RUN: Sistema sería actualizado"
        return 0
    fi
    
    # Actualizar bases de datos
    if sudo pacman -Sy; then
        success "✅ Bases de datos de paquetes actualizadas"
    else
        error "❌ Fallo al actualizar bases de datos"
        return 1
    fi
    
    # Actualizar paquetes del sistema
    if sudo pacman -Su --noconfirm; then
        success "✅ Sistema actualizado correctamente"
        return 0
    else
        error "❌ Fallo al actualizar sistema"
        return 1
    fi
}

# Limpiar caché de paquetes
clean_package_cache() {
    log "🧹 Limpiando caché de paquetes..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        success "DRY RUN: Caché sería limpiado"
        return 0
    fi
    
    # Limpiar paquetes no instalados
    if sudo pacman -Sc --noconfirm; then
        success "✅ Caché de paquetes limpiado"
        return 0
    else
        warn "⚠️  No se pudo limpiar caché de paquetes"
        return 1
    fi
}

# Optimizar base de datos de paquetes
optimize_package_database() {
    log "⚡ Optimizando base de datos de paquetes..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        success "DRY RUN: Base de datos sería optimizada"
        return 0
    fi
    
    # Optimizar base de datos
    if sudo pacman-optimize; then
        success "✅ Base de datos de paquetes optimizada"
        return 0
    else
        warn "⚠️  No se pudo optimizar base de datos"
        return 1
    fi
}

# =====================================================
# 🔍 FUNCIONES DE INFORMACIÓN Y ESTADO
# =====================================================

# Mostrar información de paquete
show_package_info() {
    local package="$1"
    
    echo -e "${CYAN}📦 Información del paquete: $package${NC}"
    echo "─────────────────────────────────────────────────────────"
    
    # Información de instalación
    if is_package_installed "$package"; then
        local version=$(pacman -Q "$package" | awk '{print $2}')
        echo -e "Estado: ${GREEN}Instalado${NC} (versión: $version)"
        
        # Información detallada
        echo -e "\n${YELLOW}Detalles del paquete:${NC}"
        pacman -Qi "$package" | grep -E "^(Description|URL|Licenses|Depends On|Required By)" | head -10
    else
        echo -e "Estado: ${RED}No instalado${NC}"
        
        # Buscar en repositorios
        echo -e "\n${YELLOW}Buscando en repositorios:${NC}"
        if package_exists_official "$package"; then
            echo -e "Repositorio: ${GREEN}Oficial${NC}"
            pacman -Ss "^$package$" | head -3
        elif package_exists_aur "$package"; then
            echo -e "Repositorio: ${YELLOW}AUR${NC}"
            local helper=$(detect_aur_helper)
            [[ -n "$helper" ]] && {
                case "$helper" in
                    "yay") yay -Ss "^$package$" | head -3 ;;
                    "paru") paru -Ss "^$package$" | head -3 ;;
                    "pikaur") pikaur -Ss "^$package$" | head -3 ;;
                    "aurman") aurman -Ss "^$package$" | head -3 ;;
                esac
            }
        else
            echo -e "Repositorio: ${RED}No encontrado${NC}"
        fi
    fi
}

# Listar paquetes instalados por el usuario
list_user_installed_packages() {
    log "📋 Listando paquetes instalados por el usuario..."
    
    local packages=$(pacman -Qeq | sort)
    local count=$(echo "$packages" | wc -l)
    
    echo -e "${CYAN}Paquetes instalados por el usuario ($count total):${NC}"
    echo "$packages" | nl | head -20
    
    if [[ $count -gt 20 ]]; then
        echo -e "${YELLOW}... y $((count - 20)) más${NC}"
        echo -e "${CYAN}Para ver todos: pacman -Qeq | sort${NC}"
    fi
}

# Verificar dependencias rotas
check_broken_dependencies() {
    log "🔍 Verificando dependencias rotas..."
    
    local broken_deps=$(pacman -Dk 2>&1 | grep "broken" || true)
    
    if [[ -z "$broken_deps" ]]; then
        success "✅ No se encontraron dependencias rotas"
        return 0
    else
        warn "⚠️  Se encontraron dependencias rotas:"
        echo "$broken_deps"
        return 1
    fi
}

# =====================================================
# 🚀 FUNCIÓN PRINCIPAL DEL GESTOR DE PAQUETES
# =====================================================

# Inicializar gestor de paquetes
init_package_manager() {
    log "🚀 Inicializando gestor de paquetes..."
    
    # Verificar permisos sudo
    if ! sudo -n true 2>/dev/null; then
        warn "⚠️  Se requieren permisos sudo para operaciones de paquetes"
        if ! sudo -v; then
            error "❌ No se pudieron obtener permisos sudo"
            return 1
        fi
    fi
    
    # Verificar conexión a internet
    if ! ping -c 1 -W 3 archlinux.org &>/dev/null; then
        warn "⚠️  Sin conexión a internet - algunas operaciones pueden fallar"
    fi
    
    # Detectar helper de AUR
    local aur_helper=$(detect_aur_helper)
    if [[ -n "$aur_helper" ]]; then
        success "✅ Helper de AUR detectado: $aur_helper"
    else
        warn "⚠️  No se detectó helper de AUR - paquetes AUR no estarán disponibles"
    fi
    
    # Verificar estado del sistema
    check_broken_dependencies || warn "⚠️  Se encontraron problemas de dependencias"
    
    success "✅ Gestor de paquetes inicializado correctamente"
}

# =====================================================
# 📋 FUNCIONES DE UTILIDAD
# =====================================================

# Función de ayuda
show_package_manager_help() {
    cat << EOF
📦 Arch Dream Package Manager

${BOLD}FUNCIONES DISPONIBLES:${NC}
    install_package <paquete>           # Instalar paquete con fallback inteligente
    install_packages <paq1> <paq2>...   # Instalar múltiples paquetes
    install_official_package <paquete>  # Instalar solo desde repositorios oficiales
    install_aur_package <paquete>       # Instalar solo desde AUR
    update_system                        # Actualizar sistema completo
    clean_package_cache                  # Limpiar caché de paquetes
    optimize_package_database            # Optimizar base de datos
    show_package_info <paquete>         # Mostrar información de paquete
    list_user_installed_packages        # Listar paquetes del usuario
    check_broken_dependencies            # Verificar dependencias rotas

${BOLD}EJEMPLOS:${NC}
    install_package "neovim"            # Instalar neovim con fallback
    install_packages "git" "vim" "htop" # Instalar múltiples paquetes
    update_system                        # Actualizar sistema
    show_package_info "zsh"             # Información de zsh

${BOLD}VARIABLES DE ENTORNO:${NC}
    DRY_RUN=true                        # Modo simulación
    FORCE_INSTALL=true                  # Forzar instalación
EOF
}

# Exportar funciones principales
export -f install_package install_packages install_official_package install_aur_package
export -f update_system clean_package_cache optimize_package_database
export -f show_package_info list_user_installed_packages check_broken_dependencies
export -f init_package_manager show_package_manager_help

# Si se ejecuta directamente, mostrar ayuda
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
    show_package_manager_help
    exit 0
}
