# 🚀 ARCH DREAM MACHINE - INSTALADORES OPTIMIZADOS

## 📋 Resumen de Mejoras v5.0

La versión 5.0 de Arch Dream Machine introduce una arquitectura completamente modular y optimizada, siguiendo las mejores prácticas de desarrollo en bash y zsh.

## 🏗️ Nueva Arquitectura Modular

### 📁 Estructura de Archivos

```
Arch_Dream08/
├── install.sh                 # 🚀 Instalador principal optimizado
├── one-liner-install.sh      # ⚡ Instalación de un solo comando
├── lib/                       # 🧩 Bibliotecas modulares
│   ├── common.sh             # 🔧 Funciones comunes y utilidades
│   ├── package-manager.sh    # 📦 Gestión inteligente de paquetes
│   ├── config-manager.sh     # ⚙️  Gestión de configuraciones
│   ├── module-manager.sh     # 🧩 Gestión de módulos
│   └── cache.sh              # 💾 Sistema de caché
├── modules/                   # 🧩 Módulos de configuración
│   ├── core/                 # 🖥️  Configuraciones del sistema
│   ├── development/          # 💻 Herramientas de desarrollo
│   ├── terminal/             # 🖥️  Configuraciones de terminal
│   ├── tools/                # 🛠️  Utilidades del sistema
│   └── themes/               # 🎨 Temas visuales
└── docs/                     # 📚 Documentación
```

## 🚀 Instalador Principal (`install.sh`)

### ✨ Características Principales

- **Arquitectura modular**: Funcionalidades separadas en módulos específicos
- **Gestión inteligente de dependencias**: Resolución automática de dependencias entre módulos
- **Instalación paralela**: Soporte para instalación simultánea de múltiples módulos
- **Modo DRY-RUN**: Simulación de instalación sin hacer cambios
- **Sistema de backup automático**: Respaldo automático de configuraciones existentes
- **Logging avanzado**: Sistema de logging con diferentes niveles y colores
- **Validación robusta**: Verificaciones del sistema y módulos antes de la instalación

### 🔧 Opciones de Línea de Comandos

```bash
# Instalación completa
./install.sh --all

# Módulos específicos
./install.sh core:zsh development:nvim

# Modo simulación
./install.sh --dry-run --all

# Instalación paralela
./install.sh --parallel development:*

# Instalación forzada sin confirmación
./install.sh --force --all

# Modo silencioso
./install.sh --quiet --all

# Modo verbose para debugging
./install.sh --verbose core:zsh
```

### 🎯 Ejemplos de Uso

```bash
# Instalar solo el shell Zsh
./install.sh core:zsh

# Instalar herramientas de desarrollo
./install.sh development:*

# Instalar terminal y temas
./install.sh terminal:kitty themes:catppuccin

# Simular instalación completa
./install.sh --dry-run --all

# Instalación paralela de módulos de desarrollo
./install.sh --parallel development:nvim development:web
```

## ⚡ Instalación de Un Solo Comando (`one-liner-install.sh`)

### 🚀 Uso Rápido

```bash
# Instalación directa desde GitHub
curl -sSL https://raw.githubusercontent.com/Albert-fer02/Arch_Dream08/main/one-liner-install.sh | bash

# O descargar y ejecutar
wget -O - https://raw.githubusercontent.com/Albert-fer02/Arch_Dream08/main/one-liner-install.sh | bash
```

### 📋 Opciones de Instalación

1. **Instalación completa** - Todos los módulos
2. **Instalación personalizada** - Seleccionar módulos específicos
3. **Modo simulación** - Ver qué se instalaría sin hacer cambios
4. **Instalación silenciosa** - Sin preguntas ni confirmaciones

## 🧩 Sistema de Módulos

### 🔧 Estructura de Módulo

Cada módulo sigue una estructura estándar:

```
modules/category/module/
├── install.sh           # Script de instalación del módulo
├── README.md            # Documentación del módulo
├── config files         # Archivos de configuración
└── dependencies         # Dependencias y metadatos
```

### 📦 Módulos Disponibles

#### 🖥️ Core (Sistema)
- **`core:zsh`** - Configuración avanzada de Zsh con Powerlevel10k y Zinit
- **`core:bash`** - Configuración de fallback para Bash

#### 💻 Development (Desarrollo)
- **`development:nvim`** - Neovim con LazyVim y plugins AI
- **`development:web`** - Herramientas de desarrollo web

#### 🖥️ Terminal
- **`terminal:kitty`** - Emulador de terminal con aceleración GPU

#### 🛠️ Tools (Utilidades)
- **`tools:fastfetch`** - Información del sistema con temas personalizados
- **`tools:nano`** - Editor nano con configuración avanzada

#### 🎨 Themes (Temas)
- **`themes:catppuccin`** - Tema Catppuccin optimizado para cuidar los ojos (Mocha/Latte)

### 🔗 Dependencias de Módulos

Los módulos pueden declarar dependencias de otros módulos:

```bash
# En install.sh del módulo
MODULE_DEPENDENCIES=("core:zsh" "tools:fastfetch")
```

## 📦 Gestor de Paquetes (`lib/package-manager.sh`)

### ✨ Características

