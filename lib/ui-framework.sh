#!/bin/bash
# =====================================================
# 🎨 ARCH DREAM - MODERN UI FRAMEWORK
# =====================================================
# Framework de interfaz moderna para instaladores
# Separación limpia de responsabilidades UI
# =====================================================

set -euo pipefail

# =====================================================
# 🎨 ADVANCED COLOR SYSTEM
# =====================================================

# Modern color palette
UI_PRIMARY='\033[38;5;87m'      # Cyan brillante
UI_SECONDARY='\033[38;5;147m'   # Púrpura suave
UI_SUCCESS='\033[38;5;118m'     # Verde brillante
UI_WARNING='\033[38;5;226m'     # Amarillo brillante
UI_ERROR='\033[38;5;196m'       # Rojo brillante
UI_INFO='\033[38;5;33m'         # Azul brillante
UI_MUTED='\033[38;5;245m'       # Gris
UI_ACCENT='\033[38;5;208m'      # Naranja

# Text styles
UI_BOLD='\033[1m'
UI_DIM='\033[2m'
UI_ITALIC='\033[3m'
UI_UNDERLINE='\033[4m'
UI_BLINK='\033[5m'
UI_REVERSE='\033[7m'
UI_RESET='\033[0m'

# Box drawing characters
BOX_H='─'
BOX_V='│'
BOX_TL='┌'
BOX_TR='┐'
BOX_BL='└'
BOX_BR='┘'
BOX_T='┬'
BOX_B='┴'
BOX_L='├'
BOX_R='┤'
BOX_X='┼'

# Unicode symbols
ICON_SUCCESS='✅'
ICON_ERROR='❌'
ICON_WARNING='⚠️'
ICON_INFO='ℹ️'
ICON_ROCKET='🚀'
ICON_GEAR='⚙️'
ICON_PACKAGE='📦'
ICON_FOLDER='📁'
ICON_FIRE='🔥'
ICON_STAR='⭐'
ICON_LIGHTNING='⚡'
ICON_DIAMOND='💎'

# =====================================================
# 🖼️ BANNER & HEADER FUNCTIONS
# =====================================================

ui_show_main_banner() {
    clear
    echo -e "${UI_BOLD}${UI_PRIMARY}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════════════╗
    ║     🚀 ARCH DREAM MACHINE - INSTALADOR MODERNO v6.0        ║
    ║           ⚡ Digital Dream Architect ⚡                       ║
    ║                                                             ║
    ║        Arquitectura modular • UI moderna • Rápido          ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${UI_RESET}${UI_INFO}"
    echo "    🎯 Usando librerías optimizadas del proyecto"
    echo "    ⚡ Separación de responsabilidades"
    echo -e "${UI_RESET}"
    echo
}

ui_show_section_header() {
    local title="$1"
    local icon="${2:-$ICON_GEAR}"
    
    echo -e "${UI_BOLD}${UI_SECONDARY}$icon $title${UI_RESET}"
    echo -e "${UI_MUTED}$(printf '%*s' ${#title} '' | tr ' ' '─')${UI_RESET}"
}

ui_show_subsection() {
    local title="$1"
    local icon="${2:-$ICON_INFO}"
    
    echo -e "${UI_BOLD}${UI_INFO}$icon $title${UI_RESET}"
}

# =====================================================
# 📊 PROGRESS & STATUS DISPLAY
# =====================================================

