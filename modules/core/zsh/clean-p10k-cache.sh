#!/bin/bash
# Clean p10k cache script
# ---------------------------------------------------------------------
# ╔═════════════════════════════════════════════════════════════
# ║                     𓂀 DreamCoder 08 𓂀                     ║
# ║                ⚡ Digital Dream Architect ⚡                 ║
# ║                                                            ║
# ║        Author: https://github.com/Albert-fer02             ║
# ╚══════════════════════════════════════════════════════════════╝
# ---------------------------------------------------------------------

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Functions
log() { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo -e "${CYAN}🧹 Limpiando cache de p10k...${NC}"

# Clean p10k cache for current user
if [[ -d "$HOME/.cache" ]]; then
    rm -rf "$HOME/.cache/p10k-"* 2>/dev/null || true
    success "Cache de p10k limpiado para usuario actual"
fi

# Clean zsh completion cache
if [[ -d "$HOME/.zsh" ]]; then
    rm -f "$HOME/.zsh/compdump"* 2>/dev/null || true
    success "Cache de completions limpiado"
fi

# Clean root cache if running as root
if [[ $EUID -eq 0 ]]; then
    rm -rf "/root/.cache/p10k-"* 2>/dev/null || true
    rm -f "/root/.zsh/compdump"* 2>/dev/null || true
    success "Cache de p10k limpiado para root"
fi

# Clean root cache if script is run with sudo
if [[ -n "${SUDO_USER:-}" ]]; then
    rm -rf "/root/.cache/p10k-"* 2>/dev/null || true
    rm -f "/root/.zsh/compdump"* 2>/dev/null || true
    success "Cache de p10k limpiado para root (via sudo)"
fi

echo
echo -e "${GREEN}✅ Limpieza completada${NC}"
echo -e "${YELLOW}💡 Para aplicar los cambios:${NC}"
echo -e "   source ~/.zshrc"
echo -e "   o reinicia la terminal" 