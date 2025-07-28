#!/bin/bash

# GUI Applications Installation Script
# Installs essential GUI applications for development and DevOps work

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common functions
source "$SCRIPT_DIR/common.sh"

log_info "Installing GUI applications via Homebrew Cask..."

# Essential Development Apps
ESSENTIAL_APPS=(
    # Terminals
    "warp"                    # Modern, AI-powered terminal
    "iterm2"                  # Classic powerful terminal
    
    # Code Editors & IDEs
    "visual-studio-code"      # Primary code editor
    "sublime-text"            # Fast text editor
    "jetbrains-toolbox"       # JetBrains IDE manager
    "cursor"                  # AI-first code editor
    
    # Version Control
    "github"                  # GitHub Desktop
    "sourcetree"              # Git GUI
    "fork"                    # Fast Git client
    
    # Containers & Virtualization
    "orbstack"                # Lightweight Docker/Linux VMs
    "utm"                     # Virtual machines for Apple Silicon
    
    # API Development
    "postman"                 # API testing
    "insomnia"                # REST/GraphQL client
    "rapidapi"                # API design and testing
    
    # Database Tools
    "tableplus"               # Modern database GUI
    "dbeaver-community"       # Universal database tool
    "redis-insight"           # Redis GUI
    "mongodb-compass"         # MongoDB GUI
)

# DevOps & Cloud Tools
DEVOPS_APPS=(
    # Cloud Providers
    "aws-vpn-client"          # AWS VPN
    "google-cloud-sdk"        # GCP CLI and tools
    
    # Kubernetes
    "lens"                    # Kubernetes IDE
    "rancher"                 # Kubernetes management
    
    # Infrastructure
    "cyberduck"               # Cloud storage browser
    "transmit"                # File transfer
    
    # Monitoring
    "stats"                   # System monitor menu bar
    "monitorcontrol"          # External display control
)

# Network Tools
NETWORK_APPS=(
    "wireshark"               # Network protocol analyzer
    "angry-ip-scanner"        # Network scanner
    "wifi-explorer"           # WiFi analyzer
    "viscosity"               # OpenVPN client
    "tailscale"               # Zero-config VPN
    "ngrok"                   # Secure tunnels
)

# Productivity Tools
PRODUCTIVITY_APPS=(
    "rectangle"               # Window management
    "alfred"                  # Productivity launcher
    "obsidian"                # Knowledge management
    "notion"                  # All-in-one workspace
    "linear-linear"           # Issue tracking
)

# Communication
COMMUNICATION_APPS=(
    "slack"                   # Team communication
    "discord"                 # Community communication
    "zoom"                    # Video conferencing
    "microsoft-teams"         # Teams collaboration
)

# Security Tools
SECURITY_APPS=(
    "1password"               # Password manager
    "little-snitch"           # Network monitor
    "gpg-suite"               # GPG tools
    "yubico-authenticator"    # YubiKey management
)

# Additional Developer Tools
DEVELOPER_TOOLS=(
    "dash"                    # API documentation browser
    "paw"                     # API design tool
    "proxyman"                # HTTP debugging proxy
    "charles"                 # Web debugging proxy
    "gas-mask"                # Hosts file manager
    "hex-fiend"               # Hex editor
)

# AI & LLM Tools
AI_TOOLS=(
    "chatgpt"                 # Official ChatGPT desktop app
    "diffusionbee"           # Stable Diffusion GUI
    "jan"                    # Open-source ChatGPT alternative
    "lm-studio"              # Run LLMs locally with GUI
    "gpt4all"                # Run LLMs locally
    "mochi-diffusion"        # Core ML Stable Diffusion
)

# Function to install apps
install_apps() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        if brew list --cask "$app" &> /dev/null 2>&1; then
            log_success "$app already installed"
        else
            log_info "Installing $app..."
            brew install --cask "$app" || log_warning "Failed to install $app"
        fi
    done
}

