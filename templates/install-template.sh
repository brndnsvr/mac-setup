#!/bin/bash

# Template Installer Script
# Copies and initializes project templates

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATES_DIR="$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

# Show available templates
show_templates() {
    echo -e "${BOLD}Available Templates:${NC}"
    echo ""
    
    # Backend templates
    echo -e "${YELLOW}Backend:${NC}"
    echo "  • python-api     - FastAPI REST API with async support"
    echo "  • go-service     - Go microservice with gin framework"
    echo "  • node-api       - Express.js API with TypeScript"
    echo ""
    
    # Frontend templates
    echo -e "${YELLOW}Frontend:${NC}"
    echo "  • react-app      - React with TypeScript and Vite"
    echo "  • vue-app        - Vue 3 with TypeScript"
    echo "  • next-app       - Next.js full-stack app"
    echo ""
    
    # Full-stack templates
    echo -e "${YELLOW}Full-Stack:${NC}"
    echo "  • mern-stack     - MongoDB, Express, React, Node.js"
    echo "  • t3-stack       - TypeScript, tRPC, Tailwind, Prisma"
    echo ""
    
    # Mobile templates
    echo -e "${YELLOW}Mobile:${NC}"
    echo "  • react-native   - React Native with TypeScript"
    echo "  • flutter-app    - Flutter mobile application"
    echo ""
    
    # DevOps templates
    echo -e "${YELLOW}DevOps:${NC}"
    echo "  • terraform-aws  - AWS infrastructure with Terraform"
    echo "  • k8s-helm       - Kubernetes Helm chart"
    echo "  • docker-compose - Multi-container Docker setup"
    echo ""
    
    # Other templates
    echo -e "${YELLOW}Specialized:${NC}"
    echo "  • ml-project     - Python ML project structure"
    echo "  • llm-app        - LangChain LLM application"
    echo "  • smart-contract - Solidity smart contract"
    echo "  • web3-dapp      - Web3 decentralized app"
}

# Show usage
show_usage() {
    echo "Usage: $0 <project-name> <template> [options]"
    echo ""
    echo "Options:"
    echo "  --git           Initialize git repository"
    echo "  --install       Install dependencies"
    echo "  --open          Open in VS Code"
    echo "  --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 my-api python-api --git --install"
    echo "  $0 my-app react-app --open"
    echo ""
    show_templates
}

# Check if template exists
template_exists() {
    local template=$1
    [ -d "$TEMPLATES_DIR/$template" ]
}

# Copy template
copy_template() {
    local project_name=$1
    local template=$2
    local target_dir="$PWD/$project_name"
    
    if [ -d "$target_dir" ]; then
        echo -e "${RED}Error: Directory '$project_name' already exists${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Creating project '$project_name' from template '$template'...${NC}"
    cp -r "$TEMPLATES_DIR/$template" "$target_dir"
    
    # Remove any .git directory from template
    rm -rf "$target_dir/.git"
    
    # Update project name in files
    if [ -f "$target_dir/package.json" ]; then
        sed -i '' "s/\"name\": \".*\"/\"name\": \"$project_name\"/" "$target_dir/package.json" 2>/dev/null || \
        sed -i "s/\"name\": \".*\"/\"name\": \"$project_name\"/" "$target_dir/package.json"
    fi
    
    if [ -f "$target_dir/README.md" ]; then
        sed -i '' "s/# .* Template/# $project_name/" "$target_dir/README.md" 2>/dev/null || \
        sed -i "s/# .* Template/# $project_name/" "$target_dir/README.md"
    fi
    
    echo -e "${GREEN}✓ Project created at: $target_dir${NC}"
}

# Initialize git repository
init_git() {
    local project_dir=$1
    echo -e "${GREEN}Initializing git repository...${NC}"
    cd "$project_dir"
    git init
    git add .
    git commit -m "Initial commit from $2 template"
    echo -e "${GREEN}✓ Git repository initialized${NC}"
}

# Install dependencies
install_deps() {
    local project_dir=$1
    local template=$2
    
    cd "$project_dir"
    
    echo -e "${GREEN}Installing dependencies...${NC}"
    
    # Node.js projects
    if [ -f "package.json" ]; then
        if command -v pnpm &> /dev/null; then
            pnpm install
        elif command -v yarn &> /dev/null; then
            yarn install
        else
            npm install
        fi
    fi
    
    # Python projects
    if [ -f "requirements.txt" ]; then
        if [ ! -d "venv" ]; then
            python3 -m venv venv
        fi
        source venv/bin/activate
        pip install -r requirements.txt
        if [ -f "requirements-dev.txt" ]; then
            pip install -r requirements-dev.txt
        fi
    fi
    
    # Go projects
    if [ -f "go.mod" ]; then
        go mod download
    fi
    
    # Flutter projects
    if [ -f "pubspec.yaml" ] && [[ "$template" == "flutter-app" ]]; then
        flutter pub get
    fi
    
    echo -e "${GREEN}✓ Dependencies installed${NC}"
}

# Open in VS Code
open_vscode() {
    local project_dir=$1
    if command -v code &> /dev/null; then
        echo -e "${GREEN}Opening in VS Code...${NC}"
        code "$project_dir"
    else
        echo -e "${YELLOW}VS Code not found. Please open the project manually.${NC}"
    fi
}

# Main function
main() {
    # Check arguments
    if [ $# -lt 2 ]; then
        show_usage
        exit 1
    fi
    
    local project_name=$1
    local template=$2
    shift 2
    
    # Check for help
    if [[ "$project_name" == "--help" ]] || [[ "$project_name" == "-h" ]]; then
        show_usage
        exit 0
    fi
    
    # Check if template exists
    if ! template_exists "$template"; then
        echo -e "${RED}Error: Template '$template' not found${NC}"
        echo ""
        show_templates
        exit 1
    fi
    
    # Parse options
    local do_git=false
    local do_install=false
    local do_open=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --git)
                do_git=true
                shift
                ;;
            --install)
                do_install=true
                shift
                ;;
            --open)
                do_open=true
                shift
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                exit 1
                ;;
        esac
    done
    
    # Copy template
    copy_template "$project_name" "$template"
    
    local project_dir="$PWD/$project_name"
    
    # Optional steps
    if [ "$do_git" = true ]; then
        init_git "$project_dir" "$template"
    fi
    
    if [ "$do_install" = true ]; then
        install_deps "$project_dir" "$template"
    fi
    
    if [ "$do_open" = true ]; then
        open_vscode "$project_dir"
    fi
    
    # Show next steps
    echo ""
    echo -e "${BOLD}Next steps:${NC}"
    echo "  cd $project_name"
    
    if [ "$do_git" = false ]; then
        echo "  git init                    # Initialize git repository"
    fi
    
    if [ "$do_install" = false ]; then
        case "$template" in
            *api|*app|*stack|react-native)
                echo "  npm install                 # Install dependencies"
                ;;
            python-*|ml-*)
                echo "  python -m venv venv         # Create virtual environment"
                echo "  source venv/bin/activate    # Activate virtual environment"
                echo "  pip install -r requirements.txt"
                ;;
        esac
    fi
    
    echo ""
    echo -e "${GREEN}Happy coding! 🚀${NC}"
}

# Run main function
main "$@"