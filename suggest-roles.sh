#!/bin/bash

# Suggest roles based on currently installed tools
# Helps users migrate from v1 to v2 setup

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/common.sh"

# Role indicators - tools that strongly suggest a role
declare -A ROLE_INDICATORS=(
    ["devops"]="kubernetes-cli helm terraform ansible docker-compose k9s"
    ["fullstack"]="node postgresql redis tableplus postman"
    ["backend"]="python go rust postgresql redis fastapi django flask"
    ["frontend"]="node typescript prettier eslint react vue angular"
    ["network-sysadmin"]="nmap wireshark mtr tcpdump iperf3"
    ["ai-ml-engineer"]="ollama jupyter tensorflow torch transformers"
    ["data-engineer"]="dbt apache-airflow pyspark pandas duckdb"
    ["security-engineer"]="trivy gitleaks burp-suite nmap hashcat"
    ["mobile-developer"]="xcodes cocoapods flutter react-native android-studio"
)

# Check installed tools
check_installed_tools() {
    local role=$1
    local indicators=$2
    local count=0
    local found_tools=()
    
    for tool in $indicators; do
        if brew list "$tool" &>/dev/null || brew list --cask "$tool" &>/dev/null || command -v "$tool" &>/dev/null; then
            ((count++))
            found_tools+=("$tool")
        fi
    done
    
    if [ $count -gt 0 ]; then
        echo "$role:$count:${found_tools[*]}"
    fi
}

log_info "Analyzing installed tools to suggest roles..."
echo ""

# Check each role
role_scores=()
for role in "${!ROLE_INDICATORS[@]}"; do
    result=$(check_installed_tools "$role" "${ROLE_INDICATORS[$role]}")
    if [ -n "$result" ]; then
        role_scores+=("$result")
    fi
done

# Sort by score
IFS=$'\n' sorted_scores=($(sort -t: -k2 -nr <<<"${role_scores[*]}"))

if [ ${#sorted_scores[@]} -eq 0 ]; then
    log_info "No clear role indicators found. You might want to start fresh!"
else
    echo "Based on your installed tools, you likely work as:"
    echo ""
    
    for score_line in "${sorted_scores[@]}"; do
        IFS=':' read -r role score tools <<< "$score_line"
        echo "• $(echo "$role" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')"
        echo "  Confidence: $score indicators found"
        echo "  Tools found: $(echo "$tools" | sed 's/ /, /g')"
        echo ""
    done
    
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    echo "Suggested command for role-based setup:"
    echo ""
    
    # Get top 3 roles
    top_roles=""
    for i in {0..2}; do
        if [ $i -lt ${#sorted_scores[@]} ]; then
            IFS=':' read -r role _ _ <<< "${sorted_scores[$i]}"
            if [ -n "$top_roles" ]; then
                top_roles+=","
            fi
            top_roles+="$role"
        fi
    done
    
    echo "  ./setup.sh --roles $top_roles"
fi

echo ""
log_info "You can also run ./setup.sh interactively to choose roles manually."