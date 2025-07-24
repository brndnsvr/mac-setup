#!/bin/bash

# DevOps & Infrastructure Tools Setup Script
# Installs tools for network engineering, systems architecture, and DevOps

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

log_info "Setting up DevOps and infrastructure tools..."

# Infrastructure as Code Tools
log_info "Installing Infrastructure as Code tools..."
IaC_TOOLS=(
    "terraform"               # Infrastructure provisioning
    "terragrunt"              # Terraform wrapper
    "packer"                  # Image building
    "vault"                   # Secrets management
    "consul"                  # Service mesh
    "nomad"                   # Workload orchestration
    "waypoint"                # Application deployment
    "pulumi"                  # Modern IaC
)

for tool in "${IaC_TOOLS[@]}"; do
    if brew list "$tool" &> /dev/null 2>&1; then
        log_success "$tool already installed"
    else
        log_info "Installing $tool..."
        brew install "$tool" || log_warning "Failed to install $tool"
    fi
done

# Kubernetes Tools
log_info "Installing Kubernetes tools..."
K8S_TOOLS=(
    "kubernetes-cli"          # kubectl
    "helm"                    # Package manager for K8s
    "k9s"                     # Terminal UI for K8s
    "kubectx"                 # Switch between contexts
    "kustomize"               # K8s configuration
    "stern"                   # Multi-pod log tailing
    "kubeseal"                # Sealed Secrets
    "velero"                  # Backup and migrate
    "argocd"                  # GitOps CD
    "flux"                    # GitOps toolkit
    "linkerd"                 # Service mesh CLI
    "istioctl"                # Istio service mesh
)

for tool in "${K8S_TOOLS[@]}"; do
    if brew list "$tool" &> /dev/null 2>&1; then
        log_success "$tool already installed"
    else
        log_info "Installing $tool..."
        brew install "$tool" || log_warning "Failed to install $tool"
    fi
done

# Container Tools
log_info "Installing container tools..."
CONTAINER_TOOLS=(
    "podman"                  # Docker alternative
    "buildah"                 # Container building
    "skopeo"                  # Container image operations
    "dive"                    # Docker image explorer
    "lazydocker"              # Terminal UI for Docker
    "ctop"                    # Container metrics
    "docker-compose"          # Multi-container apps
    "docker-credential-helper" # Credential management
)

for tool in "${CONTAINER_TOOLS[@]}"; do
    if brew list "$tool" &> /dev/null 2>&1; then
        log_success "$tool already installed"
    else
        log_info "Installing $tool..."
        brew install "$tool" || log_warning "Failed to install $tool"
    fi
done

# Cloud Provider CLIs
log_info "Installing cloud provider tools..."
CLOUD_TOOLS=(
    "awscli"                  # AWS CLI
    "azure-cli"               # Azure CLI
    "doctl"                   # DigitalOcean CLI
    "linode-cli"              # Linode CLI
    "vultr"                   # Vultr CLI
    "oci-cli"                 # Oracle Cloud CLI
)

for tool in "${CLOUD_TOOLS[@]}"; do
    if brew list "$tool" &> /dev/null 2>&1; then
        log_success "$tool already installed"
    else
        log_info "Installing $tool..."
        brew install "$tool" || log_warning "Failed to install $tool"
    fi
done

# Monitoring & Observability
log_info "Installing monitoring tools..."
MONITORING_TOOLS=(
    "prometheus"              # Monitoring system
    "grafana"                 # Visualization
    "alertmanager"            # Alert handling
    "node_exporter"           # Hardware metrics
    "loki"                    # Log aggregation
    "promtail"                # Log collector
    "telegraf"                # Metrics collector
)

for tool in "${MONITORING_TOOLS[@]}"; do
    if brew list "$tool" &> /dev/null 2>&1; then
        log_success "$tool already installed"
    else
        log_info "Installing $tool..."
        brew install "$tool" || log_warning "Failed to install $tool"
    fi
done

