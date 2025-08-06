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
# ⚡ ARCH DREAM ULTRA FAST INSTALLER
# =====================================================
# Script ultra optimizado para instalación rápida
# de herramientas de productividad en Arch Linux
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

# Banner
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                ⚡ ULTRA FAST INSTALLER ⚡                   ║"
echo "║              Productividad Máxima en 2 minutos             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar sistema
if [[ ! -f /etc/arch-release ]]; then
    error "Este script requiere Arch Linux"
    exit 1
fi

# Verificar permisos
if ! sudo -n true 2>/dev/null; then
    error "Se requieren permisos sudo"
    exit 1
fi

# Variables de configuración
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# =====================================================
# 🚀 INSTALACIÓN ULTRA RÁPIDA
# =====================================================

echo -e "${PURPLE}🚀 Iniciando instalación ultra rápida...${NC}\n"

# Función para instalar paquete rápidamente
install_fast() {
    local package="$1"
    local description="$2"
    
    if pacman -Q "$package" &>/dev/null; then
        success "$description ya instalado"
        return 0
    fi
    
    log "Instalando $description..."
    if sudo pacman -S --noconfirm --needed "$package" &>/dev/null; then
        success "$description instalado"
    else
        warn "No se pudo instalar $description, continuando..."
        return 1
    fi
}

# Función para instalar AUR rápidamente
install_aur_fast() {
    local package="$1"
    local description="$2"
    
    if pacman -Q "$package" &>/dev/null; then
        success "$description ya instalado"
        return 0
    fi
    
    local aur_helper=""
    if command -v yay &>/dev/null; then
        aur_helper="yay"
    elif command -v paru &>/dev/null; then
        aur_helper="paru"
    else
        warn "AUR helper no detectado, saltando $description"
        return 1
    fi
    
    log "Instalando $description desde AUR..."
    if "$aur_helper" -S --noconfirm --needed "$package" &>/dev/null; then
        success "$description instalado"
    else
        warn "No se pudo instalar $description, continuando..."
        return 1
    fi
}

# Función para crear symlink rápido
link_fast() {
    local source="$1"
    local target="$2"
    local description="$3"
    
    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
    fi
    
    ln -sf "$source" "$target" &>/dev/null
    success "$description enlazado"
}

# =====================================================
# 📦 INSTALACIÓN DE PAQUETES PRINCIPALES
# =====================================================

echo -e "${BLUE}📦 Instalando paquetes principales...${NC}"

# Shell y terminal
install_fast "zsh" "Zsh"
install_fast "kitty" "Kitty Terminal"
install_fast "ttf-meslo-nerd-font-powerlevel10k" "Fuentes Nerd"

# Herramientas modernas
install_fast "eza" "Eza (ls moderno)"
install_fast "bat" "Bat (cat moderno)"
install_fast "ripgrep" "Ripgrep (grep moderno)"
install_fast "fd" "Fd (find moderno)"
install_fast "fzf" "FZF (fuzzy finder)"
install_fast "btop" "Btop (top moderno)"
install_fast "duf" "Duf (df moderno)"
install_fast "dust" "Dust (du moderno)"
install_fast "delta" "Delta (diff moderno)"
install_fast "xh" "Xh (curl moderno)"
install_fast "procs" "Procs (ps moderno)"

# Editores
install_fast "neovim" "Neovim"
install_fast "nano" "Nano"

# Desarrollo
install_fast "git" "Git"
install_fast "jq" "JQ"

# AUR packages
install_aur_fast "fastfetch" "Fastfetch"

echo

# =====================================================
# ⚡ INSTALACIÓN DE OH MY ZSH Y POWERLEVEL10K
# =====================================================

echo -e "${BLUE}⚡ Configurando Zsh...${NC}"

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &>/dev/null
    success "Oh My Zsh instalado"
else
    success "Oh My Zsh ya instalado"
fi

# Powerlevel10k
local theme_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$theme_dir" ]]; then
    log "Instalando Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir" &>/dev/null
    success "Powerlevel10k instalado"
else
    success "Powerlevel10k ya instalado"
fi

echo

# =====================================================
# 🔧 CONFIGURACIÓN RÁPIDA
# =====================================================

echo -e "${BLUE}🔧 Configurando archivos...${NC}"

# Crear directorios
mkdir -p "$HOME/.config" "$HOME/.local/bin"

