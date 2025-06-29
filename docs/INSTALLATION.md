# Installation Guide

## Prerequisites

- Git installed
- Bash shell (Linux, macOS, WSL on Windows)
- GitHub CLI (`gh`) recommended but not required

## Installation Methods

### 1. Quick Installation (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/install.sh | bash
```

### 2. NPM Installation

```bash
# Global installation
npm install -g claude-actions-optimizer

# Or use npx without installation
npx claude-actions-optimizer init
```

### 3. Manual Installation

```bash
# Clone the repository
git clone https://github.com/ootakazuhiko/claude-actions-optimizer.git
cd claude-actions-optimizer

# Run the installer
./install.sh
```

### 4. GitHub Action

Add to your workflow:

```yaml
- uses: ootakazuhiko/claude-actions-optimizer@v1
  with:
    project-type: auto
    mode: quick
```

## Configuration Options

### Project Types

- `nodejs` - Node.js projects (detects package.json)
- `python` - Python projects (detects requirements.txt, pyproject.toml)
- `generic` - Any other project type
- `auto` - Automatic detection (default)

### Installation Modes

- `full` - Complete installation with all features
- `quick` - Basic installation with essential features (default)

## Post-Installation

After installation, you'll find:

1. **CLAUDE.md** - Instructions for Claude Code AI
2. **.github/disable-all-workflows.sh** - Emergency shutdown script
3. **.github/workflows/optimized-ci.yml** - Optimized CI workflow
4. **docs/DRAFT_PR_GUIDELINES.md** - Usage guidelines

## Verification

Verify the installation:

```bash
# Check if files were created
ls -la CLAUDE.md .github/*.sh

# Test emergency shutdown (dry run)
./.github/disable-all-workflows.sh
```

## Troubleshooting

### Permission Denied

```bash
chmod +x install.sh
./install.sh
```

### GitHub CLI Not Found

Install GitHub CLI:
```bash
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
```

### Workflow Not Running

1. Check if `.github/workflows/` directory exists
2. Verify workflow syntax with `gh workflow list`
3. Ensure Actions are enabled in repository settings