#!/bin/bash

# Mac Development Environment Setup - Role-Based Edition
# This script sets up a development environment based on selected roles

set -euo pipefail

# Error handling
trap 'error_handler $? $LINENO' ERR

# Global error state
ERROR_LOG="$HOME/.mac-setup-errors.log"
ERRORS_OCCURRED=false

# Error handler function
error_handler() {
    local exit_code=$1
    local line_number=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    ERRORS_OCCURRED=true
    
    echo "" >&2
    echo "ERROR: Command failed with exit code $exit_code at line $line_number" >&2
    echo "Timestamp: $timestamp" >&2
    echo "Check $ERROR_LOG for details" >&2
    
    # Log to error file
    echo "[$timestamp] Error at line $line_number: Exit code $exit_code" >> "$ERROR_LOG"
    echo "Command: ${BASH_COMMAND}" >> "$ERROR_LOG"
    echo "---" >> "$ERROR_LOG"
    
    # Don't exit immediately - allow cleanup
    return 0
}

# Cleanup function
cleanup() {
    if [ "$ERRORS_OCCURRED" = true ]; then
        echo ""
        echo "Setup completed with errors. Check $ERROR_LOG for details."
        exit 1
    fi
}

# Benchmarking functions
BENCHMARK_TIMES=()
BENCHMARK_START_TIME=""
BENCHMARK_TOTAL_START=""

benchmark_start() {
    if [ "$BENCHMARK" = true ]; then
        BENCHMARK_TOTAL_START=$(date +%s)
        echo "# Mac Setup Benchmark Report" > "$BENCHMARK_FILE"
        echo "# Started: $(date)" >> "$BENCHMARK_FILE"
        echo "" >> "$BENCHMARK_FILE"
    fi
}

benchmark_step() {
    local step_name=$1
    local start_time=$2
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [ "$BENCHMARK" = true ]; then
        echo "$step_name: ${duration}s" >> "$BENCHMARK_FILE"
        BENCHMARK_TIMES+=("$step_name:$duration")
    fi
}

benchmark_finish() {
    if [ "$BENCHMARK" = true ]; then
        local total_end=$(date +%s)
        local total_duration=$((total_end - BENCHMARK_TOTAL_START))
        
        echo "" >> "$BENCHMARK_FILE"
        echo "Total time: ${total_duration}s ($(($total_duration / 60))m $(($total_duration % 60))s)" >> "$BENCHMARK_FILE"
        echo "" >> "$BENCHMARK_FILE"
        echo "Tool installation breakdown:" >> "$BENCHMARK_FILE"
        
        # Show summary
        echo ""
        echo "════════════════════════════════════════════════════════════════"
        echo "Benchmark Summary"
        echo "════════════════════════════════════════════════════════════════"
        echo ""
        echo "Total installation time: $(($total_duration / 60))m $(($total_duration % 60))s"
        echo ""
        echo "Step breakdown:"
        for timing in "${BENCHMARK_TIMES[@]}"; do
            IFS=':' read -r step duration <<< "$timing"
            printf "  %-30s %3ds\n" "$step" "$duration"
        done
        echo ""
        echo "Full benchmark log saved to: $BENCHMARK_FILE"
    fi
}

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common functions
if [ ! -f "$SCRIPT_DIR/common.sh" ]; then
    echo "ERROR: common.sh not found. Please run from the mac-setup directory." >&2
    exit 1
fi
source "$SCRIPT_DIR/common.sh"

# Configuration
ROLES_DIR="$SCRIPT_DIR/roles"
PRESETS_FILE="$ROLES_DIR/presets.yaml"
SELECTED_ROLES=()
SELECTED_TOOLS=()
SKIP_OPTIONAL=false
AUTO_MODE=false
PRESET_MODE=""
MINIMAL_MODE=false
FULL_MODE=false
DRY_RUN=false
FAILED_UPDATES=()
BENCHMARK=false
BENCHMARK_FILE="$HOME/.mac-setup-benchmark.log"
CONFIG_ONLY=false
USE_CONFIG=false

# Source additional libraries
source "$SCRIPT_DIR/lib/install-config.sh"
source "$SCRIPT_DIR/lib/install-wrapper.sh"

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
    echo "NEW: Configuration Mode Available!"
    echo "  • Use --config-mode to build a configuration without installing"
    echo "  • Review and customize what gets installed"
    echo "  • Use --use-config to install from saved configuration"
    echo ""
}