ui_progress_bar() {
    local current=$1
    local total=$2
    local width=${3:-50}
    local title="${4:-Progress}"
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${UI_BOLD}${UI_PRIMARY}%s:${UI_RESET} [" "$title"
    printf "%*s" $filled '' | tr ' ' '█'
    printf "%*s" $empty '' | tr ' ' '░'
    printf "] ${UI_BOLD}%d%%${UI_RESET} (%d/%d)" $percentage $current $total
}

ui_spinner() {
    local pid=$1
    local message="$2"
    local delay=0.1
    local spinstr='|/-\'
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r${UI_PRIMARY}[%c]${UI_RESET} %s" "$spinstr" "$message"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r"
}

# =====================================================
# 📦 MODULE DISPLAY FUNCTIONS
# =====================================================

ui_show_module_list() {
    local modules=("$@")
    local current_category=""
    
    echo -e "${UI_BOLD}${UI_PACKAGE} MÓDULOS DISPONIBLES${UI_RESET}"
    echo
    
    for i in "${!modules[@]}"; do
        local module="${modules[i]}"
        local category="${module%%:*}"
        local name="${module#*:}"
        
        # Show category header
        if [[ "$category" != "$current_category" ]]; then
            [[ -n "$current_category" ]] && echo
            echo -e "${UI_BOLD}${UI_ACCENT}  ${ICON_FOLDER} $category:${UI_RESET}"
            current_category="$category"
        fi
        
        # Show module with number
        printf "    ${UI_PRIMARY}%2d)${UI_RESET} %-20s" "$((i+1))" "$name"
        
        # Add status if available
        if command -v is_module_installed &>/dev/null && is_module_installed "$module"; then
            echo -e " ${UI_SUCCESS}${ICON_SUCCESS}${UI_RESET}"
        else
            echo -e " ${UI_MUTED}○${UI_RESET}"
        fi
    done
}

ui_show_selection_help() {
    echo
    echo -e "${UI_BOLD}${UI_LIGHTNING} OPCIONES ESPECIALES:${UI_RESET}"
    echo -e "  • ${UI_BOLD}all${UI_RESET} - Todos los módulos"
    echo -e "  • ${UI_BOLD}<categoria>:*${UI_RESET} - Toda una categoría"
    echo -e "  • ${UI_BOLD}números separados por comas${UI_RESET} - Módulos específicos"
    echo
}

# =====================================================
# 🎯 STATUS & DIAGNOSTICS UI
# =====================================================

ui_show_system_status() {
    ui_show_section_header "ESTADO DEL SISTEMA ARCH DREAM" "$ICON_ROCKET"
    echo
    
    # System info box
    echo -e "${UI_INFO}${BOX_TL}${BOX_H} Sistema ${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_TR}${UI_RESET}"
    echo -e "${UI_INFO}${BOX_V}${UI_RESET} OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 | head -c 35)"
    echo -e "${UI_INFO}${BOX_V}${UI_RESET} Kernel: $(uname -r)"
    echo -e "${UI_INFO}${BOX_V}${UI_RESET} Shell: $SHELL"
    echo -e "${UI_INFO}${BOX_BL}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_BR}${UI_RESET}"
    echo
}

ui_show_modules_status() {
    local modules=("$@")
    local installed=0
    
    echo -e "${UI_BOLD}${UI_PACKAGE} Módulos instalados:${UI_RESET}"
    echo
    
    for module in "${modules[@]}"; do
        if command -v is_module_installed &>/dev/null && is_module_installed "$module"; then
            echo -e "   ${UI_SUCCESS}${ICON_SUCCESS}${UI_RESET} $module"
            installed=$((installed + 1))
        else
            echo -e "   ${UI_ERROR}${ICON_ERROR}${UI_RESET} $module"
        fi
    done
    
    echo
    echo -e "${UI_ACCENT}📈 Resumen: ${UI_SUCCESS}$installed${UI_RESET}/${#modules[@]} módulos instalados"
}

ui_show_installation_plan() {
    local modules=("$@")
    local original_modules=("${modules[@]}")
    
    echo -e "${UI_BOLD}${UI_PACKAGE} PLAN DE INSTALACIÓN${UI_RESET}"
    echo
    
    for module in "${modules[@]}"; do
        if [[ " ${original_modules[*]} " =~ " $module " ]]; then
            echo -e "   ${UI_PRIMARY}•${UI_RESET} $module"
        else
            echo -e "   ${UI_MUTED}•${UI_RESET} $module ${UI_DIM}(dependencia)${UI_RESET}"
        fi
    done
    echo
}

# =====================================================
# 🎮 INTERACTIVE INPUT FUNCTIONS
# =====================================================

ui_prompt() {
    local message="$1"
    local default="${2:-}"
    
    if [[ -n "$default" ]]; then
        echo -e -n "${UI_PRIMARY}$message ${UI_MUTED}[$default]${UI_RESET}: "
    else
        echo -e -n "${UI_PRIMARY}$message${UI_RESET}: "
    fi
}

ui_confirm() {
    local message="$1"
    local default="${2:-n}"
    
    local prompt_text="y/N"
    [[ "$default" == "y" ]] && prompt_text="Y/n"
    
    echo -e -n "${UI_WARNING}$message ${UI_MUTED}[$prompt_text]${UI_RESET}: "
    read -r reply
    
    if [[ -z "$reply" ]]; then
        reply="$default"
    fi
    
    [[ "$reply" =~ ^[Yy]$ ]]
}

# =====================================================
# 📊 RESULTS & SUMMARY DISPLAY
# =====================================================

ui_show_installation_results() {
    local installed=$1
    local failed=$2
    local total=$3
    local time_taken=$4
    
    echo
    echo -e "${UI_BOLD}${UI_DIAMOND} RESULTADOS DE INSTALACIÓN${UI_RESET}"
    
    # Create results box
    local box_width=45
    echo -e "${UI_INFO}${BOX_TL}$(printf '%*s' $((box_width-2)) '' | tr ' ' "$BOX_H")${BOX_TR}${UI_RESET}"
    
    printf "${UI_INFO}${BOX_V}${UI_RESET} Instalados: "
    printf "${UI_SUCCESS}%d${UI_RESET}/%d" $installed $total
    printf "%*s${UI_INFO}${BOX_V}${UI_RESET}\n" $((box_width-15-${#installed}-${#total})) ""
    
    printf "${UI_INFO}${BOX_V}${UI_RESET} Fallidos: "
    printf "${UI_ERROR}%d${UI_RESET}" $failed
    printf "%*s${UI_INFO}${BOX_V}${UI_RESET}\n" $((box_width-12-${#failed})) ""
    
    printf "${UI_INFO}${BOX_V}${UI_RESET} Tiempo: %ds" $time_taken
    printf "%*s${UI_INFO}${BOX_V}${UI_RESET}\n" $((box_width-10-${#time_taken})) ""
    
    echo -e "${UI_INFO}${BOX_BL}$(printf '%*s' $((box_width-2)) '' | tr ' ' "$BOX_H")${BOX_BR}${UI_RESET}"
}

ui_show_success_message() {
    echo -e "${UI_SUCCESS}${ICON_SUCCESS} ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!${UI_RESET}"
    echo
    echo -e "${UI_BOLD}${UI_LIGHTNING} Próximos pasos:${UI_RESET}"
    echo -e "  • ${UI_PRIMARY}exec \$SHELL${UI_RESET} - Reiniciar terminal"
    echo -e "  • ${UI_PRIMARY}./arch-dream status${UI_RESET} - Ver estado"
    echo -e "  • ${UI_PRIMARY}./arch-dream doctor${UI_RESET} - Diagnóstico"
}

ui_show_error_message() {
    local failed=$1
    echo -e "${UI_ERROR}${ICON_ERROR} INSTALACIÓN COMPLETADA CON $failed ERRORES${UI_RESET}"
}

# =====================================================
# 🔧 DIAGNOSTIC UI FUNCTIONS
# =====================================================

ui_show_diagnostic_header() {
    ui_show_section_header "DIAGNÓSTICO DEL SISTEMA" "$ICON_GEAR"
    echo
}

ui_show_diagnostic_category() {
    local category="$1"
    local icon="${2:-$ICON_GEAR}"
    
    echo -e "${UI_BOLD}${UI_ACCENT}$icon $category${UI_RESET}"
}

ui_show_diagnostic_item() {
    local status="$1"  # success, error, warning
    local item="$2"
    local details="${3:-}"
    
    local icon color
    case "$status" in
        success)
            icon="$ICON_SUCCESS"
            color="$UI_SUCCESS"
            ;;
        error)
            icon="$ICON_ERROR" 
            color="$UI_ERROR"
            ;;
        warning)
            icon="$ICON_WARNING"
            color="$UI_WARNING"
            ;;
        *)
            icon="$ICON_INFO"
            color="$UI_INFO"
            ;;
    esac
    
    if [[ -n "$details" ]]; then
        echo -e "   ${color}$icon${UI_RESET} $item ${UI_MUTED}($details)${UI_RESET}"
    else
        echo -e "   ${color}$icon${UI_RESET} $item"
    fi
}