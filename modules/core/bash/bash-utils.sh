#!/bin/bash
# =====================================================
# 🛠️ BASH UTILITIES - UNIFIED SCRIPT COLLECTION
# =====================================================
# Unified collection of bash utility functions and scripts
# Replaces: bash_wrapper.sh, exec-bash-silent.sh, silent_bashrc
# =====================================================

# =====================================================
# 🔧 LOCALE AND ENVIRONMENT UTILITIES
# =====================================================

# Clean locale setup function with dependency validation
setup_clean_locale() {
    local locale="${ARCH_DREAM_LOCALE:-en_US.UTF-8}"
    
    # Validate locale is available on system
    if ! locale -a 2>/dev/null | grep -q "${locale%.*}"; then
        # Fallback to C.utf8 if primary locale not available
        locale="C.utf8"
        if ! locale -a 2>/dev/null | grep -q "C.utf8"; then
            # Final fallback to POSIX
            locale="C"
        fi
    fi
    
    # Unset all locale variables
    unset LANG LC_ALL LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY \
          LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE \
          LC_MEASUREMENT LC_IDENTIFICATION 2>/dev/null
    
    # Set clean locale
    export LANG="$locale"
    export LC_ALL="$locale"
    export ARCH_DREAM_LOCALE="$locale"
}

# Silent environment setup
setup_silent_env() {
    setup_clean_locale
    
    # Redirect common error outputs
    exec 3>&2 2>/dev/null
    
    # Restore stderr when needed
    restore_stderr() {
        exec 2>&3 3>&-
    }
    
    export -f restore_stderr
}

# =====================================================
# 🚀 BASH EXECUTION WRAPPERS
# =====================================================

# Execute bash with clean environment
exec_bash_clean() {
    setup_clean_locale
    exec bash "$@"
}

# Execute bash silently (suppress setlocale warnings)
exec_bash_silent() {
    setup_clean_locale
    exec bash "$@" 2> >(grep -v "setlocale\|locale\|LC_" >&2)
}

# Execute bash with wrapper (comprehensive setup)
exec_bash_wrapper() {
    # Force clean environment
    setup_clean_locale
    
    # Set minimal environment
    export TERM="${TERM:-xterm-256color}"
    export SHELL="/bin/bash"
    
    # Execute with clean slate
    exec bash "$@" 2>/dev/null
}

# =====================================================
# 📄 BASHRC UTILITIES
# =====================================================

# Source bashrc silently
source_bashrc_silent() {
    local bashrc_path="${1:-$HOME/.bashrc}"
    
    if [[ -f "$bashrc_path" ]]; then
        setup_clean_locale
        source "$bashrc_path" 2> >(grep -v "setlocale\|locale\|LC_" >&2)
    fi
}

# Create silent bashrc wrapper
create_silent_bashrc() {
    local target_file="${1:-$HOME/.bashrc_silent}"
    local source_bashrc="${2:-$HOME/.bashrc}"
    
    cat > "$target_file" << EOF
#!/bin/bash
# Silent bashrc wrapper - Auto-generated
# Generated on: $(date)

# Force locale override
export ARCH_DREAM_LOCALE="\${ARCH_DREAM_LOCALE:-C.utf8}"
export LANG="\$ARCH_DREAM_LOCALE"
export LC_ALL="\$ARCH_DREAM_LOCALE"

# Source the real bashrc but suppress locale warnings
if [[ -f "$source_bashrc" ]]; then
    source "$source_bashrc" 2> >(grep -v "setlocale\|locale\|LC_" >&2)
fi
EOF
    
    chmod +x "$target_file"
    echo "Silent bashrc wrapper created: $target_file"
}

# =====================================================
# 🎯 DEVELOPMENT UTILITIES
# =====================================================

# Quick development environment setup
setup_dev_env() {
    local project_type="${1:-generic}"
    
    case "$project_type" in
        node|nodejs)
            setup_clean_locale
            [[ -s "$HOME/.nvm/nvm.sh" ]] && source "$HOME/.nvm/nvm.sh"
            echo "Node.js environment loaded"
            ;;
        rust)
            setup_clean_locale
            [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
            echo "Rust environment loaded"
            ;;
        python)
            setup_clean_locale
            if [[ -d "venv" ]]; then
                source venv/bin/activate
                echo "Python virtual environment activated"
            elif [[ -d ".venv" ]]; then
                source .venv/bin/activate
                echo "Python virtual environment activated"
            fi
            ;;
        *)
            setup_clean_locale
            echo "Generic development environment setup"
            ;;
    esac
}

# =====================================================
# 🔍 DEPENDENCY VALIDATION UTILITIES
# =====================================================

# Validate FZF dependencies
validate_fzf_deps() {
    local issues=()
    
    # Check if fzf is installed
    if ! command -v fzf &> /dev/null; then
        issues+=("FZF not installed")
        return 1
    fi
    
    # Check fd dependency
    if ! command -v fd &> /dev/null; then
        issues+=("fd not installed (required for FZF_DEFAULT_COMMAND)")
        echo "Warning: fd not found. Install with: pacman -S fd"
    fi
    
    # Check FZF integration files
    if [[ ! -f /usr/share/fzf/key-bindings.bash ]] || [[ ! -f /usr/share/fzf/completion.bash ]]; then
        issues+=("FZF bash integration files missing")
        echo "Warning: FZF bash integration not found. Reinstall fzf package."
    fi
    
    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "FZF validation issues found:"
        printf "  - %s\n" "${issues[@]}"
        return 1
    fi
    
    echo "✓ FZF dependencies validated"
    return 0
}

