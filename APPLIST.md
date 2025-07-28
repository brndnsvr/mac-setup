# Application List by Role

This document lists all applications and tools organized by role. Tools marked with 📦 are installed for all roles (core tools).

## Legend
- 📦 Core tool (installed for all roles)
- 🔧 Command-line tool (Homebrew formula)
- 🖥️ GUI application (Homebrew cask)
- 🐍 Python package (via pipx)
- 📦 npm package (global)
- ⚡ Optional tool
- 💰 Paid/Premium tool
- 🔄 Has alternatives (you choose one)

---

## Core Tools (All Developers) 📦

### Version Control & Git
- 🔧 `git` - Distributed version control
- 🔧 `gh` - GitHub CLI
- 🔧 `git-lfs` - Large file support ⚡
- 🖥️ `github` - GitHub Desktop

### Essential CLI Tools
- 🔧 `coreutils` - GNU core utilities
- 🔧 `curl` - Transfer data with URLs
- 🔧 `wget` - Internet file retriever
- 🔧 `jq` - JSON processor
- 🔧 `yq` - YAML processor

### Modern CLI Replacements
- 🔧 `ripgrep` - Fast grep replacement
- 🔧 `fd` - Fast find replacement
- 🔧 `fzf` - Fuzzy finder
- 🔧 `bat` - Better cat with syntax highlighting
- 🔧 `eza` - Modern ls replacement
- 🔧 `tree` - Directory listing

### Shell & Terminal
- 🔧 `zsh` - Z shell
- 🔧 `starship` - Cross-shell prompt
- 🔧 `tmux` - Terminal multiplexer
- 🖥️ `warp` - AI-powered terminal 🔄
  - Alt: `iterm2` - Traditional powerful terminal

### Text Editors
- 🔧 `neovim` - Modern vim
- 🖥️ `visual-studio-code` - Code editor 🔄
  - Alt: `cursor` - AI-powered VS Code fork
  - Alt: `zed` - High-performance editor

### Development Essentials
- 🔧 `make` - Build automation
- 🔧 `direnv` - Environment switcher
- 🔧 `watchman` - File watching service
- 🐍 `pre-commit` - Git hook framework
- 🐍 `httpie` - User-friendly HTTP client
- 🐍 `tldr` - Simplified man pages

### Security & Encryption
- 🔧 `gnupg` - GNU Privacy Guard
- 🔧 `openssh` - SSH connectivity
- 🔧 `age` - Modern encryption

### System Monitoring
- 🔧 `htop` - Interactive process viewer
- 🔧 `ncdu` - Disk usage analyzer

### Productivity
- 🖥️ `rectangle` - Window management
- 🖥️ `1password` - Password manager

---

## DevOps Engineer

### Container & Orchestration
- 🔧 `docker-compose` - Multi-container Docker apps
- 🔧 `kubernetes-cli` - Kubernetes command-line tool
- 🔧 `helm` - Kubernetes package manager
- 🔧 `k9s` - Terminal UI for Kubernetes
- 🔧 `kubectx` - Switch between clusters/namespaces
- 🔧 `stern` - Multi-pod log tailing
- 🔧 `kustomize` - Kubernetes native configuration
- 🖥️ `orbstack` - Fast container runtime 🔄
  - Alt: `docker` - Docker Desktop
  - Alt: `podman-desktop` - Open source alternative

### Infrastructure as Code
- 🔧 `terraform` - Infrastructure provisioning
- 🔧 `ansible` - IT automation
- 🔧 `packer` - Machine image builder
- 🔧 `vault` - Secrets management ⚡
- 🔧 `consul` - Service discovery ⚡
- 🔧 `terragrunt` - Terraform wrapper ⚡

### Cloud CLIs
- 🔧 `awscli` - Amazon Web Services CLI ⚡
- 🔧 `azure-cli` - Microsoft Azure CLI ⚡
- 🔧 `google-cloud-sdk` - Google Cloud Platform CLI ⚡
- 🔧 `doctl` - DigitalOcean CLI ⚡

### CI/CD
- 🔧 `act` - Run GitHub Actions locally
- 🔧 `gitlab-runner` - GitLab CI runner ⚡
- 🔧 `circleci` - CircleCI CLI ⚡

### Security Scanning
- 🔧 `trivy` - Container vulnerability scanner
- 🔧 `tfsec` - Terraform security scanner
- 🔧 `gitleaks` - Detect secrets in git repos

