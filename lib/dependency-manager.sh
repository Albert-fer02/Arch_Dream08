#!/bin/bash
# =====================================================
# 🔗 ARCH DREAM MACHINE - GESTOR DE DEPENDENCIAS
# =====================================================
# Sistema avanzado de gestión de dependencias con resolución inteligente
# Version 1.0 - Smart Dependency Resolution System
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# =====================================================
# 🔧 CONFIGURACIÓN DEL GESTOR DE DEPENDENCIAS
# =====================================================

# Directorios del sistema
DEPENDENCY_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/arch-dream/dependencies"
DEPENDENCY_CACHE="$DEPENDENCY_ROOT/cache"
DEPENDENCY_GRAPHS="$DEPENDENCY_ROOT/graphs"
DEPENDENCY_LOCKS="$DEPENDENCY_ROOT/locks"
DEPENDENCY_CONFLICTS="$DEPENDENCY_ROOT/conflicts"

# Archivos principales
GLOBAL_DEPS_FILE="$DEPENDENCY_CACHE/global_dependencies.json"
PACKAGE_MAP_FILE="$DEPENDENCY_CACHE/package_mapping.json"
CONFLICT_RULES_FILE="$DEPENDENCY_CONFLICTS/conflict_rules.json"
RESOLUTION_CACHE_FILE="$DEPENDENCY_CACHE/resolution_cache.json"

# Configuración de comportamiento
DEPENDENCY_TIMEOUT=300
MAX_RESOLUTION_DEPTH=10
ENABLE_CONFLICT_DETECTION=true
ENABLE_SMART_SUGGESTIONS=true

# =====================================================
# 🔧 FUNCIONES DE INICIALIZACIÓN
# =====================================================

# Inicializar gestor de dependencias
init_dependency_manager() {
    debug "Inicializando gestor de dependencias..."
    
    # Crear estructura de directorios
    mkdir -p "$DEPENDENCY_ROOT" "$DEPENDENCY_CACHE" "$DEPENDENCY_GRAPHS" \
             "$DEPENDENCY_LOCKS" "$DEPENDENCY_CONFLICTS"
    
    # Crear archivos base si no existen
    [[ -f "$GLOBAL_DEPS_FILE" ]] || echo '{}' > "$GLOBAL_DEPS_FILE"
    [[ -f "$PACKAGE_MAP_FILE" ]] || echo '{}' > "$PACKAGE_MAP_FILE"
    [[ -f "$CONFLICT_RULES_FILE" ]] || create_default_conflict_rules
    [[ -f "$RESOLUTION_CACHE_FILE" ]] || echo '{}' > "$RESOLUTION_CACHE_FILE"
    
    # Verificar dependencias del sistema
    check_system_dependencies_for_manager
    
    success "✅ Gestor de dependencias inicializado"
}

# Crear reglas de conflictos por defecto
create_default_conflict_rules() {
    cat > "$CONFLICT_RULES_FILE" << 'EOF'
{
  "conflicts": [
    {
      "packages": ["zsh", "bash"],
      "type": "shell_conflict",
      "resolution": "both_allowed",
      "priority": "user_choice"
    },
    {
      "packages": ["starship", "oh-my-posh"],
      "type": "prompt_conflict", 
      "resolution": "exclusive",
      "priority": "starship"
    },
    {
      "packages": ["yay", "paru"],
      "type": "aur_helper_conflict",
      "resolution": "exclusive",
      "priority": "user_choice"
    },
    {
      "packages": ["systemd", "runit"],
      "type": "init_system_conflict",
      "resolution": "exclusive",
      "priority": "systemd"
    }
  ],
  "alternatives": {
    "cat": ["bat", "cat"],
    "ls": ["eza", "ls"],
    "find": ["fd", "find"],
    "grep": ["ripgrep", "grep"],
    "top": ["btop", "htop", "top"],
    "du": ["dust", "du"],
    "df": ["duf", "df"]
  }
}
EOF
    debug "Reglas de conflictos por defecto creadas"
}

# Verificar dependencias del sistema para el gestor
check_system_dependencies_for_manager() {
    local required_tools=("jq" "python3")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        warn "Herramientas faltantes para el gestor de dependencias: ${missing_tools[*]}"
        
        # Intentar instalar automáticamente
        for tool in "${missing_tools[@]}"; do
            if install_package "$tool" 2>/dev/null; then
                success "✅ $tool instalado automáticamente"
            else
                error "❌ No se pudo instalar $tool"
            fi
        done
    fi
}

