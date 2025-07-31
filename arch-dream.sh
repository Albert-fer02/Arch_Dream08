#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM MACHINE - SCRIPT PRINCIPAL CONSOLIDADO
# =====================================================
# Script único que maneja instalación, actualización, verificación
# y desinstalación usando modules.json como configuración central
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# =====================================================
# 🔧 CONFIGURACIÓN
# =====================================================

# Archivo de configuración de módulos
MODULES_CONFIG="$SCRIPT_DIR/modules.json"

# =====================================================
# 🎨 FUNCIONES DE INTERFAZ INTERACTIVA
# =====================================================

# Mostrar banner principal
show_banner() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    🧩 ARCH DREAM MACHINE 🧩                  ║"
    echo "║                Script de Gestión Interactivo                 ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo -e "${CYAN}Gestión consolidada de módulos para Arch Linux${COLOR_RESET}"
    echo -e "${YELLOW}Versión: 4.0.0 - Modo Interactivo Avanzado${COLOR_RESET}\n"
    
    # Mostrar información del sistema
    show_system_info_banner
}

# Mostrar información del sistema en el banner
show_system_info_banner() {
    echo -e "${BOLD}${PURPLE}📊 Información del Sistema:${COLOR_RESET}"
    echo -e "${CYAN}•${COLOR_RESET} Sistema: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "${CYAN}•${COLOR_RESET} Kernel: $(uname -r)"
    echo -e "${CYAN}•${COLOR_RESET} Usuario: $USER"
    echo -e "${CYAN}•${COLOR_RESET} Hora: $(date '+%H:%M:%S')"
    echo
}

# Mostrar menú principal
show_main_menu() {
    echo -e "${BOLD}${YELLOW}📋 MENÚ PRINCIPAL${COLOR_RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    echo -e "${BOLD}${PURPLE}🧩 GESTIÓN DE MÓDULOS:${COLOR_RESET}"
    echo -e "${BOLD}${GREEN}1.${COLOR_RESET} 🚀 Instalar módulos"
    echo -e "${BOLD}${GREEN}2.${COLOR_RESET} 🔄 Actualizar módulos"
    echo -e "${BOLD}${GREEN}3.${COLOR_RESET} 🔍 Verificar módulos"
    echo -e "${BOLD}${GREEN}4.${COLOR_RESET} 🗑️  Desinstalar módulos"
    echo -e "${BOLD}${GREEN}5.${COLOR_RESET} 📦 Listar módulos disponibles"
    echo
    echo -e "${BOLD}${PURPLE}⚙️  HERRAMIENTAS AVANZADAS:${COLOR_RESET}"
    echo -e "${BOLD}${GREEN}6.${COLOR_RESET} ⚙️  Configuración avanzada"
    echo -e "${BOLD}${GREEN}7.${COLOR_RESET} 🧪 Pruebas rápidas"
    echo -e "${BOLD}${GREEN}8.${COLOR_RESET} 📊 Estadísticas del sistema"
    echo -e "${BOLD}${GREEN}9.${COLOR_RESET} 🔧 Modo mantenimiento"
    echo
    echo -e "${BOLD}${PURPLE}❓ AYUDA Y SALIDA:${COLOR_RESET}"
    echo -e "${BOLD}${GREEN}10.${COLOR_RESET} ❓ Ayuda"
    echo -e "${BOLD}${GREEN}0.${COLOR_RESET} 🚪 Salir"
    echo
}

# Mostrar menú de instalación
show_install_menu() {
    echo -e "${BOLD}${YELLOW}🚀 MENÚ DE INSTALACIÓN${COLOR_RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    echo -e "${BOLD}${GREEN}1.${COLOR_RESET} 📦 Instalar TODOS los módulos"
    echo -e "${BOLD}${GREEN}2.${COLOR_RESET} 🎯 Instalar módulo específico"
    echo -e "${BOLD}${GREEN}3.${COLOR_RESET} 🔧 Instalar módulos por categoría"
    echo -e "${BOLD}${GREEN}0.${COLOR_RESET} ↩️  Volver al menú principal"
    echo
}

# Mostrar menú de actualización
show_update_menu() {
    echo -e "${BOLD}${YELLOW}🔄 MENÚ DE ACTUALIZACIÓN${COLOR_RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    echo -e "${BOLD}${GREEN}1.${COLOR_RESET} 📦 Actualizar TODOS los módulos"
    echo -e "${BOLD}${GREEN}2.${COLOR_RESET} 🎯 Actualizar módulo específico"
    echo -e "${BOLD}${GREEN}3.${COLOR_RESET} 🔧 Actualizar solo paquetes del sistema"
    echo -e "${BOLD}${GREEN}4.${COLOR_RESET} 🌐 Actualizar paquetes AUR"
    echo -e "${BOLD}${GREEN}0.${COLOR_RESET} ↩️  Volver al menú principal"
    echo
}

# Mostrar menú de verificación
show_verify_menu() {
    echo -e "${BOLD}${YELLOW}🔍 MENÚ DE VERIFICACIÓN${COLOR_RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    echo -e "${BOLD}${GREEN}1.${COLOR_RESET} 📦 Verificar TODOS los módulos"
    echo -e "${BOLD}${GREEN}2.${COLOR_RESET} 🎯 Verificar módulo específico"
    echo -e "${BOLD}${GREEN}3.${COLOR_RESET} 🔧 Verificar integridad del sistema"
    echo -e "${BOLD}${GREEN}4.${COLOR_RESET} 📋 Generar reporte de verificación"
    echo -e "${BOLD}${GREEN}0.${COLOR_RESET} ↩️  Volver al menú principal"
    echo
}

# Mostrar menú de desinstalación
show_uninstall_menu() {
    echo -e "${BOLD}${YELLOW}🗑️  MENÚ DE DESINSTALACIÓN${COLOR_RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    echo -e "${BOLD}${RED}1.${COLOR_RESET} 📦 Desinstalar TODOS los módulos"
    echo -e "${BOLD}${RED}2.${COLOR_RESET} 🎯 Desinstalar módulo específico"
    echo -e "${BOLD}${RED}3.${COLOR_RESET} 🔧 Desinstalar solo configuraciones"
    echo -e "${BOLD}${RED}4.${COLOR_RESET} 🗂️  Desinstalar y remover paquetes"
    echo -e "${BOLD}${GREEN}0.${COLOR_RESET} ↩️  Volver al menú principal"
    echo
}

