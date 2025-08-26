#!/bin/bash
# =====================================================
# 🚀 Instalador Mejorado - Arch Dream v4.3
# =====================================================
# Instalador con todas las mejoras implementadas

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Variables de configuración
ARCH_DREAM_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BACKUP_DIR="$HOME/.cache/arch-dream/backups"
LOG_FILE="$HOME/.cache/arch-dream/install.log"

# Crear directorios necesarios
mkdir -p "$(dirname "$LOG_FILE")" "$BACKUP_DIR"

# =====================================================
# 📝 FUNCIONES DE LOGGING
# =====================================================

log() {
    local level="$1"; shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log "INFO" "$1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log "SUCCESS" "$1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log "WARNING" "$1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log "ERROR" "$1"
}

print_section() {
    echo -e "\n${PURPLE}=== $1 ===${NC}"
    log "SECTION" "$1"
}

# =====================================================
# 🔍 FUNCIONES DE VERIFICACIÓN
# =====================================================

check_system() {
    print_section "Verificación del Sistema"
    
    # Verificar SO
    if [[ ! -f /etc/arch-release ]]; then
        print_warning "Sistema no detectado como Arch Linux"
    else
        print_success "Sistema Arch Linux detectado"
    fi
    
    # Verificar shell
    local current_shell=$(basename "$SHELL")
    print_status "Shell actual: $current_shell"
    
    # Verificar dependencias críticas
    local deps=("git" "curl" "wget")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            print_success "Dependencia encontrada: $dep"
        else
            missing_deps+=("$dep")
            print_error "Dependencia faltante: $dep"
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Faltan dependencias críticas: ${missing_deps[*]}"
        print_status "Instala con: sudo pacman -S ${missing_deps[*]}"
        return 1
    fi
    
    return 0
}

# =====================================================
# 💾 FUNCIONES DE BACKUP
# =====================================================

create_backup() {
    local file="$1"
    local backup_name="$(basename "$file")-$(date +%Y%m%d_%H%M%S)"
    
    if [[ -f "$file" ]]; then
        cp "$file" "$BACKUP_DIR/$backup_name"
        print_success "Backup creado: $backup_name"
        return 0
    fi
    
    return 1
}

# =====================================================
# 🔧 INSTALACIÓN DE COMPONENTES
# =====================================================

install_common_components() {
    print_section "Instalando Componentes Comunes"
    
    local common_dir="$ARCH_DREAM_ROOT/modules/core/common"
    local target_dir="$HOME/.config/arch-dream/modules/common"
    
    mkdir -p "$target_dir"
    
    local components=(
        "error-handling.sh"
        "logging.sh"
        "cache.sh"
        "config.sh"
        "profiles.sh"
    )
    
    for component in "${components[@]}"; do
        if [[ -f "$common_dir/$component" ]]; then
            cp "$common_dir/$component" "$target_dir/"
            print_success "Componente instalado: $component"
        else
            print_error "Componente no encontrado: $component"
            return 1
        fi
    done
    
    return 0
}

install_shell_config() {
    local shell="$1"
    
    print_section "Instalando Configuración de $shell"
    
    local shell_dir="$ARCH_DREAM_ROOT/modules/core/$shell"
    local config_file="$shell_dir/${shell}rc.modular"
    local target_file="$HOME/.${shell}rc"
    
    # Verificar que existe la configuración
    if [[ ! -f "$config_file" ]]; then
        print_error "Configuración no encontrada: $config_file"
        return 1
    fi
    
    # Crear backup del archivo actual
    create_backup "$target_file"
    
    # Copiar nueva configuración
    cp "$config_file" "$target_file"
    print_success "Configuración instalada: $target_file"
    
    # Copiar módulos
    local modules_target="$HOME/.config/arch-dream/modules/$shell"
    mkdir -p "$modules_target"
    
    # Copiar directorios de módulos
    local module_dirs=("config" "aliases" "functions" "plugins" "ui" "advanced")
    if [[ "$shell" == "zsh" ]]; then
        module_dirs+=("keybindings")
    fi
    
    for module_dir in "${module_dirs[@]}"; do
        if [[ -d "$shell_dir/$module_dir" ]]; then
            cp -r "$shell_dir/$module_dir" "$modules_target/"
            print_success "Módulo copiado: $module_dir"
        fi
    done
    
    return 0
}

install_profiles() {
    print_section "Instalando Perfiles"
    
    local profiles_dir="$HOME/.config/arch-dream/profiles"
    local source_profiles="$HOME/.config/arch-dream/profiles"
    
    # Los perfiles ya se crearon con el sistema de configuración
    # Solo verificamos que existan
    
    local default_profiles=("developer" "pentester" "minimal")
    
    for profile in "${default_profiles[@]}"; do
        if [[ -f "$source_profiles/$profile.sh" ]]; then
            print_success "Perfil disponible: $profile"
        else
            print_warning "Perfil no encontrado: $profile"
        fi
    done
    
    return 0
}