### Monitoring (Clients Only)
- 🔧 `promtool` - Prometheus rule checker ⚡
- 🔧 `amtool` - Alertmanager CLI ⚡

### Additional Tools
- 🖥️ `lens` - Kubernetes IDE ⚡
- 🖥️ `postman` - API development platform 🔄
  - Alt: `insomnia` - Lightweight API client
  - Alt: `bruno` - Open-source API client
- 🖥️ `tableplus` - Modern database GUI
- 🖥️ `cyberduck` - Cloud storage browser ⚡
- 🐍 `ansible-lint` - Ansible playbook linter
- 🐍 `aws-sam-cli` - AWS Serverless Application Model CLI ⚡

---

## Full-Stack Developer

### Languages & Runtimes
- 🔧 `node` - JavaScript runtime
- 🔧 `python@3.13` - Python programming language
- 🔧 `go` - Go programming language ⚡
- 🔧 `rust` - Rust programming language ⚡

### Package Managers
- 🔧 `pnpm` - Fast package manager 🔄
  - Alt: `yarn` - Facebook's package manager
- 🔧 `pyenv` - Python version management
- 🔧 `pipx` - Install Python CLI tools
- 🔧 `uv` - Fast Python package installer

### Database Clients
- 🔧 `postgresql@16` - PostgreSQL client tools
- 🔧 `redis` - Redis client and server
- 🔧 `sqlite` - SQLite database

### Development Tools
- 🔧 `docker-compose` - Multi-container applications
- 🔧 `mkcert` - Local HTTPS certificates
- 🔧 `ngrok` - Secure tunnels to localhost ⚡
- 🔧 `grpcurl` - gRPC client ⚡
- 🔧 `websocat` - WebSocket client ⚡

### GUI Applications
- 🖥️ `cursor` - AI-powered code editor 🔄
  - Alt: `visual-studio-code` - Microsoft's editor
  - Alt: `webstorm` - JetBrains JavaScript IDE 💰
- 🖥️ `postman` - API platform 🔄
  - Alt: `insomnia` - REST/GraphQL client
  - Alt: `bruno` - Open-source API client
- 🖥️ `tableplus` - Modern database GUI 🔄
  - Alt: `dbeaver-community` - Free universal database tool
- 🖥️ `github` - GitHub Desktop
- 🖥️ `fork` - Fast git client 🔄
  - Alt: `sourcetree` - Free git GUI

### NPM Packages
- 📦 `typescript` - TypeScript compiler
- 📦 `ts-node` - TypeScript execution
- 📦 `prettier` - Code formatter
- 📦 `eslint` - JavaScript linter
- 📦 `nodemon` - Auto-restart node apps
- 📦 `concurrently` - Run multiple commands
- 📦 `serve` - Static file server
- 📦 `npm-check-updates` - Update package.json

### Python Packages
- 🐍 `poetry` - Python dependency management 🔄
  - Alt: `pipenv` - Python dev workflow
- 🐍 `black` - Python code formatter
- 🐍 `cookiecutter` - Project templates

---

## Backend Developer

### Primary Languages
- 🔧 `python@3.13` - Python programming language
- 🔧 `go` - Go programming language ⚡
- 🔧 `rust` - Rust programming language ⚡
- 🔧 `java` - Java programming language ⚡
- 🔧 `node` - Node.js runtime ⚡

### Language Tools
- 🔧 `pyenv` - Python version management
- 🔧 `pipx` - Python CLI tools
- 🔧 `uv` - Fast Python package manager
- 🔧 `poetry` - Python dependency management

### Database Clients Only
- 🔧 `postgresql@16` - PostgreSQL client tools
- 🔧 `mysql-client` - MySQL client tools ⚡
- 🔧 `redis` - Redis CLI client
- 🔧 `sqlite` - SQLite CLI
- 🔧 `pgcli` - Better PostgreSQL CLI
- 🔧 `mycli` - Better MySQL CLI ⚡
- 🔧 `mongosh` - MongoDB Shell ⚡

### API Development
- 🔧 `httpie` - HTTP client
- 🔧 `grpcurl` - gRPC client
- 🔧 `protobuf` - Protocol buffers ⚡
- 🔧 `wrk` - HTTP benchmarking ⚡
- 🔧 `vegeta` - Load testing tool ⚡

### Container Tools
- 🔧 `docker-compose` - Multi-container Docker apps
- 🔧 `dive` - Docker image explorer ⚡

