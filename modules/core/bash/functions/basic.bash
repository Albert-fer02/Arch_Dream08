#!/bin/bash
# =====================================================
# 🔧 FUNCIONES BÁSICAS PARA BASH - ARCH DREAM v4.3
# =====================================================

# Crear directorio y entrar con validación
mkcd() {
    local dir="$1"
    
    if [[ -z "$dir" ]]; then
        echo "❌ Uso: mkcd <directorio>" >&2
        return 1
    fi
    
    if mkdir -p "$dir" && cd "$dir"; then
        echo "✅ Directorio creado y accedido: $(pwd)"
    else
        echo "❌ Error al crear directorio: $dir" >&2
        return 1
    fi
}

# Extraer archivos con validación mejorada
extract() {
    local file="$1"
    
    if [[ -z "$file" ]]; then
        echo "❌ Uso: extract <archivo>" >&2
        return 1
    fi
    
    if [[ ! -f "$file" ]]; then
        echo "❌ Archivo no encontrado: $file" >&2
        return 1
    fi
    
    # Verificar herramientas necesarias
    local tool_needed=""
    case "$file" in
        *.tar.bz2|*.tbz2) tool_needed="tar" ;;
        *.tar.gz|*.tgz|*.tar) tool_needed="tar" ;;
        *.bz2) tool_needed="bunzip2" ;;
        *.rar) tool_needed="unrar" ;;
        *.gz) tool_needed="gunzip" ;;
        *.zip) tool_needed="unzip" ;;
        *.Z) tool_needed="uncompress" ;;
        *.7z) tool_needed="7z" ;;
        *.xz) tool_needed="xz" ;;
        *.tar.xz) tool_needed="tar" ;;
        *) echo "❌ Formato no soportado: $file" >&2; return 1 ;;
    esac
    
    if ! command -v "$tool_needed" >/dev/null 2>&1; then
        echo "❌ Herramienta necesaria no encontrada: $tool_needed" >&2
        return 1
    fi
    
    echo "📦 Extrayendo: $file"
    
    case "$file" in
        *.tar.bz2|*.tbz2) tar xjf "$file" ;;
        *.tar.gz|*.tgz) tar xzf "$file" ;;
        *.tar.xz) tar xJf "$file" ;;
        *.tar) tar xf "$file" ;;
        *.bz2) bunzip2 "$file" ;;
        *.rar) unrar x "$file" ;;
        *.gz) gunzip "$file" ;;
        *.zip) unzip "$file" ;;
        *.Z) uncompress "$file" ;;
        *.7z) 7z x "$file" ;;
        *.xz) xz -d "$file" ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Extracción completada: $file"
    else
        echo "❌ Error al extraer: $file" >&2
        return 1
    fi
}

# Backup con timestamp y validación
backup() {
    local file="$1"
    local backup_dir="${2:-$(dirname "$file")}"
    
    if [[ -z "$file" ]]; then
        echo "❌ Uso: backup <archivo> [directorio_backup]" >&2
        return 1
    fi
    
    if [[ ! -e "$file" ]]; then
        echo "❌ Archivo no encontrado: $file" >&2
        return 1
    fi
    
    local filename=$(basename "$file")
    local backup_name="${backup_dir}/${filename}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Crear directorio de backup si no existe
    mkdir -p "$backup_dir"
    
    if cp -r "$file" "$backup_name"; then
        echo "✅ Backup creado: $backup_name"
        
        # Log si está disponible
        if command -v log_info >/dev/null 2>&1; then
            log_info "Backup created: $file -> $backup_name"
        fi
    else
        echo "❌ Error al crear backup de: $file" >&2
        return 1
    fi
}

# Recargar configuración con validación
reload() {
    local config_file="${1:-$HOME/.bashrc}"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ Archivo de configuración no encontrado: $config_file" >&2
        return 1
    fi
    
    # Validar sintaxis antes de recargar
    if bash -n "$config_file" 2>/dev/null; then
        source "$config_file"
        echo "✅ Configuración de Bash recargada: $config_file"
        
        # Log si está disponible
        if command -v log_info >/dev/null 2>&1; then
            log_info "Configuration reloaded: $config_file"
        fi
    else
        echo "❌ Error de sintaxis en: $config_file" >&2
        return 1
    fi
}

