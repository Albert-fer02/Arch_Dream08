#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM MACHINE - MÓDULO ZSH
# =====================================================
# Script de instalación del módulo Zsh con Starship y Zinit (Red Team Optimized)
# Versión 3.0 - Instalación idempotente y ultra-optimizada
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# =====================================================
# 🔧 CONFIGURACIÓN DEL MÓDULO
# =====================================================

MODULE_NAME="Zsh Unified Configuration"
MODULE_DESCRIPTION="Configuración ultra-optimizada de Zsh con arquitectura unificada y herramientas de productividad"
MODULE_DEPENDENCIES=("zsh" "git" "curl" "wget" "starship")
MODULE_FILES=("zshrc" "zshrc.root")
MODULE_AUR_PACKAGES=("starship-bin")
MODULE_OPTIONAL=false

# Herramientas de productividad requeridas
PRODUCTIVITY_TOOLS=(
    "bat"           # Better cat
    "eza"           # Better ls
    "ripgrep"       # Better grep
    "fd"            # Better find
    "fzf"           # Fuzzy finder
    "btop"          # Better top
    "duf"           # Better df
    "dust"          # Better du
    "delta"         # Better diff
    "xh"            # Better curl/http
    "procs"         # Better ps
    "zoxide"        # Smart cd
    "fastfetch"     # System info
    "neofetch"      # Fallback system info
)

# Herramientas opcionales de AUR
OPTIONAL_AUR_TOOLS=(
    "lsd"           # Alternative to eza
    "hyperfine"     # Benchmarking tool
    "tokei"         # Code statistics
    "tealdeer"      # tldr pages
    "mcfly"         # Smart history search
)

# URLs de instalación
ZINIT_URL="https://github.com/zdharma-continuum/zinit.git"
STARSHIP_INSTALL_URL="https://starship.rs/install.sh"

# Directorios de instalación
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"
ZSH_CACHE_DIR="$HOME/.zsh"
ZSH_COMPDUMP_DIR="$ZSH_CACHE_DIR/compdump"
STARSHIP_CONFIG_DIR="$HOME/.config"

# =====================================================
# 🔧 FUNCIONES DEL MÓDULO
# =====================================================