### GUI Applications
- 🖥️ `tableplus` - Modern database GUI
- 🖥️ `redis-insight` - Redis GUI ⚡
- 🖥️ `postman` - API development platform 🔄
  - Alt: `insomnia` - REST/GraphQL/gRPC client
- 🖥️ `orbstack` - Lightweight Docker runtime

### Python Packages
- 🐍 `black` - Python formatter
- 🐍 `ruff` - Fast Python linter
- 🐍 `mypy` - Static type checker
- 🐍 `pytest` - Testing framework
- 🐍 `tox` - Test automation ⚡
- 🐍 `locust` - Load testing ⚡

---

## Frontend Developer

### Core Runtime
- 🔧 `node` - JavaScript runtime
- 🔧 `pnpm` - Fast package manager 🔄
  - Alt: `yarn` - Alternative package manager

### Build Tools
- 🔧 `watchman` - File watching service
- 🔧 `mkcert` - Local HTTPS certificates

### Image Optimization
- 🔧 `imagemagick` - Image manipulation
- 🔧 `jpegoptim` - JPEG optimizer ⚡
- 🔧 `optipng` - PNG optimizer ⚡
- 🔧 `svgo` - SVG optimizer ⚡

### Browser Testing
- 🔧 `selenium-server` - Browser automation ⚡
- 🔧 `chromedriver` - Chrome automation ⚡

### GUI Applications
- 🖥️ `visual-studio-code` - Primary code editor 🔄
  - Alt: `cursor` - AI-powered VS Code fork
  - Alt: `webstorm` - JetBrains IDE 💰
- 🖥️ `figma` - UI/UX design tool
- 🖥️ `sketch` - Mac design tool ⚡💰
- 🖥️ `postman` - API testing platform 🔄
  - Alt: `insomnia` - Lightweight API client
- 🖥️ `responsively` - Test responsive designs ⚡
- 🖥️ `github` - GitHub Desktop
- 🖥️ `fork` - Git GUI client 🔄
  - Alt: `sourcetree` - Free Git GUI
- 🖥️ `colorsnapper` - Color picker ⚡💰

### NPM Packages
- 📦 `typescript` - TypeScript compiler
- 📦 `prettier` - Code formatter
- 📦 `eslint` - JavaScript linter
- 📦 `stylelint` - CSS linter ⚡
- 📦 `vite` - Next generation frontend tooling
- 📦 `serve` - Static file server
- 📦 `http-server` - Simple HTTP server
- 📦 `browser-sync` - Live-reload dev server ⚡
- 📦 `webpack-cli` - Module bundler CLI ⚡
- 📦 `parcel` - Zero-config build tool ⚡
- 📦 `sass` - CSS preprocessor ⚡
- 📦 `postcss-cli` - CSS transformer ⚡
- 📦 `tailwindcss` - Utility-first CSS ⚡

### Framework CLIs (Optional)
- 📦 `create-react-app` - React app generator ⚡
- 📦 `@angular/cli` - Angular CLI ⚡
- 📦 `@vue/cli` - Vue CLI ⚡
- 📦 `create-next-app` - Next.js generator ⚡
- 📦 `@sveltejs/kit` - SvelteKit CLI ⚡

---

## Network/System Administrator

### Network Analysis
- 🔧 `nmap` - Network discovery and security auditing
- 🔧 `tcpdump` - Packet analyzer
- 🔧 `wireshark` - Network protocol analyzer (CLI)
- 🔧 `arp-scan` - ARP scanner
- 🔧 `masscan` - Fast port scanner ⚡

### Network Utilities
- 🔧 `mtr` - Network diagnostic tool
- 🔧 `iperf3` - Network performance testing
- 🔧 `netcat` - Network utility
- 🔧 `socat` - Multipurpose relay
- 🔧 `ipcalc` - IP subnet calculator
- 🔧 `sipcalc` - Advanced IP calculator

### DNS Tools
- 🔧 `bind` - DNS tools (dig, nslookup)
- 🔧 `dog` - Modern DNS client
- 🔧 `dnsx` - Fast DNS toolkit ⚡

### SSH & Remote Access
- 🔧 `openssh` - SSH client and utilities
- 🔧 `mosh` - Mobile shell
- 🔧 `autossh` - Persistent SSH tunnels
- 🔧 `sshuttle` - SSH-based VPN ⚡

### System Monitoring
- 🔧 `htop` - Process viewer
- 🔧 `btop` - Resource monitor
- 🔧 `iftop` - Network bandwidth monitor
- 🔧 `iotop` - I/O monitor
- 🔧 `bandwhich` - Terminal bandwidth utilization

