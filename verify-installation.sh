#!/bin/bash
# =====================================================
# 🔍 VERIFICADOR DE INSTALACIÓN - ARCH DREAM MACHINE
# =====================================================
# Script para verificar que todas las configuraciones
# se aplicaron correctamente en ~/.config
# =====================================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Función para mostrar resultados
show_result() {
    local status="$1"
    local message="$2"
    local details="$3"
    
    if [[ "$status" == "OK" ]]; then
        echo -e "${GREEN}✅ $message${NC}"
        [[ -n "$details" ]] && echo -e "   ${CYAN}$details${NC}"
    elif [[ "$status" == "WARN" ]]; then
        echo -e "${YELLOW}⚠️  $message${NC}"
        [[ -n "$details" ]] && echo -e "   ${CYAN}$details${NC}"
    else
        echo -e "${RED}❌ $message${NC}"
        [[ -n "$details" ]] && echo -e "   ${CYAN}$details${NC}"
    fi
}

# Función para verificar directorio
check_directory() {
    local dir="$1"
    local name="$2"
    
    if [[ -d "$dir" ]]; then
        if [[ -L "$dir" ]]; then
            local target=$(readlink -f "$dir" 2>/dev/null || true)
            if [[ -n "$target" && "$target" == *"/.mydotfiles/"* ]]; then
                show_result "WARN" "$name: Es un symlink al sistema anterior" "Apuntando a: $target"
                return 1
            else
                show_result "OK" "$name: Directorio symlink válido" "Apuntando a: $target"
                return 0
            fi
        else
            show_result "OK" "$name: Directorio real creado correctamente" "Ubicación: $dir"
            return 0
        fi
    else
        show_result "ERROR" "$name: No existe" "Ruta: $dir"
        return 1
    fi
}

# Función para verificar archivo
check_file() {
    local file="$1"
    local name="$2"
    
    if [[ -f "$file" ]]; then
        if [[ -L "$file" ]]; then
            local target=$(readlink -f "$file" 2>/dev/null || true)
            show_result "OK" "$name: Symlink creado correctamente" "Apuntando a: $target"
        else
            show_result "OK" "$name: Archivo creado correctamente" "Ubicación: $file"
        fi
        return 0
    else
        show_result "ERROR" "$name: No existe" "Ruta: $file"
        return 1
    fi
}

# Función para verificar configuración de shell
check_shell_config() {
    local config="$1"
    local name="$2"
    
    if [[ -f "$config" ]]; then
        if [[ -L "$config" ]]; then
            local target=$(readlink -f "$config" 2>/dev/null || true)
            show_result "OK" "$name: Symlink creado correctamente" "Apuntando a: $target"
        else
            show_result "OK" "$name: Archivo creado correctamente" "Ubicación: $config"
        fi
        return 0
    else
        show_result "ERROR" "$name: No existe" "Ruta: $config"
        return 1
    fi
}

# Función principal de verificación
main() {
    echo -e "${BOLD}${BLUE}🔍 VERIFICANDO INSTALACIÓN DE ARCH DREAM MACHINE${NC}"
    echo -e "${CYAN}Verificando configuraciones en ~/.config${NC}\n"
    
    local total_checks=0
    local passed_checks=0
    local failed_checks=0
    
    # Verificar directorios principales
    echo -e "${BOLD}📁 DIRECTORIOS DE CONFIGURACIÓN:${NC}"
    
    # Kitty
    if check_directory "$HOME/.config/kitty" "Kitty Terminal"; then
        ((++passed_checks))
    else
        ((++failed_checks))
    fi
    ((++total_checks))
    
    # Neovim
    if check_directory "$HOME/.config/nvim" "Neovim"; then
        ((++passed_checks))
    else
        ((++failed_checks))
    fi
    ((++total_checks))
    
    # Fastfetch
    if check_directory "$HOME/.config/fastfetch" "Fastfetch"; then
        ((++passed_checks))
    else
        ((++failed_checks))
    fi
    ((++total_checks))
    
    # Nano
    if check_directory "$HOME/.config/nano" "Nano"; then
        ((++passed_checks))
    else
        ((++failed_checks))
    fi
    ((++total_checks))
    
    echo
    
    # Verificar archivos de configuración específicos
    echo -e "${BOLD}📄 ARCHIVOS DE CONFIGURACIÓN:${NC}"
    
    # Kitty config
    if check_file "$HOME/.config/kitty/kitty.conf" "Kitty config"; then
        ((++passed_checks))
    else
        ((++failed_checks))
    fi
    ((++total_checks))
    
    # Neovim init
    if check_file "$HOME/.config/nvim/init.lua" "Neovim init.lua"; then
        ((++passed_checks))
    else
        ((++failed_checks))
    fi
    ((++total_checks))
    
    # Fastfetch config
    if check_file "$HOME/.config/fastfetch/config.jsonc" "Fastfetch config"; then
        ((++passed_checks))
    else
        ((++failed_checks))
    fi
    ((++total_checks))
    
    # Starship config
    if check_file "$HOME/.config/starship.toml" "Starship config"; then
        ((++passed_checks))
    else
        ((++failed_checks))
    fi
    ((++total_checks))
    
    echo
    
    # Verificar configuraciones de shell
    echo -e "${BOLD}🐚 CONFIGURACIONES DE SHELL:${NC}"
    
    # Zsh
    if check_shell_config "$HOME/.zshrc" "Zsh config"; then
        ((++passed_checks))
    else
        ((++failed_checks))
    fi
    ((++total_checks))
    
    # Bash
    if check_shell_config "$HOME/.bashrc" "Bash config"; then
        ((++passed_checks))
    else
        ((++failed_checks))
    fi
    ((++total_checks))
    
    echo
    
    # Verificar imágenes de Fastfetch
    echo -e "${BOLD}🖼️  RECURSOS ADICIONALES:${NC}"
    
    local image_count=$(ls "$HOME/.config/fastfetch"/*.jpg 2>/dev/null | wc -l)
    if [[ $image_count -gt 0 ]]; then
        show_result "OK" "Imágenes de Fastfetch: $image_count imágenes encontradas" "Ubicación: ~/.config/fastfetch/"
        ((++passed_checks))
    else
        show_result "ERROR" "Imágenes de Fastfetch: No se encontraron imágenes" "Ubicación: ~/.config/fastfetch/"
        ((++failed_checks))
    fi
    ((++total_checks))
    
    echo
    
    # Resumen final
    echo -e "${BOLD}${BLUE}📊 RESUMEN DE VERIFICACIÓN:${NC}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} Total de verificaciones: $total_checks"
    echo -e "${CYAN}│${NC} ✅ Exitosas: ${GREEN}$passed_checks${NC}"
    echo -e "${CYAN}│${NC} ❌ Fallidas: ${RED}$failed_checks${NC}"
    echo -e "${CYAN}│${NC} Porcentaje de éxito: $((passed_checks * 100 / total_checks))%"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
    
    if [[ $failed_checks -eq 0 ]]; then
        echo -e "\n${BOLD}${GREEN}🎉 ¡TODAS LAS CONFIGURACIONES SE APLICARON CORRECTAMENTE!${NC}"
        echo -e "${CYAN}💡 Las configuraciones están funcionando en: ~/.config${NC}"
        return 0
    else
        echo -e "\n${BOLD}${YELLOW}⚠️  ALGUNAS CONFIGURACIONES NO SE APLICARON CORRECTAMENTE${NC}"
        echo -e "${CYAN}📋 Revisa los errores arriba y ejecuta la instalación nuevamente${NC}"
        return 1
    fi
}

# Ejecutar verificación
main "$@"
