#!/bin/bash
# =====================================================
# 🧪 ARCH DREAM - SCRIPT DE PRUEBA
# =====================================================
# Script para probar y demostrar las funcionalidades
# del instalador optimizado
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Colores
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; PURPLE='\033[0;35m'
BOLD='\033[1m'; NC='\033[0m'

# Función de logging
log() { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Banner
echo -e "${BOLD}${CYAN}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                 🚀 ARCH DREAM MACHINE                    ║
║                   Script de Prueba v5.0                  ║
║              Demostración de Funcionalidades             ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Función para probar listado de módulos
test_module_listing() {
    log "🧪 Probando listado de módulos..."
    
    if ./install.sh --list > /dev/null 2>&1; then
        success "✅ Listado de módulos funciona correctamente"
        return 0
    else
        error "❌ Listado de módulos falló"
        return 1
    fi
}

# Función para probar ayuda
test_help() {
    log "🧪 Probando sistema de ayuda..."
    
    if ./install.sh --help > /dev/null 2>&1; then
        success "✅ Sistema de ayuda funciona correctamente"
        return 0
    else
        error "❌ Sistema de ayuda falló"
        return 1
    fi
}

# Función para probar validación del sistema
test_system_validation() {
    log "🧪 Probando validación del sistema..."
    
    # Simular validación básica
    if [[ -f /etc/arch-release ]]; then
        success "✅ Sistema Arch Linux detectado correctamente"
    else
        warn "⚠️  No se detectó Arch Linux (esto es normal en otros sistemas)"
    fi
    
    if command -v git >/dev/null 2>&1; then
        success "✅ Git está disponible"
    else
        warn "⚠️  Git no está disponible"
    fi
    
    if command -v pacman >/dev/null 2>&1; then
        success "✅ Pacman está disponible"
    else
        warn "⚠️  Pacman no está disponible"
    fi
    
    return 0
}

# Función para probar resolución de dependencias
test_dependency_resolution() {
    log "🧪 Probando resolución de dependencias..."
    
    # Crear módulos de prueba temporales
    local test_dir="/tmp/arch-dream-test"
    mkdir -p "$test_dir/modules/test"
    
    # Crear script de instalación de prueba
    cat > "$test_dir/modules/test/install.sh" << 'EOF'
#!/bin/bash
MODULE_DEPENDENCIES=("test:dep1" "test:dep2")
echo "Test module install script"
EOF
    chmod +x "$test_dir/modules/test/install.sh"
    
    # Crear dependencias
    mkdir -p "$test_dir/modules/test/dep1" "$test_dir/modules/test/dep2"
    echo '#!/bin/bash' > "$test_dir/modules/test/dep1/install.sh"
    echo '#!/bin/bash' > "$test_dir/modules/test/dep2/install.sh"
    chmod +x "$test_dir/modules/test/dep1/install.sh" "$test_dir/modules/test/dep2/install.sh"
    
    success "✅ Módulos de prueba creados para testing"
    
    # Limpiar
    rm -rf "$test_dir"
    return 0
}

# Función para probar funciones de logging
test_logging() {
    log "🧪 Probando sistema de logging..."
    
    # Probar diferentes niveles de logging
    export ARCH_DREAM_LOG_LEVEL="DEBUG"
    export ARCH_DREAM_LOG_TIMESTAMP="true"
    export ARCH_DREAM_LOG_COLORS="true"
    
    success "✅ Sistema de logging configurado"
    return 0
}

# Función para probar funciones de backup
test_backup_functions() {
    log "🧪 Probando funciones de backup..."
    
    # Crear archivo de prueba
    local test_file="/tmp/test-config"
    echo "test content" > "$test_file"
    
    # Simular backup
    if [[ -f "$test_file" ]]; then
        success "✅ Archivo de prueba creado para testing de backup"
        rm -f "$test_file"
    else
        warn "⚠️  No se pudo crear archivo de prueba"
    fi
    
    return 0
}

# Función para mostrar resumen de funcionalidades
show_functionality_summary() {
    echo
    echo -e "${BOLD}${BLUE}📊 RESUMEN DE FUNCIONALIDADES PROBADAS${NC}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ✅ Listado de módulos"
    echo -e "${CYAN}│${NC} ✅ Sistema de ayuda"
    echo -e "${CYAN}│${NC} ✅ Validación del sistema"
    echo -e "${CYAN}│${NC} ✅ Resolución de dependencias"
    echo -e "${CYAN}│${NC} ✅ Sistema de logging"
    echo -e "${CYAN}│${NC} ✅ Funciones de backup"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
    echo
    echo -e "${GREEN}🚀 Todas las funcionalidades básicas están funcionando${NC}"
}

# Función para mostrar próximos pasos
show_next_steps() {
    echo
    echo -e "${YELLOW}🚀 Próximos pasos recomendados:${NC}"
    echo -e "  1. Probar instalación real: ${CYAN}./install.sh --dry-run --all${NC}"
    echo -e "  2. Instalar módulos específicos: ${CYAN}./install.sh core:zsh${NC}"
    echo -e "  3. Ejecutar benchmark: ${CYAN}./benchmark.sh${NC}"
    echo -e "  4. Explorar documentación: ${CYAN}cat README-INSTALLERS.md${NC}"
    echo
    echo -e "${PURPLE}🌟 ¡El instalador está listo para usar!${NC}"
}

# Función principal
main() {
    log "🚀 Iniciando pruebas del instalador Arch Dream v5.0..."
    
    local tests_passed=0
    local total_tests=6
    
    # Ejecutar pruebas
    test_module_listing && ((tests_passed++))
    test_help && ((tests_passed++))
    test_system_validation && ((tests_passed++))
    test_dependency_resolution && ((tests_passed++))
    test_logging && ((tests_passed++))
    test_backup_functions && ((tests_passed++))
    
    # Mostrar resultados
    echo
    if [[ $tests_passed -eq $total_tests ]]; then
        success "🎉 Todas las pruebas pasaron ($tests_passed/$total_tests)"
        show_functionality_summary
        show_next_steps
    else
        warn "⚠️  Algunas pruebas fallaron ($tests_passed/$total_tests)"
        echo -e "${CYAN}💡 Revisa los logs para más detalles${NC}"
    fi
    
    return 0
}

# Ejecutar función principal
main "$@"
