#!/bin/bash
# Common functions and variables for all setup scripts

# Color codes
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Architecture detection
detect_arch() {
    ARCH=$(uname -m)
    if [[ "$ARCH" == "arm64" ]]; then
        export HOMEBREW_PREFIX="/opt/homebrew"
        export ARCH_NAME="Apple Silicon"
    else
        export HOMEBREW_PREFIX="/usr/local"
        export ARCH_NAME="Intel"
    fi
    log_info "Detected $ARCH_NAME Mac"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if package is installed via Homebrew
brew_installed() {
    brew list "$1" &> /dev/null 2>&1
}

# Check if cask is installed
cask_installed() {
    brew list --cask "$1" &> /dev/null 2>&1
}

# Safe brew install with error handling
safe_brew_install() {
    local package=$1
    if brew_installed "$package"; then
        log_success "$package already installed"
    else
        log_info "Installing $package..."
        # Ensure correct HOMEBREW_NO_AUTO_UPDATE value
        if HOMEBREW_NO_AUTO_UPDATE= brew install "$package"; then
            log_success "$package installed successfully"
        else
            log_error "Failed to install $package"
            return 1
        fi
    fi
}

# Safe cask install
safe_cask_install() {
    local app=$1
    if cask_installed "$app"; then
        log_success "$app already installed"
    else
        log_info "Installing $app..."
        # Ensure correct HOMEBREW_NO_AUTO_UPDATE value
        if HOMEBREW_NO_AUTO_UPDATE= brew install --cask "$app"; then
            log_success "$app installed successfully"
        else
            log_error "Failed to install $app"
            return 1
        fi
    fi
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir=$1
    if [[ ! -d "$dir" ]]; then
        log_info "Creating directory: $dir"
        mkdir -p "$dir"
    fi
}

# Add to PATH if not already present
add_to_path() {
    local new_path=$1
    if [[ ":$PATH:" != *":$new_path:"* ]]; then
        export PATH="$new_path:$PATH"
    fi
}