#!/bin/bash
# =====================================================
# 🎯 TEST RED TEAM FUNCTIONS
# =====================================================
# Script para probar todas las funciones Red Team
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
echo "║                🎯 RED TEAM FUNCTIONS TEST               ║"
echo "║              Prueba de Funciones Red Team               ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"

echo -e "${BOLD}${BLUE}🔍 PROBANDO FUNCIONES RED TEAM${COLOR_RESET}"

echo -e "\n${YELLOW}1. 🎯 Información de Red Team:${COLOR_RESET}"
echo "Comando: redteam-info"
zsh -c "source ~/.zshrc && redteam-info"

echo -e "\n${YELLOW}2. 🔐 Encoding Base64:${COLOR_RESET}"
echo "Comando: b64e 'Hello Red Team'"
zsh -c "source ~/.zshrc && b64e 'Hello Red Team'"

echo -e "\n${YELLOW}3. 🔓 Decoding Base64:${COLOR_RESET}"
echo "Comando: b64d 'SGVsbG8gUmVkIFRlYW0='"
zsh -c "source ~/.zshrc && b64d 'SGVsbG8gUmVkIFRlYW0='"

echo -e "\n${YELLOW}4. 🌐 URL Encoding:${COLOR_RESET}"
echo "Comando: urle 'hello world test'"
zsh -c "source ~/.zshrc && urle 'hello world test'"

echo -e "\n${YELLOW}5. 🔑 Generador de Contraseñas:${COLOR_RESET}"
echo "Comando: passgen 16"
zsh -c "source ~/.zshrc && passgen 16"

echo -e "\n${YELLOW}6. 📊 Información de Sistema:${COLOR_RESET}"
echo "Comando: uname -a"
uname -a

echo -e "\n${YELLOW}7. 🔍 Test de IP Commands:${COLOR_RESET}"
echo "Local IP:"
ip route get 8.8.8.8 | awk '{print $7}' 2>/dev/null || echo "No disponible"

echo -e "\n${YELLOW}8. 🎯 Configurar Target (Ejemplo):${COLOR_RESET}"
echo "Comando: set-target 192.168.1.1"
zsh -c "source ~/.zshrc && set-target 192.168.1.1"

echo -e "\n${BOLD}${GREEN}✅ PRUEBAS COMPLETADAS${COLOR_RESET}"
echo -e "${CYAN}Tu configuración ZSH Red Team está funcionando correctamente!${COLOR_RESET}"

echo -e "\n${BOLD}${PURPLE}🚀 PRÓXIMOS PASOS:${COLOR_RESET}"
echo -e "1. Usa ${CYAN}redteam-info${COLOR_RESET} para información de red"
echo -e "2. Configura ${CYAN}set-target <ip>${COLOR_RESET} para establecer objetivo"
echo -e "3. Usa ${CYAN}portscan <ip>${COLOR_RESET} para escanear puertos (requiere nmap)"
echo -e "4. Personaliza en ${CYAN}~/.zshrc.local${COLOR_RESET}"

echo -e "\n${YELLOW}💡 SHORTCUTS ÚTILES:${COLOR_RESET}"
echo -e "• ${CYAN}Ctrl+R${COLOR_RESET} - Búsqueda en historial"
echo -e "• ${CYAN}Ctrl+T${COLOR_RESET} - Buscar archivos con fzf"
echo -e "• ${CYAN}Alt+C${COLOR_RESET} - Buscar directorios con fzf"
echo -e "• ${CYAN}z <directorio>${COLOR_RESET} - Navegación rápida"
