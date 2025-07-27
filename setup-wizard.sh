#!/bin/bash

# Mac Development Environment Setup Wizard
# Interactive configuration helper for role-based setup

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common functions
source "$SCRIPT_DIR/common.sh"

# Configuration
ROLES_DIR="$SCRIPT_DIR/roles"
PRESETS_FILE="$ROLES_DIR/presets.yaml"
WIZARD_CONFIG="$HOME/.mac-setup-wizard.json"

# Colors for interactive display
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Wizard state
WIZARD_ANSWERS=()
SELECTED_PRESET=""
SELECTED_ROLES=()
SELECTED_OPTIONS=()
INSTALL_MODE=""

# Display wizard header
show_wizard_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${BOLD}         Mac Development Environment Setup Wizard               ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}              Interactive Configuration Assistant                ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Question 1: Experience level
ask_experience_level() {
    echo -e "${BOLD}Question 1 of 7: What's your experience level?${NC}"
    echo ""
    echo "1) I'm new to development"
    echo "2) I'm a junior developer"
    echo "3) I'm an experienced developer"
    echo "4) I'm a senior developer/architect"
    echo ""
    read -p "Select your experience level (1-4): " level
    
    case $level in
        1) WIZARD_ANSWERS+=("beginner") ;;
        2) WIZARD_ANSWERS+=("junior") ;;
        3) WIZARD_ANSWERS+=("experienced") ;;
        4) WIZARD_ANSWERS+=("senior") ;;
        *) WIZARD_ANSWERS+=("experienced") ;;
    esac
}

# Question 2: Primary focus
ask_primary_focus() {
    echo ""
    echo -e "${BOLD}Question 2 of 7: What's your primary development focus?${NC}"
    echo ""
    echo "1) Web applications"
    echo "2) Mobile applications"
    echo "3) Backend services/APIs"
    echo "4) Infrastructure/DevOps"
    echo "5) Data/Analytics"
    echo "6) AI/Machine Learning"
    echo "7) Security"
    echo "8) Games"
    echo "9) Blockchain/Web3"
    echo "10) Multiple areas"
    echo ""
    read -p "Select your primary focus (1-10): " focus
    
    case $focus in
        1) WIZARD_ANSWERS+=("web") ;;
        2) WIZARD_ANSWERS+=("mobile") ;;
        3) WIZARD_ANSWERS+=("backend") ;;
        4) WIZARD_ANSWERS+=("infrastructure") ;;
        5) WIZARD_ANSWERS+=("data") ;;
        6) WIZARD_ANSWERS+=("ai") ;;
        7) WIZARD_ANSWERS+=("security") ;;
        8) WIZARD_ANSWERS+=("games") ;;
        9) WIZARD_ANSWERS+=("blockchain") ;;
        10) WIZARD_ANSWERS+=("multiple") ;;
        *) WIZARD_ANSWERS+=("web") ;;
    esac
}

# Question 3: Team size
ask_team_size() {
    echo ""
    echo -e "${BOLD}Question 3 of 7: What's your team/company size?${NC}"
    echo ""
    echo "1) Solo developer/freelancer"
    echo "2) Small team (2-10 people)"
    echo "3) Medium company (11-100 people)"
    echo "4) Large company (100+ people)"
    echo "5) Enterprise (1000+ people)"
    echo ""
    read -p "Select your team size (1-5): " size
    
    case $size in
        1) WIZARD_ANSWERS+=("solo") ;;
        2) WIZARD_ANSWERS+=("small") ;;
        3) WIZARD_ANSWERS+=("medium") ;;
        4) WIZARD_ANSWERS+=("large") ;;
        5) WIZARD_ANSWERS+=("enterprise") ;;
        *) WIZARD_ANSWERS+=("small") ;;
    esac
}

# Question 4: Cloud preference
ask_cloud_preference() {
    echo ""
    echo -e "${BOLD}Question 4 of 7: Which cloud provider do you primarily use?${NC}"
    echo ""
    echo "1) AWS"
    echo "2) Google Cloud"
    echo "3) Azure"
    echo "4) Multiple clouds"
    echo "5) None/On-premise"
    echo ""
    read -p "Select your cloud preference (1-5): " cloud
    
    case $cloud in
        1) WIZARD_ANSWERS+=("aws") ;;
        2) WIZARD_ANSWERS+=("gcp") ;;
        3) WIZARD_ANSWERS+=("azure") ;;
        4) WIZARD_ANSWERS+=("multi-cloud") ;;
        5) WIZARD_ANSWERS+=("none") ;;
        *) WIZARD_ANSWERS+=("aws") ;;
    esac
}

