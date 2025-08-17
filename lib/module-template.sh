#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM - TEMPLATE UNIVERSAL DE MÓDULOS
# =====================================================
# Template optimizado para crear/actualizar módulos
# Elimina duplicaciones y estandariza la estructura
# =====================================================

# =====================================================
# 🔧 CONFIGURACIÓN BASE DEL MÓDULO
# =====================================================

# Variables que deben ser definidas en cada módulo:
# MODULE_NAME="Nombre del Módulo"
# MODULE_DESCRIPTION="Descripción del módulo"
# MODULE_DEPENDENCIES=("dep1" "dep2" "dep3")
# MODULE_FILES=("file1" "file2")
# MODULE_CONFIG_DIR="$HOME/.config/module"

# =====================================================
# 🔧 FUNCIONES ESTÁNDAR REUTILIZABLES
# =====================================================

# Función estándar para instalar dependencias
install_standard_dependencies() {
    log "📦 Instalando dependencias del módulo $MODULE_NAME..."
    
    local deps_to_install=()
    
    for dep in "${MODULE_DEPENDENCIES[@]}"; do
        if command -v "$dep" &>/dev/null || pacman -Q "$dep" &>/dev/null 2>&1; then
            success "✓ $dep ya está instalado"
        else
            deps_to_install+=("$dep")
        fi
    done
    
    if [[ ${#deps_to_install[@]} -gt 0 ]]; then
        log "Instalando dependencias faltantes: ${deps_to_install[*]}"
        for dep in "${deps_to_install[@]}"; do
            if sudo pacman -S --noconfirm --needed "$dep"; then
                success "✓ $dep instalado"
            else
                error "✗ Error instalando $dep"
                return 1
            fi
        done
    fi
    
    success "✅ Todas las dependencias están instaladas"
}

# Función estándar para configurar directorios
setup_standard_directories() {
    log "📁 Configurando directorios del módulo $MODULE_NAME..."
    
    # Limpiar enlaces rotos o archivos conflictivos
    if [[ -n "${MODULE_CONFIG_DIR:-}" ]]; then
        if [[ -L "$MODULE_CONFIG_DIR" ]]; then
            local target=$(readlink -f "$MODULE_CONFIG_DIR" 2>/dev/null || echo "")
            if [[ -z "$target" || ! -d "$target" ]]; then
                warn "Enlace roto detectado en $MODULE_CONFIG_DIR, corrigiendo..."
                rm -f "$MODULE_CONFIG_DIR"
            fi
        elif [[ -e "$MODULE_CONFIG_DIR" && ! -d "$MODULE_CONFIG_DIR" ]]; then
            warn "$MODULE_CONFIG_DIR es un archivo, moviendo a backup..."
            mv "$MODULE_CONFIG_DIR" "$MODULE_CONFIG_DIR.backup_$(date +%Y%m%d_%H%M%S)"
        fi
        
        mkdir -p "$MODULE_CONFIG_DIR"
        chmod 755 "$MODULE_CONFIG_DIR"
    fi
    
    success "✅ Directorios configurados"
}

# Función estándar para crear enlaces simbólicos
create_standard_symlinks() {
    log "🔗 Configurando archivos del módulo $MODULE_NAME..."
    
    for file in "${MODULE_FILES[@]}"; do
        local source="$SCRIPT_DIR/$file"
        local target=""
        
        # Determinar destino basado en el archivo
        case "$file" in
            *.conf|*.toml|*.json|*.jsonc)
                target="$MODULE_CONFIG_DIR/$(basename "$file")"
                ;;
            init.lua|*.lua)
                target="$MODULE_CONFIG_DIR/$(basename "$file")"
                ;;
            *)
                target="$MODULE_CONFIG_DIR/$(basename "$file")"
                ;;
        esac
        
        if [[ -f "$source" ]]; then
            # Crear backup si existe
            if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
                cp "$target" "$target.backup_$(date +%Y%m%d_%H%M%S)"
            fi
            
            # Crear directorio padre
            mkdir -p "$(dirname "$target")"
            
            # Crear enlace
            ln -sf "$source" "$target"
            success "✓ $(basename "$file") → $target"
        elif [[ -d "$source" ]]; then
            # Es un directorio
            ln -sf "$source" "$target"
            success "✓ $(basename "$file")/ → $target"
        else
            warn "⚠️  Archivo no encontrado: $source"
        fi
    done
    
    success "✅ Archivos del módulo configurados"
}

# Función estándar para crear configuración local
create_local_config() {
    local config_name="$1"
    local config_path="$2"
    local template_content="$3"
    
    if [[ ! -f "$config_path" ]]; then
        cat > "$config_path" << EOF
# =====================================================
# 🧩 CONFIGURACIÓN LOCAL - $config_name
# =====================================================
# Personalizaciones específicas del usuario
# Este archivo NO se sobrescribe con actualizaciones
# =====================================================

$template_content

EOF
        success "✅ Configuración local creada: $config_path"
    fi
}