# =====================================================
# 📊 ANÁLISIS DE DEPENDENCIAS
# =====================================================

# Extraer dependencias de un módulo
extract_module_dependencies() {
    local module_path="$1"
    local install_script="$module_path/install.sh"
    
    if [[ ! -f "$install_script" ]]; then
        echo '{"dependencies": [], "optional": [], "conflicts": []}'
        return
    fi
    
    # Extraer información usando múltiples métodos
    local dependencies=()
    local optional_deps=()
    local conflicts=()
    
    # Método 1: Variable MODULE_DEPENDENCIES
    if grep -q "MODULE_DEPENDENCIES=" "$install_script"; then
        while IFS= read -r dep; do
            [[ -n "$dep" ]] && dependencies+=("\"$dep\"")
        done < <(grep -o 'MODULE_DEPENDENCIES=([^)]*)' "$install_script" | \
                 sed 's/MODULE_DEPENDENCIES=(\([^)]*\))/\1/' | \
                 tr -d '"' | tr ' ' '\n' | grep -v '^$')
    fi
    
    # Método 2: Buscar install_package calls
    while IFS= read -r dep; do
        [[ -n "$dep" ]] && dependencies+=("\"$dep\"")
    done < <(grep -o 'install_package "[^"]*"' "$install_script" | \
             sed 's/install_package "\([^"]*\)"/\1/' | sort -u)
    
    # Método 3: Buscar command -v checks
    while IFS= read -r cmd; do
        [[ -n "$cmd" ]] && optional_deps+=("\"$cmd\"")
    done < <(grep -o 'command -v [a-zA-Z0-9_-]*' "$install_script" | \
             cut -d' ' -f3 | sort -u)
    
    # Método 4: AUR packages
    if grep -q "MODULE_AUR_PACKAGES=" "$install_script"; then
        while IFS= read -r pkg; do
            [[ -n "$pkg" ]] && dependencies+=("\"$pkg\"")
        done < <(grep -o 'MODULE_AUR_PACKAGES=([^)]*)' "$install_script" | \
                 sed 's/MODULE_AUR_PACKAGES=(\([^)]*\))/\1/' | \
                 tr -d '"' | tr ' ' '\n' | grep -v '^$')
    fi
    
    # Remover duplicados y construir JSON
    local unique_deps=$(printf '%s\n' "${dependencies[@]}" | sort -u | tr '\n' ',' | sed 's/,$//')
    local unique_optional=$(printf '%s\n' "${optional_deps[@]}" | sort -u | tr '\n' ',' | sed 's/,$//')
    local unique_conflicts=$(printf '%s\n' "${conflicts[@]}" | sort -u | tr '\n' ',' | sed 's/,$//')
    
    cat << EOF
{
  "dependencies": [${unique_deps}],
  "optional": [${unique_optional}],
  "conflicts": [${unique_conflicts}]
}
EOF
}

