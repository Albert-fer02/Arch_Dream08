#!/bin/bash
# =====================================================
# 🧩 ARCH DREAM MACHINE - MÓDULO FASTFETCH
# =====================================================
# Script de instalación del módulo Fastfetch
# Versión 2.0 - Instalación optimizada y robusta
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# =====================================================
# 🔧 CONFIGURACIÓN DEL MÓDULO
# =====================================================

MODULE_NAME="Fastfetch"
MODULE_DESCRIPTION="Información del sistema con temas personalizados"
MODULE_DEPENDENCIES=("fastfetch" "git" "curl" "imagemagick")
MODULE_FILES=("config.jsonc" "Dreamcoder01.jpg" "Dreamcoder02.jpg" "Dreamcoder03.jpg" "Dreamcoder04.jpg")
MODULE_AUR_PACKAGES=()
MODULE_OPTIONAL=true

# Directorios de instalación
FASTFETCH_CONFIG_DIR="$HOME/.config/fastfetch"
FASTFETCH_IMAGES_DIR="$FASTFETCH_CONFIG_DIR/images"
FASTFETCH_THEMES_DIR="$FASTFETCH_CONFIG_DIR/themes"

# =====================================================
# 🔧 FUNCIONES DEL MÓDULO
# =====================================================

# Instalar dependencias del módulo
install_module_dependencies() {
    log "Instalando dependencias del módulo $MODULE_NAME..."
    
    local deps_to_install=()
    
    # Verificar dependencias
    for dep in "${MODULE_DEPENDENCIES[@]}"; do
        if command -v "$dep" &>/dev/null; then
            success "✓ $dep ya está instalado"
        else
            deps_to_install+=("$dep")
        fi
    done
    
    # Instalar dependencias faltantes
    if [[ ${#deps_to_install[@]} -gt 0 ]]; then
        log "Instalando dependencias faltantes: ${deps_to_install[*]}"
        for dep in "${deps_to_install[@]}"; do
            install_package "$dep"
        done
    fi
    
    success "✅ Todas las dependencias están instaladas"
}

# Instalar Fastfetch desde AUR si es necesario
install_fastfetch() {
    log "Verificando instalación de Fastfetch..."
    
    if command -v fastfetch &>/dev/null; then
        success "✓ Fastfetch ya está instalado"
        return 0
    fi
    
    # Intentar instalar desde repositorios oficiales
    if pacman -Ss fastfetch &>/dev/null; then
        log "Instalando Fastfetch desde repositorios oficiales..."
        install_package "fastfetch"
    else
        # Instalar desde AUR
        log "Instalando Fastfetch desde AUR..."
        install_aur_package "fastfetch"
    fi
    
    success "✅ Fastfetch instalado correctamente"
}

# Configurar directorios de Fastfetch
setup_fastfetch_directories() {
    log "Configurando directorios de Fastfetch..."
    
    # Normalizar si existe un symlink roto o archivo en la ruta de config
    if [[ -L "$FASTFETCH_CONFIG_DIR" ]]; then
        local target
        target=$(readlink -f "$FASTFETCH_CONFIG_DIR" || true)
        if [[ -z "$target" || ! -d "$target" ]]; then
            warn "Enlace roto detectado en $FASTFETCH_CONFIG_DIR, corrigiendo..."
            rm -f "$FASTFETCH_CONFIG_DIR"
        fi
    elif [[ -e "$FASTFETCH_CONFIG_DIR" && ! -d "$FASTFETCH_CONFIG_DIR" ]]; then
        warn "$FASTFETCH_CONFIG_DIR es un archivo, moviendo a backup..."
        mv "$FASTFETCH_CONFIG_DIR" "$FASTFETCH_CONFIG_DIR.backup_$(date +%Y%m%d_%H%M%S)"
    fi

    # Crear directorios necesarios
    mkdir -p "$FASTFETCH_CONFIG_DIR" "$FASTFETCH_IMAGES_DIR" "$FASTFETCH_THEMES_DIR"
    
    # Establecer permisos correctos
    chmod 755 "$FASTFETCH_CONFIG_DIR" "$FASTFETCH_IMAGES_DIR" "$FASTFETCH_THEMES_DIR"
    
    success "✅ Directorios de Fastfetch configurados"
}

# Configurar archivos del módulo
configure_module_files() {
    log "Configurando archivos del módulo $MODULE_NAME..."
    
    # Crear symlink para archivo de configuración principal
    create_symlink "$SCRIPT_DIR/config.jsonc" "$FASTFETCH_CONFIG_DIR/config.jsonc" "config.jsonc"
    
    # Copiar imágenes personalizadas
    local images=("Dreamcoder01.jpg" "Dreamcoder02.jpg" "Dreamcoder03.jpg" "Dreamcoder04.jpg")
    for image in "${images[@]}"; do
        if [[ -f "$SCRIPT_DIR/$image" ]]; then
            cp "$SCRIPT_DIR/$image" "$FASTFETCH_IMAGES_DIR/"
            success "✓ Imagen copiada: $image"
        fi
    done

    # Crear enlaces simbólicos en ~/.config/fastfetch para que
    # "~/.config/fastfetch/Dreamcoder0N.jpg" exista y apunte a images/
    for image in "${images[@]}"; do
        local link_target="$FASTFETCH_IMAGES_DIR/$image"
        local link_name="$FASTFETCH_CONFIG_DIR/$image"
        if [[ -e "$link_name" || -L "$link_name" ]]; then
            rm -f "$link_name"
        fi
        ln -s "$link_target" "$link_name"
        success "✓ Enlace creado: ${link_name} -> ${link_target}"
    done
    
    # Crear archivo de configuración local si no existe
    if [[ ! -f "$FASTFETCH_CONFIG_DIR/config.local.jsonc" ]]; then
        cat > "$FASTFETCH_CONFIG_DIR/config.local.jsonc" << 'EOF'
// =====================================================
// 🧩 CONFIGURACIÓN LOCAL DE FASTFETCH
// =====================================================
// Personalizaciones específicas del usuario
// Este archivo NO se sobrescribe con actualizaciones
// =====================================================

{
  // Agregar aquí tus personalizaciones
  // Ejemplo:
  // "logo": {
  //   "type": "small",
  //   "padding": { "left": 2, "right": 1 }
  // }
}
EOF
        success "✅ Archivo de configuración local creado: $FASTFETCH_CONFIG_DIR/config.local.jsonc"
    fi
    
    # Crear/Actualizar tema personalizado DreamCoder (clave actualizada display.key.width)
    cat > "$FASTFETCH_THEMES_DIR/dreamcoder.jsonc" << 'EOF'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "separator": " : ",
  "color": {
    "keys": "#87CEEB",
    "title": "#FFD700",
    "separator": "#FF69B4",
    "values": "#98FB98"
  },
  "logo": {
    "type": "kitty",
    "source": "~/.config/fastfetch/images/Dreamcoder01.jpg",
    "height": 14,
    "padding": { "left": 2, "right": 1 }
  },
  "display": {
    "separator": true,
    "key": { "width": 15 },
    "smallKeys": false
  }
}
EOF
    success "✅ Tema personalizado actualizado: $FASTFETCH_THEMES_DIR/dreamcoder.jsonc"
    
    success "✅ Archivos del módulo configurados"
}

# Configurar integración con el sistema
configure_system_integration() {
    log "Configurando integración con el sistema..."
    
    # Crear wrapper para seleccionar UNA imagen aleatoria en cada ejecución
    local wrapper_path="$HOME/.local/bin/fastfetch-random"
    mkdir -p "$(dirname "$wrapper_path")"
    cat > "$wrapper_path" << 'EOF'
#!/bin/bash
set -euo pipefail

IMAGES_DIR="$HOME/.config/fastfetch/images"
# Recoger imágenes disponibles y seleccionar una aleatoria
mapfile -t images < <(find "$IMAGES_DIR" -maxdepth 1 -type f -name 'Dreamcoder*.jpg' | sort)
if [[ ${#images[@]} -eq 0 ]]; then
  exec fastfetch "$@"
fi
selected_image="${images[$((RANDOM % ${#images[@]}))]}"

# Determinar config base (si el usuario pasó --config, usar ese archivo)
base_config="$HOME/.config/fastfetch/config.jsonc"
args=("$@")
new_args=()
skip_next=0
for ((i=0; i<${#args[@]}; i++)); do
  if (( skip_next == 1 )); then
    skip_next=0
    continue
  fi
  if [[ "${args[$i]}" == "--config" ]]; then
    if (( i + 1 < ${#args[@]} )); then
      base_config="${args[$((i+1))]}"
      skip_next=1
    fi
    continue
  fi
  new_args+=("${args[$i]}")
done

if [[ -f "$base_config" ]]; then
  tmp_cfg="$(mktemp --suffix=.jsonc)"
  trap 'rm -f "$tmp_cfg"' EXIT
  cp "$base_config" "$tmp_cfg"
  # Reemplazar solo el primer valor de "source": en el archivo
  sed -i -E "0,/(\"source\"\s*:\s*\").*?(\")/s//\\1${selected_image//\//\\/}\\2/" "$tmp_cfg"
  exec fastfetch --config "$tmp_cfg" "${new_args[@]}"
else
  exec fastfetch "${new_args[@]}"
fi
EOF
    chmod +x "$wrapper_path"
    success "✅ Wrapper creado: $wrapper_path"

    # Crear alias para Fastfetch
    local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc")
    
    for config in "${shell_configs[@]}"; do
        if [[ -f "$config" ]]; then
            # Asegurar/actualizar aliases a usar el wrapper
            if grep -q "alias ff=" "$config"; then
                sed -i 's|alias ff=.*|alias ff="fastfetch-random"|' "$config"
            else
                echo "" >> "$config"
                echo "# Fastfetch aliases" >> "$config"
                echo 'alias ff="fastfetch-random"' >> "$config"
            fi

            if grep -q "alias ff-dream=" "$config"; then
                sed -i 's|alias ff-dream=.*|alias ff-dream="fastfetch-random --config ~/.config/fastfetch/themes/dreamcoder.jsonc"|' "$config"
            else
                echo 'alias ff-dream="fastfetch-random --config ~/.config/fastfetch/themes/dreamcoder.jsonc"' >> "$config"
            fi

            if grep -q "alias ff-custom=" "$config"; then
                sed -i 's|alias ff-custom=.*|alias ff-custom="fastfetch-random --config ~/.config/fastfetch/config.local.jsonc"|' "$config"
            else
                echo 'alias ff-custom="fastfetch-random --config ~/.config/fastfetch/config.local.jsonc"' >> "$config"
            fi

            # Hacer que 'fastfetch' use el wrapper por defecto para garantizar aleatoriedad
            if grep -q "alias fastfetch=" "$config"; then
                sed -i 's|alias fastfetch=.*|alias fastfetch="fastfetch-random"|' "$config"
            else
                echo 'alias fastfetch="fastfetch-random"' >> "$config"
            fi

            success "✅ Aliases actualizados en $config"
        fi
    done
    
    # Crear script de configuración interactiva
    local config_script="$HOME/.local/bin/fastfetch-config"
    mkdir -p "$(dirname "$config_script")"
    
    cat > "$config_script" << 'EOF'
#!/bin/bash
# Script para configurar Fastfetch interactivamente
echo "🎨 Configurando Fastfetch..."

# Mostrar opciones disponibles
echo "Temas disponibles:"
echo "1. DreamCoder (personalizado)"
echo "2. Configuración local"
echo "3. Configuración por defecto"
echo "4. Configuración personalizada"

read -p "Selecciona un tema (1-4): " choice

case $choice in
    1)
        fastfetch --config ~/.config/fastfetch/themes/dreamcoder.jsonc
        ;;
    2)
        fastfetch --config ~/.config/fastfetch/config.local.jsonc
        ;;
    3)
        fastfetch
        ;;
    4)
        fastfetch --config ~/.config/fastfetch/config.jsonc
        ;;
    *)
        echo "Opción inválida"
        ;;
esac
EOF
    
    chmod +x "$config_script"
    success "✅ Script de configuración creado: $config_script"
    
    success "✅ Integración con el sistema configurada"
}

# Verificar instalación del módulo
verify_module_installation() {
    log "Verificando instalación del módulo $MODULE_NAME..."
    
    local checks_passed=0
    local total_checks=6
    
    # Verificar Fastfetch instalado
    if command -v fastfetch &>/dev/null; then
        success "✓ Fastfetch instalado"
        ((++checks_passed))
    else
        error "✗ Fastfetch no está instalado"
    fi
    
    # Verificar archivo de configuración principal
    if [[ -L "$FASTFETCH_CONFIG_DIR/config.jsonc" ]] && [[ -e "$FASTFETCH_CONFIG_DIR/config.jsonc" ]]; then
        success "✓ config.jsonc configurado"
        ((++checks_passed))
    else
        error "✗ config.jsonc no está configurado"
    fi
    
    # Verificar directorios
    if [[ -d "$FASTFETCH_CONFIG_DIR" ]] && [[ -d "$FASTFETCH_IMAGES_DIR" ]]; then
        success "✓ Directorios de Fastfetch configurados"
        ((++checks_passed))
    else
        error "✗ Directorios de Fastfetch no están configurados"
    fi
    
    # Verificar imágenes
    local image_count=$(find "$FASTFETCH_IMAGES_DIR" -name "*.jpg" | wc -l)
    if [[ $image_count -gt 0 ]]; then
        success "✓ Imágenes personalizadas configuradas ($image_count imágenes)"
        ((++checks_passed))
    else
        error "✗ No se encontraron imágenes personalizadas"
    fi
    
    # Verificar tema personalizado
    if [[ -f "$FASTFETCH_THEMES_DIR/dreamcoder.jsonc" ]]; then
        success "✓ Tema personalizado creado"
        ((++checks_passed))
    else
        error "✗ Tema personalizado no está creado"
    fi
    
    # Verificar que Fastfetch puede ejecutarse
    if fastfetch --version &>/dev/null; then
        success "✓ Fastfetch puede ejecutarse correctamente"
        ((++checks_passed))
    else
        error "✗ Fastfetch no puede ejecutarse"
    fi
    
    if [[ $checks_passed -eq $total_checks ]]; then
        success "Módulo $MODULE_NAME instalado correctamente ($checks_passed/$total_checks)"
        return 0
    else
        warn "Módulo $MODULE_NAME instalado parcialmente ($checks_passed/$total_checks)"
        return 1
    fi
}

# Configuración post-instalación
post_installation_setup() {
    log "Configurando sistema post-instalación..."
    
    # Crear script de limpieza de caché
    local cleanup_script="$HOME/.local/bin/clean-fastfetch-cache"
    mkdir -p "$(dirname "$cleanup_script")"
    
    cat > "$cleanup_script" << 'EOF'
#!/bin/bash
# Script para limpiar caché de Fastfetch
echo "🧹 Limpiando caché de Fastfetch..."
rm -rf ~/.cache/fastfetch
echo "✅ Caché de Fastfetch limpiado"
EOF
    
    chmod +x "$cleanup_script"
    success "✅ Script de limpieza creado: $cleanup_script"
    
    # Mostrar información de uso
    show_usage_info
}

# Mostrar información de uso
show_usage_info() {
    echo
    echo -e "${BOLD}${GREEN}🚀 FASTFETCH CONFIGURADO EXITOSAMENTE${COLOR_RESET}"
    echo
    echo -e "${CYAN}📋 Próximos pasos:${COLOR_RESET}"
    echo -e "  1. Ejecuta: fastfetch para ver información del sistema"
    echo -e "  2. Usa: ff-dream para el tema DreamCoder"
    echo -e "  3. Personaliza tu configuración en: $FASTFETCH_CONFIG_DIR/config.local.jsonc"
    echo
    echo -e "${YELLOW}💡 Comandos útiles:${COLOR_RESET}"
    echo -e "  - ff: Alias para fastfetch"
    echo -e "  - ff-dream: Tema DreamCoder personalizado"
    echo -e "  - ff-custom: Configuración local"
    echo -e "  - fastfetch-config: Configuración interactiva"
    echo -e "  - clean-fastfetch-cache: Limpiar caché"
    echo
    echo -e "${PURPLE}🌟 ¡Disfruta tu nueva información del sistema!${COLOR_RESET}"
}

# =====================================================
# 🏁 FUNCIÓN PRINCIPAL
# =====================================================

main() {
    # Inicializar biblioteca
    init_library
    
    # Banner
    echo -e "${BOLD}${CYAN}🧩 INSTALANDO MÓDULO: $MODULE_NAME${COLOR_RESET}"
    echo -e "${CYAN}$MODULE_DESCRIPTION${COLOR_RESET}\n"
    
    # Instalar dependencias
    install_module_dependencies
    
    # Instalar Fastfetch
    install_fastfetch
    
    # Configurar directorios
    setup_fastfetch_directories
    
    # Configurar archivos
    configure_module_files
    
    # Configurar integración con el sistema
    configure_system_integration
    
    # Verificar instalación
    verify_module_installation
    
    # Configuración post-instalación
    post_installation_setup
    
    echo -e "\n${BOLD}${GREEN}✅ Módulo $MODULE_NAME instalado exitosamente${COLOR_RESET}"
    echo -e "${YELLOW}💡 Para usar Fastfetch: fastfetch o ff${COLOR_RESET}"
}

# Ejecutar función principal
main "$@" 