#!/bin/bash
# =====================================================
# 🚀 ARCH DREAM - INSTALADOR SIMPLE
# =====================================================
# Instalador directo y simplificado para módulos
# =====================================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log() { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =====================================================
# 🔧 FUNCIONES BÁSICAS
# =====================================================

show_help() {
    cat << EOF
${BOLD}${CYAN}🚀 Arch Dream - Instalador Simple${NC}

Uso: $0 [OPCIONES] [MÓDULOS...]

${YELLOW}OPCIONES:${NC}
    -a, --all       Instalar todos los módulos
    -l, --list      Listar módulos disponibles
    -h, --help      Mostrar esta ayuda

${YELLOW}MÓDULOS DISPONIBLES:${NC}
$(discover_modules | sed 's/^/    /')

${YELLOW}EJEMPLOS:${NC}
    $0 --all                    # Instalar todo
    $0 core:zsh terminal:kitty  # Módulos específicos
    $0 --list                   # Ver módulos disponibles

EOF
}

# Descubrir módulos disponibles
discover_modules() {
    for category_dir in "$SCRIPT_DIR/modules"/*; do
        [[ -d "$category_dir" ]] || continue
        local category=$(basename "$category_dir")
        
        for module_dir in "$category_dir"/*; do
            [[ -d "$module_dir" && -f "$module_dir/install.sh" ]] || continue
            local module=$(basename "$module_dir")
            echo "$category:$module"
        done
    done
}

# Instalar módulo individual
install_module() {
    local module_id="$1"
    local category="${module_id%:*}"
    local module="${module_id#*:}"
    local module_path="$SCRIPT_DIR/modules/$category/$module"
    
    if [[ ! -d "$module_path" ]] || [[ ! -f "$module_path/install.sh" ]]; then
        error "❌ Módulo no encontrado: $module_id"
        return 1
    fi
    
    log "📦 Instalando módulo: $module_id"
    
    # Cambiar al directorio del módulo y ejecutar
    (
        cd "$module_path"
        export FORCE_INSTALL=true
        bash install.sh
    ) || {
        error "❌ Error instalando $module_id"
        return 1
    }
    
    success "✅ Módulo $module_id instalado exitosamente"
}

# Verificaciones básicas del sistema
system_check() {
    log "🔍 Verificando sistema..."
    
    # Verificar Arch Linux
    if [[ ! -f /etc/arch-release ]] && ! command -v pacman &>/dev/null; then
        error "❌ Este instalador requiere Arch Linux"
        return 1
    fi
    
    # Verificar herramientas básicas
    local required_tools=("git" "curl" "sudo")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            error "❌ Herramienta requerida no encontrada: $tool"
            return 1
        fi
    done
    
    success "✅ Sistema verificado"
}

# =====================================================
# 🏁 FUNCIÓN PRINCIPAL
# =====================================================

main() {
    # Banner
    echo -e "${BOLD}${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║              🚀 ARCH DREAM INSTALLER                      ║
║                  Simple & Efficient                       ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Parsear argumentos
    local install_all=false
    local modules_to_install=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--all)
                install_all=true
                shift
                ;;
            -l|--list)
                echo -e "${YELLOW}📋 Módulos disponibles:${NC}"
                discover_modules | sed 's/^/  • /'
                exit 0
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
                modules_to_install+=("$1")
                shift
                ;;
        esac
    done
    
    # Verificar sistema
    system_check
    
    # Determinar módulos a instalar
    local final_modules=()
    if [[ "$install_all" == "true" ]]; then
        mapfile -t final_modules < <(discover_modules)
    elif [[ ${#modules_to_install[@]} -gt 0 ]]; then
        final_modules=("${modules_to_install[@]}")
    else
        # Selección interactiva simple
        echo -e "${YELLOW}📋 Módulos disponibles:${NC}"
        local available_modules=()
        mapfile -t available_modules < <(discover_modules)
        
        for i in "${!available_modules[@]}"; do
            echo "  $((i+1))) ${available_modules[$i]}"
        done
        
        echo
        read -p "Introduce los números separados por coma (o 'all' para todos): " selection
        
        if [[ "$selection" == "all" ]]; then
            final_modules=("${available_modules[@]}")
        else
            IFS=',' read -ra indices <<< "$selection"
            for idx in "${indices[@]}"; do
                idx=$(echo "$idx" | xargs)  # trim
                if [[ "$idx" =~ ^[0-9]+$ ]] && (( idx >= 1 && idx <= ${#available_modules[@]} )); then
                    final_modules+=("${available_modules[$((idx-1))]}")
                fi
            done
        fi
    fi
    
    if [[ ${#final_modules[@]} -eq 0 ]]; then
        error "❌ No se seleccionaron módulos para instalar"
        exit 1
    fi
    
    # Mostrar plan
    echo -e "${YELLOW}📋 Plan de instalación:${NC}"
    for module in "${final_modules[@]}"; do
        echo -e "  • $module"
    done
    echo
    
    # Confirmación
    read -p "¿Continuar con la instalación? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Instalación cancelada"
        exit 0
    fi
    
    # Instalar módulos
    local installed=0
    local failed=0
    
    for module in "${final_modules[@]}"; do
        if install_module "$module"; then
            ((installed++))
        else
            ((failed++))
        fi
    done
    
    # Resumen final
    echo
    echo -e "${BOLD}${BLUE}📊 RESUMEN DE INSTALACIÓN${NC}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} Total módulos: ${#final_modules[@]}"
    echo -e "${CYAN}│${NC} Instalados: ${GREEN}$installed${NC}"
    echo -e "${CYAN}│${NC} Fallidos: ${RED}$failed${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────┘${NC}"
    
    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}🎉 ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!${NC}"
        echo
        echo -e "${CYAN}📋 Próximos pasos:${NC}"
        echo -e "  1. Reinicia tu terminal: ${YELLOW}exec \$SHELL${NC}"
        echo -e "  2. Disfruta tu nuevo entorno Arch Dream!"
    else
        echo -e "${YELLOW}⚠️  INSTALACIÓN COMPLETADA CON ERRORES${NC}"
        echo -e "Algunos módulos no se pudieron instalar correctamente."
    fi
}

# Ejecutar instalador
main "$@"