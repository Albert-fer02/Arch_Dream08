#!/bin/bash
# =====================================================
# 🚀 ARCH DREAM - INSTALADOR PRINCIPAL V5.0
# =====================================================
# Instalador ultra-optimizado para Arch Linux
# Arquitectura modular con gestión inteligente de dependencias
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# =====================================================
# 🔧 CONFIGURACIÓN GLOBAL
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_VERSION="5.0.0"
LOCKFILE="$HOME/.cache/arch-dream-install.lock"
LOG_FILE="$HOME/.cache/arch-dream-install.log"

# Variables de control
INSTALL_ALL=false
SELECTED_MODULES=()
DRY_RUN=false
FORCE_INSTALL=false
PARALLEL_INSTALL=false
BACKUP_CONFIGS=true
QUIET_MODE=false
VERBOSE_MODE=false

# =====================================================
# 🎨 SISTEMA DE COLORES Y LOGGING
# =====================================================

# Colores ANSI
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; PURPLE='\033[0;35m'
BOLD='\033[1m'; NC='\033[0m'

# Funciones de logging optimizadas
log() { 
    local msg="[$(date '+%H:%M:%S')] $*"
    echo -e "${CYAN}[INFO]${NC} $msg" | tee -a "$LOG_FILE"
}

success() { 
    local msg="[$(date '+%H:%M:%S')] $*"
    echo -e "${GREEN}[OK]${NC} $msg" | tee -a "$LOG_FILE"
}

warn() { 
    local msg="[$(date '+%H:%M:%S')] $*"
    echo -e "${YELLOW}[WARN]${NC} $msg" | tee -a "$LOG_FILE"
}

error() { 
    local msg="[$(date '+%H:%M:%S')] $*"
    echo -e "${RED}[ERROR]${NC} $msg" | tee -a "$LOG_FILE" >&2
}

debug() {
    [[ "$VERBOSE_MODE" == "true" ]] && {
        local msg="[$(date '+%H:%M:%S')] $*"
        echo -e "${PURPLE}[DEBUG]${NC} $msg" | tee -a "$LOG_FILE"
    }
}

# =====================================================
# 🔒 GESTIÓN DE PROCESOS Y LOCKING
# =====================================================

cleanup() {
    local exit_code=$?
    [[ -f "$LOCKFILE" ]] && rm -f "$LOCKFILE"
    
    if [[ $exit_code -ne 0 && "${DRY_RUN:-}" != "true" ]]; then
        error "Instalación fallida. Log: $LOG_FILE"
        [[ -f "$LOG_FILE" ]] && tail -5 "$LOG_FILE" >&2
    fi
}

acquire_lock() {
    if [[ -f "$LOCKFILE" ]]; then
        local pid=$(cat "$LOCKFILE" 2>/dev/null || echo "")
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            error "Otra instalación en proceso (PID: $pid)"
            exit 1
        else
            rm -f "$LOCKFILE"
        fi
    fi
    
    echo $$ > "$LOCKFILE"
    trap cleanup EXIT INT TERM
}

# =====================================================
# 🔧 VERIFICACIONES DEL SISTEMA
# =====================================================

