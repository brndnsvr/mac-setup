#!/bin/bash

# Mac Development Environment Setup - Role-Based Edition
# This script sets up a development environment based on selected roles

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common functions
source "$SCRIPT_DIR/common.sh"

# Configuration
ROLES_DIR="$SCRIPT_DIR/roles"
SELECTED_ROLES=()
SELECTED_TOOLS=()
SKIP_OPTIONAL=false
AUTO_MODE=false

# Display welcome message
show_welcome() {
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          Mac Development Environment Setup - v2.0              ║"
    echo "║                    Role-Based Installation                     ║"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo ""
    echo "This script will set up your Mac for development based on your role(s)."
    echo "You can select multiple roles, and common tools will only be installed once."
    echo ""
}

# Display available roles
show_roles() {
    echo "Available roles:"
    echo ""
    echo "  1) DevOps Engineer        - Infrastructure, containers, cloud"
    echo "  2) Full-Stack Developer   - Frontend + backend + databases"
    echo "  3) Backend Developer      - APIs, servers, databases"
    echo "  4) Frontend Developer     - Web UIs, JavaScript, CSS"
    echo "  5) Network/Sysadmin      - Network tools, system administration"
    echo "  6) AI/ML Engineer        - Machine learning, LLMs, data science"
    echo "  7) Data Engineer         - ETL, data pipelines, analytics"
    echo "  8) Security Engineer     - Security testing, vulnerability assessment"
    echo "  9) Mobile Developer      - iOS, Android, cross-platform"
    echo ""
}

# Role selection
select_roles() {
    local roles_map=(
        "devops"
        "fullstack"
        "backend"
        "frontend"
        "network-sysadmin"
        "ai-ml-engineer"
        "data-engineer"
        "security-engineer"
        "mobile-developer"
    )
    
    echo "Select your role(s) - you can choose multiple:"
    echo "Enter numbers separated by spaces (e.g., '1 3 6'), or 'all' for all roles:"
    read -r selection
    
    if [[ "$selection" == "all" ]]; then
        SELECTED_ROLES=("${roles_map[@]}")
    else
        for num in $selection; do
            if [[ "$num" =~ ^[1-9]$ ]] && [ "$num" -le "${#roles_map[@]}" ]; then
                SELECTED_ROLES+=("${roles_map[$((num-1))]}")
            else
                log_warning "Invalid selection: $num"
            fi
        done
    fi
    
    if [ ${#SELECTED_ROLES[@]} -eq 0 ]; then
        log_error "No roles selected. Exiting."
        exit 1
    fi
    
    echo ""
    log_info "Selected roles:"
    for role in "${SELECTED_ROLES[@]}"; do
        echo "  - $role"
    done
    echo ""
}

# Parse YAML-like format (simple parser)
parse_yaml_array() {
    local file=$1
    local section=$2
    local in_section=false
    local indent_level=0
    
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # Check section start
        if [[ "$line" =~ ^${section}: ]]; then
            in_section=true
            continue
        fi
        
        # Check if we've moved to a new top-level section
        if [[ "$line" =~ ^[^[:space:]] ]] && [ "$in_section" = true ]; then
            break
        fi
        
        # Extract items if in section
        if [ "$in_section" = true ]; then
            if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*name:[[:space:]]*(.+) ]]; then
                echo "${BASH_REMATCH[1]}"
            fi
        fi
    done < "$file"
}