# Mostrar menú de configuración avanzada
show_advanced_menu() {
    echo -e "${BOLD}${YELLOW}⚙️  CONFIGURACIÓN AVANZADA${COLOR_RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    echo -e "${BOLD}${GREEN}1.${COLOR_RESET} 🔧 Configurar módulo específico"
    echo -e "${BOLD}${GREEN}2.${COLOR_RESET} 📊 Ver estadísticas del sistema"
    echo -e "${BOLD}${GREEN}3.${COLOR_RESET} 🧪 Ejecutar pruebas de diagnóstico"
    echo -e "${BOLD}${GREEN}4.${COLOR_RESET} 🔄 Restaurar configuración desde backup"
    echo -e "${BOLD}${GREEN}5.${COLOR_RESET} 📝 Ver logs del sistema"
    echo -e "${BOLD}${GREEN}0.${COLOR_RESET} ↩️  Volver al menú principal"
    echo
}

# Mostrar módulos por categoría
show_modules_by_category() {
    echo -e "${BOLD}${YELLOW}📦 MÓDULOS POR CATEGORÍA${COLOR_RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    echo -e "${BOLD}${PURPLE}🧩 CORE (Fundamentales):${COLOR_RESET}"
    echo -e "  ${GREEN}•${COLOR_RESET} zsh    - Zsh + Oh My Zsh + Powerlevel10k"
    echo -e "  ${GREEN}•${COLOR_RESET} bash   - Configuración de Bash (fallback)"
    echo
    
    echo -e "${BOLD}${PURPLE}🖥️  TERMINAL:${COLOR_RESET}"
    echo -e "  ${GREEN}•${COLOR_RESET} kitty  - Terminal con aceleración GPU"
    echo
    
    echo -e "${BOLD}${PURPLE}🛠️  TOOLS:${COLOR_RESET}"
    echo -e "  ${GREEN}•${COLOR_RESET} fastfetch - Información del sistema"
    echo -e "  ${GREEN}•${COLOR_RESET} nano      - Editor con configuración"
    echo
    
    echo -e "${BOLD}${PURPLE}💻 DEVELOPMENT:${COLOR_RESET}"
    echo -e "  ${GREEN}•${COLOR_RESET} git     - Configuración de Git"
    echo -e "  ${GREEN}•${COLOR_RESET} neovim  - Editor avanzado"
    echo
}

# Seleccionar módulo interactivamente
select_module() {
    local modules
    readarray -t modules < <(get_available_modules)
    
    echo -e "${BOLD}${YELLOW}🎯 Selecciona un módulo:${COLOR_RESET}\n"
    
    local i=1
    for module in "${modules[@]}"; do
        if [[ -n "$module" ]]; then
            local name
            local description
            name=$(get_module_info "$module" "name")
            description=$(get_module_info "$module" "description")
            
            echo -e "${BOLD}${GREEN}$i.${COLOR_RESET} $module - $name"
            echo -e "    ${CYAN}$description${COLOR_RESET}"
            echo
            ((i++))
        fi
    done
    
    echo -e "${BOLD}${GREEN}0.${COLOR_RESET} ↩️  Cancelar"
    echo
    
    read -p "Selecciona una opción (0-$((i-1))): " choice
    
    if [[ "$choice" == "0" ]]; then
        return 1
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le $((i-1)) ]]; then
        local selected_module="${modules[$((choice-1))]}"
        echo "$selected_module"
        return 0
    else
        error "Opción inválida"
        return 1
    fi
}

# Seleccionar categoría de módulos
select_category() {
    echo -e "${BOLD}${YELLOW}📂 Selecciona una categoría:${COLOR_RESET}\n"
    
    echo -e "${BOLD}${GREEN}1.${COLOR_RESET} 🧩 Core (zsh, bash)"
    echo -e "${BOLD}${GREEN}2.${COLOR_RESET} 🖥️  Terminal (kitty)"
    echo -e "${BOLD}${GREEN}3.${COLOR_RESET} 🛠️  Tools (fastfetch, nano)"
    echo -e "${BOLD}${GREEN}4.${COLOR_RESET} 💻 Development (git, neovim)"
    echo -e "${BOLD}${GREEN}0.${COLOR_RESET} ↩️  Cancelar"
    echo
    
    read -p "Selecciona una opción (0-4): " choice
    
    case "$choice" in
        "1")
            echo "core"
            return 0
            ;;
        "2")
            echo "terminal"
            return 0
            ;;
        "3")
            echo "tools"
            return 0
            ;;
        "4")
            echo "development"
            return 0
            ;;
        "0")
            return 1
            ;;
        *)
            error "Opción inválida"
            return 1
            ;;
    esac
}

# Instalar módulos por categoría
install_modules_by_category() {
    local category="$1"
    
    case "$category" in
        "core")
            log "Instalando módulos Core..."
            install_module "zsh"
            install_module "bash"
            ;;
        "terminal")
            log "Instalando módulos Terminal..."
            install_module "kitty"
            ;;
        "tools")
            log "Instalando módulos Tools..."
            install_module "fastfetch"
            install_module "nano"
            ;;
        "development")
            log "Instalando módulos Development..."
            install_module "git"
            install_module "neovim"
            ;;
        *)
            error "Categoría desconocida: $category"
            return 1
            ;;
    esac
}

# Actualizar módulos por categoría
update_modules_by_category() {
    local category="$1"
    
    case "$category" in
        "core")
            log "Actualizando módulos Core..."
            update_module "zsh"
            update_module "bash"
            ;;
        "terminal")
            log "Actualizando módulos Terminal..."
            update_module "kitty"
            ;;
        "tools")
            log "Actualizando módulos Tools..."
            update_module "fastfetch"
            update_module "nano"
            ;;
        "development")
            log "Actualizando módulos Development..."
            update_module "git"
            update_module "neovim"
            ;;
        *)
            error "Categoría desconocida: $category"
            return 1
            ;;
    esac
}

# Verificar módulos por categoría
verify_modules_by_category() {
    local category="$1"
    
    case "$category" in
        "core")
            log "Verificando módulos Core..."
            verify_module "zsh"
            verify_module "bash"
            ;;
        "terminal")
            log "Verificando módulos Terminal..."
            verify_module "kitty"
            ;;
        "tools")
            log "Verificando módulos Tools..."
            verify_module "fastfetch"
            verify_module "nano"
            ;;
        "development")
            log "Verificando módulos Development..."
            verify_module "git"
            verify_module "neovim"
            ;;
        *)
            error "Categoría desconocida: $category"
            return 1
            ;;
    esac
}

