#!/bin/bash

# Installation Configuration Manager
# Handles user selections for what tools to install

set -euo pipefail

# Source common functions
source "${BASH_SOURCE[0]%/*}/../common.sh"

# Configuration file to store selections
INSTALL_CONFIG="$HOME/.mac-setup-install-config"
INSTALL_CONFIG_TEMP="${INSTALL_CONFIG}.tmp"

# Initialize configuration
init_install_config() {
    echo "# Mac Setup Installation Configuration" > "$INSTALL_CONFIG_TEMP"
    echo "# Generated on $(date)" >> "$INSTALL_CONFIG_TEMP"
    echo "" >> "$INSTALL_CONFIG_TEMP"
}

# Add a tool to the installation config
add_to_install_config() {
    local category="$1"
    local tool="$2"
    local value="${3:-true}"
    
    echo "${category}_${tool}=${value}" >> "$INSTALL_CONFIG_TEMP"
}

# Check if a tool should be installed
should_install() {
    local category="$1"
    local tool="$2"
    local key="${category}_${tool}"
    
    # If no config exists, return false (don't install)
    [[ ! -f "$INSTALL_CONFIG" ]] && return 1
    
    # Check if the tool is in the config and set to true
    grep -q "^${key}=true" "$INSTALL_CONFIG" 2>/dev/null
}

# Display a selection menu for tools
select_tools_menu() {
    local category="$1"
    local category_name="$2"
    shift 2
    local tools=("$@")
    
    echo
    log_section "Select $category_name Tools"
    echo "Use SPACE to select/deselect, ENTER when done, 'a' to select all, 'n' to select none"
    echo
    
    local selected=()
    local current=0
    local total=${#tools[@]}
    
    # Initialize all as unselected
    for i in $(seq 0 $((total - 1))); do
        selected[$i]=false
    done
    
    while true; do
        # Clear screen for menu
        clear
        echo
        log_section "Select $category_name Tools"
        echo "Use SPACE to select/deselect, ENTER when done, 'a' to select all, 'n' to select none"
        echo
        
        # Display tools
        for i in $(seq 0 $((total - 1))); do
            if [[ $i -eq $current ]]; then
                echo -n "→ "
            else
                echo -n "  "
            fi
            
            if [[ ${selected[$i]} == true ]]; then
                echo "[✓] ${tools[$i]}"
            else
                echo "[ ] ${tools[$i]}"
            fi
        done
        
        # Read user input
        read -rsn1 key
        
        case "$key" in
            # Up arrow
            A|k)
                ((current--))
                [[ $current -lt 0 ]] && current=$((total - 1))
                ;;
            # Down arrow
            B|j)
                ((current++))
                [[ $current -ge $total ]] && current=0
                ;;
            # Space - toggle selection
            " ")
                if [[ ${selected[$current]} == true ]]; then
                    selected[$current]=false
                else
                    selected[$current]=true
                fi
                ;;
            # Select all
            a|A)
                for i in $(seq 0 $((total - 1))); do
                    selected[$i]=true
                done
                ;;
            # Select none
            n|N)
                for i in $(seq 0 $((total - 1))); do
                    selected[$i]=false
                done
                ;;
            # Enter - confirm selection
            "")
                break
                ;;
        esac
    done
    
    # Save selections to config
    for i in $(seq 0 $((total - 1))); do
        add_to_install_config "$category" "${tools[$i]}" "${selected[$i]}"
    done
    
    # Show summary
    clear
    local selected_count=0
    for i in $(seq 0 $((total - 1))); do
        [[ ${selected[$i]} == true ]] && ((selected_count++))
    done
    
    log_info "Selected $selected_count out of $total $category_name tools"
}

