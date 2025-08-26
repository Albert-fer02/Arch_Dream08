#!/bin/bash
# =====================================================
# 💻 FUNCIONES DE DESARROLLO - ARCH DREAM v4.3
# =====================================================

# Función para crear proyecto rápido
quick_project() {
    local project_name="$1"
    local project_type="${2:-basic}"
    local project_dir="${3:-$HOME/dev}"
    
    if [[ -z "$project_name" ]]; then
        echo "❌ Uso: quick_project <nombre> [tipo] [directorio]" >&2
        echo "Tipos disponibles: basic, node, python, rust, go, web" >&2
        return 1
    fi
    
    local full_path="$project_dir/$project_name"
    
    if [[ -d "$full_path" ]]; then
        echo "❌ El proyecto ya existe: $full_path" >&2
        return 1
    fi
    
    echo "🚀 Creando proyecto '$project_name' ($project_type)..."
    
    # Crear directorio base
    mkdir -p "$full_path"
    cd "$full_path"
    
    # Configurar según el tipo
    case "$project_type" in
        "node"|"nodejs")
            npm init -y
            mkdir -p src tests docs
            echo "node_modules/" > .gitignore
            echo "*.log" >> .gitignore
            echo ".env" >> .gitignore
            ;;
        "python"|"py")
            python3 -m venv venv
            mkdir -p src tests docs
            cat > .gitignore << 'EOF'
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
*.egg-info/
dist/
build/
.pytest_cache/
.coverage
EOF
            cat > requirements.txt << 'EOF'
# Production dependencies

# Development dependencies (install with: pip install -r requirements.txt)
pytest>=7.0
black>=22.0
flake8>=4.0
EOF
            ;;
        "rust"|"rs")
            if command -v cargo >/dev/null 2>&1; then
                cargo init .
            else
                echo "❌ Cargo no está instalado" >&2
                return 1
            fi
            ;;
        "go"|"golang")
            if command -v go >/dev/null 2>&1; then
                go mod init "$project_name"
                mkdir -p cmd pkg internal
                cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
EOF
            else
                echo "❌ Go no está instalado" >&2
                return 1
            fi
            ;;
        "web"|"html")
            mkdir -p src/{css,js,img} docs
            cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Proyecto Web</title>
    <link rel="stylesheet" href="src/css/style.css">
</head>
<body>
    <h1>¡Hola Mundo!</h1>
    <script src="src/js/app.js"></script>
</body>
</html>
EOF
            cat > src/css/style.css << 'EOF'
/* Estilos principales */
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    margin: 0;
    padding: 20px;
    background: #f5f5f5;
    color: #333;
}

h1 {
    color: #2563eb;
    text-align: center;
}
EOF
            echo 'console.log("Proyecto web iniciado!");' > src/js/app.js
            ;;
        *)
            # Proyecto básico
            mkdir -p src tests docs
            echo "# $project_name" > README.md
            ;;
    esac
    
    # Crear README si no existe
    if [[ ! -f "README.md" ]]; then
        cat > README.md << EOF
# $project_name

## Descripción
Proyecto $project_name creado con Arch Dream.