# Validate development tools
validate_dev_tools() {
    local missing=()
    
    # Essential tools
    local tools=("git" "curl" "wget" "unzip" "tar")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing+=("$tool")
        fi
    done
    
    # Optional development tools
    local optional=("nvim" "code" "node" "npm" "cargo" "python3")
    local optional_missing=()
    for tool in "${optional[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            optional_missing+=("$tool")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Missing essential tools:"
        printf "  - %s\n" "${missing[@]}"
        return 1
    fi
    
    if [[ ${#optional_missing[@]} -gt 0 ]]; then
        echo "Optional tools not found:"
        printf "  - %s\n" "${optional_missing[@]}"
    fi
    
    echo "✓ Development tools validated"
    return 0
}

# =====================================================
# 🧹 CLEANUP AND MAINTENANCE
# =====================================================

# Clean bash cache
clean_bash_cache() {
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/bash"
    
    if [[ -d "$cache_dir" ]]; then
        rm -rf "$cache_dir"/*
        echo "Bash cache cleaned: $cache_dir"
    else
        echo "No bash cache found"
    fi
}

# Reset bash environment
reset_bash_env() {
    # Clean cache
    clean_bash_cache
    
    # Reset history
    history -c
    history -r
    
    # Reload bashrc
    if [[ -f "$HOME/.bashrc" ]]; then
        source "$HOME/.bashrc"
        echo "Bash environment reset and reloaded"
    fi
}

# =====================================================
# 🔍 DIAGNOSTIC UTILITIES
# =====================================================

# Diagnose bash configuration
diagnose_bash() {
    echo "=== Bash Configuration Diagnostics ==="
    echo "Bash version: $BASH_VERSION"
    echo "Shell: $SHELL"
    echo "LANG: $LANG"
    echo "LC_ALL: $LC_ALL"
    echo "TERM: $TERM"
    echo
    
    echo "=== Configuration Files ==="
    for file in ~/.bashrc ~/.bash_profile ~/.bashrc.local; do
        if [[ -f "$file" ]]; then
            echo "✓ $file ($(stat -c%s "$file") bytes)"
        else
            echo "✗ $file (missing)"
        fi
    done
    echo
    
    echo "=== Cache Status ==="
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/bash"
    if [[ -d "$cache_dir" ]]; then
        echo "Cache directory: $cache_dir"
        echo "Cache size: $(du -sh "$cache_dir" 2>/dev/null | cut -f1)"
        echo "Cache files: $(find "$cache_dir" -type f 2>/dev/null | wc -l)"
    else
        echo "No cache directory found"
    fi
    echo
    
    echo "=== History Status ==="
    echo "HISTSIZE: $HISTSIZE"
    echo "HISTFILESIZE: $HISTFILESIZE"
    echo "History file: $HISTFILE"
    if [[ -f "$HISTFILE" ]]; then
        echo "History entries: $(wc -l < "$HISTFILE" 2>/dev/null || echo "unknown")"
    fi
}

# =====================================================
# 🏁 MAIN FUNCTIONS FOR SCRIPT EXECUTION
# =====================================================

# Main function for script execution
main() {
    local action="${1:-help}"
    shift
    
    case "$action" in
        clean-locale)
            setup_clean_locale
            echo "Clean locale environment set up"
            ;;
        silent-env)
            setup_silent_env
            echo "Silent environment set up"
            ;;
        exec-clean)
            exec_bash_clean "$@"
            ;;
        exec-silent)
            exec_bash_silent "$@"
            ;;
        exec-wrapper)
            exec_bash_wrapper "$@"
            ;;
        source-silent)
            source_bashrc_silent "$@"
            ;;
        create-silent)
            create_silent_bashrc "$@"
            ;;
        setup-dev)
            setup_dev_env "$@"
            ;;
        clean-cache)
            clean_bash_cache
            ;;
        reset)
            reset_bash_env
            ;;
        diagnose)
            diagnose_bash
            ;;
        validate-fzf)
            validate_fzf_deps
            ;;
        validate-tools)
            validate_dev_tools
            ;;
        help|*)
            cat << 'EOF'
Bash Utilities - Unified Script Collection

Usage: bash-utils.sh <action> [arguments]

Actions:
  clean-locale          Set up clean locale environment
  silent-env           Set up silent environment (suppress errors)
  exec-clean           Execute bash with clean environment
  exec-silent          Execute bash silently (suppress locale warnings)
  exec-wrapper         Execute bash with comprehensive wrapper
  source-silent        Source bashrc silently
  create-silent [file] Create silent bashrc wrapper
  setup-dev [type]     Set up development environment (node|rust|python)
  clean-cache          Clean bash cache
  reset                Reset bash environment
  diagnose             Show bash configuration diagnostics
  validate-fzf         Validate FZF and dependencies
  validate-tools       Validate development tools
  help                 Show this help message

Examples:
  bash-utils.sh exec-silent
  bash-utils.sh setup-dev node
  bash-utils.sh create-silent ~/.bashrc_silent
  bash-utils.sh diagnose
EOF
            ;;
    esac
}

# Export functions for use in other scripts
export -f setup_clean_locale setup_silent_env exec_bash_clean exec_bash_silent
export -f exec_bash_wrapper source_bashrc_silent create_silent_bashrc
export -f setup_dev_env clean_bash_cache reset_bash_env diagnose_bash
export -f validate_fzf_deps validate_dev_tools

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi