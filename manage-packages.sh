#!/bin/bash

# Package Management Script for Mac Setup
# Lists and manages packages installed by this tool

set -euo pipefail

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common functions
source "${SCRIPT_DIR}/common.sh"

# Function to display usage
usage() {
    cat << EOF
Mac Setup Package Manager

Usage: $(basename "$0") [command] [options]

Commands:
    list            List all packages installed by mac-setup
    list-brew       List Homebrew packages
    list-cask       List Homebrew cask applications
    list-npm        List global npm packages
    list-pip        List pipx packages
    list-go         List Go tools
    list-role       List packages for a specific role
    remove          Interactive removal of packages
    remove-brew     Remove a Homebrew package
    remove-cask     Remove a Homebrew cask application
    remove-npm      Remove a global npm package
    remove-pip      Remove a pipx package
    remove-role     Remove all packages for a specific role
    export          Export all installed packages to a file
    export-role     Export packages for a specific role
    help            Show this help message

Examples:
    $(basename "$0") list
    $(basename "$0") remove-cask zoom
    $(basename "$0") export > my-packages.txt

EOF
}

# Function to list all Homebrew packages that match our installation list
list_brew_packages() {
    log_info "Homebrew Packages:"
    echo ""
    
    # Get list of all packages from our installation files
    local packages=()
    
    # From brew-packages.txt
    if [[ -f "${SCRIPT_DIR}/brew-packages.txt" ]]; then
        while IFS= read -r line; do
            # Skip comments and empty lines
            [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
            packages+=("$line")
        done < "${SCRIPT_DIR}/brew-packages.txt"
    fi
    
    # Check which are actually installed
    for pkg in "${packages[@]}"; do
        if brew_installed "$pkg"; then
            version=$(brew list --versions "$pkg" | awk '{print $2}')
            echo "  ✓ $pkg ($version)"
        fi
    done
}

# Function to list all Homebrew casks
list_cask_packages() {
    log_info "Homebrew Cask Applications:"
    echo ""
    
    # Get installed casks and match against our lists
    while IFS= read -r cask; do
        echo "  ✓ $cask"
    done < <(brew list --cask)
}

# Function to list global npm packages
list_npm_packages() {
    log_info "Global NPM Packages:"
    echo ""
    
    if command -v npm &> /dev/null; then
        npm list -g --depth=0 2>/dev/null | grep -E "├── |└── " | sed 's/[├└]── /  ✓ /'
    else
        log_warning "npm not found"
    fi
}

# Function to list pipx packages
list_pipx_packages() {
    log_info "Pipx Packages:"
    echo ""
    
    if command -v pipx &> /dev/null; then
        pipx list | grep "package" | awk '{print "  ✓", $2}' | sed 's/,$//'
    else
        log_warning "pipx not found"
    fi
}

# Function to list Go tools
list_go_tools() {
    log_info "Go Tools:"
    echo ""
    
    if [[ -d "$HOME/go/bin" ]]; then
        for tool in "$HOME/go/bin"/*; do
            if [[ -f "$tool" ]]; then
                echo "  ✓ $(basename "$tool")"
            fi
        done
    else
        log_warning "Go bin directory not found"
    fi
}

# Function to remove a Homebrew package
remove_brew_package() {
    local package=$1
    
    if brew_installed "$package"; then
        log_info "Removing Homebrew package: $package"
        if brew uninstall "$package"; then
            log_success "Successfully removed $package"
        else
            log_error "Failed to remove $package"
        fi
    else
        log_warning "$package is not installed"
    fi
}

# Function to remove a Homebrew cask
remove_cask_package() {
    local cask=$1
    
    if cask_installed "$cask"; then
        log_info "Removing Homebrew cask: $cask"
        if brew uninstall --cask "$cask"; then
            log_success "Successfully removed $cask"
        else
            log_error "Failed to remove $cask"
        fi
    else
        log_warning "$cask is not installed"
    fi
}

# Function to remove a global npm package
remove_npm_package() {
    local package=$1
    
    if command -v npm &> /dev/null; then
        log_info "Removing global npm package: $package"
        if npm uninstall -g "$package"; then
            log_success "Successfully removed $package"
        else
            log_error "Failed to remove $package"
        fi
    else
        log_error "npm not found"
    fi
}

# Function to remove a pipx package
remove_pipx_package() {
    local package=$1
    
    if command -v pipx &> /dev/null; then
        log_info "Removing pipx package: $package"
        if pipx uninstall "$package"; then
            log_success "Successfully removed $package"
        else
            log_error "Failed to remove $package"
        fi
    else
        log_error "pipx not found"
    fi
}

# Interactive removal function
interactive_remove() {
    echo ""
    log_info "Interactive Package Removal"
    echo ""
    echo "Select package type to remove:"
    echo "1) Homebrew packages"
    echo "2) Homebrew cask applications"
    echo "3) Global npm packages"
    echo "4) Pipx packages"
    echo "5) Cancel"
    echo ""
    
    read -p "Choice (1-5): " -n 1 -r
    echo ""
    
    case $REPLY in
        1)
            echo ""
            list_brew_packages
            echo ""
            read -p "Enter package name to remove: " package
            [[ -n "$package" ]] && remove_brew_package "$package"
            ;;
        2)
            echo ""
            list_cask_packages
            echo ""
            read -p "Enter cask name to remove: " cask
            [[ -n "$cask" ]] && remove_cask_package "$cask"
            ;;
        3)
            echo ""
            list_npm_packages
            echo ""
            read -p "Enter npm package name to remove: " package
            [[ -n "$package" ]] && remove_npm_package "$package"
            ;;
        4)
            echo ""
            list_pipx_packages
            echo ""
            read -p "Enter pipx package name to remove: " package
            [[ -n "$package" ]] && remove_pipx_package "$package"
            ;;
        5)
            log_info "Cancelled"
            ;;
        *)
            log_error "Invalid choice"
            ;;
    esac
}

# Export all packages
export_packages() {
    echo "# Mac Setup Installed Packages"
    echo "# Generated on $(date)"
    echo ""
    
    echo "## Homebrew Packages"
    brew list --formula
    echo ""
    
    echo "## Homebrew Cask Applications"
    brew list --cask
    echo ""
    
    if command -v npm &> /dev/null; then
        echo "## Global NPM Packages"
        npm list -g --depth=0 2>/dev/null | grep -E "├── |└── " | sed 's/[├└]── //'
        echo ""
    fi
    
    if command -v pipx &> /dev/null; then
        echo "## Pipx Packages"
        pipx list | grep "package" | awk '{print $2}' | sed 's/,$//'
        echo ""
    fi
    
    if [[ -d "$HOME/go/bin" ]]; then
        echo "## Go Tools"
        ls -1 "$HOME/go/bin"
        echo ""
    fi
}

# Role configuration
ROLES_DIR="$SCRIPT_DIR/roles"

# Parse YAML array (simple version)
parse_yaml_array() {
    local file=$1
    local section=$2
    local in_section=false
    
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        if [[ "$line" =~ ^${section}: ]]; then
            in_section=true
            continue
        fi
        
        if [[ "$line" =~ ^[^[:space:]] ]] && [ "$in_section" = true ]; then
            break
        fi
        
        if [ "$in_section" = true ]; then
            if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*name:[[:space:]]*(.+) ]]; then
                echo "${BASH_REMATCH[1]}"
            fi
        fi
    done < "$file"
}

# List packages for a role
list_role_packages() {
    local role="${1:-}"
    
    if [[ -z "$role" ]]; then
        log_error "Role name required"
        echo "Available roles:"
        ls -1 "$ROLES_DIR"/*.yaml 2>/dev/null | xargs -n1 basename | sed 's/.yaml//' | sed 's/^/  - /'
        return 1
    fi
    
    local role_file="$ROLES_DIR/${role}.yaml"
    
    if [[ ! -f "$role_file" ]]; then
        log_error "Role not found: $role"
        return 1
    fi
    
    log_info "Packages for role: $role"
    echo ""
    
    # Get formulae
    local formulae=($(parse_yaml_array "$role_file" "brew_formulae"))
    if [[ ${#formulae[@]} -gt 0 ]]; then
        echo "Homebrew Formulae:"
        for formula in "${formulae[@]}"; do
            echo "  - $formula"
        done
        echo ""
    fi
    
    # Get casks
    local casks=($(parse_yaml_array "$role_file" "brew_casks"))
    if [[ ${#casks[@]} -gt 0 ]]; then
        echo "Homebrew Casks:"
        for cask in "${casks[@]}"; do
            echo "  - $cask"
        done
        echo ""
    fi
    
    # Get npm packages
    local npm_packages=($(parse_yaml_array "$role_file" "npm_packages"))
    if [[ ${#npm_packages[@]} -gt 0 ]]; then
        echo "NPM Packages:"
        for pkg in "${npm_packages[@]}"; do
            echo "  - $pkg"
        done
        echo ""
    fi
    
    # Get Python packages
    local python_packages=($(parse_yaml_array "$role_file" "python_packages"))
    if [[ ${#python_packages[@]} -gt 0 ]]; then
        echo "Python Packages:"
        for pkg in "${python_packages[@]}"; do
            echo "  - $pkg"
        done
    fi
}

# Export packages for a role
export_role_packages() {
    local role="${1:-}"
    
    if [[ -z "$role" ]]; then
        log_error "Role name required"
        return 1
    fi
    
    local role_file="$ROLES_DIR/${role}.yaml"
    
    if [[ ! -f "$role_file" ]]; then
        log_error "Role not found: $role"
        return 1
    fi
    
    echo "# Packages for role: $role"
    echo "# Generated on $(date)"
    echo ""
    
    cat "$role_file"
}

# Remove all packages for a role
remove_role_packages() {
    local role="${1:-}"
    
    if [[ -z "$role" ]]; then
        log_error "Role name required"
        echo "Available roles:"
        ls -1 "$ROLES_DIR"/*.yaml 2>/dev/null | xargs -n1 basename | sed 's/.yaml//' | sed 's/^/  - /'
        return 1
    fi
    
    local role_file="$ROLES_DIR/${role}.yaml"
    
    if [[ ! -f "$role_file" ]]; then
        log_error "Role not found: $role"
        return 1
    fi
    
    log_warning "This will remove all packages associated with the '$role' role."
    echo "Packages to be removed:"
    echo ""
    list_role_packages "$role"
    echo ""
    
    read -p "Are you sure you want to remove all these packages? (y/N) " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Cancelled"
        return 0
    fi
    
    # Remove formulae
    local formulae=($(parse_yaml_array "$role_file" "brew_formulae"))
    for formula in "${formulae[@]}"; do
        if brew list "$formula" &> /dev/null; then
            log_info "Removing $formula..."
            brew uninstall "$formula" || log_warning "Failed to remove $formula"
        fi
    done
    
    # Remove casks
    local casks=($(parse_yaml_array "$role_file" "brew_casks"))
    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &> /dev/null; then
            log_info "Removing $cask..."
            brew uninstall --cask "$cask" || log_warning "Failed to remove $cask"
        fi
    done
    
    # Remove npm packages
    local npm_packages=($(parse_yaml_array "$role_file" "npm_packages"))
    for pkg in "${npm_packages[@]}"; do
        if npm list -g "$pkg" &> /dev/null; then
            log_info "Removing npm package $pkg..."
            npm uninstall -g "$pkg" || log_warning "Failed to remove $pkg"
        fi
    done
    
    # Remove Python packages
    local python_packages=($(parse_yaml_array "$role_file" "python_packages"))
    for pkg in "${python_packages[@]}"; do
        if pipx list | grep -q "$pkg"; then
            log_info "Removing Python package $pkg..."
            pipx uninstall "$pkg" || log_warning "Failed to remove $pkg"
        fi
    done
    
    log_success "Role packages removed successfully"
}

# Main logic
case "${1:-help}" in
    list)
        list_brew_packages
        echo ""
        list_cask_packages
        echo ""
        list_npm_packages
        echo ""
        list_pipx_packages
        echo ""
        list_go_tools
        ;;
    list-brew)
        list_brew_packages
        ;;
    list-cask)
        list_cask_packages
        ;;
    list-npm)
        list_npm_packages
        ;;
    list-pip)
        list_pipx_packages
        ;;
    list-go)
        list_go_tools
        ;;
    remove)
        interactive_remove
        ;;
    remove-brew)
        [[ -z "${2:-}" ]] && { log_error "Package name required"; exit 1; }
        remove_brew_package "$2"
        ;;
    remove-cask)
        [[ -z "${2:-}" ]] && { log_error "Cask name required"; exit 1; }
        remove_cask_package "$2"
        ;;
    remove-npm)
        [[ -z "${2:-}" ]] && { log_error "Package name required"; exit 1; }
        remove_npm_package "$2"
        ;;
    remove-pip)
        [[ -z "${2:-}" ]] && { log_error "Package name required"; exit 1; }
        remove_pipx_package "$2"
        ;;
    list-role)
        list_role_packages "${2:-}"
        ;;
    remove-role)
        remove_role_packages "${2:-}"
        ;;
    export)
        export_packages
        ;;
    export-role)
        export_role_packages "${2:-}"
        ;;
    help|*)
        usage
        ;;
esac