# =====================================================
# 🚀 BASH BASE CONFIGURATION - SHARED FOUNDATION
# =====================================================
# Configuración base compartida entre usuario y root
# Optimizada para rendimiento y productividad máxima
# =====================================================

# =====================================================
# 💾 ADVANCED CACHE SYSTEM
# =====================================================

# Cache directory structure
BASH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/bash"
mkdir -p "$BASH_CACHE_DIR"

# Cache for environment variables (expires after 6 hours)
cache_env_vars() {
    local cache_file="$BASH_CACHE_DIR/env_vars"
    local cache_time=21600  # 6 hours
    
    if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_time ]]; then
        source "$cache_file"
    else
        # Generate environment cache
        {
            echo "export LANG=\"${ARCH_DREAM_LOCALE:-C.utf8}\""
            echo "export LC_ALL=\"${ARCH_DREAM_LOCALE:-C.utf8}\""
            echo "export EDITOR='nvim'"
            echo "export VISUAL='nvim'"
            echo "export BROWSER='firefox'"
            echo "export TERMINAL='kitty'"
        } > "$cache_file"
        source "$cache_file"
    fi
}

# Cache for PATH optimization (expires after 12 hours)
cache_path_vars() {
    local cache_file="$BASH_CACHE_DIR/path_vars"
    local cache_time=43200  # 12 hours
    
    if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_time ]]; then
        source "$cache_file"
    else
        # Build optimized PATH
        local -a path_dirs
        local base_user_home="${HOME:-/home/$USER}"
        
        # Add paths only if they exist
        [[ -d "$base_user_home/.local/bin" ]] && path_dirs+=("$base_user_home/.local/bin")
        [[ -d "$base_user_home/.cargo/bin" ]] && path_dirs+=("$base_user_home/.cargo/bin")
        [[ -d "$base_user_home/.bun/bin" ]] && path_dirs+=("$base_user_home/.bun/bin")
        [[ -d "$base_user_home/.npm-global/bin" ]] && path_dirs+=("$base_user_home/.npm-global/bin")
        [[ -d "/usr/local/bin" ]] && path_dirs+=("/usr/local/bin")
        
        # Build GOPATH
        local gopath="${GOPATH:-$base_user_home/go}"
        [[ -d "$gopath/bin" ]] && path_dirs+=("$gopath/bin")
        
        # Generate cache
        {
            printf 'export PATH="%s:$PATH"\n' "$(IFS=:; echo "${path_dirs[*]}")"
            echo "export GOPATH=\"$gopath\""
            echo "export NODE_ENV=development"
        } > "$cache_file"
        source "$cache_file"
    fi
}

# Cache for command availability (expires after 24 hours)
cache_commands() {
    local cache_file="$BASH_CACHE_DIR/commands"
    local cache_time=86400  # 24 hours
    
    if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_time ]]; then
        source "$cache_file"
    else
        # Check command availability
        {
            for cmd in eza bat rg fd btop htop duf dust delta xh procs starship yay paru; do
                if command -v "$cmd" &>/dev/null; then
                    echo "export HAS_${cmd^^}=1"
                fi
            done
        } > "$cache_file"
        source "$cache_file"
    fi
}

# Initialize cache system
init_bash_cache() {
    cache_env_vars
    cache_path_vars
    cache_commands
}

# =====================================================
# 📋 OPTIMIZED HISTORY CONFIGURATION
# =====================================================

setup_bash_history() {
    # Increase history size to match ZSH (50000)
    export HISTCONTROL=ignoreboth:erasedups
    export HISTSIZE=50000
    export HISTFILESIZE=100000
    export HISTTIMEFORMAT="%Y-%m-%d %T "
    export HISTIGNORE="ls:ll:la:cd:pwd:clear:history:exit:bg:fg:jobs"
    
    # Append to history file, don't overwrite
    shopt -s histappend
    
    # Update history after each command
    export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
}

# =====================================================
# 🛠️ INTELLIGENT ALIASES SYSTEM
# =====================================================