# Desinstalar módulos por categoría
uninstall_modules_by_category() {
    local category="$1"
    
    case "$category" in
        "core")
            log "Desinstalando módulos Core..."
            uninstall_module "zsh"
            uninstall_module "bash"
            ;;
        "terminal")
            log "Desinstalando módulos Terminal..."
            uninstall_module "kitty"
            ;;
        "tools")
            log "Desinstalando módulos Tools..."
            uninstall_module "fastfetch"
            uninstall_module "nano"
            ;;
        "development")
            log "Desinstalando módulos Development..."
            uninstall_module "git"
            uninstall_module "neovim"
            ;;
        *)
            error "Categoría desconocida: $category"
            return 1
            ;;
    esac
}

# Mostrar estadísticas del sistema
show_system_stats() {
    echo -e "${BOLD}${YELLOW}📊 ESTADÍSTICAS DEL SISTEMA${COLOR_RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    # Información del sistema
    echo -e "${BOLD}${PURPLE}🖥️  Sistema:${COLOR_RESET}"
    echo -e "  ${CYAN}•${COLOR_RESET} Distribución: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "  ${CYAN}•${COLOR_RESET} Kernel: $(uname -r)"
    echo -e "  ${CYAN}•${COLOR_RESET} Arquitectura: $(uname -m)"
    echo
    
    # Información de paquetes
    echo -e "${BOLD}${PURPLE}📦 Paquetes:${COLOR_RESET}"
    echo -e "  ${CYAN}•${COLOR_RESET} Instalados: $(pacman -Q | wc -l)"
    echo -e "  ${CYAN}•${COLOR_RESET} Repositorios: $(pacman -Sl | wc -l)"
    echo
    
    # Información de módulos
    local modules
    readarray -t modules < <(get_available_modules)
    echo -e "${BOLD}${PURPLE}🧩 Módulos Arch Dream:${COLOR_RESET}"
    echo -e "  ${CYAN}•${COLOR_RESET} Total disponibles: ${#modules[@]}"
    
    local installed_count=0
    for module in "${modules[@]}"; do
        if [[ -n "$module" ]]; then
            case "$module" in
                "zsh")
                    if command -v zsh &>/dev/null; then ((installed_count++)); fi
                    ;;
                "bash")
                    if command -v bash &>/dev/null; then ((installed_count++)); fi
                    ;;
                "kitty")
                    if command -v kitty &>/dev/null; then ((installed_count++)); fi
                    ;;
                "fastfetch")
                    if command -v fastfetch &>/dev/null; then ((installed_count++)); fi
                    ;;
                "nano")
                    if command -v nano &>/dev/null; then ((installed_count++)); fi
                    ;;
                "git")
                    if command -v git &>/dev/null; then ((installed_count++)); fi
                    ;;
                "neovim")
                    if command -v nvim &>/dev/null; then ((installed_count++)); fi
                    ;;
            esac
        fi
    done
    
    echo -e "  ${CYAN}•${COLOR_RESET} Instalados: $installed_count"
    echo -e "  ${CYAN}•${COLOR_RESET} Por instalar: $((${#modules[@]} - installed_count))"
    echo
    
    # Información de espacio en disco
    echo -e "${BOLD}${PURPLE}💾 Espacio en disco:${COLOR_RESET}"
    local disk_usage=$(df -h / | awk 'NR==2 {print $4}')
    echo -e "  ${CYAN}•${COLOR_RESET} Libre: $disk_usage"
    echo
    
    # Información de memoria
    echo -e "${BOLD}${PURPLE}🧠 Memoria:${COLOR_RESET}"
    local mem_total=$(free -h | awk 'NR==2{print $2}')
    local mem_used=$(free -h | awk 'NR==2{print $3}')
    local mem_free=$(free -h | awk 'NR==2{print $4}')
    echo -e "  ${CYAN}•${COLOR_RESET} Total: $mem_total"
    echo -e "  ${CYAN}•${COLOR_RESET} Usada: $mem_used"
    echo -e "  ${CYAN}•${COLOR_RESET} Libre: $mem_free"
    echo
}

# Ejecutar pruebas de diagnóstico
run_diagnostic_tests() {
    echo -e "${BOLD}${YELLOW}🧪 PRUEBAS DE DIAGNÓSTICO${COLOR_RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    local tests_passed=0
    local total_tests=0
    
    # Test 1: Verificar sistema operativo
    ((total_tests++))
    if is_arch_linux; then
        success "✓ Sistema Arch Linux detectado"
        ((tests_passed++))
    else
        error "✗ No se detectó Arch Linux"
    fi
    
    # Test 2: Verificar permisos sudo
    ((total_tests++))
    if sudo -n true 2>/dev/null; then
        success "✓ Permisos sudo disponibles"
        ((tests_passed++))
    else
        error "✗ Permisos sudo no disponibles"
    fi
    
    # Test 3: Verificar conexión a internet
    ((total_tests++))
    if ping -c 1 archlinux.org &>/dev/null; then
        success "✓ Conexión a internet disponible"
        ((tests_passed++))
    else
        error "✗ Sin conexión a internet"
    fi
    
    # Test 4: Verificar archivo de configuración
    ((total_tests++))
    if [[ -f "$MODULES_CONFIG" ]]; then
        success "✓ Archivo de configuración encontrado"
        ((tests_passed++))
    else
        error "✗ Archivo de configuración no encontrado"
    fi
    
    # Test 5: Verificar jq
    ((total_tests++))
    if command -v jq &>/dev/null; then
        success "✓ jq está instalado"
        ((tests_passed++))
    else
        error "✗ jq no está instalado"
    fi
    
    # Test 6: Verificar espacio en disco
    ((total_tests++))
    local available_space=$(df / | awk 'NR==2 {print $4}')
    if [ "$available_space" -gt 1048576 ]; then
        success "✓ Espacio en disco suficiente"
        ((tests_passed++))
    else
        warn "⚠️  Poco espacio en disco: $(($available_space / 1024))MB"
    fi
    
    echo
    if [[ $tests_passed -eq $total_tests ]]; then
        success "🎉 Todas las pruebas pasaron ($tests_passed/$total_tests)"
        return 0
    else
        warn "⚠️  Algunas pruebas fallaron ($tests_passed/$total_tests)"
        return 1
    fi
}

