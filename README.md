# macOS Development Environment Setup

This repository contains scripts to automatically set up a complete development environment on a fresh macOS installation, recreating a comprehensive setup with modern development tools.

## ✨ Key Features

- **🔄 Resumable Installation** - Automatically resume from where you left off if interrupted
- **🧪 Dry Run Mode** - Preview what will be installed without making changes
- **⚙️ Highly Configurable** - Customize every aspect via configuration files
- **🏃 Non-Interactive Mode** - Perfect for automated deployments
- **🔍 Pre-flight Checks** - Validate system requirements before installation
- **💊 Health Checks** - Verify successful installation with comprehensive tests
- **🎯 Modular Design** - Run individual components or the complete setup
- **🔐 Security Tools** - Built-in secret scanning and security utilities
- **📦 Modern Package Management** - Declarative configuration with Brewfile
- **🚀 Performance Optimized** - Parallel installations where possible

## 🚀 Quick Start

```bash
# Clone this repository
git clone <repository-url> mac-setup
cd mac-setup

# Make scripts executable
chmod +x *.sh

# Run pre-flight check (recommended)
./preflight.sh

# Run the main setup script
./setup.sh

# Or run with options:
./setup.sh --dry-run              # See what would be installed without installing
NON_INTERACTIVE=true ./setup.sh   # Run without prompts
```

## 📋 What Gets Installed

### System Tools
- **Homebrew** - Package manager for macOS
- **Xcode Command Line Tools** - Essential development tools
- **Core utilities** - GNU coreutils, findutils, sed, awk, grep

### Programming Languages
- **Python 3.13** - Latest Python with pip, virtualenv, poetry, uv
- **Node.js v22+** - Latest LTS with npm, yarn, pnpm
- **Go 1.23+** - Latest Go with workspace setup
- **Rust** - Via rustup (configurable)
- **Ruby** - Via rbenv
- **Java** - OpenJDK (optional)

### Development Tools
- **Git** with enhanced configuration
- **GitHub CLI** for repository management
- **Container runtimes** - OrbStack, Colima, or Docker Desktop (configurable)
- **Neovim** & **Vim** with plugins
- **VS Code** & **Cursor** with extensions
- **Starship** - Cross-shell prompt
- **Modern CLI tools** - ripgrep, fzf, bat, eza, fd
- **Security tools** - gitleaks, trufflehog, trivy, age
- **Version managers** - mise, pyenv, nvm, rbenv

### Shell Environment
- **Zsh** as default shell with:
  - Custom aliases and functions
  - Enhanced completion
  - Syntax highlighting
  - History substring search
  - Starship prompt

### AI Development Tools
- Claude Code CLI
- GitHub Copilot CLI
- Configuration templates

### DevOps Tools
- **Kubernetes** - kubectl, helm, k9s, kubectx, stern
- **Infrastructure as Code** - Terraform, Terragrunt, Packer
- **Configuration Management** - Ansible with ansible-lint
- **Cloud CLIs** - AWS, Azure, GCP, DigitalOcean
- **Container tools** - dive, lazydocker, ctop
- **Monitoring** - Prometheus, Grafana, Loki
- **CI/CD** - act (GitHub Actions locally), CircleCI, GitLab Runner

## 📁 Repository Structure

```
.
├── setup.sh              # Main setup script - orchestrates everything
├── preflight.sh          # Pre-installation system checks
├── health-check.sh       # Post-installation verification
├── common.sh             # Shared functions and utilities
├── config.sh             # Default configuration values
├── config.local.sh       # User configuration overrides (create from .example)
├── state.sh              # Progress tracking and resumability
├── Brewfile              # Declarative Homebrew package list
├── brew-packages.txt     # Additional Homebrew packages
├── python-setup.sh       # Python environment configuration
├── shell-config.sh       # Shell (Zsh) configuration and dotfiles
├── dev-tools.sh          # Development tools and IDE setup
├── devops-tools.sh       # DevOps and cloud tools setup
├── apps-install.sh       # GUI applications installation
├── CLAUDE.md             # Instructions for Claude Code
└── README.md             # This file
```

## 🔧 Script Details

### setup.sh
The main orchestrator that:
- Detects system architecture (Apple Silicon vs Intel)
- Installs Xcode Command Line Tools
- Installs and configures Homebrew
- Runs all other setup scripts in order
- Creates common directory structure