# Show help
show_help() {
    echo "Mac Development Environment Setup - Role-Based Edition"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --config-mode         Build configuration only (no installation)"
    echo "  --use-config          Use existing configuration for installation"
    echo "  --preset NAME         Use a predefined role combination"
    echo "  --roles ROLE1,ROLE2   Specify roles directly (comma-separated)"
    echo "  --minimal             Install only essential tools"
    echo "  --full                Install all tools including optional ones"
    echo "  --skip-optional       Skip optional tools"
    echo "  --non-interactive     Run without prompts (requires --preset or --roles)"
    echo "  --dry-run             Show what would be installed without installing"
    echo "  --benchmark           Track installation time for each component"
    echo "  --export FILE         Export current configuration to JSON file"
    echo "  --import FILE         Import configuration from JSON file"
    echo "  --profile NAME        Apply a company/team profile"
    echo "  --help, -h            Show this help message"
    echo ""
    echo "Available presets:"
    echo "  startup, enterprise, modern-web, platform, data-scientist,"
    echo "  mobile-fullstack, devops-sre, indie-hacker, cloud-architect,"
    echo "  ml-engineer, tech-lead, consultant, student"
    echo ""
    echo "Available roles:"
    echo "  devops, fullstack, backend, frontend, network-sysadmin,"
    echo "  ai-ml-engineer, data-engineer, security-engineer, mobile-developer"
    echo ""
    echo "Examples:"
    echo "  $0                           # Interactive mode"
    echo "  $0 --preset startup          # Startup developer setup"
    echo "  $0 --roles backend,devops    # Backend + DevOps roles"
    echo "  $0 --preset platform --full  # Full platform engineer setup"
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

# Parse preset from YAML
get_preset_roles() {
    local preset_name=$1
    local in_preset=false
    local in_roles=false
    
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # Check if we're in the right preset
        if [[ "$line" =~ ^[[:space:]]+${preset_name}: ]]; then
            in_preset=true
            continue
        fi
        
        # Check if we've moved to a different preset
        if [ "$in_preset" = true ] && [[ "$line" =~ ^[[:space:]]+[a-z-]+: ]] && [[ ! "$line" =~ name:|description:|roles:|options:|icon: ]]; then
            break
        fi
        
        # Look for roles section
        if [ "$in_preset" = true ] && [[ "$line" =~ ^[[:space:]]+roles: ]]; then
            in_roles=true
            continue
        fi
        
        # Extract roles
        if [ "$in_preset" = true ] && [ "$in_roles" = true ]; then
            if [[ "$line" =~ ^[[:space:]]+-[[:space:]]+(.+) ]]; then
                echo "${BASH_REMATCH[1]}"
            elif [[ ! "$line" =~ ^[[:space:]]+- ]]; then
                break
            fi
        fi
    done < "$PRESETS_FILE"
}

# Display available presets
show_presets() {
    echo "Available presets:"
    echo ""
    echo "  1) startup           - Full-stack + basic DevOps"
    echo "  2) enterprise        - Backend + security focus"
    echo "  3) modern-web        - Frontend + AI integration"
    echo "  4) platform          - DevOps + security + networking"
    echo "  5) data-scientist    - Data engineering + ML/AI"
    echo "  6) mobile-fullstack  - Mobile + backend"
    echo "  7) devops-sre        - Full DevOps/SRE stack"
    echo "  8) indie-hacker      - Solo developer setup"
    echo "  9) cloud-architect   - Cloud + infrastructure + security"
    echo " 10) ml-engineer       - Production ML + backend + DevOps"
    echo " 11) tech-lead         - Full-stack + DevOps + security"
    echo " 12) consultant        - Versatile multi-technology"
    echo " 13) student           - Learning-focused minimal setup"
    echo ""
    echo "  c) Choose individual roles instead"
    echo "  s) Skip and proceed with minimal core tools only"
    echo ""
}

# Select preset
select_preset() {
    local preset_map=(
        "startup"
        "enterprise"
        "modern-web"
        "platform"
        "data-scientist"
        "mobile-fullstack"
        "devops-sre"
        "indie-hacker"
        "cloud-architect"
        "ml-engineer"
        "tech-lead"
        "consultant"
        "student"
    )
    
    echo "Select a preset configuration:"
    read -r selection
    
    case "$selection" in
        c|C)
            return 1
            ;;
        s|S)
            SELECTED_ROLES=()
            return 0
            ;;
        [1-9]|1[0-3])
            local preset="${preset_map[$((selection-1))]}"
            PRESET_MODE="$preset"
            log_info "Loading preset: $preset"
            
            # Get roles from preset
            local preset_roles=($(get_preset_roles "$preset"))
            SELECTED_ROLES=("${preset_roles[@]}")
            
            if [ ${#SELECTED_ROLES[@]} -eq 0 ]; then
                log_warning "No roles found for preset: $preset"
                return 1
            fi
            
            echo ""
            log_info "Preset '$preset' includes these roles:"
            for role in "${SELECTED_ROLES[@]}"; do
                echo "  - $role"
            done
            echo ""
            return 0
            ;;
        *)
            log_warning "Invalid selection"
            return 1
            ;;
    esac
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
    local step_start=$(date +%s)
    
    # First, always install core tools
    log_info "Processing core tools..."
    local core_file="$ROLES_DIR/core.yaml"
    
    if [ -f "$core_file" ]; then
        # Extract tools from core.yaml
        local core_formulae=($(parse_yaml_array "$core_file" "brew_formulae"))
        local core_casks=($(parse_yaml_array "$core_file" "brew_casks"))
        
        # In minimal mode, only add essential core tools
        if [ "$MINIMAL_MODE" = true ]; then
            # Filter for only essential tools (you can define this list)
            local essential_formulae=("git" "gh" "coreutils" "curl" "wget" "jq" "neovim")
            for formula in "${core_formulae[@]}"; do
                if [[ " ${essential_formulae[@]} " =~ " ${formula} " ]]; then
                    SELECTED_TOOLS+=("$formula")
                fi
            done
        else
            SELECTED_TOOLS+=("${core_formulae[@]}")
        fi
        
        # Handle casks with alternatives
        for cask in "${core_casks[@]}"; do
            # Skip optional casks in minimal mode
            if [ "$MINIMAL_MODE" = true ] && [[ "$cask" =~ ^(alfred|1password)$ ]]; then
                continue
            fi
            SELECTED_TOOLS+=("cask:$cask")
        done
    fi
    
    # Process selected roles
    if [ ${#SELECTED_ROLES[@]} -gt 0 ]; then
        for role in "${SELECTED_ROLES[@]}"; do
            local role_file="$ROLES_DIR/${role}.yaml"
        
        if [ -f "$role_file" ]; then
            log_info "Processing role: $role"
            
            # Extract tools from role file with error handling
            local formulae=()
            local casks=()
            
            # Safely parse YAML arrays
            set +e  # Temporarily disable error exit
            formulae=($(parse_yaml_array "$role_file" "brew_formulae" 2>/dev/null))
            local formulae_status=$?
            casks=($(parse_yaml_array "$role_file" "brew_casks" 2>/dev/null))
            local casks_status=$?
            set -e  # Re-enable error exit
            
            if [ $formulae_status -eq 0 ] && [ ${#formulae[@]} -gt 0 ]; then
                # In minimal mode, skip tools marked as optional
                # In full mode, include everything
                # In normal mode, skip tools marked as optional if SKIP_OPTIONAL is true
                for formula in "${formulae[@]}"; do
                    local should_add=true
                    
                    if [ "$MINIMAL_MODE" = true ]; then
                        # TODO: Check if formula is marked as optional in YAML
                        # For now, skip common optional tools
                        if [[ "$formula" =~ ^(git-lfs|vault|consul|terragrunt)$ ]]; then
                            should_add=false
                        fi
                    elif [ "$SKIP_OPTIONAL" = true ]; then
                        # TODO: Check if formula is marked as optional in YAML
                        should_add=true  # For now, add all in normal mode
                    fi
                    
                    if [ "$should_add" = true ]; then
                        SELECTED_TOOLS+=("$formula")
                    fi
                done
            else
                log_warning "No formulae found or failed to parse for role: $role"
            fi
            
            if [ $casks_status -eq 0 ] && [ ${#casks[@]} -gt 0 ]; then
                for cask in "${casks[@]}"; do
                    local should_add=true
                    
                    if [ "$MINIMAL_MODE" = true ]; then
                        # Skip optional GUI apps in minimal mode
                        if [[ "$cask" =~ ^(lens|cyberduck|dash|grammarly-desktop)$ ]]; then
                            should_add=false
                        fi
                    fi
                    
                    if [ "$should_add" = true ]; then
                        SELECTED_TOOLS+=("cask:$cask")
                    fi
                done
            else
                log_warning "No casks found or failed to parse for role: $role"
            fi
        else
            log_error "Role file not found: $role_file"
            echo "Available roles:" >&2
            ls -1 "$ROLES_DIR"/*.yaml 2>/dev/null | xargs -n1 basename | sed 's/.yaml//' | sed 's/^/  - /' >&2
            exit 1
        fi
    done
    fi
    
    # Remove duplicates
    if [ ${#SELECTED_TOOLS[@]} -gt 0 ]; then
        SELECTED_TOOLS=($(echo "${SELECTED_TOOLS[@]}" | tr ' ' '\n' | sort -u))
    fi
    
    benchmark_step "Processing roles" "$step_start"
}

# Export configuration to JSON
export_configuration() {
    local export_file="${1:-mac-setup-config.json}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Get system info
    local macos_version=$(sw_vers -productVersion)
    local arch=$(uname -m)
    
    # Build JSON
    cat > "$export_file" << EOF
{
  "version": "2.0",
  "timestamp": "$timestamp",
  "system": {
    "platform": "darwin",
    "macos_version": "$macos_version",
    "architecture": "$arch"
  },
  "configuration": {
    "preset": "${PRESET_MODE:-null}",
    "roles": [$([ ${#SELECTED_ROLES[@]} -gt 0 ] && printf '"%s",' "${SELECTED_ROLES[@]}" | sed 's/,$//' || echo "")],
    "install_mode": "$([ "$MINIMAL_MODE" = true ] && echo "minimal" || ([ "$FULL_MODE" = true ] && echo "full" || echo "standard"))",
    "skip_optional": $SKIP_OPTIONAL,
    "options": {
      "non_interactive": $AUTO_MODE,
      "dry_run": $DRY_RUN,
      "benchmark": $BENCHMARK
    }
  },
  "tools": {
    "selected": [$(printf '"%s",' "${SELECTED_TOOLS[@]}" | sed 's/,$//')]
  },
  "metadata": {
    "exported_by": "$USER",
    "hostname": "$(hostname)"
  }
}
EOF
    
    log_success "Configuration exported to: $export_file"
    echo ""
    echo "Share this file with your team or use it to replicate your setup:"
    echo "  ./setup.sh --import $export_file"
}

# Import configuration from JSON
import_configuration() {
    local import_file="$1"
    
    if [ ! -f "$import_file" ]; then
        log_error "Import file not found: $import_file"
        exit 1
    fi
    
    log_info "Importing configuration from: $import_file"
    
    # Parse JSON using jq if available, otherwise use basic parsing
    if command -v jq &> /dev/null; then
        # Extract configuration using jq
        PRESET_MODE=$(jq -r '.configuration.preset // empty' "$import_file")
        mapfile -t SELECTED_ROLES < <(jq -r '.configuration.roles[]? // empty' "$import_file")
        local install_mode=$(jq -r '.configuration.install_mode // "standard"' "$import_file")
        SKIP_OPTIONAL=$(jq -r '.configuration.skip_optional // false' "$import_file")
        AUTO_MODE=$(jq -r '.configuration.options.non_interactive // false' "$import_file")
        DRY_RUN=$(jq -r '.configuration.options.dry_run // false' "$import_file")
        BENCHMARK=$(jq -r '.configuration.options.benchmark // false' "$import_file")
    else
        # Basic parsing without jq
        log_warning "jq not found, using basic JSON parsing"
        
        # Extract preset
        PRESET_MODE=$(grep -o '"preset"[[:space:]]*:[[:space:]]*"[^"]*"' "$import_file" | cut -d'"' -f4)
        
        # Extract roles (basic approach)
        local roles_line=$(grep -A 1 '"roles"' "$import_file" | tail -1)
        if [[ "$roles_line" =~ \[([^\]]*)\] ]]; then
            IFS=',' read -ra role_array <<< "${BASH_REMATCH[1]//\"/}"
            SELECTED_ROLES=("${role_array[@]// /}")
        fi
        
        # Extract install mode
        local mode=$(grep -o '"install_mode"[[:space:]]*:[[:space:]]*"[^"]*"' "$import_file" | cut -d'"' -f4)
        case "$mode" in
            "minimal") MINIMAL_MODE=true ;;
            "full") FULL_MODE=true ;;
        esac
    fi
    
    # Validate imported configuration
    if [ -z "$PRESET_MODE" ] && [ ${#SELECTED_ROLES[@]} -eq 0 ]; then
        log_error "Invalid configuration: no preset or roles specified"
        exit 1
    fi
    
    log_success "Configuration imported successfully"
    echo ""
    if [ -n "$PRESET_MODE" ]; then
        echo "Preset: $PRESET_MODE"
    else
        echo "Roles: ${SELECTED_ROLES[*]}"
    fi
    echo "Install mode: $install_mode"
    echo ""
    
    # Set AUTO_MODE since we have configuration
    AUTO_MODE=true
}

# Load company/team profile
load_profile() {
    local profile_name="$1"
    local profile_file=""
    
    # Check different profile locations
    if [ -f "$profile_name" ]; then
        profile_file="$profile_name"
    elif [ -f "$SCRIPT_DIR/profiles/$profile_name.yaml" ]; then
        profile_file="$SCRIPT_DIR/profiles/$profile_name.yaml"
    elif [ -f "$SCRIPT_DIR/profiles/$profile_name" ]; then
        profile_file="$SCRIPT_DIR/profiles/$profile_name"
    else
        log_error "Profile not found: $profile_name"
        echo "Available profiles:"
        find "$SCRIPT_DIR/profiles" -name "*.yaml" -type f | sed "s|$SCRIPT_DIR/profiles/||" | sed 's/.yaml$//'
        exit 1
    fi
    
    log_info "Loading profile: $profile_file"
    
    # Parse profile YAML
    if command -v yq &> /dev/null; then
        # Use yq if available
        local base_preset=$(yq '.base_preset // ""' "$profile_file")
        mapfile -t additional_roles < <(yq '.additional_roles[]? // empty' "$profile_file")
    else
        # Basic parsing
        local base_preset=$(grep -E '^base_preset:' "$profile_file" | sed 's/base_preset:[[:space:]]*//')
        # Parse additional_roles (simplified)
        local in_roles=false
        local additional_roles=()
        while IFS= read -r line; do
            if [[ "$line" =~ ^additional_roles: ]]; then
                in_roles=true
                continue
            fi
            if [ "$in_roles" = true ] && [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(.+) ]]; then
                additional_roles+=("${BASH_REMATCH[1]}")
            elif [ "$in_roles" = true ] && [[ "$line" =~ ^[^[:space:]] ]]; then
                break
            fi
        done < "$profile_file"
    fi
    
    # Apply base preset
    if [ -n "$base_preset" ]; then
        PRESET_MODE="$base_preset"
        # Get roles from preset
        local preset_roles=($(get_preset_roles "$base_preset"))
        SELECTED_ROLES=("${preset_roles[@]}")
    fi
    
    # Add additional roles
    for role in "${additional_roles[@]}"; do
        if [ ${#SELECTED_ROLES[@]} -eq 0 ] || [[ ! " ${SELECTED_ROLES[@]} " =~ " ${role} " ]]; then
            SELECTED_ROLES+=("$role")
        fi
    done
    
    # Extract tool preferences
    local terminal_pref=$(grep -A 1 'terminal:' "$profile_file" | tail -1 | sed 's/[[:space:]]*terminal:[[:space:]]*//' | tr -d '"')
    local editor_pref=$(grep -A 1 'editor:' "$profile_file" | tail -1 | sed 's/[[:space:]]*editor:[[:space:]]*//' | tr -d '"')
    
    if [ -n "$terminal_pref" ]; then
        log_info "Terminal preference: $terminal_pref"
        # This would be used during interactive selection
    fi
    
    if [ -n "$editor_pref" ]; then
        log_info "Editor preference: $editor_pref"
        # This would be used during interactive selection
    fi
    
    # Extract environment variables
    log_info "Profile loaded successfully"
    echo "Configuration from profile:"
    if [ -n "$base_preset" ]; then
        echo "  Base preset: $base_preset"
    fi
    if [ ${#SELECTED_ROLES[@]} -gt 0 ]; then
        echo "  Roles: ${SELECTED_ROLES[*]}"
    fi
    echo ""
    
    # Set AUTO_MODE since we have configuration
    AUTO_MODE=true
}

# Installation summary
show_summary() {
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "Installation Summary"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    if [ -n "$PRESET_MODE" ]; then
        echo "Preset: $PRESET_MODE"
        echo ""
    fi
    
    if [ ${#SELECTED_ROLES[@]} -eq 0 ]; then
        echo "Installing core tools only"
    else
        echo "Roles selected: ${#SELECTED_ROLES[@]}"
        for role in "${SELECTED_ROLES[@]}"; do
            echo "  - $role"
        done
    fi
    
    echo ""
    echo "Installation mode:"
    if [ "$MINIMAL_MODE" = true ]; then
        echo "  - MINIMAL (essential tools only)"
    elif [ "$FULL_MODE" = true ]; then
        echo "  - FULL (including all optional tools)"
    else
        echo "  - STANDARD (essential + recommended tools)"
    fi
    
    if [ "$SKIP_OPTIONAL" = true ]; then
        echo "  - Skipping optional tools"
    fi
    
    echo ""
    echo "Tools to install: ${#SELECTED_TOOLS[@]}"
    echo ""
    
    if [ "$DRY_RUN" = true ]; then
        echo "DRY RUN MODE - No changes will be made"
        echo ""
    fi
    
    read -p "Proceed with installation? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled."
        exit 0
    fi
}

# Main installation
perform_installation() {
    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN: Would perform the following actions..."
        echo ""
    else
        log_info "Starting installation..."
    fi
    
    # Install Homebrew if needed
    if ! command -v brew &> /dev/null; then
        if [ "$DRY_RUN" = true ]; then
            log_info "Would install Homebrew"
        else
            log_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    fi
    
    # Update Homebrew
    if [ "$DRY_RUN" = true ]; then
        log_info "Would update Homebrew"
    else
        log_info "Updating Homebrew..."
        brew update
    fi
    
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
        if [ "$DRY_RUN" = true ]; then
            log_info "Would install ${#formulae[@]} Homebrew formulae:"
            for formula in "${formulae[@]}"; do
                echo "  - $formula"
            done
        else
            log_info "Installing Homebrew formulae..."
            for formula in "${formulae[@]}"; do
                if brew list "$formula" &> /dev/null 2>&1; then
                    log_success "$formula already installed"
                else
                    log_info "Installing $formula..."
                    local tool_start=$(date +%s)
                    if ! brew install "$formula" 2>&1 | tee -a "$ERROR_LOG"; then
                        log_error "Failed to install $formula"
                        FAILED_UPDATES+=("brew:$formula")
                        ERRORS_OCCURRED=true
                    else
                        log_success "Installed $formula"
                        benchmark_step "brew:$formula" "$tool_start"
                    fi
                fi
            done
        fi
    fi
    
    # Install casks
    if [ ${#casks[@]} -gt 0 ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "Would install ${#casks[@]} Homebrew casks:"
            for cask in "${casks[@]}"; do
                echo "  - $cask"
            done
        else
            log_info "Installing Homebrew casks..."
            for cask in "${casks[@]}"; do
                if brew list --cask "$cask" &> /dev/null 2>&1; then
                    log_success "$cask already installed"
                else
                    log_info "Installing $cask..."
                    local tool_start=$(date +%s)
                    if ! brew install --cask "$cask" 2>&1 | tee -a "$ERROR_LOG"; then
                        log_error "Failed to install $cask"
                        FAILED_UPDATES+=("brew-cask:$cask")
                        ERRORS_OCCURRED=true
                    else
                        log_success "Installed $cask"
                        benchmark_step "cask:$cask" "$tool_start"
                    fi
                fi
            done
        fi
    fi
}

# Post-installation setup
post_installation() {
    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN: Would perform post-installation setup"
        return
    fi
    
    log_info "Running post-installation setup..."
    
    # Run shell configuration
    if [ -f "$SCRIPT_DIR/shell-config.sh" ]; then
        log_info "Configuring shell..."
        bash "$SCRIPT_DIR/shell-config.sh"
    fi
    
    # Role-specific setup
    if [ ${#SELECTED_ROLES[@]} -gt 0 ]; then
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
    fi
}

# Main execution
main() {
    show_welcome
    
    # Start benchmarking if enabled
    benchmark_start
    
    # Check for command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --config-mode)
                CONFIG_ONLY=true
                shift
                ;;
            --use-config)
                USE_CONFIG=true
                AUTO_MODE=true
                shift
                ;;
            --roles)
                IFS=',' read -ra SELECTED_ROLES <<< "$2"
                AUTO_MODE=true
                shift 2
                ;;
            --preset)
                PRESET_MODE="$2"
                AUTO_MODE=true
                # Get roles from preset
                local preset_roles=($(get_preset_roles "$2"))
                if [ ${#preset_roles[@]} -eq 0 ]; then
                    log_error "Invalid preset: $2"
                    exit 1
                fi
                SELECTED_ROLES=("${preset_roles[@]}")
                shift 2
                ;;
            --minimal)
                MINIMAL_MODE=true
                shift
                ;;
            --full)
                FULL_MODE=true
                shift
                ;;
            --skip-optional)
                SKIP_OPTIONAL=true
                shift
                ;;
            --non-interactive)
                AUTO_MODE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --benchmark)
                BENCHMARK=true
                shift
                ;;
            --export)
                # Process selected roles first to populate SELECTED_TOOLS
                if [ ${#SELECTED_ROLES[@]} -gt 0 ]; then
                    process_roles
                fi
                export_configuration "${2:-mac-setup-config.json}"
                exit 0
                ;;
            --import)
                if [ -z "${2:-}" ]; then
                    log_error "Import file required"
                    exit 1
                fi
                import_configuration "$2"
                shift 2
                ;;
            --profile)
                if [ -z "${2:-}" ]; then
                    log_error "Profile name required"
                    exit 1
                fi
                load_profile "$2"
                shift 2
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
    
    # Configuration mode - build config and exit
    if [ "$CONFIG_ONLY" = true ]; then
        log_section "Configuration Mode"
        echo "Building installation configuration..."
        echo
        
        # Initialize config
        init_install_config
        
        # Interactive mode for configuration
        if [ "$AUTO_MODE" = false ]; then
            show_presets
            if ! select_preset; then
                # User chose to select individual roles
                show_roles
                select_roles
            fi
        fi
        
        # Process roles and build configuration
        process_roles_for_config
        
        # Show summary and save config
        if show_install_summary; then
            log_success "Configuration saved!"
            echo "Run with --use-config to install using this configuration"
        else
            log_info "Configuration cancelled"
        fi
        exit 0
    fi
    
    # Use existing configuration
    if [ "$USE_CONFIG" = true ]; then
        if [[ ! -f "$HOME/.mac-setup-install-config" ]]; then
            log_error "No configuration found. Run with --config-mode first."
            exit 1
        fi
        log_info "Using existing configuration..."
        perform_installation
        post_installation
    else
        # Traditional mode - immediate installation
        # Interactive mode: show presets first, then roles if needed
        if [ "$AUTO_MODE" = false ]; then
            show_presets
            if ! select_preset; then
                # User chose to select individual roles
                show_roles
                select_roles
            fi
        fi
        
        # Process selected roles
        process_roles
        
        # Show summary and confirm
        show_summary
        
        # Perform installation
        perform_installation
        
        # Post-installation setup
        post_installation
    fi
    
    log_success "Installation complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Run role-specific setup commands shown above"
    echo "  3. Configure your preferred tools and editors"
    echo ""
    echo "For help and commands, run: dev-help"
    
    # Show benchmark results if enabled
    benchmark_finish
    
    # Final cleanup check
    cleanup
}

# Process roles for configuration mode
process_roles_for_config() {
    log_section "Building configuration for selected roles"
    
    # Add core tools to config
    add_core_tools_to_config
    
    # Process each role
    for role in "${SELECTED_ROLES[@]}"; do
        local role_file="$ROLES_DIR/${role}.yaml"
        if [ ! -f "$role_file" ]; then
            log_warning "Role file not found: $role"
            continue
        fi
        
        log_info "Adding tools for role: $role"
        
        # Let user choose which tools to include from this role
        echo
        echo "Configure tools for $role role:"
        echo "  1) Include all tools for this role"
        echo "  2) Customize tool selection"
        echo
        read -p "Your choice [1-2]: " choice
        
        case "$choice" in
            1) add_all_role_tools "$role_file" ;;
            2) customize_role_tools "$role_file" ;;
            *) add_all_role_tools "$role_file" ;;
        esac
    done
}

# Add core tools to configuration
add_core_tools_to_config() {
    local core_file="$ROLES_DIR/core.yaml"
    if [[ -f "$core_file" ]]; then
        log_info "Adding core tools to configuration"
        add_all_role_tools "$core_file"
    fi
}

# Run main function
main "$@"