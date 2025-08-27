#!/bin/zsh
# =====================================================
# 🚀 POWERLEVEL10K MAXIMALIST MASTERPIECE - ARCH DREAM
# =====================================================
# Configuración maximalista ultra premium para Powerlevel10k
# Diseño de revista de diseño internacional con separadores elegantes
# Experiencia visual inmersiva que transforma la terminal en galería de arte
# =====================================================

# Configuración principal de Powerlevel10k
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    # Diseño con icono de Arch Linux y separador
    os_icon
    dir
    vcs
)

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    # Información esencial del sistema
    status
)

# =====================================================
# 🎨 ESTILOS SIMPLIFICADOS - DREAMCODER VISUAL COMFORT 100%
# =====================================================

# Colores principales (Paleta 100% enfocada en legibilidad y cuidado visual)
POWERLEVEL9K_COLOR_SCHEME='dark'
POWERLEVEL9K_BACKGROUND='#0e1416'     # Fondo principal DreamCoder
POWERLEVEL9K_FOREGROUND='#0e1416'     # Fondo principal DreamCoder

# Colores de estado (Catppuccin Mocha)
POWERLEVEL9K_OK_VIOLET='#cba6f7'      # Lavender (Catppuccin Lavender)
POWERLEVEL9K_ERROR_RED='#f38ba8'      # Red (Catppuccin Red)
POWERLEVEL9K_WARNING_YELLOW='#f9e2af' # Yellow (Catppuccin Yellow)
POWERLEVEL9K_SUCCESS_GREEN='#a6e3a1'  # Green (Catppuccin Green)
POWERLEVEL9K_INFO_BLUE='#89b4fa'      # Blue (Catppuccin Blue)

# =====================================================
# 👤 USUARIO Y HOST - Diseño maximalista premium
# =====================================================

# Usuario con estilo DreamCoder 100% enfocado en legibilidad visual
POWERLEVEL9K_USER_ICON='👤'
POWERLEVEL9K_USER_DEFAULT_FOREGROUND='#f8fafc'     # Blanco puro para máximo contraste
POWERLEVEL9K_USER_DEFAULT_BACKGROUND='#1e293b'     # Slate-800 para elementos principales
POWERLEVEL9K_USER_ROOT_FOREGROUND='#f8fafc'
POWERLEVEL9K_USER_ROOT_BACKGROUND='#1e293b'        # Slate-800 para elementos principales
POWERLEVEL9K_USER_TEMPLATE='%B%F{$POWERLEVEL9K_USER_DEFAULT_FOREGROUND}%n%f%b'

# Host con estilo DreamCoder 100% enfocado en legibilidad visual
POWERLEVEL9K_HOST_ICON='🖥️'
POWERLEVEL9K_HOST_FOREGROUND='#f8fafc'
POWERLEVEL9K_HOST_BACKGROUND='#1e293b'             # Slate-800 para elementos principales
POWERLEVEL9K_HOST_TEMPLATE='%B%F{$POWERLEVEL9K_HOST_FOREGROUND}%m%f%b'

# =====================================================
# 📁 DIRECTORIO - Navegación maximalista con iconos sofisticados
# =====================================================

# Directorio con estilo DreamCoder 100% enfocado en legibilidad visual
POWERLEVEL9K_DIR_FOREGROUND='#f8fafc'              # Blanco puro para máximo contraste
POWERLEVEL9K_DIR_BACKGROUND='#1e293b'              # Slate-800 para elementos principales
POWERLEVEL9K_SHORTEN_STRATEGY='truncate_to_unique'
POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
POWERLEVEL9K_SHORTEN_DELIMITER='/'

# Iconos específicos para carpetas del proyecto Arch Dream
POWERLEVEL9K_DIR_ETC_ICON='⚙️'
POWERLEVEL9K_DIR_HOME_ICON='🏠'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_ICON='📁'
POWERLEVEL9K_DIR_DEFAULT_ICON='📂'

# =====================================================
# 🔥 GIT - Control de versiones maximalista con feedback visual inmersivo
# =====================================================

