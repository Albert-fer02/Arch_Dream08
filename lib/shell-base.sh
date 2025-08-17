#!/bin/bash
# =====================================================
# 🚀 ARCH DREAM - SHELL BASE CONFIGURATION
# =====================================================
# Configuración base unificada para Bash y Zsh
# Elimina duplicaciones y centraliza configuraciones comunes
# =====================================================

# =====================================================
# 🔧 CORE INITIALIZATION
# =====================================================

init_shell_base() {
    # Detectar shell actual
    export CURRENT_SHELL="$(ps -p $$ -o comm= 2>/dev/null || echo 'unknown')"
    export IS_ZSH=false
    export IS_BASH=false
    
    case "$CURRENT_SHELL" in
        *zsh*) export IS_ZSH=true ;;
        *bash*) export IS_BASH=true ;;
    esac
    
    # Detectar si es root
    export IS_ROOT=false
    [[ "$EUID" -eq 0 ]] && export IS_ROOT=true
    
    # Cargar componentes base
    load_environment_variables
    load_path_configuration
    load_modern_tools
    load_shared_aliases
    load_shared_functions
    load_starship_config
}

# =====================================================
# 🌐 ENVIRONMENT VARIABLES
# =====================================================

load_environment_variables() {
    # Locale Configuration
    export ARCH_DREAM_LOCALE="${ARCH_DREAM_LOCALE:-en_US.UTF-8}"
    export LANG="$ARCH_DREAM_LOCALE"
    export LC_ALL="$ARCH_DREAM_LOCALE"
    export LC_COLLATE=C

    # Editor Configuration
    export EDITOR='nvim'
    export VISUAL='nvim'
    export BROWSER='firefox'
    export TERMINAL='kitty'

    # XDG Base Directory Specification
    if [[ "$IS_ROOT" == "true" ]]; then
        export XDG_CONFIG_HOME="/root/.config"
        export XDG_DATA_HOME="/root/.local/share"
        export XDG_CACHE_HOME="/root/.cache"
        export XDG_STATE_HOME="/root/.local/state"
    else
        export XDG_CONFIG_HOME="$HOME/.config"
        export XDG_DATA_HOME="$HOME/.local/share"
        export XDG_CACHE_HOME="$HOME/.cache"
        export XDG_STATE_HOME="$HOME/.local/state"
    fi

    # Development Environment
    if [[ "$IS_ROOT" == "true" ]]; then
        export GOPATH="/root/go"
    else
        export GOPATH="$HOME/go"
    fi
    export NODE_ENV=development

    # Performance optimizations
    export ARCHFLAGS="-arch x86_64"
    
    # Root-specific environment
    if [[ "$IS_ROOT" == "true" ]]; then
        export ROOT_MODE=1
        export FASTFETCH_DISABLE_AUTO=1
        export NEOFETCH_DISABLE_AUTO=1
    fi
}

# =====================================================
# 🛤️ PATH CONFIGURATION
# =====================================================

