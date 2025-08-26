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
    # Usuario y host con diseño maximalista
    os_icon
    user
    host
    dir
    vcs
    # Información contextual avanzada
    nodeenv
    pyenv
    rust_version
    go_version
    # Estado del sistema
    status
    background_jobs
    time
)

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    # Información del sistema
    battery
    ram
    load
    disk_usage
    # Herramientas de desarrollo
    docker_context
    kubectl_context
    terraform
    aws
    # Estado de la sesión
    history
    command_execution_time
)

# =====================================================
# 🎨 ESTILOS MAXIMALISTAS - Paleta de colores premium
# =====================================================

# Colores principales (Catppuccin Mocha inspirado)
POWERLEVEL9K_COLOR_SCHEME='dark'
POWERLEVEL9K_BACKGROUND='#1e1e2e'
POWERLEVEL9K_FOREGROUND='#cdd6f4'

# Colores de estado
POWERLEVEL9K_OK_VIOLET='#cba6f7'
POWERLEVEL9K_ERROR_RED='#f38ba8'
POWERLEVEL9K_WARNING_YELLOW='#f9e2af'
POWERLEVEL9K_SUCCESS_GREEN='#a6e3a1'
POWERLEVEL9K_INFO_BLUE='#89b4fa'

# =====================================================
# 👤 USUARIO Y HOST - Diseño maximalista premium
# =====================================================

# Usuario con estilo maximalista
POWERLEVEL9K_USER_ICON='👤'
POWERLEVEL9K_USER_DEFAULT_FOREGROUND='#1e1e2e'
POWERLEVEL9K_USER_DEFAULT_BACKGROUND='#89b4fa'
POWERLEVEL9K_USER_ROOT_FOREGROUND='#1e1e2e'
POWERLEVEL9K_USER_ROOT_BACKGROUND='#f38ba8'
POWERLEVEL9K_USER_TEMPLATE='%B%F{$POWERLEVEL9K_USER_DEFAULT_FOREGROUND}%n%f%b'

# Host con estilo maximalista
POWERLEVEL9K_HOST_ICON='🖥️'
POWERLEVEL9K_HOST_FOREGROUND='#1e1e2e'
POWERLEVEL9K_HOST_BACKGROUND='#94e2d5'
POWERLEVEL9K_HOST_TEMPLATE='%B%F{$POWERLEVEL9K_HOST_FOREGROUND}%m%f%b'

# =====================================================
# 📁 DIRECTORIO - Navegación maximalista con iconos sofisticados
# =====================================================

# Directorio con estilo maximalista
POWERLEVEL9K_DIR_FOREGROUND='#1e1e2e'
POWERLEVEL9K_DIR_BACKGROUND='#cba6f7'
POWERLEVEL9K_SHORTEN_STRATEGY='truncate_to_unique'
POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_SHORTEN_DELIMITER='…/'

# Iconos específicos para carpetas del proyecto Arch Dream
POWERLEVEL9K_DIR_ETC_ICON='⚙️'
POWERLEVEL9K_DIR_HOME_ICON='🏠'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_ICON='📁'
POWERLEVEL9K_DIR_DEFAULT_ICON='📂'
POWERLEVEL9K_DIR_ETC_ICON='⚙️'

# =====================================================
# 🔥 GIT - Control de versiones maximalista con feedback visual inmersivo
# =====================================================

# Git con estilo maximalista
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='#a6e3a1'
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#1e1e2e'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='#f9e2af'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#1e1e2e'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='#fab387'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#1e1e2e'
POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND='#f38ba8'
POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND='#1e1e2e'

# Iconos de Git maximalistas
POWERLEVEL9K_VCS_GIT_ICON='🌿'
POWERLEVEL9K_VCS_GIT_GITHUB_ICON='🐙'
POWERLEVEL9K_VCS_GIT_GITLAB_ICON='🦊'
POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON='🐟'

# =====================================================
# 🐍 LENGUAJES - Solo los esenciales con estilo maximalista ultra premium
# =====================================================

# Python con estilo maximalista
POWERLEVEL9K_PYENV_FOREGROUND='#1e1e2e'
POWERLEVEL9K_PYENV_BACKGROUND='#94e2d5'
POWERLEVEL9K_PYENV_ICON='🐍'