# Función estándar de verificación
verify_standard_installation() {
    log "✅ Verificando instalación del módulo $MODULE_NAME..."
    
    local checks_passed=0
    local total_checks=${#MODULE_DEPENDENCIES[@]}
    
    # Verificar dependencias
    for dep in "${MODULE_DEPENDENCIES[@]}"; do
        if command -v "$dep" &>/dev/null; then
            success "✓ $dep disponible"
            ((checks_passed++))
        else
            error "✗ $dep no disponible"
        fi
    done
    
    # Verificar archivos de configuración
    for file in "${MODULE_FILES[@]}"; do
        local target="$MODULE_CONFIG_DIR/$(basename "$file")"
        if [[ -L "$target" ]] && [[ -e "$target" ]]; then
            success "✓ $(basename "$file") configurado"
            ((total_checks++))
            ((checks_passed++))
        else
            error "✗ $(basename "$file") no configurado"
            ((total_checks++))
        fi
    done
    
    # Mostrar resultado
    if [[ $checks_passed -eq $total_checks ]]; then
        success "✅ Módulo $MODULE_NAME instalado correctamente ($checks_passed/$total_checks)"
        return 0
    else
        warn "⚠️  Módulo $MODULE_NAME instalado parcialmente ($checks_passed/$total_checks)"
        return 1
    fi
}

# Función principal estándar
run_standard_installation() {
    # Banner
    echo -e "${BOLD}${CYAN}🧩 INSTALANDO MÓDULO: $MODULE_NAME${COLOR_RESET}"
    echo -e "${CYAN}$MODULE_DESCRIPTION${COLOR_RESET}\n"
    
    # Ejecutar pasos estándar
    install_standard_dependencies
    setup_standard_directories
    create_standard_symlinks
    
    # Ejecutar configuración específica del módulo si existe
    if declare -f configure_module_specifics &>/dev/null; then
        configure_module_specifics
    fi
    
    # Verificación
    verify_standard_installation
    
    echo -e "\n${BOLD}${GREEN}✅ Módulo $MODULE_NAME instalado exitosamente${COLOR_RESET}"
}

# =====================================================
# 🎨 FUNCIONES DE UTILIDAD
# =====================================================

# Detectar tipo de configuración automáticamente
detect_config_type() {
    local file="$1"
    case "$file" in
        *.toml) echo "toml" ;;
        *.json|*.jsonc) echo "json" ;;
        *.conf) echo "conf" ;;
        *.lua) echo "lua" ;;
        *.sh) echo "shell" ;;
        *) echo "generic" ;;
    esac
}

# Validar sintaxis de archivos de configuración
validate_config_syntax() {
    local file="$1"
    local type=$(detect_config_type "$file")
    
    case "$type" in
        lua)
            if command -v lua &>/dev/null; then
                lua -e "dofile('$file')" &>/dev/null
            else
                return 0  # No podemos validar, asumimos correcto
            fi
            ;;
        shell)
            bash -n "$file"
            ;;
        json)
            if command -v jq &>/dev/null; then
                jq empty "$file" &>/dev/null
            else
                return 0
            fi
            ;;
        *)
            return 0  # No validamos otros tipos
            ;;
    esac
}

# Crear backup inteligente
create_smart_backup() {
    local target="$1"
    local backup_name="${2:-$(basename "$target")}"
    
    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
        local backup_dir="$HOME/.config/arch-dream/backups"
        mkdir -p "$backup_dir"
        
        local backup_file="$backup_dir/${backup_name}_$(date +%Y%m%d_%H%M%S)"
        cp -r "$target" "$backup_file"
        debug "Backup creado: $backup_file"
    fi
}

# =====================================================
# 🎯 FUNCIONES DE COLORES Y LOGGING
# =====================================================

# Definir colores si no están definidos
if [[ -z "${RED:-}" ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    COLOR_RESET='\033[0m'
fi

# Funciones de logging si no están definidas
if ! declare -f log &>/dev/null; then
    log() { echo -e "${CYAN}[INFO]${COLOR_RESET} $*"; }
    success() { echo -e "${GREEN}[SUCCESS]${COLOR_RESET} $*"; }
    warn() { echo -e "${YELLOW}[WARN]${COLOR_RESET} $*"; }
    error() { echo -e "${RED}[ERROR]${COLOR_RESET} $*"; }
    debug() { [[ "${DEBUG:-}" == "true" ]] && echo -e "${BLUE}[DEBUG]${COLOR_RESET} $*"; }
fi

# =====================================================
# 📋 TEMPLATE DE USO
# =====================================================

show_template_usage() {
    cat << 'EOF'
# ===== TEMPLATE DE USO PARA MÓDULOS =====

#!/bin/bash
# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/module-template.sh"

# Configuración del módulo
MODULE_NAME="Mi Módulo"
MODULE_DESCRIPTION="Descripción del módulo"
MODULE_DEPENDENCIES=("dep1" "dep2")
MODULE_FILES=("config.conf" "archivo.toml")
MODULE_CONFIG_DIR="$HOME/.config/mi-modulo"

# Configuración específica del módulo (opcional)
configure_module_specifics() {
    # Pasos específicos para este módulo
    log "Configuración específica de $MODULE_NAME..."
    
    # Ejemplo: crear configuración local
    create_local_config "Mi Módulo" "$MODULE_CONFIG_DIR/local.conf" "# Configuraciones locales aquí"
}

# Ejecutar instalación estándar
run_standard_installation
EOF
}

# Exportar funciones principales
export -f install_standard_dependencies setup_standard_directories
export -f create_standard_symlinks create_local_config verify_standard_installation
export -f run_standard_installation detect_config_type validate_config_syntax
export -f create_smart_backup show_template_usage