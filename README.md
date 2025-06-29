# Claude Actions Optimizer

Universal GitHub Actions cost optimization system for Claude Code AI.

## 🎯 Overview

Reduce GitHub Actions costs by 80-95% through intelligent workflow optimization and draft PR management.

## ✨ Features

- **80-95% Cost Reduction**: Draft PR optimization
- **Emergency Controls**: Instant workflow shutdown
- **Auto-detection**: Technology stack recognition
- **Claude Code Integration**: Automatic compliance checking
- **Multi-language Support**: Node.js, Python, Go, Rust, etc.

## 🚀 Quick Start

### One-line installation
```bash
curl -sSL https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/install.sh | bash
```

### NPM installation
```bash
npx claude-actions-optimizer init
```

### Project-specific installation
```bash
# Node.js project
./quick-deploy.sh . nodejs

# Python project  
./quick-deploy.sh . python

# Generic project
./quick-deploy.sh . generic
```

## 📊 Results

### Before Optimization
- Multiple workflows on every commit
- High GitHub Actions usage (200+ minutes per PR)
- Expensive development cycles

### After Optimization  
- Draft PRs: ~3 minutes per commit
- Ready PRs: ~20 minutes (full CI)
- **Total savings: 85-95%**

## 🛠️ Usage

### Development Workflow
```bash
# 1. Create draft PR (REQUIRED)
gh pr create --draft --title "feat: new feature"

# 2. Develop with light checks
git commit -m "WIP: implementation"
git push  # ~3 minute light checks

# 3. Ready for review
gh pr ready  # ~20 minute full CI
```

### Emergency Controls
```bash
# Complete shutdown
./.github/disable-all-workflows.sh

# Restore  
./.github/enable-all-workflows.sh backup-directory
```

## 📋 What Gets Installed

```
your-project/
├── CLAUDE.md                           # Claude Code optimization instructions
├── .claude-optimization-enabled        # Optimization flag
├── .github/
│   ├── README.md                      # Emergency guide
│   ├── disable-all-workflows.sh       # Shutdown script
│   ├── enable-all-workflows.sh        # Restore script
│   └── workflows/
│       ├── draft-pr-optimization.yml  # Draft PR workflow
│       └── claude-code-compliance.yml # Compliance monitoring
└── docs/
    └── DRAFT_PR_GUIDELINES.md         # Detailed guidelines
```

## 💰 Cost Impact

### Example: 50 PRs per month
- **Before**: 50 PRs × 200 min = 10,000 minutes (167 hours)
- **After**: 50 PRs × 50 min = 2,500 minutes (42 hours)
- **Savings**: 75% reduction

### Real-world Results
- Project A: 31 workflows → 10 workflows (68% reduction)
- Project B: 29 hours/PR → 3.4 hours/PR (88% reduction)
- Project C: 95% draft PR adoption → 90% cost reduction

## 🤖 Claude Code Integration

This system is automatically recognized by Claude Code AI, which will:
- Always create draft PRs for development
- Display cost impact in real-time
- Monitor compliance automatically
- Provide optimization guidance

## 📊 Supported Technologies

- **Node.js**: Automatic package.json detection
- **Python**: requirements.txt/pyproject.toml support
- **Go**: go.mod support
- **Rust**: Cargo.toml support  
- **Docker**: Dockerfile/docker-compose.yml support
- **Generic**: Universal template for any project

## 📚 Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Draft PR Guidelines](docs/DRAFT_PR_GUIDELINES.md)
- [Emergency Response](.github/README.md)
- [Contributing](CONTRIBUTING.md)

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🔗 Links

- [NPM Package](https://www.npmjs.com/package/claude-actions-optimizer)
- [GitHub Actions Marketplace](https://github.com/marketplace/actions/claude-actions-optimizer)
- [Original Implementation](https://github.com/itdojp/shirokane-app-site-test-fork/issues/279)

---

**Save 80-95% on GitHub Actions costs with intelligent optimization for Claude Code AI.**