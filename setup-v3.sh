#!/bin/bash

# Mac Development Environment Setup - Configuration-First Edition
# This script builds a configuration of tools to install based on user selections

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required files
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/state.sh"
source "$SCRIPT_DIR/lib/install-config.sh"
source "$SCRIPT_DIR/lib/role-parser.sh"

# Initialize error handling
trap 'error_handler $? $LINENO' ERR

# Global variables
SELECTED_ROLES=()
INSTALL_MODE="interactive" # interactive, all, minimal, preset
PRESET_NAME=""

# Show main menu
show_main_menu() {
    clear
    echo
    log_section "Mac Development Environment Setup"
    echo
    echo "This tool will help you configure your development environment."
    echo "First, we'll build a configuration of what to install, then perform"
    echo "the installation based on your selections."
    echo
    echo "Installation modes:"
    echo
    echo "  1) Interactive   - Choose each tool individually (recommended)"
    echo "  2) Role-based    - Select developer roles for curated tool sets"
    echo "  3) Preset        - Use predefined configurations"
    echo "  4) Install All   - Install everything (not recommended)"
    echo "  5) Minimal       - Core tools only"
    echo
    echo "  q) Quit"
    echo
    read -p "Select installation mode [1-5, q]: " mode_selection
    
    case "$mode_selection" in
        1) INSTALL_MODE="interactive" ;;
        2) INSTALL_MODE="role-based" ;;
        3) INSTALL_MODE="preset" ;;
        4) INSTALL_MODE="all" ;;
        5) INSTALL_MODE="minimal" ;;
        q|Q) exit 0 ;;
        *) 
            log_error "Invalid selection"
            sleep 2
            show_main_menu
            ;;
    esac
}

# Configure tools based on selected mode
configure_installation() {
    init_install_config
    
    case "$INSTALL_MODE" in
        "interactive")
            configure_interactive
            ;;
        "role-based")
            configure_role_based
            ;;
        "preset")
            configure_preset
            ;;
        "all")
            configure_all
            ;;
        "minimal")
            configure_minimal
            ;;
    esac
}

# Interactive configuration
configure_interactive() {
    log_section "Interactive Tool Selection"
    echo
    echo "We'll go through each category of tools."
    echo "You can select which tools to install in each category."
    echo
    read -p "Press ENTER to continue..."
    
    # Command Line Tools
    local cli_tools=(
        "git" "gh" "jq" "yq" "curl" "wget" "tree" "htop" "tmux"
        "ripgrep" "fd" "fzf" "bat" "eza" "zoxide" "direnv"
    )
    select_tools_checklist "cli" "Command Line" "${cli_tools[@]}"
    
    # Development Tools
    local dev_tools=(
        "docker" "docker-compose" "kubernetes-cli" "helm" "terraform"
        "vagrant" "ansible" "make" "cmake" "gcc" "llvm"
    )
    select_tools_checklist "dev" "Development" "${dev_tools[@]}"
    
    # Language Tools
    local lang_tools=(
        "nvm" "node" "yarn" "pnpm" "pyenv" "python" "pipx" "poetry"
        "rbenv" "ruby" "go" "rust" "java" "gradle" "maven"
    )
    select_tools_checklist "lang" "Programming Language" "${lang_tools[@]}"
    
    # Database Tools
    local db_tools=(
        "postgresql" "mysql" "redis" "mongodb-community"
        "sqlite" "dbeaver-community"
    )
    select_tools_checklist "db" "Database" "${db_tools[@]}"
    
    # Cloud Tools
    local cloud_tools=(
        "awscli" "azure-cli" "google-cloud-sdk" "doctl"
        "heroku" "vercel" "netlify-cli"
    )
    select_tools_checklist "cloud" "Cloud Provider" "${cloud_tools[@]}"
    
    # Editor Tools
    local editor_tools=(
        "neovim" "vim" "emacs" "visual-studio-code" "sublime-text"
        "intellij-idea-ce" "pycharm-ce"
    )
    select_tools_checklist "editor" "Code Editor" "${editor_tools[@]}"
    
    # Communication Tools
    local comm_tools=(
        "slack" "discord" "zoom" "microsoft-teams" "telegram"
    )
    select_tools_checklist "comm" "Communication" "${comm_tools[@]}"
    
    # Productivity Tools
    local prod_tools=(
        "1password" "alfred" "rectangle" "raycast" "obsidian"
        "notion" "todoist" "fantastical"
    )
    select_tools_checklist "prod" "Productivity" "${prod_tools[@]}"
}