### Configuration Management
- 🔧 `ansible` - IT automation
- 🔧 `terraform` - Infrastructure as code ⚡

### Cloud CLIs
- 🔧 `awscli` - AWS CLI ⚡
- 🔧 `azure-cli` - Azure CLI ⚡

### GUI Applications
- 🖥️ `wireshark` - Network protocol analyzer GUI
- 🖥️ `angry-ip-scanner` - IP/port scanner ⚡
- 🖥️ `tailscale` - Zero-config VPN
- 🖥️ `viscosity` - OpenVPN client ⚡
- 🖥️ `royal-tsx` - Remote connection manager ⚡
- 🖥️ `iterm2` - Advanced terminal 🔄
  - Alt: `warp` - AI-powered terminal
- 🖥️ `stats` - System monitor menu bar
- 🖥️ `istat-menus` - Advanced system monitoring ⚡💰

### Python Packages
- 🐍 `ansible-lint` - Ansible playbook linter
- 🐍 `netmiko` - Network device automation ⚡
- 🐍 `paramiko` - Python SSH library ⚡

---

## AI/ML Engineer

### Languages
- 🔧 `python@3.13` - Primary ML language
- 🔧 `node` - For JS-based AI tools ⚡

### Python Environment
- 🔧 `pyenv` - Python version management
- 🔧 `pipx` - Python CLI tools
- 🔧 `uv` - Fast package installer

### LLM Tools
- 🔧 `ollama` - Run LLMs locally
- 🔧 `llm` - CLI for LLMs

### Data Processing
- 🔧 `jq` - JSON processor
- 🔧 `yq` - YAML processor
- 🔧 `csvkit` - CSV utilities ⚡

### GPU Support
- 🔧 `metal-cpp` - Apple Metal framework ⚡

### GUI Applications
- 🖥️ `cursor` - AI-powered code editor 🔄
  - Alt: `visual-studio-code` - Standard VS Code
- 🖥️ `lm-studio` - Run LLMs with GUI
- 🖥️ `chatgpt` - Official ChatGPT app ⚡
- 🖥️ `diffusionbee` - Stable Diffusion GUI ⚡
- 🖥️ `jupyter-notebook-viewer` - View Jupyter notebooks ⚡
- 🖥️ `postman` - API development 🔄
  - Alt: `insomnia` - REST client

### Python Packages
- 🐍 `jupyter` - Interactive notebooks
- 🐍 `ipython` - Enhanced Python shell
- 🐍 `poetry` - Dependency management
- 🐍 `black` - Code formatter
- 🐍 `ruff` - Fast linter
- 🐍 `aider-chat` - AI pair programming
- 🐍 `gpt-engineer` - AI code generation
- 🐍 `litellm` - LLM proxy
- 🐍 `langchain-cli` - LangChain CLI

### NPM Packages
- 📦 `@xenova/transformers` - JS transformers ⚡
- 📦 `langchainjs` - LangChain for JS ⚡

---

## Data Engineer

### Languages
- 🔧 `python@3.13` - Primary data language
- 🔧 `scala` - For Spark development ⚡

### Python Tools
- 🔧 `pyenv` - Python version management
- 🔧 `pipx` - Python CLI tools
- 🔧 `poetry` - Dependency management

### Database Clients
- 🔧 `postgresql@16` - PostgreSQL client
- 🔧 `mysql-client` - MySQL client ⚡
- 🔧 `redis` - Redis CLI
- 🔧 `mongosh` - MongoDB shell ⚡
- 🔧 `duckdb` - In-process SQL OLAP
- 🔧 `pgcli` - Better PostgreSQL CLI
- 🔧 `mycli` - Better MySQL CLI ⚡
- 🔧 `litecli` - Better SQLite CLI

### Data Processing
- 🔧 `jq` - JSON processor
- 🔧 `yq` - YAML processor
- 🔧 `csvkit` - CSV tools
- 🔧 `miller` - CSV/JSON processor

### Cloud CLIs
- 🔧 `awscli` - AWS CLI ⚡
- 🔧 `google-cloud-sdk` - GCP CLI ⚡
- 🔧 `azure-cli` - Azure CLI ⚡

### GUI Applications
- 🖥️ `tableplus` - Database GUI
- 🖥️ `dbeaver-community` - Universal DB tool 🔄
  - Alt: `datagrip` - JetBrains DB IDE 💰
- 🖥️ `visual-studio-code` - Code editor
- 🖥️ `pycharm-ce` - Python IDE ⚡

