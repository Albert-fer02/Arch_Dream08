#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM MACHINE - MÓDULO NEOVIM
# =====================================================
# Script de instalación del módulo Neovim
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# =====================================================
# 🔧 CONFIGURACIÓN DEL MÓDULO
# =====================================================

MODULE_NAME="Neovim"
MODULE_DESCRIPTION="Editor avanzado con configuración"
MODULE_DEPENDENCIES=("neovim")
MODULE_FILES=()

# =====================================================
# 🔧 FUNCIONES DEL MÓDULO
# =====================================================

# Instalar dependencias del módulo
install_module_dependencies() {
    log "Instalando dependencias del módulo $MODULE_NAME..."
    
    # Instalar Neovim
    install_package "neovim"
    
    # Instalar herramientas adicionales opcionales
    local optional_packages=("ripgrep" "fd" "bat" "tree-sitter" "nodejs" "npm")
    for pkg in "${optional_packages[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            if confirm "¿Instalar $pkg (opcional para Neovim)?"; then
                install_package "$pkg"
            fi
        fi
    done
}

# Configurar Neovim
configure_neovim() {
    log "Configurando Neovim..."
    
    # Crear directorio de configuración
    mkdir -p "$HOME/.config/nvim"
    
    # Crear configuración básica si no existe
    if [[ ! -f "$HOME/.config/nvim/init.lua" ]]; then
        cat > "$HOME/.config/nvim/init.lua" << 'EOF'
-- Configuración básica de Neovim
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

-- Configuración de colores
vim.opt.termguicolors = true
vim.cmd('colorscheme default')

-- Configuración de archivos
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Configuración de búsqueda
vim.opt.incsearch = true
vim.opt.showmatch = true
vim.opt.matchtime = 2

-- Configuración de interfaz
vim.opt.showmode = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.ruler = true
vim.opt.visualbell = true
vim.opt.errorbells = false

-- Configuración de archivos
vim.opt.hidden = true
vim.opt.history = 1000
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 240
vim.opt.updatetime = 250

-- Mapeos básicos
vim.keymap.set('n', '<leader>w', ':w<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>Q', ':q!<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>e', ':Explore<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>', { noremap = true, silent = true })

-- Configuración de plugins (básica)
vim.cmd('packadd packer.nvim')

-- Configuración de autocompletado
vim.opt.completeopt = 'menu,menuone,noselect'
EOF
        success "✓ Configuración básica de Neovim creada"
    else
        success "✓ Configuración de Neovim ya existe"
    fi
    
    # Crear alias para vim
    if [[ ! -f "$HOME/.bashrc" ]] || ! grep -q "alias vim=" "$HOME/.bashrc"; then
        echo 'alias vim="nvim"' >> "$HOME/.bashrc"
        success "✓ Alias vim=nvim agregado"
    fi
}

# Configurar archivos del módulo
configure_module_files() {
    log "Configurando archivos del módulo $MODULE_NAME..."
    
    # Crear directorios adicionales
    mkdir -p "$HOME/.local/share/nvim/site/autoload"
    mkdir -p "$HOME/.local/share/nvim/site/plugin"
    
    # Crear archivo de configuración de packer si no existe
    if [[ ! -f "$HOME/.config/nvim/lua/plugins.lua" ]]; then
        mkdir -p "$HOME/.config/nvim/lua"
        cat > "$HOME/.config/nvim/lua/plugins.lua" << 'EOF'
-- Configuración de plugins con Packer
return require('packer').startup(function(use)
  -- Packer puede gestionarse a sí mismo
  use 'wbthomason/packer.nvim'
  
  -- Temas
  use 'catppuccin/nvim'
  
  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  
  -- Treesitter
  use 'nvim-treesitter/nvim-treesitter'
  
  -- Telescope
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  
  -- Git
  use 'lewis6991/gitsigns.nvim'
  
  -- Comentarios
  use 'numToStr/Comment.nvim'
  
  -- Autopairs
  use 'windwp/nvim-autopairs'
  
  -- Lualine
  use 'nvim-lualine/lualine.nvim'
end)
EOF
        success "✓ Configuración de plugins creada"
    fi
}

# Verificar instalación del módulo
verify_module_installation() {
    log "Verificando instalación del módulo $MODULE_NAME..."
    
    local checks_passed=0
    local total_checks=3
    
    # Verificar Neovim instalado
    if command -v nvim &>/dev/null; then
        success "✓ Neovim instalado"
        ((checks_passed++))
    else
        error "✗ Neovim no está instalado"
    fi
    
    # Verificar directorio de configuración
    if [[ -d "$HOME/.config/nvim" ]]; then
        success "✓ Directorio de configuración creado"
        ((checks_passed++))
    else
        error "✗ Directorio de configuración no creado"
    fi
    
    # Verificar archivo de configuración
    if [[ -f "$HOME/.config/nvim/init.lua" ]]; then
        success "✓ Archivo de configuración presente"
        ((checks_passed++))
    else
        error "✗ Archivo de configuración no encontrado"
    fi
    
    if [[ $checks_passed -eq $total_checks ]]; then
        success "Módulo $MODULE_NAME instalado correctamente ($checks_passed/$total_checks)"
        return 0
    else
        warn "Módulo $MODULE_NAME instalado parcialmente ($checks_passed/$total_checks)"
        return 1
    fi
}

# =====================================================
# 🏁 FUNCIÓN PRINCIPAL
# =====================================================

main() {
    # Inicializar biblioteca
    init_library
    
    # Banner
    echo -e "${BOLD}${CYAN}🧩 INSTALANDO MÓDULO: $MODULE_NAME${COLOR_RESET}"
    echo -e "${CYAN}$MODULE_DESCRIPTION${COLOR_RESET}\n"
    
    # Instalar dependencias
    install_module_dependencies
    
    # Configurar Neovim
    configure_neovim
    
    # Configurar archivos
    configure_module_files
    
    # Verificar instalación
    verify_module_installation
    
    echo -e "\n${BOLD}${GREEN}✅ Módulo $MODULE_NAME instalado exitosamente${COLOR_RESET}"
    echo -e "${YELLOW}💡 Para probar Neovim: nvim archivo.txt${COLOR_RESET}"
}

# Ejecutar función principal
main "$@" 