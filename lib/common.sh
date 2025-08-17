#!/bin/bash
# ---------------------------------------------------------------------
# ╔═════════════════════════════════════════════════════════════════╗
# ║                     𓂀 DreamCoder 08 𓂀                         ║
# ║                ⚡ Digital Dream Architect ⚡                     ║
# ║                                                                ║
# ║        Author: https://github.com/Albert-fer02                 ║
# ╚═════════════════════════════════════════════════════════════════╝
# ---------------------------------------------------------------------    
# =====================================================
# 🧩 Arch Dream Machine - Biblioteca Común MEJORADA
# =====================================================
# Funciones reutilizables para todos los módulos
# Versión 2.0 - Mejorada con validaciones avanzadas
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# =====================================================
# 🎨 SISTEMA DE COLORES Y LOGGING MEJORADO
# =====================================================

# Colores ANSI mejorados con más opciones
AQUA='\033[38;5;51m'
GREEN='\033[38;5;118m'
CYAN='\033[38;5;87m'
PURPLE='\033[38;5;147m'
YELLOW='\033[38;5;226m'
RED='\033[38;5;196m'
ORANGE='\033[38;5;208m'
BLUE='\033[38;5;33m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
COLOR_RESET='\033[0m'

# Variables de control de logging
LOG_LEVEL=${LOG_LEVEL:-"INFO"}  # DEBUG, INFO, WARN, ERROR
LOG_TIMESTAMP=${LOG_TIMESTAMP:-"true"}
LOG_COLORS=${LOG_COLORS:-"true"}

