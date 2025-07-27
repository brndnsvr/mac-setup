# Project Templates

This directory contains boilerplate templates for quickly starting new projects based on your role and technology stack.

## Available Templates

### Backend
- `python-api/` - FastAPI/Flask REST API template
- `go-service/` - Go microservice template
- `node-api/` - Express.js API template

### Frontend
- `react-app/` - React with TypeScript template
- `vue-app/` - Vue 3 with TypeScript template
- `next-app/` - Next.js full-stack template

### Full-Stack
- `mern-stack/` - MongoDB, Express, React, Node.js
- `t3-stack/` - TypeScript, tRPC, Tailwind, Prisma

### Mobile
- `react-native/` - React Native with TypeScript
- `flutter-app/` - Flutter mobile app

### DevOps
- `terraform-aws/` - AWS infrastructure template
- `k8s-helm/` - Kubernetes Helm chart template
- `docker-compose/` - Multi-container Docker setup

### AI/ML
- `ml-project/` - Python ML project structure
- `llm-app/` - LangChain application template

### Blockchain
- `smart-contract/` - Solidity smart contract template
- `web3-dapp/` - Web3 decentralized app template

## Usage

Copy a template to start a new project:

```bash
# Copy template to new location
cp -r ~/mac-setup/templates/python-api ~/projects/my-new-api

# Or use the new-project command (after running shell-config.sh)
new-project my-api python-api
```

## Template Structure

Each template includes:
- Proper project structure
- Configuration files
- Basic CI/CD setup
- README with instructions
- Example code
- Testing setup
- Linting/formatting config