# Crear mapa global de dependencias
create_global_dependency_map() {
    local modules_dir="$1"
    debug "Creando mapa global de dependencias..."
    
    local temp_file=$(mktemp)
    echo '{' > "$temp_file"
    
    local first=true
    for category_dir in "$modules_dir"/*; do
        [[ -d "$category_dir" ]] || continue
        
        local category=$(basename "$category_dir")
        for module_dir in "$category_dir"/*; do
            [[ -d "$module_dir" ]] || continue
            
            local module=$(basename "$module_dir")
            local full_module="${category}:${module}"
            
            # Extraer dependencias
            local deps_json=$(extract_module_dependencies "$module_dir")
            
            # Agregar al mapa global
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo ',' >> "$temp_file"
            fi
            
            echo "  \"$full_module\": $deps_json" >> "$temp_file"
        done
    done
    
    echo '}' >> "$temp_file"
    
    # Validar JSON y mover
    if jq empty "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$GLOBAL_DEPS_FILE"
        success "✅ Mapa global de dependencias creado"
    else
        error "❌ Error en formato JSON del mapa de dependencias"
        rm -f "$temp_file"
        return 1
    fi
}

# =====================================================
# 🔍 RESOLUCIÓN DE DEPENDENCIAS
# =====================================================

# Resolver dependencias de un módulo
resolve_module_dependencies() {
    local module="$1"
    local resolution_file="$DEPENDENCY_GRAPHS/${module//[^a-zA-Z0-9]/_}.resolution"
    
    debug "Resolviendo dependencias para: $module"
    
    # Verificar cache de resolución
    local cache_key=$(echo "$module" | sha256sum | cut -d' ' -f1)
    if jq -e ".\"$cache_key\"" "$RESOLUTION_CACHE_FILE" &>/dev/null; then
        local cached_result=$(jq -r ".\"$cache_key\".resolution[]" "$RESOLUTION_CACHE_FILE" 2>/dev/null)
        if [[ -n "$cached_result" ]]; then
            debug "Usando resolución en cache para $module"
            echo "$cached_result"
            return 0
        fi
    fi
    
    # Resolver usando algoritmo recursivo
    local resolved_order=()
    local visiting=()
    local visited=()
    
    resolve_recursive() {
        local current_module="$1"
        local depth="${2:-0}"
        
        # Evitar recursión infinita
        if [[ $depth -gt $MAX_RESOLUTION_DEPTH ]]; then
            warn "Profundidad máxima de resolución alcanzada para $current_module"
            return 1
        fi
        
        # Detectar ciclos
        if [[ " ${visiting[*]} " =~ " ${current_module} " ]]; then
            warn "Ciclo detectado en dependencias: ${visiting[*]} -> $current_module"
            return 1
        fi
        
        # Si ya fue visitado, salir
        if [[ " ${visited[*]} " =~ " ${current_module} " ]]; then
            return 0
        fi
        
        # Marcar como visitando
        visiting+=("$current_module")
        
        # Obtener dependencias del módulo
        local deps_json=$(jq -r ".\"$current_module\".dependencies[]?" "$GLOBAL_DEPS_FILE" 2>/dev/null)
        
        # Resolver dependencias recursivamente
        while IFS= read -r dep; do
            [[ -n "$dep" ]] && resolve_recursive "$dep" $((depth + 1))
        done <<< "$deps_json"
        
        # Remover de visitando y agregar a visitados
        visiting=("${visiting[@]/$current_module}")
        visited+=("$current_module")
        resolved_order+=("$current_module")
    }
    
    # Iniciar resolución
    if resolve_recursive "$module"; then
        # Guardar en cache
        local cache_entry=$(jq -n --arg key "$cache_key" --argjson resolution "$(printf '%s\n' "${resolved_order[@]}" | jq -R . | jq -s .)" \
                           '.[$key] = {"module": $ARGS.positional[0], "resolution": $resolution, "timestamp": now}' --args "$module")
        
        local temp_cache=$(mktemp)
        jq ". += $cache_entry" "$RESOLUTION_CACHE_FILE" > "$temp_cache" && mv "$temp_cache" "$RESOLUTION_CACHE_FILE"
        
        # Devolver orden resuelto
        printf '%s\n' "${resolved_order[@]}"
        
        debug "Dependencias resueltas para $module: ${#resolved_order[@]} módulos"
        return 0
    else
        error "❌ No se pudieron resolver dependencias para $module"
        return 1
    fi
}

# Resolver dependencias para múltiples módulos
resolve_multiple_dependencies() {
    local modules=("$@")
    local all_resolved=()
    local seen=()
    
    debug "Resolviendo dependencias para ${#modules[@]} módulos..."
    
    # Resolver cada módulo individualmente
    for module in "${modules[@]}"; do
        local module_deps=()
        if mapfile -t module_deps < <(resolve_module_dependencies "$module"); then
            # Agregar dependencias únicas
            for dep in "${module_deps[@]}"; do
                if [[ ! " ${seen[*]} " =~ " ${dep} " ]]; then
                    all_resolved+=("$dep")
                    seen+=("$dep")
                fi
            done
        else
            warn "⚠️ No se pudieron resolver dependencias para $module"
        fi
    done
    
    # Devolver lista ordenada sin duplicados
    printf '%s\n' "${all_resolved[@]}"
}

# =====================================================
# ⚔️ DETECCIÓN DE CONFLICTOS
# =====================================================

# Detectar conflictos entre paquetes
detect_conflicts() {
    local packages=("$@")
    local conflicts_found=()
    
    if [[ "$ENABLE_CONFLICT_DETECTION" != "true" ]]; then
        return 0
    fi
    
    debug "Detectando conflictos entre ${#packages[@]} paquetes..."
    
    # Obtener reglas de conflictos
    local conflict_rules=$(jq -r '.conflicts[] | @json' "$CONFLICT_RULES_FILE" 2>/dev/null)
    
    while IFS= read -r rule_json; do
        [[ -n "$rule_json" ]] || continue
        
        local rule_packages=$(echo "$rule_json" | jq -r '.packages[]')
        local conflict_type=$(echo "$rule_json" | jq -r '.type')
        local resolution=$(echo "$rule_json" | jq -r '.resolution')
        
        # Verificar si hay conflicto
        local conflicting_packages=()
        while IFS= read -r rule_pkg; do
            for user_pkg in "${packages[@]}"; do
                if [[ "$user_pkg" == "$rule_pkg" ]]; then
                    conflicting_packages+=("$rule_pkg")
                fi
            done
        done <<< "$rule_packages"
        
        # Si hay más de un paquete conflictivo
        if [[ ${#conflicting_packages[@]} -gt 1 ]]; then
            local conflict_info=$(jq -n \
                --argjson packages "$(printf '%s\n' "${conflicting_packages[@]}" | jq -R . | jq -s .)" \
                --arg type "$conflict_type" \
                --arg resolution "$resolution" \
                '{"packages": $packages, "type": $type, "resolution": $resolution}')
            
            conflicts_found+=("$conflict_info")
        fi
    done <<< "$conflict_rules"
    
    # Devolver conflictos encontrados
    if [[ ${#conflicts_found[@]} -gt 0 ]]; then
        printf '%s\n' "${conflicts_found[@]}"
        return 1
    else
        return 0
    fi
}

# Resolver conflictos automáticamente
resolve_conflicts() {
    local conflicts=("$@")
    local resolutions=()
    
    debug "Resolviendo ${#conflicts[@]} conflictos..."
    
    for conflict_json in "${conflicts[@]}"; do
        local packages=$(echo "$conflict_json" | jq -r '.packages[]')
        local conflict_type=$(echo "$conflict_json" | jq -r '.type')
        local resolution=$(echo "$conflict_json" | jq -r '.resolution')
        
        case "$resolution" in
            "exclusive")
                # Mantener solo el de mayor prioridad
                local priority=$(jq -r --arg type "$conflict_type" '.conflicts[] | select(.type == $type) | .priority' "$CONFLICT_RULES_FILE")
                if [[ "$priority" != "user_choice" ]]; then
                    resolutions+=("keep:$priority")
                    local packages_array=($(echo "$packages"))
                    for pkg in "${packages_array[@]}"; do
                        if [[ "$pkg" != "$priority" ]]; then
                            resolutions+=("remove:$pkg")
                        fi
                    done
                fi
                ;;
            "both_allowed")
                # Mantener ambos
                while IFS= read -r pkg; do
                    resolutions+=("keep:$pkg")
                done <<< "$packages"
                ;;
            *)
                warn "⚠️ Resolución desconocida: $resolution"
                ;;
        esac
    done
    
    # Devolver resoluciones
    printf '%s\n' "${resolutions[@]}"
}

# =====================================================
# 💡 SUGERENCIAS INTELIGENTES
# =====================================================

# Sugerir alternativas para paquetes
suggest_alternatives() {
    local package="$1"
    
    if [[ "$ENABLE_SMART_SUGGESTIONS" != "true" ]]; then
        return 0
    fi
    
    # Buscar en mapa de alternativas
    local alternatives=$(jq -r --arg pkg "$package" '.alternatives[$pkg][]?' "$CONFLICT_RULES_FILE" 2>/dev/null)
    
    if [[ -n "$alternatives" ]]; then
        echo "💡 Alternativas para $package:"
        while IFS= read -r alt; do
            local is_installed=""
            if is_package_installed "$alt"; then
                is_installed=" ${GREEN}(instalado)${COLOR_RESET}"
            fi
            echo "  - $alt$is_installed"
        done <<< "$alternatives"
    fi
}

# Sugerir optimizaciones de dependencias
suggest_optimizations() {
    local modules=("$@")
    
    debug "Analizando optimizaciones para ${#modules[@]} módulos..."
    
    # Análisis de redundancia
    local all_packages=()
    for module in "${modules[@]}"; do
        local deps=$(jq -r ".\"$module\".dependencies[]?" "$GLOBAL_DEPS_FILE" 2>/dev/null)
        while IFS= read -r dep; do
            [[ -n "$dep" ]] && all_packages+=("$dep")
        done <<< "$deps"
    done
    
    # Encontrar paquetes duplicados
    local duplicates=$(printf '%s\n' "${all_packages[@]}" | sort | uniq -d)
    
    if [[ -n "$duplicates" ]]; then
        echo "🔄 Paquetes requeridos por múltiples módulos:"
        while IFS= read -r dup; do
            local count=$(printf '%s\n' "${all_packages[@]}" | grep -c "^$dup$")
            echo "  - $dup (requerido por $count módulos)"
        done <<< "$duplicates"
    fi
    
    # Sugerir agrupación de instalación
    if [[ ${#all_packages[@]} -gt 10 ]]; then
        echo "💡 Considera instalar paquetes base primero para optimizar tiempo"
    fi
}

# =====================================================
# 📊 ANÁLISIS Y REPORTES
# =====================================================

# Generar reporte de dependencias
generate_dependency_report() {
    local modules=("$@")
    local report_file="$DEPENDENCY_ROOT/dependency_report.txt"
    
    {
        echo "=== REPORTE DE ANÁLISIS DE DEPENDENCIAS ==="
        echo "Fecha: $(date)"
        echo "Módulos analizados: ${#modules[@]}"
        echo
        
        # Estadísticas generales
        local total_deps=0
        local unique_deps=()
        
        echo "=== DEPENDENCIAS POR MÓDULO ==="
        for module in "${modules[@]}"; do
            echo "- $module:"
            
            local deps=$(jq -r ".\"$module\".dependencies[]?" "$GLOBAL_DEPS_FILE" 2>/dev/null)
            local deps_count=$(echo "$deps" | grep -c . || echo 0)
            total_deps=$((total_deps + deps_count))
            
            if [[ $deps_count -gt 0 ]]; then
                while IFS= read -r dep; do
                    echo "  * $dep"
                    if [[ ! " ${unique_deps[*]} " =~ " ${dep} " ]]; then
                        unique_deps+=("$dep")
                    fi
                done <<< "$deps"
            else
                echo "  (sin dependencias)"
            fi
            echo
        done
        
        echo "=== RESUMEN ESTADÍSTICO ==="
        echo "Total de dependencias: $total_deps"
        echo "Dependencias únicas: ${#unique_deps[@]}"
        echo "Promedio por módulo: $(( total_deps / ${#modules[@]} ))"
        echo
        
        # Análisis de conflictos
        echo "=== ANÁLISIS DE CONFLICTOS ==="
        local conflicts=()
        if mapfile -t conflicts < <(detect_conflicts "${unique_deps[@]}" 2>/dev/null); then
            if [[ ${#conflicts[@]} -gt 0 ]]; then
                echo "Conflictos detectados: ${#conflicts[@]}"
                for conflict in "${conflicts[@]}"; do
                    local packages=$(echo "$conflict" | jq -r '.packages[]')
                    local type=$(echo "$conflict" | jq -r '.type')
                    echo "  - Tipo: $type"
                    echo "    Paquetes: $(echo "$packages" | tr '\n' ' ')"
                done
            else
                echo "No se detectaron conflictos"
            fi
        else
            echo "No se detectaron conflictos"
        fi
        
    } > "$report_file"
    
    echo "📊 Reporte generado: $report_file"
    
    # Mostrar resumen en consola
    echo
    echo -e "${BOLD}${BLUE}📊 RESUMEN DE DEPENDENCIAS${COLOR_RESET}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Total de dependencias: $total_deps"
    echo -e "${CYAN}│${COLOR_RESET} Dependencias únicas: ${#unique_deps[@]}"
    echo -e "${CYAN}│${COLOR_RESET} Promedio por módulo: $(( total_deps / ${#modules[@]} ))"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${COLOR_RESET}"
}

# =====================================================
# 🧹 GESTIÓN Y LIMPIEZA
# =====================================================

# Limpiar cache de dependencias
clean_dependency_cache() {
    debug "Limpiando cache de dependencias..."
    
    # Limpiar archivos temporales
    find "$DEPENDENCY_ROOT" -name "*.tmp" -delete 2>/dev/null || true
    
    # Limpiar cache de resoluciones antiguas (más de 24 horas)
    if [[ -f "$RESOLUTION_CACHE_FILE" ]]; then
        local temp_cache=$(mktemp)
        local cutoff_time=$(($(date +%s) - 86400))
        
        jq --argjson cutoff "$cutoff_time" 'to_entries | map(select(.value.timestamp > $cutoff)) | from_entries' \
           "$RESOLUTION_CACHE_FILE" > "$temp_cache" && mv "$temp_cache" "$RESOLUTION_CACHE_FILE"
    fi
    
    success "✅ Cache de dependencias limpiado"
}

# Validar integridad del sistema de dependencias
validate_dependency_system() {
    debug "Validando integridad del sistema de dependencias..."
    
    local errors=0
    
    # Verificar archivos esenciales
    local essential_files=("$GLOBAL_DEPS_FILE" "$CONFLICT_RULES_FILE")
    for file in "${essential_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error "Archivo esencial faltante: $file"
            ((errors++))
        elif ! jq empty "$file" 2>/dev/null; then
            error "Archivo JSON corrupto: $file"
            ((errors++))
        fi
    done
    
    # Verificar permisos de directorios
    local dirs=("$DEPENDENCY_ROOT" "$DEPENDENCY_CACHE" "$DEPENDENCY_GRAPHS")
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            warn "Directorio faltante: $dir"
            mkdir -p "$dir"
            ((errors++))
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        success "✅ Sistema de dependencias válido"
    else
        warn "⚠️ Se encontraron $errors problemas (algunos corregidos)"
    fi
    
    return $errors
}

# =====================================================
# 🔧 INTERFAZ PRINCIPAL
# =====================================================

# Función principal del gestor de dependencias
dependency_manager_main() {
    local action="${1:-help}"
    shift || true
    
    case "$action" in
        init)
            init_dependency_manager
            ;;
        scan)
            create_global_dependency_map "${1:-$MODULES_DIR}"
            ;;
        resolve)
            resolve_multiple_dependencies "$@"
            ;;
        conflicts)
            detect_conflicts "$@"
            ;;
        suggest)
            suggest_alternatives "$1"
            ;;
        report)
            generate_dependency_report "$@"
            ;;
        clean)
            clean_dependency_cache
            ;;
        validate)
            validate_dependency_system
            ;;
        help|*)
            cat << 'EOF'
Gestor de Dependencias - Arch Dream Machine

Uso: dependency_manager_main <acción> [argumentos]

Acciones:
  init                 Inicializar gestor de dependencias
  scan <dir>           Escanear directorio de módulos
  resolve <módulos...> Resolver dependencias para módulos
  conflicts <pkgs...>  Detectar conflictos entre paquetes
  suggest <paquete>    Sugerir alternativas para paquete
  report <módulos...>  Generar reporte de dependencias
  clean                Limpiar cache de dependencias
  validate             Validar integridad del sistema
  help                 Mostrar esta ayuda

Variables de entorno:
  MAX_RESOLUTION_DEPTH      Profundidad máxima de resolución (default: 10)
  ENABLE_CONFLICT_DETECTION Habilitar detección de conflictos (default: true)
  ENABLE_SMART_SUGGESTIONS  Habilitar sugerencias inteligentes (default: true)

Ejemplos:
  dependency_manager_main scan ./modules
  dependency_manager_main resolve core:zsh core:bash
  dependency_manager_main conflicts firefox chromium
EOF
            ;;
    esac
}

# Exportar funciones principales
export -f init_dependency_manager extract_module_dependencies create_global_dependency_map
export -f resolve_module_dependencies resolve_multiple_dependencies
export -f detect_conflicts resolve_conflicts suggest_alternatives
export -f generate_dependency_report clean_dependency_cache validate_dependency_system
export -f dependency_manager_main

# Variables exportadas
export DEPENDENCY_ROOT DEPENDENCY_CACHE DEPENDENCY_GRAPHS DEPENDENCY_LOCKS DEPENDENCY_CONFLICTS
export GLOBAL_DEPS_FILE PACKAGE_MAP_FILE CONFLICT_RULES_FILE RESOLUTION_CACHE_FILE
export DEPENDENCY_TIMEOUT MAX_RESOLUTION_DEPTH ENABLE_CONFLICT_DETECTION ENABLE_SMART_SUGGESTIONS