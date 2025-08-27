#!/bin/zsh
# =====================================================
# 🚀 POWERLEVEL10K DREAMCODER EVOLVED - TOKYO NIGHT FUSION
# =====================================================
# Configuración evolucionada con Tokyo Night + Catppuccin fusion
# Diseño adaptativo inteligente con elementos contextuales
# Experiencia visual premium optimizada para máxima productividad
# =====================================================

# Configuración principal de Powerlevel10k
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    # Diseño inteligente contextual
    os_icon
    dir
    vcs
    # Elementos contextuales (solo cuando son relevantes)
    docker_context
    pyenv
    nodeenv
)

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    # Información esencial optimizada
    status
    background_jobs
    custom_ok
)

# =====================================================
# 🎨 TOKYO NIGHT FUSION - DREAMCODER EVOLVED PALETTE
# =====================================================

# Paleta base Tokyo Night + Catppuccin fusion
POWERLEVEL9K_COLOR_SCHEME='dark'
POWERLEVEL9K_BACKGROUND='#1a1b26'     # Tokyo Night background (más profundo)
POWERLEVEL9K_FOREGROUND='#c0caf5'     # Tokyo Night foreground (más vibrante)

# Colores de estado evolucionados (Tokyo Night + Catppuccin)
POWERLEVEL9K_ACCENT_BLUE='#7aa2f7'     # Tokyo Night blue (vibrant)
POWERLEVEL9K_SUCCESS_GREEN='#9ece6a'   # Tokyo Night green (fresh)
POWERLEVEL9K_WARNING_YELLOW='#e0af68'  # Tokyo Night yellow (warm)
POWERLEVEL9K_ERROR_RED='#f7768e'       # Tokyo Night red (soft but visible)
POWERLEVEL9K_MUTED_GRAY='#565f89'      # Tokyo Night comment (subtle)
POWERLEVEL9K_PURPLE_ACCENT='#bb9af7'   # Tokyo Night purple (elegant)

# =====================================================
# 👤 USUARIO Y HOST - Diseño maximalista premium
# =====================================================

# Usuario con Tokyo Night fusion
POWERLEVEL9K_USER_ICON='⚡'
POWERLEVEL9K_USER_DEFAULT_FOREGROUND='#c0caf5'     # Tokyo Night foreground
POWERLEVEL9K_USER_DEFAULT_BACKGROUND='#24283b'     # Tokyo Night darker
POWERLEVEL9K_USER_ROOT_FOREGROUND='#f7768e'        # Tokyo Night red para root
POWERLEVEL9K_USER_ROOT_BACKGROUND='#24283b'
POWERLEVEL9K_USER_TEMPLATE='%B%F{$POWERLEVEL9K_USER_DEFAULT_FOREGROUND}%n%f%b'

# Host con diseño contextual
POWERLEVEL9K_HOST_ICON='🌐'
POWERLEVEL9K_HOST_FOREGROUND='#7aa2f7'             # Tokyo Night blue
POWERLEVEL9K_HOST_BACKGROUND='#24283b'
POWERLEVEL9K_HOST_TEMPLATE='%B%F{$POWERLEVEL9K_HOST_FOREGROUND}%m%f%b'

# =====================================================
# 📁 DIRECTORIO - Navegación maximalista con iconos sofisticados
# =====================================================

# Directorio con diseño inteligente contextual
POWERLEVEL9K_DIR_FOREGROUND='#c0caf5'              # Tokyo Night foreground
POWERLEVEL9K_DIR_BACKGROUND='#1a1b26'              # Tokyo Night base
POWERLEVEL9K_SHORTEN_STRATEGY='truncate_to_unique'
POWERLEVEL9K_SHORTEN_DIR_LENGTH=2                  # Más compacto
POWERLEVEL9K_SHORTEN_DELIMITER=''

# Iconos contextuales adaptativos
POWERLEVEL9K_DIR_ETC_ICON='⚙️'
POWERLEVEL9K_DIR_HOME_ICON='🏠'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_ICON='📁'
POWERLEVEL9K_DIR_DEFAULT_ICON='📂'
POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_ICON='🔒'
POWERLEVEL9K_DIR_PACKAGE_ICON='📦'

# =====================================================
# 🔥 GIT - Control de versiones maximalista con feedback visual inmersivo
# =====================================================

