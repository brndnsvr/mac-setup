# Setup Script Issues

This document tracks all issues encountered during the `./setup.sh` execution on 2025-07-24.

**Issue ID Format:** YYYYMMDD-XXX
- YYYYMMDD: Date discovered
- XXX: Sequential number

## Critical Issues

*None remaining*
**Severity:** High  
**Occurrences:** 12 times  
**Error Message:**
```
error: externally-managed-environment
× This environment is externally managed
```
**Affected Packages:**
- ansible
- ansible-lint
- molecule
- testinfra
- pexpect
- netmiko
- napalm
- nornir
- paramiko
- fabric
- invoke
- supervisor
- locust

**Root Cause:** macOS Homebrew Python uses PEP 668 which prevents global pip installations to protect system integrity.

**Fix Required:** Convert all pip installations to use pipx instead of pip for CLI tools, or use virtual environments for libraries.

## Medium Severity Issues

*None remaining*

## Low Severity Issues

### 20250724-005: pipx Path Already Configured
**Severity:** Low  
**Occurrences:** 1  
**Warning Message:**
```
⚠️  All pipx binary directories have been appended to PATH. If you are sure you want to proceed, try again with the '--force' flag.
```
**Impact:** Minor warning, pipx is already configured.

**Fix Required:** Add logic to check if pipx path is already configured before attempting to add it.

### 20250724-006: Python Already Linked Warning
**Severity:** Low  
**Occurrences:** 1  
**Warning Message:**
```
Warning: Already linked: /opt/homebrew/Cellar/python@3.13/3.13.5
```
**Impact:** Minor warning, Python is already properly linked.

**Fix Required:** Add check before attempting to link Python.

## Summary Statistics

- **Active Issues:** 2 distinct issue types
- **Resolved Issues:** 5
- **Total Occurrences:** 22+ error instances
- **Critical Issues:** 0 remaining
- **Failed Installations:** 18 packages (all resolved - 5 brew + 13 Python)

## Priority Action Items

1. **Low Priority:** Add existence checks before linking/configuring already-setup items (20250724-005, 20250724-006)

## Affected Files to Update

Based on the errors, these files likely need updates:
- `devops-tools.sh` - Fix Python package installations
- `python-setup.sh` - Add existence checks
- Font installation references

## Recommendations

1. **For Python packages:** 
   - CLI tools (ansible, molecule, etc.) should be installed via pipx: `pipx install ansible`
   - Libraries should be documented as needing virtual environment installation
   - Consider creating a requirements.txt for Python packages that users can install in their own virtual environments

2. **For deprecated taps:** Update to use the current font cask syntax without specifying the deprecated tap.

3. **For better error handling:** Add checks to skip already-configured items and provide clearer error messages when installations fail.

## Resolved Issues

