#!/bin/bash
# Silent bash wrapper that replaces exec bash

# Force clean environment
unset LANG LC_ALL LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION 2>/dev/null

# Set clean locale
export LANG=C.utf8
export LC_ALL=C.utf8

# Execute bash silently
exec bash "$@" 2>/dev/null