### Python Packages
- 🐍 `dbt-core` - Data build tool
- 🐍 `great-expectations` - Data validation
- 🐍 `apache-airflow` - Workflow orchestration ⚡
- 🐍 `prefect` - Modern dataflow automation ⚡

---

## Security Engineer

### Network Security
- 🔧 `nmap` - Network scanner
- 🔧 `masscan` - Fast port scanner ⚡
- 🔧 `tcpdump` - Packet capture
- 🔧 `arp-scan` - ARP scanner

### Vulnerability Scanning
- 🔧 `trivy` - Container scanner
- 🔧 `grype` - Vulnerability scanner
- 🔧 `gitleaks` - Secret scanner
- 🔧 `trufflehog` - Find secrets

### SAST/Code Analysis
- 🔧 `semgrep` - Static analysis
- 🔧 `tfsec` - Terraform security
- 🔧 `checkov` - IaC scanner
- 🔧 `bandit` - Python security ⚡

### Cryptography
- 🔧 `gnupg` - GPG encryption
- 🔧 `openssl` - Crypto toolkit
- 🔧 `age` - Modern encryption
- 🔧 `sops` - Secrets operator

### Web Security
- 🔧 `httpie` - HTTP client
- 🔧 `nikto` - Web scanner ⚡
- 🔧 `gobuster` - Directory brute-forcer ⚡

### Password Tools
- 🔧 `hashcat` - Password recovery ⚡
- 🔧 `john-jumbo` - John the Ripper ⚡

### GUI Applications
- 🖥️ `wireshark` - Packet analyzer
- 🖥️ `burp-suite-community` - Web security testing ⚡
- 🖥️ `1password` - Password manager
- 🖥️ `gpg-suite` - GPG tools
- 🖥️ `yubico-authenticator` - YubiKey manager
- 🖥️ `tailscale` - Zero-config VPN
- 🖥️ `visual-studio-code` - Code editor

### Python Packages
- 🐍 `prowler` - Cloud security tool ⚡
- 🐍 `scoutsuite` - Cloud security auditing ⚡
- 🐍 `pacu` - AWS exploitation ⚡

---

## Mobile Developer

### iOS Development
- 🔧 `xcodes` - Manage Xcode versions
- 🔧 `cocoapods` - iOS dependency manager
- 🔧 `carthage` - Decentralized dependency manager ⚡
- 🔧 `swiftlint` - Swift linter
- 🔧 `swiftformat` - Swift formatter

### Android Development
- 🔧 `gradle` - Build automation ⚡
- 🔧 `kotlin` - Kotlin language ⚡

### Cross-Platform
- 🔧 `node` - For React Native
- 🔧 `watchman` - File watcher
- 🔧 `flutter` - Flutter SDK ⚡

### Tools
- 🔧 `scrcpy` - Android screen mirror ⚡
- 🔧 `adb-sync` - Android file sync ⚡
- 🔧 `bundletool` - Android App Bundles ⚡

### GUI Applications
- 🖥️ `xcode` - iOS development (Mac App Store)
- 🖥️ `android-studio` - Android development ⚡
- 🖥️ `visual-studio-code` - Code editor
- 🖥️ `simulator` - iOS Simulator
- 🖥️ `react-native-debugger` - React Native debugging ⚡
- 🖥️ `figma` - UI/UX design
- 🖥️ `sketch` - Design tool ⚡💰
- 🖥️ `postman` - API testing 🔄
  - Alt: `insomnia` - REST client
- 🖥️ `imazing` - iOS device manager ⚡💰
- 🖥️ `android-file-transfer` - Android file transfer ⚡

### NPM Packages
- 📦 `react-native-cli` - React Native CLI ⚡
- 📦 `expo-cli` - Expo framework ⚡
- 📦 `eas-cli` - Expo build service ⚡
- 📦 `typescript` - TypeScript support
- 📦 `prettier` - Code formatter
- 📦 `eslint` - JavaScript linter

### Python Packages
- 🐍 `maestro` - Mobile UI testing ⚡

---

## Notes

1. **Tool Selection**: When you see 🔄, you'll be prompted to choose between alternatives during setup
2. **Optional Tools**: Tools marked with ⚡ are optional and can be skipped
3. **Paid Tools**: Tools marked with 💰 require a license or subscription
4. **Client Focus**: Database servers and monitoring systems are not included - use Docker containers instead
5. **Customization**: You can edit role definitions in the `roles/` directory to customize your setup