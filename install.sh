#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM MACHINE - INSTALADOR UNIFICADO
# =====================================================
# Script de instalación principal para todos los módulos
# Versión 3.0 - Instalación inteligente y modular
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# =====================================================
# 🔧 CONFIGURACIÓN GLOBAL
# =====================================================

PROJECT_NAME="Arch Dream Machine"
PROJECT_VERSION="3.0.0"
PROJECT_AUTHOR="DreamCoder 08"
PROJECT_DESCRIPTION="Sistema de configuración completo para Arch Linux"

# Directorios del proyecto
PROJECT_ROOT="$SCRIPT_DIR"
MODULES_DIR="$PROJECT_ROOT/modules"
CONFIG_DIR="$HOME/.config/arch-dream"
BACKUP_DIR="$HOME/.backups/arch-dream"

# Opciones de instalación
INSTALL_ALL=false
INSTALL_MODULES=()
SKIP_MODULES=()
FORCE_INSTALL=false
DRY_RUN=false
VERBOSE=false

# =====================================================
# 🔧 FUNCIONES DE AYUDA Y CONFIGURACIÓN
# =====================================================

show_help() {
    cat << EOF
🧩 $PROJECT_NAME v$PROJECT_VERSION

$PROJECT_DESCRIPTION

Uso: $0 [OPCIONES] [MÓDULOS...]

OPCIONES:
    -a, --all           Instalar todos los módulos
    -m, --modules       Lista de módulos específicos
    -s, --skip          Módulos a saltar
    -f, --force         Instalación forzada
    -d, --dry-run       Simular instalación
    -v, --verbose       Modo verboso
    -c, --copy          Copiar archivos en lugar de symlinks
    -h, --help          Mostrar esta ayuda

MÓDULOS DISPONIBLES:
$(
    available=$(discover_modules 2>/dev/null || true);
    for m in $available; do
        echo "    $m";
    done
)

EJEMPLOS:
    $0 --all                    # Instalar todo
    $0 core:zsh terminal:kitty # Solo Zsh y Kitty
    $0 --skip core:bash        # Todo excepto Bash
    $0 --dry-run               # Simular instalación

EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--all)
                INSTALL_ALL=true
                shift
                ;;
            -m|--modules)
                shift
                IFS=',' read -ra INSTALL_MODULES <<< "$1"
                shift
                ;;
            -s|--skip)
                shift
                IFS=',' read -ra SKIP_MODULES <<< "$1"
                shift
                ;;
            -f|--force)
                FORCE_INSTALL=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -c|--copy)
                export INSTALL_COPY_MODE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                error "Opción desconocida: $1"
                show_help
                exit 1
                ;;
            *)
                INSTALL_MODULES+=("$1")
                shift
                ;;
        esac
    done
    
    # Si no se especificaron módulos, instalar todos
    if [[ ${#INSTALL_MODULES[@]} -eq 0 ]] && [[ "$INSTALL_ALL" != "true" ]]; then
        INSTALL_ALL=true
    fi
}

# =====================================================
# 🧩 SELECCIÓN INTERACTIVA DE MÓDULOS
# =====================================================

interactive_select_modules() {
    local available_modules=("$@")
    local count=${#available_modules[@]}

    echo -e "${BOLD}${BLUE}Selecciona módulos a instalar${COLOR_RESET}"
    echo -e "${CYAN}Introduce números separados por coma, 'all' para todos o 'none' para ninguno.${COLOR_RESET}"
    for i in "${!available_modules[@]}"; do
        printf "  %2d) %s\n" "$((i+1))" "${available_modules[$i]}"
    done
    echo
    read -p "Selección [all]: " selection
    selection=${selection:-all}

    local chosen=()
    if [[ "$selection" == "all" ]]; then
        chosen=("${available_modules[@]}")
    elif [[ "$selection" == "none" ]]; then
        chosen=()
    else
        IFS=',' read -ra indices <<< "$selection"
        for idx in "${indices[@]}"; do
            idx=$(echo "$idx" | xargs)
            if [[ "$idx" =~ ^[0-9]+$ ]] && (( idx>=1 && idx<=count )); then
                chosen+=("${available_modules[$((idx-1))]}")
            else
                warn "Índice inválido: $idx (saltando)"
            fi
        done
    fi

    for m in "${chosen[@]}"; do
        printf '%s\n' "$m"
    done
}

# =====================================================
# 🔧 FUNCIONES DE ANÁLISIS DEL SISTEMA
# =====================================================

analyze_system() {
    log "🔍 Analizando sistema..."
    
    # Información del sistema
    local os_info=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
    local kernel=$(uname -r)
    local arch=$(uname -m)
    local shell=$(basename -- "$SHELL")
    
    success "Sistema: $os_info"
    success "Kernel: $kernel"
    success "Arquitectura: $arch"
    success "Shell actual: $shell"
    
    # Verificar recursos del sistema
    check_system_resources
    
    # Verificar dependencias base
    check_base_dependencies
    
    # Verificar espacio en disco
    check_disk_space 2097152  # 2GB mínimo
    
    success "✅ Análisis del sistema completado"
}

check_system_resources() {
    log "📊 Verificando recursos del sistema..."
    
    # Memoria RAM (cálculo seguro con awk)
    local total_mem_gb=$(free -b | awk 'NR==2{printf "%.1f", $2/1024/1024/1024}')
    local avail_mem_gb=$(free -b | awk 'NR==2{printf "%.1f", $7/1024/1024/1024}')
    local mem_usage_pct=$(free -b | awk 'NR==2{printf "%.0f", (1 - $7/$2) * 100}')
    
    if [[ "$mem_usage_pct" -gt 90 ]]; then
        warn "⚠️  Uso de memoria alto: ${mem_usage_pct}%"
    else
        success "✓ Memoria RAM: ${avail_mem_gb}GB libre de ${total_mem_gb}GB"
    fi
    
    # CPU
    local cpu_cores=$(nproc)
    local cpu_load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    
    success "✓ CPU: $cpu_cores núcleos, carga: $cpu_load"
    
    # Espacio en disco
    local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $disk_usage -gt 90 ]]; then
        warn "⚠️  Uso de disco alto: ${disk_usage}%"
    else
        success "✓ Disco: ${disk_usage}% usado"
    fi
}

check_base_dependencies() {
    log "🔧 Verificando dependencias base..."
    
    local base_deps=("pacman" "sudo" "git" "curl" "wget")
    local missing_deps=()
    
    for dep in "${base_deps[@]}"; do
        if command -v "$dep" &>/dev/null; then
            success "✓ $dep"
        else
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "❌ Dependencias faltantes: ${missing_deps[*]}"
        error "Instala las dependencias base antes de continuar"
        exit 1
    fi
    
    success "✅ Todas las dependencias base están disponibles"
}

# =====================================================
# 🔧 FUNCIONES DE GESTIÓN DE MÓDULOS
# =====================================================

discover_modules() {
    local available_modules=()

    # Buscar módulos en el directorio modules
    for category_dir in "$MODULES_DIR"/*; do
        if [[ -d "$category_dir" ]]; then
            local category=$(basename "$category_dir")
            for module_dir in "$category_dir"/*; do
                if [[ -d "$module_dir" ]] && [[ -f "$module_dir/install.sh" ]]; then
                    local module=$(basename "$module_dir")
                    available_modules+=("$category:$module")
                fi
            done
        fi
    done

    # Emitir solo la lista, una por línea, para consumo programático
    for m in "${available_modules[@]}"; do
        printf '%s\n' "$m"
    done
}

resolve_dependencies() {
    local modules=("$@")
    local resolved_modules=()
    local dependency_graph=()
    # No emitir logs por stdout para evitar contaminar la salida capturada
    # Crear grafo de dependencias
    for module in "${modules[@]}"; do
        local module_path="$MODULES_DIR/${module/:/\/}"
        if [[ -f "$module_path/install.sh" ]]; then
            # Leer dependencias del módulo
            local deps=$(grep -o 'MODULE_DEPENDENCIES=([^)]*)' "$module_path/install.sh" 2>/dev/null | sed 's/MODULE_DEPENDENCIES=(\([^)]*\))/\1/' || echo "")
            if [[ -n "$deps" ]]; then
                dependency_graph+=("$module:$deps")
            fi
        fi
        resolved_modules+=("$module")
    done
    
    # Ordenar por dependencias
    local ordered_modules=()
    local processed=()
    
    while [[ ${#resolved_modules[@]} -gt 0 ]]; do
        local current_module="${resolved_modules[0]}"
        resolved_modules=("${resolved_modules[@]:1}")
        
        if [[ ! " ${processed[@]} " =~ " ${current_module} " ]]; then
            ordered_modules+=("$current_module")
            processed+=("$current_module")
        fi
    done
    
    for m in "${ordered_modules[@]}"; do
        printf '%s\n' "$m"
    done
}

# =====================================================
# 🔧 FUNCIONES DE INSTALACIÓN
# =====================================================

install_module() {
    local module="$1"
    local module_path="$MODULES_DIR/${module/:/\/}"
    
    if [[ ! -d "$module_path" ]]; then
        error "Módulo no encontrado: $module"
        return 1
    fi
    
    if [[ ! -f "$module_path/install.sh" ]]; then
        error "Script de instalación no encontrado: $module"
        return 1
    fi
    
    log "🚀 Instalando módulo: $module"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        success "DRY RUN: Simulando instalación de $module"
        return 0
    fi
    
    # Cambiar al directorio del módulo
    cd "$module_path"
    
    # Ejecutar script de instalación
    if bash install.sh; then
        success "✅ Módulo $module instalado correctamente"
        return 0
    else
        error "❌ Fallo al instalar módulo $module"
        return 1
    fi
}

install_modules() {
    local modules=("$@")
    local total_modules=${#modules[@]}
    local installed_modules=()
    local failed_modules=()
    
    log "🚀 Iniciando instalación de $total_modules módulos..."
    
    for i in "${!modules[@]}"; do
        local module="${modules[$i]}"
        
        # Verificar si se debe saltar
        if [[ " ${SKIP_MODULES[@]} " =~ " ${module} " ]]; then
            warn "⏭️  Saltando módulo: $module"
            continue
        fi
        
        show_progress $((i + 1)) $total_modules "Instalando $module"
        
        if install_module "$module"; then
            installed_modules+=("$module")
        else
            failed_modules+=("$module")
            
            if [[ "$FORCE_INSTALL" != "true" ]]; then
                error "❌ Instalación falló. Usa --force para continuar"
                return 1
            fi
        fi
    done
    
    echo  # Nueva línea después de la barra de progreso
    
    # Resumen de instalación
    show_installation_summary "$total_modules" "${#installed_modules[@]}" "${#failed_modules[@]}" "${installed_modules[@]}" "${failed_modules[@]}"
}

show_installation_summary() {
    local total="$1"
    local installed="$2"
    local failed="$3"
    shift 3
    local installed_modules=("${@:1:$installed}")
    shift $installed
    local failed_modules=("${@:1:$failed}")
    
    echo
    echo -e "${BOLD}${BLUE}📊 RESUMEN DE INSTALACIÓN${COLOR_RESET}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Total de módulos: $total"
    echo -e "${CYAN}│${COLOR_RESET} Instalados: ${GREEN}$installed${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Fallidos: ${RED}$failed${COLOR_RESET}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${COLOR_RESET}"
    
    if [[ $installed -gt 0 ]]; then
        echo
        echo -e "${GREEN}✅ Módulos instalados exitosamente:${COLOR_RESET}"
        for module in "${installed_modules[@]}"; do
            echo -e "  - $module"
        done
    fi
    
    if [[ $failed -gt 0 ]]; then
        echo
        echo -e "${RED}❌ Módulos que fallaron:${COLOR_RESET}"
        for module in "${failed_modules[@]}"; do
            echo -e "  - $module"
        done
    fi
}

# =====================================================
# 🔧 FUNCIONES DE CONFIGURACIÓN POST-INSTALACIÓN
# =====================================================

post_installation_setup() {
    log "🔧 Configurando sistema post-instalación..."
    
    # Crear directorios de configuración
    mkdir -p "$CONFIG_DIR" "$BACKUP_DIR"
    
    # Configurar shell por defecto si Zsh está instalado
    if command -v zsh &>/dev/null && [[ "$SHELL" != "/bin/zsh" ]]; then
        if confirm "¿Cambiar shell por defecto a Zsh?" true; then
            log "Cambiando shell por defecto a Zsh..."
            chsh -s /bin/zsh
            success "✅ Shell cambiado a Zsh. Reinicia la sesión para aplicar"
        fi
    fi
    
    # Crear archivo de configuración global
    create_global_config
    
    # Mostrar mensaje de finalización
    show_completion_message
}

create_global_config() {
    local config_file="$CONFIG_DIR/config.sh"
    
    cat > "$config_file" << EOF
# Arch Dream Machine - Configuración Global
# Generado automáticamente el $(date)

export ARCH_DREAM_VERSION="$PROJECT_VERSION"
export ARCH_DREAM_CONFIG_DIR="$CONFIG_DIR"
export ARCH_DREAM_BACKUP_DIR="$BACKUP_DIR"

# Función para recargar configuración
reload_arch_dream() {
    source "$config_file"
    echo "✅ Configuración de Arch Dream Machine recargada"
}

# Función para mostrar estado
arch_dream_status() {
    echo "🧩 Arch Dream Machine v$PROJECT_VERSION"
    echo "📁 Config: $CONFIG_DIR"
    echo "💾 Backups: $BACKUP_DIR"
}
EOF
    
    success "✅ Configuración global creada: $config_file"
}

show_completion_message() {
    echo
    echo -e "${BOLD}${GREEN}🎉 ¡INSTALACIÓN COMPLETADA!${COLOR_RESET}"
    echo
    echo -e "${CYAN}🚀 Próximos pasos:${COLOR_RESET}"
    echo -e "  1. Reinicia tu terminal o ejecuta: exec zsh"
    echo -e "  2. Personaliza tu configuración en: $CONFIG_DIR"
    echo -e "  3. Ejecuta: arch_dream_status para ver el estado"
    echo
    echo -e "${YELLOW}💡 Consejos:${COLOR_RESET}"
    echo -e "  - Usa 'reload_arch_dream' para recargar configuración"
    echo -e "  - Los backups se guardan en: $BACKUP_DIR"
    echo -e "  - Consulta la documentación en: $PROJECT_ROOT/README.md"
    echo
    echo -e "${RED}🎯 Red Team ZSH:${COLOR_RESET}"
    echo -e "  - Ejecuta: ./verify-redteam-zsh.sh para verificar ZSH Red Team"
    echo -e "  - Usa: redteam-info para información de red"
    echo -e "  - Configura: set-target <ip> para establecer objetivo"
    echo
    echo -e "${PURPLE}🌟 ¡Disfruta tu nueva configuración!${COLOR_RESET}"
}

# =====================================================
# 🔧 FUNCIÓN PRINCIPAL
# =====================================================

main() {
    # Mostrar banner
    show_banner "$PROJECT_NAME v$PROJECT_VERSION" "$PROJECT_DESCRIPTION"
    
    # Parsear argumentos
    parse_arguments "$@"
    
    # Inicializar biblioteca
    init_library
    
    # Analizar sistema
    analyze_system
    
    # Descubrir módulos disponibles
    local available_modules=()
    # Capturar salida limpia de discover_modules sin mezclar logs
    mapfile -t available_modules < <(discover_modules)
    
    # Determinar módulos a instalar
    local modules_to_install=()
    if [[ "$INSTALL_ALL" == "true" ]]; then
        modules_to_install=("${available_modules[@]}")
    else
        # Validar que los módulos solicitados existan en la lista disponible
        for m in "${INSTALL_MODULES[@]}"; do
            for a in "${available_modules[@]}"; do
                if [[ "$m" == "$a" ]]; then
                    modules_to_install+=("$m")
                    break
                fi
            done
        done
        # Si no se pasaron módulos válidos, ofrecer selección interactiva
        if [[ ${#modules_to_install[@]} -eq 0 ]]; then
            mapfile -t modules_to_install < <(interactive_select_modules "${available_modules[@]}")
        fi
    fi
    
    # Resolver dependencias
    local ordered_modules=()
    mapfile -t ordered_modules < <(resolve_dependencies "${modules_to_install[@]}")
    
    if [[ ${#ordered_modules[@]} -eq 0 ]]; then
        error "No se encontraron módulos para instalar"
        exit 1
    fi
    
    # Confirmar instalación (omitir si --yes o variables de CI)
    if [[ "$DRY_RUN" != "true" ]] && [[ "$FORCE_INSTALL" != "true" ]] && [[ "${CI:-false}" != "true" ]] && [[ "${YES:-false}" != "true" ]]; then
        echo -e "${YELLOW}📋 Módulos a instalar:${COLOR_RESET}"
        for module in "${ordered_modules[@]}"; do
            echo -e "  - $module"
        done
        echo
        
        if ! confirm "¿Continuar con la instalación?" true; then
            log "Instalación cancelada por el usuario"
            exit 0
        fi
    fi
    
    # Instalar módulos
    install_modules "${ordered_modules[@]}"
    
    # Configuración post-instalación
    post_installation_setup
    
    success "🎉 Instalación completada exitosamente!"
}

# Ejecutar función principal
main "$@"
