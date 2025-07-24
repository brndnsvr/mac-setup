#!/bin/bash

# Python Environment Setup Script
# Sets up Python with the latest version and common packages

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common functions
source "$SCRIPT_DIR/common.sh"

log_info "Setting up Python environment..."

# Ensure Homebrew Python is installed
if ! brew list python@3.13 &> /dev/null; then
    log_info "Installing Python 3.13..."
    brew install python@3.13
else
    log_success "Python 3.13 already installed"
fi

# Link Python 3.13 as the default python3
log_info "Setting up Python symlinks..."
brew link --overwrite python@3.13

# Get the correct Python path
if [[ -d "/opt/homebrew" ]]; then
    PYTHON_PATH="/opt/homebrew/bin/python3.13"
    PIP_PATH="/opt/homebrew/bin/pip3.13"
else
    PYTHON_PATH="/usr/local/bin/python3.13"
    PIP_PATH="/usr/local/bin/pip3.13"
fi

# Verify Python installation
log_info "Python version:"
$PYTHON_PATH --version

# Note about pip and externally-managed-environment
log_info "Note: macOS Homebrew Python uses PEP 668 (externally-managed-environment)"
log_info "Global pip installations are discouraged. Instead:"
log_info "  - Use 'brew install' for system-wide packages"
log_info "  - Use 'pipx' for Python CLI tools (installing below)"
log_info "  - Use virtual environments for project-specific packages"

# Install pipx for isolated tool installations
if ! command -v pipx &> /dev/null; then
    log_info "Installing pipx..."
    brew install pipx
else
    log_success "pipx already installed"
fi

# Ensure pipx path is set up
log_info "Ensuring pipx path is configured..."
pipx ensurepath || log_warning "pipx ensurepath failed (may already be configured)"

# Install Python tools via pipx
log_info "Installing Python tools via pipx..."
PIPX_TOOLS=(
    "cookiecutter"
    "httpie"
    "aws-sam-cli"
    "pre-commit"
    "tox"
    "twine"
    "bpython"
    "ptpython"
    "black"
    "flake8"
    "pylint"
    "mypy"
    "poetry"
    "pipenv"
    "jupyter"
    "ipython"
)

for tool in "${PIPX_TOOLS[@]}"; do
    if pipx list | grep -q "$tool"; then
        log_success "$tool already installed via pipx"
    else
        log_info "Installing $tool via pipx..."
        pipx install "$tool" || log_warning "Failed to install $tool"
    fi
done

# Set up pyenv for Python version management
if ! command -v pyenv &> /dev/null; then
    log_info "Installing pyenv..."
    brew install pyenv
else
    log_success "pyenv already installed"
fi

# Create Python startup file
log_info "Creating Python startup file..."
mkdir -p "$HOME/.config/python"
cat > "$HOME/.config/python/pythonstartup.py" << 'EOF'
# Python interactive startup file
import sys
import os
import atexit
import readline
import rlcompleter

# Enable tab completion
readline.parse_and_bind('tab: complete')

# History file
history_file = os.path.expanduser('~/.python_history')

# Load history if it exists
try:
    readline.read_history_file(history_file)
except FileNotFoundError:
    pass

# Save history on exit
atexit.register(readline.write_history_file, history_file)

# Add some useful imports for interactive sessions
try:
    from rich import print as rprint
    from rich.pretty import pprint
    from rich.console import Console
    console = Console()
except ImportError:
    pass

# Custom prompt (optional)
sys.ps1 = '>>> '
sys.ps2 = '... '

print(f"Python {sys.version.split()[0]} interactive session")
print("Tab completion enabled. History will be saved to ~/.python_history")
EOF

# Set PYTHONSTARTUP environment variable
echo "" >> "$HOME/.zshrc"
echo "# Python startup file" >> "$HOME/.zshrc"
echo "export PYTHONSTARTUP=\$HOME/.config/python/pythonstartup.py" >> "$HOME/.zshrc"

# Create a template for virtual environments
log_info "Creating virtual environment template..."
mkdir -p "$HOME/.config/python/templates"
cat > "$HOME/.config/python/templates/requirements-dev.txt" << 'EOF'
# Development dependencies
black
flake8
pylint
mypy
pytest
pytest-cov
pytest-mock
ipython
jupyter
pre-commit
EOF

# Create helper script for creating new Python projects
cat > "$HOME/bin/new-python-project" << 'EOF'
#!/bin/bash
# Helper script to create a new Python project with best practices

PROJECT_NAME=$1
if [[ -z "$PROJECT_NAME" ]]; then
    echo "Usage: new-python-project <project-name>"
    exit 1
fi

echo "Creating new Python project: $PROJECT_NAME"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Create project structure
mkdir -p src tests docs
touch src/__init__.py
touch tests/__init__.py
touch README.md
touch .gitignore
touch setup.py
touch requirements.txt
touch requirements-dev.txt

# Create .gitignore
cat > .gitignore << 'GITIGNORE'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
.venv/
venv/
ENV/
env/
*.egg-info/
dist/
build/
.pytest_cache/
.coverage
.mypy_cache/
.ruff_cache/

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Project
.env
*.log
GITIGNORE

# Create basic setup.py
cat > setup.py << SETUP
from setuptools import setup, find_packages

setup(
    name="$PROJECT_NAME",
    version="0.1.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    python_requires=">=3.8",
    install_requires=[
        # Add your dependencies here
    ],
    extras_require={
        "dev": [
            "black",
            "flake8",
            "pytest",
            "mypy",
        ],
    },
)
SETUP

# Copy development requirements
cp "$HOME/.config/python/templates/requirements-dev.txt" .

echo "Python project '$PROJECT_NAME' created successfully!"
echo "To activate the virtual environment, run:"
echo "  cd $PROJECT_NAME && source .venv/bin/activate"
EOF

chmod +x "$HOME/bin/new-python-project"

log_success "Python environment setup complete!"
log_info "Installed:"
echo "  - Python 3.13 (via Homebrew)"
echo "  - Essential Python packages"
echo "  - pipx for tool isolation"
echo "  - pyenv for version management"
echo "  - Python startup file with tab completion"
echo "  - new-python-project helper script"

log_info "To use the new Python project creator:"
echo "  new-python-project <project-name>"