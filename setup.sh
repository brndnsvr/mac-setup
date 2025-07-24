#!/bin/bash

# Mac Environment Setup Script
# This script will set up a development environment on a fresh macOS installation
# matching the configuration analyzed from the source system

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    log_error "This script is designed for macOS only"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log_info "Starting macOS development environment setup..."
log_info "Script directory: $SCRIPT_DIR"

# Check if running on Apple Silicon or Intel
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    log_info "Detected Apple Silicon Mac"
    HOMEBREW_PREFIX="/opt/homebrew"
else
    log_info "Detected Intel Mac"
    HOMEBREW_PREFIX="/usr/local"
fi

# Install Xcode Command Line Tools
log_info "Checking for Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    log_warning "Please complete the Xcode Command Line Tools installation in the popup window"
    log_warning "Press Enter to continue after installation is complete..."
    read -r
else
    log_success "Xcode Command Line Tools already installed"
fi

# Install Homebrew
log_info "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [[ "$ARCH" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    log_success "Homebrew already installed"
fi

# Update Homebrew
log_info "Updating Homebrew..."
brew update

# Install essential packages first
log_info "Installing essential packages..."
ESSENTIALS=(
    "git"
    "wget"
    "curl"
    "jq"
    "coreutils"
    "findutils"
    "gnu-sed"
    "gawk"
    "grep"
)

for package in "${ESSENTIALS[@]}"; do
    if brew list "$package" &> /dev/null; then
        log_success "$package already installed"
    else
        log_info "Installing $package..."
        brew install "$package"
    fi
done

# Install all packages from brew-packages.txt
if [[ -f "$SCRIPT_DIR/brew-packages.txt" ]]; then
    log_info "Installing packages from brew-packages.txt..."
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        if [[ -z "$line" ]] || [[ "$line" =~ ^# ]]; then
            continue
        fi
        
        # Remove inline comments and trim whitespace
        package=$(echo "$line" | sed 's/#.*$//' | xargs)
        
        # Skip if package name is empty after removing comments
        if [[ -z "$package" ]]; then
            continue
        fi
        
        if brew list "$package" &> /dev/null 2>&1; then
            log_success "$package already installed"
        else
            log_info "Installing $package..."
            brew install "$package" || log_warning "Failed to install $package"
        fi
    done < "$SCRIPT_DIR/brew-packages.txt"
else
    log_warning "brew-packages.txt not found, skipping bulk package installation"
fi

# Set up Python environment
if [[ -f "$SCRIPT_DIR/python-setup.sh" ]]; then
    log_info "Setting up Python environment..."
    bash "$SCRIPT_DIR/python-setup.sh"
else
    log_warning "python-setup.sh not found, skipping Python setup"
fi

# Set up shell configuration
if [[ -f "$SCRIPT_DIR/shell-config.sh" ]]; then
    log_info "Setting up shell configuration..."
    bash "$SCRIPT_DIR/shell-config.sh"
else
    log_warning "shell-config.sh not found, skipping shell configuration"
fi

# Set up development tools
if [[ -f "$SCRIPT_DIR/dev-tools.sh" ]]; then
    log_info "Setting up development tools..."
    bash "$SCRIPT_DIR/dev-tools.sh"
else
    log_warning "dev-tools.sh not found, skipping development tools setup"
fi

# Install GUI applications
if [[ -f "$SCRIPT_DIR/apps-install.sh" ]]; then
    log_info "Installing GUI applications..."
    bash "$SCRIPT_DIR/apps-install.sh"
else
    log_warning "apps-install.sh not found, skipping GUI applications"
fi

# Set up DevOps and infrastructure tools
if [[ -f "$SCRIPT_DIR/devops-tools.sh" ]]; then
    log_info "Setting up DevOps and infrastructure tools..."
    bash "$SCRIPT_DIR/devops-tools.sh"
else
    log_warning "devops-tools.sh not found, skipping DevOps tools"
fi

# Create common directories
log_info "Creating common directories..."
DIRECTORIES=(
    "$HOME/bin"
    "$HOME/Projects"
    "$HOME/.config"
    "$HOME/.local/bin"
)

for dir in "${DIRECTORIES[@]}"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_success "Created $dir"
    else
        log_success "$dir already exists"
    fi
done

# Final setup tasks
log_info "Running final setup tasks..."

# Set macOS defaults for development
log_info "Setting macOS defaults for development..."
# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
# Show file extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Enable text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true
# Restart Finder to apply changes
killall Finder || true

log_success "Complete environment setup finished!"
log_info "Please review the following:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. GUI applications installed (if selected):"
echo "   - Warp (modern terminal)"
echo "   - Visual Studio Code"
echo "   - OrbStack (Docker alternative)"
echo "   - Database tools, API clients, and more"
echo "3. Set up your Git configuration:"
echo "   git config --global user.name 'Your Name'"
echo "   git config --global user.email 'your.email@example.com'"
echo "4. Add any personal SSH keys to ~/.ssh/"
echo "5. Configure cloud CLIs:"
echo "   - AWS: aws configure"
echo "   - GitHub: gh auth login"
echo "   - Azure: az login"
echo "6. Launch VS Code and install extensions: install-vscode-extensions"
echo "7. Use helper commands:"
echo "   - dev-help: Show all custom commands"
echo "   - new-project: Create new projects"
echo "   - kube-switch: Switch Kubernetes contexts"
echo "   - aws-switch: Switch AWS profiles"

log_success "Setup script completed!"