# Simple checklist selection (for when we can't use interactive menu)
select_tools_checklist() {
    local category="$1"
    local category_name="$2"
    shift 2
    local tools=("$@")
    
    echo
    log_section "Select $category_name Tools"
    echo "Enter the numbers of tools to install (space-separated), or:"
    echo "  'all' - Select all tools"
    echo "  'none' - Skip all tools"
    echo "  'recommended' - Select recommended tools only"
    echo
    
    # Display tools with numbers
    for i in $(seq 0 $((${#tools[@]} - 1))); do
        local tool="${tools[$i]}"
        local desc=""
        
        # Add descriptions for common tools
        case "$tool" in
            "git") desc=" (version control - RECOMMENDED)" ;;
            "gh") desc=" (GitHub CLI)" ;;
            "docker") desc=" (containerization - RECOMMENDED)" ;;
            "nvm") desc=" (Node version manager)" ;;
            "pyenv") desc=" (Python version manager - RECOMMENDED)" ;;
            "terraform") desc=" (infrastructure as code)" ;;
            "kubectl") desc=" (Kubernetes CLI)" ;;
            "aws-cli") desc=" (AWS command line)" ;;
            "jq") desc=" (JSON processor - RECOMMENDED)" ;;
            "ripgrep") desc=" (fast file search - RECOMMENDED)" ;;
            "fzf") desc=" (fuzzy finder - RECOMMENDED)" ;;
            "tmux") desc=" (terminal multiplexer)" ;;
            "neovim") desc=" (modern vim editor)" ;;
            "postgresql") desc=" (PostgreSQL client)" ;;
            "redis") desc=" (Redis client)" ;;
        esac
        
        printf "%3d) %-20s%s\n" $((i + 1)) "$tool" "$desc"
    done
    
    echo
    read -p "Your selection: " selection
    
    # Process selection
    case "$selection" in
        all|ALL)
            for tool in "${tools[@]}"; do
                add_to_install_config "$category" "$tool" "true"
            done
            log_info "Selected all $category_name tools"
            ;;
        none|NONE)
            for tool in "${tools[@]}"; do
                add_to_install_config "$category" "$tool" "false"
            done
            log_info "Skipped all $category_name tools"
            ;;
        recommended|RECOMMENDED)
            local recommended=("git" "jq" "ripgrep" "fzf" "pyenv" "docker")
            for tool in "${tools[@]}"; do
                if [[ " ${recommended[@]} " =~ " ${tool} " ]]; then
                    add_to_install_config "$category" "$tool" "true"
                else
                    add_to_install_config "$category" "$tool" "false"
                fi
            done
            log_info "Selected recommended $category_name tools"
            ;;
        *)
            # First, set all to false
            for tool in "${tools[@]}"; do
                add_to_install_config "$category" "$tool" "false"
            done
            
            # Then set selected ones to true
            for num in $selection; do
                if [[ $num =~ ^[0-9]+$ ]] && [[ $num -ge 1 ]] && [[ $num -le ${#tools[@]} ]]; then
                    local index=$((num - 1))
                    add_to_install_config "$category" "${tools[$index]}" "true"
                fi
            done
            ;;
    esac
}

# Load configuration for a role
load_role_tools() {
    local role="$1"
    local role_file="${BASH_SOURCE[0]%/*}/../roles/${role}.yaml"
    
    if [[ ! -f "$role_file" ]]; then
        log_error "Role file not found: $role_file"
        return 1
    fi
    
    # Parse tools from role file
    local in_brew=false
    local in_cask=false
    local category=""
    
    while IFS= read -r line; do
        # Check for section headers
        if [[ "$line" =~ ^brew: ]]; then
            in_brew=true
            in_cask=false
            category="brew"
        elif [[ "$line" =~ ^cask: ]]; then
            in_brew=false
            in_cask=true
            category="cask"
        elif [[ "$line" =~ ^[a-z]+: ]]; then
            in_brew=false
            in_cask=false
        fi
        
        # Extract tool names
        if [[ "$line" =~ ^[[:space:]]+- ]] && [[ -n "$category" ]]; then
            local tool=$(echo "$line" | sed 's/^[[:space:]]*- //' | cut -d' ' -f1)
            echo "${category}:${tool}"
        fi
    done < "$role_file"
}

# Display installation summary
show_install_summary() {
    echo
    log_section "Installation Summary"
    
    if [[ ! -f "$INSTALL_CONFIG_TEMP" ]]; then
        log_error "No configuration found"
        return 1
    fi
    
    local total=0
    local selected=0
    
    echo "Selected tools:"
    echo
    
    local current_category=""
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^# ]] && continue
        [[ -z "$key" ]] && continue
        
        ((total++))
        
        if [[ "$value" == "true" ]]; then
            ((selected++))
            local category="${key%%_*}"
            local tool="${key#*_}"
            
            if [[ "$category" != "$current_category" ]]; then
                echo
                echo "  ${category}:"
                current_category="$category"
            fi
            
            echo "    - $tool"
        fi
    done < "$INSTALL_CONFIG_TEMP"
    
    echo
    echo "Total: $selected tools selected out of $total available"
    echo
    
    read -p "Proceed with installation? (y/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mv "$INSTALL_CONFIG_TEMP" "$INSTALL_CONFIG"
        return 0
    else
        rm -f "$INSTALL_CONFIG_TEMP"
        return 1
    fi
}

# Clean up configuration files
cleanup_install_config() {
    rm -f "$INSTALL_CONFIG" "$INSTALL_CONFIG_TEMP"
}

# Export functions
export -f init_install_config
export -f add_to_install_config
export -f should_install
export -f select_tools_menu
export -f select_tools_checklist
export -f load_role_tools
export -f show_install_summary
export -f cleanup_install_config