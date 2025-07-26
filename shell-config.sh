#!/bin/bash

# Shell Configuration Setup Script
# Sets up Zsh with custom configurations and dotfiles

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

log_info "Setting up shell configuration..."

# Ensure Zsh is the default shell
if [[ "$SHELL" != *"zsh"* ]]; then
    log_info "Setting Zsh as default shell..."
    chsh -s /bin/zsh
    log_success "Default shell changed to Zsh. Please restart your terminal."
else
    log_success "Zsh is already the default shell"
fi

# Create .zsh directory structure
log_info "Creating Zsh configuration structure..."
mkdir -p "$HOME/.zsh"
mkdir -p "$HOME/.zsh/completions"
mkdir -p "$HOME/.zsh/functions"

# Create main .zshrc file
log_info "Creating .zshrc configuration..."
cat > "$HOME/.zshrc" << 'EOF'
# Zsh Configuration
# This file is sourced for interactive shells

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path configuration
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Homebrew configuration
if [[ -d "/opt/homebrew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/usr/local/bin/brew shellenv)"
fi

# History configuration
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Completion system
autoload -Uz compinit
compinit

# Load custom completions
fpath=($HOME/.zsh/completions $fpath)

# Enhanced completion
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'

# Load aliases
if [[ -f "$HOME/.zsh/aliases.zsh" ]]; then
    source "$HOME/.zsh/aliases.zsh"
fi

# Load functions
if [[ -f "$HOME/.zsh/functions.zsh" ]]; then
    source "$HOME/.zsh/functions.zsh"
fi

# Load environment variables
if [[ -f "$HOME/.zsh/env.zsh" ]]; then
    source "$HOME/.zsh/env.zsh"
fi

# Load local configuration (not tracked in git)
if [[ -f "$HOME/.zsh/local.zsh" ]]; then
    source "$HOME/.zsh/local.zsh"
fi

# Python configuration
export PYTHONSTARTUP="$HOME/.config/python/pythonstartup.py"

# Node.js configuration
export NODE_REPL_HISTORY="$HOME/.node_repl_history"

# Go configuration
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Rust configuration
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

# Editor configuration
export EDITOR="nvim"
export VISUAL="nvim"

# Less configuration
export LESS="-R"
export LESSHISTFILE="$HOME/.lesshst"

# FZF configuration (if installed)
if command -v fzf &> /dev/null; then
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
    export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
fi

# Load zsh-syntax-highlighting (if installed)
if [[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Load zsh-autosuggestions (if installed)
if [[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Load zsh-history-substring-search (if installed)
if [[ -f "$(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    source "$(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
fi

# Starship prompt (if installed)
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Source iTerm2 shell integration (if available)
if [[ -f "$HOME/.iterm2_shell_integration.zsh" ]]; then
    source "$HOME/.iterm2_shell_integration.zsh"
fi

# Source Warp terminal integration (if available)
if [[ -f "$HOME/.warp/warp.zsh" ]]; then
    source "$HOME/.warp/warp.zsh"
fi
EOF

# Create aliases file
log_info "Creating aliases configuration..."
cat > "$HOME/.zsh/aliases.zsh" << 'EOF'
# Shell Aliases

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Enhanced ls using eza (if available)
if command -v eza &> /dev/null; then
    alias ls='eza'
    alias ll='eza -l'
    alias la='eza -la'
    alias lt='eza --tree'
    alias l='eza -lah'
else
    alias ls='ls -G'
    alias ll='ls -lh'
    alias la='ls -lah'
    alias l='ls -lah'
fi

# Git aliases
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gl='git log'
alias gp='git push'
alias gs='git status'
alias gpl='git pull'
alias gb='git branch'
alias gm='git merge'
alias gr='git remote'

# Docker aliases
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'

# Python aliases
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source .venv/bin/activate'

# npm aliases
alias ni='npm install'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'

# System aliases
alias reload='source ~/.zshrc'
alias path='echo $PATH | tr ":" "\n"'
alias ports='netstat -tuln'
alias myip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Shortcuts
alias h='history'
alias j='jobs -l'
alias c='clear'
alias e='$EDITOR'
alias v='$VISUAL'

# Mac specific
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
alias cleanup='find . -type f -name "*.DS_Store" -delete'

# Development
alias serve='python3 -m http.server'
alias json='python3 -m json.tool'
alias urlencode='python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))"'
alias urldecode='python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))"'

# Process management
alias psg='ps aux | grep -v grep | grep -i'
alias top='htop || top'
EOF

# Create functions file
log_info "Creating functions configuration..."
cat > "$HOME/.zsh/functions.zsh" << 'EOF'
# Shell Functions

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find files by name
ff() {
    find . -type f -iname "*$1*"
}

# Find directories by name
fd() {
    find . -type d -iname "*$1*"
}

# Quick look at CSV files
csvlook() {
    column -s, -t < "$1" | less -S
}

# Get weather
weather() {
    curl -s "wttr.in/${1:-}"
}

# Quick HTTP server with specified port
server() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

# Git commit with message
gcm() {
    git commit -m "$*"
}

# Docker cleanup
docker-cleanup() {
    docker system prune -af
    docker volume prune -f
}

# Show PATH entries on separate lines
showpath() {
    echo $PATH | tr ':' '\n' | sort | uniq
}

# Backup file with timestamp
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Show disk usage sorted by size
dus() {
    du -sh * | sort -h
}

# Quick notes function
note() {
    local notes_dir="$HOME/notes"
    mkdir -p "$notes_dir"
    
    if [ $# -eq 0 ]; then
        ls -la "$notes_dir"
    else
        echo "$*" >> "$notes_dir/$(date +%Y-%m-%d).txt"
        echo "Note added to $notes_dir/$(date +%Y-%m-%d).txt"
    fi
}

# Quick project navigation
proj() {
    cd "$HOME/Projects/$1"
}

# Update system
update() {
    echo "Updating Homebrew..."
    brew update && brew upgrade
    echo "Updating npm packages..."
    npm update -g
    echo "Update complete!"
}
EOF

# Create environment variables file
log_info "Creating environment configuration..."
cat > "$HOME/.zsh/env.zsh" << 'EOF'
# Environment Variables

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Create XDG directories if they don't exist
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

# Language settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Terminal settings
export TERM="xterm-256color"

# GPG settings
export GPG_TTY=$(tty)

# Homebrew settings
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=

# Development settings
export PYTHONDONTWRITEBYTECODE=1
export PIP_REQUIRE_VIRTUALENV=false

# AWS CLI settings (if used)
export AWS_PAGER=""

# Ansible settings (if used)
export ANSIBLE_HOST_KEY_CHECKING=False

# Custom bin directories
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
EOF

# Install shell enhancements
log_info "Installing shell enhancements..."

# Install Starship prompt
if ! command -v starship &> /dev/null; then
    log_info "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    log_success "Starship already installed"
fi

# Create Starship configuration
log_info "Creating Starship configuration..."
mkdir -p "$HOME/.config"
cat > "$HOME/.config/starship.toml" << 'EOF'
# Starship prompt configuration

format = """
[](#3B4252)\
$username\
[](bg:#434C5E fg:#3B4252)\
$directory\
[](fg:#434C5E bg:#4C566A)\
$git_branch\
$git_status\
[](fg:#4C566A bg:#5E81AC)\
$python\
$nodejs\
$golang\
$rust\
[](fg:#5E81AC)\
$character\
"""

[username]
show_always = true
style_user = "bg:#3B4252"
style_root = "bg:#3B4252"
format = '[ $user ]($style)'

[directory]
style = "bg:#434C5E"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = ""
style = "bg:#4C566A"
format = '[ $symbol $branch ]($style)'

[git_status]
style = "bg:#4C566A"
format = '[$all_status$ahead_behind ]($style)'

[python]
symbol = ""
style = "bg:#5E81AC"
format = '[ $symbol ($version) ]($style)'

[nodejs]
symbol = ""
style = "bg:#5E81AC"
format = '[ $symbol ($version) ]($style)'

[golang]
symbol = ""
style = "bg:#5E81AC"
format = '[ $symbol ($version) ]($style)'

[rust]
symbol = ""
style = "bg:#5E81AC"
format = '[ $symbol ($version) ]($style)'

[character]
success_symbol = '[ ](bold green)'
error_symbol = '[ ](bold red)'
EOF

# Create .gitconfig
log_info "Creating Git configuration template..."
cat > "$HOME/.gitconfig.template" << 'EOF'
[user]
    name = Your Name
    email = your.email@example.com

[core]
    editor = nvim
    whitespace = fix,-indent-with-non-tab,trailing-space,cr-at-eol
    excludesfile = ~/.gitignore_global
    pager = less

[color]
    ui = auto
    branch = auto
    diff = auto
    status = auto

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    df = diff
    lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    last = log -1 HEAD
    unstage = reset HEAD --
    amend = commit --amend
    undo = reset --soft HEAD~1

[push]
    default = simple
    autoSetupRemote = true

[pull]
    rebase = false

[init]
    defaultBranch = main

[diff]
    tool = vimdiff

[merge]
    tool = vimdiff
    conflictstyle = diff3

[help]
    autocorrect = 1
EOF

# Create global gitignore
log_info "Creating global gitignore..."
cat > "$HOME/.gitignore_global" << 'EOF'
# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# Linux
*~

# IDEs
.idea/
.vscode/
*.swp
*.swo
*~
.project
.classpath
.settings/

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
.venv/
ENV/
env/

# Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# General
*.log
*.tmp
*.temp
.env
.env.local
.env.*.local
EOF

log_success "Shell configuration setup complete!"
log_info "To apply changes, run: source ~/.zshrc"
log_info "Don't forget to:"
echo "  1. Update ~/.gitconfig.template with your information"
echo "  2. Copy it to ~/.gitconfig"
echo "  3. Restart your terminal for all changes to take effect"