# Función para obtener timestamp
get_timestamp() {
    if [[ "$LOG_TIMESTAMP" == "true" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')]"
    else
        echo ""
    fi
}

# Función para formatear mensaje con colores
format_message() {
    local level="$1"
    local message="$2"
    local color="$3"
    local timestamp=$(get_timestamp)
    
    if [[ "$LOG_COLORS" == "true" ]]; then
        echo -e "${color}${timestamp}[${level}]${COLOR_RESET} $message"
    else
        echo "${timestamp}[${level}] $message"
    fi
}

# Funciones de logging mejoradas
debug() {
    if [[ "$LOG_LEVEL" == "DEBUG" ]]; then
        format_message "DEBUG" "$1" "$DIM"
    fi
}

log() { 
    format_message "INFO" "$1" "$CYAN"
}

success() { 
    format_message "SUCCESS" "$1" "$GREEN"
}

warn() { 
    format_message "WARN" "$1" "$YELLOW"
}

error() { 
    format_message "ERROR" "$1" "$RED"
}

critical() {
    format_message "CRITICAL" "$1" "$RED$BOLD"
}

# Función para mostrar progreso
show_progress() {
    local current="$1"
    local total="$2"
    local description="$3"
    local percentage=$((current * 100 / total))
    local bars=$((percentage / 2))
    local spaces=$((50 - bars))
    
    printf "\r${CYAN}[${description}]${COLOR_RESET} ["
    printf "%${bars}s" | tr ' ' '█'
    printf "%${spaces}s" | tr ' ' ' '
    printf "] %d%% (%d/%d)" "$percentage" "$current" "$total"
    
    if [[ $current -eq $total ]]; then
        echo
    fi
}

# Función para mostrar spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r${CYAN}[%c]${COLOR_RESET} Procesando..." "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r${GREEN}[✓]${COLOR_RESET} Completado!    \n"
}

# =====================================================
# 🔧 FUNCIONES DE SISTEMA MEJORADAS
# =====================================================

# Verificar si es Arch Linux con más detalles
is_arch_linux() {
    if [[ -f /etc/arch-release ]] || command -v pacman &>/dev/null; then
        debug "Sistema detectado como Arch Linux"
        return 0
    else
        debug "Sistema NO es Arch Linux"
        return 1
    fi
}

# Verificar versión de Arch Linux
get_arch_version() {
    if [[ -f /etc/arch-release ]]; then
        cat /etc/arch-release
    else
        echo "unknown"
    fi
}

# Verificar permisos sudo con timeout
check_sudo() {
    # Si ya hay credenciales en caché, salir
    if sudo -n true 2>/dev/null; then
        debug "Permisos sudo ya disponibles"
        return 0
    fi

    # Pedir credenciales sin timeout para no cortar la escritura
    warn "Solicitando permisos sudo (la contraseña no se muestra al escribir)..."
    if sudo -v; then
        success "Permisos sudo obtenidos"
        return 0
    fi

    # Reintento único por si hubo error tipográfico
    warn "Intento adicional de autenticación sudo..."
    if sudo -v; then
        success "Permisos sudo obtenidos"
        return 0
    else
        error "No se pudieron obtener permisos sudo"
        return 1
    fi
}

# Verificar conexión a internet con múltiples endpoints
check_internet() {
    local endpoints=("archlinux.org" "google.com" "github.com")
    local timeout=${1:-5}
    
    for endpoint in "${endpoints[@]}"; do
        if ping -c 1 -W "$timeout" "$endpoint" &>/dev/null; then
            debug "Conexión a internet verificada con $endpoint"
            return 0
        fi
    done
    
    error "Sin conexión a internet. Verifica tu conexión."
    return 1
}

# Verificar espacio en disco con más opciones
check_disk_space() {
    local min_space=${1:-1048576}  # 1GB por defecto
    local path=${2:-/}
    # En modo simulación, no bloquear por espacio
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        debug "DRY-RUN: omitiendo verificación de espacio en disco"
        return 0
    fi
    local available_space=$(df "$path" | awk 'NR==2 {print $4}')
    local total_space=$(df "$path" | awk 'NR==2 {print $2}')
    local used_percent=$(df "$path" | awk 'NR==2 {print $5}' | sed 's/%//')
    
    debug "Espacio disponible: $(($available_space / 1024))MB"
    debug "Espacio total: $(($total_space / 1024))MB"
    debug "Uso: ${used_percent}%"
    
    if [ "$available_space" -lt "$min_space" ]; then
        warn "Poco espacio en disco: $(($available_space / 1024))MB disponible"
        warn "Uso actual: ${used_percent}%"
        # Respetar modo no interactivo
        if [[ "${FORCE_INSTALL:-false}" == "true" ]] || [[ "${YES:-false}" == "true" ]]; then
            warn "Continuando pese a bajo espacio por FORCE_INSTALL/YES"
        else
            read -p "¿Continuar? (y/N): " -n 1 -r
            echo
            [[ ! $REPLY =~ ^[Yy]$ ]] && return 1
        fi
    fi
}

# Verificar memoria RAM disponible
check_memory() {
    local min_memory=${1:-1048576}  # 1GB por defecto
    local available_memory=$(free | awk 'NR==2{print $7}')
    
    debug "Memoria disponible: $(($available_memory / 1024))MB"
    
    if [ "$available_memory" -lt "$min_memory" ]; then
        warn "Poca memoria RAM: $(($available_memory / 1024))MB disponible"
        return 1
    fi
}

# Verificar CPU y carga del sistema
check_system_load() {
    local max_load=${1:-5.0}
    local current_load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')

    debug "Carga actual del sistema: $current_load"

    # Comparación de floats sin depender de bc
    if awk -v a="$current_load" -v b="$max_load" 'BEGIN{exit (a>b)?0:1}'; then
        warn "Alta carga del sistema: $current_load"
        return 1
    fi
}

# =====================================================
# 📦 GESTIÓN DE PAQUETES MEJORADA
# =====================================================

# Instalar paquete con verificación mejorada
install_package() {
    local package="$1"
    local description="${2:-$package}"
    local force="${3:-false}"
    
    if pacman -Q "$package" &>/dev/null; then
        success "$description ya está instalado."
        return 0
    fi
    
    log "Instalando $description..."
    
    # Verificar si el paquete existe en los repositorios oficiales
    if ! pacman -Si "$package" >/dev/null 2>&1; then
        error "Paquete $package no encontrado en los repositorios"
        return 1
    fi
    
    # Instalar sin preguntar y evitando reinstalar si ya está
    if ! sudo pacman -S --noconfirm --needed "$package"; then
        error "Fallo al instalar $description"
        return 1
    fi
    
    success "$description instalado correctamente."
}

# Instalar paquete AUR con detección automática de helper
install_aur_package() {
    local package="$1"
    local description="${2:-$package}"
    
    if pacman -Q "$package" &>/dev/null; then
        success "$description ya está instalado."
        return 0
    fi
    
    # Detectar AUR helper
    local aur_helper=""
    if command -v yay &>/dev/null; then
        aur_helper="yay"
    elif command -v paru &>/dev/null; then
        aur_helper="paru"
    else
        error "No se encontró AUR helper (yay o paru)"
        return 1
    fi
    
    log "Instalando $description desde AUR usando $aur_helper..."
    
    if $aur_helper -S --noconfirm --needed "$package" &>/dev/null; then
        success "$description instalado correctamente desde AUR."
    else
        error "Fallo al instalar $description desde AUR"
        return 1
    fi
}

# Actualizar sistema de manera segura
update_system() {
    local force="${1:-false}"
    
    log "Actualizando sistema..."
    
    # Verificar espacio antes de actualizar
    check_disk_space 2097152  # 2GB mínimo para actualizaciones
    
    if [[ "$force" == "true" ]]; then
        sudo pacman -Syu --noconfirm || {
            error "Fallo al actualizar sistema"
            return 1
        }
    else
        sudo pacman -Syu || {
            error "Fallo al actualizar sistema"
            return 1
        }
    fi
    
    success "Sistema actualizado correctamente."
}

# Limpiar caché de paquetes
clean_package_cache() {
    log "Limpiando caché de paquetes..."
    
    local cache_size=$(du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1)
    debug "Tamaño del caché: $cache_size"
    
    sudo pacman -Sc --noconfirm || {
        warn "No se pudo limpiar completamente el caché"
        return 1
    }
    
    success "Caché de paquetes limpiado."
}

# =====================================================
# 🔧 FUNCIONES DE ARCHIVOS Y DIRECTORIOS
# =====================================================

# Crear backup seguro
create_backup() {
    local source="$1"
    local backup_dir="${2:-$HOME/.backups}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="$(basename "$source")_$timestamp"
    local backup_path="$backup_dir/$backup_name"
    
    if [[ ! -e "$source" ]]; then
        debug "Archivo $source no existe, saltando backup"
        return 0
    fi
    
    mkdir -p "$backup_dir"
    
    if cp -r "$source" "$backup_path" 2>/dev/null; then
        debug "Backup creado: $backup_path"
        return 0
    else
        warn "No se pudo crear backup de $source"
        return 1
    fi
}

# Crear symlink seguro
create_symlink() {
    local source="$1"
    local target="$2"
    local description="${3:-symlink}"

    if [[ ! -e "$source" ]]; then
        error "Origen no existe: $source"
        return 1
    fi

    # Crear backup si el target existe o es un symlink
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        create_backup "$target"
        rm -rf "$target"
    fi

    # Crear directorio padre si no existe
    mkdir -p "$(dirname "$target")"

    # Permitir modo copia para evitar symlinks en el sistema del usuario
    if [[ "${INSTALL_COPY_MODE:-false}" == "true" ]]; then
        if cp -a "$source" "$target" 2>/dev/null; then
            success "copiado: $target (desde $source)"
            return 0
        else
            error "No se pudo copiar $description"
            return 1
        fi
    else
        if ln -sf "$source" "$target"; then
            success "$description creado: $target -> $source"
            return 0
        else
            error "No se pudo crear $description"
            return 1
        fi
    fi
}

# Verificar integridad de archivos
verify_file_integrity() {
    local file="$1"
    local expected_hash="$2"
    local hash_type="${3:-sha256}"
    
    if [[ ! -f "$file" ]]; then
        error "Archivo no existe: $file"
        return 1
    fi
    
    local actual_hash=""
    case "$hash_type" in
        "md5") actual_hash=$(md5sum "$file" | cut -d' ' -f1) ;;
        "sha1") actual_hash=$(sha1sum "$file" | cut -d' ' -f1) ;;
        "sha256") actual_hash=$(sha256sum "$file" | cut -d' ' -f1) ;;
        *) error "Tipo de hash no soportado: $hash_type"; return 1 ;;
    esac
    
    if [[ "$actual_hash" == "$expected_hash" ]]; then
        debug "Integridad verificada: $file"
        return 0
    else
        error "Integridad fallida: $file"
        return 1
    fi
}