# Node.js con estilo maximalista
POWERLEVEL9K_NODEENV_FOREGROUND='#1e1e2e'
POWERLEVEL9K_NODEENV_BACKGROUND='#94e2d5'
POWERLEVEL9K_NODEENV_ICON='⬢'

# Rust con estilo maximalista
POWERLEVEL9K_RUST_VERSION_FOREGROUND='#1e1e2e'
POWERLEVEL9K_RUST_VERSION_BACKGROUND='#f38ba8'
POWERLEVEL9K_RUST_VERSION_ICON='🦀'

# Go con estilo maximalista
POWERLEVEL9K_GO_VERSION_FOREGROUND='#1e1e2e'
POWERLEVEL9K_GO_VERSION_BACKGROUND='#89b4fa'
POWERLEVEL9K_GO_VERSION_ICON='🐹'

# =====================================================
# ⚡ PROMPT CHARACTER - Diseño maximalista ultra premium con feedback contextual
# =====================================================

# Prompt character maximalista
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{blue}❯%f '

# =====================================================
# 🔧 ESTADO DEL SISTEMA - Información maximalista con diseño premium
# =====================================================

# Estado del sistema maximalista
POWERLEVEL9K_STATUS_OK_BACKGROUND='#a6e3a1'
POWERLEVEL9K_STATUS_OK_FOREGROUND='#1e1e2e'
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='#f38ba8'
POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#1e1e2e'

# Jobs en background maximalistas
POWERLEVEL9K_BACKGROUND_JOBS_ICON='⚙️'
POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='#1e1e2e'
POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND='#89b4fa'

# Tiempo maximalista
POWERLEVEL9K_TIME_FOREGROUND='#1e1e2e'
POWERLEVEL9K_TIME_BACKGROUND='#6c7086'
POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'

# =====================================================
# 📊 INFORMACIÓN DEL SISTEMA - Solo lo esencial con estilo maximalista
# =====================================================

# Batería maximalista
POWERLEVEL9K_BATTERY_CHARGING_ICON='⚡'
POWERLEVEL9K_BATTERY_DISCONNECTED_ICON='🔋'
POWERLEVEL9K_BATTERY_LOW_THRESHOLD=20
POWERLEVEL9K_BATTERY_LOW_FOREGROUND='#f38ba8'
POWERLEVEL9K_BATTERY_LOW_BACKGROUND='#1e1e2e'

# RAM maximalista
POWERLEVEL9K_RAM_FOREGROUND='#1e1e2e'
POWERLEVEL9K_RAM_BACKGROUND='#89b4fa'
POWERLEVEL9K_RAM_ICON='💾'

# Load maximalista
POWERLEVEL9K_LOAD_FOREGROUND='#1e1e2e'
POWERLEVEL9K_LOAD_BACKGROUND='#f9e2af'
POWERLEVEL9K_LOAD_ICON='📈'

# =====================================================
# 🐳 HERRAMIENTAS DE DESARROLLO - Solo cuando es necesario con estilo maximalista
# =====================================================

# Docker maximalista
POWERLEVEL9K_DOCKER_CONTEXT_FOREGROUND='#1e1e2e'
POWERLEVEL9K_DOCKER_CONTEXT_BACKGROUND='#94e2d5'
POWERLEVEL9K_DOCKER_CONTEXT_ICON='🐳'

# Kubernetes maximalista
POWERLEVEL9K_KUBECONTEXT_FOREGROUND='#1e1e2e'
POWERLEVEL9K_KUBECONTEXT_BACKGROUND='#cba6f7'
POWERLEVEL9K_KUBECONTEXT_ICON='☸️'

# =====================================================
# 🎯 CONFIGURACIÓN FINAL MAXIMALIST MASTERPIECE
# =====================================================

# Configuraciones adicionales para maximalismo
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '

# Hacer que el prompt sea más compacto
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_PROMPT_ON_NEWLINE=true

# Configuración para mejor rendimiento
POWERLEVEL9K_DISABLE_RPROMPT_AFTER_COMMAND=true
POWERLEVEL9K_DISABLE_RPROMPT_AFTER_COMMAND_EDIT=true

# =====================================================
# 🚀 ACTIVACIÓN DE POWERLEVEL10K MAXIMALIST
# =====================================================

# Cargar Powerlevel10k
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme



