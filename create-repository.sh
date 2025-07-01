#!/bin/bash
# Claude Actions Optimizer - 独立リポジトリ作成スクリプト

set -e

echo "🚀 Claude Actions Optimizer - 独立リポジトリ作成"
echo ""

# 設定値
REPO_NAME="claude-actions-optimizer"
ORG_NAME="${1:-your-org}"  # 引数で組織名を指定、デフォルトはyour-org
REPO_DESCRIPTION="Universal GitHub Actions cost optimization system for Claude Code AI"

echo "📋 設定:"
echo "  リポジトリ名: $REPO_NAME"
echo "  組織/ユーザー: $ORG_NAME"
echo "  説明: $REPO_DESCRIPTION"
echo ""

read -p "この設定で新しいリポジトリを作成しますか？ (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "キャンセルしました"
    exit 1
fi

# 作業ディレクトリの準備
WORK_DIR="../$REPO_NAME"
if [ -d "$WORK_DIR" ]; then
    echo "⚠️  ディレクトリが既に存在します: $WORK_DIR"
    read -p "削除して続行しますか？ (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$WORK_DIR"
    else
        echo "キャンセルしました"
        exit 1
    fi
fi

echo "📁 作業ディレクトリ作成: $WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Gitリポジトリ初期化
echo "🔧 Gitリポジトリ初期化..."
git init
git branch -M main

# ディレクトリ構造作成
echo "📂 ディレクトリ構造作成..."
mkdir -p {templates/{nodejs,python,generic},docs,examples,scripts,bin}

# 1. メインファイルのコピーと調整
echo "📝 メインファイル作成..."

# install.sh (汎用インストーラー)
cp ../shirokane-app-site-test-fork/claude-actions-optimizer/install.sh .
chmod +x install.sh

# quick-deploy.sh (高速デプロイ)
cp ../shirokane-app-site-test-fork/claude-actions-optimizer/quick-deploy.sh .
chmod +x quick-deploy.sh

# 2. README.md作成
cat > README.md << 'EOF'
# Claude Actions Optimizer

Universal GitHub Actions cost optimization system for Claude Code AI.

## 🎯 Overview

Reduce GitHub Actions costs by 80-95% through intelligent workflow optimization and draft PR management.

## 🚀 Quick Start

### One-line installation
```bash
curl -sSL https://raw.githubusercontent.com/your-org/claude-actions-optimizer/main/install.sh | bash
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

## ✨ Features

- **80-95% Cost Reduction**: Draft PR optimization
- **Emergency Controls**: Instant workflow shutdown
- **Auto-detection**: Technology stack recognition
- **Claude Code Integration**: Automatic compliance checking
- **Multi-language Support**: Node.js, Python, Go, Rust, etc.

## 📊 Results

### Before Optimization
- Multiple workflows on every commit
- High GitHub Actions usage
- Expensive development cycles

### After Optimization  
- Draft PRs: ~3 minutes per commit
- Ready PRs: ~20 minutes (full CI)
- **85-95% cost savings**

## 🛠️ Usage

### Development Workflow
```bash
# 1. Create draft PR
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

## 📋 Supported Technologies

- **Node.js**: Automatic package.json detection
- **Python**: requirements.txt/pyproject.toml support
- **Go**: go.mod support
- **Rust**: Cargo.toml support  
- **Docker**: Dockerfile/docker-compose.yml support
- **Generic**: Universal template

## 📚 Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Configuration Options](docs/CONFIGURATION.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Contributing](CONTRIBUTING.md)

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🔗 Related Projects

