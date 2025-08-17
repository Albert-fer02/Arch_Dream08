#!/bin/bash
# =====================================================
# 🚀 ARCH DREAM MACHINE - INSTALADOR PARALELO
# =====================================================
# Sistema de instalación paralela optimizada con gestión de dependencias
# Version 1.0 - Ultra Performance Parallel Installation System
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# =====================================================
# 🔧 CONFIGURACIÓN DEL INSTALADOR PARALELO
# =====================================================

# Configuración de paralelización
MAX_PARALLEL_JOBS=${MAX_PARALLEL_JOBS:-4}
INSTALL_TIMEOUT=${INSTALL_TIMEOUT:-1800}  # 30 minutos por módulo
DEPENDENCY_TIMEOUT=${DEPENDENCY_TIMEOUT:-300}  # 5 minutos para resolver dependencias

# Directorios de trabajo
PARALLEL_WORK_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/arch-dream/parallel"
JOBS_DIR="$PARALLEL_WORK_DIR/jobs"
LOGS_DIR="$PARALLEL_WORK_DIR/logs"
STATUS_DIR="$PARALLEL_WORK_DIR/status"

# Estados de trabajos
JOB_PENDING="pending"
JOB_RUNNING="running"
JOB_COMPLETED="completed"
JOB_FAILED="failed"
JOB_SKIPPED="skipped"

# =====================================================
# 🔧 FUNCIONES DE INICIALIZACIÓN
# =====================================================

# Inicializar sistema de instalación paralela
init_parallel_installer() {
    debug "Inicializando instalador paralelo..."
    
    # Crear directorios de trabajo
    mkdir -p "$PARALLEL_WORK_DIR" "$JOBS_DIR" "$LOGS_DIR" "$STATUS_DIR"
    
    # Limpiar trabajos anteriores
    rm -f "$JOBS_DIR"/* "$STATUS_DIR"/* 2>/dev/null || true
    
    # Detectar número óptimo de trabajos en paralelo
    local cpu_cores=$(nproc)
    local available_memory=$(free -m | awk 'NR==2{print $7}')
    
    # Ajustar jobs basado en recursos disponibles
    if [[ $available_memory -lt 2048 ]]; then
        # Menos de 2GB RAM - usar menos jobs
        MAX_PARALLEL_JOBS=$((cpu_cores / 2))
    elif [[ $available_memory -lt 4096 ]]; then
        # Menos de 4GB RAM - usar CPU cores
        MAX_PARALLEL_JOBS=$cpu_cores
    else
        # Más de 4GB RAM - usar más jobs
        MAX_PARALLEL_JOBS=$((cpu_cores + 2))
    fi
    
    # Mínimo 1, máximo 8
    MAX_PARALLEL_JOBS=$(( MAX_PARALLEL_JOBS < 1 ? 1 : MAX_PARALLEL_JOBS ))
    MAX_PARALLEL_JOBS=$(( MAX_PARALLEL_JOBS > 8 ? 8 : MAX_PARALLEL_JOBS ))
    
    success "✅ Instalador paralelo inicializado (${MAX_PARALLEL_JOBS} jobs simultáneos)"
}

# =====================================================
# 📊 GESTIÓN DE TRABAJOS
# =====================================================

# Crear trabajo de instalación
create_job() {
    local module="$1"
    local script_path="$2"
    local dependencies_list="$3"
    
    local job_id="${module//[^a-zA-Z0-9]/_}"
    local job_file="$JOBS_DIR/${job_id}.job"
    
    # Crear archivo de trabajo
    cat > "$job_file" << EOF
MODULE="$module"
SCRIPT_PATH="$script_path"
DEPENDENCIES="$dependencies_list"
STATUS="$JOB_PENDING"
CREATED=$(date +%s)
PID=""
STARTED=""
FINISHED=""
EXIT_CODE=""
EOF
    
    debug "Trabajo creado: $job_id"
    echo "$job_id"
}

# Actualizar estado de trabajo
update_job_status() {
    local job_id="$1"
    local status="$2"
    local additional_info="${3:-}"
    
    local job_file="$JOBS_DIR/${job_id}.job"
    local status_file="$STATUS_DIR/${job_id}.status"
    
    if [[ -f "$job_file" ]]; then
        # Actualizar archivo de trabajo
        sed -i "s/^STATUS=.*/STATUS=\"$status\"/" "$job_file"
        
        # Agregar información adicional
        if [[ -n "$additional_info" ]]; then
            echo "$additional_info" >> "$job_file"
        fi
        
        # Crear archivo de estado para monitoreo rápido
        echo "$status" > "$status_file"
        
        debug "Estado de trabajo $job_id actualizado: $status"
    fi
}

