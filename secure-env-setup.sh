#!/bin/bash

# Secure Environment Setup Script
# Sets up .secure_env file with API keys and credentials
# Configures additional shell functions and aliases

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common functions
source "$SCRIPT_DIR/common.sh"

# Configuration
SECURE_ENV_FILE="$HOME/.secure_env"
SECURE_ENV_BACKUP="$HOME/.secure_env.backup.$(date +%Y%m%d_%H%M%S)"
ZSH_FUNCTIONS_FILE="$HOME/.zsh/functions.zsh"
ZSH_ALIASES_FILE="$HOME/.zsh/aliases.zsh"

# Ensure directories exist
mkdir -p "$HOME/.zsh"

# Colors for interactive display
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# Show welcome
show_welcome() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD}         Secure Environment & Shell Configuration               ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "This tool will help you:"
    echo "  • Set up secure environment variables (API keys, tokens)"
    echo "  • Configure useful shell functions"
    echo "  • Add productivity aliases"
    echo ""
    echo -e "${YELLOW}⚠️  Important: Your .secure_env file should NEVER be committed to Git${NC}"
    echo ""
}

# Backup existing files
backup_existing() {
    if [ -f "$SECURE_ENV_FILE" ]; then
        log_info "Backing up existing .secure_env to $SECURE_ENV_BACKUP"
        cp "$SECURE_ENV_FILE" "$SECURE_ENV_BACKUP"
    fi
}

# Environment variable templates
declare -A ENV_TEMPLATES=(
    ["openai"]="OPENAI_API_KEY="
    ["anthropic"]="ANTHROPIC_API_KEY="
    ["github"]="GITHUB_TOKEN=
GH_TOKEN=
GITHUB_USER="
    ["aws"]="AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_PROFILE=default"
    ["gcp"]="GOOGLE_APPLICATION_CREDENTIALS=
GCP_PROJECT_ID="
    ["azure"]="AZURE_SUBSCRIPTION_ID=
AZURE_TENANT_ID=
AZURE_CLIENT_ID=
AZURE_CLIENT_SECRET="
    ["docker"]="DOCKER_USERNAME=
DOCKER_PASSWORD=
DOCKER_REGISTRY="
    ["npm"]="NPM_TOKEN=
NPM_REGISTRY="
    ["databricks"]="DATABRICKS_HOST=
DATABRICKS_TOKEN="
    ["stripe"]="STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=
STRIPE_WEBHOOK_SECRET="
    ["sendgrid"]="SENDGRID_API_KEY=
SENDGRID_FROM_EMAIL="
    ["twilio"]="TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE_NUMBER="
    ["slack"]="SLACK_BOT_TOKEN=
SLACK_APP_TOKEN=
SLACK_WEBHOOK_URL="
    ["database"]="DATABASE_URL=
DB_HOST=localhost
DB_PORT=5432
DB_NAME=
DB_USER=
DB_PASSWORD="
    ["redis"]="REDIS_URL=redis://localhost:6379
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD="
    ["ssh"]="SSH_USER=
SSH_HOST=
SSH_PORT=22
SSH_KEY_PATH=~/.ssh/id_ed25519"
    ["api_general"]="API_BASE_URL=
API_KEY=
API_SECRET=
API_VERSION=v1"
)