# Function to let user pick individual apps from a list
pick_and_install_apps() {
    local app_category="$1"
    shift
    local apps=("$@")
    
    echo ""
    log_info "Available $app_category:"
    echo ""
    
    # Display apps with numbers
    for i in "${!apps[@]}"; do
        printf "  %2d) %s\n" $((i+1)) "${apps[$i]}"
    done
    
    echo ""
    echo "Enter the numbers of the apps you want to install (space-separated),"
    echo "or 'all' to install everything, or 'none' to skip:"
    read -r selection
    
    if [[ "$selection" == "all" ]]; then
        install_apps "${apps[@]}"
    elif [[ "$selection" == "none" ]] || [[ -z "$selection" ]]; then
        log_info "Skipping $app_category"
    else
        # Parse selected numbers and install corresponding apps
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#apps[@]}" ]; then
                install_apps "${apps[$((num-1))]}"
            else
                log_warning "Invalid selection: $num"
            fi
        done
    fi
}

# Install essential apps (these are always installed)
echo ""
read -p "Install essential development applications? (y/n/p) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_apps "${ESSENTIAL_APPS[@]}"
elif [[ $REPLY =~ ^[Pp]$ ]]; then
    pick_and_install_apps "essential development applications" "${ESSENTIAL_APPS[@]}"
else
    log_warning "Skipping essential apps - some functionality may be limited"
fi

# Ask for DevOps tools
echo ""
read -p "Install DevOps and cloud tools? (y/n/p) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_apps "${DEVOPS_APPS[@]}"
elif [[ $REPLY =~ ^[Pp]$ ]]; then
    pick_and_install_apps "DevOps and cloud tools" "${DEVOPS_APPS[@]}"
fi

# Ask for network tools
echo ""
read -p "Install network analysis tools? (y/n/p) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_apps "${NETWORK_APPS[@]}"
elif [[ $REPLY =~ ^[Pp]$ ]]; then
    pick_and_install_apps "network analysis tools" "${NETWORK_APPS[@]}"
fi

# Ask for productivity tools
echo ""
read -p "Install productivity tools? (y/n/p) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_apps "${PRODUCTIVITY_APPS[@]}"
elif [[ $REPLY =~ ^[Pp]$ ]]; then
    pick_and_install_apps "productivity tools" "${PRODUCTIVITY_APPS[@]}"
fi

# Ask for communication tools
echo ""
read -p "Install communication tools? (y/n/p) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_apps "${COMMUNICATION_APPS[@]}"
elif [[ $REPLY =~ ^[Pp]$ ]]; then
    pick_and_install_apps "communication tools" "${COMMUNICATION_APPS[@]}"
fi

# Ask for security tools
echo ""
read -p "Install security tools? (y/n/p) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_apps "${SECURITY_APPS[@]}"
elif [[ $REPLY =~ ^[Pp]$ ]]; then
    pick_and_install_apps "security tools" "${SECURITY_APPS[@]}"
fi

# Ask for additional developer tools
echo ""
read -p "Install additional developer tools? (y/n/p) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_apps "${DEVELOPER_TOOLS[@]}"
elif [[ $REPLY =~ ^[Pp]$ ]]; then
    pick_and_install_apps "additional developer tools" "${DEVELOPER_TOOLS[@]}"
fi

# Ask for AI & LLM tools
echo ""
read -p "Install AI & LLM tools? (y/n/p) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_apps "${AI_TOOLS[@]}"
elif [[ $REPLY =~ ^[Pp]$ ]]; then
    pick_and_install_apps "AI & LLM tools" "${AI_TOOLS[@]}"
fi

# Ask about installing fonts
echo ""
read -p "Install developer fonts? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Install fonts for development
    log_info "Installing developer fonts..."
    # Note: Font casks are now in the main homebrew/cask tap, no separate tap needed

    FONTS=(
        "font-jetbrains-mono"
        "font-jetbrains-mono-nerd-font"
        "font-fira-code"
        "font-fira-code-nerd-font"
        "font-hack-nerd-font"
        "font-meslo-lg-nerd-font"
        "font-source-code-pro"
        "font-cascadia-code"
        "font-sf-mono"
    )

    for font in "${FONTS[@]}"; do
        if brew list --cask "$font" &> /dev/null 2>&1; then
            log_success "$font already installed"
        else
            log_info "Installing $font..."
            brew install --cask "$font" || log_warning "Failed to install $font"
        fi
    done
fi  # End of font installation conditional

