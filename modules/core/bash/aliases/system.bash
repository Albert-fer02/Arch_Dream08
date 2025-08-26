#!/bin/bash
# =====================================================
# 💻 ALIASES DEL SISTEMA PARA BASH
# =====================================================

# Sistema optimizado
alias myip='curl -s --max-time 5 ipinfo.io/ip'
alias ports='ss -tulanp'
alias sysinfo='fastfetch 2>/dev/null || neofetch 2>/dev/null || uname -a'

# Arch Linux optimizado
alias pacupdate='sudo pacman -Syu'
alias pacinstall='sudo pacman -S'
alias pacsearch='pacman -Ss'
alias aurinstall='yay -S'
alias aurupdate='yay -Syu'

# Fastfetch aliases optimizados
alias ff="fastfetch"
alias ff-dream="fastfetch --config ~/.config/fastfetch/config.jsonc"
alias ff-custom="fastfetch --config ~/.config/fastfetch/config.local.jsonc"

# Nano aliases optimizados
alias nano="nano --rcfile ~/.config/nano/nanorc"
alias nano-code="nano --rcfile ~/.config/nano/code.nanorc"
alias nano-config="nano --rcfile ~/.config/nano/config.nanorc"
alias nano-log="nano --rcfile ~/.config/nano/log.nanorc"
alias nano-edit="nano --rcfile ~/.config/nano/nanorc.local"
