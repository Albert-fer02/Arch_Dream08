#!/bin/bash
# =====================================================
# 🔴 Actualizador de BASH Root a Modular - Arch Dream
# =====================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para hacer backup del bashrc.root original
backup_original() {
    if [[ -f "bashrc.root" ]]; then
        local backup_file="bashrc.root.backup.$(date +%Y%m%d_%H%M%S)"
        print_status "Haciendo backup del bashrc.root original..."
        cp bashrc.root "$backup_file"
        print_success "Backup creado: $backup_file"
    else
        print_error "bashrc.root no encontrado en el directorio actual"
        exit 1
    fi
}

# Función para reemplazar con la versión modular
replace_with_modular() {
    print_status "Reemplazando bashrc.root con versión modular..."
    
    # Hacer backup primero
    backup_original
    
    # Reemplazar con la versión modular
    cp bashrc.root.modular bashrc.root
    chmod +x bashrc.root
    
    print_success "bashrc.root actualizado a versión modular"
}

# Función para verificar la nueva configuración
verify_configuration() {
    print_status "Verificando nueva configuración..."
    
    if bash -n bashrc.root; then
        print_success "Configuración sintácticamente correcta"
    else
        print_error "Error de sintaxis en la nueva configuración"
        return 1
    fi
}

# Función para mostrar diferencias
show_differences() {
    local backup_file=$(ls -t bashrc.root.backup.* | head -1)
    
    if [[ -n "$backup_file" ]]; then
        print_status "Mostrando diferencias principales:"
        echo "=========================================="
        echo "🔴 VERSIÓN ORIGINAL: 153 líneas"
        echo "🚀 VERSIÓN MODULAR:  ~180 líneas"
        echo "📁 BASE COMPARTIDA: bashrc.modular"
        echo "🔧 PERSONALIZACIONES: Root-specific"
        echo "=========================================="
        
        print_status "Para ver diferencias detalladas:"
        echo "diff bashrc.root $backup_file"
    fi
}

# Función para mostrar información de uso
show_usage() {
    echo -e "${BLUE}Uso:${NC}"
    echo "  $0 [opciones]"
    echo ""
    echo -e "${BLUE}Opciones:${NC}"
    echo "  -h, --help     Mostrar esta ayuda"
    echo "  -d, --diff     Mostrar diferencias después de actualizar"
    echo "  -t, --test     Solo probar la nueva configuración"
    echo ""
    echo -e "${BLUE}Ejemplos:${NC}"
    echo "  $0              # Actualización completa"
    echo "  $0 --diff       # Actualizar y mostrar diferencias"
    echo "  $0 --test       # Solo probar"
}

# Función principal
main() {
    local show_diff=false
    local test_only=false
    
    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -d|--diff)
                show_diff=true
                shift
                ;;
            -t|--test)
                test_only=true
                shift
                ;;
            *)
                print_error "Opción desconocida: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    print_status "🔴 Iniciando actualización de BASH Root a Modular..."
    
    # Cambiar al directorio del script
    cd "$(dirname "$0")"
    
    # Verificar que existan los archivos necesarios
    if [[ ! -f "bashrc.root.modular" ]]; then
        print_error "bashrc.root.modular no encontrado"
        exit 1
    fi
    
    if [[ ! -f "bashrc.modular" ]]; then
        print_error "bashrc.modular no encontrado"
        exit 1
    fi
    
    if [[ "$test_only" == true ]]; then
        verify_configuration
        exit $?
    fi
    
    # Actualización completa
    replace_with_modular
    verify_configuration
    
    if [[ "$show_diff" == true ]]; then
        show_differences
    fi
    
    print_success "🎉 Actualización de BASH Root completada exitosamente!"
    print_status "El archivo bashrc.root ahora usa el sistema modular"
    print_status "Para aplicar cambios: source bashrc.root"
}

# Ejecutar función principal
main "$@"
