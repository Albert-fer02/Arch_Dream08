# 🚀 BASH Modular - Arch Dream v4.3

## 📋 Descripción

Esta es la versión modularizada de la configuración de BASH para Arch Dream. El código original de 136 líneas ha sido dividido en módulos más pequeños y organizados para facilitar el mantenimiento, la personalización y la extensibilidad.

**Nueva característica**: El `bashrc.root` ahora también usa el sistema modular, compartiendo la base común con el `bashrc` normal.

## 🏗️ Estructura Modular

```
modules/core/bash/
├── config/                    # Configuración base
│   ├── shell-base.bash       # Cargador del shell base
│   ├── history.bash          # Configuración del historial
│   ├── completion.bash       # Configuración de completions

│   └── environment.bash      # Variables de entorno
├── aliases/                  # Aliases organizados por categoría
│   ├── basic.bash            # Aliases básicos de navegación
│   ├── git.bash              # Aliases de Git
│   └── system.bash           # Aliases del sistema y Arch
├── functions/                # Funciones organizadas por categoría
│   ├── basic.bash            # Funciones básicas útiles
│   └── arch.bash             # Funciones específicas de Arch
├── plugins/                  # Gestión de plugins
│   └── fzf.bash              # Integración de FZF
├── ui/                       # Interfaz de usuario
│   └── welcome.bash          # Mensaje de bienvenida
├── advanced/                 # Funcionalidades avanzadas
│   └── lesspipe.bash         # Configuración de lesspipe
├── bashrc.modular            # Archivo principal modular (usuario normal)
├── bashrc.root.modular       # Archivo principal modular (root)
├── bashrc.root               # Archivo root (puede ser modular o original)
├── install-modular.sh        # Script de instalación para usuario normal
├── update-root-to-modular.sh # Script para actualizar root a modular
└── README-MODULAR.md         # Esta documentación
```

## 🚀 Instalación

### Instalación para Usuario Normal

```bash
# Desde el directorio del proyecto
cd modules/core/bash
chmod +x install-modular.sh
./install-modular.sh
```

### Actualización de Root a Modular

```bash
# Actualizar bashrc.root para usar sistema modular
cd modules/core/bash
chmod +x update-root-to-modular.sh
./update-root-to-modular.sh

# Solo probar la nueva configuración
./update-root-to-modular.sh --test

# Actualizar y mostrar diferencias
./update-root-to-modular.sh --diff
```

### Opciones de Instalación

```bash
# Solo verificar archivos
./install-modular.sh --verify

# Solo probar configuración
./install-modular.sh --test

# Instalación completa
./install-modular.sh

# Mostrar ayuda
./install-modular.sh --help
```

## 🔄 Arquitectura de Configuración

### 📁 **Base Compartida (bashrc.modular)**
- Configuración del historial
- Completions y estilos
- Variables de entorno básicas
- Integración de FZF
- Aliases y funciones comunes
- Configuración de lesspipe

### 🔴 **Configuración Root (bashrc.root.modular)**
- **Hereda** toda la funcionalidad base del `bashrc.modular`
- **Agrega** funcionalidades específicas para root:
  - Gestión de servicios del sistema
  - Aliases de seguridad
  - Funciones de mantenimiento
  - Configuración específica de root
  - Optimizaciones de seguridad

### ✅ **Ventajas de la Nueva Arquitectura**

