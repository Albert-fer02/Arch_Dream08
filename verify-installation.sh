#!/bin/bash
# =====================================================
# 🔍 VERIFICACIÓN FINAL DE INSTALACIÓN
# =====================================================
# Script para verificar que todas las configuraciones
# se hayan instalado correctamente
# =====================================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Función para mostrar resultados
show_result() {
    local status="$1"
    local message="$2"
    
    if [[ "$status" == "OK" ]]; then
        echo -e "${GREEN}✅ $message${NC}"
    elif [[ "$status" == "WARN" ]]; then
        echo -e "${YELLOW}⚠️  $message${NC}"
    else
        echo -e "${RED}❌ $message${NC}"
    fi
}

# Función para verificar archivo/directorio
check_path() {
    local path="$1"
    local description="$2"
    
    if [[ -e "$path" ]]; then
        show_result "OK" "$description: $path"
        return 0
    else
        show_result "ERROR" "$description: $path (NO ENCONTRADO)"
        return 1
    fi
}

# Función para verificar comando
check_command() {
    local command="$1"
    local description="$2"
    
    if command -v "$command" &>/dev/null; then
        show_result "OK" "$description: $command"
        return 0
    else
        show_result "ERROR" "$description: $command (NO ENCONTRADO)"
        return 1
    fi
}

# Función para verificar symlink
check_symlink() {
    local path="$1"
    local description="$2"
    
    if [[ -L "$path" ]] && [[ -e "$path" ]]; then
        show_result "OK" "$description: $path"
        return 0
    else
        show_result "ERROR" "$description: $path (SYMLINK ROTO O NO EXISTE)"
        return 1
    fi
}

echo -e "${BLUE}🔍 VERIFICANDO INSTALACIÓN DE ARCH DREAM MACHINE${NC}"
echo -e "${CYAN}=====================================================${NC}"
echo

# Contadores
total_checks=0
passed_checks=0
failed_checks=0

# Verificar directorios de configuración
echo -e "${YELLOW}📁 DIRECTORIOS DE CONFIGURACIÓN:${NC}"
echo "----------------------------------------"

check_path "/home/dreamcoder08/.config/arch-dream" "Directorio principal de Arch Dream" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_path "/home/dreamcoder08/.config/kitty" "Directorio de configuración de Kitty" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_path "/home/dreamcoder08/.config/fastfetch" "Directorio de configuración de Fastfetch" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_path "/home/dreamcoder08/.config/nano" "Directorio de configuración de Nano" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_path "/home/dreamcoder08/.config/nvim" "Directorio de configuración de Neovim" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

echo

# Verificar archivos de configuración
echo -e "${YELLOW}📄 ARCHIVOS DE CONFIGURACIÓN:${NC}"
echo "----------------------------------------"

check_symlink "/home/dreamcoder08/.config/kitty/kitty.conf" "Configuración principal de Kitty" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_symlink "/home/dreamcoder08/.config/kitty/colors-dreamcoder.conf" "Tema de colores de Kitty" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_symlink "/home/dreamcoder08/.config/fastfetch/config.jsonc" "Configuración de Fastfetch" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_symlink "/home/dreamcoder08/.config/nano/nanorc" "Configuración de Nano" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_symlink "/home/dreamcoder08/.config/nvim/init.lua" "Configuración principal de Neovim" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_symlink "/home/dreamcoder08/.config/starship.toml" "Tema de Starship" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

echo

# Verificar comandos
echo -e "${YELLOW}⚡ COMANDOS INSTALADOS:${NC}"
echo "----------------------------------------"

check_command "fastfetch" "Fastfetch" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_command "nano" "Nano Editor" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_command "kitty" "Kitty Terminal" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_command "nvim" "Neovim" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

echo

# Verificar scripts de utilidades
echo -e "${YELLOW}🛠️  SCRIPTS DE UTILIDADES:${NC}"
echo "----------------------------------------"

check_path "/home/dreamcoder08/.local/bin/fastfetch-random" "Wrapper de Fastfetch" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_path "/home/dreamcoder08/.local/bin/nano-config" "Configurador de Nano" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_path "/home/dreamcoder08/.local/bin/clean-kitty-cache" "Limpieza de caché de Kitty" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_path "/home/dreamcoder08/.local/bin/catppuccin-switch" "Cambiador de temas Catppuccin" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

echo

# Verificar módulos instalados
echo -e "${YELLOW}🧩 MÓDULOS INSTALADOS:${NC}"
echo "----------------------------------------"

check_path "/home/dreamcoder08/.config/arch-dream/installed/core:zsh" "Módulo core:zsh" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_path "/home/dreamcoder08/.config/arch-dream/installed/development:nvim" "Módulo development:nvim" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_path "/home/dreamcoder08/.config/arch-dream/installed/terminal:kitty" "Módulo terminal:kitty" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_path "/home/dreamcoder08/.config/arch-dream/installed/themes:catppuccin" "Módulo themes:catppuccin" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_path "/home/dreamcoder08/.config/arch-dream/installed/tools:fastfetch" "Módulo tools:fastfetch" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

check_path "/home/dreamcoder08/.config/arch-dream/installed/tools:nano" "Módulo tools:nano" && ((++passed_checks)) || ((++failed_checks))
((++total_checks))

echo

# Verificar imágenes de Fastfetch
echo -e "${YELLOW}🖼️  IMÁGENES DE FASTFETCH:${NC}"
echo "----------------------------------------"

image_count=$(ls /home/dreamcoder08/.config/fastfetch/*.jpg 2>/dev/null | wc -l)
if [[ $image_count -gt 0 ]]; then
    show_result "OK" "Imágenes de Fastfetch: $image_count imágenes encontradas"
    ((++passed_checks))
else
    show_result "WARN" "Imágenes de Fastfetch: No se encontraron imágenes"
    ((++failed_checks))
fi
((++total_checks))

echo

# Resumen final
echo -e "${BLUE}📊 RESUMEN DE VERIFICACIÓN:${NC}"
echo -e "${CYAN}=====================================================${NC}"
echo -e "Total de verificaciones: ${total_checks}"
echo -e "✅ Exitosas: ${GREEN}${passed_checks}${NC}"
echo -e "❌ Fallidas: ${RED}${failed_checks}${NC}"

if [[ $failed_checks -eq 0 ]]; then
    echo
    echo -e "${GREEN}🎉 ¡TODAS LAS VERIFICACIONES PASARON EXITOSAMENTE!${NC}"
    echo -e "${CYAN}🚀 Arch Dream Machine está completamente instalado y configurado.${NC}"
    echo
    echo -e "${YELLOW}💡 Próximos pasos:${NC}"
    echo -e "  1. Reinicia tu terminal: ${CYAN}exec \$SHELL${NC}"
    echo -e "  2. Prueba los comandos: ${CYAN}fastfetch${NC}, ${CYAN}kitty${NC}, ${CYAN}nvim${NC}"
    echo -e "  3. Cambia temas: ${CYAN}catppuccin-switch mocha${NC} o ${CYAN}catppuccin-switch latte${NC}"
    echo -e "  4. Personaliza configuraciones en ${CYAN}~/.config/${NC}"
    exit 0
else
    echo
    echo -e "${YELLOW}⚠️  ALGUNAS VERIFICACIONES FALLARON${NC}"
    echo -e "${CYAN}📋 Revisa los errores arriba y ejecuta el instalador nuevamente si es necesario.${NC}"
    exit 1
fi
