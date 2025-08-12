#!/bin/bash
# =====================================================
# 🎯 VERIFICADOR ZSH RED TEAM CONFIGURATION
# =====================================================
# Script para verificar la instalación y configuración
# de ZSH optimizado para Red Team
# =====================================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
COLOR_RESET='\033[0m'

# Banner
echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                🎯 ZSH RED TEAM VERIFIER                 ║"
echo "║            Verificación de Configuración                ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"

# Contadores
checks_passed=0
total_checks=0

# Función para verificaciones
check() {
    local description="$1"
    local command="$2"
    local optional="${3:-false}"
    
    ((total_checks++))
    echo -n "🔍 Verificando $description... "
    
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✅ OK${COLOR_RESET}"
        ((checks_passed++))
        return 0
    else
        if [[ "$optional" == "true" ]]; then
            echo -e "${YELLOW}⚠️  OPCIONAL${COLOR_RESET}"
            ((checks_passed++))
        else
            echo -e "${RED}❌ FALLO${COLOR_RESET}"
        fi
        return 1
    fi
}

echo -e "${BOLD}${BLUE}🔧 VERIFICACIONES BÁSICAS${COLOR_RESET}"

# Verificaciones básicas
check "ZSH instalado" "command -v zsh"
check "Starship instalado" "command -v starship"
check "Git instalado" "command -v git"
check "Curl instalado" "command -v curl"

echo
echo -e "${BOLD}${PURPLE}📁 VERIFICACIONES DE ARCHIVOS${COLOR_RESET}"

# Verificaciones de archivos
check "Archivo .zshrc" "[ -f ~/.zshrc ]"
check "Configuración Starship" "[ -f ~/.config/starship.toml ]"
check "Directorio Zinit" "[ -d ~/.local/share/zinit/zinit.git ]"
check "Caché ZSH" "[ -d ~/.zsh ]"
check "Archivo local ZSH" "[ -f ~/.zshrc.local ]"

echo
echo -e "${BOLD}${GREEN}🛠️  VERIFICACIONES DE HERRAMIENTAS${COLOR_RESET}"

# Herramientas modernas (opcionales)
check "bat (better cat)" "command -v bat" true
check "eza (better ls)" "command -v eza" true
check "ripgrep (better grep)" "command -v rg" true
check "fd (better find)" "command -v fd" true
check "fzf (fuzzy finder)" "command -v fzf" true
check "btop (better top)" "command -v btop" true

echo
echo -e "${BOLD}${CYAN}🎯 VERIFICACIONES RED TEAM${COLOR_RESET}"

# Herramientas Red Team (opcionales)
check "nmap" "command -v nmap" true
check "gobuster" "command -v gobuster" true
check "dirb" "command -v dirb" true
check "nikto" "command -v nikto" true

echo
echo -e "${BOLD}${YELLOW}📊 RESUMEN DE VERIFICACIÓN${COLOR_RESET}"

# Mostrar resumen
percentage=$((checks_passed * 100 / total_checks))
echo -e "Verificaciones completadas: ${GREEN}$checks_passed${COLOR_RESET}/${total_checks}"
echo -e "Porcentaje de éxito: ${GREEN}$percentage%${COLOR_RESET}"

if [[ $percentage -ge 80 ]]; then
    echo -e "\n${BOLD}${GREEN}🎉 ¡CONFIGURACIÓN ZSH RED TEAM EXITOSA!${COLOR_RESET}"
    echo -e "${CYAN}Tu entorno está listo para Red Team operations.${COLOR_RESET}"
elif [[ $percentage -ge 60 ]]; then
    echo -e "\n${BOLD}${YELLOW}⚠️  CONFIGURACIÓN PARCIAL${COLOR_RESET}"
    echo -e "${YELLOW}La configuración básica está lista, algunas herramientas opcionales faltan.${COLOR_RESET}"
else
    echo -e "\n${BOLD}${RED}❌ CONFIGURACIÓN INCOMPLETA${COLOR_RESET}"
    echo -e "${RED}Hay problemas importantes que necesitan ser resueltos.${COLOR_RESET}"
fi

echo
echo -e "${BOLD}${BLUE}🚀 PRÓXIMOS PASOS${COLOR_RESET}"
echo -e "1. Ejecuta: ${CYAN}exec zsh${COLOR_RESET} o reinicia tu terminal"
echo -e "2. Prueba: ${CYAN}redteam-info${COLOR_RESET} para ver información de red"
echo -e "3. Configura: ${CYAN}set-target <ip>${COLOR_RESET} para establecer objetivo"
echo -e "4. Personaliza: ${CYAN}~/.zshrc.local${COLOR_RESET} para configuraciones locales"

echo
echo -e "${BOLD}${PURPLE}💡 COMANDOS ÚTILES RED TEAM${COLOR_RESET}"
echo -e "• ${CYAN}portscan <ip>${COLOR_RESET} - Escaneo rápido de puertos"
echo -e "• ${CYAN}direnum <url>${COLOR_RESET} - Enumeración de directorios"
echo -e "• ${CYAN}b64e/b64d${COLOR_RESET} - Codificar/decodificar base64"
echo -e "• ${CYAN}passgen${COLOR_RESET} - Generar contraseñas"

exit 0
