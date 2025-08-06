#!/bin/bash
# My Powerlevel10k Configuration
# ---------------------------------------------------------------------
# ╔═════════════════════════════════════════════════════════════
# ║                     𓂀 DreamCoder 08 𓂀                     ║
# ║                ⚡ Digital Dream Architect ⚡                 ║
# ║                                                            ║
# ║        Author: https://github.com/Albert-fer02             ║
# ╚══════════════════════════════════════════════════════════════╝
# ---------------------------------------------------------------------    
# =====================================================
# 🧩 Arch Dream Machine - Biblioteca Común
# =====================================================
# Funciones reutilizables para todos los módulos
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# =====================================================
# 🎨 SISTEMA DE COLORES Y LOGGING
# =====================================================

# Colores ANSI
AQUA='\033[38;5;51m'
GREEN='\033[38;5;118m'
CYAN='\033[38;5;87m'
PURPLE='\033[38;5;147m'
YELLOW='\033[38;5;226m'
RED='\033[38;5;196m'
BOLD='\033[1m'
COLOR_RESET='\033[0m'

# Funciones de logging
log() { echo -e "${CYAN}[INFO]${COLOR_RESET} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${COLOR_RESET} $1"; }
warn() { echo -e "${YELLOW}[WARN]${COLOR_RESET} $1"; }
error() { echo -e "${RED}[ERROR]${COLOR_RESET} $1"; }

# =====================================================
# 🔧 FUNCIONES DE SISTEMA
# =====================================================

# Verificar si es Arch Linux
is_arch_linux() {
    [[ -f /etc/arch-release ]] || command -v pacman &>/dev/null
}

# Verificar permisos sudo
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        error "Se requieren permisos sudo. Ejecuta: sudo -v"
        return 1
    fi
}

# Verificar conexión a internet
check_internet() {
    if ! ping -c 1 archlinux.org &>/dev/null; then
        error "Sin conexión a internet. Verifica tu conexión."
        return 1
    fi
}

# Verificar espacio en disco
check_disk_space() {
    local min_space=${1:-1048576}  # 1GB por defecto
    local available_space=$(df / | awk 'NR==2 {print $4}')
    
    if [ "$available_space" -lt "$min_space" ]; then
        warn "Poco espacio en disco: $(($available_space / 1024))MB"
        read -p "¿Continuar? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && return 1
    fi
}

# =====================================================
# 📦 GESTIÓN DE PAQUETES
# =====================================================

# Instalar paquete con verificación
install_package() {
    local package="$1"
    local description="${2:-$package}"
    
    if pacman -Q "$package" &>/dev/null; then
        success "$description ya está instalado."
        return 0
    fi
    
    log "Instalando $description..."
    sudo pacman -S --noconfirm --needed "$package" || {
        error "Fallo al instalar $description"
        return 1
    }
    success "$description instalado correctamente."
}

# Instalar paquete AUR
install_aur_package() {
    local package="$1"
    local description="${2:-$package}"
    
    if pacman -Q "$package" &>/dev/null; then
        success "$description (AUR) ya está instalado."
        return 0
    fi
    
    local aur_helper=""
    if command -v yay &>/dev/null; then
        aur_helper="yay"
    elif command -v paru &>/dev/null; then
        aur_helper="paru"
    else
        error "No se detectó AUR helper (yay/paru)"
        return 1
    fi
    
    log "Instalando $description desde AUR..."
    "$aur_helper" -S --noconfirm --needed "$package" || {
        warn "Fallo al instalar $description desde AUR"
        return 1
    }
    success "$description instalado desde AUR."
}

# =====================================================
# 📁 GESTIÓN DE ARCHIVOS
# =====================================================

# Crear backup seguro
create_backup() {
    local source="$1"
    local backup_dir="${2:-$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)}"
    
    [[ -e "$source" ]] || return 0
    
    if [[ -L "$source" ]]; then
        log "Eliminando symlink existente: $source"
        rm "$source"
        return 0
    fi
    
    mkdir -p "$backup_dir"
    cp -r "$source" "$backup_dir/" && success "Backup de $source realizado."
}

# Crear symlink seguro
create_symlink() {
    local source="$1"
    local target="$2"
    local description="${3:-$target}"
    
    # Verificar que el archivo fuente existe
    if [[ ! -e "$source" ]]; then
        error "Archivo fuente no encontrado: $source"
        return 1
    fi
    
    # Si el target ya existe y no es un symlink, crear backup
    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
        local backup_file="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        log "Creando backup de $description: $backup_file"
        mv "$target" "$backup_file" || {
            warn "$description ya existe y no es un symlink. Saltando..."
            return 1
        }
    fi
    
    # Crear el symlink
    ln -sf "$source" "$target" && success "$description enlazado." || {
        error "Fallo al enlazar $description"
        return 1
    }
}

# Verificar integridad de archivo
verify_file() {
    local file="$1"
    local description="${2:-$file}"
    
    [[ -f "$file" ]] || {
        error "Archivo faltante: $description"
        return 1
    }
    
    [[ -r "$file" ]] || {
        error "Archivo no legible: $description"
        return 1
    }
    
    success "Archivo verificado: $description"
}