# Configure VS Code
if command -v code &> /dev/null; then
    log_info "Configuring VS Code..."
    
    # Create VS Code settings directory
    mkdir -p "$HOME/Library/Application Support/Code/User"
    
    # Create VS Code settings
    cat > "$HOME/Library/Application Support/Code/User/settings.json" << 'EOF'
{
    "editor.fontFamily": "'JetBrains Mono', 'Fira Code', Menlo, Monaco, 'Courier New', monospace",
    "editor.fontSize": 13,
    "editor.fontLigatures": true,
    "editor.tabSize": 2,
    "editor.insertSpaces": true,
    "editor.detectIndentation": true,
    "editor.rulers": [80, 120],
    "editor.wordWrap": "on",
    "editor.minimap.enabled": true,
    "editor.formatOnSave": true,
    "editor.formatOnPaste": true,
    "editor.suggestSelection": "first",
    "editor.bracketPairColorization.enabled": true,
    "editor.inlineSuggest.enabled": true,
    
    "terminal.integrated.fontFamily": "'JetBrains Mono', 'MesloLGS NF'",
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.defaultProfile.osx": "zsh",
    
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "files.associations": {
        "*.yml": "yaml",
        "*.yaml": "yaml",
        ".env*": "dotenv"
    },
    
    "workbench.colorTheme": "GitHub Dark Default",
    "workbench.iconTheme": "material-icon-theme",
    "workbench.startupEditor": "none",
    
    "git.enableSmartCommit": true,
    "git.autofetch": true,
    "git.confirmSync": false,
    
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black",
    "python.terminal.activateEnvironment": true,
    
    "[python]": {
        "editor.tabSize": 4
    },
    
    "[go]": {
        "editor.tabSize": 4,
        "editor.insertSpaces": false
    },
    
    "[yaml]": {
        "editor.insertSpaces": true,
        "editor.tabSize": 2
    },
    
    "github.copilot.enable": {
        "*": true,
        "yaml": true,
        "plaintext": true,
        "markdown": true
    },
    
    "redhat.telemetry.enabled": false,
    "telemetry.telemetryLevel": "off"
}
EOF
    
    log_success "VS Code configured with development settings"
fi

# Configure Warp
if [[ -d "$HOME/.warp" ]]; then
    log_info "Configuring Warp terminal..."
    
    # Create Warp themes directory
    mkdir -p "$HOME/.warp/themes"
    
    # Create a custom DevOps theme
    cat > "$HOME/.warp/themes/devops-dark.yaml" << 'EOF'
name: "DevOps Dark"
accent: "#00d4ff"
background: "#0a0e14"
foreground: "#b3b1ad"
details: "darker"
terminal_colors:
  bright:
    black: "#626a73"
    blue: "#59c2ff"
    cyan: "#95e6cb"
    green: "#c2d94c"
    magenta: "#ffee99"
    red: "#f07178"
    white: "#ffffff"
    yellow: "#ffb454"
  normal:
    black: "#01060e"
    blue: "#39bae6"
    cyan: "#95e6cb"
    green: "#91b362"
    magenta: "#f07178"
    red: "#ea6c73"
    white: "#c7c7c7"
    yellow: "#f9af4f"
EOF
    
    log_success "Warp terminal configured"
fi

# Set up app defaults
log_info "Setting up application defaults..."

# Rectangle (window manager) defaults
defaults write com.knollsoft.Rectangle launchOnLogin -bool true
defaults write com.knollsoft.Rectangle hideMenubarIcon -bool false

# Stats (system monitor) defaults
defaults write eu.exelban.Stats runAtLoginEnabled -bool true

log_success "GUI applications installation complete!"
log_info "Installed applications are available in:"
echo "  - Applications folder"
echo "  - Launchpad"
echo "  - Spotlight search"

log_info "Recommended next steps:"
echo "  1. Launch VS Code and sign in to Settings Sync"
echo "  2. Configure Warp with your preferences"
echo "  3. Set up 1Password or your password manager"
echo "  4. Configure cloud provider CLIs (AWS, GCP, Azure)"
echo "  5. Sign in to communication apps (Slack, Discord, etc.)"

log_info "For VS Code extensions, run: install-vscode-extensions"