### 20250724-001: Homebrew Environment Variable Error
**Severity:** High  
**Occurrences:** Multiple (5+ times)  
**Error Message:**
```
Error: Calling HOMEBREW_NO_AUTO_UPDATE=0 is disabled! Use HOMEBREW_NO_AUTO_UPDATE=1 to enable and HOMEBREW_NO_AUTO_UPDATE= (an empty value) to disable instead.
```
**Affected Packages:**
- ascii-image-converter (Note: Package doesn't exist in Homebrew)
- dash
- buildah
- alertmanager
- buildkite-agent

**Root Cause:** The script was setting `HOMEBREW_NO_AUTO_UPDATE=0` which is no longer supported by Homebrew.

**Resolution:** 
- **Date:** 2025-07-24
- **Fix Applied:** Changed `export HOMEBREW_NO_AUTO_UPDATE=0` to `export HOMEBREW_NO_AUTO_UPDATE=` in shell-config.sh line 415
- **Files Modified:** shell-config.sh, common.sh (added inline environment variable), devops-tools.sh (added inline environment variable)
- **Verification:** Tested by installing dash cask successfully without the error
- **Notes:** The empty value disables auto-update as intended (the original value of 0 was meant to disable)
- **Additional Fix:** Also updated common.sh to set `HOMEBREW_NO_AUTO_UPDATE=` inline for brew commands to handle existing shell sessions

### 20250724-004: Jupyter Installation via pipx
**Severity:** Medium  
**Occurrences:** 1  
**Error Message:**
```
No apps associated with package jupyter. Try again with '--include-deps' to include apps of dependent packages
```
**Impact:** Jupyter installation failed via pipx.

**Resolution:** 
- **Date:** 2025-07-24
- **Fix Applied:** Modified python-setup.sh to use `pipx install jupyter --include-deps` specifically for jupyter
- **Files Modified:** python-setup.sh line 87-88
- **Notes:** Jupyter has many dependent packages with CLI tools, so --include-deps is required

### 20250724-002: Python PEP 668 Externally Managed Environment
**Severity:** High  
**Occurrences:** 12 times  
**Error Message:**
```
error: externally-managed-environment
× This environment is externally managed
```
**Affected Packages:**
- ansible-lint
- molecule  
- testinfra
- pexpect
- netmiko
- napalm
- nornir
- paramiko
- fabric
- invoke
- supervisor
- locust

**Root Cause:** macOS Homebrew Python uses PEP 668 which prevents global pip installations to protect system integrity.

**Resolution:**
- **Date:** 2025-07-24
- **Fix Applied:** 
  1. Converted CLI tools (ansible-lint, molecule, supervisor, locust) to use pipx installation
  2. Created requirements file at ~/.mac-setup-python-libs.txt for Python libraries
  3. Added instructions for virtual environment usage
- **Files Modified:** devops-tools.sh lines 228-276
- **Documentation:** Created PYTHON_PACKAGES.md with comprehensive Python package management guide
- **Notes:** ansible kept in Homebrew as it's already installed there; libraries require virtual environments for proper usage

### 20250724-007: Script Ignoring User Response for Font Installation
**Severity:** High  
**Occurrences:** 1  
**Impact:** When user selected 'n' for additional developer tools, the script continued to install fonts anyway.

**Root Cause:** Font installation code was outside the conditional block for the user's response.

**Resolution:**
- **Date:** 2025-07-24
- **Fix Applied:** 
  1. Added a separate prompt asking if user wants to install developer fonts
  2. Wrapped font installation code in a conditional block that only runs if user responds 'y'
  3. Fixed indentation to ensure all font-related code is within the conditional
- **Files Modified:** apps-install.sh lines 235-264
- **Notes:** Now fonts are only installed when explicitly requested by the user

## New Features Added

### 20250724-F01: Package Management Tool
**Date:** 2025-07-24  
**Purpose:** Provide ability to list and remove packages installed by mac-setup  
**Implementation:** Created `manage-packages.sh` script with the following features:

**Commands:**
- `list` - List all packages installed by mac-setup
- `list-brew` - List Homebrew packages
- `list-cask` - List Homebrew cask applications
- `list-npm` - List global npm packages
- `list-pip` - List pipx packages
- `list-go` - List Go tools
- `remove` - Interactive removal of packages
- `remove-brew <package>` - Remove a specific Homebrew package
- `remove-cask <app>` - Remove a specific Homebrew cask
- `remove-npm <package>` - Remove a global npm package
- `remove-pip <package>` - Remove a pipx package
- `export` - Export all installed packages to a file

**Usage Examples:**
```bash
./manage-packages.sh list
./manage-packages.sh remove-cask zoom
./manage-packages.sh export > my-packages.txt
```

This tool provides visibility into what was installed and allows selective removal of packages.

### 20250724-003: Deprecated Homebrew Tap
**Severity:** Medium  
**Occurrences:** 1  
**Error Message:**
```
Error: homebrew/cask-fonts was deprecated. This tap is now empty and all its contents were either deleted or migrated.
```
**Impact:** Font installation was trying to use deprecated tap.

**Root Cause:** Homebrew moved font casks from the separate homebrew/cask-fonts tap to the main homebrew/cask tap.

**Resolution:**
- **Date:** 2025-07-24
- **Fix Applied:** 
  1. Removed `brew tap homebrew/cask-fonts` from apps-install.sh
  2. Commented out the tap in Brewfile
- **Files Modified:** 
  - apps-install.sh line 242
  - Brewfile line 6
- **Notes:** Font casks now work directly from the main homebrew/cask tap without needing a separate tap