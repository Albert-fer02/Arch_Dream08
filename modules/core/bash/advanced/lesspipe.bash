#!/bin/bash
# =====================================================
# 📖 LESSPIPE CONFIGURATION PARA BASH
# =====================================================

# Make less more friendly for non-text input files
if [[ -x /usr/bin/lesspipe ]]; then
    eval "$(SHELL=/bin/sh lesspipe)" 2>/dev/null || true
fi
