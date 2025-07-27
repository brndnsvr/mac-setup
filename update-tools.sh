#!/bin/bash

# Update Tools Script
# Updates all installed tools managed by mac-setup

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common functions
source "$SCRIPT_DIR/common.sh"

# Configuration
UPDATE_LOG="$HOME/.mac-setup-update.log"
FAILED_UPDATES=()
UPDATED_TOOLS=()
SKIPPED_TOOLS=()

# Options
CHECK_ONLY=false
SELECTIVE=false
SELECTED_CATEGORIES=()
FORCE_UPDATE=false
QUIET_MODE=false

# Categories
CATEGORIES=(
    "homebrew"
    "npm"
    "python"
    "rust"
    "go"
    "ruby"
    "vscode"
    "system"
)

# Show help
show_help() {
    echo "Mac Development Environment - Update Tools"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --check          Check for updates without installing"
    echo "  --category CAT   Update only specific category (can be used multiple times)"
    echo "  --force          Force update even if already up-to-date"
    echo "  --quiet          Suppress progress output"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "Categories:"
    echo "  homebrew    - Homebrew formulae and casks"
    echo "  npm         - Global npm packages"
    echo "  python      - Python packages (pipx)"
    echo "  rust        - Rust toolchain and cargo packages"
    echo "  go          - Go modules"
    echo "  ruby        - Ruby gems"
    echo "  vscode      - VS Code extensions"
    echo "  system      - macOS system updates"
    echo ""
    echo "Examples:"
    echo "  $0                              # Update everything"
    echo "  $0 --check                      # Check what needs updating"
    echo "  $0 --category homebrew npm      # Update only Homebrew and npm"
    echo ""
}

# Initialize log
init_log() {
    echo "Update started at $(date)" > "$UPDATE_LOG"
    echo "================================" >> "$UPDATE_LOG"
}

# Log update
log_update() {
    local category=$1
    local tool=$2
    local status=$3
    local message=${4:-""}
    
    echo "[$category] $tool: $status $message" >> "$UPDATE_LOG"
}

# Check for Homebrew updates
check_homebrew_updates() {
    log_info "Checking Homebrew updates..."
    
    # Update Homebrew itself
    brew update &>/dev/null || log_warning "Failed to update Homebrew"
    
    # Check outdated formulae
    local outdated_formulae=$(brew outdated --formula 2>/dev/null || echo "")
    if [ -n "$outdated_formulae" ]; then
        echo "Outdated formulae:"
        echo "$outdated_formulae" | sed 's/^/  - /'
    fi
    
    # Check outdated casks
    local outdated_casks=$(brew outdated --cask 2>/dev/null || echo "")
    if [ -n "$outdated_casks" ]; then
        echo "Outdated casks:"
        echo "$outdated_casks" | sed 's/^/  - /'
    fi
    
    if [ -z "$outdated_formulae" ] && [ -z "$outdated_casks" ]; then
        log_success "All Homebrew packages are up-to-date"
    fi
}

# Update Homebrew packages
update_homebrew() {
    log_info "Updating Homebrew packages..."
    
    # Update Homebrew itself
    if [ "$CHECK_ONLY" = false ]; then
        brew update || log_warning "Failed to update Homebrew"
    fi
    
    # Upgrade formulae
    local outdated_formulae=$(brew outdated --formula --quiet 2>/dev/null || echo "")
    if [ -n "$outdated_formulae" ]; then
        for formula in $outdated_formulae; do
            if [ "$CHECK_ONLY" = false ]; then
                log_info "Updating $formula..."
                if brew upgrade "$formula" 2>&1 | tee -a "$UPDATE_LOG"; then
                    UPDATED_TOOLS+=("homebrew:$formula")
                    log_update "homebrew" "$formula" "SUCCESS"
                else
                    FAILED_UPDATES+=("homebrew:$formula")
                    log_update "homebrew" "$formula" "FAILED"
                fi
            fi
        done
    fi
    
    # Upgrade casks
    local outdated_casks=$(brew outdated --cask --quiet 2>/dev/null || echo "")
    if [ -n "$outdated_casks" ]; then
        for cask in $outdated_casks; do
            if [ "$CHECK_ONLY" = false ]; then
                log_info "Updating $cask..."
                if brew upgrade --cask "$cask" 2>&1 | tee -a "$UPDATE_LOG"; then
                    UPDATED_TOOLS+=("homebrew-cask:$cask")
                    log_update "homebrew-cask" "$cask" "SUCCESS"
                else
                    FAILED_UPDATES+=("homebrew-cask:$cask")
                    log_update "homebrew-cask" "$cask" "FAILED"
                fi
            fi
        done
    fi
    
    # Cleanup
    if [ "$CHECK_ONLY" = false ]; then
        brew cleanup -s &>/dev/null || log_warning "Cleanup failed"
        brew autoremove &>/dev/null || log_warning "Autoremove failed"
    fi
}