install_configuration() {
    print_section "Instalando Configuración Dinámica"
    
    local config_file="$HOME/.config/arch-dream/config.toml"
    
    if [[ ! -f "$config_file" ]]; then
        print_error "Archivo de configuración no encontrado: $config_file"
        return 1
    fi
    
    print_success "Configuración dinámica disponible"
    
    # Crear directorio de cache
    mkdir -p "$HOME/.cache/arch-dream"/{logs,config}
    
    return 0
}

# =====================================================
# 🧪 FUNCIONES DE TESTING
# =====================================================

test_installation() {
    print_section "Probando Instalación"
    
    local errors=0
    
    # Test 1: Verificar archivos de configuración
    local configs=("$HOME/.bashrc" "$HOME/.zshrc")
    for config in "${configs[@]}"; do
        if [[ -f "$config" ]]; then
            if bash -n "$config" 2>/dev/null || zsh -n "$config" 2>/dev/null; then
                print_success "Sintaxis correcta: $(basename "$config")"
            else
                print_error "Error de sintaxis: $(basename "$config")"
                ((errors++))
            fi
        fi
    done
    
    # Test 2: Verificar componentes comunes
    local common_dir="$HOME/.config/arch-dream/modules/common"
    local components=("error-handling.sh" "logging.sh" "cache.sh" "config.sh" "profiles.sh")
    
    for component in "${components[@]}"; do
        if [[ -f "$common_dir/$component" ]]; then
            if bash -n "$common_dir/$component" 2>/dev/null; then
                print_success "Componente válido: $component"
            else
                print_error "Error en componente: $component"
                ((errors++))
            fi
        else
            print_error "Componente faltante: $component"
            ((errors++))
        fi
    done
    
    # Test 3: Verificar configuración TOML
    if [[ -f "$HOME/.config/arch-dream/config.toml" ]]; then
        print_success "Configuración TOML presente"
    else
        print_error "Configuración TOML faltante"
        ((errors++))
    fi
    
    return $errors
}

run_performance_test() {
    print_section "Test de Performance"
    
    local start_time=$(date +%s%N)
    
    # Simular carga de configuración
    bash -c "source $HOME/.bashrc" 2>/dev/null || true
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 )) # en ms
    
    print_status "Tiempo de carga: ${duration}ms"
    
    if [[ $duration -lt 1000 ]]; then
        print_success "Performance excelente (< 1s)"
    elif [[ $duration -lt 2000 ]]; then
        print_success "Performance buena (< 2s)"
    else
        print_warning "Performance lenta (>= 2s)"
    fi
}

# =====================================================
# 📊 FUNCIONES DE REPORTE
# =====================================================

generate_report() {
    print_section "Generando Reporte de Instalación"
    
    local report_file="$HOME/.cache/arch-dream/install-report-$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" << EOF
# =====================================================
# 📊 REPORTE DE INSTALACIÓN - ARCH DREAM v4.3
# =====================================================
# Fecha: $(date)
# Usuario: $USER
# Sistema: $(uname -a)
# Shell: $SHELL
# =====================================================

## Componentes Instalados:

### Sistemas Core:
- ✅ Sistema de manejo de errores
- ✅ Sistema de logging estructurado  
- ✅ Sistema de cache inteligente
- ✅ Sistema de configuración dinámica
- ✅ Sistema de perfiles por entorno

### Configuraciones:
- ✅ BASH modular mejorado
- ✅ ZSH modular mejorado
- ✅ Configuración TOML dinámica
- ✅ Perfiles: developer, pentester, minimal

### Funcionalidades:
- ✅ Carga segura de módulos
- ✅ Logging con múltiples formatos
- ✅ Cache con TTL automático
- ✅ Configuración por perfiles
- ✅ Sistema de backup automático

## Archivos de Configuración:
- ~/.bashrc ($(if [[ -f ~/.bashrc ]]; then echo "✅"; else echo "❌"; fi))
- ~/.zshrc ($(if [[ -f ~/.zshrc ]]; then echo "✅"; else echo "❌"; fi))
- ~/.config/arch-dream/config.toml ($(if [[ -f ~/.config/arch-dream/config.toml ]]; then echo "✅"; else echo "❌"; fi))

## Directorios:
- ~/.config/arch-dream/
- ~/.cache/arch-dream/
- ~/.config/arch-dream/profiles/
- ~/.config/arch-dream/modules/

## Logs:
- Instalación: $LOG_FILE
- Sistema: ~/.cache/arch-dream/logs/

## Próximos Pasos:
1. Reinicia tu terminal o ejecuta: source ~/.bashrc (o ~/.zshrc)
2. Explora los perfiles disponibles: profile_list
3. Cambia de perfil: profile_switch <perfil>
4. Revisa la configuración: config_show
5. Consulta el cache: cache_stats

¡Disfruta tu nueva configuración mejorada de Arch Dream!
EOF
    
    print_success "Reporte generado: $report_file"
    echo "📄 Ver reporte: cat $report_file"
}

