#!/bin/bash

# AI & LLM Tools Setup Script
# Installs tools for AI development, LLMs, and machine learning

set -euo pipefail

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common functions
source "${SCRIPT_DIR}/common.sh"

log_info "Setting up AI and LLM development tools..."

# LLM Runtimes and Servers
log_info "Installing LLM runtimes and servers..."
LLM_RUNTIMES=(
    "ollama"                    # Run large language models locally
    "llm"                       # Access LLMs from the command line
)

for tool in "${LLM_RUNTIMES[@]}"; do
    safe_brew_install "$tool"
done

# AI Development Tools
log_info "Installing AI development tools..."
AI_DEV_TOOLS=(
    "openai-whisper"            # OpenAI's Whisper speech recognition
    "tesseract"                 # OCR engine (already in brew-packages.txt)
    "ffmpeg"                    # Media processing (already installed, needed for whisper)
)

for tool in "${AI_DEV_TOOLS[@]}"; do
    if [[ "$tool" != "tesseract" && "$tool" != "ffmpeg" ]]; then
        safe_brew_install "$tool"
    else
        log_success "$tool already handled by brew-packages.txt"
    fi
done

# Python AI/ML packages via pipx (CLI tools)
log_info "Installing AI/ML CLI tools via pipx..."
if command -v pipx &> /dev/null; then
    AI_CLI_TOOLS=(
        "gpt-engineer"          # AI-powered code generation
        "aider-chat"            # AI pair programming in terminal
        "litellm"               # Use any LLM as a drop-in replacement for GPT
        "langchain-cli"         # LangChain command line interface
    )
    
    for tool in "${AI_CLI_TOOLS[@]}"; do
        if pipx list | grep -q "$tool"; then
            log_success "$tool already installed via pipx"
        else
            log_info "Installing $tool via pipx..."
            pipx install "$tool" || log_warning "Failed to install $tool"
        fi
    done
else
    log_warning "pipx not found - please install it first"
fi

# Create Python requirements for AI/ML libraries
log_info "Creating AI/ML Python requirements file..."
cat > "$HOME/.mac-setup-ai-ml-libs.txt" << 'EOF'
# AI/ML Python libraries
# Install these in a virtual environment:
# python3 -m venv ai-env
# source ai-env/bin/activate
# pip install -r ~/.mac-setup-ai-ml-libs.txt

# Core ML Frameworks
torch                   # PyTorch deep learning framework
tensorflow             # TensorFlow ML framework
transformers           # Hugging Face transformers
datasets               # Hugging Face datasets

# LLM Libraries
langchain              # Building applications with LLMs
langchain-community    # Community integrations
llama-index           # Data framework for LLMs
openai                # OpenAI API client
anthropic             # Anthropic (Claude) API client
google-generativeai   # Google AI API client
cohere                # Cohere API client

# Vector Databases & Embeddings
chromadb              # Vector database
faiss-cpu             # Facebook AI similarity search
sentence-transformers # Sentence embeddings
tiktoken              # OpenAI's tokenizer

# ML Tools & Utilities
scikit-learn          # Traditional ML algorithms
pandas                # Data manipulation
numpy                 # Numerical computing
matplotlib            # Plotting
seaborn              # Statistical visualization
jupyterlab            # Interactive notebooks
gradio                # ML model demos
streamlit             # ML apps

# Computer Vision
opencv-python         # Computer vision library
pillow               # Image processing

# NLP Tools
nltk                 # Natural language toolkit
spacy                # Advanced NLP
textblob             # Simple NLP tasks

# Audio Processing
soundfile            # Audio file I/O
librosa              # Audio analysis
pydub                # Audio manipulation
EOF

log_info "AI/ML Python libraries saved to ~/.mac-setup-ai-ml-libs.txt"

# Node.js AI packages
log_info "Installing Node.js AI packages..."
if command -v npm &> /dev/null; then
    NPM_AI_PACKAGES=(
        "@xenova/transformers"      # Run transformers in browser/node
        "langchainjs"               # LangChain for JavaScript
    )
    
    for package in "${NPM_AI_PACKAGES[@]}"; do
        if npm list -g --depth=0 2>/dev/null | grep -q "$package"; then
            log_success "$package already installed globally"
        else
            log_info "Installing $package..."
            npm install -g "$package" || log_warning "Failed to install $package"
        fi
    done
else
    log_warning "npm not found - skipping Node.js AI packages"
fi

# Create AI tools configuration
log_info "Creating AI tools configuration..."
mkdir -p "$HOME/.config/ai-tools"

# Create Ollama model pulling script
cat > "$HOME/bin/ollama-setup" << 'EOF'
#!/bin/bash
# Ollama Model Setup Script

echo "Setting up Ollama models..."

# Start Ollama service if not running
if ! pgrep -x "ollama" > /dev/null; then
    echo "Starting Ollama service..."
    ollama serve &
    sleep 5
fi

# Popular models to pull
MODELS=(
    "llama3.2"          # Latest Llama 3.2
    "mistral"           # Mistral 7B
    "codellama"         # Code-focused model
    "phi3"              # Microsoft's Phi-3
    "gemma2"            # Google's Gemma 2
    "qwen2.5-coder"     # Coding-focused model
)