# Network Engineering Tools
log_info "Installing network engineering tools..."
NETWORK_TOOLS=(
    "nmap"                    # Network scanner
    "tcpdump"                 # Packet analyzer
    "mtr"                     # Network diagnostic
    "iperf3"                  # Network performance
    "netcat"                  # Network utility
    "socat"                   # Socket utility
    "tcptraceroute"           # TCP traceroute
    "bandwhich"               # Bandwidth utilization
    "gping"                   # Ping with graph
    "dog"                     # DNS client
    "dnsx"                    # DNS toolkit
    "httpie"                  # HTTP client
    "curlie"                  # curl + httpie
    "grpcurl"                 # gRPC client
    "websocat"                # WebSocket client
)

for tool in "${NETWORK_TOOLS[@]}"; do
    if brew list "$tool" &> /dev/null 2>&1; then
        log_success "$tool already installed"
    else
        log_info "Installing $tool..."
        brew install "$tool" || log_warning "Failed to install $tool"
    fi
done

# CI/CD Tools
log_info "Installing CI/CD tools..."
CICD_TOOLS=(
    "circleci"                # CircleCI CLI
    "travis"                  # Travis CI CLI
    "gitlab-runner"           # GitLab Runner
    "buildkite-agent"         # Buildkite Agent
    "drone-cli"               # Drone CLI
    "jenkins"                 # Jenkins
    "act"                     # Run GitHub Actions locally
)

for tool in "${CICD_TOOLS[@]}"; do
    if brew list "$tool" &> /dev/null 2>&1; then
        log_success "$tool already installed"
    else
        log_info "Installing $tool..."
        brew install "$tool" || log_warning "Failed to install $tool"
    fi
done

# Security & Compliance Tools
log_info "Installing security tools..."
SECURITY_TOOLS=(
    "trivy"                   # Vulnerability scanner
    "grype"                   # Vulnerability scanner
    "syft"                    # SBOM generator
    "cosign"                  # Container signing
    "tfsec"                   # Terraform security scanner
    "checkov"                 # IaC security scanner
    "kubescape"               # K8s security scanner
    "falco"                   # Runtime security
    "opa"                     # Open Policy Agent
)

for tool in "${SECURITY_TOOLS[@]}"; do
    if brew list "$tool" &> /dev/null 2>&1; then
        log_success "$tool already installed"
    else
        log_info "Installing $tool..."
        brew install "$tool" || log_warning "Failed to install $tool"
    fi
done

# Database Tools
log_info "Installing database tools..."
DB_TOOLS=(
    "postgresql@14"           # PostgreSQL
    "mysql"                   # MySQL
    "redis"                   # Redis
    "mongodb-community"       # MongoDB
    "cassandra"               # Cassandra
    "sqlite"                  # SQLite
    "pgcli"                   # PostgreSQL CLI
    "mycli"                   # MySQL CLI
    "litecli"                 # SQLite CLI
)

# First tap MongoDB
brew tap mongodb/brew || true

for tool in "${DB_TOOLS[@]}"; do
    if brew list "$tool" &> /dev/null 2>&1; then
        log_success "$tool already installed"
    else
        log_info "Installing $tool..."
        brew install "$tool" || log_warning "Failed to install $tool"
    fi
done

# Install Python DevOps packages
log_info "Installing Python DevOps packages..."
if command -v pip3 &> /dev/null; then
    PYTHON_DEVOPS=(
        "ansible"                 # Already installed via brew, but getting latest
        "ansible-lint"            # Ansible linting
        "molecule"                # Ansible testing
        "testinfra"               # Infrastructure testing
        "pexpect"                 # Expect for Python
        "netmiko"                 # Network device automation
        "napalm"                  # Network automation
        "nornir"                  # Network automation framework
        "paramiko"                # SSH client
        "fabric"                  # Remote execution
        "invoke"                  # Task execution
        "supervisor"              # Process control
        "locust"                  # Load testing
    )
    
    for package in "${PYTHON_DEVOPS[@]}"; do
        log_info "Installing Python package: $package..."
        pip3 install --user "$package" || log_warning "Failed to install $package"
    done
