#!/bin/bash
# Simple Cache System

CACHE_DIR="$HOME/.cache/arch-dream"

cache_get() {
    local key="$1"
    local file="$CACHE_DIR/$key"
    [[ -f "$file" && $(stat -c %Y "$file") -gt $(($(date +%s) - 3600)) ]] && cat "$file"
}

cache_set() {
    local key="$1"
    local value="$2"
    mkdir -p "$CACHE_DIR"
    echo "$value" > "$CACHE_DIR/$key"
}

cache_clear() {
    rm -rf "$CACHE_DIR"/*
}