# Configurar Zsh
link_fast "$SCRIPT_DIR/modules/core/zsh/zshrc" "$HOME/.zshrc" "Zsh config"
link_fast "$SCRIPT_DIR/modules/core/zsh/p10k.zsh" "$HOME/.p10k.zsh" "Powerlevel10k config"

# Configurar Bash
link_fast "$SCRIPT_DIR/modules/core/bash/bashrc" "$HOME/.bashrc" "Bash config"

# Configurar Kitty
link_fast "$SCRIPT_DIR/modules/terminal/kitty" "$HOME/.config/kitty" "Kitty config"

# Configurar Fastfetch
link_fast "$SCRIPT_DIR/modules/tools/fastfetch" "$HOME/.config/fastfetch" "Fastfetch config"

# Configurar Nano
link_fast "$SCRIPT_DIR/modules/tools/nano/nanorc.conf" "$HOME/.nanorc" "Nano config"

echo

# =====================================================
# 🔴 CONFIGURACIÓN DE SUPERUSUARIO (ROOT)
# =====================================================

echo -e "${BLUE}🔴 Configurando superusuario...${NC}"

# Función para instalar configuración de root
install_root_config() {
    local ROOT_HOME="/root"
    local ROOT_CONFIG_DIR="$ROOT_HOME/.config"
    local ROOT_ZSH_DIR="$ROOT_HOME/.zsh"
    
    # Archivos de configuración de root
    local BASH_CONFIG_SOURCE="$SCRIPT_DIR/modules/core/bash/bashrc.root"
    local BASH_CONFIG_TARGET="$ROOT_HOME/.bashrc"
    local ZSH_CONFIG_SOURCE="$SCRIPT_DIR/modules/core/zsh/zshrc.root"
    local ZSH_CONFIG_TARGET="$ROOT_HOME/.zshrc"
    local P10K_CONFIG_SOURCE="$SCRIPT_DIR/modules/core/zsh/p10k.root.zsh"
    local P10K_CONFIG_TARGET="$ROOT_HOME/.p10k.zsh"
    
    # Crear directorios necesarios
    sudo mkdir -p "$ROOT_CONFIG_DIR" "$ROOT_ZSH_DIR" 2>/dev/null || true
    
    # Instalar configuración de Bash para root
    if [[ -f "$BASH_CONFIG_SOURCE" ]]; then
        sudo cp "$BASH_CONFIG_SOURCE" "$BASH_CONFIG_TARGET" 2>/dev/null
        sudo chmod 644 "$BASH_CONFIG_TARGET" 2>/dev/null
        success "Configuración de Bash para root instalada"
    else
        warn "Archivo de configuración de Bash para root no encontrado"
    fi
    
    # Instalar configuración de Zsh para root
    if [[ -f "$ZSH_CONFIG_SOURCE" ]]; then
        sudo cp "$ZSH_CONFIG_SOURCE" "$ZSH_CONFIG_TARGET" 2>/dev/null
        sudo chmod 644 "$ZSH_CONFIG_TARGET" 2>/dev/null
        success "Configuración de Zsh para root instalada"
    else
        warn "Archivo de configuración de Zsh para root no encontrado"
    fi
    
    # Instalar configuración de Powerlevel10k para root
    if [[ -f "$P10K_CONFIG_SOURCE" ]]; then
        sudo cp "$P10K_CONFIG_SOURCE" "$P10K_CONFIG_TARGET" 2>/dev/null
        sudo chmod 644 "$P10K_CONFIG_TARGET" 2>/dev/null
        success "Configuración de Powerlevel10k para root instalada"
    else
        warn "Archivo de configuración de Powerlevel10k para root no encontrado"
    fi
}

# Instalar configuración de root
if install_root_config; then
    success "Configuración de superusuario completada"
else
    warn "Algunos archivos de configuración de root no se pudieron instalar"
fi

echo

# =====================================================
# ⚙️ CONFIGURACIÓN DE GIT
# =====================================================

echo -e "${BLUE}⚙️ Configurando Git...${NC}"

# Configuraciones básicas de Git
git config --global init.defaultBranch main &>/dev/null
git config --global pull.rebase false &>/dev/null
git config --global core.editor "nano" &>/dev/null

# Solo configurar usuario si no está configurado
if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
    log "Configurando usuario de Git..."
    echo "Configura manualmente tu usuario de Git con:"
    echo "git config --global user.name 'Tu Nombre'"
    echo "git config --global user.email 'tu@email.com'"
else
    success "Git ya configurado"