system_check() {
    log "🔍 Verificando sistema Arch Linux..."
    
    # Verificar Arch Linux
    [[ -f /etc/arch-release ]] || {
        error "❌ Este instalador requiere Arch Linux"
        exit 1
    }
    
    # Verificar herramientas esenciales
    local missing_tools=()
    for tool in git sudo pacman curl; do
        command -v "$tool" &>/dev/null || missing_tools+=("$tool")
    done
    
    [[ ${#missing_tools[@]} -eq 0 ]] || {
        error "❌ Herramientas faltantes: ${missing_tools[*]}"
        log "💡 Instala con: sudo pacman -S ${missing_tools[*]}"
        exit 1
    }
    
    # Verificar conexión a internet
    ping -c 1 -W 3 archlinux.org &>/dev/null || warn "⚠️  Sin conexión a repositorios de Arch"
    
    # Verificar espacio en disco (mínimo 2GB)
    local available_space=$(df "$HOME" | awk 'NR==2 {print $4}')
    [[ $available_space -gt 2097152 ]] || {
        error "❌ Espacio insuficiente: $(($available_space/1024))MB disponible, 2GB requerido"
        exit 1
    }
    
    # Verificar permisos sudo
    [[ "$DRY_RUN" == "true" ]] || {
        log "🔐 Se requieren permisos sudo..."
        sudo -v || {
            error "❌ Permisos sudo requeridos"
            exit 1
        }
    }
    
    # Actualizar bases de datos de pacman
    [[ "$DRY_RUN" == "true" ]] || {
        log "📦 Actualizando bases de datos de pacman..."
        sudo pacman -Sy --noconfirm &>/dev/null || warn "No se pudo actualizar pacman"
    }
    
    success "✅ Sistema verificado correctamente"
}

# =====================================================
# 📦 GESTIÓN DE MÓDULOS OPTIMIZADA
# =====================================================

discover_modules() {
    find "$SCRIPT_DIR/modules" -name "install.sh" 2>/dev/null | \
    sed "s|$SCRIPT_DIR/modules/||g; s|/install.sh||g; s|/|:|g" | \
    sort -V
}

validate_module() {
    local module="$1"
    local module_path="$SCRIPT_DIR/modules/${module/:/\/}"
    
    [[ -f "$module_path/install.sh" ]] || return 1
    bash -n "$module_path/install.sh" || return 1
    [[ -x "$module_path/install.sh" ]] || return 1
    return 0
}

backup_existing_configs() {
    [[ "$BACKUP_CONFIGS" != "true" ]] && return 0
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$HOME/.arch-dream-backup-$timestamp"
    
    log "💾 Creando backup de configuraciones..."
    mkdir -p "$backup_dir" || {
        warn "No se pudo crear directorio de backup"
        return 0
    }
    
    local configs=(".bashrc" ".zshrc" ".vimrc" ".config/nvim" ".config/kitty")
    local backed_up=0
    
    for config in "${configs[@]}"; do
        if [[ -e "$HOME/$config" ]]; then
            if cp -r "$HOME/$config" "$backup_dir/" 2>/dev/null; then
                backed_up=$((backed_up + 1))
            fi
        fi
    done
    
    if [[ $backed_up -gt 0 ]]; then
        success "✅ Backup creado: $backup_dir ($backed_up archivos)"
        echo "$backup_dir" > "$HOME/.arch-dream-last-backup"
    else
        log "ℹ️  No se encontraron configuraciones para respaldar"
        rmdir "$backup_dir" 2>/dev/null || true
    fi
}

install_module() {
    local module="$1"
    local module_path="$SCRIPT_DIR/modules/${module/:/\/}"
    
    validate_module "$module" || {
        error "❌ Módulo inválido: $module"
        return 1
    }
    
    log "📦 Instalando: $module"
    
    [[ "$DRY_RUN" == "true" ]] && {
        success "🔍 DRY RUN: $module sería instalado"
        return 0
    }
    
    local install_start=$(date +%s)
    
    if timeout 300 bash -c "cd '$module_path' && bash install.sh" &>>"$LOG_FILE"; then
        local install_time=$(($(date +%s) - install_start))
        success "✅ $module instalado (${install_time}s)"
        
        # Marcar como instalado
        mkdir -p "$HOME/.config/arch-dream/installed"
        echo "$(date)" > "$HOME/.config/arch-dream/installed/$module"
        return 0
    else
        local install_time=$(($(date +%s) - install_start))
        error "❌ Fallo al instalar $module (${install_time}s)"
        
        tail -5 "$LOG_FILE" | while read line; do
            error "    $line"
        done
        return 1
    fi
}

install_modules_parallel() {
    local modules=("$@")
    local pids=()
    local max_jobs=3
    local job_count=0
    
    log "🚀 Instalación paralela de ${#modules[@]} módulos..."
    
    for module in "${modules[@]}"; do
        if [[ $job_count -ge $max_jobs ]]; then
            wait "${pids[0]}"
            pids=("${pids[@]:1}")
            job_count=$((job_count - 1))
        fi
        
        install_module "$module" &
        pids+=($!)
        job_count=$((job_count + 1))
    done
    
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}

# =====================================================
# 🎯 RESOLUCIÓN DE DEPENDENCIAS INTELIGENTE
# =====================================================

resolve_dependencies() {
    local requested_modules=("$@")
    local resolved_modules=()
    local processed=()
    
    resolve_module() {
        local module="$1"
        
        [[ " ${processed[@]} " =~ " $module " ]] && return
        processed+=("$module")
        
        # Buscar dependencias de módulos
        local module_path="$SCRIPT_DIR/modules/${module/:/\/}"
        if [[ -f "$module_path/install.sh" ]]; then
            local deps=$(grep '^MODULE_DEPENDENCIES=' "$module_path/install.sh" 2>/dev/null | \
                        sed 's/MODULE_DEPENDENCIES=(\([^)]*\))/\1/' | tr -d '"' || echo "")
            
            if [[ -n "$deps" ]]; then
                IFS=' ' read -ra dep_array <<< "$deps"
                for dep in "${dep_array[@]}"; do
                    [[ -n "$dep" && "$dep" =~ ^[a-z]+:[a-z]+ ]] && resolve_module "$dep"
                done
            fi
        fi
        
        [[ " ${resolved_modules[@]} " =~ " $module " ]] || resolved_modules+=("$module")
    }
    
    for module in "${requested_modules[@]}"; do
        resolve_module "$module"
    done
    
    printf '%s\n' "${resolved_modules[@]}"
}

# =====================================================
# 🎨 INTERFAZ DE USUARIO MEJORADA
# =====================================================

show_banner() {
    echo -e "${BOLD}${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                 🚀 ARCH DREAM MACHINE                    ║
║                   Instalador v5.0                        ║
║              Ultra-optimizado para Arch Linux            ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_help() {
    cat << EOF
🚀 Arch Dream Machine v$PROJECT_VERSION

${BOLD}OPCIONES:${NC}
    -a, --all           Instalar todos los módulos
    -l, --list          Listar módulos disponibles
    -f, --force         Forzar reinstalación (no preguntar)
    -d, --dry-run       Simular instalación (no hacer cambios)
    -p, --parallel      Instalación paralela (experimental)
    -b, --no-backup     No crear backup de configuraciones
    -q, --quiet         Modo silencioso
    -v, --verbose       Modo verbose
    -h, --help          Mostrar esta ayuda

${BOLD}MÓDULOS:${NC}
    core:*              Configuraciones de shell (zsh, bash)
    development:*       Herramientas de desarrollo (nvim, web)
    terminal:*          Configuraciones de terminal (kitty)
    tools:*             Utilidades (fastfetch, nano)
    themes:*            Temas visuales (catppuccin)

${BOLD}EJEMPLOS:${NC}
    $0 --all                        # Instalar todo
    $0 core:zsh development:nvim     # Módulos específicos
    $0 --dry-run --all               # Simular instalación completa
    $0 --parallel development:*     # Instalación paralela de desarrollo
    $0 --force --no-backup core:zsh # Reinstalar sin backup

${BOLD}VARIABLES DE ENTORNO:${NC}
    CI=true                         # Modo no interactivo
    ARCH_DREAM_PARALLEL=true        # Forzar instalación paralela
    ARCH_DREAM_LOG_LEVEL=debug      # Nivel de logging
EOF
}

interactive_selection() {
    local available_modules=()
    mapfile -t available_modules < <(discover_modules)
    
    echo -e "${YELLOW}📋 Módulos disponibles (${#available_modules[@]} total):${NC}" >&2
    
    local categories=()
    local current_cat=""
    
    for i in "${!available_modules[@]}"; do
        local module="${available_modules[$i]}"
        local cat="${module%%:*}"
        
        [[ "$cat" != "$current_cat" ]] && {
            [[ -n "$current_cat" ]] && echo >&2
            echo -e "${BOLD}  ${cat}:${NC}" >&2
            current_cat="$cat"
            categories+=("$cat")
        }
        
        printf "    %2d) %s\n" "$((i+1))" "$module" >&2
    done
    
    echo >&2
    echo -e "${CYAN}💡 Opciones especiales:${NC}" >&2
    echo -e "  • ${BOLD}all${NC} - Todos los módulos" >&2
    echo -e "  • ${BOLD}cat:*${NC} - Toda una categoría (ej: core:*, development:*)" >&2
    echo >&2
    
    read -p "Selección (números, 'all', o 'cat:*'): " selection >&2
    
    case "$selection" in
        "all")
            printf '%s\n' "${available_modules[@]}"
            ;;
        *:*)
            local pattern="${selection%:*}"
            for module in "${available_modules[@]}"; do
                [[ "$module" =~ ^${pattern}: ]] && echo "$module"
            done
            ;;
        *)
            IFS=',' read -ra indices <<< "$selection"
            for idx in "${indices[@]}"; do
                idx=$(echo "$idx" | xargs)
                [[ "$idx" =~ ^[0-9]+$ && $idx -ge 1 && $idx -le ${#available_modules[@]} ]] && {
                    echo "${available_modules[$((idx-1))]}"
                }
            done
            ;;
    esac
}

# =====================================================
# 🔧 FUNCIÓN PRINCIPAL OPTIMIZADA
# =====================================================

main() {
    # Crear directorio de cache si no existe
    mkdir -p "$(dirname "$LOG_FILE")" "$(dirname "$LOCKFILE")"
    
    # Inicializar logging
    > "$LOG_FILE"
    log "Iniciando Arch Dream Installer v$PROJECT_VERSION"
    
    # Adquirir lock
    acquire_lock
    
    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--all)
                INSTALL_ALL=true
                shift
                ;;
            -l|--list)
                echo "📋 Módulos disponibles:"
                discover_modules | sed 's/^/  - /'
                exit 0
                ;;
            -f|--force)
                FORCE_INSTALL=true
                export FORCE_INSTALL=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -p|--parallel)
                PARALLEL_INSTALL=true
                shift
                ;;
            -b|--no-backup)
                BACKUP_CONFIGS=false
                shift
                ;;
            -q|--quiet)
                QUIET_MODE=true
                exec > /dev/null
                shift
                ;;
            -v|--verbose)
                VERBOSE_MODE=true
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
                SELECTED_MODULES+=("$1")
                shift
                ;;
        esac
    done
    
    # Variables de entorno
    [[ "${ARCH_DREAM_PARALLEL:-}" == "true" ]] && PARALLEL_INSTALL=true
    [[ "${CI:-}" == "true" ]] && FORCE_INSTALL=true
    
    show_banner
    system_check
    
    # Crear backup si es necesario
    [[ "$DRY_RUN" != "true" ]] && backup_existing_configs
    
    # Determinar módulos a instalar
    local modules_to_install=()
    
    if [[ "$INSTALL_ALL" == "true" ]]; then
        mapfile -t modules_to_install < <(discover_modules)
    elif [[ ${#SELECTED_MODULES[@]} -gt 0 ]]; then
        # Expandir wildcards (ej: core:*)
        for pattern in "${SELECTED_MODULES[@]}"; do
            if [[ "$pattern" == *:* ]]; then
                local category="${pattern%:*}"
                local module_part="${pattern#*:}"
                
                if [[ "$module_part" == "*" ]]; then
                    local matches=()
                    mapfile -t matches < <(discover_modules | grep "^${category}:")
                    [[ ${#matches[@]} -gt 0 ]] && modules_to_install+=("${matches[@]}")
                else
                    modules_to_install+=("$pattern")
                fi
            else
                modules_to_install+=("$pattern")
            fi
        done
    else
        mapfile -t modules_to_install < <(interactive_selection)
    fi
    
    [[ ${#modules_to_install[@]} -eq 0 ]] && {
        error "❌ No se seleccionaron módulos"
        exit 1
    }
    
    # Resolver dependencias
    log "🔗 Resolviendo dependencias..."
    local resolved_modules=()
    mapfile -t resolved_modules < <(resolve_dependencies "${modules_to_install[@]}")
    
    # Mostrar plan de instalación
    echo -e "${YELLOW}📋 Plan de instalación (${#resolved_modules[@]} módulos):${NC}"
    for module in "${resolved_modules[@]}"; do
        if [[ " ${modules_to_install[@]} " =~ " $module " ]]; then
            echo -e "  • $module"
        else
            echo -e "  • $module ${CYAN}(dependencia)${NC}"
        fi
    done
    echo
    
    # Confirmación final
    [[ "$DRY_RUN" != "true" && "$FORCE_INSTALL" != "true" ]] && {
        read -p "¿Continuar con la instalación? [y/N]: " -n 1 -r && echo
        [[ $REPLY =~ ^[Yy]$ ]] || {
            log "Instalación cancelada por el usuario"
            exit 0
        }
    }
    
    # Instalar módulos
    local start_time=$(date +%s)
    local installed=0
    local failed=0
    
    # Variables ya inicializadas anteriormente
    
    if [[ "$PARALLEL_INSTALL" == "true" && ${#resolved_modules[@]} -gt 1 ]]; then
        install_modules_parallel "${resolved_modules[@]}"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            installed=${#resolved_modules[@]}
            failed=0
        else
            for module in "${resolved_modules[@]}"; do
                if [[ -f "$HOME/.config/arch-dream/installed/$module" ]]; then
                    installed=$((installed + 1))
                else
                    failed=$((failed + 1))
                fi
            done
        fi
    else
        for module in "${resolved_modules[@]}"; do
            if install_module "$module"; then
                installed=$((installed + 1))
            else
                failed=$((failed + 1))
                [[ "$FORCE_INSTALL" != "true" ]] && break
            fi
        done
        
        # En modo dry run, todos los módulos se consideran instalados exitosamente
        if [[ "$DRY_RUN" == "true" ]]; then
            installed=${#resolved_modules[@]}
            failed=0
        fi
    fi
    
    local total_time=$(($(date +%s) - start_time))
    
    # Resumen final mejorado
    echo
    echo -e "${BOLD}${BLUE}📊 RESUMEN DE INSTALACIÓN${NC}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} Total de módulos: ${#resolved_modules[@]}"
    echo -e "${CYAN}│${NC} Instalados: ${GREEN}$installed${NC}"
    echo -e "${CYAN}│${NC} Fallidos: ${RED}$failed${NC}"
    echo -e "${CYAN}│${NC} Tiempo total: ${total_time}s"
    echo -e "${CYAN}│${NC} Log completo: $LOG_FILE"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
    
    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}🎉 ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!${NC}"
        echo
        echo -e "${YELLOW}🚀 Próximos pasos:${NC}"
        echo -e "  1. Reinicia tu terminal: ${CYAN}exec \$SHELL${NC}"
        echo -e "  2. Usa el CLI: ${CYAN}./arch-dream status${NC}"
        echo -e "  3. Explora las nuevas funcionalidades"
        
        [[ -f "$HOME/.arch-dream-last-backup" ]] && {
            echo
            echo -e "${CYAN}💾 Backup disponible en: $(cat "$HOME/.arch-dream-last-backup")${NC}"
        }
    else
        echo -e "${YELLOW}⚠️  INSTALACIÓN COMPLETADA CON $failed ERRORES${NC}"
        echo -e "${CYAN}📋 Revisa el log: $LOG_FILE${NC}"
        exit 1
    fi
}

# Ejecutar función principal
main "$@"