# Function templates
declare -A FUNCTION_TEMPLATES=(
    ["docker_cleanup"]='# Docker cleanup functions
docker-cleanup() {
    echo "Cleaning up Docker resources..."
    docker system prune -af --volumes
    docker network prune -f
    echo "Docker cleanup complete!"
}

docker-nuke() {
    echo "⚠️  Removing ALL Docker resources..."
    docker stop $(docker ps -aq) 2>/dev/null || true
    docker rm $(docker ps -aq) 2>/dev/null || true
    docker rmi $(docker images -q) 2>/dev/null || true
    docker volume rm $(docker volume ls -q) 2>/dev/null || true
    docker network rm $(docker network ls -q) 2>/dev/null || true
    echo "Docker nuke complete!"
}'

    ["git_helpers"]='# Git helper functions
git-clean-branches() {
    echo "Cleaning merged branches..."
    git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d
}

git-undo() {
    git reset --soft HEAD~${1:-1}
}

git-amend() {
    git add -A && git commit --amend --no-edit
}

git-push-upstream() {
    git push -u origin $(git branch --show-current)
}'

    ["dev_helpers"]='# Development helper functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

json() {
    jq "." "$@" | less -R
}

port-kill() {
    local port=$1
    lsof -ti:$port | xargs kill -9
}

find-port() {
    lsof -i :$1
}'

    ["productivity"]='# Productivity functions
todo() {
    if [ -z "$1" ]; then
        cat ~/todo.txt 2>/dev/null || echo "No todos yet!"
    else
        echo "$(date +%Y-%m-%d): $*" >> ~/todo.txt
        echo "Added: $*"
    fi
}

note() {
    local note_file="$HOME/notes/$(date +%Y-%m-%d).md"
    mkdir -p "$HOME/notes"
    if [ -z "$1" ]; then
        ${EDITOR:-vim} "$note_file"
    else
        echo "$(date +%H:%M) - $*" >> "$note_file"
        echo "Note added to $note_file"
    fi
}

backup() {
    local source="$1"
    local backup="${source}.backup.$(date +%Y%m%d_%H%M%S)"
    cp -r "$source" "$backup"
    echo "Backed up to: $backup"
}'

    ["cloud_helpers"]='# Cloud helper functions
aws-profile() {
    export AWS_PROFILE=$1
    echo "AWS Profile set to: $AWS_PROFILE"
}

aws-whoami() {
    aws sts get-caller-identity
}

gcloud-project() {
    gcloud config set project $1
    echo "GCloud project set to: $1"
}

k8s-context() {
    kubectl config use-context $1
    echo "Kubernetes context set to: $1"
}'

    ["network_helpers"]='# Network helper functions
myip() {
    echo "Local IP: $(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1)"
    echo "Public IP: $(curl -s https://api.ipify.org)"
}

ports() {
    lsof -iTCP -sTCP:LISTEN -P
}

ssl-check() {
    echo | openssl s_client -connect "$1:443" 2>/dev/null | openssl x509 -noout -dates
}

speed-test() {
    curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -
}'
)

# Alias templates
declare -A ALIAS_TEMPLATES=(
    ["navigation"]='# Navigation aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias docs="cd ~/Documents"
alias proj="cd ~/projects"'

    ["git_shortcuts"]='# Git shortcuts
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gco="git checkout"
alias gb="git branch"
alias gd="git diff"
alias gl="git log --oneline --graph --decorate"
alias gst="git stash"
alias gsp="git stash pop"'

    ["docker_shortcuts"]='# Docker shortcuts
alias d="docker"
alias dc="docker-compose"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias di="docker images"
alias dex="docker exec -it"
alias dlog="docker logs -f"
alias dcp="docker-compose"
alias dcup="docker-compose up -d"
alias dcdown="docker-compose down"
alias dclog="docker-compose logs -f"'

    ["kubernetes_shortcuts"]='# Kubernetes shortcuts
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kgd="kubectl get deployments"
alias kaf="kubectl apply -f"
alias kdel="kubectl delete"
alias klog="kubectl logs -f"
alias kex="kubectl exec -it"
alias kctx="kubectx"
alias kns="kubens"'

    ["development"]='# Development shortcuts
alias py="python3"
alias pip="pip3"
alias venv="python3 -m venv venv && source venv/bin/activate"
alias serve="python3 -m http.server"
alias json="jq ."
alias xml="xmllint --format -"
alias headers="curl -I"
alias grep="grep --color=auto"
alias diff="diff --color=auto"'

    ["productivity"]='# Productivity aliases
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"
alias cls="clear"
alias please="sudo"
alias reload="source ~/.zshrc"
alias zshrc="$EDITOR ~/.zshrc"
alias hosts="sudo $EDITOR /etc/hosts"
alias path="echo $PATH | tr ':' '\n'"'

    ["safety"]='# Safety aliases
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias mkdir="mkdir -pv"
alias wget="wget -c"'

    ["macos_specific"]='# macOS specific aliases
alias showfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidefiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"
alias update="brew update && brew upgrade && brew cleanup"
alias flushdns="dscacheutil -flushcache && killall -HUP mDNSResponder"'
)