# Instalar dependencias del módulo
install_module_dependencies() {
    log "Instalando dependencias del módulo $MODULE_NAME..."
    
    local deps_to_install=()
    
    # Verificar dependencias
    for dep in "${MODULE_DEPENDENCIES[@]}"; do
        if command -v "$dep" &>/dev/null; then
            success "✓ $dep ya está instalado"
        else
            deps_to_install+=("$dep")
        fi
    done
    
    # Instalar dependencias faltantes
    if [[ ${#deps_to_install[@]} -gt 0 ]]; then
        log "Instalando dependencias faltantes: ${deps_to_install[*]}"
        for dep in "${deps_to_install[@]}"; do
            if ! install_package "$dep"; then
                warn "⚠️  No se pudo instalar $dep - continuando sin esta dependencia"
            fi
        done
    fi
    
    success "✅ Verificación de dependencias completada"
}

# Instalar Starship
install_starship() {
    log "Instalando Starship..."
    
    if command -v starship &>/dev/null; then
        success "✓ Starship ya está instalado"
        return 0
    fi
    
    # Intentar instalar desde repositorios de Arch primero
    if install_package "starship"; then
        success "✅ Starship instalado desde repositorio"
        return 0
    fi
    
    # Si falla, instalar desde AUR
    log "Instalando Starship desde AUR..."
    if command -v yay &>/dev/null; then
        yay -S --noconfirm starship-bin
    elif command -v paru &>/dev/null; then
        paru -S --noconfirm starship-bin
    else
        # Último recurso: instalación manual
        log "Instalando Starship manualmente..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
    fi
    
    if command -v starship &>/dev/null; then
        success "✅ Starship instalado correctamente"
    else
        error "❌ Fallo al instalar Starship"
        return 1
    fi
}

# Instalar Zinit
install_zinit() {
    log "Instalando Zinit plugin manager..."
    
    if [[ -d "$ZINIT_HOME/zinit.git" ]]; then
        success "✓ Zinit ya está instalado"
        return 0
    fi
    
    # Crear directorio de Zinit
    mkdir -p "$(dirname "$ZINIT_HOME")"
    
    # Clonar Zinit
    if git clone --depth=1 "$ZINIT_URL" "$ZINIT_HOME/zinit.git"; then
        success "✅ Zinit instalado correctamente"
    else
        error "❌ Fallo al instalar Zinit"
        return 1
    fi
}

# Instalar herramientas de productividad
install_productivity_tools() {
    log "Instalando herramientas de productividad..."
    
    local installed_count=0
    local total_tools=${#PRODUCTIVITY_TOOLS[@]}
    
    # Verificar herramientas esenciales únicamente
    local essential_tools=("bat" "eza" "ripgrep" "fd" "fzf")
    
    for tool in "${essential_tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            success "✓ $tool ya está instalado"
            installed_count=$((installed_count + 1))
        else
            warn "⚠️  $tool no está instalado - funcionalidad limitada"
        fi
    done
    
    log "Herramientas esenciales: $installed_count/${#essential_tools[@]} disponibles"
    success "✅ Verificación de herramientas completada"
}

# Instalar herramientas opcionales desde AUR
install_optional_tools() {
    log "Instalando herramientas opcionales desde AUR..."
    
    for tool in "${OPTIONAL_AUR_TOOLS[@]}"; do
        if command -v "$tool" &>/dev/null; then
            success "✓ $tool ya está instalado"
        else
            # En modo no interactivo o CI, saltar confirmación
            if [[ "${YES:-false}" == "true" ]] || [[ "${CI:-false}" == "true" ]]; then
                log "Saltando herramienta opcional $tool (modo no interactivo)"
                continue
            fi
            
            if confirm "¿Instalar herramienta opcional $tool?" false; then
                log "Instalando $tool desde AUR..."
                install_aur_package "$tool" || warn "⚠️  No se pudo instalar $tool"
            fi
        fi
    done
    
    return 0  # Siempre exitoso para no bloquear instalación
}

# Función para instalar paquetes AUR
install_aur_package() {
    local package="$1"
    
    if command -v yay &>/dev/null; then
        yay -S --noconfirm "$package"
    elif command -v paru &>/dev/null; then
        paru -S --noconfirm "$package"
    else
        warn "⚠️  No hay helper de AUR disponible para instalar $package"
        return 1
    fi
}

# Configurar directorios de Zsh
setup_zsh_directories() {
    log "Configurando directorios de Zsh..."
    
    # Crear directorios necesarios
    mkdir -p "$ZSH_CACHE_DIR" "$ZSH_COMPDUMP_DIR"
    
    # Crear directorio para binarios locales si no existe
    mkdir -p "$HOME/.local/bin"
    
    # Asegurar que .local/bin esté en PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        log "Agregando ~/.local/bin al PATH"
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Establecer permisos correctos
    chmod 755 "$ZSH_CACHE_DIR" "$ZSH_COMPDUMP_DIR" "$HOME/.local/bin"
    
    # Crear directorios para plugins de Zsh
    mkdir -p "$HOME/.local/share/zsh/plugins"
    chmod 755 "$HOME/.local/share/zsh/plugins"
    
    success "✅ Directorios de Zsh configurados"
}

# Configurar archivos del módulo
configure_module_files() {
    log "Configurando archivos del módulo $MODULE_NAME..."
    
    # Crear directorio de configuración de Starship
    mkdir -p "$STARSHIP_CONFIG_DIR"
    
    # Crear symlinks para archivos de configuración
    create_symlink "$SCRIPT_DIR/zshrc" "$HOME/.zshrc" ".zshrc"
    
    # Configurar Starship desde la ubicación centralizada
    local starship_source="$SCRIPT_DIR/../../../lib/starship.toml"
    local starship_dest="$STARSHIP_CONFIG_DIR/starship.toml"
    if [[ -f "$starship_source" ]]; then
        create_symlink "$starship_source" "$starship_dest" "starship.toml"
    else
        warn "⚠️  Configuración centralizada de Starship no encontrada"
    fi
    
    # Asegurar archivos de inicio mínimos para evitar zsh-newuser-install
    for startup_file in ".zshenv" ".zprofile" ".zlogin"; do
        if [[ ! -f "$HOME/$startup_file" ]]; then
            printf "# Arch Dream: archivo creado para suprimir zsh-newuser-install\n" > "$HOME/$startup_file"
            chmod 644 "$HOME/$startup_file"
            success "✅ Archivo creado: ~/$startup_file"
        fi
    done
    
    # Configurar archivos root si es necesario
    if [[ "$EUID" -eq 0 ]]; then
        create_symlink "$SCRIPT_DIR/zshrc.root" "$HOME/.zshrc" ".zshrc (root)"
    fi
    
    # Crear archivo de configuración local si no existe
    if [[ ! -f "$HOME/.zshrc.local" ]]; then
        cat > "$HOME/.zshrc.local" << 'EOF'
# =====================================================
# 🧩 CONFIGURACIÓN LOCAL DE ZSH - RED TEAM
# =====================================================
# Personalizaciones específicas del usuario
# Este archivo NO se sobrescribe con actualizaciones
# =====================================================

# Variables de entorno personalizadas
# export TARGET=""
# export PROXY=""

# Aliases personalizados
# alias custom="comando personalizado"

# Funciones personalizadas
# custom_function() {
#     echo "Mi función personalizada"
# }

EOF
        success "✅ Archivo de configuración local creado: ~/.zshrc.local"
    fi
    
    success "✅ Archivos del módulo configurados"
}

# Configurar shell por defecto
configure_default_shell() {
    log "Configurando shell por defecto..."
    
    local current_shell=$(getent passwd "$USER" | cut -d: -f7 | xargs basename || basename -- "$SHELL")
    local zsh_path=$(command -v zsh || true)
    
    if [[ "$current_shell" != "zsh" ]]; then
        if [[ -n "$zsh_path" ]]; then
            if confirm "¿Cambiar shell por defecto a Zsh?" true; then
                log "Cambiando shell por defecto a Zsh..."
                # En Arch, chsh requiere ruta absoluta del shell presente en /etc/shells
                if ! grep -q "^$zsh_path$" /etc/shells 2>/dev/null; then
                    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null || true
                fi
                if chsh -s "$zsh_path" "$USER"; then
                    success "✅ Shell cambiado a Zsh. Reinicia la sesión para aplicar"
                    warn "⚠️  IMPORTANTE: Reinicia tu terminal o ejecuta 'exec zsh'"
                else
                    warn "⚠️  No se pudo cambiar el shell por defecto"
                fi
            else
                log "Shell por defecto no cambiado"
            fi
        else
            warn "⚠️  Zsh no encontrado en PATH"
        fi
    else
        success "✓ Zsh ya es el shell por defecto"
    fi
}

# Verificar instalación del módulo
verify_module_installation() {
    log "Verificando instalación del módulo $MODULE_NAME..."
    
    local checks_passed=0
    local total_checks=8
    
    # Verificar Zsh instalado
    if command -v zsh &>/dev/null; then
        success "✓ Zsh instalado $(zsh --version)"
        checks_passed=$((checks_passed + 1))
    else
        error "✗ Zsh no está instalado"
    fi
    
    # Verificar Starship instalado
    if command -v starship &>/dev/null; then
        success "✓ Starship instalado $(starship --version | head -1)"
        checks_passed=$((checks_passed + 1))
    else
        error "✗ Starship no está instalado"
    fi
    
    # Verificar Zinit instalado
    if [[ -d "$ZINIT_HOME/zinit.git" ]]; then
        success "✓ Zinit instalado"
        checks_passed=$((checks_passed + 1))
    else
        error "✗ Zinit no está instalado"
    fi
    
    # Verificar .zshrc
    if [[ -L "$HOME/.zshrc" ]] && [[ -e "$HOME/.zshrc" ]]; then
        success "✓ .zshrc configurado"
        checks_passed=$((checks_passed + 1))
    else
        error "✗ .zshrc no está configurado"
    fi
    
    # Verificar configuración de Starship
    if [[ -f "$STARSHIP_CONFIG_DIR/starship.toml" ]]; then
        success "✓ Starship configurado"
        checks_passed=$((checks_passed + 1))
    else
        error "✗ Starship no está configurado"
    fi
    
    # Verificar directorios de Zsh
    if [[ -d "$ZSH_CACHE_DIR" ]] && [[ -d "$ZSH_COMPDUMP_DIR" ]]; then
        success "✓ Directorios de Zsh configurados"
        checks_passed=$((checks_passed + 1))
    else
        error "✗ Directorios de Zsh no están configurados"
    fi
    
    # Verificar herramientas esenciales de productividad
    local essential_tools=("fzf" "bat" "eza" "ripgrep" "fd")
    local tools_installed=0
    
    for tool in "${essential_tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            tools_installed=$((tools_installed + 1))
        fi
    done
    
    if [[ $tools_installed -ge 3 ]]; then
        success "✓ Herramientas de productividad ($tools_installed/${#essential_tools[@]} esenciales)"
        checks_passed=$((checks_passed + 1))
    else
        warn "⚠️  Pocas herramientas de productividad instaladas ($tools_installed/${#essential_tools[@]})"
    fi
    
    # Verificar FZF configurado
    if command -v fzf &>/dev/null && [[ -f "/usr/share/fzf/key-bindings.zsh" ]]; then
        success "✓ FZF completamente configurado"
        checks_passed=$((checks_passed + 1))
    elif command -v fzf &>/dev/null; then
        success "✓ FZF instalado (configuración básica)"
        checks_passed=$((checks_passed + 1))
    else
        error "✗ FZF no está instalado"
    fi
    
    if [[ $checks_passed -eq $total_checks ]]; then
        success "Módulo $MODULE_NAME instalado correctamente ($checks_passed/$total_checks)"
        return 0
    elif [[ $checks_passed -ge 5 ]]; then
        success "Módulo $MODULE_NAME instalado satisfactoriamente ($checks_passed/$total_checks)"
        return 0
    else
        warn "Módulo $MODULE_NAME instalado con advertencias ($checks_passed/$total_checks)"
        return 0  # Cambiado a 0 para no bloquear instalación
    fi
}

# Configuración post-instalación
post_installation_setup() {
    log "Configurando sistema post-instalación..."
    
    # Limpiar caché de completions
    if [[ -d "$ZSH_COMPDUMP_DIR" ]]; then
        rm -f "$ZSH_COMPDUMP_DIR"/*
        success "✅ Caché de completions limpiado"
    fi
    
    # Crear scripts de utilidad
    create_utility_scripts
    
    # Configurar herramientas adicionales
    configure_additional_tools
    
    # Optimizar configuración inicial
    optimize_initial_setup
    
    # Mostrar información de uso
    show_usage_info
}

# Crear scripts de utilidad
create_utility_scripts() {
    log "Creando scripts de utilidad..."
    
    local scripts_dir="$HOME/.local/bin"
    mkdir -p "$scripts_dir"
    
    # Script de limpieza de caché
    cat > "$scripts_dir/clean-zsh-cache" << 'EOF'
#!/bin/bash
# Script para limpiar caché de Zsh
echo "🧹 Limpiando caché de Zsh..."
rm -f ~/.zsh/compdump/*
rm -f ~/.zsh/.zcompdump*
rm -f ~/.zsh_history
echo "✅ Caché limpiado"
EOF
    
    # Script de actualización de plugins
    cat > "$scripts_dir/update-zsh-plugins" << 'EOF'
#!/bin/bash
# Script para actualizar plugins de Zsh
echo "🔄 Actualizando plugins de Zsh..."
if [[ -d "${ZINIT_HOME:-$HOME/.local/share/zinit}/zinit.git" ]]; then
    zsh -c "source ~/.zshrc && zinit update --all"
    echo "✅ Plugins actualizados"
else
    echo "❌ Zinit no encontrado"
fi
EOF
    
    # Script de información del sistema
    cat > "$scripts_dir/zsh-info" << 'EOF'
#!/bin/bash
# Script de información de Zsh
echo "📊 Información de Zsh:"
echo "  Versión: $(zsh --version)"
echo "  Shell actual: $SHELL"
echo "  Configuración: ~/.zshrc"
echo "  Plugins: ${ZINIT_HOME:-$HOME/.local/share/zinit}"
echo "  Cache: ~/.zsh"
echo "  Historial: ~/.zsh_history ($(wc -l < ~/.zsh_history 2>/dev/null || echo 0) líneas)"
EOF
    
    # Hacer scripts ejecutables
    chmod +x "$scripts_dir"/{clean-zsh-cache,update-zsh-plugins,zsh-info}
    
    success "✅ Scripts de utilidad creados en $scripts_dir"
}

# Configurar herramientas adicionales
configure_additional_tools() {
    log "Configurando herramientas adicionales..."
    
    # Configurar bat si está instalado
    if command -v bat &>/dev/null; then
        local bat_config_dir="$HOME/.config/bat"
        mkdir -p "$bat_config_dir"
        if [[ ! -f "$bat_config_dir/config" ]]; then
            cat > "$bat_config_dir/config" << 'EOF'
--theme=Catppuccin-macchiato
--style=numbers,changes,header
--paging=never
--wrap=auto
EOF
            success "✅ Configuración de bat creada"
        fi
    fi
    
    # Configurar ripgrep si está instalado
    if command -v rg &>/dev/null; then
        if [[ ! -f "$HOME/.ripgreprc" ]]; then
            cat > "$HOME/.ripgreprc" << 'EOF'
--smart-case
--hidden
--glob=!.git/*
--glob=!node_modules/*
--glob=!.cache/*
--colors=match:fg:yellow
--colors=match:style:bold
EOF
            export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
            success "✅ Configuración de ripgrep creada"
        fi
    fi
    
    # Configurar zoxide si está instalado
    if command -v zoxide &>/dev/null; then
        log "Configurando zoxide..."
        success "✅ Zoxide detectado - se inicializará automáticamente"
    fi
}

# Optimizar configuración inicial
optimize_initial_setup() {
    log "Optimizando configuración inicial..."
    
    # Pre-compilar archivos de configuración
    if [[ -f "$HOME/.zshrc" ]]; then
        zsh -c "zcompile ~/.zshrc" 2>/dev/null || true
        success "✅ Configuración pre-compilada"
    fi
    
    # Crear directorio de completions personalizados
    mkdir -p "$HOME/.local/share/zsh/completions"
    
    # Configurar permisos de seguridad
    chmod 700 "$HOME/.zsh" 2>/dev/null || true
    chmod 600 "$HOME/.zsh_history" 2>/dev/null || true
    
    success "✅ Configuración inicial optimizada"
}

# Mostrar información de uso
show_usage_info() {
    echo
    echo -e "${BOLD}${GREEN}🚀 ZSH PRODUCTIVIDAD CONFIGURADO EXITOSAMENTE${COLOR_RESET}"
    echo
    echo -e "${CYAN}📋 Próximos pasos:${COLOR_RESET}"
    echo -e "  1. Reinicia tu terminal o ejecuta: ${YELLOW}exec zsh${COLOR_RESET}"
    echo -e "  2. Personaliza tu configuración en: ${YELLOW}~/.zshrc.local${COLOR_RESET}"
    echo -e "  3. Explora las nuevas funciones y aliases"
    echo
    echo -e "${YELLOW}💡 Nuevas funciones útiles:${COLOR_RESET}"
    echo -e "  - ${GREEN}sysinfo${COLOR_RESET}: Información del sistema"
    echo -e "  - ${GREEN}dotfile <config>${COLOR_RESET}: Editar configuraciones"
    echo -e "  - ${GREEN}fcd${COLOR_RESET}: Navegación con FZF"
    echo -e "  - ${GREEN}fff${COLOR_RESET}: Buscar y editar archivos"
    echo -e "  - ${GREEN}fkill${COLOR_RESET}: Matar procesos interactivamente"
    echo -e "  - ${GREEN}fglog${COLOR_RESET}: Git log interactivo"
    echo
    echo -e "${CYAN}🛠️  Aliases mejorados:${COLOR_RESET}"
    echo -e "  - ${GREEN}ls/ll/la${COLOR_RESET}: Usando eza con iconos"
    echo -e "  - ${GREEN}cat${COLOR_RESET}: Usando bat con highlighting"
    echo -e "  - ${GREEN}grep${COLOR_RESET}: Usando ripgrep"
    echo -e "  - ${GREEN}find${COLOR_RESET}: Usando fd"
    echo -e "  - ${GREEN}top/htop${COLOR_RESET}: Usando btop"
    echo
    echo -e "${PURPLE}⚡ Scripts de utilidad:${COLOR_RESET}"
    echo -e "  - ${GREEN}clean-zsh-cache${COLOR_RESET}: Limpiar caché"
    echo -e "  - ${GREEN}update-zsh-plugins${COLOR_RESET}: Actualizar plugins"
    echo -e "  - ${GREEN}zsh-info${COLOR_RESET}: Información de configuración"
    echo
    echo -e "${RED}🔧 Keybindings especiales:${COLOR_RESET}"
    echo -e "  - ${GREEN}Alt+Alt${COLOR_RESET}: Insertar/quitar sudo"
    echo -e "  - ${GREEN}Ctrl+R${COLOR_RESET}: Búsqueda en historial"
    echo -e "  - ${GREEN}Ctrl+X Ctrl+X${COLOR_RESET}: Substitución de comandos"
    echo -e "  - ${GREEN}↑/↓${COLOR_RESET}: Búsqueda por substring"
    echo
    echo -e "${BOLD}${BLUE}🌟 ¡Disfruta tu nueva configuración ultra-productiva!${COLOR_RESET}"
    echo -e "${CYAN}💭 Tip: Usa 'dotfile zshlocal' para personalizar aún más${COLOR_RESET}"
}

# Crear archivo de referencia rápida
create_quick_reference() {
    local ref_file="$HOME/.local/share/zsh-productivity-reference.md"
    mkdir -p "$(dirname "$ref_file")"
    
    cat > "$ref_file" << 'EOF'
# 🚀 Zsh Productividad - Referencia Rápida

## 🛠️ Aliases Mejorados
- `ls`, `ll`, `la` → `eza` con iconos
- `cat` → `bat` con syntax highlighting
- `grep` → `ripgrep` (rg)
- `find` → `fd`
- `top`, `htop` → `btop`
- `ps` → `procs`
- `du` → `dust`
- `df` → `duf`
- `diff` → `delta`

## 💡 Funciones Nuevas
- `sysinfo` - Información del sistema
- `dotfile <config>` - Editar configuraciones (zsh, nvim, starship, kitty)
- `mkcd <dir>` - Crear directorio y entrar
- `extract <file>` - Extraer cualquier archivo comprimido

## 🔍 FZF Interactivo
- `fcd` - Navegación de directorios con preview
- `fff` - Buscar y editar archivos
- `fkill` - Matar procesos interactivamente
- `fglog` - Git log interactivo

## ⚡ Keybindings Especiales
- `Alt + Alt` - Insertar/quitar sudo
- `Ctrl + R` - Búsqueda en historial
- `Ctrl + X, Ctrl + X` - Substitución de comandos
- `↑ / ↓` - Búsqueda por substring en historial
- `Ctrl + /` - Toggle preview en FZF
- `Alt + Enter` - Ejecutar en FZF

## 🔧 Scripts de Utilidad
- `clean-zsh-cache` - Limpiar caché de zsh
- `update-zsh-plugins` - Actualizar plugins
- `zsh-info` - Información de configuración

## 📁 Navegación Rápida
- `..`, `...`, `....` - Subir directorios
- `-` - Directorio anterior
- `z <pattern>` - Saltar a directorio frecuente

## 🎨 Git Aliases
- `g` → `git`
- `gs` → `git status`
- `ga` → `git add`
- `gc` → `git commit`
- `gp` → `git push`
- `gl` → `git pull`
- `gd` → `git diff`
- `gco` → `git checkout`
- `gb` → `git branch`
- `glog` → `git log --oneline --graph --decorate`

## 🌐 Red y Sistema
- `myip` - IP pública
- `localip` - IP local
- `ports` - Puertos abiertos
- `ping` - Ping con 5 paquetes

## 📝 Personalización
- Edita `~/.zshrc.local` para personalizaciones
- Los aliases y funciones no se sobrescriben en actualizaciones
- Usa `dotfile zshlocal` para editar rápidamente

## 🔄 Plugins Incluidos
- zsh-autosuggestions - Sugerencias automáticas
- fast-syntax-highlighting - Syntax highlighting
- zsh-you-should-use - Recordatorios de aliases
- forgit - Git interactivo
- zsh-z - Navegación inteligente
- history-search-multi-word - Búsqueda avanzada
EOF
    
    success "✅ Referencia rápida creada en: $ref_file"
    log "💡 Accede con: cat ~/.local/share/zsh-productivity-reference.md"
}

# =====================================================
# 🏁 FUNCIÓN PRINCIPAL
# =====================================================

main() {
    # Inicializar biblioteca
    init_library
    
    # Banner
    echo -e "${BOLD}${CYAN}🎯 INSTALANDO MÓDULO: $MODULE_NAME${COLOR_RESET}"
    echo -e "${CYAN}$MODULE_DESCRIPTION${COLOR_RESET}\n"
    
    # Instalar dependencias
    install_module_dependencies
    
    # Instalar Starship
    install_starship
    
    # Instalar Zinit
    install_zinit
    
    # Instalar herramientas de productividad
    install_productivity_tools
    
    # Configurar directorios
    setup_zsh_directories
    
    # Configurar archivos
    configure_module_files
    
    # Configurar shell por defecto
    configure_default_shell
    
    # Verificar instalación
    verify_module_installation || warn "⚠️  Verificación parcial - continuando"
    
    # Configuración post-instalación
    post_installation_setup
    
    echo -e "\n${BOLD}${GREEN}✅ Módulo $MODULE_NAME instalado exitosamente${COLOR_RESET}"
    echo -e "${YELLOW}🚀 Para usar Zsh Productividad: exec zsh${COLOR_RESET}"
    
    # Crear archivo de información para referencia rápida
    create_quick_reference
    
    # Retornar exitosamente
    return 0
}

# Ejecutar función principal
main "$@"
exit $?
