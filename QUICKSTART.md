# Quick Start Guide

Welcome to the Mac Development Environment Setup! This guide will help you get started quickly based on your role.

## 🚀 Installation in 30 Seconds

```bash
# Clone and run
git clone git@github.com:brndnsvr/mac-setup.git
cd mac-setup
chmod +x *.sh
./setup.sh
```

## 💼 Quick Start by Role

### Backend Developer
Building APIs, microservices, or server applications? Start here:
```bash
./setup.sh --roles backend

# Full stack backend (with databases and testing tools)
./setup.sh --roles backend --full

# Minimal backend (just essentials)
./setup.sh --roles backend --minimal
```
**You'll get**: Python/Go/Rust, database clients, API testing tools, Docker

---

### Frontend Developer
Creating beautiful web interfaces? This is for you:
```bash
./setup.sh --roles frontend

# With design tools
./setup.sh --roles frontend --full
```
**You'll get**: Node.js, modern build tools, CSS processors, design software

---

### Full-Stack Developer
Working on both frontend and backend? Get everything you need:
```bash
./setup.sh --roles fullstack

# Startup mode (includes basic DevOps)
./setup.sh --preset startup
```
**You'll get**: All backend + frontend tools, databases, Docker, API tools

---

### DevOps Engineer
Managing infrastructure and deployments? Start here:
```bash
./setup.sh --roles devops

# With all cloud providers
./setup.sh --roles devops --full
```
**You'll get**: Kubernetes, Terraform, cloud CLIs, monitoring tools

---

### AI/ML Engineer
Building AI-powered applications? Get your ML stack:
```bash
./setup.sh --roles ai-ml-engineer

# Download popular LLM models too
./setup.sh --roles ai-ml-engineer && ollama-setup
```
**You'll get**: Python ML stack, Ollama, LangChain, Jupyter, AI tools

---

### Mobile Developer
Building iOS or Android apps? Choose your platform:
```bash
# iOS Development
./setup.sh --roles mobile-developer --filter ios

# Android Development  
./setup.sh --roles mobile-developer --filter android

# Cross-platform
./setup.sh --roles mobile-developer
```
**You'll get**: Xcode tools, Android Studio, React Native/Flutter

---

### Data Engineer
Working with data pipelines and analytics?
```bash
./setup.sh --roles data-engineer

# With all cloud SDKs
./setup.sh --roles data-engineer --full
```
**You'll get**: Python data stack, database clients, ETL tools, cloud SDKs

---

### Security Engineer
Focusing on security and vulnerability assessment?
```bash
./setup.sh --roles security-engineer

# Include offensive security tools
./setup.sh --roles security-engineer --full
```
**You'll get**: Security scanners, network tools, encryption utilities

---

### Network/System Administrator
Managing networks and systems?
```bash
./setup.sh --roles network-sysadmin
```
**You'll get**: Network analysis tools, monitoring, remote access utilities

---

### QA Engineer
Testing and quality assurance?
```bash
./setup.sh --roles qa-engineer
```
**You'll get**: Testing frameworks, automation tools, API testing

---

### Game Developer
Creating games?
```bash
./setup.sh --roles game-developer

# With specific engine
./setup.sh --roles game-developer --filter unity
```
**You'll get**: Game engines, graphics tools, performance profilers

---

### Blockchain Developer
Building Web3 applications?
```bash
./setup.sh --roles blockchain-developer
```
**You'll get**: Solidity tools, Web3 libraries, blockchain clients

---

### Technical Writer
Creating documentation?
```bash
./setup.sh --roles technical-writer
```
**You'll get**: Markdown editors, static site generators, diagram tools

## 🎯 Common Combinations

### Startup Developer (Full-Stack + Basic DevOps)
```bash
./setup.sh --preset startup
# Equivalent to: ./setup.sh --roles fullstack,devops --minimal
```

### Enterprise Developer (Backend + Security)
```bash
./setup.sh --preset enterprise
# Equivalent to: ./setup.sh --roles backend,security-engineer
```

### Modern Web Developer (Frontend + AI)
```bash
./setup.sh --preset modern-web
# Equivalent to: ./setup.sh --roles frontend,ai-ml-engineer
```

### Platform Engineer (DevOps + Security)
```bash
./setup.sh --preset platform
# Equivalent to: ./setup.sh --roles devops,security-engineer
```

## 🔧 Customization Options

### Minimal Installation
Only install essential tools, skip optional ones:
```bash
./setup.sh --roles backend --minimal
```

### Full Installation
Install everything including optional tools:
```bash
./setup.sh --roles backend --full
```

### Skip Specific Categories
```bash
./setup.sh --roles backend --skip databases,testing
```

### Non-Interactive Mode
Perfect for automation:
```bash
./setup.sh --roles backend,devops --non-interactive
```

### Dry Run
See what would be installed without installing:
```bash
./setup.sh --roles backend --dry-run
```

## 🔍 Not Sure Which Role?

### Use the Setup Wizard
Let us help you choose:
```bash
./setup-wizard.sh
```

### Analyze Your Current Setup
If you already have tools installed:
```bash
./suggest-roles.sh
```

### Browse All Tools
See everything available:
```bash
cat APPLIST.md | less
```

## 📦 What's Next?

After installation:

1. **Restart your terminal** or run:
   ```bash
   source ~/.zshrc
   ```

2. **Check installation**:
   ```bash
   ./health-check.sh
   ```

3. **View your custom commands**:
   ```bash
   dev-help
   ```

4. **Create a new project**:
   ```bash
   new-project my-app     # General project
   new-ai-project my-bot  # AI project
   new-python-project api # Python project
   ```

## ⚡ Quick Tips

- **Choose one terminal**: When prompted, pick either Warp (modern) or iTerm2 (traditional)
- **Choose one editor**: VS Code, Cursor (AI-powered), or Zed (performance)
- **Skip optional tools**: You can always install them later
- **Use presets**: Faster than selecting individual roles
- **Export your setup**: `./setup.sh --export my-setup.json` to replicate later

## 🆘 Need Help?

- **Detailed documentation**: See [README.md](README.md)
- **Role descriptions**: Check [APPLIST.md](APPLIST.md)
- **Troubleshooting**: Run `./health-check.sh`
- **List installed tools**: `./manage-packages.sh list`

## 🚄 Express Setup

Just want to get started ASAP? Run this based on what you do:

```bash
# "I build web apps"
./setup.sh --preset startup

# "I manage cloud infrastructure"  
./setup.sh --roles devops

# "I work with data and ML"
./setup.sh --roles data-engineer,ai-ml-engineer

# "I'm learning to code"
./setup.sh --roles fullstack --minimal

# "I do everything"
./setup.sh --preset platform --full
```

Welcome to your new, perfectly configured Mac development environment! 🎉
