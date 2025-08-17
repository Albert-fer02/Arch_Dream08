#!/bin/bash
# =====================================================
# 🚀 ARCH DREAM - MIGRACIÓN RÁPIDA
# =====================================================
# Migración simplificada y directa
# =====================================================

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =====================================================
# 🧹 LIMPIEZA DE ARCHIVOS OBSOLETOS
# =====================================================

cleanup_obsolete() {
    log "🧹 Eliminando archivos obsoletos..."
    
    local cleaned=0
    
    # Archivos P10K obsoletos
    local p10k_files=(
        "modules/core/zsh/p10k.zsh"
        "modules/core/zsh/p10k.root.zsh" 
        "modules/core/zsh/p10k-base.zsh"
        "modules/core/zsh/clean-p10k-cache.sh"
        "modules/core/zsh/setup-root.sh"
        "modules/core/bash/oh-my-posh.dreamcoder.json"
    )
    
    for file in "${p10k_files[@]}"; do
        if [[ -f "$file" ]]; then
            rm -f "$file" && ((cleaned++))
            log "Eliminado: $file"
        fi
    done
    
    # Scripts complejos innecesarios  
    local complex_scripts=(
        "lib/backup-rollback.sh"
        "lib/cache-system.sh"
        "lib/dependency-manager.sh"
        "lib/parallel-installer.sh"
    )
    
    for script in "${complex_scripts[@]}"; do
        if [[ -f "$script" ]]; then
            rm -f "$script" && ((cleaned++))
            log "Eliminado: $script"
        fi
    done
    
    success "✅ Limpieza completada: $cleaned archivos eliminados"
}

# =====================================================
# 🔧 CONFIGURACIÓN DE ENLACES
# =====================================================

setup_symlinks() {
    log "🔧 Configurando enlaces simbólicos..."
    
    # Backup actual si existe
    [[ -f ~/.bashrc ]] && cp ~/.bashrc ~/.bashrc.backup.$(date +%s)
    [[ -f ~/.zshrc ]] && cp ~/.zshrc ~/.zshrc.backup.$(date +%s)
    
    # Crear directorios necesarios
    mkdir -p ~/.config
    
    # Enlaces principales
    ln -sf "$SCRIPT_DIR/modules/core/bash/bashrc" ~/.bashrc
    ln -sf "$SCRIPT_DIR/modules/core/zsh/zshrc" ~/.zshrc
    ln -sf "$SCRIPT_DIR/lib/starship.toml" ~/.config/starship.toml
    
    success "✅ Enlaces simbólicos configurados"
}

# =====================================================
# ✅ VALIDACIÓN
# =====================================================

validate_setup() {
    log "✅ Validando configuración..."
    
    local errors=0
    
    # Verificar archivos clave
    local key_files=(
        "lib/shell-base.sh"
        "lib/module-manager.sh" 
        "lib/simple-backup.sh"
        "install-unified.sh"
        "~/.bashrc"
        "~/.zshrc"
        "~/.config/starship.toml"
    )
    
    for file in "${key_files[@]}"; do
        local expanded_file=$(eval echo "$file")
        if [[ -e "$expanded_file" ]]; then
            success "✓ $file"
        else
            error "✗ $file no existe"
            ((errors++))
        fi
    done
    
    # Test sintaxis bash
    if [[ -f ~/.bashrc ]]; then
        if bash -n ~/.bashrc; then
            success "✓ .bashrc sintaxis OK"
        else
            error "✗ .bashrc tiene errores de sintaxis"
            ((errors++))
        fi
    fi
    
    return $errors
}

# =====================================================
# 📊 ESTADÍSTICAS
# =====================================================

show_stats() {
    log "📊 Estadísticas del proyecto optimizado..."
    
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}                   Arch Dream 4.0                        ${BLUE}│${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────────┤${NC}"
    
    # Contar archivos
    local total_files=$(find . -type f | wc -l)
    local config_files=$(find . -name "*.conf" -o -name "*.toml" -o -name "*.json" | wc -l)
    local shell_scripts=$(find . -name "*.sh" | wc -l)
    
    echo -e "${BLUE}│${NC} Archivos totales:     $total_files"
    echo -e "${BLUE}│${NC} Scripts shell:        $shell_scripts"
    echo -e "${BLUE}│${NC} Archivos config:      $config_files"
    
    # Tamaño total
    local total_size=$(du -sh . | cut -f1)
    echo -e "${BLUE}│${NC} Tamaño total:         $total_size"
    
    # Módulos disponibles
    local modules=$(find modules -name "install.sh" | wc -l)
    echo -e "${BLUE}│${NC} Módulos disponibles:  $modules"
    
    echo -e "${BLUE}└─────────────────────────────────────────────────────────┘${NC}"
}

# =====================================================
# 🏁 FUNCIÓN PRINCIPAL
# =====================================================

main() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                🚀 ARCH DREAM QUICK MIGRATION                   ║
║                     Optimización Rápida                       ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    log "🚀 Iniciando migración rápida..."
    
    # Ejecutar pasos
    cleanup_obsolete
    setup_symlinks
    
    # Validar
    local validation_errors=0
    validate_setup || validation_errors=$?
    
    # Mostrar estadísticas
    show_stats
    
    echo
    if [[ $validation_errors -eq 0 ]]; then
        echo -e "${GREEN}🎉 ¡MIGRACIÓN COMPLETADA EXITOSAMENTE!${NC}"
        echo
        echo -e "${CYAN}📋 Próximos pasos:${NC}"
        echo -e "  1. Reinicia tu terminal: ${YELLOW}exec \$SHELL${NC}"
        echo -e "  2. Prueba el nuevo instalador: ${YELLOW}./install-unified.sh --help${NC}"
        echo -e "  3. Instala módulos: ${YELLOW}./install-unified.sh core:zsh${NC}"
    else
        echo -e "${YELLOW}⚠️  MIGRACIÓN COMPLETADA CON $validation_errors ADVERTENCIAS${NC}"
        echo -e "Revisa los errores mostrados arriba"
    fi
    
    echo
    echo -e "${BLUE}💡 Tu Arch Dream ahora está optimizado y listo para usar!${NC}"
}

# Ejecutar migración
main "$@"