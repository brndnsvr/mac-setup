# macOS Development Environment Setup

A **role-based** development environment setup for macOS that installs only the tools you need based on your job function. Choose from predefined roles like DevOps Engineer, Full-Stack Developer, or AI/ML Engineer to get a tailored development environment without the bloat.

## ✨ Key Features

- **👤 Role-Based Installation** - Select your role(s) and get only relevant tools
- **🎯 Smart Tool Selection** - Choose between alternatives (e.g., Postman vs Insomnia)
- **📦 Minimal by Default** - Core tools + role-specific additions only
- **🔄 No Redundancy** - Shared tools installed only once across multiple roles
- **🚀 Client-Focused** - No heavy servers; use containers for databases & services
- **⚙️ Highly Configurable** - Customize via YAML role definitions
- **🔍 Pre-flight Checks** - Validate system requirements before installation
- **💊 Health Checks** - Verify successful installation
- **🏃 Non-Interactive Mode** - Perfect for automated deployments
- **🔐 Modern Security** - Built-in security tools and best practices

## 🚀 Quick Start

```bash
# Clone this repository
git clone <repository-url> mac-setup
cd mac-setup

# Make scripts executable
chmod +x *.sh

# Run the setup (interactive mode)
./setup.sh

# Or specify roles directly
./setup.sh --roles backend,devops

# Skip optional tools
./setup.sh --skip-optional

# See what roles match your current setup
./suggest-roles.sh
```

## 👥 Available Roles

### 1. DevOps Engineer
Infrastructure automation, containers, cloud platforms
- Kubernetes tools (kubectl, helm, k9s)
- Infrastructure as Code (Terraform, Ansible)
- Cloud CLIs (AWS, GCP, Azure)
- Container management
- CI/CD tools

### 2. Full-Stack Developer
Frontend + backend + databases
- Node.js, Python, and other runtimes
- Frontend build tools
- Database clients
- API testing tools
- Docker for local services

### 3. Backend Developer
APIs, microservices, server-side development
- Language runtimes (Python, Go, Rust, Java)
- Database clients only (no servers)
- API development tools
- Testing frameworks

### 4. Frontend Developer
Web UIs, JavaScript frameworks, CSS
- Node.js and modern build tools
- CSS processors and frameworks
- Browser testing tools
- Design tool integration

### 5. Network/System Administrator
Network management and system administration
- Network analysis tools (nmap, wireshark)
- System monitoring utilities
- SSH and remote access tools
- Configuration management

### 6. AI/ML Engineer
Machine learning, LLMs, data science
- Ollama for local LLMs
- Python ML/DL frameworks
- Jupyter and notebooks
- LangChain and AI tools

### 7. Data Engineer
ETL, data pipelines, analytics
- Database clients
- Data processing tools
- Python data stack
- Cloud SDKs

### 8. Security Engineer
Security testing and vulnerability assessment
- Security scanners
- Network analysis
- Cryptography tools
- Penetration testing utilities

### 9. Mobile Developer
iOS, Android, and cross-platform development
- Xcode tools
- React Native/Flutter
- Device management
- Mobile testing tools

## 📋 What Gets Installed

### Core Tools (All Roles)
- **Git** & **GitHub CLI** - Version control
- **Modern CLI** - ripgrep, fzf, bat, eza, fd
- **Editors** - Neovim + VS Code/Cursor
- **Terminal** - Warp or iTerm2
- **Shell** - Zsh with Starship prompt
- **Security** - GPG, SSH, age encryption
- **Productivity** - Rectangle, 1Password

## 📁 Repository Structure