# Git con estilo Catppuccin (Mocha) - Nivel 1 (Alto contraste)
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='#1e293b'        # Slate-800 para elementos principales
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#f8fafc'        # Blanco puro para máximo contraste
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='#334155'     # Slate-700 para elementos secundarios
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#e2e8f0'     # Slate-200 para contraste medio
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='#475569'    # Slate-600 para elementos de estado
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#cbd5e1'    # Slate-300 para contraste bajo
POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND='#dc2626'   # Rojo para conflictos
POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND='#fef2f2'   # Blanco para máximo contraste

# Iconos de Git maximalistas
POWERLEVEL9K_VCS_GIT_ICON='🌿'
POWERLEVEL9K_VCS_GIT_GITHUB_ICON='🐙'
POWERLEVEL9K_VCS_GIT_GITLAB_ICON='🦊'
POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON='🐟'

# =====================================================
# 🐍 LENGUAJES - Solo los esenciales con estilo maximalista ultra premium
# =====================================================

# Python con estilo DreamCoder 100% enfocado en legibilidad visual
POWERLEVEL9K_PYENV_FOREGROUND='#e2e8f0'            # Slate-200 para contraste medio
POWERLEVEL9K_PYENV_BACKGROUND='#334155'             # Slate-700 para elementos secundarios
POWERLEVEL9K_PYENV_ICON='🐍'

# Node.js con estilo DreamCoder 100% enfocado en legibilidad visual
POWERLEVEL9K_NODEENV_FOREGROUND='#e2e8f0'          # Slate-200 para contraste medio
POWERLEVEL9K_NODEENV_BACKGROUND='#334155'           # Slate-700 para elementos secundarios
POWERLEVEL9K_NODEENV_ICON='⬢'

# Rust con estilo DreamCoder 100% enfocado en legibilidad visual
POWERLEVEL9K_RUST_VERSION_FOREGROUND='#e2e8f0'     # Slate-200 para contraste medio
POWERLEVEL9K_RUST_VERSION_BACKGROUND='#334155'      # Slate-700 para elementos secundarios
POWERLEVEL9K_RUST_VERSION_ICON='🦀'

# Go con estilo DreamCoder 100% enfocado en legibilidad visual
POWERLEVEL9K_GO_VERSION_FOREGROUND='#e2e8f0'       # Slate-200 para contraste medio
POWERLEVEL9K_GO_VERSION_BACKGROUND='#334155'        # Slate-700 para elementos secundarios
POWERLEVEL9K_GO_VERSION_ICON='🐹'

# =====================================================
# ⚡ PROMPT CHARACTER - Diseño de dos líneas con flecha debajo
# =====================================================

