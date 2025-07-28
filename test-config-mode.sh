#!/bin/bash

# Test script for configuration mode

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Testing Mac Setup Configuration Mode"
echo "===================================="
echo

# Test 1: Configuration mode with minimal preset
echo "Test 1: Building configuration with minimal preset"
echo "./setup.sh --config-mode --preset minimal"
echo
read -p "Press ENTER to run test..."
"$SCRIPT_DIR/setup.sh" --config-mode --preset minimal

echo
echo "Test 1 complete. Configuration should be saved."
echo

# Test 2: Check if configuration file exists
echo "Test 2: Checking if configuration file was created"
if [[ -f "$HOME/.mac-setup-install-config" ]]; then
    echo "✓ Configuration file exists"
    echo
    echo "Configuration contents:"
    echo "----------------------"
    head -20 "$HOME/.mac-setup-install-config"
    echo "..."
    echo
else
    echo "✗ Configuration file not found"
    exit 1
fi

# Test 3: Use configuration for installation (dry run)
echo "Test 3: Using configuration with dry-run"
echo "./setup.sh --use-config --dry-run"
echo
read -p "Press ENTER to run test..."
"$SCRIPT_DIR/setup.sh" --use-config --dry-run

echo
echo "Test 3 complete. Dry run should have shown what would be installed."
echo

# Test 4: Interactive configuration mode
echo "Test 4: Interactive configuration mode"
echo "./setup.sh --config-mode"
echo
echo "This will run interactively. Please select some options to test."
read -p "Press ENTER to run test..."
"$SCRIPT_DIR/setup.sh" --config-mode

echo
echo "All tests complete!"
echo
echo "To actually install using the configuration, run:"
echo "  ./setup.sh --use-config"
echo
echo "To clean up test configuration:"
echo "  rm -f ~/.mac-setup-install-config"