# Question 5: Programming languages
ask_languages() {
    echo ""
    echo -e "${BOLD}Question 5 of 7: Which programming languages do you use?${NC}"
    echo "(Select multiple, separated by spaces)"
    echo ""
    echo "1) JavaScript/TypeScript"
    echo "2) Python"
    echo "3) Go"
    echo "4) Rust"
    echo "5) Java/Kotlin"
    echo "6) Swift"
    echo "7) C/C++"
    echo "8) Ruby"
    echo "9) PHP"
    echo ""
    read -p "Select languages (e.g., '1 2 3'): " langs
    
    local selected_langs=""
    for lang in $langs; do
        case $lang in
            1) selected_langs+="js," ;;
            2) selected_langs+="python," ;;
            3) selected_langs+="go," ;;
            4) selected_langs+="rust," ;;
            5) selected_langs+="java," ;;
            6) selected_langs+="swift," ;;
            7) selected_langs+="c," ;;
            8) selected_langs+="ruby," ;;
            9) selected_langs+="php," ;;
        esac
    done
    
    WIZARD_ANSWERS+=("${selected_langs%,}")
}

# Question 6: Installation preference
ask_installation_preference() {
    echo ""
    echo -e "${BOLD}Question 6 of 7: How much do you want to install?${NC}"
    echo ""
    echo "1) Minimal - Just the essentials"
    echo "2) Standard - Recommended tools"
    echo "3) Full - Everything including optional tools"
    echo ""
    read -p "Select installation preference (1-3): " pref
    
    case $pref in
        1) INSTALL_MODE="minimal" ;;
        2) INSTALL_MODE="standard" ;;
        3) INSTALL_MODE="full" ;;
        *) INSTALL_MODE="standard" ;;
    esac
}

# Question 7: Additional features
ask_additional_features() {
    echo ""
    echo -e "${BOLD}Question 7 of 7: Which additional features do you want?${NC}"
    echo "(Select multiple, separated by spaces)"
    echo ""
    echo "1) AI/LLM tools (Ollama, etc.)"
    echo "2) Design tools (Figma, etc.)"
    echo "3) Database servers"
    echo "4) Monitoring tools"
    echo "5) Security scanners"
    echo "6) None"
    echo ""
    read -p "Select features (e.g., '1 2'): " features
    
    local selected_features=""
    for feat in $features; do
        case $feat in
            1) selected_features+="ai," ;;
            2) selected_features+="design," ;;
            3) selected_features+="databases," ;;
            4) selected_features+="monitoring," ;;
            5) selected_features+="security," ;;
            6) selected_features+="none," ;;
        esac
    done
    
    WIZARD_ANSWERS+=("${selected_features%,}")
}

# Analyze answers and recommend configuration
analyze_and_recommend() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Analyzing your responses...${NC}"
    echo ""
    
    local experience="${WIZARD_ANSWERS[0]}"
    local focus="${WIZARD_ANSWERS[1]}"
    local team_size="${WIZARD_ANSWERS[2]}"
    local cloud="${WIZARD_ANSWERS[3]}"
    local languages="${WIZARD_ANSWERS[4]}"
    local features="${WIZARD_ANSWERS[5]}"
    
    # Determine recommended preset/roles based on answers
    case "$focus" in
        "web")
            if [[ "$team_size" == "solo" || "$team_size" == "small" ]]; then
                SELECTED_PRESET="startup"
            else
                SELECTED_PRESET="modern-web"
            fi
            ;;
        "mobile")
            SELECTED_PRESET="mobile-fullstack"
            ;;
        "backend")
            if [[ "$team_size" == "enterprise" ]]; then
                SELECTED_PRESET="enterprise"
            else
                SELECTED_ROLES=("backend")
            fi
            ;;
        "infrastructure")
            if [[ "$experience" == "senior" ]]; then
                SELECTED_PRESET="cloud-architect"
            else
                SELECTED_PRESET="platform"
            fi
            ;;
        "data")
            SELECTED_PRESET="data-scientist"
            ;;
        "ai")
            SELECTED_PRESET="ml-engineer"
            ;;
        "security")
            SELECTED_ROLES=("security-engineer")
            ;;
        "games")
            SELECTED_ROLES=("game-developer")
            ;;
        "blockchain")
            SELECTED_ROLES=("blockchain-developer" "fullstack")
            ;;
        "multiple")
            if [[ "$experience" == "senior" ]]; then
                SELECTED_PRESET="tech-lead"
            else
                SELECTED_PRESET="consultant"
            fi
            ;;
    esac
    
    # Add additional roles based on features
    if [[ "$features" == *"ai"* ]] && [[ "$focus" != "ai" ]]; then
        SELECTED_ROLES+=("ai-ml-engineer")
    fi
    
    if [[ "$features" == *"security"* ]] && [[ "$focus" != "security" ]]; then
        SELECTED_ROLES+=("security-engineer")
    fi
    
    # Show recommendation
    echo -e "${GREEN}✨ Based on your answers, we recommend:${NC}"
    echo ""
    
    if [ -n "$SELECTED_PRESET" ]; then
        echo -e "${BOLD}Preset:${NC} $SELECTED_PRESET"
        # Get roles from preset
        local preset_roles=$(grep -A 10 "^  $SELECTED_PRESET:" "$PRESETS_FILE" | grep -E "^    - " | sed 's/^    - //')
        echo -e "${BOLD}This includes roles:${NC}"
        echo "$preset_roles" | while read -r role; do
            echo "  • $role"
        done
    else
        echo -e "${BOLD}Roles:${NC}"
        for role in "${SELECTED_ROLES[@]}"; do
            echo "  • $role"
        done
    fi
    
    echo ""
    echo -e "${BOLD}Installation mode:${NC} $INSTALL_MODE"
    
    # Cloud-specific recommendations
    if [[ "$cloud" != "none" ]]; then
        echo ""
        echo -e "${BOLD}Cloud tools:${NC}"
        case "$cloud" in
            "aws") echo "  • AWS CLI, SAM CLI, CDK" ;;
            "gcp") echo "  • Google Cloud SDK, gcloud" ;;
            "azure") echo "  • Azure CLI, Azure Functions" ;;
            "multi-cloud") echo "  • AWS CLI, Google Cloud SDK, Azure CLI" ;;
        esac
    fi
}