# Información del sistema detallada con cache
quickinfo() {
    local use_cache="${1:-true}"
    local cache_key="system_quickinfo"
    
    # Intentar usar cache si está disponible
    if [[ "$use_cache" == "true" ]] && command -v cache_get >/dev/null 2>&1; then
        local cached=$(cache_get "$cache_key" "system" 300)  # 5 min TTL
        if [[ -n "$cached" ]]; then
            echo "$cached"
            return 0
        fi
    fi
    
    local info=""
    info+="💻 \033[1;34mSistema:\033[0m $(uname -sr)\n"
    info+="🏠 \033[1;34mHostname:\033[0m $(hostname)\n"
    info+="⏰ \033[1;34mUptime:\033[0m $(uptime -p 2>/dev/null || uptime)\n"
    info+="👤 \033[1;34mUsuario:\033[0m $(whoami)\n"
    info+="🐚 \033[1;34mShell:\033[0m $SHELL ($BASH_VERSION)\n"
    info+="🌍 \033[1;34mLocale:\033[0m $LANG\n"
    info+="📊 \033[1;34mMemoria:\033[0m $(free -h 2>/dev/null | awk 'NR==2{printf "%.1f/%.1f GB (%.1f%%)", $3/1024, $2/1024, $3*100/$2}' 2>/dev/null || echo "N/A")\n"
    info+="💾 \033[1;34mDisco (/):\033[0m $(df -h / 2>/dev/null | tail -1 | awk '{print $3"/"$2" ("$5")"}' 2>/dev/null || echo "N/A")\n"
    
    # Cachear resultado si está disponible
    if [[ "$use_cache" == "true" ]] && command -v cache_set >/dev/null 2>&1; then
        cache_set "$cache_key" "$info" "system"
    fi
    
    echo -e "$info"
}

# Buscar en historial con contexto
h() {
    local pattern="$1"
    local count="${2:-20}"
    
    if [[ -z "$pattern" ]]; then
        # Mostrar últimos comandos
        history | tail -"$count"
    else
        # Buscar patrón con resaltado si está disponible
        if command -v grep >/dev/null 2>&1; then
            history | grep --color=auto -i "$pattern" | tail -"$count"
        else
            history | grep -i "$pattern" | tail -"$count"
        fi
    fi
}

# Buscar archivos de forma inteligente
find_file() {
    local pattern="$1"
    local path="${2:-.}"
    local type="${3:-f}"
    
    if [[ -z "$pattern" ]]; then
        echo "❌ Uso: find_file <patrón> [ruta] [tipo]" >&2
        return 1
    fi
    
    # Usar fd si está disponible, sino find
    if command -v fd >/dev/null 2>&1; then
        fd -t "$type" "$pattern" "$path"
    else
        find "$path" -type "$type" -iname "*$pattern*" 2>/dev/null
    fi
}

# Información de directorio con estadísticas
dirinfo() {
    local dir="${1:-.}"
    
    if [[ ! -d "$dir" ]]; then
        echo "❌ Directorio no encontrado: $dir" >&2
        return 1
    fi
    
    echo "📁 Información de directorio: $(realpath "$dir")"
    echo "==========================================="
    
    # Estadísticas básicas
    local total_files=$(find "$dir" -type f 2>/dev/null | wc -l)
    local total_dirs=$(find "$dir" -type d 2>/dev/null | wc -l)
    local total_size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    
    echo "📄 Archivos: $total_files"
    echo "📁 Directorios: $total_dirs"
    echo "📊 Tamaño total: $total_size"
    echo ""
    
    # Archivos más grandes (top 5)
    echo "📈 Archivos más grandes:"
    find "$dir" -type f -exec ls -lh {} \; 2>/dev/null | \
        sort -k5 -hr | head -5 | awk '{print "  "$ 9 " (" $ 5 ")"}'
    echo ""
    
    # Tipos de archivo más comunes
    echo "📅 Tipos de archivo comunes:"
    find "$dir" -type f -name "*.*" 2>/dev/null | \
        awk -F. '{print $NF}' | sort | uniq -c | sort -nr | head -5 | \
        awk '{print "  ." $ 2 ": " $ 1 " archivos"}'
}

# Limpiar pantalla y mostrar contexto
cls() {
    clear
    echo "📁 $(pwd)"
    echo "📅 $(date)"
    echo ""
    
    # Mostrar contenido con la herramienta disponible
    if command -v eza >/dev/null 2>&1; then
        eza --icons --group-directories-first
    elif command -v exa >/dev/null 2>&1; then
        exa --icons --group-directories-first
    else
        ls --color=auto 2>/dev/null || ls
    fi
}

# Crear enlace simbólico con validación
ln_safe() {
    local target="$1"
    local link_name="$2"
    
    if [[ -z "$target" || -z "$link_name" ]]; then
        echo "❌ Uso: ln_safe <archivo_destino> <nombre_enlace>" >&2
        return 1
    fi
    
    if [[ ! -e "$target" ]]; then
        echo "❌ Archivo destino no existe: $target" >&2
        return 1
    fi
    
    if [[ -e "$link_name" ]]; then
        echo "⚠️ El enlace ya existe: $link_name" >&2
        read -p "¿Sobrescribir? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
        rm -f "$link_name"
    fi
    
    if ln -s "$(realpath "$target")" "$link_name"; then
        echo "✅ Enlace creado: $link_name -> $(realpath "$target")"
    else
        echo "❌ Error al crear enlace: $link_name" >&2
        return 1
    fi
}