setup_modern_aliases() {
    # File Operations with modern tools (using cache)
    if [[ "$HAS_EZA" == "1" ]]; then
        alias ls='eza --icons --group-directories-first --git'
        alias ll='eza -l --icons --group-directories-first --git --time-style=long-iso --smart-group'
        alias la='eza -la --icons --group-directories-first --git --time-style=long-iso'
        alias tree='eza --tree --level=3 --icons --git-ignore'
        alias ltree='eza --tree --level=4 --icons --long --git-ignore'
        alias lt='eza --tree --level=2 --icons --git-ignore'
        alias lta='eza --tree --level=2 --icons --git-ignore --all'
    else
        alias ls='ls --color=auto --group-directories-first'
        alias ll='ls -alF --color=auto --group-directories-first'
        alias la='ls -A --color=auto --group-directories-first'
        alias l='ls -CF --color=auto'
    fi

    # Modern replacements (using cache)
    if [[ "$HAS_BAT" == "1" ]]; then
        alias cat='bat --style=plain --paging=never'
        alias ccat='bat --style=full'
        export BAT_THEME="Catppuccin Frappe"
    fi

    if [[ "$HAS_RG" == "1" ]]; then
        alias grep='rg --smart-case --hidden --glob "!**/.git/*" --glob "!**/node_modules/*"'
        alias rga='rg --no-ignore --hidden'
        alias rgi='rg --case-insensitive'
        alias rgf='rg --files --glob'
    fi

    if [[ "$HAS_FD" == "1" ]]; then
        alias find='fd'
        alias fda='fd --no-ignore --hidden'
        alias fdi='fd --case-insensitive'
        alias fde='fd --extension'
    fi

    # System monitoring (using cache)
    if [[ "$HAS_BTOP" == "1" ]]; then
        alias top='btop'
    elif [[ "$HAS_HTOP" == "1" ]]; then
        alias top='htop'
    fi

    if [[ "$HAS_DUF" == "1" ]]; then
        alias df='duf'
    fi

    if [[ "$HAS_DUST" == "1" ]]; then
        alias du='dust'
    fi

    if [[ "$HAS_DELTA" == "1" ]]; then
        alias diff='delta'
    fi

    if [[ "$HAS_XH" == "1" ]]; then
        alias http='xh'
    fi

    if [[ "$HAS_PROCS" == "1" ]]; then
        alias pps='procs'
    fi
}

# =====================================================
# 🚀 NAVIGATION AND GIT ALIASES
# =====================================================

setup_navigation_aliases() {
    # Navigation shortcuts
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias ~='cd ~'
    alias -- -='cd -'

    # Safety aliases
    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'
    alias mkdir='mkdir -p'

    # Git aliases - Enhanced
    alias g='git'
    alias gs='git status --short --branch'
    alias ga='git add'
    alias gaa='git add --all'
    alias gc='git commit --verbose'
    alias gcm='git commit -m'
    alias gca='git commit -am'
    alias gp='git push'
    alias gpl='git pull'
    alias gl='git log --oneline --graph --decorate --all -10'
    alias gd='git diff'
    alias gdc='git diff --cached'
    alias gco='git checkout'
    alias gb='git branch'
    alias gba='git branch -a'
    alias gbd='git branch -d'
    alias gm='git merge'
    alias gr='git rebase'
    alias gst='git stash'
    alias gstp='git stash pop'
    alias gf='git fetch'
    alias gcl='git clone'
}

# =====================================================
# 📦 PACKAGE MANAGEMENT ALIASES
# =====================================================

setup_package_aliases() {
    # Arch Linux specific aliases
    local pac_prefix=""
    if [[ "$EUID" -ne 0 ]]; then
        pac_prefix="sudo "
    fi
    
    alias pac="${pac_prefix}pacman"
    alias pacr="${pac_prefix}pacman -R"
    alias pacu="${pac_prefix}pacman -Syu"
    alias pacq='pacman -Q'
    alias pacqi='pacman -Qi'
    alias pacql='pacman -Ql'
    alias pacqo='pacman -Qo'
    alias pacc="${pac_prefix}pacman -Sc"
    alias paccc="${pac_prefix}pacman -Scc"
    alias pacs='pacman -Ss'
    alias paci="${pac_prefix}pacman -S"

    # AUR helper detection (using cache)
    if [[ "$HAS_YAY" == "1" ]]; then
        alias aur='yay'
        alias aurs='yay -Ss'
        alias auri='yay -S'
        alias auru='yay -Syu'
    elif [[ "$HAS_PARU" == "1" ]]; then
        alias aur='paru'
        alias aurs='paru -Ss'
        alias auri='paru -S'
        alias auru='paru -Syu'
    fi
}

# =====================================================
# 🔧 DEVELOPMENT ALIASES
# =====================================================

setup_development_aliases() {
    # Python
    alias py='python3'
    alias py3='python3'
    alias pip='pip3'
    alias venv='python3 -m venv'
    alias activate='source ./venv/bin/activate'

    # Node.js
    alias n='npm'
    alias ni='npm install'
    alias nid='npm install --save-dev'
    alias nrb='npm run build'
    alias nrd='npm run dev'
    alias y='yarn'
    alias yi='yarn install'
    alias yrb='yarn build'
    alias yrd='yarn dev'

    # Network aliases
    alias myip='curl -s ifconfig.me && echo'
    alias localip="ip route get 8.8.8.8 | awk '{print \$7}'"
    alias ping='ping -c 5'

    # Process management
    alias psg='ps aux | grep -v grep | grep -i'
    alias killall='killall -i'
    alias j='jobs'
    alias h='history'

    # File opening
    alias open='xdg-open'
    alias edit='$EDITOR'
    alias vim="nvim"
    alias vi="nvim"
}

