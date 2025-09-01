#!/bin/bash
# =====================================================
# 🧪 SCRIPT DE PRUEBA DE INTEGRACIÓN ROOT
# =====================================================
# Script para probar la integración de la configuración
# root con el proyecto Arch Dream sin requerir sudo
# =====================================================

set -euo pipefail

# Variables del proyecto
ARCH_DREAM_ROOT="/home/dreamcoder08/Documentos/PROYECTOS/Arch_Dream08"
ROOT_CONFIG="$ARCH_DREAM_ROOT/modules/core/zsh/root/.zshrc"
AUTO_APPLY_SCRIPT="$ARCH_DREAM_ROOT/modules/core/zsh/auto-apply-root.sh"

echo "🧪 PROBANDO INTEGRACIÓN ROOT CON ARCH DREAM"
echo "=============================================="

# Test 1: Verificar estructura del proyecto
echo
echo "📁 Test 1: Estructura del proyecto"
echo "-----------------------------------"

if [[ -d "$ARCH_DREAM_ROOT" ]]; then
    echo "✅ Directorio principal: $ARCH_DREAM_ROOT"
else
    echo "❌ Directorio principal no encontrado"
    exit 1
fi

if [[ -f "$ARCH_DREAM_ROOT/arch-dream" ]]; then
    echo "✅ CLI principal encontrado"
else
    echo "❌ CLI principal no encontrado"
fi

if [[ -f "$ARCH_DREAM_ROOT/install.sh" ]]; then
    echo "✅ Instalador principal encontrado"
else
    echo "❌ Instalador principal no encontrado"
fi

# Test 2: Verificar configuración root
echo
echo "⚙️  Test 2: Configuración root"
echo "------------------------------"

if [[ -f "$ROOT_CONFIG" ]]; then
    echo "✅ Archivo de configuración root encontrado"
    
    # Verificar sintaxis
    if zsh -n "$ROOT_CONFIG" 2>/dev/null; then
        echo "✅ Sintaxis de configuración válida"
    else
        echo "❌ Error de sintaxis en configuración"
    fi
    
    # Verificar variables importantes
    if grep -q "ARCH_DREAM_ROOT=" "$ROOT_CONFIG"; then
        echo "✅ Variables de Arch Dream configuradas"
    else
        echo "❌ Variables de Arch Dream no encontradas"
    fi
    
    # Verificar funciones específicas
    if grep -q "arch-dream()" "$ROOT_CONFIG"; then
        echo "✅ Función arch-dream() implementada"
    else
        echo "❌ Función arch-dream() no encontrada"
    fi
    
    if grep -q "cd-arch-dream()" "$ROOT_CONFIG"; then
        echo "✅ Función cd-arch-dream() implementada"
    else
        echo "❌ Función cd-arch-dream() no encontrada"
    fi
else
    echo "❌ Archivo de configuración root no encontrado"
fi

# Test 3: Script de auto-aplicación
echo
echo "🔄 Test 3: Script de auto-aplicación"
echo "------------------------------------"

if [[ -f "$AUTO_APPLY_SCRIPT" ]]; then
    echo "✅ Script de auto-aplicación encontrado"
    
    if [[ -x "$AUTO_APPLY_SCRIPT" ]]; then
        echo "✅ Script es ejecutable"
        
        # Probar verificación
        echo "🔍 Ejecutando verificación..."
        if "$AUTO_APPLY_SCRIPT" verify; then
            echo "✅ Verificación exitosa"
        else
            echo "❌ Error en verificación"
        fi
        
        # Probar status
        echo "📊 Ejecutando status..."
        "$AUTO_APPLY_SCRIPT" status
        
    else
        echo "❌ Script no es ejecutable"
    fi
else
    echo "❌ Script de auto-aplicación no encontrado"
fi

# Test 4: Integración con configuración principal
echo
echo "🔗 Test 4: Integración con configuración principal"
echo "--------------------------------------------------"

MAIN_ZSH_CONFIG="$ARCH_DREAM_ROOT/modules/core/zsh/.zshrc"
if [[ -f "$MAIN_ZSH_CONFIG" ]]; then
    if grep -q "auto-apply-root.sh" "$MAIN_ZSH_CONFIG"; then
        echo "✅ Integración con configuración principal detectada"
    else
        echo "❌ Integración con configuración principal no encontrada"
    fi
else
    echo "❌ Configuración principal no encontrada"
fi

# Test 5: Verificar aliases y funciones específicas
echo
echo "🔧 Test 5: Aliases y funciones específicas"
echo "------------------------------------------"

# Verificar aliases de Arch Dream
aliases_found=0
for alias in "ad=" "ad-status=" "ad-doctor=" "cd-ad=" "ls-ad="; do
    if grep -q "$alias" "$ROOT_CONFIG"; then
        echo "✅ Alias $alias encontrado"
        aliases_found=$((aliases_found + 1))
    else
        echo "❌ Alias $alias no encontrado"
    fi
done

if [[ $aliases_found -eq 5 ]]; then
    echo "✅ Todos los aliases específicos implementados"
else
    echo "⚠️  Solo $aliases_found/5 aliases encontrados"
fi

# Resumen final
echo
echo "📋 RESUMEN DE PRUEBAS"
echo "====================="

total_tests=5
passed_tests=0

# Contar tests pasados (simplificado)
if [[ -d "$ARCH_DREAM_ROOT" ]]; then
    passed_tests=$((passed_tests + 1))
fi

if [[ -f "$ROOT_CONFIG" ]] && zsh -n "$ROOT_CONFIG" 2>/dev/null; then
    passed_tests=$((passed_tests + 1))
fi

if [[ -x "$AUTO_APPLY_SCRIPT" ]]; then
    passed_tests=$((passed_tests + 1))
fi

if [[ -f "$MAIN_ZSH_CONFIG" ]] && grep -q "auto-apply-root.sh" "$MAIN_ZSH_CONFIG"; then
    passed_tests=$((passed_tests + 1))
fi

if [[ $aliases_found -ge 4 ]]; then
    passed_tests=$((passed_tests + 1))
fi

echo "Tests pasados: $passed_tests/$total_tests"

if [[ $passed_tests -eq $total_tests ]]; then
    echo "🎉 ¡TODAS LAS PRUEBAS PASARON!"
    echo "La integración root está lista para usar"
    exit 0
else
    echo "⚠️  Algunas pruebas fallaron"
    echo "Revisa los errores arriba antes de usar en producción"
    exit 1
fi