#!/bin/bash

# Role Configuration Parser
# Parses YAML role files and handles tool preferences

# Parse tools from a role file section
parse_role_section() {
    local file=$1
    local section=$2
    local include_optional=${3:-false}
    
    python3 -c "
import yaml
import sys

try:
    with open('$file', 'r') as f:
        data = yaml.safe_load(f)
    
    tools = []
    if '$section' in data:
        for item in data['$section']:
            if isinstance(item, dict):
                # Skip optional items if requested
                if not $include_optional and item.get('optional', False):
                    continue
                    
                tool = {
                    'name': item['name'],
                    'description': item.get('description', ''),
                    'alternatives': item.get('alternatives', []),
                    'optional': item.get('optional', False),
                    'paid': item.get('paid', False)
                }
                
                # Format alternatives
                if tool['alternatives']:
                    alt_list = []
                    for alt in tool['alternatives']:
                        if isinstance(alt, dict):
                            alt_list.append(f\"{alt['name']}|{alt.get('description', '')}\")
                        else:
                            alt_list.append(f\"{alt}|\")
                    tool['alternatives'] = alt_list
                
                # Output format: name|description|alternatives|optional|paid
                alt_str = ';'.join(tool['alternatives']) if tool['alternatives'] else ''
                print(f\"{tool['name']}|{tool['description']}|{alt_str}|{tool['optional']}|{tool['paid']}\")
            else:
                # Simple string format
                print(f\"{item}|||False|False\")
    
except Exception as e:
    print(f\"Error parsing $file: {e}\", file=sys.stderr)
    sys.exit(1)
"
}

# Get role metadata
get_role_info() {
    local file=$1
    
    python3 -c "
import yaml
import sys

try:
    with open('$file', 'r') as f:
        data = yaml.safe_load(f)
    
    print(f\"{data.get('name', 'Unknown')}|{data.get('description', '')}\")
    
except Exception as e:
    print(f\"Error parsing $file: {e}\", file=sys.stderr)
    sys.exit(1)
"
}

# Handle tool selection with alternatives
select_tool_with_alternatives() {
    local tool_info=$1
    local auto_select=${2:-false}
    
    IFS='|' read -r name description alternatives optional paid <<< "$tool_info"
    
    # If no alternatives or auto-select, return the primary tool
    if [ -z "$alternatives" ] || [ "$auto_select" = true ]; then
        echo "$name"
        return
    fi
    
    # Parse alternatives
    IFS=';' read -ra alt_array <<< "$alternatives"
    
    echo ""
    log_info "Choose $description:"
    echo "  1) $name (recommended)"
    
    local i=2
    local alt_names=()
    for alt in "${alt_array[@]}"; do
        IFS='|' read -r alt_name alt_desc <<< "$alt"
        alt_names+=("$alt_name")
        if [ -n "$alt_desc" ]; then
            echo "  $i) $alt_name - $alt_desc"
        else
            echo "  $i) $alt_name"
        fi
        ((i++))
    done
    echo "  s) Skip this tool"
    
    read -p "Select option (default: 1): " choice
    
    case "$choice" in
        s|S)
            echo "SKIP"
            ;;
        [2-9])
            local idx=$((choice-2))
            if [ $idx -lt ${#alt_names[@]} ]; then
                echo "${alt_names[$idx]}"
            else
                echo "$name"
            fi
            ;;
        *)
            echo "$name"
            ;;
    esac
}

# Check if Python and PyYAML are available
check_dependencies() {
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 is required but not installed"
        exit 1
    fi
    
    if ! python3 -c "import yaml" 2>/dev/null; then
        log_info "Installing PyYAML..."
        pip3 install --user pyyaml || {
            log_error "Failed to install PyYAML"
            exit 1
        }
    fi
}

# Export functions
export -f parse_role_section
export -f get_role_info
export -f select_tool_with_alternatives
export -f check_dependencies