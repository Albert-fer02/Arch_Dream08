# 🚀 ZSH Modular - Arch Dream v4.3

## 📋 Descripción

Esta es la versión modularizada de la configuración de ZSH para Arch Dream. El código original de 535 líneas ha sido dividido en módulos más pequeños y organizados para facilitar el mantenimiento, la personalización y la extensibilidad.

**Nueva característica**: El `zshrc.root` ahora también usa el sistema modular, compartiendo la base común con el `zshrc` normal.

## 🏗️ Estructura Modular

```
modules/core/zsh/
├── config/                    # Configuración base
│   ├── history.zsh          # Configuración del historial
│   ├── completion.zsh       # Configuración de completions
│   ├── starship.zsh         # Configuración de Starship prompt
│   └── environment.zsh      # Variables de entorno
├── aliases/                  # Aliases organizados por categoría
│   ├── basic.zsh            # Aliases básicos de navegación
│   ├── git.zsh              # Aliases de Git
│   ├── system.zsh           # Aliases del sistema y Arch
│   └── redteam.zsh          # Aliases para Red Team
├── functions/                # Funciones organizadas por categoría
│   ├── basic.zsh            # Funciones básicas útiles
│   ├── arch.zsh             # Funciones específicas de Arch
│   └── redteam.zsh          # Funciones para Red Team
├── plugins/                  # Gestión de plugins
│   └── plugin-manager.zsh   # Sistema de lazy loading
├── keybindings/              # Configuración de teclas
│   └── keybindings.zsh      # Key bindings personalizados
├── ui/                       # Interfaz de usuario
│   ├── welcome.zsh          # Mensaje de bienvenida
│   └── prompt.zsh           # Prompt personalizado
├── advanced/                 # Funcionalidades avanzadas
│   ├── lazy-loading.zsh     # Lazy loading de herramientas
│   └── security.zsh         # Configuración de seguridad
├── zshrc.modular            # Archivo principal modular (usuario normal)
├── zshrc.root.modular       # Archivo principal modular (root)
├── zshrc.root               # Archivo root (puede ser modular o original)
├── install-modular.sh       # Script de instalación para usuario normal
├── update-root-to-modular.sh # Script para actualizar root a modular
└── README-MODULAR.md        # Esta documentación
```

## 🚀 Instalación

### Instalación para Usuario Normal

```bash
# Desde el directorio del proyecto
cd modules/core/zsh
chmod +x install-modular.sh
./install-modular.sh
```

### Actualización de Root a Modular

```bash
# Actualizar zshrc.root para usar sistema modular
cd modules/core/zsh
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

### 📁 **Base Compartida (zshrc.modular)**
- Configuración del historial
- Completions y estilos
- Variables de entorno básicas
- Sistema de plugins
- Aliases y funciones comunes
- Key bindings estándar

### 🔴 **Configuración Root (zshrc.root.modular)**
- **Hereda** toda la funcionalidad base del `zshrc.modular`
- **Agrega** funcionalidades específicas para root:
  - Gestión de servicios del sistema
  - Aliases de seguridad
  - Funciones de mantenimiento
  - Configuración de Zinit
  - Optimizaciones de seguridad

### ✅ **Ventajas de la Nueva Arquitectura**

1. **DRY (Don't Repeat Yourself)**: No hay duplicación de código
2. **Mantenimiento Unificado**: Cambios en la base se reflejan en ambos
3. **Personalización Específica**: Root mantiene sus funcionalidades únicas
4. **Consistencia**: Misma experiencia base para usuario y root
5. **Eficiencia**: Menos líneas de código total

## 📊 Estadísticas de la Modularización

### **Antes (Duplicación)**
- `zshrc`: 535 líneas
- `zshrc.root`: 361 líneas
- **Total**: 896 líneas con duplicación

### **Después (Modular)**
- `zshrc.modular`: 106 líneas (base)
- `zshrc.root.modular`: ~200 líneas (base + root-specific)
- **Total**: ~306 líneas sin duplicación
- **Reducción**: 66% menos código

## 🔧 Personalización

### Agregar Nuevos Aliases

1. **Crear nuevo archivo de aliases:**
   ```bash
   # ~/.zsh/aliases/custom.zsh
   alias myalias='mycommand'
   ```

2. **Agregar al zshrc principal:**
   ```bash
   # En ~/.zshrc
   source "${0:A:h}/aliases/custom.zsh"
   ```

### Agregar Nuevas Funciones

1. **Crear nuevo archivo de funciones:**
   ```bash
   # ~/.zsh/functions/custom.zsh
   my_function() {
       echo "Mi función personalizada"
   }
   ```

2. **Agregar al zshrc principal:**
   ```bash
   # En ~/.zshrc
   source "${0:A:h}/functions/custom.zsh"
   ```

### Modificar Configuración Existente

- **Historial:** Editar `~/.zsh/config/history.zsh`
- **Completions:** Editar `~/.zsh/config/completion.zsh`
- **Variables de entorno:** Editar `~/.zsh/config/environment.zsh`
- **Key bindings:** Editar `~/.zsh/keybindings/keybindings.zsh`

## 🔄 Migración desde Configuración Original

### Backup Automático
Los scripts de instalación crean automáticamente backups con timestamp.

### Restauración
```bash
# Restaurar configuración original de usuario
cp ~/.zshrc.backup.YYYYMMDD_HHMMSS ~/.zshrc

# Restaurar configuración original de root
cp zshrc.root.backup.YYYYMMDD_HHMMSS zshrc.root
```

### Comparación
```bash
# Comparar configuración modular con original
diff ~/.zshrc ~/.zshrc.backup.YYYYMMDD_HHMMSS

# Comparar configuración root modular con original
diff zshrc.root zshrc.root.backup.YYYYMMDD_HHMMSS
```

## 🧪 Testing

### Verificación de Sintaxis
```bash
# Verificar sintaxis de configuración de usuario
zsh -n ~/.zshrc

# Verificar sintaxis de configuración de root
zsh -n zshrc.root
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
   zsh -n ~/.zshrc
   zsh -n zshrc.root
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
# Habilitar profiling (descomenta en zshrc)
zmodload zsh/zprof
```

## 📚 Referencias

- [ZSH Documentation](https://zsh.sourceforge.io/Doc/)
- [Starship Documentation](https://starship.rs/)
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

**🚀 ¡Disfruta de tu ZSH modular y optimizado!**

**🔴 ¡Ahora también para root con la misma base modular!**