# Generate setup command
generate_setup_command() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Your personalized setup command:${NC}"
    echo ""
    
    local cmd="./setup.sh"
    
    if [ -n "$SELECTED_PRESET" ]; then
        cmd+=" --preset $SELECTED_PRESET"
    elif [ ${#SELECTED_ROLES[@]} -gt 0 ]; then
        cmd+=" --roles $(IFS=, ; echo "${SELECTED_ROLES[*]}")"
    fi
    
    case "$INSTALL_MODE" in
        "minimal") cmd+=" --minimal" ;;
        "full") cmd+=" --full" ;;
    esac
    
    echo -e "${GREEN}$cmd${NC}"
    echo ""
    
    # Save configuration
    cat > "$WIZARD_CONFIG" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "experience": "${WIZARD_ANSWERS[0]}",
  "focus": "${WIZARD_ANSWERS[1]}",
  "team_size": "${WIZARD_ANSWERS[2]}",
  "cloud": "${WIZARD_ANSWERS[3]}",
  "languages": "${WIZARD_ANSWERS[4]}",
  "features": "${WIZARD_ANSWERS[5]}",
  "install_mode": "$INSTALL_MODE",
  "preset": "$SELECTED_PRESET",
  "roles": [$(printf '"%s",' "${SELECTED_ROLES[@]}" | sed 's/,$//')]
  "command": "$cmd"
}
EOF
    
    echo "Configuration saved to: $WIZARD_CONFIG"
}

# Ask to run setup
ask_to_run() {
    echo ""
    read -p "Would you like to run this setup now? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BOLD}Starting setup...${NC}"
        echo ""
        
        # Parse the command and run it
        if [ -n "$SELECTED_PRESET" ]; then
            "$SCRIPT_DIR/setup.sh" --preset "$SELECTED_PRESET" ${INSTALL_MODE:+--$INSTALL_MODE}
        else
            "$SCRIPT_DIR/setup.sh" --roles "$(IFS=, ; echo "${SELECTED_ROLES[*]}")" ${INSTALL_MODE:+--$INSTALL_MODE}
        fi
    else
        echo ""
        echo "You can run the setup later with the command shown above."
        echo "Your configuration has been saved to: $WIZARD_CONFIG"
    fi
}

# Show tips
show_tips() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}💡 Pro Tips:${NC}"
    echo ""
    echo "• You can always add more roles later with setup.sh"
    echo "• Run './suggest-roles.sh' to see what roles match your current tools"
    echo "• Check './manage-packages.sh list' to see what's installed"
    echo "• Your wizard config is saved and can be shared with teammates"
    echo "• Run './health-check.sh' after installation to verify everything"
    echo ""
}

# Main wizard flow
main() {
    show_wizard_header
    
    echo -e "${BOLD}Welcome to the Mac Setup Wizard!${NC}"
    echo ""
    echo "I'll ask you a few questions to recommend the best setup for you."
    echo "This will take about 2 minutes."
    echo ""
    read -p "Press Enter to begin..."
    
    show_wizard_header
    ask_experience_level
    
    show_wizard_header
    ask_primary_focus
    
    show_wizard_header
    ask_team_size
    
    show_wizard_header
    ask_cloud_preference
    
    show_wizard_header
    ask_languages
    
    show_wizard_header
    ask_installation_preference
    
    show_wizard_header
    ask_additional_features
    
    show_wizard_header
    analyze_and_recommend
    
    generate_setup_command
    ask_to_run
    show_tips
}

# Run the wizard
main "$@"