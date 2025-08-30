#!/bin/bash
# =====================================================
# 🚀 Instalador de BASH Modular - Arch Dream
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

# Función para crear directorios
create_directories() {
    print_status "Creando estructura de directorios..."
    
    local dirs=(
        "config"
        "aliases"
        "functions"
        "plugins"
        "ui"
        "advanced"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            print_success "Directorio creado: $dir"
        else
            print_warning "Directorio ya existe: $dir"
        fi
    done
}

# Función para verificar archivos
verify_files() {
    print_status "Verificando archivos modulares..."
    
    local files=(
        "config/shell-base.bash"
        "config/history.bash"
        "config/completion.bash"

        "config/environment.bash"
        "aliases/basic.bash"
        "aliases/git.bash"
        "aliases/system.bash"
        "functions/basic.bash"
        "functions/arch.bash"
        "plugins/fzf.bash"
        "ui/welcome.bash"
        "advanced/lesspipe.bash"
        "bashrc.modular"
        "bashrc.root.modular"
    )
    
    local missing_files=()
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            print_success "Archivo encontrado: $file"
        else
            print_error "Archivo faltante: $file"
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        print_error "Faltan ${#missing_files[@]} archivos:"
        printf '%s\n' "${missing_files[@]}"
        return 1
    fi
    
    return 0
}

# Función para hacer backup del bashrc original
backup_original() {
    if [[ -f ~/.bashrc ]]; then
        local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        print_status "Haciendo backup del bashrc original..."
        cp ~/.bashrc "$backup_file"
        print_success "Backup creado: $backup_file"
    fi
}

# Función para instalar la configuración modular
install_modular() {
    print_status "Instalando configuración modular..."
    
    # Crear enlace simbólico o copiar
    if [[ -L ~/.bashrc ]]; then
        rm ~/.bashrc
        print_status "Enlace simbólico existente removido"
    fi
    
    # Copiar el archivo modular
    cp bashrc.modular ~/.bashrc
    print_success "Configuración modular instalada en ~/.bashrc"
    
    # Hacer el archivo ejecutable
    chmod +x ~/.bashrc
}

# Función para probar la configuración
test_configuration() {
    print_status "Probando configuración..."
    
    if bash -n ~/.bashrc; then
        print_success "Configuración sintácticamente correcta"
    else
        print_error "Error de sintaxis en la configuración"
        return 1
    fi
}

# Función para mostrar información de uso
show_usage() {
    echo -e "${BLUE}Uso:${NC}"
    echo "  $0 [opciones]"
    echo ""
    echo -e "${BLUE}Opciones:${NC}"
    echo "  -h, --help     Mostrar esta ayuda"
    echo "  -t, --test     Solo probar la configuración"
    echo "  -v, --verify   Solo verificar archivos"
    echo ""
    echo -e "${BLUE}Ejemplos:${NC}"
    echo "  $0              # Instalación completa"
    echo "  $0 --test       # Solo probar"
    echo "  $0 --verify     # Solo verificar"
}

# Función principal
main() {
    local test_only=false
    local verify_only=false
    
    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -t|--test)
                test_only=true
                shift
                ;;
            -v|--verify)
                verify_only=true
                shift
                ;;
            *)
                print_error "Opción desconocida: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    print_status "🚀 Iniciando instalación de BASH Modular..."
    
    # Cambiar al directorio del script
    cd "$(dirname "$0")"
    
    if [[ "$verify_only" == true ]]; then
        verify_files
        exit $?
    fi
    
    if [[ "$test_only" == true ]]; then
        verify_files && test_configuration
        exit $?
    fi
    
    # Instalación completa
    create_directories
    verify_files
    backup_original
    install_modular
    test_configuration
    
    print_success "🎉 Instalación completada exitosamente!"
    print_status "Para aplicar los cambios, ejecuta: source ~/.bashrc"
    print_status "O reinicia tu terminal"
}

# Ejecutar función principal
main "$@"