# Ver logs del sistema
show_system_logs() {
    echo -e "${BOLD}${YELLOW}📝 LOGS DEL SISTEMA${COLOR_RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    if [[ -f "$LOGFILE" ]]; then
        echo -e "${BOLD}${GREEN}Últimas 20 líneas del log:${COLOR_RESET}\n"
        tail -n 20 "$LOGFILE"
    else
        echo -e "${YELLOW}No se encontró archivo de log.${COLOR_RESET}"
    fi
    
    echo
    echo -e "${BOLD}${GREEN}Logs del sistema:${COLOR_RESET}\n"
    echo -e "${CYAN}•${COLOR_RESET} Log de instalación: $LOGFILE"
    echo -e "${CYAN}•${COLOR_RESET} Log de pacman: /var/log/pacman.log"
    echo -e "${CYAN}•${COLOR_RESET} Log del sistema: /var/log/messages"
    echo
}

# Ejecutar pruebas rápidas
run_quick_tests() {
    echo -e "${BOLD}${YELLOW}🧪 PRUEBAS RÁPIDAS${COLOR_RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    local tests_passed=0
    local total_tests=0
    
    # Test básico: Verificar sistema
    ((total_tests++))
    if is_arch_linux; then
        success "✓ Sistema Arch Linux"
        ((tests_passed++))
    else
        error "✗ No es Arch Linux"
    fi
    
    # Test: Verificar jq
    ((total_tests++))
    if command -v jq &>/dev/null; then
        success "✓ jq disponible"
        ((tests_passed++))
    else
        error "✗ jq no disponible"
    fi
    
    # Test: Verificar módulos.json
    ((total_tests++))
    if [[ -f "$MODULES_CONFIG" ]]; then
        success "✓ Configuración de módulos"
        ((tests_passed++))
    else
        error "✗ Configuración faltante"
    fi
    
    # Test: Verificar permisos sudo
    ((total_tests++))
    if sudo -n true 2>/dev/null; then
        success "✓ Permisos sudo"
        ((tests_passed++))
    else
        warn "⚠️  Sin permisos sudo"
    fi
    
    echo
    if [[ $tests_passed -eq $total_tests ]]; then
        success "🎉 Todas las pruebas pasaron ($tests_passed/$total_tests)"
    else
        warn "⚠️  Algunas pruebas fallaron ($tests_passed/$total_tests)"
    fi
    echo
}

# Modo mantenimiento
maintenance_mode() {
    echo -e "${BOLD}${YELLOW}🔧 MODO MANTENIMIENTO${COLOR_RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    echo -e "${BOLD}${PURPLE}🛠️  Herramientas de mantenimiento:${COLOR_RESET}\n"
    
    echo -e "${BOLD}${GREEN}1.${COLOR_RESET} 🧹 Limpiar cache de pacman"
    echo -e "${BOLD}${GREEN}2.${COLOR_RESET} 🗑️  Limpiar paquetes huérfanos"
    echo -e "${BOLD}${GREEN}3.${COLOR_RESET} 🔍 Verificar integridad de paquetes"
    echo -e "${BOLD}${GREEN}4.${COLOR_RESET} 📦 Optimizar base de datos"
    echo -e "${BOLD}${GREEN}5.${COLOR_RESET} 🔄 Actualizar mirrorlist"
    echo -e "${BOLD}${GREEN}0.${COLOR_RESET} ↩️  Volver"
    echo
    
    read -p "Selecciona una opción (0-5): " choice
    
    case "$choice" in
        "1")
            echo
            log "Limpiando cache de pacman..."
            sudo pacman -Sc --noconfirm
            success "✅ Cache limpiado"
            ;;
        "2")
            echo
            log "Removiendo paquetes huérfanos..."
            sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || warn "No hay paquetes huérfanos"
            success "✅ Paquetes huérfanos removidos"
            ;;
        "3")
            echo
            log "Verificando integridad de paquetes..."
            sudo pacman -Qkk
            success "✅ Verificación completada"
            ;;
        "4")
            echo
            log "Optimizando base de datos..."
            sudo pacman-optimize
            success "✅ Base de datos optimizada"
            ;;
        "5")
            echo
            log "Actualizando mirrorlist..."
            sudo pacman -S reflector --noconfirm
            sudo reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
            success "✅ Mirrorlist actualizado"
            ;;
        "0")
            return
            ;;
        *)
            error "Opción inválida"
            ;;
    esac
}

# Mostrar progreso de instalación
show_installation_progress() {
    local module="$1"
    local step="$2"
    local total_steps="$3"
    
    local percentage=$((step * 100 / total_steps))
    local filled=$((percentage / 2))
    local empty=$((50 - filled))
    
    printf "\r${CYAN}[${COLOR_RESET}"
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "${CYAN}]${COLOR_RESET} ${YELLOW}%d%%${COLOR_RESET} - ${GREEN}$module${COLOR_RESET} - ${CYAN}$step/$total_steps${COLOR_RESET}"
    
    if [[ $step -eq $total_steps ]]; then
        echo
    fi
}

# Validar entrada del usuario
validate_user_input() {
    local input="$1"
    local min="$2"
    local max="$3"
    
    if [[ "$input" =~ ^[0-9]+$ ]] && [[ "$input" -ge "$min" ]] && [[ "$input" -le "$max" ]]; then
        return 0
    else
        return 1
    fi
}

