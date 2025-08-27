# 🚀 Funcionalidades estilo Warp AI - Arch Dream

## ✅ CONFIGURACIÓN UNIFICADA FZF MULTI-SHELL

**Arquitectura nueva**:
- `modules/core/shared/fzf-core.sh` - **Core común** para ambos shells
- `modules/core/zsh/functions/fzf-zsh-extensions.zsh` - **Extensiones ZSH** específicas
- `modules/core/bash/plugins/fzf-bash-extensions.bash` - **Extensiones BASH** específicas

**Estado**: ✅ Unificado, sin duplicaciones, compatible con ambos shells

### 🎯 Keybindings principales
- `Ctrl+R` - 📜 Historia de comandos inteligente (estilo Warp AI)
- `Ctrl+T` - 📁 Búsqueda de archivos con preview
- `Alt+C`  - 📂 Navegación de directorios visual
- `Ctrl+G` - 🌳 Git commits navegable con diff
- `Ctrl+S` - 📝 Snippets/comandos guardados (Warp Drive)

### 🔍 Aliases simplificados
- `h` - Historia inteligente | `ff` - Files | `dd` - Directories
- `pp` - Processes (kill) | `gg` - Git log | `ss` - Snippets
- `pf` - Pacman search | `df` - Docker containers

### 🎨 Tema DreamCoder integrado
- Colores coordinados con tu configuración actual
- Preview windows con bat + syntax highlighting
- Interfaz moderna estilo Warp AI

## ✅ Implementado en kitty.conf

### Command Palette & Hints
- `Ctrl+Shift+P` - Paleta de comandos (scrollback con bat)
- `F1` - URLs | `F2` - Paths | `F3` - Líneas completas
- `Ctrl+Shift+Z/X` - Navegación entre prompts

### Shell integration optimizada  
- Historial 10,000 líneas con bat como pager
- Tracking de comandos mejorado
- Preview automático en búsquedas

## 🔧 Arquitectura optimizada (sin duplicaciones)

✅ **fzf-core.sh** - Funciones base compartidas entre shells
✅ **fzf-zsh-extensions.zsh** - Widgets ZSH específicos (bindkey, zle)
✅ **fzf-bash-extensions.bash** - Readline y funciones BASH específicas

### Configuraciones eliminadas:
❌ `fzf-unified.zsh` - Reemplazado por arquitectura modular
❌ `warp-fzf.zsh` - Integrado en extensiones
❌ `warp-aliases.zsh` - Distribuido por shell
❌ Configuración FZF duplicada en plugin-manager.zsh

## 🚀 Uso diario recomendado

### Búsqueda rápida:
```bash
h          # Historia de comandos (como Warp "#")
ff         # Find archivos con preview
ss         # Snippets guardados (Warp Drive)
```

### Desarrollo:
```bash
gg         # Git log navegable
pp         # Kill procesos visual
pf nginx   # Buscar paquetes
```

### Ayuda:
```bash
fhelp      # Ver todos los comandos FZF disponibles
```

## 🤖 Integraciones AI opcionales

### Para completar experiencia Warp:
```bash
# Instalar herramienta AI
yay -S aichat

# Alias para comandos AI
alias ai='aichat'
alias cmd='aichat "Dame el comando Linux para:"'
```

## 📊 Estado actual - Multi-Shell

- ✅ **FZF Core**: Configuración base compartida (fzf-core.sh)
- ✅ **ZSH**: Widgets y extensiones avanzadas 
- ✅ **BASH**: Readline y funciones específicas
- ✅ **Kitty**: Hints y navegación estilo Warp  
- 🔄 **AI**: Opcional (aichat recomendado)

### Comandos por shell:

**ZSH (avanzado)**:
```bash
h, ff, dd, gg, ss    # Widgets interactivos
ggr <texto>          # Grep con preview
zz                   # Zoxide navigation
fzhelp              # Ayuda ZSH específica
```

**BASH (compatible)**:
```bash
h, ff, dd, gg, ss    # Funciones directas
ggr <texto>          # Grep con preview  
zz                   # Zoxide navigation
fzf-bash-help       # Ayuda BASH específica
```

**Core (ambos shells)**:
```bash
fh, ffs, fdd, fgg, fpp, fss  # Funciones base
fzf-help                     # Ayuda del core
```

**Resultado**: Configuración FZF profesional compatible con ZSH y BASH, sin duplicaciones, estilo Warp AI completo.