# Setup secure environment variables
setup_secure_env() {
    echo ""
    echo -e "${BOLD}Setting up Secure Environment Variables${NC}"
    echo "Select the services you use (space-separated numbers):"
    echo ""
    
    # Display options
    local options=()
    local i=1
    for key in "${!ENV_TEMPLATES[@]}"; do
        options+=("$key")
        echo "  $i) $key"
        ((i++))
    done
    
    echo ""
    echo "  a) All services"
    echo "  s) Skip environment setup"
    echo ""
    
    read -p "Your selection: " selection
    
    if [[ "$selection" == "s" ]]; then
        log_info "Skipping environment setup"
        return
    fi
    
    # Create .secure_env header
    cat > "$SECURE_ENV_FILE" << 'EOF'
#!/usr/bin/env bash
# Secure Environment Variables
# Generated by mac-setup on $(date)
# 
# ⚠️  IMPORTANT: Never commit this file to version control!
# Add .secure_env to your .gitignore
#
# Usage: Add to your .zshrc or .bashrc:
#   [ -f ~/.secure_env ] && source ~/.secure_env

EOF
    
    # Process selections
    if [[ "$selection" == "a" ]]; then
        # Add all templates
        for key in "${!ENV_TEMPLATES[@]}"; do
            echo "" >> "$SECURE_ENV_FILE"
            echo "# $key Configuration" >> "$SECURE_ENV_FILE"
            echo "${ENV_TEMPLATES[$key]}" >> "$SECURE_ENV_FILE"
        done
    else
        # Add selected templates
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#options[@]}" ]; then
                local key="${options[$((num-1))]}"
                echo "" >> "$SECURE_ENV_FILE"
                echo "# $key Configuration" >> "$SECURE_ENV_FILE"
                echo "${ENV_TEMPLATES[$key]}" >> "$SECURE_ENV_FILE"
            fi
        done
    fi
    
    # Set permissions
    chmod 600 "$SECURE_ENV_FILE"
    
    log_success "Created $SECURE_ENV_FILE"
    echo ""
    echo "Next steps:"
    echo "  1. Edit $SECURE_ENV_FILE and add your actual values"
    echo "  2. Add to .gitignore: echo '.secure_env' >> ~/.gitignore_global"
    echo "  3. Source in .zshrc: echo '[ -f ~/.secure_env ] && source ~/.secure_env' >> ~/.zshrc"
}

# Setup shell functions
setup_functions() {
    echo ""
    echo -e "${BOLD}Setting up Shell Functions${NC}"
    echo "Select function categories to add (space-separated numbers):"
    echo ""
    
    local options=()
    local i=1
    for key in "${!FUNCTION_TEMPLATES[@]}"; do
        options+=("$key")
        local clean_name=$(echo "$key" | tr '_' ' ')
        echo "  $i) $clean_name"
        ((i++))
    done
    
    echo ""
    echo "  a) All functions"
    echo "  s) Skip function setup"
    echo ""
    
    read -p "Your selection: " selection
    
    if [[ "$selection" == "s" ]]; then
        log_info "Skipping function setup"
        return
    fi
    
    # Create functions file header if it doesn't exist
    if [ ! -f "$ZSH_FUNCTIONS_FILE" ]; then
        cat > "$ZSH_FUNCTIONS_FILE" << 'EOF'
#!/usr/bin/env zsh
# Custom Shell Functions
# Generated by mac-setup

EOF
    else
        echo "" >> "$ZSH_FUNCTIONS_FILE"
        echo "# Additional functions added by mac-setup on $(date)" >> "$ZSH_FUNCTIONS_FILE"
    fi
    
    # Process selections
    if [[ "$selection" == "a" ]]; then
        # Add all function templates
        for key in "${!FUNCTION_TEMPLATES[@]}"; do
            echo "" >> "$ZSH_FUNCTIONS_FILE"
            echo "${FUNCTION_TEMPLATES[$key]}" >> "$ZSH_FUNCTIONS_FILE"
        done
    else
        # Add selected function templates
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#options[@]}" ]; then
                local key="${options[$((num-1))]}"
                echo "" >> "$ZSH_FUNCTIONS_FILE"
                echo "${FUNCTION_TEMPLATES[$key]}" >> "$ZSH_FUNCTIONS_FILE"
            fi
        done
    fi
    
    log_success "Updated $ZSH_FUNCTIONS_FILE"
}