# =====================================================
# 🔧 FUNCIONES DE VALIDACIÓN Y CONFIRMACIÓN
# =====================================================

# Función de confirmación mejorada
confirm() {
    local message="$1"
    local default="${2:-false}"
    
    if [[ "${FORCE_INSTALL:-false}" == "true" ]]; then
        debug "Instalación forzada, saltando confirmación"
        return 0
    fi
    
    local prompt=""
    if [[ "$default" == "true" ]]; then
        prompt="$message (Y/n): "
    else
        prompt="$message (y/N): "
    fi
    
    read -p "$prompt" -n 1 -r
    echo
    
    if [[ "$default" == "true" ]]; then
        [[ ! $REPLY =~ ^[Nn]$ ]]
    else
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Validar argumentos de línea de comandos
validate_args() {
    local required_args=("$@")
    local missing_args=()
    
    for arg in "${required_args[@]}"; do
        if [[ -z "${!arg:-}" ]]; then
            missing_args+=("$arg")
        fi
    done
    
    if [[ ${#missing_args[@]} -gt 0 ]]; then
        error "Argumentos faltantes: ${missing_args[*]}"
        return 1
    fi
    
    return 0
}

# Verificar dependencias del sistema
check_system_dependencies() {
    local dependencies=("$@")
    local missing_deps=()
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Dependencias faltantes: ${missing_deps[*]}"
        return 1
    fi
    
    return 0
}

# =====================================================
# 🔧 FUNCIONES DE INICIALIZACIÓN
# =====================================================

# Función para mostrar banner
show_banner() {
    local title="$1"
    local subtitle="${2:-}"
    
    echo -e "${BOLD}${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                     𓂀 DreamCoder 08 𓂀                     ║"
    echo "║                ⚡ Digital Dream Architect ⚡                 ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    
    if [[ -n "$title" ]]; then
        echo -e "${BOLD}${PURPLE}$title${COLOR_RESET}"
    fi
    
    if [[ -n "$subtitle" ]]; then
        echo -e "${CYAN}$subtitle${COLOR_RESET}"
    fi
    
    echo
}

# Función para mostrar resumen
show_summary() {
    local title="$1"
    local items=("${@:2}")
    
    echo -e "${BOLD}${BLUE}$title${COLOR_RESET}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    
    for item in "${items[@]}"; do
        echo -e "${CYAN}│${COLOR_RESET} $item"
    done
    
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${COLOR_RESET}"
    echo
}

# Inicializar biblioteca
init_library() {
    debug "Inicializando biblioteca común..."
    
    # Verificar sistema
    if ! is_arch_linux; then
        error "Este script requiere Arch Linux"
        exit 1
    fi

    # En modo simulación, saltar checks que requieren sudo o conexión
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        warn "DRY-RUN: omitiendo verificación de sudo e internet"
    else
        # Verificar permisos
        if ! check_sudo; then
            error "No se pudieron obtener permisos sudo"
            exit 1
        fi
        # Verificar conexión
        if ! check_internet; then
            error "Sin conexión a internet"
            exit 1
        fi
    fi

    # Verificar recursos del sistema
    check_disk_space
    check_memory
    check_system_load
    
    success "Biblioteca inicializada correctamente"
}

# =====================================================
# 🔧 FUNCIONES DE LIMPIEZA Y FINALIZACIÓN
# =====================================================

# Función de limpieza
cleanup() {
    # Limpiar variables temporales
    unset -f debug log success warn error critical
    unset -f show_progress spinner
    unset -f is_arch_linux get_arch_version check_sudo check_internet
    unset -f check_disk_space check_memory check_system_load
    unset -f install_package install_aur_package update_system clean_package_cache
    unset -f create_backup create_symlink verify_file_integrity
    unset -f confirm validate_args check_system_dependencies
    unset -f init_library show_banner show_summary cleanup
}

# No usar trap por ahora para evitar problemas
# trap cleanup EXIT

# Las funciones están disponibles para ser llamadas directamente
# No es necesario exportarlas en este contexto 