load_path_configuration() {
    local base_path="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    local user_paths local_bin cargo_bin npm_bin go_bin bun_bin
    
    if [[ "$IS_ROOT" == "true" ]]; then
        user_paths="/root/.local/bin"
        local_bin="/root/.local/bin"
        cargo_bin="/root/.cargo/bin"
        npm_bin="/root/.npm-global/bin"
        go_bin="/root/go/bin"
        bun_bin="/root/.bun/bin"
    else
        user_paths="$HOME/.local/bin"
        local_bin="$HOME/.local/bin"
        cargo_bin="$HOME/.cargo/bin"
        npm_bin="$HOME/.npm-global/bin"
        go_bin="$HOME/go/bin"
        bun_bin="$HOME/.bun/bin"
    fi
    
    # Build PATH with proper precedence
    export PATH="$local_bin:$cargo_bin:$npm_bin:$go_bin:$bun_bin:/usr/local/go/bin:$base_path"
    
    # Add Homebrew support for non-Arch environments
    [[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:$PATH"
    
    # Add security tools paths (only if they exist)
    [[ -d /opt/metasploit-framework/bin ]] && export PATH="$PATH:/opt/metasploit-framework/bin"
    [[ -d /opt/burpsuite ]] && export PATH="$PATH:/opt/burpsuite"
    [[ -d /opt/nmap/bin ]] && export PATH="$PATH:/opt/nmap/bin"
}

# =====================================================
# 🛠️ MODERN TOOLS CONFIGURATION
# =====================================================

load_modern_tools() {
    # Bat (better cat)
    if command -v bat &> /dev/null; then
        export BAT_THEME="Catppuccin Frappe"
        alias cat='bat --style=plain --paging=never'
        alias ccat='bat --style=full'
    fi

    # Eza (better ls)
    if command -v eza &> /dev/null; then
        alias ls='eza --icons --group-directories-first --git'
        alias ll='eza -l --icons --group-directories-first --git --time-style=long-iso --smart-group'
        alias la='eza -la --icons --group-directories-first --git --time-style=long-iso'
        alias tree='eza --tree --level=3 --icons --git-ignore'
        alias ltree='eza --tree --level=4 --icons --long --git-ignore'
        alias lt='eza --tree --level=2 --icons --git-ignore'
        alias lta='eza --tree --level=2 --icons --git-ignore --all'
    else
        alias ll='ls -alF --color=auto --group-directories-first'
        alias la='ls -A --color=auto --group-directories-first'
        alias ls='ls --color=auto --group-directories-first'
    fi

    # Ripgrep (better grep)
    if command -v rg &> /dev/null; then
        alias grep='rg --smart-case --hidden --glob "!**/.git/*" --glob "!**/node_modules/*"'
        alias rga='rg --no-ignore --hidden'
        alias rgi='rg --case-insensitive'
        alias rgf='rg --files --glob'
    fi

    # Fd (better find)
    if command -v fd &> /dev/null; then
        alias find='fd'
        alias fda='fd --no-ignore --hidden'
        alias fdi='fd --case-insensitive'
        alias fde='fd --extension'
    fi

    # System monitoring
    command -v duf &> /dev/null && alias df='duf'
    command -v dust &> /dev/null && alias du='dust'
    command -v btop &> /dev/null && alias top='btop' || command -v htop &> /dev/null && alias top='htop'
    command -v delta &> /dev/null && alias diff='delta'
    command -v xh &> /dev/null && alias http='xh'
    command -v procs &> /dev/null && alias pps='procs'
}

# =====================================================
# 🔗 SHARED ALIASES
# =====================================================

load_shared_aliases() {
    # Navigation shortcuts
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias ~='cd ~'
    alias -- -='cd -'

    # Directory shortcuts
    if [[ "$IS_ROOT" == "true" ]]; then
        alias dl='cd /root/Downloads'
        alias dt='cd /root/Desktop'
        alias dc='cd /root/Documents'
        alias dev='cd /root/Development'
        alias proj='cd /root/Projects'
        alias opt='cd /opt'
        alias etc='cd /etc'
        alias logs='cd /var/log'
    else
        alias dl='cd ~/Downloads'
        alias dt='cd ~/Desktop'
        alias dc='cd ~/Documents'
        alias dev='cd ~/Development'
        alias proj='cd ~/Projects'
        alias tools='cd /opt'
        alias www='cd /var/www'
        alias logs='cd /var/log'
    fi
    alias tmp='cd /tmp'

    # File operations with safety
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

    # Pacman aliases
    if [[ "$IS_ROOT" == "true" ]]; then
        alias pac='pacman'
        alias pacr='pacman -R'
        alias pacu='pacman -Syu'
    else
        alias pac='sudo pacman'
        alias pacr='sudo pacman -R'
        alias pacu='sudo pacman -Syu'
    fi
    alias pacq='pacman -Q'
    alias pacqi='pacman -Qi'
    alias pacql='pacman -Ql'
    alias pacqo='pacman -Qo'
    alias pacc='sudo pacman -Sc'
    alias paccc='sudo pacman -Scc'
    alias pacs='pacman -Ss'
    alias paci='sudo pacman -S'

    # AUR helper detection
    if command -v yay &> /dev/null; then
        alias aur='yay'
        alias aurs='yay -Ss'
        alias auri='yay -S'
        alias auru='yay -Syu'
    elif command -v paru &> /dev/null; then
        alias aur='paru'
        alias aurs='paru -Ss'
        alias auri='paru -S'
        alias auru='paru -Syu'
    fi

    # Network aliases
    alias myip='curl -s ifconfig.me && echo'
    alias localip="ip route get 8.8.8.8 | awk '{print \$7}'"
    alias ports='sudo lsof -i -P -n | grep LISTEN'
    alias netstat='ss -tuln'
    alias listening='ss -tlnp'
    alias connections='ss -tup'
    alias ping='ping -c 5'

    # Development aliases
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

    # System aliases
    alias arch="cat /etc/arch-release 2>/dev/null || echo 'Arch Linux'"
    alias kernel="uname -r"
    alias uptime="uptime -p"
    alias memory="free -h"
    alias disk="df -h"
    alias processes="ps aux --sort=-%cpu | head -20"

    # Editor aliases
    alias vim="nvim"
    alias vi="nvim"

    # Quick access aliases
    if [[ "$IS_ROOT" == "true" ]]; then
        alias zshrc="nvim /root/.zshrc"
        alias bashrc="nvim /root/.bashrc"
        alias reload-zsh="source /root/.zshrc"
        alias reload-bash="source /root/.bashrc"
    else
        alias zshrc="nvim ~/.zshrc"
        alias bashrc="nvim ~/.bashrc"
        alias reload-zsh="source ~/.zshrc"
        alias reload-bash="source ~/.bashrc"
    fi
    alias starship-config="nvim $XDG_CONFIG_HOME/starship.toml"

    # Fastfetch aliases
    alias ff="fastfetch"
    alias ff-dream="fastfetch --config ~/.config/fastfetch/themes/dreamcoder.jsonc"
    alias ff-custom="fastfetch --config ~/.config/fastfetch/config.local.jsonc"
}

# =====================================================
# ⚡ SHARED FUNCTIONS
# =====================================================

load_shared_functions() {
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
    mkcd() {
        mkdir -p "$1" && cd "$1"
    }

    # Quick backup with timestamp
    backup() {
        cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
    }

    # Quick password generator
    passgen() {
        openssl rand -base64 "${1:-12}" | tr -d "=+/" | cut -c1-${1:-12}
    }

    # Quick calculator
    calc() {
        echo "$*" | bc -l
    }

    # Git functions
    gac() {
        [[ -z "$1" ]] && { echo "Usage: gac \"commit message\""; return 1; }
        git add --all && git commit -m "$1"
    }

    gacp() {
        [[ -z "$1" ]] && { echo "Usage: gacp \"commit message\""; return 1; }
        git add --all && git commit -m "$1" && git push
    }

    gundo() {
        git reset --soft HEAD~1
    }

    gamend() {
        git commit --amend --no-edit
    }

    # System update function
    sysupdate() {
        echo "🔄 Updating system..."
        if [[ "$IS_ROOT" == "true" ]]; then
            pacman -Syu
        else
            sudo pacman -Syu
        fi
        
        if command -v yay &> /dev/null; then
            echo "🔄 Updating AUR packages..."
            yay -Sua
        elif command -v paru &> /dev/null; then
            echo "🔄 Updating AUR packages..."
            paru -Sua
        fi
        echo "✅ System updated!"
    }

    # System cleanup
    sysclean() {
        echo "🧹 Cleaning system..."
        if [[ "$IS_ROOT" == "true" ]]; then
            pacman -Sc
        else
            sudo pacman -Sc
        fi
        sudo journalctl --vacuum-time=7d
        sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || true
        echo "✅ System cleaned!"
    }

    # Red Team functions
    redteam-info() {
        echo "🎯 Red Team Network Information"
        echo "================================"
        echo "🏠 Local IP: $(get_cached_local_ip 2>/dev/null || ip route get 8.8.8.8 2>/dev/null | awk '{print $7}' || echo 'unknown')"
        echo "🌐 Public IP: $(get_cached_public_ip 2>/dev/null || curl -s --max-time 3 ifconfig.me 2>/dev/null || echo 'unknown')"
        echo "🔗 Gateway: $(ip route | grep default | awk '{print $3}')"
        echo "📡 Interface: $(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}' || echo 'unknown')"
        echo "🖥️  Hostname: $(hostname)"
        echo "👤 User: $(whoami)"
        echo "⏰ Time: $(date)"
    }

    set-target() {
        [[ -n "$1" ]] || { echo "Usage: set-target <target_ip_or_domain>"; return 1; }
        export TARGET="$1"
        export LOCAL_IP=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $7}' || echo 'unknown')
        echo "🎯 Target set to: $TARGET"
        echo "🏠 Local IP: $LOCAL_IP"
    }

    portscan() {
        [[ -n "$1" ]] || { echo "Usage: portscan <target>"; return 1; }
        echo "🔍 Scanning ports on $1..."
        nmap -T4 -F "$1"
    }

    # Base64 encode/decode
    b64e() { echo -n "$1" | base64; }
    b64d() { echo -n "$1" | base64 -d; }

    # URL encode/decode
    urle() { python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"; }
    urld() { python3 -c "import urllib.parse; print(urllib.parse.unquote('$1'))"; }

    # Hash helpers
    md5s() { echo -n "$1" | command md5sum | cut -d' ' -f1; }
    sha1s() { echo -n "$1" | command sha1sum | cut -d' ' -f1; }
    sha256s() { echo -n "$1" | command sha256sum | cut -d' ' -f1; }

    # Cache functions for network info (performance optimization)
    get_cached_local_ip() {
        local cache_dir="${XDG_CACHE_HOME}/arch-dream"
        local cache_file="$cache_dir/local_ip"
        local cache_time=300  # 5 minutes
        
        mkdir -p "$cache_dir"
        
        if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_time ]]; then
            cat "$cache_file"
        else
            local ip=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $7}' || echo "unknown")
            echo "$ip" > "$cache_file"
            echo "$ip"
        fi
    }

    get_cached_public_ip() {
        local cache_dir="${XDG_CACHE_HOME}/arch-dream"
        local cache_file="$cache_dir/public_ip"
        local cache_time=3600  # 1 hour
        
        mkdir -p "$cache_dir"
        
        if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_time ]]; then
            cat "$cache_file"
        else
            local ip=$(curl -s --max-time 3 ifconfig.me 2>/dev/null || echo "unknown")
            echo "$ip" > "$cache_file"
            echo "$ip"
        fi
    }
}