# Obtener estado de trabajo
get_job_status() {
    local job_id="$1"
    local status_file="$STATUS_DIR/${job_id}.status"
    
    if [[ -f "$status_file" ]]; then
        cat "$status_file"
    else
        echo "$JOB_PENDING"
    fi
}

# Listar trabajos por estado
list_jobs_by_status() {
    local target_status="$1"
    
    for status_file in "$STATUS_DIR"/*.status; do
        [[ -f "$status_file" ]] || continue
        
        local status=$(cat "$status_file")
        if [[ "$status" == "$target_status" ]]; then
            local job_id=$(basename "$status_file" .status)
            echo "$job_id"
        fi
    done
}

# =====================================================
# 🔗 GESTIÓN DE DEPENDENCIAS PARALELA
# =====================================================

# Crear grafo de dependencias
create_dependency_graph() {
    local modules=("$@")
    local graph_file="$PARALLEL_WORK_DIR/dependency_graph.txt"
    
    debug "Creando grafo de dependencias..."
    
    # Limpiar grafo anterior
    > "$graph_file"
    
    # Construir grafo
    for module in "${modules[@]}"; do
        local module_path="$MODULES_DIR/${module/:/\/}"
        local dependencies=""
        
        if [[ -f "$module_path/install.sh" ]]; then
            # Extraer dependencias del script
            dependencies=$(grep -o 'MODULE_DEPENDENCIES=([^)]*)' "$module_path/install.sh" 2>/dev/null | \
                          sed 's/MODULE_DEPENDENCIES=(\([^)]*\))/\1/' | \
                          tr -d '"' | \
                          tr ' ' '\n' | \
                          grep -v '^$' || true)
        fi
        
        # Agregar al grafo
        if [[ -n "$dependencies" ]]; then
            echo "$module:$dependencies" >> "$graph_file"
        else
            echo "$module:" >> "$graph_file"
        fi
    done
    
    debug "Grafo de dependencias creado: $graph_file"
}

# Resolver orden de instalación topológica
resolve_topological_order() {
    local graph_file="$PARALLEL_WORK_DIR/dependency_graph.txt"
    local ordered_file="$PARALLEL_WORK_DIR/install_order.txt"
    
    debug "Resolviendo orden topológico..."
    
    # Implementación simple de ordenamiento topológico
    python3 << 'EOF'
import sys
from collections import defaultdict, deque

def topological_sort(graph_file, output_file):
    # Leer grafo
    graph = defaultdict(list)
    in_degree = defaultdict(int)
    all_nodes = set()
    
    try:
        with open(graph_file, 'r') as f:
            for line in f:
                line = line.strip()
                if ':' in line:
                    node, deps = line.split(':', 1)
                    all_nodes.add(node)
                    
                    if deps:
                        for dep in deps.split():
                            if dep:
                                graph[dep].append(node)
                                in_degree[node] += 1
                                all_nodes.add(dep)
                    
                    # Asegurar que el nodo esté en in_degree
                    if node not in in_degree:
                        in_degree[node] = 0
    except FileNotFoundError:
        return []
    
    # Ordenamiento topológico usando algoritmo de Kahn
    queue = deque([node for node in all_nodes if in_degree[node] == 0])
    result = []
    
    while queue:
        node = queue.popleft()
        result.append(node)
        
        for neighbor in graph[node]:
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0:
                queue.append(neighbor)
    
    # Verificar ciclos
    if len(result) != len(all_nodes):
        # Hay ciclos, agregar nodos restantes
        remaining = [node for node in all_nodes if node not in result]
        result.extend(remaining)
    
    # Escribir resultado
    with open(output_file, 'w') as f:
        for node in result:
            f.write(f"{node}\n")
    
    return result

# Ejecutar
try:
    graph_file = sys.argv[1] if len(sys.argv) > 1 else '/dev/stdin'
    output_file = sys.argv[2] if len(sys.argv) > 2 else '/dev/stdout'
    topological_sort(graph_file, output_file)
except Exception as e:
    print(f"Error en ordenamiento topológico: {e}", file=sys.stderr)
    sys.exit(1)
EOF "$graph_file" "$ordered_file"
    
    if [[ -f "$ordered_file" ]]; then
        cat "$ordered_file"
        debug "Orden topológico resuelto"
    else
        warn "No se pudo resolver orden topológico, usando orden original"
        return 1
    fi
}

# =====================================================
# 🔄 EJECUTOR DE TRABAJOS PARALELOS
# =====================================================

# Ejecutar trabajo individual
execute_job() {
    local job_id="$1"
    local job_file="$JOBS_DIR/${job_id}.job"
    local log_file="$LOGS_DIR/${job_id}.log"
    
    if [[ ! -f "$job_file" ]]; then
        error "Archivo de trabajo no encontrado: $job_id"
        return 1
    fi
    
    # Cargar información del trabajo
    source "$job_file"
    
    # Actualizar estado a ejecutándose
    update_job_status "$job_id" "$JOB_RUNNING" "STARTED=$(date +%s)"
    update_job_status "$job_id" "$JOB_RUNNING" "PID=$$"
    
    debug "Ejecutando trabajo: $MODULE"
    
    # Ejecutar script de instalación con timeout
    local exit_code=0
    
    {
        echo "=== Iniciando instalación de $MODULE ==="
        echo "Fecha: $(date)"
        echo "PID: $$"
        echo "Script: $SCRIPT_PATH"
        echo "Dependencias: $DEPENDENCIES"
        echo
        
        # Cambiar al directorio del script
        cd "$(dirname "$SCRIPT_PATH")"
        
        # Ejecutar con timeout
        if timeout "$INSTALL_TIMEOUT" bash "$SCRIPT_PATH"; then
            echo
            echo "=== Instalación completada exitosamente ==="
            echo "Fecha fin: $(date)"
            exit_code=0
        else
            echo
            echo "=== Instalación falló o timeout ==="
            echo "Fecha fin: $(date)"
            exit_code=1
        fi
    } &> "$log_file"
    
    exit_code=$?
    
    # Actualizar estado final
    if [[ $exit_code -eq 0 ]]; then
        update_job_status "$job_id" "$JOB_COMPLETED" "EXIT_CODE=$exit_code"
        update_job_status "$job_id" "$JOB_COMPLETED" "FINISHED=$(date +%s)"
        success "✅ Módulo $MODULE instalado exitosamente"
    else
        update_job_status "$job_id" "$JOB_FAILED" "EXIT_CODE=$exit_code"
        update_job_status "$job_id" "$JOB_FAILED" "FINISHED=$(date +%s)"
        error "❌ Fallo al instalar módulo $MODULE"
    fi
    
    return $exit_code
}

# Verificar si las dependencias están completadas
check_dependencies_completed() {
    local dependencies="$1"
    local all_completed=true
    
    if [[ -z "$dependencies" ]]; then
        return 0  # Sin dependencias
    fi
    
    for dep in $dependencies; do
        local dep_job_id="${dep//[^a-zA-Z0-9]/_}"
        local status=$(get_job_status "$dep_job_id")
        
        if [[ "$status" != "$JOB_COMPLETED" ]]; then
            all_completed=false
            break
        fi
    done
    
    $all_completed
}

# Monitor de trabajos paralelos
job_monitor() {
    debug "Iniciando monitor de trabajos..."
    
    local active_jobs=0
    local completed_jobs=0
    local failed_jobs=0
    local total_jobs=$(ls "$JOBS_DIR"/*.job 2>/dev/null | wc -l)
    
    while true; do
        # Contar trabajos por estado
        local pending_jobs=$(list_jobs_by_status "$JOB_PENDING" | wc -l)
        local running_jobs=$(list_jobs_by_status "$JOB_RUNNING" | wc -l)
        completed_jobs=$(list_jobs_by_status "$JOB_COMPLETED" | wc -l)
        failed_jobs=$(list_jobs_by_status "$JOB_FAILED" | wc -l)
        
        # Mostrar progreso
        local progress=$(( (completed_jobs + failed_jobs) * 100 / total_jobs ))
        printf "\r${CYAN}Progreso: %d%% | Ejecutándose: %d | Completados: %d | Fallidos: %d${COLOR_RESET}" \
               "$progress" "$running_jobs" "$completed_jobs" "$failed_jobs"
        
        # Verificar si todos los trabajos han terminado
        if [[ $((completed_jobs + failed_jobs)) -eq $total_jobs ]]; then
            echo
            break
        fi
        
        # Buscar trabajos listos para ejecutar
        for job_file in "$JOBS_DIR"/*.job; do
            [[ -f "$job_file" ]] || continue
            
            local job_id=$(basename "$job_file" .job)
            local status=$(get_job_status "$job_id")
            
            # Si el trabajo está pendiente y hay slots disponibles
            if [[ "$status" == "$JOB_PENDING" ]] && [[ $running_jobs -lt $MAX_PARALLEL_JOBS ]]; then
                # Verificar dependencias
                source "$job_file"
                
                if check_dependencies_completed "$DEPENDENCIES"; then
                    # Ejecutar trabajo en background
                    execute_job "$job_id" &
                    ((running_jobs++))
                    debug "Trabajo iniciado: $job_id"
                fi
            fi
        done
        
        # Limpiar procesos terminados
        wait -n 2>/dev/null || true
        
        sleep 1
    done
    
    # Esperar a que terminen todos los trabajos
    wait
    
    echo
    success "✅ Monitor de trabajos finalizado"
}

# =====================================================
# 🎯 INSTALADOR PARALELO PRINCIPAL
# =====================================================

# Instalar módulos en paralelo
install_modules_parallel() {
    local modules=("$@")
    
    if [[ ${#modules[@]} -eq 0 ]]; then
        warn "No hay módulos para instalar"
        return 0
    fi
    
    log "🚀 Iniciando instalación paralela de ${#modules[@]} módulos..."
    
    # Inicializar sistema
    init_parallel_installer
    
    # Crear grafo de dependencias
    create_dependency_graph "${modules[@]}"
    
    # Resolver orden topológico (opcional, para optimización)
    local ordered_modules=()
    if mapfile -t ordered_modules < <(resolve_topological_order 2>/dev/null); then
        debug "Usando orden topológico optimizado"
        modules=("${ordered_modules[@]}")
    fi
    
    # Crear trabajos para cada módulo
    local job_ids=()
    for module in "${modules[@]}"; do
        local module_path="$MODULES_DIR/${module/:/\/}"
        local script_path="$module_path/install.sh"
        
        if [[ ! -f "$script_path" ]]; then
            warn "Script de instalación no encontrado: $module"
            continue
        fi
        
        # Extraer dependencias
        local dependencies=""
        if [[ -f "$script_path" ]]; then
            dependencies=$(grep -o 'MODULE_DEPENDENCIES=([^)]*)' "$script_path" 2>/dev/null | \
                          sed 's/MODULE_DEPENDENCIES=(\([^)]*\))/\1/' | \
                          tr -d '"' || true)
        fi
        
        # Crear trabajo
        local job_id=$(create_job "$module" "$script_path" "$dependencies")
        job_ids+=("$job_id")
    done
    
    if [[ ${#job_ids[@]} -eq 0 ]]; then
        error "No se pudieron crear trabajos de instalación"
        return 1
    fi
    
    success "✅ ${#job_ids[@]} trabajos creados"
    
    # Ejecutar monitor de trabajos
    job_monitor
    
    # Generar reporte final
    generate_installation_report "${job_ids[@]}"
}

# =====================================================
# 📊 REPORTES Y ESTADÍSTICAS
# =====================================================

# Generar reporte de instalación
generate_installation_report() {
    local job_ids=("$@")
    local report_file="$PARALLEL_WORK_DIR/installation_report.txt"
    
    {
        echo "=== REPORTE DE INSTALACIÓN PARALELA ==="
        echo "Fecha: $(date)"
        echo "Total de módulos: ${#job_ids[@]}"
        echo "Jobs paralelos máximos: $MAX_PARALLEL_JOBS"
        echo
        
        # Estadísticas
        local completed=0
        local failed=0
        local total_time=0
        
        echo "=== RESULTADOS POR MÓDULO ==="
        for job_id in "${job_ids[@]}"; do
            local job_file="$JOBS_DIR/${job_id}.job"
            
            if [[ -f "$job_file" ]]; then
                source "$job_file"
                
                local status=$(get_job_status "$job_id")
                local duration=""
                
                if [[ -n "$STARTED" ]] && [[ -n "$FINISHED" ]]; then
                    duration=$(( FINISHED - STARTED ))
                    total_time=$((total_time + duration))
                fi
                
                echo "- $MODULE: $status${duration:+ (${duration}s)}"
                
                case "$status" in
                    "$JOB_COMPLETED") ((completed++)) ;;
                    "$JOB_FAILED") ((failed++)) ;;
                esac
            fi
        done
        
        echo
        echo "=== RESUMEN ==="
        echo "Completados: $completed"
        echo "Fallidos: $failed"
        echo "Tiempo total de instalación: ${total_time}s"
        echo "Promedio por módulo: $(( completed > 0 ? total_time / completed : 0 ))s"
    } > "$report_file"
    
    # Mostrar resumen en consola
    echo
    echo -e "${BOLD}${BLUE}📊 REPORTE DE INSTALACIÓN${COLOR_RESET}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Completados: ${GREEN}$completed${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Fallidos: ${RED}$failed${COLOR_RESET}"
    echo -e "${CYAN}│${COLOR_RESET} Tiempo total: ${total_time}s"
    echo -e "${CYAN}│${COLOR_RESET} Reporte completo: $report_file"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${COLOR_RESET}"
    
    # Mostrar logs de módulos fallidos
    if [[ $failed -gt 0 ]]; then
        echo
        echo -e "${RED}❌ MÓDULOS FALLIDOS:${COLOR_RESET}"
        for job_id in "${job_ids[@]}"; do
            local status=$(get_job_status "$job_id")
            if [[ "$status" == "$JOB_FAILED" ]]; then
                local job_file="$JOBS_DIR/${job_id}.job"
                source "$job_file"
                echo -e "  - $MODULE (log: $LOGS_DIR/${job_id}.log)"
            fi
        done
    fi
    
    return $failed
}

# Limpiar datos de instalación paralela
cleanup_parallel_data() {
    debug "Limpiando datos de instalación paralela..."
    
    if [[ -d "$PARALLEL_WORK_DIR" ]]; then
        # Mantener logs por un tiempo, limpiar el resto
        find "$PARALLEL_WORK_DIR" -name "*.job" -o -name "*.status" -delete 2>/dev/null || true
        success "✅ Datos de instalación paralela limpiados"
    fi
}

# =====================================================
# 🔧 FUNCIONES DE INTERFAZ
# =====================================================

# Función principal del instalador paralelo
parallel_installer_main() {
    local action="${1:-help}"
    shift || true
    
    case "$action" in
        install)
            install_modules_parallel "$@"
            ;;
        cleanup)
            cleanup_parallel_data
            ;;
        monitor)
            job_monitor
            ;;
        status)
            show_cache_stats
            ;;
        help|*)
            cat << 'EOF'
Instalador Paralelo - Arch Dream Machine

Uso: parallel_installer_main <acción> [argumentos]

Acciones:
  install <módulos...>  Instalar módulos en paralelo
  cleanup              Limpiar datos de instalación
  monitor              Monitorear trabajos en ejecución
  status               Mostrar estado del sistema
  help                 Mostrar esta ayuda

Variables de entorno:
  MAX_PARALLEL_JOBS    Número máximo de trabajos simultáneos (default: auto)
  INSTALL_TIMEOUT      Timeout por módulo en segundos (default: 1800)

Ejemplos:
  parallel_installer_main install core:zsh core:bash
  MAX_PARALLEL_JOBS=2 parallel_installer_main install core:zsh
EOF
            ;;
    esac
}

# Exportar funciones principales
export -f init_parallel_installer create_job update_job_status get_job_status
export -f install_modules_parallel execute_job job_monitor
export -f generate_installation_report cleanup_parallel_data
export -f parallel_installer_main

# Variables exportadas
export MAX_PARALLEL_JOBS INSTALL_TIMEOUT DEPENDENCY_TIMEOUT
export PARALLEL_WORK_DIR JOBS_DIR LOGS_DIR STATUS_DIR
export JOB_PENDING JOB_RUNNING JOB_COMPLETED JOB_FAILED JOB_SKIPPED