# Setup shell aliases
setup_aliases() {
    echo ""
    echo -e "${BOLD}Setting up Shell Aliases${NC}"
    echo "Select alias categories to add (space-separated numbers):"
    echo ""
    
    local options=()
    local i=1
    for key in "${!ALIAS_TEMPLATES[@]}"; do
        options+=("$key")
        local clean_name=$(echo "$key" | tr '_' ' ')
        echo "  $i) $clean_name"
        ((i++))
    done
    
    echo ""
    echo "  a) All aliases"
    echo "  s) Skip alias setup"
    echo ""
    
    read -p "Your selection: " selection
    
    if [[ "$selection" == "s" ]]; then
        log_info "Skipping alias setup"
        return
    fi
    
    # Create aliases file header if it doesn't exist
    if [ ! -f "$ZSH_ALIASES_FILE" ]; then
        cat > "$ZSH_ALIASES_FILE" << 'EOF'
#!/usr/bin/env zsh
# Custom Shell Aliases
# Generated by mac-setup

EOF
    else
        echo "" >> "$ZSH_ALIASES_FILE"
        echo "# Additional aliases added by mac-setup on $(date)" >> "$ZSH_ALIASES_FILE"
    fi
    
    # Process selections
    if [[ "$selection" == "a" ]]; then
        # Add all alias templates
        for key in "${!ALIAS_TEMPLATES[@]}"; do
            echo "" >> "$ZSH_ALIASES_FILE"
            echo "${ALIAS_TEMPLATES[$key]}" >> "$ZSH_ALIASES_FILE"
        done
    else
        # Add selected alias templates
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#options[@]}" ]; then
                local key="${options[$((num-1))]}"
                echo "" >> "$ZSH_ALIASES_FILE"
                echo "${ALIAS_TEMPLATES[$key]}" >> "$ZSH_ALIASES_FILE"
            fi
        done
    fi
    
    log_success "Updated $ZSH_ALIASES_FILE"
}

# Ensure .zshrc sources these files
update_zshrc() {
    local zshrc="$HOME/.zshrc"
    local updated=false
    
    echo ""
    log_info "Updating .zshrc configuration..."
    
    # Check and add .secure_env sourcing
    if ! grep -q "source.*\.secure_env" "$zshrc" 2>/dev/null; then
        echo "" >> "$zshrc"
        echo "# Source secure environment variables" >> "$zshrc"
        echo "[ -f ~/.secure_env ] && source ~/.secure_env" >> "$zshrc"
        updated=true
    fi
    
    # Check and add functions sourcing
    if ! grep -q "source.*\.zsh/functions\.zsh" "$zshrc" 2>/dev/null; then
        echo "" >> "$zshrc"
        echo "# Source custom functions" >> "$zshrc"
        echo "[ -f ~/.zsh/functions.zsh ] && source ~/.zsh/functions.zsh" >> "$zshrc"
        updated=true
    fi
    
    # Check and add aliases sourcing
    if ! grep -q "source.*\.zsh/aliases\.zsh" "$zshrc" 2>/dev/null; then
        echo "" >> "$zshrc"
        echo "# Source custom aliases" >> "$zshrc"
        echo "[ -f ~/.zsh/aliases.zsh ] && source ~/.zsh/aliases.zsh" >> "$zshrc"
        updated=true
    fi
    
    if [ "$updated" = true ]; then
        log_success ".zshrc updated with source commands"
    else
        log_info ".zshrc already configured"
    fi
}

# Show final summary
show_summary() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Setup Complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f "$SECURE_ENV_FILE" ]; then
        echo "✅ Secure environment file created: $SECURE_ENV_FILE"
        echo "   Edit this file to add your actual API keys and credentials"
    fi
    
    if [ -f "$ZSH_FUNCTIONS_FILE" ]; then
        echo "✅ Functions file updated: $ZSH_FUNCTIONS_FILE"
    fi
    
    if [ -f "$ZSH_ALIASES_FILE" ]; then
        echo "✅ Aliases file updated: $ZSH_ALIASES_FILE"
    fi
    
    echo ""
    echo -e "${YELLOW}⚠️  Important Security Notes:${NC}"
    echo "1. Never commit .secure_env to version control"
    echo "2. Add to .gitignore: echo '.secure_env' >> ~/.gitignore_global"
    echo "3. Set restrictive permissions: chmod 600 ~/.secure_env"
    echo "4. Use a password manager for storing the actual values"
    echo ""
    echo "To apply changes, run: source ~/.zshrc"
}

# Main execution
main() {
    show_welcome
    
    # Ask if user wants to proceed
    read -p "Continue with setup? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Setup cancelled"
        exit 0
    fi
    
    # Backup existing files
    backup_existing
    
    # Run setup steps
    setup_secure_env
    setup_functions
    setup_aliases
    update_zshrc
    
    # Show summary
    show_summary
}

# Run main function
main "$@"