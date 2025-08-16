# My Powerlevel10k Configuration
# ---------------------------------------------------------------------
# ╔═════════════════════════════════════════════════════════════
# ║                     𓂀 DreamCoder 08 𓂀                     ║
# ║                ⚡ Digital Dream Architect ⚡                 ║
# ║                                                            ║
# ║        Author: https://github.com/Albert-fer02             ║
# ╚══════════════════════════════════════════════════════════════╝
# ---------------------------------------------------------------------    
# My Powerlevel10k Configuration for ROOT
# ---------------------------------------------------------------------
# ╔═════════════════════════════════════════════════════════════
# ║                     𓂀 DreamCoder 08 𓂀                     ║
# ║                ⚡ Digital Dream Architect ⚡                 ║
# ║                                                            ║
# ║        Author: https://github.com/Albert-fer02             ║
# ╚══════════════════════════════════════════════════════════════╝
# ---------------------------------------------------------------------    
# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options. This allows you to apply configuration changes without
  # restarting zsh. Edit ~/.p10k.zsh and type `source ~/.p10k.zsh`.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # =========================[ DYNAMIC COLOR DETECTION & ADAPTATION ]=========================
  # Function to detect terminal theme and background
  function detect_terminal_theme() {
    local is_dark=true
    local is_light=false
    
    # Detect terminal type and theme
    case "$TERM_PROGRAM" in
      "iTerm.app")
        # iTerm2 theme detection
        if [[ -n "$ITERM_PROFILE" ]]; then
          case "$ITERM_PROFILE" in
            *"Light"*|*"light"*|*"Solarized Light"*|*"GitHub Light"*)
              is_dark=false
              is_light=true
              ;;
          esac
        fi
        ;;
      "WarpTerminal"|"warp")
        # Warp terminal theme detection
        if [[ -n "$WARP_THEME" ]]; then
          case "$WARP_THEME" in
            *"Light"*|*"light"*|*"Day"*|*"day"*)
              is_dark=false
              is_light=true
              ;;
          esac
        fi
        ;;
      "vscode")
        # VS Code terminal theme detection
        if [[ -n "$VSCODE_THEME" ]]; then
          case "$VSCODE_THEME" in
            *"Light"*|*"light"*|*"Day"*|*"day"*|*"Solarized Light"*)
              is_dark=false
              is_light=true
              ;;
          esac
        fi
        ;;
    esac
    
    # Detect background color using terminal escape sequences
    if command -v tput >/dev/null 2>&1; then
      local bg_color=$(tput setab 0 2>/dev/null | tput sgr0 2>/dev/null)
      # This is a simplified detection - in practice, you might need more sophisticated methods
    fi
    
    # Environment variable override
    if [[ -n "$P10K_THEME_MODE" ]]; then
      case "$P10K_THEME_MODE" in
        "light"|"Light"|"LIGHT")
          is_dark=false
          is_light=true
          ;;
        "dark"|"Dark"|"DARK")
          is_dark=true
          is_light=false
          ;;
      esac
    fi
    
    # Export theme state
    export P10K_IS_DARK=$is_dark
    export P10K_IS_LIGHT=$is_light
  }
  
  # Function to get adaptive colors based on theme
  function get_adaptive_colors() {
    local is_dark=${P10K_IS_DARK:-true}
    
    if [[ "$is_dark" == "true" ]]; then
      # Dark theme colors - Tokyo Night Storm inspired
      export P10K_PRIMARY_COLOR="#7AA2F7"      # Blue
      export P10K_SECONDARY_COLOR="#9ECE6A"    # Green
      export P10K_ACCENT_COLOR="#BB9AF7"       # Purple
      export P10K_WARNING_COLOR="#E0AF68"      # Yellow
      export P10K_ERROR_COLOR="#F7768E"        # Red
      export P10K_BG_COLOR="#1A1B26"           # Dark background
      export P10K_FG_COLOR="#C0CAF5"           # Light foreground
      export P10K_DIM_COLOR="#414868"          # Dimmed text
      export P10K_GLASS_COLOR="#24283B"        # Glassmorphism background
    else
      # Light theme colors - Solarized Light inspired
      export P10K_PRIMARY_COLOR="#268BD2"      # Blue
      export P10K_SECONDARY_COLOR="#859900"    # Green
      export P10K_ACCENT_COLOR="#6C71C4"       # Purple
      export P10K_WARNING_COLOR="#B58900"      # Yellow
      export P10K_ERROR_COLOR="#DC322F"        # Red
      export P10K_BG_COLOR="#FDF6E3"           # Light background
      export P10K_FG_COLOR="#586E75"           # Dark foreground
      export P10K_DIM_COLOR="#93A1A1"          # Dimmed text
      export P10K_GLASS_COLOR="#EEE8D5"        # Glassmorphism background
    fi
  }
  
  # Function to get terminal-specific colors
  function get_terminal_specific_colors() {
    case "$TERM_PROGRAM" in
      "iTerm.app")
        # iTerm2 specific optimizations
        export P10K_SEPARATOR_STYLE="powerline"
        export P10K_ICON_PADDING="moderate"
        ;;
      "WarpTerminal"|"warp")
        # Warp specific optimizations
        export P10K_SEPARATOR_STYLE="round"
        export P10K_ICON_PADDING="minimal"
        ;;
      "vscode")
        # VS Code specific optimizations
        export P10K_SEPARATOR_STYLE="flat"
        export P10K_ICON_PADDING="standard"
        ;;
      *)
        # Default terminal optimizations
        export P10K_SEPARATOR_STYLE="powerline"
        export P10K_ICON_PADDING="standard"
        ;;
    esac
  }
  
  # Load base configuration
  [[ -f "${${(%):-%x}:h}/p10k-base.zsh" ]] && source "${${(%):-%x}:h}/p10k-base.zsh"
  setup_p10k_base

  # =========================[ WARP AI TERMINAL DETECTION ]=========================
  # Detect if running in Warp AI terminal and apply specific optimizations
  local is_warp=false
  if [[ "$TERM_PROGRAM" == "WarpTerminal" ]] || [[ "$TERM_PROGRAM" == "warp" ]] || [[ "$WARP_TERMINAL" == "1" ]]; then
    is_warp=true
  fi

  # =========================[ MAIN SEGMENTS - ULTRA MODERN GLASSMORPHISM ]=========================
  # Left Prompt: Essential Information with Glassmorphism Panels
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    # =========================[ Line #1 - System Identity & Context ]=========================
    os_icon                 # Arch Linux identity
    root_indicator          # 🔥 ROOT indicator (before directory)
    dir                     # spatial context with glassmorphism
    vcs                     # development state
    # =========================[ Line #2 - Interaction Point ]=========================
    newline                 # clear separation
    prompt_char             # interaction point
  )

  # Right Prompt: Critical System Information with Glassmorphism Panels
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    # =========================[ Line #1 - Development Environment ]=========================
    kubecontext             # Kubernetes context
    aws                     # AWS profile
    docker_context          # Docker context
    nodeenv                 # Node.js version
    python_env              # Python virtual environment
    # =========================[ Line #2 - System Monitoring ]=========================
    vpn_ip                  # VPN status
    network                 # network connectivity
    cpu_arch                # CPU usage
    # =========================[ Line #3 - Command Feedback ]=========================
    status                  # command status
    command_execution_time  # performance metrics
    background_jobs         # background processes
  )

  # =========================[ GENERAL CONFIGURATION - ULTRA MODERN UX/UI ]=========================
  # Nerd Font v3 mode for unique icons and readability
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=${P10K_ICON_PADDING:-standard}
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true

  # Intelligent spacing for better readability and visual hierarchy
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  
  # Micro-interactions: Smooth transitions and visual feedback
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  
  # Performance optimization for fluid experience
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # =========================[ VISUAL SEPARATORS - ULTRA MODERN GLASSMORPHISM ]=========================
  # Glassmorphism separators with ultra modern effect - adaptive colors
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{${P10K_PRIMARY_COLOR}}╭─"
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX="%F{${P10K_PRIMARY_COLOR}}├─"
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{${P10K_PRIMARY_COLOR}}╰─"
  
  # Right side separators - glassmorphism symmetry
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX="%F{${P10K_PRIMARY_COLOR}}─╮"
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX="%F{${P10K_PRIMARY_COLOR}}─┤"
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX="%F{${P10K_PRIMARY_COLOR}}─╯"

  # Fill character between left and right prompt
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR='─'
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_BACKGROUND=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_GAP_BACKGROUND=
  
  if [[ $POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR != ' ' ]]; then
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=${P10K_ACCENT_COLOR}
    typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_FIRST_SEGMENT_END_SYMBOL='%{%}'
    typeset -g POWERLEVEL9K_EMPTY_LINE_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='%{%}'
  fi

  # =========================[ BASE COLORS - ADAPTIVE GLASSMORPHISM ]=========================
  # Main background - adaptive for glassmorphism effect
  typeset -g POWERLEVEL9K_BACKGROUND=${P10K_BG_COLOR}

  # Segment separators - glassmorphism ultra modern with adaptive colors
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR="%F{${P10K_PRIMARY_COLOR}}\uE0B1"
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR="%F{${P10K_PRIMARY_COLOR}}\uE0B3"
  
  # Separators between segments of different colors - perfect harmony
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0B0'
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0B2'

  # Prompt start and end symbols
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL='\uE0B0'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='\uE0B2'
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL='\uE0BA'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL='\uE0BC'
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  # =========================[ OS_ICON: SYSTEM ICON - ULTRA MODERN GLASSMORPHISM ]=========================
  # System icon color - glassmorphism ultra modern with adaptive colors
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=${P10K_SECONDARY_COLOR}
  # Custom icon for Arch Linux - futuristic glass effect
  typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION=''

  # =========================[ PROMPT_CHAR: PROMPT SYMBOL - MICRO-INTERACTIONS ]=========================
  # Transparent background for visual focus
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  
  # Prompt symbol colors - glassmorphism ultra modern with adaptive colors
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=${P10K_ERROR_COLOR}
  
  # Simple and functional symbols
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  
  # Optimized spacing for better usability
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

  # =========================[ DIR: CURRENT DIRECTORY - ULTRA MODERN GLASSMORPHISM ]=========================
  # Directory colors - glassmorphism ultra modern with adaptive colors
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=${P10K_FG_COLOR}
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=''
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=${P10K_DIM_COLOR}
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  
  # Space optimization for better readability
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  
  # Files that mark important directories
  local anchor_files=(
    .bzr .citc .git .hg .node-version .python-version .go-version .ruby-version
    .lua-version .java-version .perl-version .php-version .tool-versions
    .mise.toml .shorten_folder_marker .svn .terraform CVS Cargo.toml
    composer.json go.mod package.json stack.yaml
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  typeset -g POWERLEVEL9K_DIR_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  # =========================[ VCS: GIT STATUS - WORKFLOW UX ]=========================
  # Custom branch icon - clear visual identification
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'

  # Custom Git formatter with adaptive colors
  function my_git_formatter() {
    emulate -L zsh

    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi

    if (( $1 )); then
      # Adaptive colors based on theme
      local       meta="%F{${P10K_PRIMARY_COLOR}}"   # primary color
      local      clean="%F{${P10K_SECONDARY_COLOR}}" # secondary color
      local   modified="%F{${P10K_WARNING_COLOR}}"   # warning color
      local  untracked="%F{${P10K_ACCENT_COLOR}}"    # accent color
      local conflicted="%F{${P10K_ERROR_COLOR}}"     # error color
    else
      # Colors for incomplete state - adaptive dimmed colors
      local       meta="%F{${P10K_DIM_COLOR}}"
      local      clean="%F{${P10K_DIM_COLOR}}"
      local   modified="%F{${P10K_DIM_COLOR}}"
      local  untracked="%F{${P10K_DIM_COLOR}}"
      local conflicted="%F{${P10K_DIM_COLOR}}"
    fi

    local res

    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
      (( $#branch > 32 )) && branch[13,-13]="…"
      res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
    fi

    if [[ -n $VCS_STATUS_TAG && -z $VCS_STATUS_LOCAL_BRANCH ]]; then
      local tag=${(V)VCS_STATUS_TAG}
      (( $#tag > 32 )) && tag[13,-13]="…"
      res+="${meta}#${clean}${tag//\%/%%}"
    fi

    [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&
      res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"

    if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
      res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
    fi

    if [[ $VCS_STATUS_COMMIT_SUMMARY == (|*[^[:alnum:]])(wip|WIP)(|[^[:alnum:]]*) ]]; then
      res+=" ${modified}wip"
    fi

    if (( VCS_STATUS_COMMITS_AHEAD || VCS_STATUS_COMMITS_BEHIND )); then
      (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
      (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
      (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
    elif [[ -n $VCS_STATUS_REMOTE_BRANCH ]]; then
      # res+=" ${clean}="
    fi

    (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
    (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" "
    (( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
    (( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
    [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
    (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
    (( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"
    (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─"

    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null

  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1

  # Git icon colors - glassmorphism ultra modern with adaptive colors
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR=${P10K_ACCENT_COLOR}
  typeset -g POWERLEVEL9K_VCS_PREFIX="%F{${P10K_PRIMARY_COLOR}}on "

  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=${P10K_WARNING_COLOR}

  # =========================[ KUBECONTEXT: KUBERNETES CONTEXT ]=========================
  typeset -g POWERLEVEL9K_KUBECONTEXT_FOREGROUND=${P10K_FG_COLOR}
  typeset -g POWERLEVEL9K_KUBECONTEXT_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_KUBECONTEXT_PREFIX="%F{${P10K_PRIMARY_COLOR}}k8s "

  # =========================[ AWS: AWS PROFILE ]=========================
  typeset -g POWERLEVEL9K_AWS_FOREGROUND=${P10K_FG_COLOR}
  typeset -g POWERLEVEL9K_AWS_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_AWS_PREFIX="%F{${P10K_PRIMARY_COLOR}}aws "

  # =========================[ DOCKER_CONTEXT: DOCKER CONTEXT ]=========================
  typeset -g POWERLEVEL9K_DOCKER_CONTEXT_FOREGROUND=${P10K_FG_COLOR}
  typeset -g POWERLEVEL9K_DOCKER_CONTEXT_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_DOCKER_CONTEXT_PREFIX="%F{${P10K_PRIMARY_COLOR}}docker "

  # =========================[ NODEENV: NODE.JS VERSION ]=========================
  typeset -g POWERLEVEL9K_NODEENV_FOREGROUND=${P10K_FG_COLOR}
  typeset -g POWERLEVEL9K_NODEENV_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_NODEENV_PREFIX="%F{${P10K_PRIMARY_COLOR}}node "

  # =========================[ PYTHON_ENV: PYTHON VIRTUAL ENVIRONMENT ]=========================
  typeset -g POWERLEVEL9K_PYTHON_ENV_FOREGROUND=${P10K_FG_COLOR}
  typeset -g POWERLEVEL9K_PYTHON_ENV_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_PYTHON_ENV_PREFIX="%F{${P10K_PRIMARY_COLOR}}py "

  # =========================[ VPN_IP: VPN STATUS ]=========================
  typeset -g POWERLEVEL9K_VPN_IP_FOREGROUND=${P10K_FG_COLOR}
  typeset -g POWERLEVEL9K_VPN_IP_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_VPN_IP_PREFIX="%F{${P10K_PRIMARY_COLOR}}vpn "

  # =========================[ DISK_USAGE: DISK SPACE MONITORING ]=========================
  typeset -g POWERLEVEL9K_DISK_USAGE_NORMAL_FOREGROUND=${P10K_FG_COLOR}
  typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_FOREGROUND=${P10K_WARNING_COLOR}
  typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_FOREGROUND=${P10K_ERROR_COLOR}
  typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL=90
  typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL=95
  typeset -g POWERLEVEL9K_DISK_USAGE_ONLY_WARNING=false
  typeset -g POWERLEVEL9K_DISK_USAGE_VISUAL_IDENTIFIER_EXPANSION=''

  # =========================[ NETWORK: NETWORK CONNECTIVITY ]=========================
  typeset -g POWERLEVEL9K_NETWORK_FOREGROUND=${P10K_FG_COLOR}
  typeset -g POWERLEVEL9K_NETWORK_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_NETWORK_INTERFACE_SORTING=auto
  typeset -g POWERLEVEL9K_NETWORK_VERBOSE=false

  # =========================[ LOAD: SYSTEM LOAD - ULTRA MODERN GLASSMORPHISM ]=========================
  typeset -g POWERLEVEL9K_LOAD_NORMAL_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_LOAD_WARNING_FOREGROUND=${P10K_WARNING_COLOR}
  typeset -g POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND=${P10K_ERROR_COLOR}
  typeset -g POWERLEVEL9K_LOAD_WHICH=1
  typeset -g POWERLEVEL9K_LOAD_NORMAL_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_LOAD_WARNING_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_LOAD_CRITICAL_VISUAL_IDENTIFIER_EXPANSION=''

  # =========================[ RAM: MEMORY USAGE - ULTRA MODERN GLASSMORPHISM ]=========================
  typeset -g POWERLEVEL9K_RAM_FOREGROUND=${P10K_FG_COLOR}
  typeset -g POWERLEVEL9K_RAM_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_RAM_ELEMENTS=(ram_free)

  # =========================[ CPU_ARCH: CPU USAGE - ULTRA MODERN GLASSMORPHISM ]=========================
  typeset -g POWERLEVEL9K_CPU_ARCH_FOREGROUND=${P10K_FG_COLOR}
  typeset -g POWERLEVEL9K_CPU_ARCH_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_CPU_ARCH_PREFIX="%F{${P10K_PRIMARY_COLOR}}CPU: "

  # =========================[ STATUS: EXIT CODE - FEEDBACK UX ]=========================
  # Extended states for complete visual feedback
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  
  # Success states - glassmorphism ultra modern with adaptive colors
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔'
  
  # Error states - glassmorphism ultra modern with adaptive colors
  typeset -g POWERLEVEL9K_STATUS_ERROR=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=${P10K_ERROR_COLOR}
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=${P10K_ERROR_COLOR}
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=${P10K_ERROR_COLOR}
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='✘'

  # =========================[ COMMAND_EXECUTION_TIME: DURATION ]=========================
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=${P10K_ACCENT_COLOR}
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX="%F{${P10K_PRIMARY_COLOR}}took "

  # =========================[ BACKGROUND_JOBS: BACKGROUND PROCESSES ]=========================
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=${P10K_WARNING_COLOR}
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=true

  # =========================[ KITTY TERMINAL OPTIMIZATIONS ]=========================
  # Detect Kitty terminal
  if [[ "$TERM" == "xterm-kitty" || "$TERM_PROGRAM" == "kitty" ]]; then
    # Elegant Kitty configuration with stability
    typeset -g POWERLEVEL9K_MODE=nerdfont-v3
    
    # Conservative width constraints for stability
    typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=45
    typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=70
    typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=55
    
    # Elegant separators for Kitty
    typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0B0'
    typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0B2'
    typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='\uE0B1'
    typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='\uE0B3'
    
    # Elegant multiline separators for Kitty
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{${P10K_PRIMARY_COLOR}}╭─"
    typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX="%F{${P10K_PRIMARY_COLOR}}├─"
    typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{${P10K_PRIMARY_COLOR}}╰─"
    
    # Elegant spacing for Kitty
    typeset -g POWERLEVEL9K_ICON_PADDING=moderate
    typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true
    
    # Stable features for Kitty
    typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
    typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  fi

  # =========================[ WARP AI SPECIFIC OPTIMIZATIONS ]=========================
  if [[ "$is_warp" == "true" ]]; then
    # Warp AI specific font and rendering optimizations
    typeset -g POWERLEVEL9K_MODE=nerdfont-v3
    
    # Optimize separators for Warp AI rendering
    typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0B0'
    typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0B2'
    typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='\uE0B1'
    typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='\uE0B3'
    
    # Enhanced visual separators for Warp AI - consistent with main config
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{${P10K_PRIMARY_COLOR}}╭─"
    typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX="%F{${P10K_PRIMARY_COLOR}}├─"
    typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{${P10K_PRIMARY_COLOR}}╰─"
    
    # Warp AI specific prompt symbols for better compatibility
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
    
    # Optimize spacing for Warp AI
    typeset -g POWERLEVEL9K_ICON_PADDING=none
    typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true
    
    # Enhanced performance for Warp AI
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
    typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
    
    # Warp AI specific color adjustments for better contrast
    typeset -g POWERLEVEL9K_BACKGROUND=${P10K_BG_COLOR}
    typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=${P10K_SECONDARY_COLOR}
    typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=${P10K_ERROR_COLOR}
    
    # Optimize directory display for Warp AI - stable configuration
    typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=70
    typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=80
    typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=60
  fi

  # =========================[ ADDITIONAL CONFIGURATIONS - ELEGANT SETUP ]=========================
  # Elegant transient prompt for fluid experience
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always

  # Disable instant prompt to prevent cache issues
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

  # Disable hot reload for stability
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
  
  # Elegant newline addition
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  
  # Disable gitstatusd messages
  export GITSTATUS_DAEMON_LOG_LEVEL=ERROR
  export GITSTATUS_DAEMON_LOG_LEVEL_STDERR=ERROR

  # =========================[ ROOT_INDICATOR: ELEGANT ROOT INDICATOR ]=========================
  # Elegant root indicator - positioned before directory
  function prompt_root_indicator() {
    p10k segment -f red -t '' -b ''
  }

  # =========================[ THEME RELOAD FUNCTION ]=========================
  # Function to reload theme with new colors
  function p10k_reload_theme() {
    detect_terminal_theme
    get_adaptive_colors
    get_terminal_specific_colors
    p10k reload
  }

  # Make reload function available globally (zsh compatible)
  autoload -Uz p10k_reload_theme

  # If p10k is already loaded, reload configuration
  (( ! $+functions[p10k] )) || p10k reload
}

# Configuration file for p10k configure
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts' 