# Role-based configuration
configure_role_based() {
    # First select roles
    echo
    log_section "Role-Based Tool Selection"
    echo
    echo "Available roles:"
    echo "  1) DevOps Engineer"
    echo "  2) Full-Stack Developer"
    echo "  3) Backend Developer"
    echo "  4) Frontend Developer"
    echo "  5) Network/System Admin"
    echo "  6) AI/ML Engineer"
    echo "  7) Data Engineer"
    echo "  8) Security Engineer"
    echo "  9) Mobile Developer"
    echo
    
    select_roles
    
    # Process each role's tools
    for role in "${SELECTED_ROLES[@]}"; do
        log_info "Processing role: $role"
        local role_file="$SCRIPT_DIR/roles/${role}.yaml"
        
        if [[ -f "$role_file" ]]; then
            # Parse and add tools from role
            process_role_tools "$role" "$role_file"
        else
            log_warning "Role file not found: $role_file"
        fi
    done
}

# Process tools for a specific role
process_role_tools() {
    local role=$1
    local role_file=$2
    
    log_section "Configuring tools for: $role"
    echo
    echo "This role includes the following tool categories:"
    echo "Would you like to customize the selection or accept all?"
    echo
    echo "  1) Accept all tools for this role"
    echo "  2) Customize selection"
    echo
    read -p "Your choice [1-2]: " choice
    
    case "$choice" in
        1)
            # Add all tools from role
            add_all_role_tools "$role_file"
            ;;
        2)
            # Let user customize
            customize_role_tools "$role_file"
            ;;
        *)
            log_warning "Invalid choice, accepting all tools"
            add_all_role_tools "$role_file"
            ;;
    esac
}

# Add all tools from a role file
add_all_role_tools() {
    local role_file=$1
    local category=""
    
    while IFS= read -r line; do
        # Detect category
        if [[ "$line" =~ ^(brew|cask|npm|pip|go|cargo): ]]; then
            category="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^[[:space:]]+-[[:space:]]+ ]] && [[ -n "$category" ]]; then
            # Extract tool name (handle both simple and complex entries)
            local tool=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | cut -d' ' -f1 | cut -d':' -f1)
            [[ -n "$tool" ]] && add_to_install_config "$category" "$tool" "true"
        fi
    done < "$role_file"
}

