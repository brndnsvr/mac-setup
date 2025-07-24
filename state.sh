#!/bin/bash
# State management for mac-setup scripts

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

# Initialize state file
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        touch "$STATE_FILE"
        log_info "Created state file: $STATE_FILE"
    fi
}

# Mark a step as complete
mark_complete() {
    local step=$1
    echo "$step|$(date +%s)" >> "$STATE_FILE"
    log_info "Marked '$step' as complete"
}

# Check if a step is complete
is_complete() {
    local step=$1
    grep -q "^$step|" "$STATE_FILE" 2>/dev/null
}

# Get completion time for a step
get_completion_time() {
    local step=$1
    grep "^$step|" "$STATE_FILE" 2>/dev/null | cut -d'|' -f2
}

# Reset state (for re-running setup)
reset_state() {
    if [[ -f "$STATE_FILE" ]]; then
        log_warning "Removing existing state file"
        rm "$STATE_FILE"
    fi
    init_state
}

# List completed steps
list_completed() {
    if [[ -f "$STATE_FILE" ]]; then
        log_info "Completed steps:"
        while IFS='|' read -r step timestamp; do
            date_str=$(date -r "$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown time")
            echo "  - $step (completed at $date_str)"
        done < "$STATE_FILE"
    else
        log_info "No completed steps found"
    fi
}

# Progress tracking
TOTAL_STEPS=0
CURRENT_STEP=0

set_total_steps() {
    TOTAL_STEPS=$1
}

progress() {
    local step_name=$1
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Progress: [$CURRENT_STEP/$TOTAL_STEPS]${NC} $step_name"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Run a step with state tracking
run_step() {
    local step_name=$1
    local step_function=$2
    
    progress "$step_name"
    
    if is_complete "$step_name"; then
        log_success "$step_name already completed"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would run: $step_name"
        return 0
    fi
    
    log_info "Running: $step_name"
    if $step_function; then
        mark_complete "$step_name"
        log_success "$step_name completed successfully"
    else
        log_error "$step_name failed"
        return 1
    fi
}