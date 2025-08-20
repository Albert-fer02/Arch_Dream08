#!/bin/bash
# =====================================================
# 🚀 ARCH DREAM - INSTALACIÓN DE UN SOLO COMANDO
# =====================================================
# Script de instalación ultra-simple para Arch Dream
# Uso: curl -sSL https://raw.githubusercontent.com/user/repo/main/one-liner-install.sh | bash
# =====================================================

set -euo pipefail

# Colores para output
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# Función de logging simple
log() { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Banner
echo -e "${BOLD}${CYAN}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                 🚀 ARCH DREAM MACHINE                    ║
║              Instalación de un solo comando              ║
║              Ultra-optimizado para Arch Linux            ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Verificar Arch Linux
[[ -f /etc/arch-release ]] || {
    error "❌ Este instalador requiere Arch Linux"
    exit 1
}

# Verificar herramientas esenciales
for tool in git sudo pacman curl; do
    command -v "$tool" &>/dev/null || {
        error "❌ Herramienta faltante: $tool"
        log "💡 Instala con: sudo pacman -S $tool"
        exit 1
    }
done

# Verificar conexión a internet
ping -c 1 -W 3 archlinux.org &>/dev/null || {
    warn "⚠️  Sin conexión a internet - la instalación puede fallar"
}

# Verificar permisos sudo
log "🔐 Verificando permisos sudo..."
sudo -v || {
    error "❌ Se requieren permisos sudo"
    exit 1
}

# Directorio de instalación
INSTALL_DIR="$HOME/arch-dream"
log "📁 Instalando en: $INSTALL_DIR"

# Crear directorio de instalación
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Clonar repositorio
log "📥 Clonando repositorio Arch Dream..."
if [[ -d ".git" ]]; then
    log "🔄 Actualizando repositorio existente..."
    git pull origin main || git pull origin master || {
        warn "⚠️  No se pudo actualizar, continuando con instalación..."
    }
else
    git clone --depth=1 "https://github.com/Albert-fer02/Arch_Dream08.git" . || {
        error "❌ Fallo al clonar repositorio"
        exit 1
    }
fi

# Hacer ejecutable el script principal
chmod +x install.sh

# Mostrar opciones de instalación
echo
echo -e "${YELLOW}📋 Opciones de instalación:${NC}"
echo -e "  1) ${BOLD}Instalación completa${NC} - Todos los módulos"
echo -e "  2) ${BOLD}Instalación personalizada${NC} - Seleccionar módulos"
echo -e "  3) ${BOLD}Modo simulación${NC} - Ver qué se instalaría"
echo -e "  4) ${BOLD}Instalación silenciosa${NC} - Sin preguntas"
echo

# Función para obtener selección del usuario
get_installation_choice() {
    local choice
    read -p "Selecciona una opción (1-4) [1]: " choice
    choice=${choice:-1}
    
    case "$choice" in
        1) echo "--all" ;;
        2) echo "" ;;
        3) echo "--dry-run --all" ;;
        4) echo "--all --force" ;;
        *) echo "--all" ;;
    esac
}

# Obtener opciones de instalación
INSTALL_OPTS=$(get_installation_choice)

# Ejecutar instalación
log "🚀 Iniciando instalación..."
if ./install.sh $INSTALL_OPTS; then
    echo
    echo -e "${BOLD}${GREEN}🎉 ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!${NC}"
    echo
    echo -e "${YELLOW}🚀 Próximos pasos:${NC}"
    echo -e "  1. Reinicia tu terminal: ${CYAN}exec \$SHELL${NC}"
    echo -e "  2. Explora las nuevas funcionalidades"
    echo -e "  3. Personaliza tu configuración"
    echo
    echo -e "${CYAN}💡 Para más información:${NC}"
    echo -e "  - Documentación: ${BLUE}$INSTALL_DIR/README.md${NC}"
    echo -e "  - Módulos: ${BLUE}$INSTALL_DIR/modules/${NC}"
    echo -e "  - Script principal: ${BLUE}$INSTALL_DIR/install.sh${NC}"
    echo
    echo -e "${PURPLE}🌟 ¡Disfruta tu nueva Arch Dream Machine!${NC}"
else
    echo
    echo -e "${RED}❌ La instalación falló${NC}"
    echo -e "${CYAN}💡 Revisa los logs y ejecuta manualmente:${NC}"
    echo -e "  ${BLUE}cd $INSTALL_DIR && ./install.sh --help${NC}"
    exit 1
fi