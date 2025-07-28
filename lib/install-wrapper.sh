#!/bin/bash

# Installation Wrapper Functions
# Provides configuration-aware installation functions

# Source install config if available
if [[ -f "${BASH_SOURCE[0]%/*}/install-config.sh" ]]; then
    source "${BASH_SOURCE[0]%/*}/install-config.sh"
fi

# Check if we're in configuration mode
is_config_mode() {
    [[ -f "$HOME/.mac-setup-install-config" ]] || [[ -f "$HOME/.mac-setup-install-config.tmp" ]]
}

# Wrapper for brew install
brew_install() {
    local package="$1"
    shift
    local args=("$@")
    
    if is_config_mode && ! should_install "brew" "$package"; then
        log_info "Skipping $package (not selected in configuration)"
        return 0
    fi
    
    if brew list "$package" &>/dev/null; then
        log_info "$package is already installed"
        return 0
    fi
    
    log_info "Installing $package..."
    brew install "$package" "${args[@]}"
}

# Wrapper for brew cask install
brew_cask_install() {
    local app="$1"
    shift
    local args=("$@")
    
    if is_config_mode && ! should_install "cask" "$app"; then
        log_info "Skipping $app (not selected in configuration)"
        return 0
    fi
    
    if brew list --cask "$app" &>/dev/null; then
        log_info "$app is already installed"
        return 0
    fi
    
    log_info "Installing $app..."
    brew install --cask "$app" "${args[@]}"
}

# Wrapper for npm install
npm_install_global() {
    local package="$1"
    
    if is_config_mode && ! should_install "npm" "$package"; then
        log_info "Skipping $package (not selected in configuration)"
        return 0
    fi
    
    if npm list -g "$package" &>/dev/null; then
        log_info "$package is already installed"
        return 0
    fi
    
    log_info "Installing $package..."
    npm install -g "$package"
}

# Wrapper for pip install
pip_install() {
    local package="$1"
    
    if is_config_mode && ! should_install "pip" "$package"; then
        log_info "Skipping $package (not selected in configuration)"
        return 0
    fi
    
    if pip3 show "$package" &>/dev/null; then
        log_info "$package is already installed"
        return 0
    fi
    
    log_info "Installing $package..."
    pip3 install "$package"
}

# Wrapper for pipx install
pipx_install() {
    local package="$1"
    
    if is_config_mode && ! should_install "pipx" "$package"; then
        log_info "Skipping $package (not selected in configuration)"
        return 0
    fi
    
    if pipx list | grep -q "$package"; then
        log_info "$package is already installed"
        return 0
    fi
    
    log_info "Installing $package..."
    pipx install "$package"
}

# Wrapper for go install
go_install() {
    local package="$1"
    
    if is_config_mode && ! should_install "go" "$package"; then
        log_info "Skipping $package (not selected in configuration)"
        return 0
    fi
    
    log_info "Installing $package..."
    go install "$package"
}

# Wrapper for cargo install
cargo_install() {
    local package="$1"
    
    if is_config_mode && ! should_install "cargo" "$package"; then
        log_info "Skipping $package (not selected in configuration)"
        return 0
    fi
    
    if cargo install --list | grep -q "^$package "; then
        log_info "$package is already installed"
        return 0
    fi
    
    log_info "Installing $package..."
    cargo install "$package"
}

# Batch install function
install_batch() {
    local installer="$1"
    shift
    local packages=("$@")
    
    case "$installer" in
        brew)
            for pkg in "${packages[@]}"; do
                brew_install "$pkg"
            done
            ;;
        cask)
            for pkg in "${packages[@]}"; do
                brew_cask_install "$pkg"
            done
            ;;
        npm)
            for pkg in "${packages[@]}"; do
                npm_install_global "$pkg"
            done
            ;;
        pip)
            for pkg in "${packages[@]}"; do
                pip_install "$pkg"
            done
            ;;
        pipx)
            for pkg in "${packages[@]}"; do
                pipx_install "$pkg"
            done
            ;;
        go)
            for pkg in "${packages[@]}"; do
                go_install "$pkg"
            done
            ;;
        cargo)
            for pkg in "${packages[@]}"; do
                cargo_install "$pkg"
            done
            ;;
    esac
}

# Export all functions
export -f is_config_mode
export -f brew_install
export -f brew_cask_install
export -f npm_install_global
export -f pip_install
export -f pipx_install
export -f go_install
export -f cargo_install
export -f install_batch