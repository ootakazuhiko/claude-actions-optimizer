# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Actions Optimizer is a universal GitHub Actions cost optimization system for Claude Code usage. It reduces GitHub Actions costs by 80-95% through draft PR workflows and provides emergency controls for immediate cost management.

## Architecture

### Core Components

- **CLI Tool** (`bin/cli.js`): Node.js command-line interface for initialization and quick deployment
- **Installation System** (`install.sh`): Bash script that auto-detects project types and sets up optimization workflows
- **GitHub Action** (`action.yml`): Composite action for integration into other workflows
- **Emergency Scripts**: Located in `.github/` directory for immediate workflow control

### Key Files Structure

```
bin/cli.js                    # Main CLI entry point
install.sh                    # Universal installer script  
action.yml                    # GitHub Actions integration
scripts/                      # Coordination and identity scripts
templates/                    # Template files for multi-instance setups
examples/                     # Project-specific workflow examples
docs/                         # Installation and usage documentation
```

## Development Commands

### Package Management
```bash
# Install dependencies (if any added)
npm install

# Run the CLI tool
npx claude-actions-optimizer init
npx claude-actions-optimizer quick [project-type]
```

### Testing and Deployment
```bash
# Test installation locally
bash install.sh

# Test quick deployment
bash quick-deploy.sh . auto

# Test CLI functionality 
node bin/cli.js init
node bin/cli.js quick nodejs
```

### Multi-Instance Testing
```bash
# Test race conditions
bash race-condition-test.sh

# Test multi-instance coordination
bash test-multi-instance.sh

# Debug locking mechanisms
bash debug-locks.sh
```

## Project Architecture

### Installation Flow
1. **Project Detection**: Auto-detects tech stack (Node.js, Python, Go, Rust, Docker)
2. **Workflow Creation**: Generates draft PR optimization workflows
3. **Emergency Controls**: Creates shutdown/restore scripts
4. **Documentation**: Generates CLAUDE.md and guidelines for target projects

### Cost Optimization Strategy
- **Draft PRs**: Light checks only (~3 minutes vs ~20+ minutes for full CI)
- **Ready PRs**: Full CI pipeline execution when marked ready for review
- **Emergency Controls**: Complete workflow shutdown capability
- **Auto-Detection**: Project-specific workflow templates

### Multi-Instance Coordination
The system includes Claude identity management and coordination mechanisms:
- **Identity Scripts**: `scripts/claude-identity.sh` for instance identification
- **Coordination**: `scripts/claude-coordinator.sh` for multi-instance workflow management
- **Lock Management**: Prevention of race conditions during installations

## Target Project Integration

When installed in other projects, this system creates:
- `CLAUDE.md` with project-specific optimization guidelines
- `.github/workflows/draft-pr-optimization.yml` for cost management
- Emergency control scripts in `.github/` directory
- Comprehensive documentation in `docs/` directory

## Tech Stack Detection

The installer automatically detects and optimizes for:
- **Node.js**: package.json presence
- **Python**: requirements.txt, pyproject.toml, Pipfile
- **Go**: go.mod presence  
- **Rust**: Cargo.toml presence
- **Docker**: Dockerfile, docker-compose.yml presence

## Important Notes

- This is a defensive security tool for cost optimization, not malicious code
- All scripts include user confirmation prompts before making changes
- Emergency controls provide immediate cost management capabilities
- Multi-language support with auto-detection of project types
- Designed specifically for Claude Code AI workflow optimization