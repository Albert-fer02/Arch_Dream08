#!/bin/bash
# =====================================================
# 🎯 FINALIZADOR ZSH RED TEAM
# =====================================================
# Script para limpiar y finalizar la configuración
# =====================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
COLOR_RESET='\033[0m'

echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║            🎯 ZSH RED TEAM FINALIZER                    ║"
echo "║          Limpieza y Verificación Final                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"

echo -e "${BOLD}${BLUE}🧹 LIMPIANDO CONFIGURACIÓN${COLOR_RESET}"

# Limpiar archivos problemáticos
echo "Eliminando archivos problemáticos de fzf..."
rm -f ~/.fzf.zsh
rm -rf ~/.fzf/

# Limpiar caché de Zinit
echo "Limpiando caché de Zinit..."
rm -rf ~/.local/share/zinit/.zinit/

# Limpiar caché de ZSH
echo "Limpiando caché de ZSH..."
rm -rf ~/.zsh/compdump/*

echo -e "\n${BOLD}${GREEN}✅ VERIFICACIÓN FINAL${COLOR_RESET}"

# Verificar instalación
echo "🔍 Verificando ZSH..."
if command -v zsh &>/dev/null; then
    echo -e "${GREEN}✓ ZSH instalado: $(zsh --version)${COLOR_RESET}"
else
    echo -e "${RED}✗ ZSH no encontrado${COLOR_RESET}"
fi

echo "🔍 Verificando Starship..."
if command -v starship &>/dev/null; then
    echo -e "${GREEN}✓ Starship instalado: $(starship --version)${COLOR_RESET}"
else
    echo -e "${RED}✗ Starship no encontrado${COLOR_RESET}"
fi

echo "🔍 Verificando Zinit..."
if [[ -d ~/.local/share/zinit/zinit.git ]]; then
    echo -e "${GREEN}✓ Zinit instalado${COLOR_RESET}"
else
    echo -e "${RED}✗ Zinit no encontrado${COLOR_RESET}"
fi

echo "🔍 Verificando archivos de configuración..."
if [[ -f ~/.zshrc ]]; then
    echo -e "${GREEN}✓ .zshrc configurado${COLOR_RESET}"
else
    echo -e "${RED}✗ .zshrc no encontrado${COLOR_RESET}"
fi

if [[ -f ~/.config/starship.toml ]]; then
    echo -e "${GREEN}✓ starship.toml configurado${COLOR_RESET}"
else
    echo -e "${RED}✗ starship.toml no encontrado${COLOR_RESET}"
fi

echo -e "\n${BOLD}${PURPLE}🎯 CONFIGURACIÓN FINAL COMPLETADA${COLOR_RESET}"

echo -e "\n${YELLOW}💡 Para aplicar los cambios ejecuta:${COLOR_RESET}"
echo -e "${CYAN}exec zsh${COLOR_RESET}"

echo -e "\n${YELLOW}🚀 Funciones Red Team disponibles:${COLOR_RESET}"
echo -e "• ${CYAN}redteam-info${COLOR_RESET} - Información de red"
echo -e "• ${CYAN}set-target <ip>${COLOR_RESET} - Configurar objetivo"
echo -e "• ${CYAN}b64e/b64d${COLOR_RESET} - Encoding/decoding base64"
echo -e "• ${CYAN}urle/urld${COLOR_RESET} - Encoding/decoding URL"
echo -e "• ${CYAN}passgen${COLOR_RESET} - Generar contraseñas"

echo -e "\n${BOLD}${GREEN}🎉 ¡ZSH RED TEAM LISTO PARA USAR!${COLOR_RESET}"