# =====================================================
# 🔍 FUNCIONES DE VERIFICACIÓN
# =====================================================

# Verificar dependencias
check_dependencies() {
    local deps=("$@")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Dependencias faltantes: ${missing[*]}"
        return 1
    fi
    
    success "Todas las dependencias están disponibles."
}

# Verificar fuentes Nerd Font
check_nerd_fonts() {
    local font_paths=(
        "/usr/share/fonts/TTF/MesloLGS NF Regular.ttf"
        "/usr/share/fonts/nerd-fonts-meslo/MesloLGS NF Regular.ttf"
        "$HOME/.local/share/fonts/MesloLGS NF Regular.ttf"
    )
    
    for font_path in "${font_paths[@]}"; do
        if [[ -f "$font_path" ]]; then
            success "Fuente Nerd Font encontrada: $font_path"
            return 0
        fi
    done
    
    warn "No se encontraron fuentes Nerd Font."
    return 1
}

# =====================================================
# 🎯 FUNCIONES DE PRODUCTIVIDAD
# =====================================================

# Spinner para operaciones largas
spinner() {
    local pid=$1
    local msg=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    tput civis
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${AQUA}${spin:i++%${#spin}:1}${COLOR_RESET} ${msg}"
        sleep 0.1
    done
    printf "\r${GREEN}✓${COLOR_RESET} ${msg}\n"
    tput cnorm
}

# Confirmación del usuario
confirm() {
    local message="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        read -p "$message (Y/n): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Nn]$ ]] && return 1
    else
        read -p "$message (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && return 1
    fi
    
    return 0
}

# =====================================================
# 🔧 FUNCIONES DE CONFIGURACIÓN
# =====================================================

# Obtener directorio del script
get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

# Obtener directorio del proyecto
get_project_dir() {
    local script_dir=$(get_script_dir)
    [[ "$script_dir" == */lib ]] && dirname "$script_dir" || "$script_dir"
}

# Configurar variables de entorno
setup_environment() {
    export CONFIG_DIR=$(get_project_dir)
    export LOGFILE="$HOME/setup_arch_dream.log"
    export DRY_RUN=${DRY_RUN:-0}
    export ENABLE_AUR=${ENABLE_AUR:-1}
    export VERIFY_INTEGRITY=${VERIFY_INTEGRITY:-1}
    export SKIP_BACKUP=${SKIP_BACKUP:-0}
    export SETUP_ROOT=${SETUP_ROOT:-0}
}

# =====================================================
# 🛡️ FUNCIONES DE SEGURIDAD
# =====================================================

# Validar permisos de archivo
validate_permissions() {
    local file="$1"
    local expected_perms="${2:-644}"
    
    [[ -f "$file" ]] || return 1
    
    local current_perms=$(stat -c %a "$file")
    [[ "$current_perms" == "$expected_perms" ]] || {
        warn "Permisos incorrectos en $file: $current_perms (esperado: $expected_perms)"
        chmod "$expected_perms" "$file"
    }
}

# Verificar checksum de archivo
verify_checksum() {
    local file="$1"
    local expected_checksum="$2"
    
    [[ -f "$file" ]] || return 1
    
    local actual_checksum=$(sha256sum "$file" | cut -d' ' -f1)
    [[ "$actual_checksum" == "$expected_checksum" ]] || {
        error "Checksum incorrecto para $file"
        return 1
    }
    
    success "Checksum verificado para $file"
}

# =====================================================
# 📋 FUNCIONES DE REPORTE
# =====================================================

# Generar reporte de instalación
generate_report() {
    local module="$1"
    local status="$2"
    local details="$3"
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $module | $status | $details" >> "$LOGFILE"
}

# Mostrar resumen de instalación
show_summary() {
    local module="$1"
    local installed_packages="$2"
    local config_files="$3"
    
    echo -e "\n${BOLD}${CYAN}📋 Resumen de $module:${COLOR_RESET}"
    echo -e "${YELLOW}•${COLOR_RESET} Paquetes instalados: $installed_packages"
    echo -e "${YELLOW}•${COLOR_RESET} Archivos configurados: $config_files"
    echo -e "${YELLOW}•${COLOR_RESET} Logs disponibles en: $LOGFILE"
}

# =====================================================
# 🏁 INICIALIZACIÓN
# =====================================================

# Configurar manejo de señales
setup_signal_handlers() {
    trap 'echo -e "\n${RED}Operación interrumpida.${COLOR_RESET}"; exit 1' INT TERM
}

# Inicializar biblioteca
init_library() {
    setup_environment
    setup_signal_handlers
    
    # Verificar sistema
    is_arch_linux || {
        error "Este script requiere Arch Linux o derivado."
        exit 1
    }
    
    # Crear directorio de logs
    mkdir -p "$(dirname "$LOGFILE")"
    
    log "Biblioteca común inicializada"
} 