# Customize tools from a role file
customize_role_tools() {
    local role_file=$1
    local current_category=""
    local tools_in_category=()
    
    while IFS= read -r line; do
        # Detect category
        if [[ "$line" =~ ^(brew|cask|npm|pip|go|cargo): ]]; then
            # Process previous category if exists
            if [[ -n "$current_category" ]] && [[ ${#tools_in_category[@]} -gt 0 ]]; then
                select_tools_checklist "$current_category" "$current_category" "${tools_in_category[@]}"
                tools_in_category=()
            fi
            current_category="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^[[:space:]]+-[[:space:]]+ ]] && [[ -n "$current_category" ]]; then
            # Extract tool name
            local tool=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | cut -d' ' -f1 | cut -d':' -f1)
            [[ -n "$tool" ]] && tools_in_category+=("$tool")
        fi
    done < "$role_file"
    
    # Process last category
    if [[ -n "$current_category" ]] && [[ ${#tools_in_category[@]} -gt 0 ]]; then
        select_tools_checklist "$current_category" "$current_category" "${tools_in_category[@]}"
    fi
}

# Preset configuration
configure_preset() {
    show_presets
    if select_preset; then
        # Process roles from preset
        configure_role_based
    else
        # User chose to select individual roles
        configure_role_based
    fi
}

# Configure all tools
configure_all() {
    log_warning "Installing ALL available tools. This is not recommended for most users."
    echo
    read -p "Are you sure you want to install everything? (y/N) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Cancelled. Returning to main menu."
        sleep 2
        show_main_menu
        return
    fi
    
    # Add all tools from all roles
    for role_file in "$SCRIPT_DIR/roles"/*.yaml; do
        [[ -f "$role_file" ]] && add_all_role_tools "$role_file"
    done
}

# Configure minimal installation
configure_minimal() {
    log_info "Configuring minimal installation with core tools only"
    
    # Core tools only
    local core_tools=(
        "git" "curl" "wget" "jq" "ripgrep" "fzf" "htop" "tmux"
    )
    
    for tool in "${core_tools[@]}"; do
        add_to_install_config "brew" "$tool" "true"
    done
    
    # Essential cask apps
    add_to_install_config "cask" "visual-studio-code" "true"
    add_to_install_config "cask" "iterm2" "true"
}

# Perform the actual installation
perform_installation() {
    if [[ ! -f "$INSTALL_CONFIG" ]]; then
        log_error "No installation configuration found"
        return 1
    fi
    
    log_section "Starting Installation"
    echo
    
    # Pre-installation setup
    run_step "Pre-flight checks" "$SCRIPT_DIR/preflight.sh"
    
    # Install Xcode Command Line Tools
    if ! xcode-select -p &> /dev/null; then
        run_step "Xcode Command Line Tools" install_xcode_cli_tools
    fi
    
    # Install Homebrew if needed
    if ! command -v brew &> /dev/null; then
        run_step "Homebrew" install_homebrew
    fi
    
    # Process installations based on configuration
    local current_category=""
    local tools_to_install=()
    
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^# ]] && continue
        [[ -z "$key" ]] && continue
        
        if [[ "$value" == "true" ]]; then
            local category="${key%%_*}"
            local tool="${key#*_}"
            
            # Batch by category for efficiency
            if [[ "$category" != "$current_category" ]]; then
                # Install previous batch
                if [[ -n "$current_category" ]] && [[ ${#tools_to_install[@]} -gt 0 ]]; then
                    install_tools_batch "$current_category" "${tools_to_install[@]}"
                    tools_to_install=()
                fi
                current_category="$category"
            fi
            
            tools_to_install+=("$tool")
        fi
    done < "$INSTALL_CONFIG"
    
    # Install last batch
    if [[ -n "$current_category" ]] && [[ ${#tools_to_install[@]} -gt 0 ]]; then
        install_tools_batch "$current_category" "${tools_to_install[@]}"
    fi
    
    # Post-installation setup
    run_step "Shell configuration" "$SCRIPT_DIR/shell-config.sh"
    run_step "Development tools setup" "$SCRIPT_DIR/dev-tools.sh"
    
    # Clean up installation config
    cleanup_install_config
    
    log_success "Installation complete!"
}

# Install a batch of tools
install_tools_batch() {
    local category=$1
    shift
    local tools=("$@")
    
    case "$category" in
        brew)
            log_info "Installing Homebrew packages: ${tools[*]}"
            brew install "${tools[@]}" || true
            ;;
        cask)
            log_info "Installing Homebrew Cask applications: ${tools[*]}"
            brew install --cask "${tools[@]}" || true
            ;;
        npm)
            log_info "Installing npm packages: ${tools[*]}"
            npm install -g "${tools[@]}" || true
            ;;
        pip)
            log_info "Installing Python packages: ${tools[*]}"
            pip3 install "${tools[@]}" || true
            ;;
        go)
            log_info "Installing Go packages: ${tools[*]}"
            for tool in "${tools[@]}"; do
                go install "$tool" || true
            done
            ;;
        cargo)
            log_info "Installing Rust packages: ${tools[*]}"
            cargo install "${tools[@]}" || true
            ;;
    esac
}

# Main execution flow
main() {
    log_section "Mac Development Environment Setup"
    echo "Version: 3.0 (Configuration-First)"
    echo
    
    # Check if we're resuming
    if [[ -f "$HOME/.mac-setup-state" ]]; then
        read -p "Previous installation detected. Resume? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            load_state
            perform_installation
            return
        fi
    fi
    
    # Show main menu
    show_main_menu
    
    # Build configuration
    configure_installation
    
    # Show summary and confirm
    if show_install_summary; then
        # Save state before installation
        save_state
        
        # Perform installation
        perform_installation
    else
        log_info "Installation cancelled"
        cleanup_install_config
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            INSTALL_MODE="all"
            shift
            ;;
        --minimal)
            INSTALL_MODE="minimal"
            shift
            ;;
        --preset)
            INSTALL_MODE="preset"
            PRESET_NAME="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --all              Install all available tools"
            echo "  --minimal          Install minimal core tools only"
            echo "  --preset <name>    Use a specific preset"
            echo "  --help, -h         Show this help message"
            echo ""
            echo "Without options, runs in interactive mode"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Run main function
main