# Git con diseño inteligente y colores contextuales
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='#24283b'        # Tokyo Night darker
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#9ece6a'        # Tokyo Night green para limpio
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='#24283b'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#e0af68'     # Tokyo Night yellow para modificado
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='#24283b'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#7aa2f7'    # Tokyo Night blue para sin track
POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND='#24283b'
POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND='#f7768e'   # Tokyo Night red para conflictos
POWERLEVEL9K_VCS_LOADING_BACKGROUND='#24283b'
POWERLEVEL9K_VCS_LOADING_FOREGROUND='#565f89'      # Tokyo Night muted

# Iconos Git contextuales mejorados
POWERLEVEL9K_VCS_GIT_ICON='✨'                    # Sparkles para git limpio
POWERLEVEL9K_VCS_GIT_GITHUB_ICON='🐙'
POWERLEVEL9K_VCS_GIT_GITLAB_ICON='🦊'
POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON='🐟'
POWERLEVEL9K_VCS_DIRTY_ICON='🔥'              # Fire para cambios urgentes
POWERLEVEL9K_VCS_CLEAN_ICON='✔️'                # Check para limpio
POWERLEVEL9K_VCS_UNTRACKED_ICON='❓'             # Question para untracked

# =====================================================
# 🐍 LENGUAJES - Solo los esenciales con estilo maximalista ultra premium
# =====================================================

# Lenguajes con colores contextuales Tokyo Night
# Python - solo cuando hay archivos .py o entorno virtual
POWERLEVEL9K_PYENV_FOREGROUND='#e0af68'            # Tokyo Night yellow para Python
POWERLEVEL9K_PYENV_BACKGROUND='#24283b'
POWERLEVEL9K_PYENV_ICON='🐍'
POWERLEVEL9K_PYTHON_ICON='🐍'

# Node.js - solo cuando hay package.json o node_modules
POWERLEVEL9K_NODEENV_FOREGROUND='#9ece6a'          # Tokyo Night green para Node
POWERLEVEL9K_NODEENV_BACKGROUND='#24283b'
POWERLEVEL9K_NODEENV_ICON='⬢'
POWERLEVEL9K_NODE_VERSION_FOREGROUND='#9ece6a'
POWERLEVEL9K_NODE_VERSION_BACKGROUND='#24283b'

# Rust - solo cuando hay Cargo.toml
POWERLEVEL9K_RUST_VERSION_FOREGROUND='#f7768e'     # Tokyo Night red para Rust
POWERLEVEL9K_RUST_VERSION_BACKGROUND='#24283b'
POWERLEVEL9K_RUST_VERSION_ICON='🦀'

# Go - solo cuando hay go.mod
POWERLEVEL9K_GO_VERSION_FOREGROUND='#7aa2f7'       # Tokyo Night blue para Go
POWERLEVEL9K_GO_VERSION_BACKGROUND='#24283b'
POWERLEVEL9K_GO_VERSION_ICON='🐹'

# =====================================================
# ⚡ PROMPT CHARACTER - Diseño de dos líneas con flecha debajo
# =====================================================

