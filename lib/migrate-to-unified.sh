#!/bin/bash
# =====================================================
# 🔄 ARCH DREAM - MIGRATION TO UNIFIED ARCHITECTURE
# =====================================================
# Script para migrar configuraciones existentes a la nueva arquitectura unificada
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh" 2>/dev/null || {
    echo "⚠️  Warning: common.sh not found, using basic functions"
    
    # Funciones básicas de fallback
    log() { echo "📝 $*"; }
    success() { echo "✅ $*"; }
    warn() { echo "⚠️  $*"; }
    error() { echo "❌ $*"; }
    confirm() {
        local message="$1"
        local default="${2:-false}"
        read -p "$message [y/N]: " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    }
}

# =====================================================
# 🔧 MIGRATION FUNCTIONS
# =====================================================

backup_existing_configs() {
    log "Creando respaldo de configuraciones existentes..."
    
    local backup_dir="$HOME/.config/arch-dream-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup shell configs
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$backup_dir/zshrc.bak"
    [[ -f "$HOME/.bashrc" ]] && cp "$HOME/.bashrc" "$backup_dir/bashrc.bak"
    [[ -f "$HOME/.config/starship.toml" ]] && cp "$HOME/.config/starship.toml" "$backup_dir/starship.toml.bak"
    
    # Backup P10K configs if they exist
    [[ -f "$HOME/.p10k.zsh" ]] && cp "$HOME/.p10k.zsh" "$backup_dir/p10k.zsh.bak"
    
    success "✅ Respaldo creado en: $backup_dir"
    echo "$backup_dir" > "$HOME/.arch-dream-last-backup"
}

clean_obsolete_files() {
    log "Limpiando archivos obsoletos..."
    
    local cleaned=0
    
    # Remove P10K files
    if [[ -f "$HOME/.p10k.zsh" ]]; then
        rm -f "$HOME/.p10k.zsh"
        ((cleaned++))
    fi
    
    # Clean P10K cache
    if [[ -d "$HOME/.cache/p10k-instant-prompt-$(whoami)" ]]; then
        rm -rf "$HOME/.cache/p10k-instant-prompt-$(whoami)"
        ((cleaned++))
    fi
    
    # Clean old zinit cache if it exists
    if [[ -d "$HOME/.zinit" ]]; then
        if confirm "¿Eliminar caché antiguo de Zinit (~/.zinit)?"; then
            rm -rf "$HOME/.zinit"
            ((cleaned++))
        fi
    fi
    
    success "✅ $cleaned archivos/directorios obsoletos eliminados"
}

setup_unified_symlinks() {
    log "Configurando enlaces simbólicos unificados..."
    
    local project_root="$SCRIPT_DIR/.."
    
    # Create symlinks for new unified configs
    ln -sf "$project_root/modules/core/zsh/zshrc" "$HOME/.zshrc"
    ln -sf "$project_root/modules/core/bash/bashrc" "$HOME/.bashrc"
    ln -sf "$project_root/lib/starship.toml" "$HOME/.config/starship.toml"
    
    # Ensure config directory exists
    mkdir -p "$HOME/.config"
    
    success "✅ Enlaces simbólicos configurados"
}

update_shell_cache() {
    log "Actualizando caché del shell..."
    
    # Clear zsh completion cache
    rm -f ~/.zsh/compdump* 2>/dev/null || true
    rm -f ~/.zcompdump* 2>/dev/null || true
    
    # Clear bash completion cache if it exists
    rm -f ~/.bash_completion_cache 2>/dev/null || true
    
    success "✅ Caché del shell limpiado"
}

show_migration_summary() {
    echo
    echo -e "${BOLD}${GREEN}🎉 MIGRACIÓN COMPLETADA EXITOSAMENTE${COLOR_RESET}"
    echo
    echo -e "${CYAN}📋 Resumen de cambios:${COLOR_RESET}"
    echo -e "  ✅ Configuraciones respaldadas"
    echo -e "  ✅ Archivos obsoletos eliminados"
    echo -e "  ✅ Arquitectura unificada configurada"
    echo -e "  ✅ Enlaces simbólicos actualizados"
    echo -e "  ✅ Caché de shell limpiado"
    echo
    echo -e "${YELLOW}🔄 Próximos pasos:${COLOR_RESET}"
    echo -e "  1. Reinicia tu terminal o ejecuta: exec \$SHELL"
    echo -e "  2. Verifica que todo funcione correctamente"
    echo -e "  3. Personaliza en ~/.zshrc.local o ~/.bashrc.local"
    echo
    echo -e "${PURPLE}📦 Nueva estructura:${COLOR_RESET}"
    echo -e "  🔹 lib/shell-base.sh - Configuración base unificada"
    echo -e "  🔹 lib/starship.toml - Configuración única de Starship"
    echo -e "  🔹 modules/core/*/\*rc - Configuraciones específicas del shell"
    echo
    
    if [[ -f "$HOME/.arch-dream-last-backup" ]]; then
        local backup_dir=$(cat "$HOME/.arch-dream-last-backup")
        echo -e "${BLUE}💾 Respaldo disponible en: $backup_dir${COLOR_RESET}"
    fi
}

# =====================================================
# 🏁 MAIN FUNCTION
# =====================================================

main() {
    echo -e "${BOLD}${CYAN}🔄 ARCH DREAM - MIGRACIÓN A ARQUITECTURA UNIFICADA${COLOR_RESET}"
    echo -e "${CYAN}Migrando configuraciones shell a la nueva arquitectura optimizada${COLOR_RESET}\n"
    
    # Verificar que estamos en el directorio correcto
    if [[ ! -f "$SCRIPT_DIR/../modules/core/zsh/zshrc" ]]; then
        error "❌ No se encontraron los archivos de configuración unificada"
        error "Asegúrate de ejecutar este script desde el directorio correcto"
        exit 1
    fi
    
    # Confirmar migración
    if ! confirm "¿Proceder con la migración a la arquitectura unificada?" true; then
        echo "Migración cancelada"
        exit 0
    fi
    
    # Ejecutar migración
    backup_existing_configs
    clean_obsolete_files
    setup_unified_symlinks
    update_shell_cache
    show_migration_summary
    
    echo -e "\n${BOLD}${GREEN}🚀 ¡Disfruta tu nueva configuración shell unificada!${COLOR_RESET}"
}

# Ejecutar función principal
main "$@"