1. **DRY (Don't Repeat Yourself)**: No hay duplicación de código
2. **Mantenimiento Unificado**: Cambios en la base se reflejan en ambos
3. **Personalización Específica**: Root mantiene sus funcionalidades únicas
4. **Consistencia**: Misma experiencia base para usuario y root
5. **Eficiencia**: Menos líneas de código total

## 📊 Estadísticas de la Modularización

### **Antes (Duplicación)**
- `bashrc`: 136 líneas
- `bashrc.root`: 153 líneas
- **Total**: 289 líneas con duplicación

### **Después (Modular)**
- `bashrc.modular`: 95 líneas (base)
- `bashrc.root.modular`: ~180 líneas (base + root-specific)
- **Total**: ~275 líneas sin duplicación
- **Reducción**: 5% menos código, pero 0% duplicación

## 🔧 Personalización

### Agregar Nuevos Aliases

1. **Crear nuevo archivo de aliases:**
   ```bash
   # ~/.bash/aliases/custom.bash
   alias myalias='mycommand'
   ```

2. **Agregar al bashrc principal:**
   ```bash
   # En ~/.bashrc
   source "${BASH_SOURCE[0]%/*}/aliases/custom.bash"
   ```

### Agregar Nuevas Funciones

1. **Crear nuevo archivo de funciones:**
   ```bash
   # ~/.bash/functions/custom.bash
   my_function() {
       echo "Mi función personalizada"
   }
   ```

2. **Agregar al bashrc principal:**
   ```bash
   # En ~/.bashrc
   source "${BASH_SOURCE[0]%/*}/functions/custom.bash"
   ```

### Modificar Configuración Existente

- **Historial:** Editar `~/.bash/config/history.bash`
- **Completions:** Editar `~/.bash/config/completion.bash`
- **Variables de entorno:** Editar `~/.bash/config/environment.bash`
- **FZF:** Editar `~/.bash/plugins/fzf.bash`

## 🔄 Migración desde Configuración Original

### Backup Automático
Los scripts de instalación crean automáticamente backups con timestamp.

### Restauración
```bash
# Restaurar configuración original de usuario
cp ~/.bashrc.backup.YYYYMMDD_HHMMSS ~/.bashrc

# Restaurar configuración original de root
cp bashrc.root.backup.YYYYMMDD_HHMMSS bashrc.root
```

### Comparación
```bash
# Comparar configuración modular con original
diff ~/.bashrc ~/.bashrc.backup.YYYYMMDD_HHMMSS

# Comparar configuración root modular con original
diff bashrc.root bashrc.root.backup.YYYYMMDD_HHMMSS
```

## 🧪 Testing

### Verificación de Sintaxis
```bash
# Verificar sintaxis de configuración de usuario
bash -n ~/.bashrc

# Verificar sintaxis de configuración de root
bash -n bashrc.root
```

### Verificación de Archivos
```bash
# Verificar que todos los módulos estén presentes
./install-modular.sh --verify
```

### Test de Configuración
```bash
# Probar configuración de usuario sin instalar
./install-modular.sh --test

# Probar configuración de root sin instalar
./update-root-to-modular.sh --test
```

## 🐛 Troubleshooting

### Problemas Comunes

1. **Error de sintaxis:**
   ```bash
   bash -n ~/.bashrc
   bash -n bashrc.root
   ```

2. **Módulo no encontrado:**
   ```bash
   ./install-modular.sh --verify
   ```

3. **Permisos insuficientes:**
   ```bash
   chmod +x install-modular.sh
   chmod +x update-root-to-modular.sh
   ```

### Logs de Debug
```bash
# Habilitar debug (exportar variable)
export ARCH_DREAM_DEBUG=1
```

## 📚 Referencias

- [Bash Documentation](https://www.gnu.org/software/bash/manual/)

- [Arch Linux Wiki](https://wiki.archlinux.org/)

## 🤝 Contribución

Para contribuir a la configuración modular:

1. **Fork del repositorio**
2. **Crear rama para feature:** `git checkout -b feature/nueva-funcionalidad`
3. **Hacer cambios en módulos específicos**
4. **Probar configuraciones:** `./install-modular.sh --test` y `./update-root-to-modular.sh --test`
5. **Commit y push:** `git commit -am 'Agregar nueva funcionalidad'`
6. **Crear Pull Request**

## 📄 Licencia

Esta configuración está bajo la misma licencia que el proyecto Arch Dream.

---

**🚀 ¡Disfruta de tu BASH modular y optimizado!**

**🔴 ¡Ahora también para root con la misma base modular!**