```
.
├── setup.sh              # Main role-based setup script
├── suggest-roles.sh      # Analyze current setup and suggest roles
├── roles/                # Role definitions (YAML)
│   ├── core.yaml        # Tools for all developers
│   ├── devops.yaml      # DevOps Engineer tools
│   ├── fullstack.yaml   # Full-Stack Developer tools
│   ├── backend.yaml     # Backend Developer tools
│   ├── frontend.yaml    # Frontend Developer tools
│   ├── network-sysadmin.yaml  # Network/Sysadmin tools
│   ├── ai-ml-engineer.yaml    # AI/ML Engineer tools
│   ├── data-engineer.yaml     # Data Engineer tools
│   ├── security-engineer.yaml # Security Engineer tools
│   └── mobile-developer.yaml  # Mobile Developer tools
├── lib/                  # Supporting libraries
│   ├── role-parser.sh   # YAML parsing functions
│   └── tool-conflicts.yaml # Tool conflict definitions
├── common.sh            # Shared functions and utilities
├── config.sh            # Default configuration values
├── config.local.sh      # User configuration overrides
├── state.sh             # Progress tracking
├── preflight.sh         # Pre-installation checks
├── health-check.sh      # Post-installation verification
├── python-setup.sh      # Python environment setup
├── shell-config.sh      # Shell configuration
├── dev-tools.sh         # Development tools setup
├── devops-tools.sh      # DevOps tools setup
├── ai-tools.sh          # AI/ML tools setup
├── apps-install.sh      # GUI applications
├── manage-packages.sh   # Package management utilities
├── CLAUDE.md           # Instructions for Claude Code
└── README.md           # This file
```

## 🎯 How It Works

### 1. Role Selection
When you run `./setup.sh`, you'll see:
```
Available roles:

  1) DevOps Engineer        - Infrastructure, containers, cloud
  2) Full-Stack Developer   - Frontend + backend + databases
  3) Backend Developer      - APIs, servers, databases
  4) Frontend Developer     - Web UIs, JavaScript, CSS
  5) Network/Sysadmin      - Network tools, system administration
  6) AI/ML Engineer        - Machine learning, LLMs, data science
  7) Data Engineer         - ETL, data pipelines, analytics
  8) Security Engineer     - Security testing, vulnerability assessment
  9) Mobile Developer      - iOS, Android, cross-platform

Select your role(s) - you can choose multiple:
```

### 2. Tool Preference Selection
When similar tools exist, you choose:
```
Choose API testing client:
  1) postman (recommended)
  2) insomnia - Lightweight REST client
  3) bruno - Open-source API client
  s) Skip this tool
Select option (default: 1):
```

### 3. Smart Installation
- Core tools are installed for everyone
- Role-specific tools are added based on selection
- Duplicate tools are automatically detected and installed only once
- Optional tools can be skipped

## 🔧 Role Configuration

Each role is defined in a YAML file under `roles/`:

```yaml
name: "Backend Developer"
description: "APIs, microservices, server-side development"

brew_formulae:
  - name: python@3.13
    description: "Python programming language"
  - name: go
    description: "Go programming language"
    optional: true
    
brew_casks:
  - name: postman
    description: "API testing platform"
    alternatives:
      - name: insomnia
        description: "REST/GraphQL client"
```

## ⚙️ Usage Examples

### Basic Usage
```bash
# Interactive mode - choose roles and preferences
./setup.sh

# Install specific roles
./setup.sh --roles backend,devops

# Skip optional tools
./setup.sh --skip-optional
```

### Migration from Existing Setup
```bash
# See what roles match your current tools
./suggest-roles.sh

# Example output:
# Based on your installed tools, you likely work as:
# • DevOps Engineer
#   Confidence: 5 indicators found
#   Tools found: kubernetes-cli, helm, terraform, docker, k9s
#
# Suggested command:
#   ./setup.sh --roles devops,backend
```

### Adding Custom Roles
Create a new YAML file in `roles/`:
```yaml
# roles/game-developer.yaml
name: "Game Developer"
description: "Game development tools"

brew_formulae:
  - name: sdl2
    description: "Graphics library"
    
brew_casks:
  - name: unity-hub
    description: "Unity game engine"
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