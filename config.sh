#!/bin/bash
# User configuration for mac-setup
# Copy this file to config.local.sh and modify as needed

# Python version to install
PYTHON_VERSION=${PYTHON_VERSION:-"3.13"}

# Node.js version (major version only)
NODE_VERSION=${NODE_VERSION:-"22"}

# Which components to install
INSTALL_DEVOPS_TOOLS=${INSTALL_DEVOPS_TOOLS:-true}
INSTALL_GUI_APPS=${INSTALL_GUI_APPS:-true}
INSTALL_SECURITY_TOOLS=${INSTALL_SECURITY_TOOLS:-true}
INSTALL_DATABASE_TOOLS=${INSTALL_DATABASE_TOOLS:-true}
INSTALL_NETWORK_TOOLS=${INSTALL_NETWORK_TOOLS:-true}
INSTALL_FUN_STUFF=${INSTALL_FUN_STUFF:-false}

# Terminal preference (warp, iterm2, or both)
PREFERRED_TERMINAL=${PREFERRED_TERMINAL:-"warp"}

# Shell configuration
INSTALL_OH_MY_ZSH=${INSTALL_OH_MY_ZSH:-false}
CONFIGURE_STARSHIP=${CONFIGURE_STARSHIP:-true}

# Development tools
INSTALL_RUST=${INSTALL_RUST:-true}
INSTALL_GO=${INSTALL_GO:-true}
INSTALL_JAVA=${INSTALL_JAVA:-false}

# AI tools
INSTALL_CLAUDE_CLI=${INSTALL_CLAUDE_CLI:-true}
INSTALL_GITHUB_COPILOT=${INSTALL_GITHUB_COPILOT:-true}

# Container runtime (orbstack, docker-desktop, or colima)
CONTAINER_RUNTIME=${CONTAINER_RUNTIME:-"orbstack"}

# Skip confirmations for non-interactive mode
NON_INTERACTIVE=${NON_INTERACTIVE:-false}

# Enable dry run mode (show what would be done without doing it)
DRY_RUN=${DRY_RUN:-false}

# Cache directory for downloads
CACHE_DIR=${CACHE_DIR:-"$HOME/.mac-setup-cache"}

# State file for tracking progress
STATE_FILE=${STATE_FILE:-"$HOME/.mac-setup-state"}

# Load local overrides if they exist
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/config.local.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/config.local.sh"
fi