#!/bin/bash

# Development Tools Setup Script
# Installs and configures additional development tools

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

log_info "Setting up development tools..."

# Node.js development
log_info "Setting up Node.js development environment..."
if command -v node &> /dev/null; then
    log_success "Node.js $(node --version) installed"
    
    # Install global npm packages
    log_info "Installing global npm packages..."
    NPM_PACKAGES=(
        "typescript"
        "ts-node"
        "nodemon"
        "pm2"
        "prettier"
        "eslint"
        "npm-check-updates"
        "yarn"
        "serve"
        "http-server"
        "json-server"
        "concurrently"
    )
    
    for package in "${NPM_PACKAGES[@]}"; do
        if npm list -g "$package" &> /dev/null; then
            log_success "$package already installed globally"
        else
            log_info "Installing $package globally..."
            npm install -g "$package" || log_warning "Failed to install $package"
        fi
    done
else
    log_warning "Node.js not found, skipping npm packages"
fi

# Go development
log_info "Setting up Go development environment..."
if command -v go &> /dev/null; then
    log_success "Go $(go version) installed"
    
    # Create Go workspace
    mkdir -p "$HOME/go/src" "$HOME/go/bin" "$HOME/go/pkg"
    
    # Install Go tools
    log_info "Installing Go development tools..."
    GO_TOOLS=(
        "golang.org/x/tools/gopls@latest"
        "github.com/go-delve/delve/cmd/dlv@latest"
        "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
        "github.com/fatih/gomodifytags@latest"
        "github.com/cweill/gotests/...@latest"
        "github.com/koron/iferr@latest"
    )
    
    for tool in "${GO_TOOLS[@]}"; do
        log_info "Installing $tool..."
        go install "$tool" || log_warning "Failed to install $tool"
    done
else
    log_warning "Go not found, skipping Go tools"
fi

# Rust development
log_info "Checking for Rust installation..."
if ! command -v rustc &> /dev/null; then
    log_info "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    log_success "Rust already installed"
fi

# Docker setup
log_info "Setting up Docker environment..."
if command -v docker &> /dev/null; then
    log_success "Docker already installed"
else
    log_warning "Docker not found. Please install Docker Desktop or OrbStack manually"
    echo "  - Docker Desktop: https://www.docker.com/products/docker-desktop"
    echo "  - OrbStack (lighter alternative): https://orbstack.dev"
fi

# AWS CLI configuration
if command -v aws &> /dev/null; then
    log_success "AWS CLI installed"
    log_info "Creating AWS config directory..."
    mkdir -p "$HOME/.aws"
    
    # Create sample AWS config
    if [[ ! -f "$HOME/.aws/config" ]]; then
        cat > "$HOME/.aws/config" << 'EOF'
[default]
region = us-east-1
output = json

[profile production]
region = us-east-1
output = json

[profile development]
region = us-west-2
output = json
EOF
        log_success "Created sample AWS config"
    fi
else
    log_warning "AWS CLI not found"
fi

# GitHub CLI setup
if command -v gh &> /dev/null; then
    log_success "GitHub CLI installed"
    log_info "To authenticate with GitHub, run: gh auth login"
else
    log_warning "GitHub CLI not found"
fi

# VS Code extensions installer
log_info "Creating VS Code extensions installer..."
cat > "$HOME/bin/install-vscode-extensions" << 'EOF'
#!/bin/bash
# Install recommended VS Code extensions

EXTENSIONS=(
    # General development
    "ms-vscode.vscode-typescript-next"
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    "editorconfig.editorconfig"
    "streetsidesoftware.code-spell-checker"
    "wayou.vscode-todo-highlight"
    "gruntfuggly.todo-tree"
    
    # Git
    "eamodio.gitlens"
    "donjayamanne.githistory"
    "mhutchie.git-graph"
    
    # Python
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-python.black-formatter"
    "charliermarsh.ruff"
    
    # JavaScript/TypeScript
    "ms-vscode.vscode-typescript-next"
    "dbaeumer.vscode-eslint"
    "dsznajder.es7-react-js-snippets"
    
    # Go
    "golang.go"
    
    # Docker
    "ms-azuretools.vscode-docker"
    "ms-vscode-remote.remote-containers"
    
    # YAML/JSON
    "redhat.vscode-yaml"
    "zainchen.json"
    
    # Markdown
    "yzhang.markdown-all-in-one"
    "davidanson.vscode-markdownlint"
    
    # Themes
    "github.github-vscode-theme"
    "zhuangtongfa.material-theme"
    
    # AI assistance
    "github.copilot"
    "github.copilot-chat"
)

echo "Installing VS Code extensions..."
for extension in "${EXTENSIONS[@]}"; do
    echo "Installing $extension..."
    code --install-extension "$extension" || echo "Failed to install $extension"
done

echo "VS Code extensions installation complete!"
EOF

chmod +x "$HOME/bin/install-vscode-extensions"

# Create development project template
log_info "Creating project template generator..."
cat > "$HOME/bin/new-project" << 'EOF'
#!/bin/bash
# Create a new project with common structure

PROJECT_NAME=$1
PROJECT_TYPE=${2:-general}

if [[ -z "$PROJECT_NAME" ]]; then
    echo "Usage: new-project <project-name> [type]"
    echo "Types: general, node, python, go, react"
    exit 1
fi

echo "Creating new $PROJECT_TYPE project: $PROJECT_NAME"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize git
git init

