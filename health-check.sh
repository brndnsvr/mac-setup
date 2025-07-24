#!/bin/bash
# Health check script to verify installation

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Track success/failure
TOTAL_CHECKS=0
FAILED_CHECKS=0

# Check a tool/command
check_tool() {
    local name=$1
    local check_cmd=$2
    local min_version=$3
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if eval "$check_cmd" &>/dev/null; then
        if [[ -n "$min_version" ]]; then
            version=$(eval "$check_cmd" 2>&1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
            log_success "$name is installed (version: $version)"
        else
            log_success "$name is installed"
        fi
    else
        log_error "$name is NOT installed or not working"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

# Check brew package
check_brew_package() {
    local package=$1
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if brew_installed "$package"; then
        version=$(brew list --versions "$package" | awk '{print $2}')
        log_success "$package is installed (version: $version)"
    else
        log_error "$package is NOT installed"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

log_info "Running health check for mac-setup installation..."
echo

# Check Homebrew
log_info "Checking Homebrew..."
check_tool "Homebrew" "brew --version"

# Check shells
echo
log_info "Checking shells..."
check_tool "Zsh" "zsh --version"
check_tool "Bash" "bash --version"

# Check programming languages
echo
log_info "Checking programming languages..."
check_tool "Python 3" "python3 --version"
check_tool "Node.js" "node --version"
check_tool "npm" "npm --version"
check_tool "Go" "go version"
check_tool "Rust" "rustc --version"
check_tool "Ruby" "ruby --version"

# Check version managers
echo
log_info "Checking version managers..."
check_tool "pyenv" "pyenv --version"
check_tool "nvm" "nvm --version"
check_tool "rbenv" "rbenv --version"

# Check development tools
echo
log_info "Checking development tools..."
check_tool "Git" "git --version"
check_tool "GitHub CLI" "gh --version"
check_tool "Docker" "docker --version"
check_tool "Docker Compose" "docker-compose --version"
check_tool "VS Code" "code --version"

# Check DevOps tools
echo
log_info "Checking DevOps tools..."
check_tool "kubectl" "kubectl version --client"
check_tool "Helm" "helm version"
check_tool "Terraform" "terraform version"
check_tool "AWS CLI" "aws --version"
check_tool "Ansible" "ansible --version"

# Check shell enhancements
echo
log_info "Checking shell enhancements..."
check_tool "Starship" "starship --version"
check_tool "fzf" "fzf --version"
check_tool "ripgrep" "rg --version"
check_tool "bat" "bat --version"
check_tool "eza" "eza --version"

# Check directories
echo
log_info "Checking directory structure..."
directories=(
    "$HOME/Developer"
    "$HOME/go"
    "$HOME/.config"
    "$HOME/.local/bin"
)

for dir in "${directories[@]}"; do
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if [[ -d "$dir" ]]; then
        log_success "Directory exists: $dir"
    else
        log_warning "Directory missing: $dir"
    fi
done

# Summary
echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Health Check Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Total checks: $TOTAL_CHECKS"
echo "Passed: $((TOTAL_CHECKS - FAILED_CHECKS))"
echo "Failed: $FAILED_CHECKS"

if [[ $FAILED_CHECKS -eq 0 ]]; then
    echo
    log_success "All checks passed! Your development environment is properly configured."
else
    echo
    log_warning "Some checks failed. You may need to run setup.sh again or install missing components manually."
fi

# Check for common issues
echo
log_info "Checking for common issues..."

# Check if shell is Zsh
if [[ "$SHELL" != *"zsh" ]]; then
    log_warning "Your default shell is not Zsh. Run: chsh -s $(which zsh)"
fi

# Check if Homebrew is in PATH
if ! command_exists brew; then
    log_error "Homebrew is not in PATH. Add it to your shell configuration."
fi

# Check Git configuration
if [[ -z "$(git config --global user.name)" ]]; then
    log_warning "Git user name not configured. Run: git config --global user.name 'Your Name'"
fi

if [[ -z "$(git config --global user.email)" ]]; then
    log_warning "Git user email not configured. Run: git config --global user.email 'your.email@example.com'"
fi

exit $FAILED_CHECKS