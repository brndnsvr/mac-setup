#!/bin/bash

# Zsh Extra Functions and Aliases
# This file contains useful aliases and functions for enhanced shell productivity

# Source common functions
source "${BASH_SOURCE[0]%/*}/common.sh"

setup_zsh_extras() {
    log_section "Setting up Zsh extras and productivity functions"
    
    # Create .zsh directory if it doesn't exist
    mkdir -p "$HOME/.zsh"
    
    # Get the roles from the state file or environment
    local roles_file="$HOME/.mac-setup-state"
    if [[ -f "$roles_file" ]] && grep -q "SELECTED_ROLES=" "$roles_file"; then
        source "$roles_file"
        SETUP_ROLES=($SELECTED_ROLES)
    else
        SETUP_ROLES=()
    fi
    
    # Create aliases file
    cat > "$HOME/.zsh/aliases.zsh" << 'EOF'
# Enhanced directory listing using eza
if command -v eza &> /dev/null; then
    alias ll='eza -lh --git --group-directories-first -s extension --icons'
else
    alias ll='ls -lahG'
fi

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Repository updater - finds all git repos and pulls latest (DevOps/Backend roles)
if [[ " ${SETUP_ROLES[@]} " =~ " devops " ]] || [[ " ${SETUP_ROLES[@]} " =~ " backend " ]] || [[ " ${SETUP_ROLES[@]} " =~ " fullstack " ]]; then
    alias update-repos='find ~/code -maxdepth 3 -name .git -type d -prune -execdir sh -c "pwd && git pull --rebase --autostash" \;'
fi

# Show/hide hidden files in Finder
alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'

# Network utilities
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias localip='ipconfig getifaddr en0'

# Docker shortcuts
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dil='docker image ls'
alias dcup='docker-compose up'
alias dcdown='docker-compose down'
alias dclogs='docker-compose logs -f'

# Python virtual environment shortcuts
alias venv='python3 -m venv venv'
alias activate='source venv/bin/activate'
EOF

    # Create functions file
    cat > "$HOME/.zsh/functions.zsh" << 'EOF'
# SSH Agent Initialization
init_ssh_agent() {
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)"
        echo "SSH agent started"
    else
        echo "SSH agent already running"
    fi
}

# Terminal/Tab naming functions
set-session-name() {
    echo -ne "\033]0;$1\007"
}

set-tab-name() {
    echo -ne "\033]1;$1\007"
}

# Public IP checker
myip() {
    local ip
    ip=$(curl -s ifconfig.me)
    if [ $? -eq 0 ]; then
        echo "My public IP is: $ip"
    else
        echo "Failed to retrieve public IP"
        return 1
    fi
}

# Weather function
weather() {
    local location="${1:-}"
    case $location in
        nyc|"new york")
            curl -s "wttr.in/New+York?u"
            ;;
        la|"los angeles")
            curl -s "wttr.in/Los+Angeles?u"
            ;;
        chicago)
            curl -s "wttr.in/Chicago?u"
            ;;
        miami)
            curl -s "wttr.in/Miami?u"
            ;;
        seattle)
            curl -s "wttr.in/Seattle?u"
            ;;
        dallas)
            curl -s "wttr.in/Dallas?u"
            ;;
        atlanta)
            curl -s "wttr.in/Atlanta?u"
            ;;
        sf|"san francisco")
            curl -s "wttr.in/San+Francisco?u"
            ;;
        boston)
            curl -s "wttr.in/Boston?u"
            ;;
        denver)
            curl -s "wttr.in/Denver?u"
            ;;
        "")
            curl -s "wttr.in/?u"
            ;;
        *)
            # Try to get weather for any location
            curl -s "wttr.in/${location}?u"
            ;;
    esac
}