# Create common structure
mkdir -p src tests docs scripts
touch README.md CHANGELOG.md .gitignore

# Create basic README
cat > README.md << README
# $PROJECT_NAME

## Description

Brief description of your project.

## Installation

\`\`\`bash
# Installation instructions
\`\`\`

## Usage

\`\`\`bash
# Usage examples
\`\`\`

## Development

\`\`\`bash
# Development setup
\`\`\`

## Testing

\`\`\`bash
# Run tests
\`\`\`

## License

MIT
README

# Create .editorconfig
cat > .editorconfig << EDITORCONFIG
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.{py,go}]
indent_size = 4

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
EDITORCONFIG

# Type-specific setup
case "$PROJECT_TYPE" in
    node)
        npm init -y
        npm install --save-dev typescript @types/node eslint prettier
        npx tsc --init
        echo "node_modules/" >> .gitignore
        echo "dist/" >> .gitignore
        ;;
    python)
        $HOME/bin/new-python-project "$PROJECT_NAME"
        cd ..
        rm -rf "$PROJECT_NAME"
        ;;
    go)
        go mod init "github.com/username/$PROJECT_NAME"
        mkdir -p cmd pkg internal
        echo "bin/" >> .gitignore
        ;;
    react)
        npx create-react-app . --template typescript
        ;;
    *)
        echo "General project created"
        ;;
esac

echo "Project '$PROJECT_NAME' created successfully!"
echo "cd $PROJECT_NAME to start working"
EOF

chmod +x "$HOME/bin/new-project"

# Install AI development tools
log_info "Setting up AI development tools..."

# Claude Code CLI
if ! command -v claude &> /dev/null; then
    log_info "Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/install.sh | sh || log_warning "Failed to install Claude Code CLI"
else
    log_success "Claude Code CLI already installed"
fi

# GitHub Copilot CLI
if ! command -v github-copilot-cli &> /dev/null; then
    log_info "Installing GitHub Copilot CLI..."
    npm install -g @githubnext/github-copilot-cli || log_warning "Failed to install GitHub Copilot CLI"
else
    log_success "GitHub Copilot CLI already installed"
fi

# Create AI tools configuration
log_info "Creating AI tools configuration..."
mkdir -p "$HOME/.config/ai-tools"
cat > "$HOME/.config/ai-tools/config.json" << 'EOF'
{
  "claude": {
    "model": "claude-3-opus",
    "temperature": 0.7,
    "max_tokens": 4096
  },
  "copilot": {
    "suggestions": true,
    "auto_trigger": true
  },
  "openai": {
    "model": "gpt-4",
    "temperature": 0.7
  }
}
EOF

# Ansible configuration
if command -v ansible &> /dev/null; then
    log_info "Creating Ansible configuration..."
    mkdir -p "$HOME/.ansible"
    cat > "$HOME/.ansible.cfg" << 'EOF'
[defaults]
host_key_checking = False
retry_files_enabled = False
ansible_managed = Ansible managed
interpreter_python = auto_silent
stdout_callback = yaml
callback_whitelist = timer, profile_tasks

[ssh_connection]
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
EOF
    log_success "Ansible configuration created"
fi

# Create a quick reference guide
log_info "Creating development quick reference..."
cat > "$HOME/bin/dev-help" << 'EOF'
#!/bin/bash
# Development Environment Quick Reference

cat << HELP
=== Development Environment Quick Reference ===

## Project Creation
- new-project <name> [type]    Create new project (types: general, node, python, go, react)
- new-python-project <name>    Create Python project with virtual environment

## Package Management
- brew install <package>       Install macOS package
- npm install -g <package>     Install Node.js package globally
- pip install <package>        Install Python package
- go install <package>         Install Go package

## Development Commands
- code .                       Open VS Code in current directory
- nvim <file>                  Edit file with Neovim
- serve                        Start HTTP server in current directory
- json <file>                  Pretty print JSON file

## Git Shortcuts
- g                           git
- gs                          git status
- ga                          git add
- gc                          git commit
- gp                          git push
- gl                          git log

## Docker Commands
- d                           docker
- dc                          docker compose
- dps                         docker ps
- di                          docker images

## System Commands
- reload                      Reload shell configuration
- update                      Update all package managers
- path                        Show PATH entries
- ports                       Show listening ports
- myip                        Show public IP
- localip                     Show local IP

## AI Tools
- claude                      Claude Code CLI
- github-copilot-cli          GitHub Copilot CLI

## VS Code Extensions
- install-vscode-extensions   Install recommended extensions

Type 'man <command>' for detailed help on any command.
HELP
EOF

chmod +x "$HOME/bin/dev-help"

log_success "Development tools setup complete!"
log_info "Installed/configured:"
echo "  - Node.js global packages"
echo "  - Go development tools"
echo "  - Rust toolchain"
echo "  - Docker environment"
echo "  - AWS CLI configuration"
echo "  - GitHub CLI"
echo "  - VS Code extensions installer"
echo "  - Project template generator"
echo "  - AI development tools"
echo "  - Development quick reference (run 'dev-help')"

log_info "Next steps:"
echo "  1. Authenticate GitHub CLI: gh auth login"
echo "  2. Configure AWS CLI: aws configure"
echo "  3. Install VS Code extensions: install-vscode-extensions"
echo "  4. Set up AI tools API keys as needed"