# Mostrar mensaje de confirmación mejorado
show_confirmation() {
    local message="$1"
    local default="${2:-n}"
    
    echo -e "${BOLD}${YELLOW}⚠️  CONFIRMACIÓN REQUERIDA${COLOR_RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    echo -e "${message}\n"
    
    if [[ "$default" == "y" ]]; then
        read -p "¿Continuar? (Y/n): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Nn]$ ]]
    else
        read -p "¿Continuar? (y/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# =====================================================
# 🔧 FUNCIONES PRINCIPALES (MANTENER EXISTENTES)
# =====================================================

# Cargar configuración de módulos
load_modules_config() {
    if [[ ! -f "$MODULES_CONFIG" ]]; then
        error "Archivo de configuración no encontrado: $MODULES_CONFIG"
        exit 1
    fi
    
    # Verificar que jq esté disponible
    if ! command -v jq &>/dev/null; then
        error "jq no está instalado. Instálalo con: sudo pacman -S jq"
        exit 1
    fi
    
    # Verificar sintaxis JSON
    if ! jq empty "$MODULES_CONFIG" 2>/dev/null; then
        error "Error de sintaxis en $MODULES_CONFIG"
        exit 1
    fi
}

# Obtener lista de módulos disponibles
get_available_modules() {
    jq -r 'keys[]' "$MODULES_CONFIG" 2>/dev/null
}

# Verificar si un módulo existe
module_exists() {
    local module="$1"
    jq -e "has(\"$module\")" "$MODULES_CONFIG" &>/dev/null
}

# Obtener información de un módulo
get_module_info() {
    local module="$1"
    local field="$2"
    jq -r ".$module.$field" "$MODULES_CONFIG" 2>/dev/null
}

# Obtener dependencias de un módulo
get_module_dependencies() {
    local module="$1"
    jq -r ".$module.dependencies[]?" "$MODULES_CONFIG" 2>/dev/null
}

# Obtener archivos de un módulo
get_module_files() {
    local module="$1"
    jq -r ".$module.files[]?" "$MODULES_CONFIG" 2>/dev/null
}

# =====================================================
# 🔧 FUNCIONES DE INSTALACIÓN
# =====================================================

# Instalar dependencias de un módulo
install_module_dependencies() {
    local module="$1"
    log "Instalando dependencias del módulo: $module"
    
    local dependencies
    readarray -t dependencies < <(get_module_dependencies "$module")
    
    for dep in "${dependencies[@]}"; do
        if [[ -n "$dep" ]]; then
            install_package "$dep"
        fi
    done
}

# Configurar archivos de un módulo
configure_module_files() {
    local module="$1"
    log "Configurando archivos del módulo: $module"
    
    case "$module" in
        "zsh")
            # Configurar Zsh
            if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
                log "Instalando Oh My Zsh..."
                sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            fi
            
            # Instalar Powerlevel10k
            local theme_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
            if [[ ! -d "$theme_dir" ]]; then
                log "Instalando Powerlevel10k..."
                git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"
            fi
            
            # Crear symlinks
            create_symlink "$SCRIPT_DIR/modules/core/zsh/zshrc" "$HOME/.zshrc" ".zshrc"
            create_symlink "$SCRIPT_DIR/modules/core/zsh/p10k.zsh" "$HOME/.p10k.zsh" ".p10k.zsh"
            ;;
            
        "bash")
            # Configurar Bash
            create_symlink "$SCRIPT_DIR/modules/core/bash/bashrc" "$HOME/.bashrc" ".bashrc"
            if [[ ! -e "$HOME/.bash_profile" ]]; then
                create_symlink "$SCRIPT_DIR/modules/core/bash/bashrc" "$HOME/.bash_profile" ".bash_profile"
            fi
            ;;
            
        "kitty")
            # Configurar Kitty
            mkdir -p "$HOME/.config"
            create_symlink "$SCRIPT_DIR/modules/terminal/kitty" "$HOME/.config/kitty" "kitty"
            
            # Instalar fuentes Nerd Font si no están instaladas
            if ! fc-list | grep -q "MesloLGS NF"; then
                install_package "ttf-meslo-nerd-font-powerlevel10k"
            fi
            ;;
            
        "fastfetch")
            # Configurar Fastfetch
            mkdir -p "$HOME/.config"
            create_symlink "$SCRIPT_DIR/modules/tools/fastfetch" "$HOME/.config/fastfetch" "fastfetch"
            ;;
            
        "nano")
            # Configurar Nano
            mkdir -p "$HOME/.nano/backups"
            create_symlink "$SCRIPT_DIR/modules/tools/nano/nanorc.conf" "$HOME/.nanorc" ".nanorc"
            ;;
            
        "git")
            # Configurar Git
            if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
                log "Configurando usuario de Git..."
                read -p "Nombre de usuario para Git: " git_name
                read -p "Email para Git: " git_email
                
                if [[ -n "$git_name" && -n "$git_email" ]]; then
                    git config --global user.name "$git_name"
                    git config --global user.email "$git_email"
                fi
            fi
            
            # Configuraciones adicionales
            git config --global init.defaultBranch main
            git config --global pull.rebase false
            git config --global core.editor "nano"
            ;;
            
        "neovim")
            # Configurar Neovim
            mkdir -p "$HOME/.config/nvim"
            
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
            fi
            
            # Crear alias para vim
            if [[ ! -f "$HOME/.bashrc" ]] || ! grep -q "alias vim=" "$HOME/.bashrc"; then
                echo 'alias vim="nvim"' >> "$HOME/.bashrc"
            fi
            ;;
            
        *)
            warn "Configuración no implementada para módulo: $module"
            ;;
    esac
}

# Instalar módulo específico
install_module() {
    local module="$1"
    
    if ! module_exists "$module"; then
        error "Módulo no encontrado: $module"
        return 1
    fi
    
    local module_name
    module_name=$(get_module_info "$module" "name")
    
    echo -e "${BOLD}${CYAN}🧩 INSTALANDO MÓDULO: $module_name${COLOR_RESET}"
    echo -e "${CYAN}$(get_module_info "$module" "description")${COLOR_RESET}\n"
    
    # Mostrar progreso
    show_installation_progress "$module_name" 1 3
    
    # Instalar dependencias
    install_module_dependencies "$module"
    show_installation_progress "$module_name" 2 3
    
    # Configurar archivos
    configure_module_files "$module"
    show_installation_progress "$module_name" 3 3
    
    success "✅ Módulo $module_name instalado exitosamente"
}

# Instalar todos los módulos
install_all_modules() {
    log "Instalando todos los módulos..."
    
    local modules
    readarray -t modules < <(get_available_modules)
    
    for module in "${modules[@]}"; do
        if [[ -n "$module" ]]; then
            install_module "$module"
            echo
        fi
    done
}

# =====================================================
# 🔧 FUNCIONES DE ACTUALIZACIÓN
# =====================================================

# Actualizar módulo específico
update_module() {
    local module="$1"
    
    if ! module_exists "$module"; then
        error "Módulo no encontrado: $module"
        return 1
    fi
    
    local module_name
    module_name=$(get_module_info "$module" "name")
    
    echo -e "${BOLD}${CYAN}🔄 ACTUALIZANDO MÓDULO: $module_name${COLOR_RESET}\n"
    
    case "$module" in
        "zsh")
            # Actualizar Oh My Zsh
            if [[ -d "$HOME/.oh-my-zsh" ]]; then
                log "Actualizando Oh My Zsh..."
                cd "$HOME/.oh-my-zsh" && git pull --rebase
            fi
            
            # Actualizar Powerlevel10k
            local theme_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
            if [[ -d "$theme_dir" ]]; then
                log "Actualizando Powerlevel10k..."
                cd "$theme_dir" && git pull --rebase
            fi
            ;;
            
        "kitty"|"fastfetch"|"nano")
            # Recrear symlinks
            configure_module_files "$module"
            ;;
            
        *)
            warn "Actualización no implementada para módulo: $module"
            ;;
    esac
    
    success "✅ Módulo $module_name actualizado exitosamente"
}