fi

echo

# =====================================================
# 🎯 CONFIGURACIÓN DE NEOVIM
# =====================================================

echo -e "${BLUE}🎯 Configurando Neovim...${NC}"

mkdir -p "$HOME/.config/nvim"

if [[ ! -f "$HOME/.config/nvim/init.lua" ]]; then
    cat > "$HOME/.config/nvim/init.lua" << 'EOF'
-- Configuración ultra optimizada de Neovim
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.copyindent = true
vim.opt.preserveindent = true
vim.opt.softtabstop = 0
vim.opt.noexpandtab = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.clipboard = 'unnamedplus'
vim.opt.termguicolors = true
vim.cmd('colorscheme default')
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.incsearch = true
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.opt.showmode = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.ruler = true
vim.opt.visualbell = true
vim.opt.errorbells = false
vim.opt.hidden = true
vim.opt.history = 1000
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 240
vim.opt.updatetime = 250
vim.opt.completeopt = 'menu,menuone,noselect'
EOF
    success "Configuración de Neovim creada"
else
    success "Configuración de Neovim ya existe"
fi

echo

# =====================================================
# 🚀 CONFIGURACIÓN DE VARIABLES DE ENTORNO
# =====================================================

echo -e "${BLUE}🚀 Configurando variables de entorno...${NC}"

# Agregar variables al .bashrc si no existen
if ! grep -q "EDITOR='nvim'" "$HOME/.bashrc" 2>/dev/null; then
    echo 'export EDITOR="nvim"' >> "$HOME/.bashrc"
fi

if ! grep -q "alias vim=" "$HOME/.bashrc" 2>/dev/null; then
    echo 'alias vim="nvim"' >> "$HOME/.bashrc"
fi

success "Variables de entorno configuradas"

echo

# =====================================================
# ✅ VERIFICACIÓN FINAL
# =====================================================

echo -e "${BLUE}✅ Verificando instalación...${NC}"

# Verificar herramientas principales
tools=("zsh" "kitty" "eza" "bat" "rg" "fd" "fzf" "btop" "nvim" "git" "fastfetch")
all_installed=true

for tool in "${tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
        success "$tool ✓"
    else
        error "$tool ✗"
        all_installed=false
    fi
done

echo

# =====================================================
# 🎉 FINALIZACIÓN
# =====================================================

if [[ "$all_installed" == true ]]; then
    echo -e "${GREEN}🎉 ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!${NC}"
    echo
    echo -e "${CYAN}📋 Resumen:${NC}"
    echo -e "  • ${GREEN}Shell optimizado${NC}: Zsh + Oh My Zsh + Powerlevel10k"
    echo -e "  • ${GREEN}Terminal moderna${NC}: Kitty con aceleración GPU"
    echo -e "  • ${GREEN}Herramientas modernas${NC}: eza, bat, ripgrep, fd, fzf"
    echo -e "  • ${GREEN}Monitoreo${NC}: btop, duf, dust, fastfetch"
    echo -e "  • ${GREEN}Editores${NC}: Neovim, Nano"
    echo -e "  • ${GREEN}Desarrollo${NC}: Git configurado"
    echo -e "  • ${GREEN}Superusuario${NC}: Configuración con Powerlevel10k (sin fastfetch)"
    echo
    echo -e "${YELLOW}💡 Próximos pasos:${NC}"
    echo -e "  1. Reinicia tu terminal o ejecuta: source ~/.bashrc"
    echo -e "  2. Ejecuta: zsh para cambiar a Zsh"
    echo -e "  3. Configura tu usuario de Git si es necesario"
    echo -e "  4. Prueba la configuración de root: sudo su"
    echo -e "  5. ¡Disfruta de tu entorno ultra productivo!"
    echo
    echo -e "${PURPLE}🚀 Tu sistema está listo para máxima productividad${NC}"
else
    echo -e "${YELLOW}⚠️  Instalación completada con algunos problemas${NC}"
    echo -e "${CYAN}💡 Revisa los errores arriba y instala manualmente si es necesario${NC}"
fi

echo
echo -e "${CYAN}⏱️  Tiempo total: ~$(($SECONDS / 60)) minutos${NC}"

# Limpiar backup si está vacío
if [[ -d "$BACKUP_DIR" ]] && [[ -z "$(ls -A "$BACKUP_DIR")" ]]; then
    rmdir "$BACKUP_DIR" 2>/dev/null || true
fi 