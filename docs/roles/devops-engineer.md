# DevOps Engineer Guide

## Overview

As a DevOps Engineer, you bridge the gap between development and operations, focusing on automation, infrastructure as code, continuous integration/deployment, and cloud platforms. This role setup provides you with modern tools for container orchestration, infrastructure management, and deployment automation.

## Tools Installed

### Container & Orchestration
- **docker-compose** - Multi-container Docker application management
- **kubernetes-cli (kubectl)** - Kubernetes command-line tool
- **helm** - Kubernetes package manager
- **k9s** - Terminal UI for Kubernetes
- **kubectx** - Switch between Kubernetes contexts
- **stern** - Multi-pod log tailing
- **kustomize** - Kubernetes native configuration management

### Infrastructure as Code
- **terraform** - Infrastructure provisioning and management
- **ansible** - IT automation and configuration management
- **packer** - Machine image builder
- **vault** (optional) - Secrets management
- **consul** (optional) - Service discovery and configuration

### Cloud CLIs
- **awscli** - Amazon Web Services CLI
- **azure-cli** - Microsoft Azure CLI
- **google-cloud-sdk** - Google Cloud Platform CLI
- **doctl** - DigitalOcean CLI

### CI/CD Tools
- **act** - Run GitHub Actions locally
- **gitlab-runner** - GitLab CI runner
- **circleci** - CircleCI CLI

### Security & Monitoring
- **trivy** - Container vulnerability scanner
- **tfsec** - Terraform security scanner
- **gitleaks** - Detect secrets in git repos

## Getting Started

### 1. Container Runtime Setup
```bash
# Install Docker Desktop or OrbStack
# OrbStack is lighter and faster for Mac
brew install --cask orbstack

# Verify Docker is running
docker version
docker-compose version
```

### 2. Kubernetes Configuration
```bash
# Set up kubectl aliases (already configured)
k version  # Short for kubectl version

# Configure your first cluster
# For local development
k3d cluster create dev-cluster

# For cloud clusters
aws eks update-kubeconfig --name my-cluster
gcloud container clusters get-credentials my-cluster
az aks get-credentials --resource-group myRG --name myCluster
```

### 3. Cloud Authentication
```bash
# AWS
aws configure
aws sso login  # For SSO

# Google Cloud
gcloud auth login
gcloud config set project PROJECT_ID

# Azure
az login
az account set --subscription SUBSCRIPTION_ID
```

### 4. Terraform Setup
```bash
# Initialize Terraform for a project
cd my-infrastructure
terraform init

# Set up Terraform Cloud (optional)
terraform login
```

## Common Workflows

### Container Management
```bash
# Build and run containers
docker-compose up -d
docker-compose logs -f
docker-compose down

# Kubernetes deployments
k apply -f deployment.yaml
k get pods
k logs -f deployment/my-app
k exec -it pod-name -- /bin/bash

# Using Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/nginx
helm list
helm upgrade my-release bitnami/nginx
```

### Infrastructure as Code
```bash
# Terraform workflow
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform destroy

# Ansible playbooks
ansible-playbook -i inventory.yml site.yml --check
ansible-playbook -i inventory.yml site.yml
ansible-vault encrypt secrets.yml
```

### CI/CD Pipeline Testing
```bash
# Test GitHub Actions locally
act push
act -j test
act -s GITHUB_TOKEN=$GITHUB_TOKEN

# GitLab CI
gitlab-runner exec docker test-job
```

### Security Scanning
```bash
# Scan containers
trivy image myapp:latest
trivy fs .

# Scan Terraform
tfsec .
terraform plan -out=tfplan
terraform show -json tfplan | tfsec

# Check for secrets
gitleaks detect
gitleaks protect --staged
```

## Best Practices

### 1. Infrastructure as Code
- **Version Control Everything**: All infrastructure should be in Git
- **Use Modules**: Create reusable Terraform modules
- **Environment Separation**: Separate configs for dev/staging/prod
- **State Management**: Use remote state (S3, Terraform Cloud)

### 2. Container Best Practices
- **Small Images**: Use alpine or distroless base images
- **Multi-stage Builds**: Reduce final image size
- **Security Scanning**: Scan all images before deployment
- **Resource Limits**: Always set CPU/memory limits

### 3. Kubernetes Guidelines
- **Namespaces**: Use namespaces for environment separation
- **Resource Quotas**: Set quotas to prevent resource exhaustion
- **Health Checks**: Always define liveness and readiness probes
- **Secrets Management**: Use external secrets operators

### 4. CI/CD Principles
- **Fail Fast**: Run quick tests first
- **Parallel Execution**: Run independent jobs in parallel
- **Artifact Caching**: Cache dependencies and build artifacts
- **Rollback Strategy**: Always have a rollback plan

### 5. Security First
- **Least Privilege**: Minimal permissions for all resources
- **Secrets Rotation**: Regularly rotate credentials
- **Audit Logging**: Enable audit logs for all services
- **Compliance Scanning**: Regular compliance checks

## Aliases and Shortcuts

Your shell is configured with these helpful aliases:
```bash
k         # kubectl
tf        # terraform
tfa       # terraform apply
tfp       # terraform plan
kctx      # kubectx (switch contexts)
kns       # kubens (switch namespaces)
dcp       # docker-compose
```

## Learning Resources

### Official Documentation
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Ansible Documentation](https://docs.ansible.com/)

### Tutorials and Courses
- [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
- [Terraform Up & Running](https://www.terraformupandrunning.com/)
- [Docker Mastery](https://www.udemy.com/course/docker-mastery/)
- [Linux Academy DevOps Path](https://linuxacademy.com/devops)

### Communities
- [DevOps Subreddit](https://reddit.com/r/devops)
- [CNCF Slack](https://slack.cncf.io/)
- [HashiCorp Community](https://discuss.hashicorp.com/)
- [Kubernetes Slack](https://kubernetes.slack.com/)

### Blogs and Newsletters
- [DevOps Weekly](https://www.devopsweekly.com/)
- [KubeWeekly](https://kubeweekly.io/)
- [HashiCorp Blog](https://www.hashicorp.com/blog)
- [Docker Blog](https://www.docker.com/blog/)

## Troubleshooting

### Common Issues

#### Docker daemon not running
```bash
# Check Docker status
docker version

# Start Docker Desktop or OrbStack
open -a OrbStack
```

#### Kubernetes context issues
```bash
# List contexts
kubectl config get-contexts

# Switch context
kubectl config use-context my-context

# Fix kubeconfig
export KUBECONFIG=~/.kube/config
```

#### Terraform state lock
```bash
# Force unlock (use carefully)
terraform force-unlock LOCK_ID

# Check who has the lock
terraform show
```

#### Permission denied errors
```bash
# AWS credentials
aws configure list
aws sts get-caller-identity

# Fix Docker permissions
sudo usermod -aG docker $USER
newgrp docker
```

## Next Steps

1. **Set up a local Kubernetes cluster** for development
2. **Create your first Terraform module** for common infrastructure
3. **Build a CI/CD pipeline** for a sample application
4. **Implement GitOps** with Flux or ArgoCD
5. **Learn service mesh** with Istio or Linkerd

Remember: DevOps is about culture as much as tools. Focus on automation, collaboration, and continuous improvement!