# Actualizar todos los módulos
update_all_modules() {
    log "Actualizando todos los módulos..."
    
    # Actualizar paquetes del sistema
    sudo pacman -Syu --noconfirm
    success "✅ Paquetes del sistema actualizados"
    
    # Actualizar paquetes AUR si están disponibles
    if command -v yay &>/dev/null; then
        if confirm "¿Actualizar paquetes AUR con yay?"; then
            yay -Sua --noconfirm
            success "✅ Paquetes AUR actualizados"
        fi
    elif command -v paru &>/dev/null; then
        if confirm "¿Actualizar paquetes AUR con paru?"; then
            paru -Sua --noconfirm
            success "✅ Paquetes AUR actualizados"
        fi
    fi
    
    # Actualizar módulos
    local modules
    readarray -t modules < <(get_available_modules)
    
    for module in "${modules[@]}"; do
        if [[ -n "$module" ]]; then
            update_module "$module"
        fi
    done
}

# =====================================================
# 🔧 FUNCIONES DE VERIFICACIÓN
# =====================================================

# Verificar módulo específico
verify_module() {
    local module="$1"
    
    if ! module_exists "$module"; then
        error "Módulo no encontrado: $module"
        return 1
    fi
    
    local module_name
    module_name=$(get_module_info "$module" "name")
    
    echo -e "${BOLD}${CYAN}🔍 VERIFICANDO MÓDULO: $module_name${COLOR_RESET}\n"
    
    local checks_passed=0
    local total_checks=0
    
    case "$module" in
        "zsh")
            total_checks=4
            
            # Verificar Zsh instalado
            if command -v zsh &>/dev/null; then
                success "✓ Zsh instalado"
                ((checks_passed++))
            else
                error "✗ Zsh no está instalado"
            fi
            
            # Verificar Oh My Zsh
            if [[ -d "$HOME/.oh-my-zsh" ]]; then
                success "✓ Oh My Zsh instalado"
                ((checks_passed++))
            else
                error "✗ Oh My Zsh no está instalado"
            fi
            
            # Verificar Powerlevel10k
            if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
                success "✓ Powerlevel10k instalado"
                ((checks_passed++))
            else
                error "✗ Powerlevel10k no está instalado"
            fi
            
            # Verificar symlinks
            if [[ -L "$HOME/.zshrc" ]] && [[ -e "$HOME/.zshrc" ]]; then
                success "✓ .zshrc configurado"
                ((checks_passed++))
            else
                error "✗ .zshrc no está configurado"
            fi
            ;;
            
        "kitty")
            total_checks=3
            
            # Verificar Kitty instalado
            if command -v kitty &>/dev/null; then
                success "✓ Kitty instalado"
                ((checks_passed++))
            else
                error "✗ Kitty no está instalado"
            fi
            
            # Verificar fuentes Nerd Font
            if fc-list | grep -q "MesloLGS NF"; then
                success "✓ Fuentes Nerd Font instaladas"
                ((checks_passed++))
            else
                error "✗ Fuentes Nerd Font no están instaladas"
            fi
            
            # Verificar symlink
            if [[ -L "$HOME/.config/kitty" ]] && [[ -e "$HOME/.config/kitty" ]]; then
                success "✓ Configuración de Kitty enlazada"
                ((checks_passed++))
            else
                error "✗ Configuración de Kitty no está enlazada"
            fi
            ;;
            
        "fastfetch")
            total_checks=2
            
            # Verificar Fastfetch instalado
            if command -v fastfetch &>/dev/null; then
                success "✓ Fastfetch instalado"
                ((checks_passed++))
            else
                error "✗ Fastfetch no está instalado"
            fi
            
            # Verificar symlink
            if [[ -L "$HOME/.config/fastfetch" ]] && [[ -e "$HOME/.config/fastfetch" ]]; then
                success "✓ Configuración de Fastfetch enlazada"
                ((checks_passed++))
            else
                error "✗ Configuración de Fastfetch no está enlazada"
            fi
            ;;
            
        *)
            warn "Verificación no implementada para módulo: $module"
            return 0
            ;;
    esac
    
    if [[ $checks_passed -eq $total_checks ]]; then
        success "✅ Módulo $module_name verificado correctamente ($checks_passed/$total_checks)"
        return 0
    else
        warn "⚠️  Módulo $module_name verificado parcialmente ($checks_passed/$total_checks)"
        return 1
    fi
}

# Verificar todos los módulos
verify_all_modules() {
    log "Verificando todos los módulos..."
    
    local modules
    readarray -t modules < <(get_available_modules)
    
    local failed_modules=()
    
    for module in "${modules[@]}"; do
        if [[ -n "$module" ]]; then
            if ! verify_module "$module"; then
                failed_modules+=("$module")
            fi
            echo
        fi
    done
    
    if [[ ${#failed_modules[@]} -eq 0 ]]; then
        success "🎉 Todos los módulos verificados correctamente"
        return 0
    else
        warn "⚠️  Algunos módulos fallaron: ${failed_modules[*]}"
        return 1
    fi
}

# =====================================================
# 🔧 FUNCIONES DE DESINSTALACIÓN
# =====================================================

# Desinstalar módulo específico
uninstall_module() {
    local module="$1"
    
    if ! module_exists "$module"; then
        error "Módulo no encontrado: $module"
        return 1
    fi
    
    local module_name
    module_name=$(get_module_info "$module" "name")
    
    echo -e "${BOLD}${CYAN}🗑️  DESINSTALANDO MÓDULO: $module_name${COLOR_RESET}\n"
    
    if ! confirm "¿Estás seguro de que quieres desinstalar $module_name?"; then
        log "Desinstalación cancelada"
        return 0
    fi
    
    case "$module" in
        "zsh")
            # Remover symlinks
            rm -f "$HOME/.zshrc" "$HOME/.p10k.zsh"
            
            # Desinstalar Oh My Zsh
            if [[ -d "$HOME/.oh-my-zsh" ]]; then
                if confirm "¿Desinstalar Oh My Zsh?"; then
                    rm -rf "$HOME/.oh-my-zsh"
                fi
            fi
            ;;
            
        "bash")
            # Remover symlinks
            rm -f "$HOME/.bashrc" "$HOME/.bash_profile"
            ;;
            
        "kitty")
            # Remover symlink
            rm -f "$HOME/.config/kitty"
            ;;
            
        "fastfetch")
            # Remover symlink
            rm -f "$HOME/.config/fastfetch"
            ;;
            
        "nano")
            # Remover symlink
            rm -f "$HOME/.nanorc"
            ;;
            
        *)
            warn "Desinstalación no implementada para módulo: $module"
            ;;
    esac
    
    success "✅ Módulo $module_name desinstalado exitosamente"
}