# Check npm updates
check_npm_updates() {
    log_info "Checking npm package updates..."
    
    if command -v npm &>/dev/null; then
        # Check for npm itself
        local current_npm=$(npm --version)
        local latest_npm=$(npm view npm version 2>/dev/null || echo "$current_npm")
        
        if [ "$current_npm" != "$latest_npm" ]; then
            echo "npm itself can be updated: $current_npm → $latest_npm"
        fi
        
        # Check global packages
        local outdated=$(npm outdated -g --parseable 2>/dev/null || echo "")
        if [ -n "$outdated" ]; then
            echo "Outdated npm packages:"
            echo "$outdated" | while IFS=: read -r path current wanted latest; do
                local pkg=$(basename "$path")
                echo "  - $pkg: $current → $wanted"
            done
        else
            log_success "All npm packages are up-to-date"
        fi
    else
        log_warning "npm not found"
    fi
}

# Update npm packages
update_npm() {
    log_info "Updating npm packages..."
    
    if command -v npm &>/dev/null; then
        # Update npm itself
        if [ "$CHECK_ONLY" = false ]; then
            log_info "Updating npm..."
            if npm install -g npm@latest 2>&1 | tee -a "$UPDATE_LOG"; then
                UPDATED_TOOLS+=("npm:npm")
                log_update "npm" "npm" "SUCCESS"
            fi
        fi
        
        # Get list of global packages
        local packages=$(npm list -g --depth=0 --parseable 2>/dev/null | tail -n +2 | sed 's/.*node_modules\///')
        
        for pkg in $packages; do
            if [ "$CHECK_ONLY" = false ]; then
                log_info "Updating $pkg..."
                if npm update -g "$pkg" 2>&1 | tee -a "$UPDATE_LOG"; then
                    UPDATED_TOOLS+=("npm:$pkg")
                    log_update "npm" "$pkg" "SUCCESS"
                else
                    FAILED_UPDATES+=("npm:$pkg")
                    log_update "npm" "$pkg" "FAILED"
                fi
            fi
        done
    else
        log_warning "npm not found"
    fi
}

# Check Python updates
check_python_updates() {
    log_info "Checking Python package updates..."
    
    if command -v pipx &>/dev/null; then
        # List outdated pipx packages
        local outdated=$(pipx list --short 2>/dev/null | while read -r pkg; do
            pipx runpip "$pkg" list --outdated 2>/dev/null | grep -v "^Package" | grep -v "^---" | head -1
        done)
        
        if [ -n "$outdated" ]; then
            echo "Outdated Python packages:"
            echo "$outdated"
        else
            log_success "All Python packages are up-to-date"
        fi
    else
        log_warning "pipx not found"
    fi
}

# Update Python packages
update_python() {
    log_info "Updating Python packages..."
    
    if command -v pipx &>/dev/null; then
        if [ "$CHECK_ONLY" = false ]; then
            # Update all pipx packages
            log_info "Updating all pipx packages..."
            if pipx upgrade-all 2>&1 | tee -a "$UPDATE_LOG"; then
                UPDATED_TOOLS+=("python:all-pipx-packages")
                log_update "python" "all-pipx-packages" "SUCCESS"
            else
                FAILED_UPDATES+=("python:pipx-packages")
                log_update "python" "pipx-packages" "FAILED"
            fi
        fi
    fi
    
    # Update pip itself
    if command -v python3 &>/dev/null; then
        if [ "$CHECK_ONLY" = false ]; then
            log_info "Updating pip..."
            if python3 -m pip install --upgrade pip 2>&1 | tee -a "$UPDATE_LOG"; then
                UPDATED_TOOLS+=("python:pip")
                log_update "python" "pip" "SUCCESS"
            fi
        fi
    fi
}

