#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM MACHINE - MÓDULO NEOVIM
# =====================================================
# Script de instalación del módulo Neovim (LazyVim + plugins)
# Versión 1.0 - Instalación idempotente y robusta
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
MODULE_DESCRIPTION="Editor avanzado con configuración personalizada (LazyVim + plugins AI)"
MODULE_DEPENDENCIES=("neovim" "git" "curl" "ripgrep")
MODULE_FILES=("init.lua" "lua" "lazyvim.json" "stylua.toml")
NVIM_CONFIG_DIR="$HOME/.config/nvim"

# =====================================================
# 🔧 FUNCIONES DEL MÓDULO
# =====================================================

install_module_dependencies() {
  log "Instalando dependencias del módulo $MODULE_NAME..."
  local deps_to_install=()
  for dep in "${MODULE_DEPENDENCIES[@]}"; do
    if command -v "$dep" &>/dev/null; then
      success "✓ $dep ya está instalado"
    else
      deps_to_install+=("$dep")
    fi
  done

  if [[ ${#deps_to_install[@]} -gt 0 ]]; then
    log "Instalando dependencias faltantes: ${deps_to_install[*]}"
    for dep in "${deps_to_install[@]}"; do
      install_package "$dep"
    done
  fi
  success "✅ Todas las dependencias están instaladas"
}

# Configurar directorios de Neovim
setup_nvim_directories() {
    log "Configurando directorios de Neovim..."
    
    # Usar la función mejorada para crear directorios de configuración
    create_config_directory "$NVIM_CONFIG_DIR" "directorio principal de Neovim"
    
    # Crear directorios adicionales si es necesario
    mkdir -p "$NVIM_CONFIG_DIR/lua" "$NVIM_CONFIG_DIR/spell"
    
    # Establecer permisos correctos
    chmod 755 "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_DIR/lua" "$NVIM_CONFIG_DIR/spell"
    
    success "✅ Directorios de Neovim configurados"
}

configure_module_files() {
  log "Configurando archivos del módulo $MODULE_NAME..."

  # Enlazar configuración completa
  create_symlink "$SCRIPT_DIR/init.lua" "$NVIM_CONFIG_DIR/init.lua" "nvim init.lua"

  # Enlazar árbol lua completo
  create_symlink "$SCRIPT_DIR/lua" "$NVIM_CONFIG_DIR/lua" "nvim lua config"

  # Extras opcionales
  if [[ -f "$SCRIPT_DIR/lazyvim.json" ]]; then
    create_symlink "$SCRIPT_DIR/lazyvim.json" "$NVIM_CONFIG_DIR/lazyvim.json" "nvim lazyvim.json"
  fi
  if [[ -f "$SCRIPT_DIR/stylua.toml" ]]; then
    create_symlink "$SCRIPT_DIR/stylua.toml" "$NVIM_CONFIG_DIR/stylua.toml" "nvim stylua.toml"
  fi

  # Spell files (si existen)
  if [[ -d "$SCRIPT_DIR/spell" ]]; then
    create_symlink "$SCRIPT_DIR/spell" "$NVIM_CONFIG_DIR/spell" "nvim spell"
  fi

  success "✅ Archivos del módulo configurados"
}

post_installation_setup_nvim() {
  log "Realizando bootstrap de Lazy.nvim y validación mínima..."

  # Crear wrapper para ejecutar nvim de forma no interactiva si es posible
  if command -v nvim &>/dev/null; then
    # Intentar instalar plugins en modo headless
    if nvim --headless "+Lazy! sync" +qa &>/dev/null; then
      success "✅ Plugins sincronizados con Lazy.nvim (headless)"
    else
      warn "⚠️  No se pudo sincronizar Lazy.nvim en headless (esto puede ser normal en primera ejecución)."
    fi

    # Instalar servidores con Mason para evitar prompts por faltantes
    if nvim --headless "+MasonInstall angular-language-server astro-language-server typescript-language-server eslint-lsp css-lsp json-lsp lua-language-server tailwindcss-language-server" +qa &>/dev/null; then
      success "✅ Mason: servidores base instalados (Angular, Astro, TS, ESLint, CSS, JSON, Lua, Tailwind)"
    else
      warn "⚠️  Mason no pudo instalar algunos servidores en headless (puede requerir reintento manual con :Mason)."
    fi
  else
    error "nvim no está en PATH tras la instalación. Verifica el paquete 'neovim'."
  fi
}

verify_module_installation() {
  log "Verificando instalación del módulo $MODULE_NAME..."
  local checks_passed=0
  local total_checks=4

  if command -v nvim &>/dev/null; then
    success "✓ Neovim instalado"
    ((++checks_passed))
  else
    error "✗ Neovim no está instalado"
  fi

  if [[ -f "$NVIM_CONFIG_DIR/init.lua" ]]; then
    success "✓ init.lua enlazado"
    ((++checks_passed))
  else
    error "✗ init.lua no está enlazado"
  fi

  if [[ -d "$NVIM_CONFIG_DIR/lua" ]]; then
    success "✓ Árbol lua enlazado"
    ((++checks_passed))
  else
    error "✗ Árbol lua no enlazado"
  fi

  if nvim --version &>/dev/null; then
    success "✓ Neovim ejecutable"
    ((++checks_passed))
  else
    error "✗ Neovim no ejecuta correctamente"
  fi

  if [[ $checks_passed -eq $total_checks ]]; then
    success "Módulo $MODULE_NAME instalado correctamente ($checks_passed/$total_checks)"
    return 0
  else
    warn "Módulo $MODULE_NAME instalado parcialmente ($checks_passed/$total_checks)"
    return 1
  fi
}

main() {
  # Inicializar biblioteca
  init_library

  echo -e "${BOLD}${CYAN}🧩 INSTALANDO MÓDULO: $MODULE_NAME${COLOR_RESET}"
  echo -e "${CYAN}$MODULE_DESCRIPTION${COLOR_RESET}\n"

  install_module_dependencies
  setup_nvim_directories
  configure_module_files
  post_installation_setup_nvim || true
  verify_module_installation

  echo -e "\n${BOLD}${GREEN}✅ Módulo $MODULE_NAME instalado exitosamente${COLOR_RESET}"
  echo -e "${YELLOW}💡 Para usar Neovim: nvim${COLOR_RESET}"
}

main "$@"


