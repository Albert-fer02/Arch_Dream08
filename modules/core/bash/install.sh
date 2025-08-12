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
# 🧩 ARCH DREAM MACHINE - MÓDULO BASH
# =====================================================
# Script de instalación del módulo Bash (con Starship / Oh My Posh y utilidades)
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# =====================================================
# 🔧 CONFIGURACIÓN DEL MÓDULO
# =====================================================

MODULE_NAME="Bash Configuration"
MODULE_DESCRIPTION="Configuración avanzada de Bash con prompt moderno y utilidades"
MODULE_DEPENDENCIES=("bash" "git" "curl" "wget")
MODULE_FILES=("bashrc" "bashrc.root")

# Flags de comportamiento (pueden sobreescribirse por entorno)
BASH_PROMPT="${BASH_PROMPT:-starship}"          # starship | oh-my-posh | native
BASH_ENABLE_FZF="${BASH_ENABLE_FZF:-true}"
BASH_ENABLE_ZOXIDE="${BASH_ENABLE_ZOXIDE:-true}"
BASH_ENABLE_DIRENV="${BASH_ENABLE_DIRENV:-true}"
BASH_ENABLE_ATUIN="${BASH_ENABLE_ATUIN:-true}"
BASH_ENABLE_BLE="${BASH_ENABLE_BLE:-false}"     # desactivado por defecto (modifica el comportamiento de edición)

# Rutas de configuración
XDG_CONFIG_HOME_DEFAULT="$HOME/.config"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$XDG_CONFIG_HOME_DEFAULT}"
OMP_CONFIG_DIR="$XDG_CONFIG_HOME/oh-my-posh"
OMP_CONFIG_FILE="$OMP_CONFIG_DIR/theme.omp.json"

# =====================================================
# 🔧 FUNCIONES DEL MÓDULO
# =====================================================

install_module_dependencies() {
    log "Instalando dependencias base del módulo $MODULE_NAME..."
    for dep in "${MODULE_DEPENDENCIES[@]}"; do
        if command -v "$dep" &>/dev/null; then
            success "✓ $dep ya está instalado"
        else
            install_package "$dep"
        fi
    done
}

install_prompt_engine() {
    case "$BASH_PROMPT" in
        starship)
            log "Instalando Starship..."
            install_package "starship" "Starship"
            ;;
        oh-my-posh)
            log "Instalando Oh My Posh..."
            if pacman -Si oh-my-posh >/dev/null 2>&1; then
                install_package "oh-my-posh" "Oh My Posh"
            else
                install_aur_package "oh-my-posh-bin" "Oh My Posh (AUR)"
            fi
            # Crear configuración mínima si no existe
            if [[ ! -f "$OMP_CONFIG_FILE" ]]; then
                mkdir -p "$OMP_CONFIG_DIR"
                cat >"$OMP_CONFIG_FILE" <<'EOF'
{
  "$schema": "https://ohmyposh.dev/schema.json",
  "final_space": true,
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "segments": [
        { "type": "path", "style": "diamond", "foreground": "p:white", "background": "p:blue" },
        { "type": "git", "style": "diamond", "background": "p:green", "foreground": "p:black" }
      ]
    }
  ]
}
EOF
                success "✓ Configuración mínima creada: $OMP_CONFIG_FILE"
            fi
            ;;
        native|*)
            log "Usando prompt nativo de Bash (sin motor externo)"
            ;;
    esac
}

install_optional_tools() {
    # fzf
    if [[ "$BASH_ENABLE_FZF" == "true" ]]; then
        install_package "fzf" "fzf"
    fi
    # bash-completion (siempre útil si está disponible)
    install_package "bash-completion" "bash-completion" || true
    # zoxide
    if [[ "$BASH_ENABLE_ZOXIDE" == "true" ]]; then
        install_package "zoxide" "zoxide" || install_aur_package "zoxide-bin" "zoxide (AUR)"
    fi
    # direnv
    if [[ "$BASH_ENABLE_DIRENV" == "true" ]]; then
        install_package "direnv" "direnv"
    fi
    # atuin
    if [[ "$BASH_ENABLE_ATUIN" == "true" ]]; then
        if pacman -Si atuin >/dev/null 2>&1; then
            install_package "atuin" "atuin"
        else
            install_aur_package "atuin-bin" "atuin (AUR)"
        fi
    fi
    # ble.sh (opcional)
    if [[ "$BASH_ENABLE_BLE" == "true" ]]; then
        install_aur_package "bash-ble" "ble.sh" || install_aur_package "ble.sh" "ble.sh"
    fi
}