- **Detección automática de helpers AUR** (yay, paru, pikaur, aurman)
- **Fallback inteligente**: Repositorios oficiales → AUR
- **Instalación en lote**: Agrupación eficiente de paquetes
- **Verificación de integridad**: Comprobación de paquetes instalados
- **Mantenimiento del sistema**: Actualización, limpieza y optimización

### 🔧 Funciones Principales

```bash
# Instalar paquete con fallback inteligente
install_package "neovim"

# Instalar múltiples paquetes
install_packages "git" "vim" "htop"

# Instalar solo desde repositorios oficiales
install_official_package "zsh"



# Actualizar sistema
update_system

# Limpiar caché
clean_package_cache
```

## ⚙️ Gestor de Configuraciones (`lib/config-manager.sh`)

### ✨ Características

- **Sistema de backup automático** con compresión opcional
- **Gestión inteligente de symlinks** con verificación de integridad
- **Creación automática de directorios** con permisos correctos
- **Reparación automática** de symlinks rotos
- **Validación de configuraciones** de módulos

### 🔧 Funciones Principales

```bash
# Crear backup automático
create_backup ~/.zshrc

# Crear symlink inteligente
create_symlink ~/config/zshrc ~/.zshrc

# Verificar integridad de symlinks
verify_symlinks ~/.config

# Reparar symlinks rotos
repair_symlinks ~/.config

# Crear estructura de directorios
create_directory_structure ~/.config "nvim" "kitty"
```

## 🎨 Sistema de Logging y Colores

### 🌈 Colores ANSI Mejorados

- **INFO**: Cyan - Información general
- **SUCCESS**: Verde - Operaciones exitosas
- **WARN**: Amarillo - Advertencias
- **ERROR**: Rojo - Errores críticos
- **DEBUG**: Púrpura - Información de debugging

### 📝 Niveles de Logging

```bash
# Configurar nivel de logging
export ARCH_DREAM_LOG_LEVEL="DEBUG"

# Habilitar timestamps
export ARCH_DREAM_LOG_TIMESTAMP="true"

# Deshabilitar colores
export ARCH_DREAM_LOG_COLORS="false"
```

## 🔧 Variables de Entorno

### 🌍 Configuración Global

```bash
# Modo no interactivo (CI/CD)
export CI=true

# Forzar instalación paralela
export ARCH_DREAM_PARALLEL=true

# Modo simulación
export DRY_RUN=true

# Forzar instalación sin confirmación
export FORCE_INSTALL=true
```

## 🚀 Instalación y Uso

### 📥 Instalación Rápida

```bash
# Opción 1: Instalación de un solo comando
curl -sSL https://raw.githubusercontent.com/Albert-fer02/Arch_Dream08/main/one-liner-install.sh | bash

# Opción 2: Clonar y ejecutar
git clone https://github.com/Albert-fer02/Arch_Dream08.git
cd Arch_Dream08
./install.sh --all
```

### 🔍 Verificar Instalación

```bash
# Ver estado de módulos instalados
ls ~/.config/arch-dream/installed/

# Ver logs de instalación
tail -f /tmp/arch-dream-install.log

# Verificar configuración de módulo
./install.sh --dry-run core:zsh
```

### 🧹 Desinstalación

```bash
# Restaurar desde backup
list_backups .zshrc
restore_from_backup ~/.arch-dream-backups/.zshrc.20241201_143022 ~/.zshrc

# Eliminar configuraciones
rm -rf ~/.config/arch-dream/
```

## 🐛 Solución de Problemas

### ❌ Errores Comunes

1. **Permisos sudo**: Asegúrate de tener permisos de administrador
2. **Conexión a internet**: Verifica tu conexión para descargar paquetes
3. **Espacio en disco**: Mínimo 2GB de espacio libre requerido
4. **Dependencias faltantes**: Instala git, sudo, pacman, curl

### 🔧 Modo Debug

```bash
# Habilitar modo verbose
./install.sh --verbose --dry-run core:zsh

# Ver logs detallados
export ARCH_DREAM_LOG_LEVEL="DEBUG"
./install.sh core:zsh

# Verificar sistema
./install.sh --dry-run --all
```

## 📚 Documentación Adicional

- **README.md** - Documentación principal del proyecto
- **docs/OPTIMIZATIONS.md** - Guía de optimizaciones
- **modules/*/README.md** - Documentación específica de cada módulo

## 🤝 Contribuir

### 🔧 Desarrollo

1. Fork el repositorio
2. Crea una rama para tu feature
3. Sigue las convenciones de código
4. Envía un pull request

### 📝 Convenciones de Código

- **Bash**: Usar `set -euo pipefail` y `IFS=$'\n\t'`
- **Funciones**: Nombres descriptivos en snake_case
- **Variables**: Uso de `local` para variables de función
- **Comentarios**: Documentar funciones y secciones importantes
- **Logging**: Usar funciones de logging apropiadas

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver `LICENSE` para más detalles.

## 🙏 Agradecimientos

- Comunidad de Arch Linux
- Contribuidores del proyecto
- Usuarios que reportan bugs y sugieren mejoras

---

**🚀 ¡Disfruta tu nueva Arch Dream Machine! 🚀**