echo "Available models to pull:"
for i in "${!MODELS[@]}"; do
    echo "  $((i+1))) ${MODELS[$i]}"
done
echo "  a) All models"
echo "  s) Skip"

read -p "Select models to pull (space-separated numbers, 'a' for all, or 's' to skip): " -r
if [[ "$REPLY" == "a" ]]; then
    for model in "${MODELS[@]}"; do
        echo "Pulling $model..."
        ollama pull "$model"
    done
elif [[ "$REPLY" != "s" ]]; then
    for num in $REPLY; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#MODELS[@]}" ]; then
            model="${MODELS[$((num-1))]}"
            echo "Pulling $model..."
            ollama pull "$model"
        fi
    done
fi

echo "Ollama setup complete!"
echo "Run 'ollama list' to see installed models"
echo "Run 'ollama run <model>' to start chatting"
EOF

chmod +x "$HOME/bin/ollama-setup"

# Create LLM CLI configuration
cat > "$HOME/.config/ai-tools/llm-config.yaml" << 'EOF'
# LLM CLI Configuration
# See: https://llm.datasette.io/

# Default model settings
default_model: gpt-4-turbo-preview

# Model aliases for easier access
aliases:
  gpt4: gpt-4-turbo-preview
  gpt3: gpt-3.5-turbo
  claude: claude-3-opus-20240229
  ollama-llama: ollama/llama3.2
  ollama-mistral: ollama/mistral
  ollama-code: ollama/codellama

# Plugins to install (run: llm install <plugin>)
recommended_plugins:
  - llm-ollama           # Use Ollama models
  - llm-claude-3         # Use Anthropic Claude
  - llm-gemini          # Use Google Gemini
  - llm-mistral         # Use Mistral models
EOF

# Create AI project template
cat > "$HOME/bin/new-ai-project" << 'EOF'
#!/bin/bash
# Create a new AI/ML project with common structure

if [ -z "$1" ]; then
    echo "Usage: new-ai-project <project-name> [project-type]"
    echo "Types: llm, ml, cv, nlp, general (default)"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_TYPE="${2:-general}"

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Create project structure
mkdir -p {data,models,notebooks,src,tests,docs}

# Create .gitignore
cat > .gitignore << 'GITIGNORE'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
venv/
env/
.env