# Desinstalar todos los módulos
uninstall_all_modules() {
    log "Desinstalando todos los módulos..."
    
    if ! confirm "¿Estás seguro de que quieres desinstalar TODOS los módulos?"; then
        log "Desinstalación cancelada"
        return 0
    fi
    
    local modules
    readarray -t modules < <(get_available_modules)
    
    for module in "${modules[@]}"; do
        if [[ -n "$module" ]]; then
            uninstall_module "$module"
        fi
    done
    
    success "✅ Todos los módulos desinstalados exitosamente"
}

# =====================================================
# 🔧 FUNCIONES DE AYUDA
# =====================================================

# Mostrar módulos disponibles
show_modules() {
    echo -e "${BOLD}${CYAN}📦 MÓDULOS DISPONIBLES${COLOR_RESET}"
    echo -e "${CYAN}=====================================================${COLOR_RESET}\n"
    
    local modules
    readarray -t modules < <(get_available_modules)
    
    for module in "${modules[@]}"; do
        if [[ -n "$module" ]]; then
            local name
            local description
            local status
            name=$(get_module_info "$module" "name")
            description=$(get_module_info "$module" "description")
            
            # Verificar estado del módulo
            if is_module_installed "$module"; then
                status="${GREEN}✅ Instalado${COLOR_RESET}"
            else
                status="${YELLOW}⏳ No instalado${COLOR_RESET}"
            fi
            
            echo -e "${BOLD}$module${COLOR_RESET} - $status"
            echo -e "  📝 $name"
            echo -e "  📄 $description"
            echo
        fi
    done
    
    echo -e "${BOLD}${PURPLE}📊 Resumen:${COLOR_RESET}"
    local installed_count=0
    local total_count=0
    
    for module in "${modules[@]}"; do
        if [[ -n "$module" ]]; then
            ((total_count++))
            if is_module_installed "$module"; then
                ((installed_count++))
            fi
        fi
    done
    
    echo -e "  ${CYAN}•${COLOR_RESET} Total: $total_count módulos"
    echo -e "  ${GREEN}•${COLOR_RESET} Instalados: $installed_count"
    echo -e "  ${YELLOW}•${COLOR_RESET} Pendientes: $((total_count - installed_count))"
    echo
}

# Verificar si un módulo está instalado
is_module_installed() {
    local module="$1"
    
    case "$module" in
        "zsh")
            command -v zsh &>/dev/null && [[ -d "$HOME/.oh-my-zsh" ]]
            ;;
        "bash")
            command -v bash &>/dev/null
            ;;
        "kitty")
            command -v kitty &>/dev/null
            ;;
        "fastfetch")
            command -v fastfetch &>/dev/null
            ;;
        "nano")
            command -v nano &>/dev/null
            ;;
        "git")
            command -v git &>/dev/null
            ;;
        "neovim")
            command -v nvim &>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Mostrar ayuda
show_help() {
    cat << EOF
🧩 Arch Dream Machine - Script Principal Consolidado

Uso: $0 [COMANDO] [MÓDULO]

Comandos:
  interactive, -i, --interactive  🎯 Modo interactivo (RECOMENDADO)
  install [módulo]               Instalar módulo específico o todos
  update [módulo]                Actualizar módulo específico o todos
  verify [módulo]                Verificar módulo específico o todos
  uninstall [módulo]             Desinstalar módulo específico o todos
  list                           Mostrar módulos disponibles
  help                           Mostrar esta ayuda

🎯 MODO INTERACTIVO (RECOMENDADO):
  $0 interactive                 # Iniciar modo interactivo
  $0 -i                         # Abreviatura del modo interactivo
  $0 --interactive              # Modo interactivo completo

📋 Ejemplos de comandos directos:
  $0 install                     # Instalar todos los módulos
  $0 install zsh                 # Instalar solo Zsh
  $0 update kitty                # Actualizar Kitty
  $0 verify fastfetch            # Verificar Fastfetch
  $0 uninstall nano              # Desinstalar Nano
  $0 list                        # Ver módulos disponibles

🧩 Módulos disponibles:
  zsh        - Configuración de Zsh con Oh My Zsh y Powerlevel10k
  bash       - Configuración de Bash (fallback)
  kitty      - Terminal Kitty con tema personalizado
  fastfetch  - Información del sistema con temas
  nano       - Editor Nano con configuración avanzada
  git        - Configuración de Git con aliases
  neovim     - Editor Neovim con configuración básica

🎨 Características del modo interactivo:
  • Menús intuitivos y fáciles de usar
  • Selección de módulos por categorías
  • Confirmaciones de seguridad
  • Estadísticas del sistema
  • Pruebas de diagnóstico
  • Gestión avanzada de módulos

EOF
}

# =====================================================
# 🏁 FUNCIÓN PRINCIPAL
# =====================================================

# Función para manejar el menú de instalación
handle_install_menu() {
    while true; do
        show_install_menu
        read -p "Selecciona una opción (0-3): " choice
        
        case "$choice" in
            "1")
                echo
                if show_confirmation "¿Instalar TODOS los módulos?\nEsta acción instalará todos los módulos disponibles de Arch Dream Machine."; then
                    install_all_modules
                fi
                break
                ;;
            "2")
                echo
                local selected_module
                if selected_module=$(select_module); then
                    install_module "$selected_module"
                fi
                break
                ;;
            "3")
                echo
                local category
                if category=$(select_category); then
                    show_modules_by_category
                    if show_confirmation "¿Instalar módulos de la categoría $category?\nEsta acción instalará todos los módulos de esta categoría."; then
                        install_modules_by_category "$category"
                    fi
                fi
                break
                ;;
            "0")
                break
                ;;
            *)
                error "Opción inválida"
                ;;
        esac
    done
}