# Prompt character adaptativo con animación sutil
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{#7aa2f7}❯%f '  # Tokyo Night blue arrow
# Prompt alternativo para errores
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX_ERROR='%F{#f7768e}❯%f '  # Tokyo Night red arrow

# =====================================================
# 🔧 ESTADO DEL SISTEMA - Información maximalista con diseño premium
# =====================================================

# Estado del sistema con retroalimentación visual inteligente
POWERLEVEL9K_STATUS_OK_BACKGROUND='#24283b'
POWERLEVEL9K_STATUS_OK_FOREGROUND='#9ece6a'        # Tokyo Night green para éxito
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='#24283b'
POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#f7768e'     # Tokyo Night red para errores
POWERLEVEL9K_STATUS_OK_ICON='✨'                  # Sparkles para éxito
POWERLEVEL9K_STATUS_ERROR_ICON='💥'           # Boom para errores
POWERLEVEL9K_STATUS_OK=false                       # Solo mostrar en errores

# Jobs en background con indicador visual mejorado
POWERLEVEL9K_BACKGROUND_JOBS_ICON='⚡'
POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='#e0af68'  # Tokyo Night yellow
POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND='#24283b'
POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_COLOR='#bb9af7'  # Tokyo Night purple

# Segmento personalizado para reemplazar la hora
# Mostrará: " ✔ " cuando se renderice junto a los separadores de la RPROMPT
POWERLEVEL9K_CUSTOM_OK='echo "✔ "'
POWERLEVEL9K_CUSTOM_OK_FOREGROUND='#c0caf5'
POWERLEVEL9K_CUSTOM_OK_BACKGROUND='#1a1b26'

# =====================================================
# 📊 INFORMACIÓN DEL SISTEMA - Contextual e inteligente
# =====================================================

# Información del sistema - solo cuando es crítica
# Batería - solo cuando <30%
POWERLEVEL9K_BATTERY_CHARGING_ICON='⚡'
POWERLEVEL9K_BATTERY_DISCONNECTED_ICON='🔋'
POWERLEVEL9K_BATTERY_LOW_THRESHOLD=30               # Mostrar antes para mejor UX
POWERLEVEL9K_BATTERY_LOW_FOREGROUND='#f7768e'      # Tokyo Night red para batería baja
POWERLEVEL9K_BATTERY_LOW_BACKGROUND='#24283b'
POWERLEVEL9K_BATTERY_CHARGING_FOREGROUND='#e0af68' # Tokyo Night yellow para carga
POWERLEVEL9K_BATTERY_CHARGING_BACKGROUND='#24283b'

# RAM - solo cuando >80% de uso
POWERLEVEL9K_RAM_FOREGROUND='#bb9af7'              # Tokyo Night purple para RAM
POWERLEVEL9K_RAM_BACKGROUND='#24283b'
POWERLEVEL9K_RAM_ICON='💾'

# Load - solo cuando >2.0
POWERLEVEL9K_LOAD_FOREGROUND='#f7768e'             # Tokyo Night red para carga alta
POWERLEVEL9K_LOAD_BACKGROUND='#24283b'
POWERLEVEL9K_LOAD_ICON='📊'
POWERLEVEL9K_LOAD_CRITICAL=2.0                     # Umbral crítico

# Configuraciones duplicadas eliminadas para mejor rendimiento

# =====================================================
# 🐳 HERRAMIENTAS DE DESARROLLO - Solo cuando es necesario con estilo maximalista
# =====================================================

# Docker - solo cuando hay Dockerfile o docker-compose
POWERLEVEL9K_DOCKER_CONTEXT_FOREGROUND='#7aa2f7'    # Tokyo Night blue para Docker
POWERLEVEL9K_DOCKER_CONTEXT_BACKGROUND='#24283b'
POWERLEVEL9K_DOCKER_CONTEXT_ICON='🐳'
POWERLEVEL9K_DOCKER_MACHINE_FOREGROUND='#7aa2f7'
POWERLEVEL9K_DOCKER_MACHINE_BACKGROUND='#24283b'

# Kubernetes - solo cuando hay contexto activo
POWERLEVEL9K_KUBECONTEXT_FOREGROUND='#bb9af7'       # Tokyo Night purple para K8s
POWERLEVEL9K_KUBECONTEXT_BACKGROUND='#24283b'
POWERLEVEL9K_KUBECONTEXT_ICON='☸️'
POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx'

# =====================================================
# 🎯 CONFIGURACIÓN FINAL DREAMCODER TWO-LINE WITH ARROW
# =====================================================

# Configuraciones adicionales para el estilo DreamCoder de dos líneas
POWERLEVEL9K_MODE='nerdfont-complete'

# Separadores optimizados para máximo rendimiento y compatibilidad
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='%F{#7aa2f7}%f'      # Powerline triangle (más rápido)
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='%F{#7aa2f7}%f'     # Powerline triangle reversed
POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='%F{#565f89}|%f'       # Simple pipe (ultra rápido)
POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='%F{#565f89}|%f'

# Separadores minimalistas para mejor rendimiento
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS_SEPARATOR=''              # Sin separadores extra
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS_SEPARATOR=''

# Configuración de rendimiento optimizada
POWERLEVEL9K_DISABLE_RPROMPT_AFTER_COMMAND=true
POWERLEVEL9K_DISABLE_RPROMPT_AFTER_COMMAND_EDIT=true

# Optimizaciones adicionales
POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME=false              # Deshabilitar tiempo en tiempo real
POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=4096                 # Límite para repositorios grandes
POWERLEVEL9K_VCS_STAGED_MAX_NUM=10                         # Límite de archivos staged mostrados
POWERLEVEL9K_VCS_UNSTAGED_MAX_NUM=10                       # Límite de archivos unstaged mostrados
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2            # Solo mostrar tiempo si >2s
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0            # Sin decimales

# Deshabilitar elementos innecesarios para mejor rendimiento
POWERLEVEL9K_BATTERY_VERBOSE=false
POWERLEVEL9K_LOAD_WHICH=1                                  # Solo 1min load average

# =====================================================
# 🚀 ACTIVACIÓN DE POWERLEVEL10K DREAMCODER TWO-LINE WITH ARROW
# =====================================================

# Cargar Powerlevel10k
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme



