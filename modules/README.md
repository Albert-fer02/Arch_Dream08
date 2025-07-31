# 🧩 Arch Dream Machine - Estructura Modular

## 📁 Estructura de Módulos

```
modules/
├── core/                    # Módulos fundamentales
│   ├── zsh/                # Configuración de Zsh
│   ├── bash/               # Configuración de Bash (fallback)
│   └── shell/              # Configuración común de shell
├── terminal/               # Emuladores de terminal
│   ├── kitty/              # Kitty terminal
│   └── alacritty/          # Alacritty (opcional)
├── tools/                  # Herramientas de desarrollo
│   ├── fastfetch/          # Fastfetch con temas
│   ├── nano/               # Editor Nano
│   └── neovim/             # Neovim (opcional)
├── themes/                 # Temas y colores
│   ├── catppuccin/         # Tema Catppuccin
│   └── custom/             # Temas personalizados
└── scripts/                # Scripts de utilidad
    ├── install.sh          # Instalador principal
    ├── uninstall.sh        # Desinstalador
    └── verify.sh           # Verificador de integridad
```

## 🔧 Características de Cada Módulo

### Core Modules
- **zsh/**: Configuración completa de Zsh con Oh My Zsh y Powerlevel10k
- **bash/**: Configuración de fallback para sistemas sin Zsh
- **shell/**: Configuraciones comunes entre shells

### Terminal Modules
- **kitty/**: Emulador de terminal principal con aceleración GPU
- **alacritty/**: Alternativa ligera (opcional)

### Tools Modules
- **fastfetch/**: Información del sistema con temas personalizados
- **nano/**: Editor de texto con configuración avanzada
- **neovim/**: Editor avanzado (opcional)

### Theme Modules
- **catppuccin/**: Tema principal basado en Catppuccin
- **custom/**: Temas personalizados adicionales

## 🚀 Uso de Módulos

### Instalación Selectiva
```bash
# Instalar solo módulos específicos
./modules/scripts/install.sh --modules zsh,kitty,fastfetch

# Instalar todos los módulos
./modules/scripts/install.sh --all
```

### Configuración Modular
```bash
# Configurar solo terminal
./modules/terminal/kitty/install.sh

# Configurar solo herramientas
./modules/tools/fastfetch/install.sh
```

## 📋 Dependencias por Módulo

| Módulo | Dependencias | AUR | Descripción |
|--------|-------------|-----|-------------|
| zsh | zsh, oh-my-zsh, powerlevel10k | No | Shell principal |
| kitty | kitty | No | Terminal GPU |
| fastfetch | fastfetch | No | Info del sistema |
| nano | nano | No | Editor de texto |
| neovim | neovim | No | Editor avanzado |

## 🔄 Gestión de Módulos

### Agregar Nuevo Módulo
1. Crear directorio en `modules/`
2. Implementar `install.sh`, `config.sh`, `uninstall.sh`
3. Agregar documentación en `README.md`
4. Actualizar dependencias en `modules.json`

### Actualizar Módulo
```bash
# Actualizar módulo específico
./modules/scripts/update.sh --module zsh

# Actualizar todos los módulos
./modules/scripts/update.sh --all
```

## 🛡️ Seguridad y Validación

- Verificación de integridad de archivos
- Backup automático antes de cambios
- Validación de permisos y dependencias
- Logs detallados de todas las operaciones

## 📝 Convenciones

- Todos los scripts deben ser POSIX-compliant
- Usar funciones reutilizables de `lib/common.sh`
- Documentar todas las funciones y variables
- Incluir manejo de errores robusto
- Seguir el patrón de colores y logging establecido 