# =====================================================
# 🎯 CORE UTILITY FUNCTIONS
# =====================================================

# Extract function for various archive types
extract() {
    [[ -f "$1" ]] || { echo "'$1' is not a valid file"; return 1; }
    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz)  tar xzf "$1" ;;
        *.bz2)     bunzip2 "$1" ;;
        *.rar)     unrar x "$1" ;;
        *.gz)      gunzip "$1"  ;;
        *.tar)     tar xf "$1"  ;;
        *.tbz2)    tar xjf "$1" ;;
        *.tgz)     tar xzf "$1" ;;
        *.zip)     unzip "$1"   ;;
        *.Z)       uncompress "$1" ;;
        *.7z)      7z x "$1"    ;;
        *.xz)      unxz "$1"    ;;
        *.exe)     cabextract "$1" ;;
        *.deb)     ar x "$1" && tar xf data.tar.* ;;
        *.rpm)     rpm2cpio "$1" | cpio -idmv ;;
        *)         echo "'$1': unrecognized file compression" ;;
    esac
}

# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Quick backup of a file
backup() { cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"; }

# Quick password generator
passgen() { openssl rand -base64 "${1:-12}" | tr -d "=+/" | cut -c1-${1:-12}; }

# Quick calculator
calc() { echo "$*" | bc -l; }

# =====================================================
# 🎯 ENHANCED GIT FUNCTIONS
# =====================================================

# Git workflow functions with validation
gac() {
    if [[ -z "$1" ]]; then
        echo "❌ Error: Commit message required"
        echo "Usage: gac \"commit message\""
        return 1
    fi
    git add --all && git commit -m "$1"
}

gacp() {
    if [[ -z "$1" ]]; then
        echo "❌ Error: Commit message required"
        echo "Usage: gacp \"commit message\""
        return 1
    fi
    git add --all && git commit -m "$1" && git push
}

gundo() {
    git reset --soft HEAD~1
    echo "✅ Last commit undone (changes preserved)"
}

gamend() {
    git commit --amend --no-edit
    echo "✅ Changes added to last commit"
}

gcleanhard() {
    git clean -fd && git reset --hard HEAD
    echo "✅ Working directory cleaned (HARD RESET)"
}

# =====================================================
# 💻 SYSTEM INFORMATION
# =====================================================

# Enhanced system information
sysinfo() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo "Memory Usage: $(free -h | awk '/^Mem:/ {printf "%s/%s (%.1f%%)", $3, $2, $3/$2*100}')"
    echo "Disk Usage: $(df -h / | awk 'NR==2 {printf "%s/%s (%s)", $3, $2, $5}')"
    echo "CPU Temperature: $(sensors 2>/dev/null | grep 'Core 0' | awk '{print $3}' || echo 'N/A')"
}

# =====================================================
# 🎨 PROMPT CONFIGURATION
# =====================================================

setup_bash_prompt() {
    if [[ "$HAS_STARSHIP" == "1" ]]; then
        eval "$(starship init bash)"
    else
        # Fallback prompt with git status
        parse_git_branch() {
            git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
        }
        
        # Enhanced color prompt with git integration
        if [[ "$EUID" -eq 0 ]]; then
            PS1='\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(parse_git_branch)\[\033[00m\]# '
        else
            PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(parse_git_branch)\[\033[00m\]\$ '
        fi
    fi
}

# =====================================================
# 🏁 INITIALIZATION FUNCTION
# =====================================================

init_bash_base() {
    # Initialize cache system
    init_bash_cache
    
    # Setup configurations
    setup_bash_history
    setup_modern_aliases
    setup_navigation_aliases
    setup_package_aliases
    setup_development_aliases
    setup_bash_prompt
    
    # Shell options
    shopt -s checkwinsize
    shopt -s histappend
    
    # Disable flow control commands
    stty -ixon 2>/dev/null
    
    # Colors
    export CLICOLOR=1
    export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
    
    # XDG Base Directory Specification
    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
    export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
    export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
}

# Make functions available
export -f init_bash_base setup_bash_history setup_modern_aliases
export -f extract mkcd backup passgen calc gac gacp gundo gamend gcleanhard sysinfo