### brew-packages.txt
Contains all Homebrew formulae to install, organized by category:
- Core utilities
- Development tools
- Language environments
- Network tools
- Media utilities

### python-setup.sh
Sets up Python development:
- Installs Python 3.13 via Homebrew
- Configures pip and essential packages
- Sets up pipx for tool isolation
- Creates project templates
- Configures Python REPL with history and completion

### shell-config.sh
Configures the shell environment:
- Sets Zsh as default shell
- Creates organized ~/.zsh/ structure
- Installs Starship prompt
- Sets up aliases and functions
- Configures git with sensible defaults
- Creates development-friendly environment variables

### dev-tools.sh
Installs additional development tools:
- Node.js global packages (TypeScript, ESLint, etc.)
- Go development tools
- Rust toolchain
- VS Code extensions installer
- Project template generators
- AI tool configurations

## ⚙️ Configuration

The setup scripts are highly configurable. Create a `config.local.sh` file to customize your installation:

```bash
# Copy the example configuration
cp config.local.sh.example config.local.sh

# Edit with your preferences
vim config.local.sh
```

### Available Configuration Options

- **Language versions** - Python, Node.js versions
- **Component selection** - Skip GUI apps, DevOps tools, etc.
- **Container runtime** - Choose between OrbStack, Docker Desktop, or Colima
- **Terminal preference** - Warp or iTerm2
- **Shell configuration** - Starship prompt, Oh My Zsh
- **Development tools** - Rust, Go, Java installation

### Running Modes

```bash
# Dry run - see what would be installed
DRY_RUN=true ./setup.sh

# Non-interactive - no prompts
NON_INTERACTIVE=true ./setup.sh

# Resume interrupted installation
./setup.sh  # Automatically resumes from last successful step

# Reset and start fresh
rm ~/.mac-setup-state
./setup.sh
```

## 🛠️ Manual Steps After Setup

1. **Restart Terminal**
   ```bash
   source ~/.zshrc
   ```

2. **Configure Git**
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

3. **Verify Installation**
   ```bash
   ./health-check.sh
   ```

4. **Authenticate Services**
   ```bash
   gh auth login          # GitHub CLI
   aws configure          # AWS CLI
   ```

5. **Install VS Code Extensions**
   ```bash
   install-vscode-extensions
   ```

## 🎯 Custom Commands

After setup, you'll have access to these custom commands:

- `new-project <name> [type]` - Create new project (types: node, python, go, react)
- `new-python-project <name>` - Create Python project with virtual environment
- `dev-help` - Show quick reference for all custom commands
- `update` - Update all package managers
- `extract <file>` - Extract any archive format
- `server [port]` - Start HTTP server
- `ff <name>` - Find files by name
- `backup <file>` - Create timestamped backup

## 🔐 Security Notes

- The scripts don't store any credentials
- AWS and GitHub authentication must be done manually
- Consider using a password manager for API keys
- Review `.gitignore_global` for sensitive file patterns

## 🐛 Troubleshooting

### Homebrew Installation Issues
If Homebrew fails to install:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Python Issues
If Python packages fail to install:
```bash
python3 -m pip install --upgrade pip
python3 -m pip install --user <package>
```

### Shell Not Changing
If Zsh doesn't become the default:
```bash
chsh -s $(which zsh)
# Then restart terminal
```

## 📝 Customization

### Adding Packages
Edit `brew-packages.txt` to add/remove Homebrew packages.

### Shell Configuration
- Edit `~/.zsh/aliases.zsh` for custom aliases
- Edit `~/.zsh/functions.zsh` for custom functions
- Edit `~/.zsh/local.zsh` for machine-specific settings

### Python Packages
Edit the `PYTHON_PACKAGES` array in `python-setup.sh`.

## 🤝 Contributing

Feel free to fork and customize these scripts for your own use. Consider:
- Adding your preferred tools to `brew-packages.txt`
- Customizing shell aliases in `shell-config.sh`
- Adding language-specific setups

## 📄 License

MIT - Feel free to use and modify as needed.

---

**Note**: This setup is optimized for macOS on Apple Silicon but includes Intel Mac compatibility. Tested on macOS Sequoia (Darwin 24.x).