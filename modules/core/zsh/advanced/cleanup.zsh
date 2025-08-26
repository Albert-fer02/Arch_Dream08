#!/bin/zsh
# =====================================================
# 🧹 LIMPIEZA ESENCIAL DEL SISTEMA ZSH
# =====================================================

# Función para limpiar variables de Starship conflictivas
cleanup_starship_conflicts() {
    local starship_vars=(
        "STARSHIP_CMD_STATUS"
        "STARSHIP_DURATION" 
        "STARSHIP_JOBS"
        "STARSHIP_KUBECONTEXT"
        "STARSHIP_PACKAGE"
        "STARSHIP_PHP_VERSION"
        "STARSHIP_PYTHON_VERSION"
        "STARSHIP_RUBY_VERSION"
        "STARSHIP_RUST_VERSION"
        "STARSHIP_NODE_VERSION"
    )
    
    for var in "${starship_vars[@]}"; do
        if [[ -n "${(P)var}" ]]; then
            unset "$var" 2>/dev/null || true
        fi
    done
}

# Función principal de limpieza
perform_cleanup() {
    cleanup_starship_conflicts
    echo "✅ Limpieza completada"
}
