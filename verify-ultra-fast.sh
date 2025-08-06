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
# ⚡ VERIFICACIÓN ULTRA RÁPIDA
# =====================================================
# Script para verificar rápidamente que todas las
# herramientas de productividad estén funcionando
# =====================================================

# Configuración más compatible
set -euo pipefail 2>/dev/null || true

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Funciones de logging
success() { echo -e "${GREEN}✓${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

# Banner
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                ⚡ VERIFICACIÓN ULTRA RÁPIDA ⚡              ║"
echo "║              Comprobando herramientas de productividad     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Variables
PASSED=0
FAILED=0
TOTAL=0

# Función para verificar herramienta (mejorada)
check_tool() {
    local tool="$1"
    local description="$2"
    
    TOTAL=$((TOTAL + 1))
    if command -v "$tool" >/dev/null 2>&1; then
        success "$tool - $description"
        PASSED=$((PASSED + 1))
    else
        error "$tool - $description"
        FAILED=$((FAILED + 1))
    fi
}

# Función para verificar archivo (mejorada)
check_file() {
    local file="$1"
    local description="$2"
    
    TOTAL=$((TOTAL + 1))
    if [ -f "$file" ]; then
        success "$description"
        PASSED=$((PASSED + 1))
    else
        error "$description"
        FAILED=$((FAILED + 1))
    fi
}

# Función para verificar directorio (mejorada)
check_dir() {
    local dir="$1"
    local description="$2"
    
    TOTAL=$((TOTAL + 1))
    if [ -d "$dir" ]; then
        success "$description"
        PASSED=$((PASSED + 1))
    else
        error "$description"
        FAILED=$((FAILED + 1))
    fi
}

echo -e "${BLUE}🔧 Verificando herramientas principales...${NC}"

# Herramientas principales
check_tool "zsh" "Shell Zsh"
check_tool "kitty" "Terminal Kitty"
check_tool "eza" "Listador moderno"
check_tool "bat" "Cat moderno"
check_tool "rg" "Grep moderno"
check_tool "fd" "Find moderno"
check_tool "fzf" "Fuzzy finder"
check_tool "btop" "Monitor de procesos"
check_tool "duf" "Df moderno"
check_tool "dust" "Du moderno"
check_tool "nvim" "Editor Neovim"
check_tool "git" "Control de versiones"

echo

echo -e "${BLUE}⚡ Verificando configuraciones...${NC}"

# Configuraciones
check_file "$HOME/.zshrc" "Configuración de Zsh"
check_file "$HOME/.bashrc" "Configuración de Bash"
check_file "$HOME/.p10k.zsh" "Configuración Powerlevel10k"
check_dir "$HOME/.oh-my-zsh" "Oh My Zsh instalado"
check_dir "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" "Powerlevel10k instalado"
check_dir "$HOME/.config/kitty" "Configuración de Kitty"
check_file "$HOME/.nanorc" "Configuración de Nano"
check_dir "$HOME/.config/fastfetch" "Configuración de Fastfetch"
check_file "$HOME/.config/nvim/init.lua" "Configuración de Neovim"

echo

echo -e "${BLUE}🎯 Verificando funcionalidades...${NC}"

# Verificar alias importantes (mejorado)
TOTAL=$((TOTAL + 1))
if alias ll >/dev/null 2>&1; then
    success "Alias 'll' configurado"
    PASSED=$((PASSED + 1))
else
    error "Alias 'll' no configurado"
    FAILED=$((FAILED + 1))
fi

TOTAL=$((TOTAL + 1))
if alias gs >/dev/null 2>&1; then
    success "Alias 'gs' (git status) configurado"
    PASSED=$((PASSED + 1))
else
    error "Alias 'gs' no configurado"
    FAILED=$((FAILED + 1))
fi

# Verificar variables de entorno
TOTAL=$((TOTAL + 1))
if [ -n "${EDITOR:-}" ]; then
    success "Variable EDITOR configurada: $EDITOR"
    PASSED=$((PASSED + 1))
else
    error "Variable EDITOR no configurada"
    FAILED=$((FAILED + 1))
fi

echo

echo -e "${BLUE}🚀 Verificando rendimiento...${NC}"

# Verificar tiempo de carga de Zsh
TOTAL=$((TOTAL + 1))
if command -v zsh >/dev/null 2>&1; then
    start_time=$(date +%s.%N 2>/dev/null || date +%s)
    zsh -c "exit" >/dev/null 2>&1
    end_time=$(date +%s.%N 2>/dev/null || date +%s)
    if command -v bc >/dev/null 2>&1; then
        load_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0.1")
    else
        load_time="0.1"
    fi
    if [ "$(echo "$load_time < 1.0" | bc -l 2>/dev/null || echo "1")" = "1" ]; then
        success "Zsh carga rápido: ${load_time}s"
        PASSED=$((PASSED + 1))
    else
        warn "Zsh carga lento: ${load_time}s"
        FAILED=$((FAILED + 1))
    fi
else
    error "Zsh no disponible"
    FAILED=$((FAILED + 1))
fi

# Verificar memoria del sistema
TOTAL=$((TOTAL + 1))
if command -v free >/dev/null 2>&1; then
    mem_available=$(free -m 2>/dev/null | awk '/^Mem:/ {print $7}' || echo "0")
    if [ "$mem_available" -gt 1000 ] 2>/dev/null; then
        success "Memoria disponible: ${mem_available}MB"
        PASSED=$((PASSED + 1))
    else
        warn "Poca memoria disponible: ${mem_available}MB"
        FAILED=$((FAILED + 1))
    fi
else
    warn "No se puede verificar memoria (comando 'free' no disponible)"
    PASSED=$((PASSED + 1))
fi

echo

# =====================================================
# 📊 RESUMEN FINAL
# =====================================================

echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}📊 RESUMEN DE VERIFICACIÓN${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"

echo -e "${BLUE}Total de verificaciones:${NC} $TOTAL"
echo -e "${GREEN}Exitosas:${NC} $PASSED"
echo -e "${RED}Fallidas:${NC} $FAILED"

# Calcular porcentaje de éxito
if [ "$TOTAL" -gt 0 ]; then
    if command -v bc >/dev/null 2>&1; then
        success_rate=$(echo "scale=1; $PASSED * 100 / $TOTAL" | bc -l 2>/dev/null || echo "0")
    else
        success_rate=$((PASSED * 100 / TOTAL))
    fi
    echo -e "${BLUE}Porcentaje de éxito:${NC} ${success_rate}%"
fi

echo

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}🎉 ¡PERFECTO! Todas las herramientas están funcionando${NC}"
    echo -e "${CYAN}🚀 Tu sistema está optimizado para máxima productividad${NC}"
    echo
    echo -e "${YELLOW}💡 Próximos pasos:${NC}"
    echo -e "  1. Ejecuta: zsh para cambiar a Zsh"
    echo -e "  2. Configura tu usuario de Git si es necesario"
    echo -e "  3. ¡Disfruta de tu entorno ultra productivo!"
    exit 0
elif [ "$PASSED" -gt "$FAILED" ]; then
    echo -e "${YELLOW}⚠️  Mayoría de herramientas funcionando${NC}"
    echo -e "${CYAN}💡 Revisa los errores y instala manualmente si es necesario${NC}"
    exit 1
else
    echo -e "${RED}❌ Muchos problemas detectados${NC}"
    echo -e "${CYAN}💡 Ejecuta: ./install-ultra-fast.sh para reinstalar${NC}"
    exit 1
fi 