# Keep system awake (macOS caffeinate wrapper) - useful for long-running processes
# Available for DevOps, Backend, Data Engineer, and AI/ML Engineer roles
if [[ " ${SETUP_ROLES[@]} " =~ " devops " ]] || [[ " ${SETUP_ROLES[@]} " =~ " backend " ]] || 
   [[ " ${SETUP_ROLES[@]} " =~ " data-engineer " ]] || [[ " ${SETUP_ROLES[@]} " =~ " ai-ml-engineer " ]] ||
   [[ " ${SETUP_ROLES[@]} " =~ " fullstack " ]]; then
    keep-awake() {
        if [[ "$OSTYPE" == "darwin"* ]]; then
            caffeinate -disu &
            local pid=$!
            echo $pid >> ~/.caffeinate_pids
            echo "System will stay awake (PID: $pid)"
            echo "Use 'stop-awake' to allow sleep again"
        else
            echo "This function is only available on macOS"
        fi
    }

    # Stop keeping system awake
    stop-awake() {
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if [ -f ~/.caffeinate_pids ]; then
                while read -r pid; do
                    if kill -0 "$pid" 2>/dev/null; then
                        kill "$pid"
                        echo "Stopped caffeinate process $pid"
                    fi
                done < ~/.caffeinate_pids
                rm ~/.caffeinate_pids
                echo "System can now sleep normally"
            else
                echo "No caffeinate processes found"
            fi
        else
            echo "This function is only available on macOS"
        fi
    }
fi

# Create a new directory and cd into it
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
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick backup of a file
backup() {
    if [ -f "$1" ]; then
        cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
        echo "Backed up $1"
    else
        echo "'$1' is not a valid file"
    fi
}

# Search for a process
psgrep() {
    ps aux | grep -v grep | grep -i "$1"
}

# Kill processes by name
killgrep() {
    local process="$1"
    if [ -z "$process" ]; then
        echo "Usage: killgrep <process_name>"
        return 1
    fi
    
    local pids=$(ps aux | grep -v grep | grep -i "$process" | awk '{print $2}')
    if [ -z "$pids" ]; then
        echo "No processes found matching '$process'"
        return 1
    fi
    
    echo "Found processes:"
    ps aux | grep -v grep | grep -i "$process"
    echo
    read -p "Kill these processes? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo $pids | xargs kill -9
        echo "Processes killed"
    fi
}

# Quick HTTP server in current directory
serve() {
    local port="${1:-8000}"
    if command -v python3 &> /dev/null; then
        echo "Starting HTTP server on http://localhost:$port"
        python3 -m http.server "$port"
    elif command -v python &> /dev/null; then
        echo "Starting HTTP server on http://localhost:$port"
        python -m SimpleHTTPServer "$port"
    else
        echo "Python is required but not installed"
    fi
}

# Get size of directory or file
sizeof() {
    if [ -z "$1" ]; then
        echo "Usage: sizeof <file_or_directory>"
    elif [ -d "$1" ] || [ -f "$1" ]; then
        du -sh "$1"
    else
        echo "'$1' is not a valid file or directory"
    fi
}

# Show the largest files/directories
biggest() {
    local num="${1:-10}"
    du -sh * 2>/dev/null | sort -rh | head -"$num"
}

# Git branch cleanup - remove merged branches
git-cleanup() {
    git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d
}

# Check which ports are listening
listening() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        lsof -iTCP -sTCP:LISTEN -n -P
    else
        netstat -tlnp 2>/dev/null || ss -tlnp
    fi
}
EOF

    # Add sourcing to .zshrc if not already present
    if ! grep -q "source.*\.zsh/\*\.zsh" "$HOME/.zshrc" 2>/dev/null; then
        log_info "Adding Zsh extras to .zshrc"
        cat >> "$HOME/.zshrc" << 'EOF'

# Source custom functions and aliases from ~/.zsh directory
if [ -d "$HOME/.zsh" ]; then
    for config_file in "$HOME/.zsh/"*.zsh; do
        [ -f "$config_file" ] && source "$config_file"
    done
fi
EOF
    else
        log_info "Zsh extras already configured in .zshrc"
    fi
    
    log_success "Zsh extras setup complete"
}

# Run setup if executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    setup_zsh_extras
fi