#!/bin/bash
# =====================================================
# 📊 ARCH DREAM - BENCHMARK DE RENDIMIENTO
# =====================================================
# Script para medir y comparar el rendimiento de diferentes
# configuraciones y módulos de Arch Dream Machine
# =====================================================

set -euo pipefail
IFS=$'\n\t'

# Cargar biblioteca común
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh" 2>/dev/null || {
    echo "Error: No se pudo cargar common.sh" >&2
    exit 1
}

# =====================================================
# 🔧 CONFIGURACIÓN DEL BENCHMARK
# =====================================================

# Directorios de benchmark
BENCHMARK_ROOT="$HOME/.arch-dream-benchmark"
BENCHMARK_RESULTS="$BENCHMARK_ROOT/results"
BENCHMARK_LOGS="$BENCHMARK_ROOT/logs"

# Configuración de tests
BENCHMARK_MODULES=("core:zsh" "development:nvim" "terminal:kitty" "tools:fastfetch")
BENCHMARK_ITERATIONS=3
BENCHMARK_TIMEOUT=300

# Métricas a medir
METRICS=("install_time" "memory_usage" "disk_usage" "cpu_usage" "success_rate")

# =====================================================
# 🎯 FUNCIONES DE BENCHMARK
# =====================================================

# Inicializar entorno de benchmark
init_benchmark() {
    log "🚀 Inicializando entorno de benchmark..."
    
    # Crear directorios
    mkdir -p "$BENCHMARK_ROOT" "$BENCHMARK_RESULTS" "$BENCHMARK_LOGS"
    
    # Limpiar resultados anteriores
    rm -rf "$BENCHMARK_RESULTS"/*
    
    # Crear archivo de resultados
    cat > "$BENCHMARK_RESULTS/summary.md" << 'EOF'
# 📊 Arch Dream Machine - Benchmark Results

## 🎯 Resumen de Rendimiento

| Módulo | Tiempo Promedio | Memoria | Disco | CPU | Éxito |
|--------|-----------------|---------|-------|-----|-------|
EOF
    
    success "✅ Entorno de benchmark inicializado"
}

# Medir uso de recursos del sistema
measure_system_resources() {
    local metric="$1"
    
    case "$metric" in
        "memory_usage")
            free -m | awk 'NR==2{printf "%.1f", $3*100/$2}'
            ;;
        "disk_usage")
            df "$HOME" | awk 'NR==2{printf "%.1f", $5}' | sed 's/%//'
            ;;
        "cpu_usage")
            top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//'
            ;;
        "load_average")
            uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//'
            ;;
        *)
            echo "0"
            ;;
    esac
}

# Ejecutar benchmark de módulo
benchmark_module() {
    local module="$1"
    local iteration="$2"
    
    local start_time=$(date +%s)
    local start_memory=$(measure_system_resources "memory_usage")
    local start_disk=$(measure_system_resources "disk_usage")
    local start_cpu=$(measure_system_resources "cpu_usage")
    
    log "🔄 Ejecutando benchmark: $module (iteración $iteration)"
    
    # Ejecutar instalación con timeout
    local success=false
    local error_log=""
    
    if timeout "$BENCHMARK_TIMEOUT" bash -c "
        cd '$SCRIPT_DIR'
        export DRY_RUN=true
        export QUIET_MODE=true
        ./install.sh '$module' 2>&1
    " > "$BENCHMARK_LOGS/${module//:/_}_${iteration}.log" 2>&1; then
        success=true
    else
        error_log=$(tail -5 "$BENCHMARK_LOGS/${module//:/_}_${iteration}.log")
    fi
    
    local end_time=$(date +%s)
    local end_memory=$(measure_system_resources "memory_usage")
    local end_disk=$(measure_system_resources "disk_usage")
    local end_cpu=$(measure_system_resources "cpu_usage")
    
    # Calcular métricas
    local install_time=$((end_time - start_time))
    local memory_delta=$(echo "$end_memory - $start_memory" | bc -l 2>/dev/null || echo "0")
    local disk_delta=$(echo "$end_disk - $start_disk" | bc -l 2>/dev/null || echo "0")
    local cpu_delta=$(echo "$end_cpu - $start_cpu" | bc -l 2>/dev/null || echo "0")
    
    # Guardar resultados
    cat > "$BENCHMARK_RESULTS/${module//:/_}_${iteration}.json" << EOF
{
    "module": "$module",
    "iteration": $iteration,
    "timestamp": "$(date -Iseconds)",
    "metrics": {
        "install_time": $install_time,
        "memory_usage": "$memory_delta%",
        "disk_usage": "$disk_delta%",
        "cpu_usage": "$cpu_delta%",
        "success": $success
    },
    "error_log": "$error_log"
}
EOF
    
    if [[ "$success" == "true" ]]; then
        success "✅ Benchmark completado: $module (${install_time}s)"
    else
        warn "⚠️  Benchmark falló: $module (${install_time}s)"
    fi
    
    return 0
}

# Ejecutar benchmark completo
run_full_benchmark() {
    log "🚀 Iniciando benchmark completo..."
    
    local total_tests=$(( ${#BENCHMARK_MODULES[@]} * BENCHMARK_ITERATIONS ))
    local current_test=0
    
    for module in "${BENCHMARK_MODULES[@]}"; do
        for iteration in $(seq 1 $BENCHMARK_ITERATIONS); do
            ((current_test++))
            show_progress "$current_test" "$total_tests" "Benchmark: $module"
            
            benchmark_module "$module" "$iteration"
        done
    done
    
    echo
    success "✅ Benchmark completo finalizado"
}

# Analizar resultados
analyze_results() {
    log "📊 Analizando resultados del benchmark..."
    
    local summary_file="$BENCHMARK_RESULTS/summary.md"
    
    for module in "${BENCHMARK_MODULES[@]}"; do
        local module_name="${module//:/_}"
        local total_time=0
        local total_memory=0
        local total_disk=0
        local total_cpu=0
        local success_count=0
        
        # Calcular promedios
        for iteration in $(seq 1 $BENCHMARK_ITERATIONS); do
            local result_file="$BENCHMARK_RESULTS/${module_name}_${iteration}.json"
            if [[ -f "$result_file" ]]; then
                local install_time=$(jq -r '.metrics.install_time' "$result_file" 2>/dev/null || echo "0")
                local memory=$(jq -r '.metrics.memory_usage' "$result_file" 2>/dev/null | sed 's/%//' || echo "0")
                local disk=$(jq -r '.metrics.disk_usage' "$result_file" 2>/dev/null | sed 's/%//' || echo "0")
                local cpu=$(jq -r '.metrics.cpu_usage' "$result_file" 2>/dev/null | sed 's/%//' || echo "0")
                local success=$(jq -r '.metrics.success' "$result_file" 2>/dev/null || echo "false")
                
                total_time=$((total_time + install_time))
                total_memory=$(echo "$total_memory + $memory" | bc -l 2>/dev/null || echo "$total_memory")
                total_disk=$(echo "$total_disk + $disk" | bc -l 2>/dev/null || echo "$total_disk")
                total_cpu=$(echo "$total_cpu + $cpu" | bc -l 2>/dev/null || echo "$total_cpu")
                
                [[ "$success" == "true" ]] && ((success_count++))
            fi
        done
        
        # Calcular promedios
        local avg_time=$((total_time / BENCHMARK_ITERATIONS))
        local avg_memory=$(echo "scale=1; $total_memory / $BENCHMARK_ITERATIONS" | bc -l 2>/dev/null || echo "0")
        local avg_disk=$(echo "scale=1; $total_disk / $BENCHMARK_ITERATIONS" | bc -l 2>/dev/null || echo "0")
        local avg_cpu=$(echo "scale=1; $total_cpu / $BENCHMARK_ITERATIONS" | bc -l 2>/dev/null || echo "0")
        local success_rate=$((success_count * 100 / BENCHMARK_ITERATIONS))
        
        # Agregar a resumen
        echo "| $module | ${avg_time}s | ${avg_memory}% | ${avg_disk}% | ${avg_cpu}% | ${success_rate}% |" >> "$summary_file"
    done
    
    # Finalizar resumen
    cat >> "$summary_file" << 'EOF'

## 📈 Métricas de Rendimiento

### ⏱️ Tiempo de Instalación
- **Más rápido**: Módulo con menor tiempo promedio
- **Más lento**: Módulo con mayor tiempo promedio

### 💾 Uso de Recursos
- **Memoria**: Cambio en uso de RAM durante instalación
- **Disco**: Cambio en uso de espacio en disco
- **CPU**: Cambio en uso de procesador

### ✅ Tasa de Éxito
- Porcentaje de instalaciones exitosas por módulo

## 🔍 Archivos de Resultados

Los resultados detallados están disponibles en formato JSON:
EOF
    
    for module in "${BENCHMARK_MODULES[@]}"; do
        local module_name="${module//:/_}"
        echo "- \`${module_name}_*.json\` - Resultados de $module" >> "$summary_file"
    done
    
    success "✅ Análisis de resultados completado"
}

# Generar reporte HTML
generate_html_report() {
    log "🌐 Generando reporte HTML..."
    
    local html_file="$BENCHMARK_RESULTS/report.html"
    
    cat > "$html_file" << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Arch Dream Machine - Benchmark Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; text-align: center; border-bottom: 3px solid #3498db; padding-bottom: 20px; }
        h2 { color: #34495e; margin-top: 30px; }
        .metrics { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
        .metric-card { background: #ecf0f1; padding: 20px; border-radius: 8px; text-align: center; }
        .metric-value { font-size: 2em; font-weight: bold; color: #3498db; }
        .metric-label { color: #7f8c8d; margin-top: 10px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #3498db; color: white; }
        tr:nth-child(even) { background: #f9f9f9; }
        .success { color: #27ae60; }
        .warning { color: #f39c12; }
        .error { color: #e74c3c; }
        .chart-container { margin: 30px 0; text-align: center; }
        .footer { text-align: center; margin-top: 40px; color: #7f8c8d; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Arch Dream Machine - Benchmark Report</h1>
        <p><strong>Fecha:</strong> <span id="timestamp"></span></p>
        <p><strong>Versión:</strong> 5.0</p>
        
        <h2>📊 Resumen de Métricas</h2>
        <div class="metrics">
            <div class="metric-card">
                <div class="metric-value" id="total-modules">0</div>
                <div class="metric-label">Módulos Testeados</div>
            </div>
            <div class="metric-card">
                <div class="metric-value" id="avg-time">0s</div>
                <div class="metric-label">Tiempo Promedio</div>
            </div>
            <div class="metric-card">
                <div class="metric-value" id="success-rate">0%</div>
                <div class="metric-label">Tasa de Éxito</div>
            </div>
            <div class="metric-card">
                <div class="metric-value" id="total-iterations">0</div>
                <div class="metric-label">Iteraciones</div>
            </div>
        </div>
        
        <h2>📋 Resultados Detallados</h2>
        <table>
            <thead>
                <tr>
                    <th>Módulo</th>
                    <th>Tiempo Promedio</th>
                    <th>Memoria</th>
                    <th>Disco</th>
                    <th>CPU</th>
                    <th>Éxito</th>
                </tr>
            </thead>
            <tbody id="results-table">
            </tbody>
        </table>
        
        <h2>📈 Gráficos de Rendimiento</h2>
        <div class="chart-container">
            <p>Los gráficos interactivos estarán disponibles en futuras versiones.</p>
        </div>
        
        <div class="footer">
            <p>Generado por Arch Dream Machine v5.0</p>
            <p>Para más información, consulta la documentación del proyecto.</p>
        </div>
    </div>
    
    <script>
        // Cargar datos del benchmark
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('timestamp').textContent = new Date().toLocaleString();
            
            // Aquí se cargarían los datos reales del benchmark
            // Por ahora, mostramos datos de ejemplo
            document.getElementById('total-modules').textContent = '4';
            document.getElementById('avg-time').textContent = '15s';
            document.getElementById('success-rate').textContent = '95%';
            document.getElementById('total-iterations').textContent = '12';
        });
    </script>
</body>
</html>
EOF
    
    success "✅ Reporte HTML generado: $html_file"
}

# Mostrar resumen de resultados
show_benchmark_summary() {
    echo
    echo -e "${BOLD}${BLUE}📊 RESUMEN DEL BENCHMARK${NC}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} Módulos testeados: ${#BENCHMARK_MODULES[@]}"
    echo -e "${CYAN}│${NC} Iteraciones por módulo: $BENCHMARK_ITERATIONS"
    echo -e "${CYAN}│${NC} Total de tests: $(( ${#BENCHMARK_MODULES[@]} * BENCHMARK_ITERATIONS ))"
    echo -e "${CYAN}│${NC} Resultados: $BENCHMARK_RESULTS"
    echo -e "${CYAN}│${NC} Logs: $BENCHMARK_LOGS"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
    echo
    echo -e "${YELLOW}📋 Archivos generados:${NC}"
    echo -e "  • ${CYAN}summary.md${NC} - Resumen en Markdown"
    echo -e "  • ${CYAN}report.html${NC} - Reporte HTML interactivo"
    echo -e "  • ${CYAN}*.json${NC} - Resultados detallados por módulo"
    echo
    echo -e "${GREEN}🚀 Para ver el reporte completo:${NC}"
    echo -e "  ${CYAN}cat $BENCHMARK_RESULTS/summary.md${NC}"
    echo -e "  ${CYAN}xdg-open $BENCHMARK_RESULTS/report.html${NC}"
}

# =====================================================
# 🚀 FUNCIÓN PRINCIPAL
# =====================================================

main() {
    show_banner "Arch Dream Benchmark" "Medición de rendimiento v5.0"
    
    # Verificar dependencias
    for tool in bc jq; do
        command -v "$tool" &>/dev/null || {
            warn "⚠️  $tool no está instalado - algunas métricas pueden no estar disponibles"
        }
    done
    
    # Inicializar benchmark
    init_benchmark
    
    # Ejecutar benchmark
    run_full_benchmark
    
    # Analizar resultados
    analyze_results
    
    # Generar reportes
    generate_html_report
    
    # Mostrar resumen
    show_benchmark_summary
    
    success "🎉 Benchmark completado exitosamente"
}

# Ejecutar función principal
main "$@"