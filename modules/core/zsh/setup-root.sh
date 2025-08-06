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
# 🔴 ROOT ENVIRONMENT SETUP
# =====================================================
# Script para configurar el entorno de root correctamente
# =====================================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Funciones de logging
log() { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Verificar que estamos ejecutando como root
if [[ $EUID -ne 0 ]]; then
    error "Este script debe ejecutarse como root"
    exit 1
fi

ROOT_HOME="/root"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"

echo -e "${CYAN}🔴 Configurando entorno de root...${NC}"

# Crear directorios necesarios
mkdir -p "$ROOT_HOME/.config" "$ROOT_HOME/.zsh" "$ROOT_HOME/.cache" "$ROOT_HOME/.local/share"

# Configurar archivos de configuración de root
setup_root_configs() {
    log "Configurando archivos de configuración de root..."
    
    # Zsh configuration
    if [[ -f "$PROJECT_ROOT/modules/core/zsh/zshrc.root" ]]; then
        cp "$PROJECT_ROOT/modules/core/zsh/zshrc.root" "$ROOT_HOME/.zshrc"
        chmod 644 "$ROOT_HOME/.zshrc"
        success "Configuración de Zsh para root instalada"
    else
        warn "Archivo zshrc.root no encontrado"
    fi
    
    # Powerlevel10k configuration
    if [[ -f "$PROJECT_ROOT/modules/core/zsh/p10k.root.zsh" ]]; then
        cp "$PROJECT_ROOT/modules/core/zsh/p10k.root.zsh" "$ROOT_HOME/.p10k.zsh"
        chmod 644 "$ROOT_HOME/.p10k.zsh"
        success "Configuración de Powerlevel10k para root instalada"
    else
        warn "Archivo p10k.root.zsh no encontrado"
    fi
    
    # Bash configuration
    if [[ -f "$PROJECT_ROOT/modules/core/bash/bashrc.root" ]]; then
        cp "$PROJECT_ROOT/modules/core/bash/bashrc.root" "$ROOT_HOME/.bashrc"
        chmod 644 "$ROOT_HOME/.bashrc"
        success "Configuración de Bash para root instalada"
    else
        warn "Archivo bashrc.root no encontrado"
    fi
}

# Configurar Oh My Zsh para root
setup_oh_my_zsh() {
    log "Configurando Oh My Zsh para root..."
    
    if [[ ! -d "$ROOT_HOME/.oh-my-zsh" ]]; then
        # Clonar Oh My Zsh
        git clone https://github.com/ohmyzsh/ohmyzsh.git "$ROOT_HOME/.oh-my-zsh" &>/dev/null || {
            error "No se pudo clonar Oh My Zsh"
            return 1
        }
        success "Oh My Zsh instalado para root"
    else
        success "Oh My Zsh ya está instalado para root"
    fi
    
    # Instalar Powerlevel10k theme
    if [[ ! -d "$ROOT_HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ROOT_HOME/.oh-my-zsh/custom/themes/powerlevel10k" &>/dev/null || {
            error "No se pudo instalar Powerlevel10k"
            return 1
        }
        success "Powerlevel10k instalado para root"
    else
        success "Powerlevel10k ya está instalado para root"
    fi
}

# Configurar plugins de Zsh
setup_zsh_plugins() {
    log "Configurando plugins de Zsh para root..."
    
    # zsh-autosuggestions
    if [[ ! -d "$ROOT_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ROOT_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" &>/dev/null || {
            warn "No se pudo instalar zsh-autosuggestions"
        }
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$ROOT_HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ROOT_HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" &>/dev/null || {
            warn "No se pudo instalar zsh-syntax-highlighting"
        }
    fi
    
    success "Plugins de Zsh configurados para root"
}

# Configurar variables de entorno específicas para root
setup_root_environment() {
    log "Configurando variables de entorno para root..."
    
    # Crear archivo de variables de entorno
    cat > "$ROOT_HOME/.root_env" << 'EOF'
# Root Environment Variables
export ROOT_MODE=1
export FASTFETCH_DISABLE_AUTO=1
export NEOFETCH_DISABLE_AUTO=1
export P10K_THEME_MODE=dark

# Disable any auto-launch tools in root mode
export DISABLE_AUTO_LAUNCH=1

# Root-specific aliases
alias fastfetch='echo "🔴 Fastfetch disabled in root mode"'
alias neofetch='echo "🔴 Neofetch disabled in root mode"'
EOF
    
    success "Variables de entorno para root configuradas"
}

# Configurar permisos
setup_permissions() {
    log "Configurando permisos..."
    
    # Cambiar propietario de todos los archivos de root
    chown -R root:root "$ROOT_HOME/.zshrc" "$ROOT_HOME/.p10k.zsh" "$ROOT_HOME/.bashrc" 2>/dev/null || true
    chown -R root:root "$ROOT_HOME/.oh-my-zsh" 2>/dev/null || true
    chown -R root:root "$ROOT_HOME/.config" 2>/dev/null || true
    
    success "Permisos configurados"
}

# Función principal
main() {
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}🔴 CONFIGURACIÓN DE ENTORNO ROOT${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    
    setup_root_configs
    setup_oh_my_zsh
    setup_zsh_plugins
    setup_root_environment
    setup_permissions
    
    echo
    echo -e "${GREEN}✅ Configuración de root completada${NC}"
    echo -e "${YELLOW}💡 Para aplicar los cambios, ejecuta:${NC}"
    echo -e "   source ~/.zshrc"
    echo -e "   o reinicia la sesión de root"
}

# Ejecutar función principal
main "$@" 