# Data & Models
data/*
!data/.gitkeep
models/*
!models/.gitkeep
*.h5
*.pkl
*.pth
*.onnx

# Jupyter
.ipynb_checkpoints/
*.ipynb_checkpoints

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# API Keys
.env
config/secrets.yaml
GITIGNORE

# Create .env template
cat > .env.example << 'ENV'
# API Keys
OPENAI_API_KEY=your_key_here
ANTHROPIC_API_KEY=your_key_here
HUGGINGFACE_TOKEN=your_token_here

# Model Settings
MODEL_NAME=gpt-4-turbo-preview
TEMPERATURE=0.7
MAX_TOKENS=2000

# Vector DB
CHROMA_PERSIST_DIRECTORY=./chroma_db
ENV

# Create requirements.txt based on project type
case "$PROJECT_TYPE" in
    llm)
        cat > requirements.txt << 'REQ'
langchain>=0.1.0
langchain-community
openai>=1.0.0
anthropic>=0.18.0
chromadb>=0.4.0
tiktoken>=0.5.0
python-dotenv>=1.0.0
gradio>=4.0.0
streamlit>=1.29.0
REQ
        ;;
    ml)
        cat > requirements.txt << 'REQ'
scikit-learn>=1.3.0
pandas>=2.0.0
numpy>=1.24.0
matplotlib>=3.7.0
seaborn>=0.12.0
joblib>=1.3.0
xgboost>=2.0.0
lightgbm>=4.0.0
python-dotenv>=1.0.0
jupyterlab>=4.0.0
REQ
        ;;
    cv)
        cat > requirements.txt << 'REQ'
torch>=2.0.0
torchvision>=0.15.0
opencv-python>=4.8.0
pillow>=10.0.0
albumentations>=1.3.0
ultralytics>=8.0.0
python-dotenv>=1.0.0
jupyterlab>=4.0.0
REQ
        ;;
    nlp)
        cat > requirements.txt << 'REQ'
transformers>=4.35.0
torch>=2.0.0
datasets>=2.14.0
tokenizers>=0.15.0
spacy>=3.6.0
nltk>=3.8.0
python-dotenv>=1.0.0
jupyterlab>=4.0.0
REQ
        ;;
    *)
        cat > requirements.txt << 'REQ'
numpy>=1.24.0
pandas>=2.0.0
matplotlib>=3.7.0
jupyterlab>=4.0.0
python-dotenv>=1.0.0
requests>=2.31.0
REQ
        ;;
esac

# Create README
cat > README.md << README
# $PROJECT_NAME

AI/ML project created with new-ai-project.

## Setup

1. Activate virtual environment:
   \`\`\`bash
   source venv/bin/activate
   \`\`\`

2. Install dependencies:
   \`\`\`bash
   pip install -r requirements.txt
   \`\`\`

3. Copy .env.example to .env and add your API keys:
   \`\`\`bash
   cp .env.example .env
   \`\`\`

## Project Structure

- \`data/\` - Dataset storage
- \`models/\` - Trained model storage
- \`notebooks/\` - Jupyter notebooks
- \`src/\` - Source code
- \`tests/\` - Unit tests
- \`docs/\` - Documentation

## Usage

[Add usage instructions here]
README

# Create .gitkeep files
touch data/.gitkeep models/.gitkeep notebooks/.gitkeep src/.gitkeep tests/.gitkeep docs/.gitkeep

# Create a sample notebook
cat > notebooks/01_exploration.ipynb << 'NOTEBOOK'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Data Exploration\n",
    "\n",
    "This notebook is for initial data exploration and analysis."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import numpy as np\n",
    "import pandas as pd\n",
    "import matplotlib.pyplot as plt\n",
    "import seaborn as sns\n",
    "\n",
    "# Set style\n",
    "plt.style.use('seaborn-v0_8-darkgrid')\n",
    "sns.set_palette('husl')"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
NOTEBOOK

echo "AI/ML project '$PROJECT_NAME' created successfully!"
echo ""
echo "Next steps:"
echo "1. cd $PROJECT_NAME"
echo "2. source venv/bin/activate"
echo "3. pip install -r requirements.txt"
echo "4. cp .env.example .env && edit .env"
echo ""
echo "To start Jupyter Lab: jupyter lab"
GITIGNORE

chmod +x "$HOME/bin/new-ai-project"

# Create quick reference
cat > "$HOME/.ai-tools-help.md" << 'EOF'
# AI/LLM Tools Quick Reference

## Ollama (Local LLMs)

```bash
# First-time setup
ollama-setup              # Pull popular models

# Basic usage
ollama list              # List installed models
ollama run llama3.2      # Start chat with Llama 3.2
ollama run codellama     # Start chat with CodeLlama
ollama serve             # Start Ollama server (auto-starts with run)

# Model management
ollama pull <model>      # Download a model
ollama rm <model>        # Remove a model
ollama show <model>      # Show model information
```

## LLM CLI Tool

```bash
# Setup (add your API keys)
llm keys set openai
llm keys set anthropic

# Basic usage
llm "Your prompt here"                    # Use default model
llm -m gpt4 "Your prompt"                # Use specific model
llm -m ollama/llama3.2 "Your prompt"     # Use Ollama model
cat file.py | llm "Explain this code"    # Pipe input
llm -c "Continue our conversation"        # Continue previous chat

# Install plugins
llm install llm-ollama     # For Ollama support
llm install llm-claude-3   # For Claude support
```

## AI Project Creation

```bash
# Create new AI projects
new-ai-project my-llm-app llm      # LangChain project
new-ai-project my-ml-app ml        # Scikit-learn project  
new-ai-project my-cv-app cv        # Computer vision project
new-ai-project my-nlp-app nlp      # NLP project
new-ai-project my-ai-app           # General AI project
```

## Python AI/ML Tools

```bash
# Activate AI environment
python3 -m venv ai-env
source ai-env/bin/activate
pip install -r ~/.mac-setup-ai-ml-libs.txt

# Or install specific tools
pip install langchain openai chromadb
pip install torch transformers
```

## CLI AI Tools

```bash
# AI pair programming
aider                    # Start AI coding assistant

# GPT Engineer
gpt-engineer            # AI-powered code generation

# LiteLLM proxy
litellm --model ollama/llama3.2    # Proxy any LLM as OpenAI
```

## Quick LLM Interactions

```bash
# Code explanation
cat script.py | llm "Explain this code and suggest improvements"

# Generate code
llm "Write a Python function to calculate fibonacci numbers"

# Data analysis
cat data.csv | llm "Analyze this CSV and provide insights"

# Git commit messages
git diff --staged | llm "Write a commit message for these changes"
```

## Environment Variables

Add to your ~/.zshrc or ~/.bash_profile:
```bash
export OPENAI_API_KEY="your-key"
export ANTHROPIC_API_KEY="your-key"
export HUGGINGFACE_TOKEN="your-token"
```

## Useful Aliases

Add to your shell config:
```bash
alias llama="ollama run llama3.2"
alias code-llm="ollama run codellama"
alias gpt="llm -m gpt4"
alias claude="llm -m claude"
```
EOF

log_success "AI and LLM tools setup complete!"
log_info "Created:"
log_info "  - Ollama setup script: ollama-setup"
log_info "  - AI project creator: new-ai-project"
log_info "  - Python AI/ML requirements: ~/.mac-setup-ai-ml-libs.txt"
log_info "  - Quick reference: ~/.ai-tools-help.md"
log_info ""
log_info "Next steps:"
log_info "  1. Run 'ollama-setup' to download LLM models"
log_info "  2. Set up API keys for cloud LLMs:"
log_info "     llm keys set openai"
log_info "     llm keys set anthropic"
log_info "  3. Create an AI project: new-ai-project my-app"
log_info "  4. See ~/.ai-tools-help.md for usage guide"