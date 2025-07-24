#!/bin/bash
# Pre-flight check before running setup

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

ERRORS=0
WARNINGS=0

log_info "Running pre-flight checks..."
echo

# Check macOS version
log_info "Checking macOS version..."
OS_VERSION=$(sw_vers -productVersion)
OS_MAJOR=$(echo "$OS_VERSION" | cut -d. -f1)
OS_MINOR=$(echo "$OS_VERSION" | cut -d. -f2)

if [[ $OS_MAJOR -lt 12 ]] || ([[ $OS_MAJOR -eq 12 ]] && [[ $OS_MINOR -lt 0 ]]); then
    log_error "macOS 12.0 (Monterey) or later is required. You have $OS_VERSION"
    ERRORS=$((ERRORS + 1))
else
    log_success "macOS version $OS_VERSION is supported"
fi

# Check available disk space
log_info "Checking disk space..."
AVAILABLE_SPACE=$(df -g / | awk 'NR==2 {print $4}')
if [[ $AVAILABLE_SPACE -lt 20 ]]; then
    log_error "At least 20GB of free disk space is recommended. You have ${AVAILABLE_SPACE}GB"
    ERRORS=$((ERRORS + 1))
else
    log_success "${AVAILABLE_SPACE}GB of free disk space available"
fi

# Check internet connectivity
log_info "Checking internet connectivity..."
if ping -c 1 -t 5 github.com &> /dev/null; then
    log_success "Internet connection is working"
else
    log_error "No internet connection detected. Setup requires internet access."
    ERRORS=$((ERRORS + 1))
fi

# Check if running as root
log_info "Checking user permissions..."
if [[ $EUID -eq 0 ]]; then
    log_error "This script should not be run as root!"
    ERRORS=$((ERRORS + 1))
else
    log_success "Running as regular user"
fi

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
    log_error "sudo is required but not found"
    ERRORS=$((ERRORS + 1))
else
    log_success "sudo is available"
fi

# Check if user can sudo
log_info "Checking sudo access..."
if sudo -n true 2>/dev/null; then
    log_success "User has passwordless sudo access"
elif sudo -v 2>/dev/null; then
    log_success "User has sudo access (password required)"
else
    log_error "User does not have sudo access"
    ERRORS=$((ERRORS + 1))
fi

# Check for existing installations that might conflict
log_info "Checking for existing installations..."

# Check for MacPorts (conflicts with Homebrew)
if [[ -d "/opt/local" ]] && command -v port &> /dev/null; then
    log_warning "MacPorts detected. This may conflict with Homebrew."
    WARNINGS=$((WARNINGS + 1))
fi

# Check for existing Homebrew
if command -v brew &> /dev/null; then
    BREW_VERSION=$(brew --version | head -1)
    log_info "Existing Homebrew installation found: $BREW_VERSION"
    log_info "Setup will use existing Homebrew installation"
else
    log_info "Homebrew not found. Will install during setup."
fi

# Check Xcode Command Line Tools
log_info "Checking Xcode Command Line Tools..."
if xcode-select -p &> /dev/null; then
    log_success "Xcode Command Line Tools are installed"
else
    log_warning "Xcode Command Line Tools not found. Will install during setup."
    WARNINGS=$((WARNINGS + 1))
fi

# Check for Rosetta 2 on Apple Silicon
if [[ $(uname -m) == "arm64" ]]; then
    log_info "Checking Rosetta 2 on Apple Silicon..."
    if /usr/bin/pgrep oahd >/dev/null 2>&1; then
        log_success "Rosetta 2 is installed"
    else
        log_warning "Rosetta 2 not found. Some Intel-only apps may not work."
        log_info "To install Rosetta 2, run: softwareupdate --install-rosetta"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# Check file permissions
log_info "Checking file permissions..."
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
if [[ -w "$SCRIPT_DIR" ]]; then
    log_success "Script directory is writable"
else
    log_error "Script directory is not writable"
    ERRORS=$((ERRORS + 1))
fi

# Summary
echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Pre-flight Check Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"

if [[ $ERRORS -gt 0 ]]; then
    echo
    log_error "Pre-flight check failed! Please fix the errors above before running setup."
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo
    log_warning "Pre-flight check passed with warnings. Setup can continue but some issues may occur."
    if [[ "${NON_INTERACTIVE:-false}" != "true" ]]; then
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    echo
    log_success "All pre-flight checks passed! Ready to run setup."
fi