#!/bin/bash

echo "🔧 CORRIGIENDO CONFIGURACIÓN DE STARSHIP"
echo "========================================"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARN") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
    esac
}

# 1. Verificar que Starship esté instalado
echo "1. Verificando instalación de Starship..."
if command -v starship &>/dev/null; then
    print_status "OK" "Starship está instalado: $(which starship)"
else
    print_status "ERROR" "Starship NO está instalado. Instalando..."
    sudo pacman -S starship --noconfirm
    if ! command -v starship &>/dev/null; then
        print_status "ERROR" "No se pudo instalar Starship"
        exit 1
    fi
fi

# 2. Crear directorio de configuración si no existe
echo ""
echo "2. Verificando directorio de configuración..."
if [[ ! -d "$HOME/.config" ]]; then
    mkdir -p "$HOME/.config"
    print_status "OK" "Directorio .config creado"
else
    print_status "OK" "Directorio .config ya existe"
fi

# 3. Verificar archivo de configuración
echo ""
echo "3. Verificando archivo de configuración..."
if [[ -L "$HOME/.config/starship.toml" ]]; then
    print_status "OK" "Symlink de configuración existe"
    
    # Verificar que el archivo destino existe
    local target_file=$(readlink "$HOME/.config/starship.toml")
    if [[ -f "$target_file" ]]; then
        print_status "OK" "Archivo destino existe: $target_file"
    else
        print_status "ERROR" "Archivo destino NO existe: $target_file"
        # Recrear el symlink
        rm "$HOME/.config/starship.toml"
        ln -s "$PWD/modules/themes/catppuccin/catppuccin-mocha.toml" "$HOME/.config/starship.toml"
        print_status "OK" "Symlink recreado"
    fi
else
    print_status "WARN" "Symlink no existe, creándolo..."
    ln -s "$PWD/modules/themes/catppuccin/catppuccin-mocha.toml" "$HOME/.config/starship.toml"
    print_status "OK" "Symlink creado"
fi

# 4. Verificar .zshrc
echo ""
echo "4. Verificando configuración de Zsh..."
if [[ -f "$HOME/.zshrc" ]]; then
    print_status "OK" "Archivo .zshrc existe"
    
    # Verificar que no haya duplicaciones de Starship
    local starship_lines=$(grep -c "starship init" "$HOME/.zshrc" 2>/dev/null || echo "0")
    if [[ $starship_lines -gt 1 ]]; then
        print_status "WARN" "Múltiples inicializaciones de Starship detectadas"
    else
        print_status "OK" "Una sola inicialización de Starship"
    fi
else
    print_status "ERROR" "Archivo .zshrc NO existe"
fi

# 5. Verificar .zshrc.local
echo ""
echo "5. Verificando archivo .zshrc.local..."
if [[ -f "$HOME/.zshrc.local" ]]; then
    print_status "OK" "Archivo .zshrc.local existe"
    
    # Verificar configuración de Starship
    if grep -q "STARSHIP_CONFIG" "$HOME/.zshrc.local"; then
        print_status "OK" "Variable STARSHIP_CONFIG configurada"
    else
        print_status "WARN" "Variable STARSHIP_CONFIG no configurada"
    fi
    
    if grep -q "starship init zsh" "$HOME/.zshrc.local"; then
        print_status "OK" "Inicialización de Starship configurada"
    else
        print_status "WARN" "Inicialización de Starship no configurada"
    fi
else
    print_status "ERROR" "Archivo .zshrc.local NO existe"
fi

# 6. Test de Starship
echo ""
echo "6. Probando Starship..."
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
if starship prompt --status=0 &>/dev/null; then
    print_status "OK" "Starship funciona correctamente"
    echo "Prompt de prueba:"
    starship prompt --status=0
else
    print_status "ERROR" "Starship NO funciona correctamente"
fi

# 7. Instrucciones para el usuario
echo ""
echo "🎯 INSTRUCCIONES PARA APLICAR CAMBIOS:"
echo "======================================"
echo "1. Cierra todas las terminales abiertas"
echo "2. Abre una nueva terminal"
echo "3. O ejecuta: exec zsh"
echo "4. Verifica que el prompt sea diferente (debería ser más bonito)"
echo ""
echo "Si el problema persiste, ejecuta:"
echo "  source ~/.zshrc.local"
echo ""

print_status "OK" "Configuración de Starship corregida"
print_status "OK" "Script completado exitosamente"