# Update VS Code extensions
update_vscode() {
    log_info "Updating VS Code extensions..."
    
    if command -v code &>/dev/null; then
        if [ "$CHECK_ONLY" = true ]; then
            log_info "Checking for VS Code extension updates..."
            code --list-extensions --show-versions
        else
            log_info "Updating all VS Code extensions..."
            local extensions=$(code --list-extensions)
            for ext in $extensions; do
                if code --install-extension "$ext" --force 2>&1 | tee -a "$UPDATE_LOG"; then
                    UPDATED_TOOLS+=("vscode:$ext")
                    log_update "vscode" "$ext" "SUCCESS"
                fi
            done
        fi
    else
        log_warning "VS Code CLI not found"
    fi
}

# Update Rust
update_rust() {
    log_info "Updating Rust toolchain..."
    
    if command -v rustup &>/dev/null; then
        if [ "$CHECK_ONLY" = true ]; then
            rustup check
        else
            log_info "Updating rustup..."
            if rustup self update 2>&1 | tee -a "$UPDATE_LOG"; then
                UPDATED_TOOLS+=("rust:rustup")
                log_update "rust" "rustup" "SUCCESS"
            fi
            
            log_info "Updating Rust toolchain..."
            if rustup update stable 2>&1 | tee -a "$UPDATE_LOG"; then
                UPDATED_TOOLS+=("rust:toolchain")
                log_update "rust" "toolchain" "SUCCESS"
            fi
        fi
    else
        log_warning "Rust not found"
    fi
}

# Check system updates
check_system_updates() {
    log_info "Checking macOS system updates..."
    
    softwareupdate --list 2>&1 | grep -v "No new software available" || log_success "No system updates available"
}

# Update system
update_system() {
    if [ "$CHECK_ONLY" = true ]; then
        check_system_updates
    else
        log_info "Installing macOS updates..."
        log_warning "System updates require sudo and may restart your computer"
        read -p "Continue with system updates? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo softwareupdate --install --all
        fi
    fi
}

# Show summary
show_summary() {
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "Update Summary"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    if [ "$CHECK_ONLY" = true ]; then
        echo "Check-only mode completed. Run without --check to install updates."
    else
        echo "Updated: ${#UPDATED_TOOLS[@]} tools"
        if [ ${#UPDATED_TOOLS[@]} -gt 0 ]; then
            for tool in "${UPDATED_TOOLS[@]}"; do
                echo "  ✓ $tool"
            done
        fi
        
        if [ ${#FAILED_UPDATES[@]} -gt 0 ]; then
            echo ""
            echo "Failed: ${#FAILED_UPDATES[@]} tools"
            for tool in "${FAILED_UPDATES[@]}"; do
                echo "  ✗ $tool"
            done
        fi
        
        echo ""
        echo "Update log saved to: $UPDATE_LOG"
    fi
}

# Main execution
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check)
                CHECK_ONLY=true
                shift
                ;;
            --category)
                SELECTIVE=true
                SELECTED_CATEGORIES+=("$2")
                shift 2
                ;;
            --force)
                FORCE_UPDATE=true
                shift
                ;;
            --quiet)
                QUIET_MODE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Initialize
    init_log
    
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              Mac Development Environment Updater               ║"
    echo "╔════════════════════════════════════════════════════════════════╝"
    echo ""
    
    if [ "$CHECK_ONLY" = true ]; then
        echo "Running in check-only mode..."
    fi
    
    # Determine which categories to update
    local categories_to_update=()
    if [ "$SELECTIVE" = true ]; then
        categories_to_update=("${SELECTED_CATEGORIES[@]}")
    else
        categories_to_update=("${CATEGORIES[@]}")
    fi
    
    # Run updates
    for category in "${categories_to_update[@]}"; do
        case $category in
            homebrew)
                if [ "$CHECK_ONLY" = true ]; then
                    check_homebrew_updates
                else
                    update_homebrew
                fi
                ;;
            npm)
                if [ "$CHECK_ONLY" = true ]; then
                    check_npm_updates
                else
                    update_npm
                fi
                ;;
            python)
                if [ "$CHECK_ONLY" = true ]; then
                    check_python_updates
                else
                    update_python
                fi
                ;;
            rust)
                update_rust
                ;;
            vscode)
                update_vscode
                ;;
            system)
                update_system
                ;;
            *)
                log_warning "Unknown category: $category"
                ;;
        esac
        echo ""
    done
    
    # Show summary
    show_summary
}

# Run main function
main "$@"