# Install tool with preference handling
install_with_preference() {
    local tool=$1
    local alternatives=$2
    local description=$3
    
    if [ -n "$alternatives" ]; then
        echo ""
        log_info "Multiple options available for: $description"
        echo "  1) $tool (recommended)"
        
        local alt_array=($alternatives)
        local i=2
        for alt in "${alt_array[@]}"; do
            echo "  $i) $alt"
            ((i++))
        done
        echo "  s) Skip this category"
        
        read -p "Select option (default: 1): " choice
        
        case "$choice" in
            s|S)
                log_info "Skipping $description"
                return
                ;;
            [2-9])
                local idx=$((choice-2))
                if [ $idx -lt ${#alt_array[@]} ]; then
                    tool="${alt_array[$idx]}"
                fi
                ;;
        esac
    fi
    
    SELECTED_TOOLS+=("$tool")
}

# Process role configurations
process_roles() {
    # First, always install core tools
    log_info "Processing core tools..."
    local core_file="$ROLES_DIR/core.yaml"
    
    if [ -f "$core_file" ]; then
        # Extract tools from core.yaml
        local core_formulae=($(parse_yaml_array "$core_file" "brew_formulae"))
        local core_casks=($(parse_yaml_array "$core_file" "brew_casks"))
        
        SELECTED_TOOLS+=("${core_formulae[@]}")
        
        # Handle casks with alternatives
        for cask in "${core_casks[@]}"; do
            # For now, just add them - in full implementation, handle alternatives
            SELECTED_TOOLS+=("cask:$cask")
        done
    fi
    
    # Process selected roles
    for role in "${SELECTED_ROLES[@]}"; do
        local role_file="$ROLES_DIR/${role}.yaml"
        
        if [ -f "$role_file" ]; then
            log_info "Processing role: $role"
            
            # Extract tools from role file
            local formulae=($(parse_yaml_array "$role_file" "brew_formulae"))
            local casks=($(parse_yaml_array "$role_file" "brew_casks"))
            
            SELECTED_TOOLS+=("${formulae[@]}")
            for cask in "${casks[@]}"; do
                SELECTED_TOOLS+=("cask:$cask")
            done
        else
            log_warning "Role file not found: $role_file"
        fi
    done
    
    # Remove duplicates
    SELECTED_TOOLS=($(echo "${SELECTED_TOOLS[@]}" | tr ' ' '\n' | sort -u))
}

# Installation summary
show_summary() {
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "Installation Summary"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    echo "Roles selected: ${#SELECTED_ROLES[@]}"
    for role in "${SELECTED_ROLES[@]}"; do
        echo "  - $role"
    done
    echo ""
    echo "Tools to install: ${#SELECTED_TOOLS[@]}"
    echo ""
    read -p "Proceed with installation? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled."
        exit 0
    fi
}

# Main installation
perform_installation() {
    log_info "Starting installation..."
    
    # Install Homebrew if needed
    if ! command -v brew &> /dev/null; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Update Homebrew
    log_info "Updating Homebrew..."
    brew update
    
    # Install tools
    local formulae=()
    local casks=()
    
    for tool in "${SELECTED_TOOLS[@]}"; do
        if [[ "$tool" == cask:* ]]; then
            casks+=("${tool#cask:}")
        else
            formulae+=("$tool")
        fi
    done
    
    # Install formulae
    if [ ${#formulae[@]} -gt 0 ]; then
        log_info "Installing Homebrew formulae..."
        for formula in "${formulae[@]}"; do
            if brew list "$formula" &> /dev/null 2>&1; then
                log_success "$formula already installed"
            else
                log_info "Installing $formula..."
                brew install "$formula" || log_warning "Failed to install $formula"
            fi
        done
    fi
    
    # Install casks
    if [ ${#casks[@]} -gt 0 ]; then
        log_info "Installing Homebrew casks..."
        for cask in "${casks[@]}"; do
            if brew list --cask "$cask" &> /dev/null 2>&1; then
                log_success "$cask already installed"
            else
                log_info "Installing $cask..."
                brew install --cask "$cask" || log_warning "Failed to install $cask"
            fi
        done
    fi
}

# Post-installation setup
post_installation() {
    log_info "Running post-installation setup..."
    
    # Run shell configuration
    if [ -f "$SCRIPT_DIR/shell-config.sh" ]; then
        log_info "Configuring shell..."
        bash "$SCRIPT_DIR/shell-config.sh"
    fi
    
    # Role-specific setup
    for role in "${SELECTED_ROLES[@]}"; do
        case "$role" in
            "ai-ml-engineer")
                if command -v ollama &> /dev/null; then
                    log_info "Run 'ollama-setup' to download AI models"
                fi
                ;;
            "devops")
                log_info "Remember to authenticate cloud CLIs:"
                echo "  - AWS: aws configure"
                echo "  - GCP: gcloud auth login"
                echo "  - Azure: az login"
                ;;
            "mobile-developer")
                log_info "Remember to:"
                echo "  - Install Xcode from Mac App Store"
                echo "  - Run: sudo xcode-select --switch /Applications/Xcode.app"
                echo "  - Accept Xcode license: sudo xcodebuild -license accept"
                ;;
        esac
    done
}

# Main execution
main() {
    show_welcome
    
    # Check for command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --roles)
                IFS=',' read -ra SELECTED_ROLES <<< "$2"
                AUTO_MODE=true
                shift 2
                ;;
            --skip-optional)
                SKIP_OPTIONAL=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Interactive role selection if not provided
    if [ "$AUTO_MODE" = false ]; then
        show_roles
        select_roles
    fi
    
    # Process selected roles
    process_roles
    
    # Show summary and confirm
    show_summary
    
    # Perform installation
    perform_installation
    
    # Post-installation setup
    post_installation
    
    log_success "Installation complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Run role-specific setup commands shown above"
    echo "  3. Configure your preferred tools and editors"
    echo ""
    echo "For help and commands, run: dev-help"
}

# Run main function
main "$@"