fi

# Create DevOps helper scripts
log_info "Creating DevOps helper scripts..."

# Kubernetes context switcher
cat > "$HOME/bin/kube-switch" << 'EOF'
#!/bin/bash
# Quick Kubernetes context switcher

if [ $# -eq 0 ]; then
    echo "Current context: $(kubectl config current-context)"
    echo ""
    echo "Available contexts:"
    kubectl config get-contexts -o name | nl -v 0
    echo ""
    echo "Usage: kube-switch <number|name>"
else
    if [[ $1 =~ ^[0-9]+$ ]]; then
        # Switch by number
        context=$(kubectl config get-contexts -o name | sed -n "$((${1}+1))p")
    else
        # Switch by name
        context=$1
    fi
    
    if [ -n "$context" ]; then
        kubectl config use-context "$context"
        echo "Switched to context: $context"
    else
        echo "Context not found"
    fi
fi
EOF
chmod +x "$HOME/bin/kube-switch"

# Docker cleanup script
cat > "$HOME/bin/docker-nuke" << 'EOF'
#!/bin/bash
# Nuclear option for Docker cleanup

echo "WARNING: This will remove ALL Docker containers, images, volumes, and networks!"
read -p "Are you sure? (yes/no) " -r
if [[ $REPLY == "yes" ]]; then
    echo "Stopping all containers..."
    docker stop $(docker ps -aq) 2>/dev/null
    
    echo "Removing all containers..."
    docker rm $(docker ps -aq) 2>/dev/null
    
    echo "Removing all images..."
    docker rmi $(docker images -q) 2>/dev/null
    
    echo "Removing all volumes..."
    docker volume rm $(docker volume ls -q) 2>/dev/null
    
    echo "Removing all networks..."
    docker network rm $(docker network ls -q) 2>/dev/null
    
    echo "Running system prune..."
    docker system prune -af --volumes
    
    echo "Docker has been nuked!"
else
    echo "Cancelled"
fi
EOF
chmod +x "$HOME/bin/docker-nuke"

# AWS profile switcher
cat > "$HOME/bin/aws-switch" << 'EOF'
#!/bin/bash
# Quick AWS profile switcher

if [ $# -eq 0 ]; then
    echo "Current profile: ${AWS_PROFILE:-default}"
    echo ""
    echo "Available profiles:"
    grep '^\[' ~/.aws/config | grep -v default | sed 's/\[profile //g' | sed 's/\]//g' | nl -v 0
    echo ""
    echo "Usage: aws-switch <number|name>"
else
    if [[ $1 =~ ^[0-9]+$ ]]; then
        # Switch by number
        profile=$(grep '^\[' ~/.aws/config | grep -v default | sed 's/\[profile //g' | sed 's/\]//g' | sed -n "$((${1}+1))p")
    else
        # Switch by name
        profile=$1
    fi
    
    if [ -n "$profile" ]; then
        export AWS_PROFILE="$profile"
        echo "Switched to AWS profile: $profile"
        echo "Run 'export AWS_PROFILE=$profile' to persist in current shell"
    else
        echo "Profile not found"
    fi
fi
EOF
chmod +x "$HOME/bin/aws-switch"

# Create Terraform helper
cat > "$HOME/bin/tf-init" << 'EOF'
#!/bin/bash
# Terraform initialization helper

echo "Initializing Terraform with common options..."
terraform init -upgrade -reconfigure

if [ -f "terraform.tfvars" ]; then
    echo "Found terraform.tfvars"
else
    echo "No terraform.tfvars found. Creating template..."
    cat > terraform.tfvars.example << TFVARS
# Example Terraform variables
# Copy to terraform.tfvars and fill in values

# region = "us-east-1"
# environment = "dev"
TFVARS
fi

echo ""
echo "Terraform initialized. Common commands:"
echo "  terraform plan"
echo "  terraform apply"
echo "  terraform destroy"
EOF
chmod +x "$HOME/bin/tf-init"

# Create infrastructure testing script
cat > "$HOME/bin/infra-test" << 'EOF'
#!/bin/bash
# Run infrastructure tests

if [ -f "molecule.yml" ]; then
    echo "Running Molecule tests..."
    molecule test
elif [ -f "terratest" ] || [ -d "test" ]; then
    echo "Running Terratest..."
    go test -v ./test/...
elif [ -f "pytest.ini" ] || [ -f "tests/test_*.py" ]; then
    echo "Running pytest..."
    pytest -v
elif [ -f "Makefile" ] && grep -q "test:" Makefile; then
    echo "Running make test..."
    make test
else
    echo "No test framework detected"
    echo "Supported: Molecule, Terratest, pytest, Makefile"
fi
EOF
chmod +x "$HOME/bin/infra-test"

# Set up configuration files
log_info "Creating DevOps configuration templates..."

# Ansible configuration
mkdir -p "$HOME/.ansible"
cat > "$HOME/.ansible.cfg" << 'EOF'
[defaults]
host_key_checking = False
retry_files_enabled = False
ansible_managed = Ansible managed
interpreter_python = auto_silent
stdout_callback = yaml
callback_whitelist = timer, profile_tasks
gathering = smart
fact_caching = jsonfile
fact_caching_connection = ~/.ansible/cache
fact_caching_timeout = 86400

[ssh_connection]
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
ssh_args = -o ControlMaster=auto -o ControlPersist=60s

[colors]
highlight = bright blue
verbose = blue
warn = bright purple
error = red
debug = dark gray
deprecate = purple
skip = cyan
unreachable = bright red
ok = green
changed = yellow
diff_add = green
diff_remove = red
diff_lines = cyan
EOF

# Terraform configuration
mkdir -p "$HOME/.terraform.d"
cat > "$HOME/.terraform.d/plugin-cache.tf" << 'EOF'
# Enable plugin caching
plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
EOF

# Create kubectl aliases
cat >> "$HOME/.zsh/aliases.zsh" << 'EOF'

# Kubernetes aliases
alias k='kubectl'
alias kga='kubectl get all'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'
alias kdn='kubectl describe node'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias ke='kubectl exec -it'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kctx='kubectx'
alias kns='kubens'
alias ks='kube-switch'

# Docker aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dl='docker logs'
alias dlf='docker logs -f'
alias dcp='docker-compose'
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dclogs='docker-compose logs -f'

# Terraform aliases
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tff='terraform fmt -recursive'

# AWS aliases
alias awsw='aws-switch'
alias awsp='echo $AWS_PROFILE'
EOF

log_success "DevOps and infrastructure tools setup complete!"
log_info "Installed:"
echo "  - Infrastructure as Code: Terraform, Packer, Pulumi"
echo "  - Kubernetes: kubectl, Helm, k9s, ArgoCD, Flux"
echo "  - Containers: Docker tools, Podman, Buildah"
echo "  - Cloud CLIs: AWS, Azure, GCP, DigitalOcean"
echo "  - Monitoring: Prometheus, Grafana, Loki"
echo "  - Network tools: nmap, mtr, iperf3, bandwhich"
echo "  - Security: Trivy, Checkov, Falco, OPA"
echo "  - CI/CD: Various CI platform CLIs"

log_info "Helper scripts created:"
echo "  - kube-switch: Quick Kubernetes context switching"
echo "  - docker-nuke: Complete Docker cleanup"
echo "  - aws-switch: AWS profile switching"
echo "  - tf-init: Terraform initialization helper"
echo "  - infra-test: Infrastructure testing runner"

log_info "Quick tips:"
echo "  - Use 'k' as alias for kubectl"
echo "  - Use 'tf' as alias for terraform"
echo "  - Run 'dev-help' for command reference"
echo "  - Check ~/.ansible.cfg for Ansible configuration"