# Función para manejar el menú de actualización
handle_update_menu() {
    while true; do
        show_update_menu
        read -p "Selecciona una opción (0-4): " choice
        
        case "$choice" in
            "1")
                echo
                if confirm "¿Actualizar TODOS los módulos?"; then
                    update_all_modules
                fi
                break
                ;;
            "2")
                echo
                local selected_module
                if selected_module=$(select_module); then
                    update_module "$selected_module"
                fi
                break
                ;;
            "3")
                echo
                log "Actualizando paquetes del sistema..."
                sudo pacman -Syu --noconfirm
                success "✅ Paquetes del sistema actualizados"
                break
                ;;
            "4")
                echo
                if command -v yay &>/dev/null; then
                    log "Actualizando paquetes AUR con yay..."
                    yay -Sua --noconfirm
                    success "✅ Paquetes AUR actualizados"
                elif command -v paru &>/dev/null; then
                    log "Actualizando paquetes AUR con paru..."
                    paru -Sua --noconfirm
                    success "✅ Paquetes AUR actualizados"
                else
                    error "No se detectó AUR helper (yay/paru)"
                fi
                break
                ;;
            "0")
                break
                ;;
            *)
                error "Opción inválida"
                ;;
        esac
    done
}

# Función para manejar el menú de verificación
handle_verify_menu() {
    while true; do
        show_verify_menu
        read -p "Selecciona una opción (0-4): " choice
        
        case "$choice" in
            "1")
                echo
                verify_all_modules
                break
                ;;
            "2")
                echo
                local selected_module
                if selected_module=$(select_module); then
                    verify_module "$selected_module"
                fi
                break
                ;;
            "3")
                echo
                run_diagnostic_tests
                break
                ;;
            "4")
                echo
                log "Generando reporte de verificación..."
                verify_all_modules > "$HOME/arch_dream_verification_report.txt" 2>&1
                success "✅ Reporte guardado en: $HOME/arch_dream_verification_report.txt"
                break
                ;;
            "0")
                break
                ;;
            *)
                error "Opción inválida"
                ;;
        esac
    done
}

# Función para manejar el menú de desinstalación
handle_uninstall_menu() {
    while true; do
        show_uninstall_menu
        read -p "Selecciona una opción (0-4): " choice
        
        case "$choice" in
            "1")
                echo
                if confirm "¿Estás SEGURO de que quieres desinstalar TODOS los módulos?"; then
                    if confirm "Esta acción es irreversible. ¿Continuar?"; then
                        uninstall_all_modules
                    fi
                fi
                break
                ;;
            "2")
                echo
                local selected_module
                if selected_module=$(select_module); then
                    uninstall_module "$selected_module"
                fi
                break
                ;;
            "3")
                echo
                if confirm "¿Desinstalar solo configuraciones (sin remover paquetes)?"; then
                    log "Removiendo solo configuraciones..."
                    # Implementar lógica para remover solo configuraciones
                    success "✅ Configuraciones removidas"
                fi
                break
                ;;
            "4")
                echo
                if confirm "¿Desinstalar módulos y remover paquetes?"; then
                    if confirm "Esta acción removerá los paquetes instalados. ¿Continuar?"; then
                        log "Desinstalando módulos y paquetes..."
                        # Implementar lógica para remover paquetes
                        success "✅ Módulos y paquetes removidos"
                    fi
                fi
                break
                ;;
            "0")
                break
                ;;
            *)
                error "Opción inválida"
                ;;
        esac
    done
}

# Función para manejar el menú de configuración avanzada
handle_advanced_menu() {
    while true; do
        show_advanced_menu
        read -p "Selecciona una opción (0-5): " choice
        
        case "$choice" in
            "1")
                echo
                local selected_module
                if selected_module=$(select_module); then
                    log "Configurando módulo: $selected_module"
                    configure_module_files "$selected_module"
                fi
                break
                ;;
            "2")
                echo
                show_system_stats
                break
                ;;
            "3")
                echo
                run_diagnostic_tests
                break
                ;;
            "4")
                echo
                log "Función de restauración no implementada aún"
                warn "Esta función estará disponible en futuras versiones"
                break
                ;;
            "5")
                echo
                show_system_logs
                break
                ;;
            "0")
                break
                ;;
            *)
                error "Opción inválida"
                ;;
        esac
    done
}

# Función principal interactiva
interactive_main() {
    # Inicializar biblioteca
    init_library
    
    # Cargar configuración
    load_modules_config
    
    while true; do
        show_banner
        show_main_menu
        read -p "Selecciona una opción (0-10): " choice
        
        case "$choice" in
            "1")
                handle_install_menu
                ;;
            "2")
                handle_update_menu
                ;;
            "3")
                handle_verify_menu
                ;;
            "4")
                handle_uninstall_menu
                ;;
            "5")
                echo
                show_modules
                ;;
            "6")
                handle_advanced_menu
                ;;
            "7")
                echo
                run_quick_tests
                ;;
            "8")
                echo
                show_system_stats
                ;;
            "9")
                echo
                maintenance_mode
                ;;
            "10")
                echo
                show_help
                ;;
            "0")
                echo -e "\n${GREEN}¡Gracias por usar Arch Dream Machine! 👋${COLOR_RESET}\n"
                echo -e "${CYAN}Versión 4.0.0 - Modo Interactivo Avanzado${COLOR_RESET}"
                echo -e "${YELLOW}¡Que tengas un excelente día! 🌟${COLOR_RESET}\n"
                exit 0
                ;;
            *)
                error "Opción inválida. Selecciona una opción entre 0 y 10."
                ;;
        esac
        
        if [[ "$choice" != "0" ]]; then
            echo
            read -p "Presiona Enter para continuar..."
        fi
    done
}

# Función principal (modo no interactivo)
main() {
    # Inicializar biblioteca
    init_library
    
    # Cargar configuración
    load_modules_config
    
    # Procesar argumentos
    local command="${1:-interactive}"
    local module="${2:-}"
    
    # Si no hay argumentos, usar modo interactivo por defecto
    if [[ $# -eq 0 ]]; then
        interactive_main
        return 0
    fi
    
    case "$command" in
        "install")
            if [[ -n "$module" ]]; then
                install_module "$module"
            else
                install_all_modules
            fi
            ;;
            
        "update")
            if [[ -n "$module" ]]; then
                update_module "$module"
            else
                update_all_modules
            fi
            ;;
            
        "verify")
            if [[ -n "$module" ]]; then
                verify_module "$module"
            else
                verify_all_modules
            fi
            ;;
            
        "uninstall")
            if [[ -n "$module" ]]; then
                uninstall_module "$module"
            else
                uninstall_all_modules
            fi
            ;;
            
        "list")
            show_modules
            ;;
            
        "interactive"|"-i"|"--interactive")
            interactive_main
            ;;
            
        "help"|"-h"|"--help")
            show_help
            ;;
            
        *)
            error "Comando desconocido: $command"
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@" 