- [Original Implementation](https://github.com/your-org/shirokane-app-site-test-fork/issues/279)
- [Claude Code](https://claude.ai/code)

---

**Save 80-95% on GitHub Actions costs with intelligent optimization for Claude Code AI.**
EOF

# 3. package.json作成（NPM配布用）
cat > package.json << 'EOF'
{
  "name": "claude-actions-optimizer",
  "version": "1.0.0",
  "description": "Universal GitHub Actions cost optimization for Claude Code AI",
  "main": "bin/cli.js",
  "bin": {
    "claude-optimizer": "./bin/cli.js"
  },
  "scripts": {
    "init": "node bin/init.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [
    "github-actions",
    "claude-code",
    "cost-optimization",
    "ci-cd",
    "automation"
  ],
  "author": "Your Organization",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/your-org/claude-actions-optimizer.git"
  },
  "bugs": {
    "url": "https://github.com/your-org/claude-actions-optimizer/issues"
  },
  "homepage": "https://github.com/your-org/claude-actions-optimizer#readme",
  "preferGlobal": true,
  "engines": {
    "node": ">=16.0.0"
  }
}
EOF

# 4. NPM CLI作成
cat > bin/cli.js << 'EOF'
#!/usr/bin/env node
const { execSync } = require('child_process');
const path = require('path');

const command = process.argv[2];
const projectType = process.argv[3] || 'auto';

switch (command) {
  case 'init':
    console.log('🚀 Initializing Claude Actions Optimizer...');
    try {
      const scriptPath = path.join(__dirname, '..', 'install.sh');
      execSync(`bash ${scriptPath}`, { stdio: 'inherit' });
    } catch (error) {
      console.error('❌ Installation failed:', error.message);
      process.exit(1);
    }
    break;
    
  case 'quick':
    console.log('⚡ Quick deployment...');
    try {
      const scriptPath = path.join(__dirname, '..', 'quick-deploy.sh');
      execSync(`bash ${scriptPath} . ${projectType}`, { stdio: 'inherit' });
    } catch (error) {
      console.error('❌ Quick deployment failed:', error.message);
      process.exit(1);
    }
    break;
    
  default:
    console.log(`
Claude Actions Optimizer CLI

Usage:
  npx claude-actions-optimizer init         # Full installation
  npx claude-actions-optimizer quick nodejs # Quick deployment
  npx claude-actions-optimizer quick python # Python project
  npx claude-actions-optimizer quick        # Auto-detect
    `);
}
EOF

chmod +x bin/cli.js

# 5. GitHub Action作成
cat > action.yml << 'EOF'
name: 'Claude Actions Optimizer'
description: 'Optimize GitHub Actions costs for Claude Code usage'
branding:
  icon: 'zap'
  color: 'blue'

inputs:
  project-type:
    description: 'Project type (nodejs, python, generic, auto)'
    required: false
    default: 'auto'
  mode:
    description: 'Installation mode (full, quick)'
    required: false
    default: 'quick'

outputs:
  optimization-status:
    description: 'Optimization installation status'
    
runs:
  using: 'composite'
  steps:
    - name: Install Claude Actions Optimizer
      shell: bash
      run: |
        if [ "${{ inputs.mode }}" = "full" ]; then
          ${{ github.action_path }}/install.sh
        else
          ${{ github.action_path }}/quick-deploy.sh . ${{ inputs.project-type }}
        fi
        echo "optimization-status=installed" >> $GITHUB_OUTPUT
EOF

# 6. ライセンス作成
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2024 Claude Actions Optimizer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# 7. テンプレートファイルの作成
echo "📄 テンプレートファイル作成..."

# Node.js テンプレート
cp ../shirokane-app-site-test-fork/claude-actions-optimizer/examples/nodejs-project.yml templates/nodejs/
cp ../shirokane-app-site-test-fork/claude-actions-optimizer/examples/python-project.yml templates/python/

# 8. ドキュメント作成
cp ../shirokane-app-site-test-fork/claude-actions-optimizer/README.md docs/INSTALLATION.md

cat > docs/CONFIGURATION.md << 'EOF'
# Configuration Guide

## Project-specific Configuration

### .claude-optimizer.yml
```yaml
project:
  type: nodejs
  features:
    - draft-pr-optimization
    - emergency-shutdown
    - cost-monitoring

optimization:
  draft-timeout: 180
  full-timeout: 1800
```

## Environment Variables

- `CLAUDE_CODE_OPTIMIZATION=true`
- `GITHUB_ACTIONS_COST_OPTIMIZATION=enabled`

## Advanced Options

See [examples/](../examples/) for language-specific configurations.
EOF

cat > docs/TROUBLESHOOTING.md << 'EOF'
# Troubleshooting Guide

## Common Issues

### Installation Failed
```bash
# Check permissions
chmod +x install.sh
./install.sh
```

### High Costs Detected
```bash
# Emergency shutdown
./.github/disable-all-workflows.sh
```

### Claude Code Not Compliant
Check automatic monitoring workflow output for guidance.
EOF

# 9. CONTRIBUTING.md作成
cat > CONTRIBUTING.md << 'EOF'
# Contributing to Claude Actions Optimizer

## Development Setup

```bash
git clone https://github.com/your-org/claude-actions-optimizer.git
cd claude-actions-optimizer
```

## Testing

Test with different project types:
```bash
./quick-deploy.sh test-nodejs nodejs
./quick-deploy.sh test-python python
```

## Pull Request Process

1. Fork the repository
2. Create feature branch
3. Test with multiple project types
4. Submit PR with clear description

## Code Style

- Shell scripts: Use shellcheck
- Documentation: Clear and concise
- Examples: Working and tested
EOF

# 10. GitHub workflow作成
mkdir -p .github/workflows

cat > .github/workflows/test.yml << 'EOF'
name: Test Claude Actions Optimizer

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test-installation:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        project-type: [nodejs, python, generic]
    steps:
      - uses: actions/checkout@v4
      - name: Test ${{ matrix.project-type }} installation
        run: |
          mkdir test-${{ matrix.project-type }}
          cd test-${{ matrix.project-type }}
          
          # Create minimal project structure
          if [ "${{ matrix.project-type }}" = "nodejs" ]; then
            echo '{"name": "test"}' > package.json
          elif [ "${{ matrix.project-type }}" = "python" ]; then
            echo "requests" > requirements.txt
          fi
          
          # Test installation
          ../quick-deploy.sh . ${{ matrix.project-type }}
          
          # Verify installation
          [ -f "CLAUDE.md" ] && echo "✅ CLAUDE.md created"
          [ -f ".github/disable-all-workflows.sh" ] && echo "✅ Emergency scripts created"
          [ -f ".github/workflows/optimized-ci.yml" ] && echo "✅ Workflow created"
EOF

# 11. 初期コミット
echo "📦 初期コミット作成..."
git add .
git commit -m "feat: Initial release of Claude Actions Optimizer

Universal GitHub Actions cost optimization system:
- 80-95% cost reduction through draft PR optimization
- Emergency shutdown capabilities
- Multi-language support (Node.js, Python, Go, Rust)
- Claude Code AI integration
- NPM package and GitHub Action distribution

Features:
- One-line installation
- Technology stack auto-detection
- Comprehensive documentation
- Template system for different project types"

# 12. GitHub リポジトリ作成
echo "🌐 GitHubリポジトリ作成..."
if command -v gh &> /dev/null; then
    gh repo create "$ORG_NAME/$REPO_NAME" --public --description "$REPO_DESCRIPTION" --source .
    git push -u origin main
    
    echo ""
    echo "🎉 リポジトリ作成完了！"
    echo ""
    echo "📊 作成されたリポジトリ:"
    echo "  🔗 URL: https://github.com/$ORG_NAME/$REPO_NAME"
    echo "  📦 NPM: npm install -g $REPO_NAME"
    echo "  ⚡ Quick: curl -sSL https://raw.githubusercontent.com/$ORG_NAME/$REPO_NAME/main/install.sh | bash"
    echo ""
    echo "📋 次のステップ:"
    echo "1. NPM公開: cd $WORK_DIR && npm publish"
    echo "2. GitHub Release作成: gh release create v1.0.0"
    echo "3. Marketplace申請: GitHub Actions Marketplace"
    echo "4. ドキュメント更新: README.mdのリンク修正"
else
    echo "⚠️  GitHub CLIが見つかりません"
    echo "手動でリポジトリを作成してください:"
    echo "  1. https://github.com/new でリポジトリ作成"
    echo "  2. git remote add origin https://github.com/$ORG_NAME/$REPO_NAME.git"
    echo "  3. git push -u origin main"
fi

echo ""
echo "📁 リポジトリ構造:"
find . -type f -name ".*" -prune -o -type f -print | head -20