# =====================================================
# 🌟 STARSHIP CONFIGURATION
# =====================================================

load_starship_config() {
    # Initialize Starship if available
    if command -v starship &>/dev/null; then
        if [[ "$IS_ZSH" == "true" ]]; then
            eval "$(starship init zsh)"
        elif [[ "$IS_BASH" == "true" ]]; then
            eval "$(starship init bash)"
        fi
    else
        # Fallback prompt for cases where Starship is not available
        if [[ "$IS_ROOT" == "true" ]]; then
            export PS1='\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]# '
        else
            export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        fi
    fi
}

# =====================================================
# 🔧 LAZY LOADING FUNCTIONS
# =====================================================

# Lazy load NVM
nvm() {
    if [[ "$IS_ROOT" == "true" ]]; then
        export NVM_DIR="/root/.nvm"
    else
        export NVM_DIR="$HOME/.nvm"
    fi
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
    nvm "$@"
}

# Lazy load Rust environment
load_rust() {
    if [[ "$IS_ROOT" == "true" ]]; then
        [[ -f "/root/.cargo/env" ]] && source "/root/.cargo/env"
    else
        [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
    fi
}

# Lazy load Bun
load_bun() {
    if [[ "$IS_ROOT" == "true" ]]; then
        [[ -s "/root/.bun/_bun" ]] && source "/root/.bun/_bun"
    else
        [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
    fi
}

# Environment loader aliases
alias rust='load_rust'
alias cargo='load_rust && cargo'

# =====================================================
# 🏁 INITIALIZATION MESSAGE
# =====================================================

shell_base_loaded() {
    export SHELL_BASE_LOADED=true
    # Optionally show load message in non-production environments
    [[ -n "${ARCH_DREAM_DEBUG:-}" ]] && echo "✅ Shell base configuration loaded for $CURRENT_SHELL"
}

# Mark as loaded
shell_base_loaded