configure_prompt_theme_files() {
    # Configurar archivos de tema/plantilla para el prompt elegido
    case "$BASH_PROMPT" in
        starship|auto)
            # En auto podría no estar instalado, pero enlazamos si existe el archivo de tema del módulo
            local src_starship="$SCRIPT_DIR/starship.toml"
            local dst_starship="$XDG_CONFIG_HOME/starship.toml"
            if [[ -f "$src_starship" ]]; then
                mkdir -p "$(dirname "$dst_starship")"
                create_symlink "$src_starship" "$dst_starship" "starship.toml"
            fi
            ;;
        oh-my-posh)
            local src_omp="$SCRIPT_DIR/oh-my-posh.dreamcoder.json"
            local dst_omp="$OMP_CONFIG_FILE"
            if [[ -f "$src_omp" ]]; then
                mkdir -p "$(dirname "$dst_omp")"
                create_symlink "$src_omp" "$dst_omp" "oh-my-posh theme"
            fi
            ;;
    esac
}

configure_module_files() {
    log "Configurando archivos del módulo $MODULE_NAME..."

    # Usuario normal
    if [[ "$EUID" -ne 0 ]]; then
        create_symlink "$SCRIPT_DIR/bashrc" "$HOME/.bashrc" ".bashrc"
        # .bash_profile opcional
        if [[ ! -e "$HOME/.bash_profile" ]]; then
            create_symlink "$SCRIPT_DIR/bashrc" "$HOME/.bash_profile" ".bash_profile"
        fi
        # archivo local
        if [[ ! -f "$HOME/.bashrc.local" ]]; then
            cat > "$HOME/.bashrc.local" << 'EOF'
# =====================================================
# 🧩 CONFIGURACIÓN LOCAL DE BASH
# =====================================================
# Personalizaciones específicas del usuario (no se sobrescribe)

# Ejemplos:
# export BASH_PROMPT="starship"   # oh-my-posh | starship | native
# export BASH_ENABLE_FZF=true
# export BASH_ENABLE_ZOXIDE=true
# export BASH_ENABLE_DIRENV=true
# export BASH_ENABLE_ATUIN=true
# export BASH_ENABLE_BLE=false
EOF
            success "✓ Archivo local creado: ~/.bashrc.local"
        fi
    else
        # Entorno root
        create_symlink "$SCRIPT_DIR/bashrc.root" "$HOME/.bashrc" ".bashrc (root)"
        if [[ ! -e "$HOME/.bash_profile" ]]; then
            create_symlink "$SCRIPT_DIR/bashrc.root" "$HOME/.bash_profile" ".bash_profile (root)"
        fi
        if [[ ! -f "$HOME/.bashrc.local" ]]; then
            printf "# Configuración local de root\n" > "$HOME/.bashrc.local"
            success "✓ Archivo local creado: /root/.bashrc.local"
        fi
    fi
}

verify_module_installation() {
    log "Verificando instalación del módulo $MODULE_NAME..."

    local checks_passed=0
    local total_checks=4

    if command -v bash &>/dev/null; then
        success "✓ Bash instalado"
        ((++checks_passed))
    else
        error "✗ Bash no está instalado"
    fi

    if [[ -L "$HOME/.bashrc" ]] && [[ -e "$HOME/.bashrc" ]]; then
        success "✓ .bashrc configurado"
        ((++checks_passed))
    else
        error "✗ .bashrc no está configurado"
    fi

    # Verificación del motor de prompt seleccionado
    case "$BASH_PROMPT" in
        starship)
            if command -v starship &>/dev/null; then
                success "✓ Starship instalado"
                ((++checks_passed))
            else
                warn "⚠️ Starship no detectado"
            fi
            ;;
        oh-my-posh)
            if command -v oh-my-posh &>/dev/null; then
                success "✓ Oh My Posh instalado"
                ((++checks_passed))
            else
                warn "⚠️ Oh My Posh no detectado"
            fi
            ;;
        native|*)
            success "✓ Prompt nativo seleccionado"
            ((++checks_passed))
            ;;
    esac

    # .bash_profile opcional
    if [[ -e "$HOME/.bash_profile" ]]; then
        success "✓ .bash_profile presente"
        ((++checks_passed))
    else
        success "✓ .bash_profile opcional"
        ((++checks_passed))
    fi

    if [[ $checks_passed -ge $total_checks ]]; then
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
    init_library

    echo -e "${BOLD}${CYAN}🧩 INSTALANDO MÓDULO: $MODULE_NAME${COLOR_RESET}"
    echo -e "${CYAN}$MODULE_DESCRIPTION${COLOR_RESET}\n"

    install_module_dependencies
    install_prompt_engine
    install_optional_tools
    configure_prompt_theme_files
    configure_module_files
    verify_module_installation

    echo -e "\n${BOLD}${GREEN}✅ Módulo $MODULE_NAME instalado exitosamente${COLOR_RESET}"
    echo -e "${YELLOW}💡 Para usar Bash: bash${COLOR_RESET}"
}

main "$@"