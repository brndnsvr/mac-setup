# Python Package Management Guide

This guide explains how Python packages are managed in the mac-setup repository and how to work with them on macOS with Homebrew Python.

## Background: PEP 668 and Externally Managed Environments

Starting with Python 3.11, Homebrew's Python installation is marked as "externally managed" according to [PEP 668](https://peps.python.org/pep-0668/). This prevents accidental breakage of system packages by restricting global pip installations.

## Package Installation Strategy

### 1. CLI Tools (Installed via pipx)

Command-line tools that you run directly from the terminal are installed using `pipx`. This creates isolated environments for each tool while making the commands globally available.

**Tools installed via pipx:**
- `ansible-lint` - Ansible playbook linting
- `aws-sam-cli` - AWS Serverless Application Model CLI
- `black` - Python code formatter
- `bpython` - Enhanced Python REPL
- `cookiecutter` - Project templates
- `flake8` - Python linting
- `httpie` - Command-line HTTP client
- `ipython` - Enhanced Python shell
- `jupyter` - Jupyter notebooks (with --include-deps)
- `locust` - Load testing tool
- `molecule` - Ansible testing framework
- `mypy` - Static type checker
- `pipenv` - Python dependency management
- `poetry` - Python packaging and dependency management
- `pre-commit` - Git hook framework
- `ptpython` - Python REPL
- `pylint` - Python code analysis
- `supervisor` - Process control system
- `tox` - Testing automation
- `twine` - PyPI package publishing

**To install a new CLI tool:**
```bash
pipx install <tool-name>
```

**To list installed tools:**
```bash
pipx list
```

### 2. Python Libraries (Virtual Environment Required)

Libraries that are imported in Python scripts must be installed in virtual environments. The setup creates a requirements file at `~/.mac-setup-python-libs.txt` with commonly needed DevOps libraries.

**Libraries included:**
- `fabric` - Remote execution and deployment
- `invoke` - Task execution tool
- `napalm` - Network automation and programmability
- `netmiko` - Multi-vendor network device automation
- `nornir` - Network automation framework
- `paramiko` - SSH2 protocol library
- `pexpect` - Spawning and controlling interactive programs
- `testinfra` - Infrastructure testing

**To use these libraries:**

1. Create a virtual environment:
   ```bash
   python3 -m venv ~/devops-env
   ```

2. Activate the virtual environment:
   ```bash
   source ~/devops-env/bin/activate
   ```

3. Install the libraries:
   ```bash
   pip install -r ~/.mac-setup-python-libs.txt
   ```

4. When done, deactivate:
   ```bash
   deactivate
   ```

### 3. Project-Specific Dependencies

For individual projects, always create a dedicated virtual environment:

```bash
cd my-project
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Common Workflows

### Creating a New Python Project

Use the helper script created by mac-setup:
```bash
new-python-project my-awesome-project
```

This creates a new directory with:
- Virtual environment
- Basic project structure
- `.gitignore` file
- `requirements.txt`
- `setup.py` template

### Installing Additional Tools

**For CLI tools:**
```bash
pipx install <tool-name>
```

**For libraries in your project:**
```bash
# Activate your project's virtual environment first
source venv/bin/activate
pip install <library-name>
pip freeze > requirements.txt
```

### Managing Virtual Environments

**List all virtual environments:**
```bash
find ~ -name "pyvenv.cfg" -type f 2>/dev/null | xargs dirname
```

**Remove a virtual environment:**
```bash
rm -rf path/to/venv
```

## Troubleshooting

### "error: externally-managed-environment"

This error means you're trying to pip install globally. Solutions:
1. Use `pipx install` for CLI tools
2. Create and activate a virtual environment for libraries
3. Never use `pip install --break-system-packages` (it can break Homebrew)

### pipx command not found

Install pipx first:
```bash
brew install pipx
pipx ensurepath
```

Then restart your terminal or run:
```bash
source ~/.zshrc
```

### Import errors in scripts

Make sure you:
1. Created a virtual environment for your project
2. Activated it before installing packages
3. Are running your script with the virtual environment activated

## Best Practices

1. **Always use virtual environments** for project dependencies
2. **Use pipx for CLI tools** that you want available globally
3. **Document dependencies** in requirements.txt or pyproject.toml
4. **Don't mix system and project packages** - keep them separate
5. **Use the same Python version** for virtual environments as your project requires

## Package Management Commands

Use the included package management script to manage installed packages:

```bash
# List all Python packages installed by mac-setup
./manage-packages.sh list-pip

# Remove a pipx package
./manage-packages.sh remove-pip <package-name>

# Interactive package removal
./manage-packages.sh remove
```

## Additional Resources

- [pipx documentation](https://pypa.github.io/pipx/)
- [Python venv documentation](https://docs.python.org/3/library/venv.html)
- [PEP 668 - Externally Managed Environments](https://peps.python.org/pep-0668/)
- [Homebrew Python documentation](https://docs.brew.sh/Homebrew-and-Python)