## Instalación
\`\`\`bash
# Instrucciones de instalación aquí
\`\`\`

## Uso
\`\`\`bash
# Instrucciones de uso aquí
\`\`\`

## Desarrollo
Este proyecto fue creado el $(date) usando el tipo: $project_type

## Licencia
MIT
EOF
    fi
    
    # Inicializar Git si está disponible
    if command -v git >/dev/null 2>&1; then
        git init
        git add .
        git commit -m "Initial commit: $project_name ($project_type)"
    fi
    
    echo "✅ Proyecto creado exitosamente en: $full_path"
    
    # Log si está disponible
    if command -v log_info >/dev/null 2>&1; then
        log_info "Project created: $project_name ($project_type) at $full_path"
    fi
}

# Función para cambiar entre proyectos
project_switch() {
    local project="$1"
    local dev_dir="${2:-$HOME/dev}"
    
    if [[ -z "$project" ]]; then
        echo "📁 Proyectos disponibles en $dev_dir:"
        if [[ -d "$dev_dir" ]]; then
            find "$dev_dir" -maxdepth 1 -type d -not -name "$(basename "$dev_dir")" | sort
        else
            echo "❌ Directorio de desarrollo no encontrado: $dev_dir" >&2
        fi
        return 0
    fi
    
    local project_path="$dev_dir/$project"
    
    if [[ -d "$project_path" ]]; then
        cd "$project_path"
        echo "🚀 Cambiado a proyecto: $project"
        
        # Mostrar información del proyecto
        if [[ -f "package.json" ]]; then
            echo "📦 Proyecto Node.js detectado"
        elif [[ -f "Cargo.toml" ]]; then
            echo "🦀 Proyecto Rust detectado"
        elif [[ -f "requirements.txt" || -f "setup.py" ]]; then
            echo "🐍 Proyecto Python detectado"
        elif [[ -f "go.mod" ]]; then
            echo "🐹 Proyecto Go detectado"
        fi
        
        # Activar entorno virtual si existe (Python)
        if [[ -f "venv/bin/activate" ]]; then
            echo "🔄 Activando entorno virtual Python..."
            source venv/bin/activate
        fi
        
        # Log si está disponible
        if command -v log_info >/dev/null 2>&1; then
            log_info "Switched to project: $project"
        fi
    else
        echo "❌ Proyecto no encontrado: $project_path" >&2
        return 1
    fi
}

# Función para backup de proyecto
project_backup() {
    local project_dir="${1:-$(pwd)}"
    local backup_dir="${2:-$HOME/backups/projects}"
    
    if [[ ! -d "$project_dir" ]]; then
        echo "❌ Directorio de proyecto no encontrado: $project_dir" >&2
        return 1
    fi
    
    local project_name=$(basename "$project_dir")
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="${project_name}-backup-${timestamp}"
    
    mkdir -p "$backup_dir"
    
    echo "💾 Creando backup del proyecto: $project_name"
    
    # Crear archivo tar con exclusiones
    tar -czf "$backup_dir/$backup_name.tar.gz" \
        -C "$(dirname "$project_dir")" \
        --exclude='node_modules' \
        --exclude='venv' \
        --exclude='env' \
        --exclude='target' \
        --exclude='.git' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        --exclude='.pytest_cache' \
        --exclude='.coverage' \
        --exclude='dist' \
        --exclude='build' \
        "$(basename "$project_dir")"
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Backup creado: $backup_dir/$backup_name.tar.gz"
        
        # Log si está disponible
        if command -v log_info >/dev/null 2>&1; then
            log_info "Project backup created: $project_name -> $backup_name.tar.gz"
        fi
    else
        echo "❌ Error al crear backup" >&2
        return 1
    fi
}

# Función para limpiar proyecto
project_clean() {
    local project_dir="${1:-$(pwd)}"
    
    if [[ ! -d "$project_dir" ]]; then
        echo "❌ Directorio de proyecto no encontrado: $project_dir" >&2
        return 1
    fi
    
    cd "$project_dir"
    
    echo "🧹 Limpiando proyecto: $(basename "$project_dir")"
    
    # Node.js
    if [[ -f "package.json" ]]; then
        echo "🗑️ Limpiando Node.js..."
        [[ -d "node_modules" ]] && rm -rf node_modules
        [[ -f "package-lock.json" ]] && rm -f package-lock.json
        [[ -f "yarn.lock" ]] && rm -f yarn.lock
        [[ -d "dist" ]] && rm -rf dist
        [[ -d "build" ]] && rm -rf build
    fi
    
    # Python
    if [[ -f "requirements.txt" || -f "setup.py" ]]; then
        echo "🗑️ Limpiando Python..."
        find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
        find . -name "*.pyc" -delete 2>/dev/null
        [[ -d ".pytest_cache" ]] && rm -rf .pytest_cache
        [[ -f ".coverage" ]] && rm -f .coverage
        [[ -d "dist" ]] && rm -rf dist
        [[ -d "build" ]] && rm -rf build
        [[ -d "*.egg-info" ]] && rm -rf *.egg-info
    fi
    
    # Rust
    if [[ -f "Cargo.toml" ]]; then
        echo "🗑️ Limpiando Rust..."
        [[ -d "target" ]] && rm -rf target
    fi
    
    # Go
    if [[ -f "go.mod" ]]; then
        echo "🗑️ Limpiando Go..."
        go clean -cache -modcache -testcache 2>/dev/null || true
    fi
    
    # Archivos temporales generales
    find . -name ".DS_Store" -delete 2>/dev/null
    find . -name "Thumbs.db" -delete 2>/dev/null
    find . -name "*.tmp" -delete 2>/dev/null
    find . -name "*.temp" -delete 2>/dev/null
    
    echo "✅ Limpieza completada"
    
    # Log si está disponible
    if command -v log_info >/dev/null 2>&1; then
        log_info "Project cleaned: $(basename "$project_dir")"
    fi
}

# Función para mostrar estadísticas del proyecto
project_stats() {
    local project_dir="${1:-$(pwd)}"
    
    if [[ ! -d "$project_dir" ]]; then
        echo "❌ Directorio de proyecto no encontrado: $project_dir" >&2
        return 1
    fi
    
    cd "$project_dir"
    local project_name=$(basename "$project_dir")
    
    echo "📊 Estadísticas del proyecto: $project_name"
    echo "=========================================="
    
    # Información general
    echo "📁 Ruta: $project_dir"
    echo "📅 Creado: $(stat -c %y . 2>/dev/null | cut -d' ' -f1)"
    echo "💾 Tamaño: $(du -sh . 2>/dev/null | cut -f1)"
    
    # Contar archivos por tipo
    echo ""
    echo "📄 Archivos por tipo:"
    find . -type f -name "*.*" | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -10 | \
        awk '{printf "  .%-8s: %s archivos\n", $2, $1}'
    
    # Líneas de código
    echo ""
    echo "📏 Líneas de código:"
    local total_lines=$(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.rs" -o -name "*.go" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" \) -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
    echo "  Total: ${total_lines:-0} líneas"
    
    # Git stats si está disponible
    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
        echo ""
        echo "📊 Git:"
        echo "  Commits: $(git rev-list --count HEAD 2>/dev/null || echo "0")"
        echo "  Rama actual: $(git branch --show-current 2>/dev/null || echo "N/A")"
        echo "  Último commit: $(git log -1 --format="%ar" 2>/dev/null || echo "N/A")"
    fi
    
    # Dependencias por tecnología
    if [[ -f "package.json" ]]; then
        local deps=$(jq '.dependencies | length' package.json 2>/dev/null || echo "0")
        local dev_deps=$(jq '.devDependencies | length' package.json 2>/dev/null || echo "0")
        echo ""
        echo "📦 Node.js:"
        echo "  Dependencias: $deps"
        echo "  Dev dependencies: $dev_deps"
    fi
    
    if [[ -f "requirements.txt" ]]; then
        local py_deps=$(grep -c "^[^#]" requirements.txt 2>/dev/null || echo "0")
        echo ""
        echo "🐍 Python:"
        echo "  Dependencias: $py_deps"
    fi
    
    if [[ -f "Cargo.toml" ]]; then
        local rust_deps=$(grep -c "^[a-zA-Z]" Cargo.toml 2>/dev/null || echo "0")
        echo ""
        echo "🦀 Rust:"
        echo "  Dependencias: $rust_deps"
    fi
}

# Función para detectar tipo de proyecto
project_detect() {
    local project_dir="${1:-$(pwd)}"
    
    cd "$project_dir"
    local types=()
    
    [[ -f "package.json" ]] && types+=("Node.js")
    [[ -f "requirements.txt" || -f "setup.py" ]] && types+=("Python")
    [[ -f "Cargo.toml" ]] && types+=("Rust")
    [[ -f "go.mod" ]] && types+=("Go")
    [[ -f "index.html" ]] && types+=("Web")
    [[ -f "Dockerfile" ]] && types+=("Docker")
    [[ -f ".github/workflows" ]] && types+=("GitHub Actions")
    [[ -d ".git" ]] && types+=("Git")
    
    if [[ ${#types[@]} -eq 0 ]]; then
        echo "❓ Tipo de proyecto no detectado"
    else
        echo "🔍 Tipos detectados: ${types[*]}"
    fi
}

# Exportar funciones
export -f quick_project project_switch project_backup project_clean
export -f project_stats project_detect