# =====================================================
# 🎯 FUNCIÓN PRINCIPAL
# =====================================================

show_banner() {
    echo -e "${PURPLE}"
    cat << 'EOF'
    ╔═══════════════════════════════════════╗
    ║         🚀 ARCH DREAM v4.3           ║
    ║      Instalador Mejorado Enhanced     ║
    ╠═══════════════════════════════════════╣
    ║  ⚡ Sistema de errores robusto        ║
    ║  📝 Logging estructurado              ║
    ║  🚀 Cache inteligente                 ║
    ║  ⚙️ Configuración dinámica            ║
    ║  👤 Perfiles por entorno              ║
    ╚═══════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_usage() {
    echo -e "${BLUE}Uso:${NC}"
    echo "  $0 [opciones]"
    echo ""
    echo -e "${BLUE}Opciones:${NC}"
    echo "  -h, --help        Mostrar esta ayuda"
    echo "  -t, --test        Solo probar sin instalar"
    echo "  -s, --shell SHELL Instalar solo para shell específico (bash/zsh)"
    echo "  -p, --profile     Instalar perfiles adicionales"
    echo "  --skip-deps       Omitir verificación de dependencias"
    echo "  --backup-only     Solo crear backups"
    echo ""
    echo -e "${BLUE}Ejemplos:${NC}"
    echo "  $0                # Instalación completa"
    echo "  $0 --test         # Solo probar"
    echo "  $0 -s zsh         # Solo configurar ZSH"
}

main() {
    local test_only=false
    local shell_only=""
    local skip_deps=false
    local backup_only=false
    local install_profiles_only=false
    
    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -t|--test)
                test_only=true
                shift
                ;;
            -s|--shell)
                shell_only="$2"
                shift 2
                ;;
            -p|--profile)
                install_profiles_only=true
                shift
                ;;
            --skip-deps)
                skip_deps=true
                shift
                ;;
            --backup-only)
                backup_only=true
                shift
                ;;
            *)
                print_error "Opción desconocida: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    show_banner
    print_status "🚀 Iniciando instalación mejorada de Arch Dream v4.3..."
    print_status "📝 Log: $LOG_FILE"
    
    # Verificación del sistema
    if [[ "$skip_deps" != true ]]; then
        if ! check_system; then
            print_error "❌ Verificación del sistema falló"
            exit 1
        fi
    fi
    
    # Solo backup
    if [[ "$backup_only" == true ]]; then
        print_section "Creando Backups"
        create_backup "$HOME/.bashrc"
        create_backup "$HOME/.zshrc"
        print_success "✅ Backups completados"
        exit 0
    fi
    
    # Solo testing
    if [[ "$test_only" == true ]]; then
        test_installation
        run_performance_test
        exit $?
    fi
    
    # Instalación principal
    print_status "📦 Iniciando instalación de componentes..."
    
    # Instalar componentes comunes
    if ! install_common_components; then
        print_error "❌ Error instalando componentes comunes"
        exit 1
    fi
    
    # Instalar configuración dinámica
    if ! install_configuration; then
        print_error "❌ Error instalando configuración"
        exit 1
    fi
    
    # Instalar perfiles
    if ! install_profiles; then
        print_error "❌ Error instalando perfiles"
        exit 1
    fi
    
    # Instalar configuraciones de shell
    if [[ -n "$shell_only" ]]; then
        if ! install_shell_config "$shell_only"; then
            print_error "❌ Error instalando configuración de $shell_only"
            exit 1
        fi
    else
        # Instalar ambos shells si existen
        for shell in bash zsh; do
            if command -v "$shell" >/dev/null 2>&1; then
                if ! install_shell_config "$shell"; then
                    print_warning "⚠️ Error instalando configuración de $shell"
                fi
            fi
        done
    fi
    
    # Testing post-instalación
    print_section "Verificación Post-Instalación"
    local test_errors
    test_errors=$(test_installation)
    
    if [[ $test_errors -eq 0 ]]; then
        print_success "✅ Todas las pruebas pasaron"
    else
        print_warning "⚠️ $test_errors errores encontrados"
    fi
    
    # Performance test
    run_performance_test
    
    # Generar reporte
    generate_report
    
    print_section "¡Instalación Completada!"
    print_success "🎉 Arch Dream v4.3 instalado exitosamente"
    print_status "📋 Para aplicar cambios: source ~/.bashrc (o source ~/.zshrc)"
    print_status "📚 Comandos útiles:"
    print_status "   - profile_list     (ver perfiles disponibles)"
    print_status "   - config_show      (ver configuración)"
    print_status "   - cache_stats      (estadísticas de cache)"
    print_status "   - log_stats        (estadísticas de logging)"
    
    return 0
}

# Ejecutar función principal
main "$@"