# Prompt character de dos líneas con flecha debajo y separador elegante
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{#93C5FD}❯%f '

# =====================================================
# 🔧 ESTADO DEL SISTEMA - Información maximalista con diseño premium
# =====================================================

# Estado del sistema DreamCoder 100% enfocado en legibilidad visual
POWERLEVEL9K_STATUS_OK_BACKGROUND='#1e293b'        # Slate-800 para elementos principales
POWERLEVEL9K_STATUS_OK_FOREGROUND='#a6e3a1'        # Verde Catppuccin para éxito
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='#dc2626'     # Rojo para errores
POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#fef2f2'     # Blanco para máximo contraste
POWERLEVEL9K_STATUS_OK_ICON='✔'
POWERLEVEL9K_STATUS_ERROR_ICON='✘'

# Jobs en background DreamCoder optimizado para legibilidad
POWERLEVEL9K_BACKGROUND_JOBS_ICON='⚙️'
POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='#e2e8f0'  # Slate-200 para contraste medio
POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND='#334155'   # Slate-700 para elementos secundarios

# Tiempo DreamCoder simplificado y elegante
POWERLEVEL9K_TIME_FOREGROUND='#cbd5e1'              # Slate-300 para contraste bajo
POWERLEVEL9K_TIME_BACKGROUND='#475569'              # Slate-600 para elementos de estado
POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
POWERLEVEL9K_TIME_ICON=''
POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=true
POWERLEVEL9K_TIME_UPDATE_ON_COMMAND_EDIT=true
POWERLEVEL9K_TIME_PREFIX=''
POWERLEVEL9K_TIME_SUFFIX=''
POWERLEVEL9K_TIME_SHOW_SECONDS=false

# =====================================================
# 📊 INFORMACIÓN DEL SISTEMA - Solo lo esencial con estilo maximalista
# =====================================================

# Batería DreamCoder optimizada para legibilidad
POWERLEVEL9K_BATTERY_CHARGING_ICON='⚡'
POWERLEVEL9K_BATTERY_DISCONNECTED_ICON='🔋'
POWERLEVEL9K_BATTERY_LOW_THRESHOLD=20
POWERLEVEL9K_BATTERY_LOW_FOREGROUND='#cbd5e1'      # Slate-300 para contraste bajo
POWERLEVEL9K_BATTERY_LOW_BACKGROUND='#475569'       # Slate-600 para elementos de estado

# RAM DreamCoder optimizada para legibilidad
POWERLEVEL9K_RAM_FOREGROUND='#cbd5e1'               # Slate-300 para contraste bajo
POWERLEVEL9K_RAM_BACKGROUND='#475569'                # Slate-600 para elementos de estado
POWERLEVEL9K_RAM_ICON='💾'

# Load DreamCoder optimizado para legibilidad
POWERLEVEL9K_LOAD_FOREGROUND='#cbd5e1'              # Slate-300 para contraste bajo
POWERLEVEL9K_LOAD_BACKGROUND='#475569'               # Slate-600 para elementos de estado
POWERLEVEL9K_LOAD_ICON='📈'

# =====================================================
# 🐳 HERRAMIENTAS DE DESARROLLO - Solo cuando es necesario con estilo maximalista
# =====================================================

# Docker DreamCoder optimizado para legibilidad
POWERLEVEL9K_DOCKER_CONTEXT_FOREGROUND='#e2e8f0'    # Slate-200 para contraste medio
POWERLEVEL9K_DOCKER_CONTEXT_BACKGROUND='#334155'     # Slate-700 para elementos secundarios
POWERLEVEL9K_DOCKER_CONTEXT_ICON='🐳'

# Kubernetes DreamCoder optimizado para legibilidad
POWERLEVEL9K_KUBECONTEXT_FOREGROUND='#e2e8f0'       # Slate-200 para contraste medio
POWERLEVEL9K_KUBECONTEXT_BACKGROUND='#334155'        # Slate-700 para elementos secundarios
POWERLEVEL9K_KUBECONTEXT_ICON='☸️'

# =====================================================
# 🎯 CONFIGURACIÓN FINAL DREAMCODER TWO-LINE WITH ARROW
# =====================================================

# Configuraciones adicionales para el estilo DreamCoder de dos líneas
POWERLEVEL9K_MODE='nerdfont-complete'

# Separadores elegantes con símbolos Unicode sofisticados
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='%F{#93C5FD}❘%f'
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='%F{#93C5FD}❘%f'
POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='%F{#A7F3D0}❘%f'
POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='%F{#A7F3D0}❘%f'

# Separadores entre elementos del prompt con estilo minimalista
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS_SEPARATOR='%F{#C4B5FD} ❘ %f'
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS_SEPARATOR='%F{#C4B5FD} ❘ %f'

# Separadores avanzados con símbolos Unicode elegantes
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR_FINISH='%F{#93C5FD}❘%f'
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR_FINISH='%F{#93C5FD}❘%f'

# Separadores de conexión entre segmentos
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR_LEFT='%F{#A7F3D0}❘%f'
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR_RIGHT='%F{#A7F3D0}❘%f'

# Hacer que el prompt sea de dos líneas con flecha debajo
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_PROMPT_ON_NEWLINE=true

# Configuración para mejor rendimiento
POWERLEVEL9K_DISABLE_RPROMPT_AFTER_COMMAND=true
POWERLEVEL9K_DISABLE_RPROMPT_AFTER_COMMAND_EDIT=true

# =====================================================
# 🚀 ACTIVACIÓN DE POWERLEVEL10K DREAMCODER TWO-LINE WITH ARROW
# =====================================================

# Cargar Powerlevel10k
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme



