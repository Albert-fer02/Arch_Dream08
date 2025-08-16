# =====================================================
# 🎨 P10K BASE CONFIGURATION - UNIFIED THEME SYSTEM
# =====================================================
# Base configuration shared between user and root
# Optimized for terminal theme detection and performance
# =====================================================

# =========================[ DYNAMIC COLOR DETECTION & ADAPTATION ]=========================

# Function to detect terminal theme and background
function detect_terminal_theme() {
  local is_dark=true
  local is_light=false
  
  # Detect terminal type and theme
  case "$TERM_PROGRAM" in
    "iTerm.app")
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
      export P10K_SEPARATOR_STYLE="powerline"
      export P10K_ICON_PADDING="moderate"
      ;;
    "WarpTerminal"|"warp")
      export P10K_SEPARATOR_STYLE="round"
      export P10K_ICON_PADDING="minimal"
      ;;
    "vscode")
      export P10K_SEPARATOR_STYLE="flat"
      export P10K_ICON_PADDING="standard"
      ;;
    *)
      export P10K_SEPARATOR_STYLE="powerline"
      export P10K_ICON_PADDING="standard"
      ;;
  esac
}

# =========================[ SHARED P10K CONFIGURATION ]=========================

function setup_p10k_base() {
  # Initialize theme detection and colors
  detect_terminal_theme
  get_adaptive_colors
  get_terminal_specific_colors

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

  # =========================[ OS_ICON: SYSTEM ICON ]=========================
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION=''

  # =========================[ PROMPT_CHAR: PROMPT SYMBOL ]=========================
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=${P10K_ERROR_COLOR}
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

  # =========================[ DIR: CURRENT DIRECTORY ]=========================
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=${P10K_FG_COLOR}
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=''
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=${P10K_DIM_COLOR}
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  
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

  # =========================[ VCS: GIT STATUS ]=========================
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR=${P10K_ACCENT_COLOR}
  typeset -g POWERLEVEL9K_VCS_PREFIX="%F{${P10K_PRIMARY_COLOR}}on "
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=${P10K_WARNING_COLOR}

  # =========================[ STATUS: EXIT CODE ]=========================
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=${P10K_SECONDARY_COLOR}
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔'
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

  # =========================[ COMMAND_EXECUTION_TIME ]=========================
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=${P10K_ACCENT_COLOR}
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX="%F{${P10K_PRIMARY_COLOR}}took "

  # =========================[ BACKGROUND_JOBS ]=========================
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=${P10K_WARNING_COLOR}
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=true

  # Disable gitstatusd messages
  export GITSTATUS_DAEMON_LOG_LEVEL=ERROR
  export GITSTATUS_DAEMON_LOG_LEVEL_STDERR=ERROR
}

# Function to reload theme with new colors
function p10k_reload_theme() {
  detect_terminal_theme
  get_adaptive_colors
  get_terminal_specific_colors
  p10k reload
}

# Make functions available globally
autoload -Uz setup_p10k_base p10k_reload_theme
