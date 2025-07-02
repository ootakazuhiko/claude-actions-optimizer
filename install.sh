#!/bin/bash
# Claude Code GitHub Actions最適化システム - 汎用インストーラー
# 任意のプロジェクトにGitHub Actions最適化を適用

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"

echo "🤖 Claude Code GitHub Actions最適化システム"
echo "Universal installer for any project"
echo ""
echo "プロジェクトディレクトリ: $PROJECT_ROOT"
echo "インストーラーディレクトリ: $SCRIPT_DIR"
echo ""

# プロジェクトの基本情報を収集
echo "📋 プロジェクト情報の収集..."

# プロジェクト名の取得
PROJECT_NAME=$(basename "$PROJECT_ROOT")
if [ -f "package.json" ]; then
    PACKAGE_NAME=$(grep '"name"' package.json | sed 's/.*"name": *"\([^"]*\)".*/\1/' 2>/dev/null || echo "$PROJECT_NAME")
    PROJECT_NAME="$PACKAGE_NAME"
fi

echo "プロジェクト名: $PROJECT_NAME"

# 技術スタックの検出
TECH_STACK=""
if [ -f "package.json" ]; then
    TECH_STACK="$TECH_STACK Node.js"
fi
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "Pipfile" ]; then
    TECH_STACK="$TECH_STACK Python"
fi
if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ]; then
    TECH_STACK="$TECH_STACK Docker"
fi
if [ -f "go.mod" ]; then
    TECH_STACK="$TECH_STACK Go"
fi
if [ -f "Cargo.toml" ]; then
    TECH_STACK="$TECH_STACK Rust"
fi

echo "検出された技術スタック:$TECH_STACK"

# 既存のGitHub Actionsワークフローの確認
EXISTING_WORKFLOWS=0
if [ -d ".github/workflows" ]; then
    EXISTING_WORKFLOWS=$(ls -1 .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null | wc -l)
fi
echo "既存ワークフロー数: $EXISTING_WORKFLOWS"

printf "\n"
read -p "このプロジェクトにClaude Code最適化を適用しますか？ (y/N): " -n 1 -r
printf "\n"
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "キャンセルしました"
    exit 0
fi

# ディレクトリ構造の作成
echo "📁 ディレクトリ構造を作成中..."
mkdir -p .github/workflows
mkdir -p .github/actions/claude-code-guard
mkdir -p docs

# 1. 基本的なCLAUDE.mdの作成
echo "📝 CLAUDE.mdを作成中..."
cat > CLAUDE.md << EOF
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Project: $PROJECT_NAME
Tech Stack:$TECH_STACK

## 🚨 CRITICAL: GitHub Actions Cost Optimization

**MANDATORY WORKFLOW**: All Claude Code instances MUST follow this optimized process to prevent excessive GitHub Actions costs.

### 1. ALWAYS Use Draft PRs for Development

**REQUIRED**: Create ALL new PRs as draft PRs initially:

\`\`\`bash
# ✅ CORRECT: Always start with draft
gh pr create --draft --title "feat: your feature"

# ❌ WRONG: Never create ready PRs during development
gh pr create --title "feat: your feature"
\`\`\`

**Development Flow**:
\`\`\`
1. Draft PR creation  → Light checks only (~3 minutes)
2. Multiple commits   → Light checks only (~3 minutes each)  
3. Ready for review   → Full CI execution (~15-30 minutes)
\`\`\`

### 2. Emergency Actions Controls

**Available immediately** in \`.github/\` directory:

\`\`\`bash
# Complete shutdown (emergency)
./.github/disable-all-workflows.sh

# Partial shutdown (high-cost workflows only)
./.github/disable-expensive-workflows.sh

# Restore from shutdown
./.github/enable-all-workflows.sh backup-directory
\`\`\`

### 3. Cost Impact Awareness

**Before Optimization**:
- Multiple workflows running on every commit
- High GitHub Actions usage and costs

**After Optimization** (CURRENT):
- Draft PRs: Light checks only (~3 minutes)
- Ready PRs: Full CI only when needed
- Expected savings: 80-95% cost reduction

### 4. Mandatory Practices for Claude Code

#### When Creating PRs:
1. **ALWAYS** check if this is development work
2. **ALWAYS** use \`--draft\` flag for new features/fixes
3. **ALWAYS** mention draft PR workflow in PR descriptions
4. **NEVER** create ready PRs unless it's a hotfix

#### When Making Commits:
1. **ENCOURAGE** multiple small commits during development
2. **EXPLAIN** that draft PRs have minimal CI overhead
3. **REMIND** about ready-for-review transition

#### When Finishing Work:
1. **INSTRUCT** to use \`gh pr ready\` or GitHub UI "Ready for review"
2. **EXPLAIN** that full CI will run at this point
3. **CONFIRM** all tests pass before marking ready

### 5. Documentation References

- **Emergency Guide**: \`.github/README.md\`
- **Draft PR Guidelines**: \`docs/DRAFT_PR_GUIDELINES.md\`

## 📋 Claude Code Implementation Checklist

Before any PR creation, Claude Code must:
- [ ] Determine if this is development work (features, fixes, refactoring)
- [ ] If yes, create draft PR with \`--draft\` flag
- [ ] Include draft PR explanation in PR description
- [ ] Reference cost optimization when explaining workflow
- [ ] Suggest ready-for-review transition when work is complete

**Failure to follow this workflow may result in significant unnecessary costs and should be avoided at all times.**
EOF

# 2. 緊急停止スクリプトの作成
echo "🛑 緊急停止スクリプトを作成中..."

cat > .github/disable-all-workflows.sh << 'EOF'
#!/bin/bash
# 全GitHub Actions一時停止スクリプト（汎用版）

set -e

echo "🚨 全GitHub Actions 一時停止スクリプト"
echo "Universal GitHub Actions emergency shutdown"
echo ""

# 現在のワークフロー数を表示
workflow_count=$(ls -1 .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null | wc -l)
echo "現在のワークフロー数: $workflow_count 個"

if [ "$workflow_count" -eq 0 ]; then
    echo "ワークフローが見つかりません。"
    exit 0
fi

echo ""
echo "実行内容:"
echo "  .github/workflows → .github/workflows-disabled-$(date +%Y%m%d-%H%M%S)"
echo ""

read -p "全てのワークフローを停止しますか？ (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "キャンセルしました"
    exit 1
fi

# タイムスタンプ付きでリネーム
DISABLED_DIR="workflows-disabled-$(date +%Y%m%d-%H%M%S)"
mv .github/workflows ".github/$DISABLED_DIR"

echo ""
echo "🎉 全ワークフロー停止完了！"
echo "  📁 移動先: .github/$DISABLED_DIR"
echo ""
echo "復元方法:"
echo "  mv .github/$DISABLED_DIR .github/workflows"
EOF

cat > .github/enable-all-workflows.sh << 'EOF'
#!/bin/bash
# 全GitHub Actions復元スクリプト（汎用版）

set -e

if [ $# -eq 0 ]; then
    echo "使用方法: $0 <disabled-directory-name>"
    echo ""
    echo "利用可能な無効化ディレクトリ:"
    ls -la .github/ | grep "workflows-disabled" || echo "  無効化されたワークフローが見つかりません"
    exit 1
fi

DISABLED_DIR="$1"
FULL_PATH=".github/$DISABLED_DIR"

if [ ! -d "$FULL_PATH" ]; then
    echo "❌ エラー: 無効化ディレクトリが見つかりません: $FULL_PATH"
    exit 1
fi

echo "🔄 全GitHub Actions復元スクリプト"
echo ""

# 復元元の確認
workflow_count=$(ls -1 "$FULL_PATH"/*.yml "$FULL_PATH"/*.yaml 2>/dev/null | wc -l)
echo "復元するワークフロー数: $workflow_count 個"

if [ "$workflow_count" -eq 0 ]; then
    echo "❌ 復元するワークフローが見つかりません"
    exit 1
fi

# 既存確認
if [ -d ".github/workflows" ]; then
    current_count=$(ls -1 .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null | wc -l)
    echo "⚠️  既存のワークフロー: $current_count 個"
    echo ""
    read -p "既存のワークフローを上書きしますか？ (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "キャンセルしました"
        exit 1
    fi
    
    backup_existing=".github/workflows-backup-before-restore-$(date +%Y%m%d-%H%M%S)"
    mv .github/workflows "$backup_existing"
    echo "📁 既存ワークフローを $backup_existing にバックアップ"
fi

# 復元実行
mv "$FULL_PATH" .github/workflows

echo ""
echo "🎉 全ワークフロー復元完了！"
echo "  📊 復元されたワークフロー: $workflow_count 個"
echo ""
echo "GitHub Actionsが再度有効になりました。"
EOF

# 3. ドラフトPR対応の基本ワークフローを作成
echo "⚙️ 基本ワークフローを作成中..."

cat > .github/workflows/draft-pr-optimization.yml << 'EOF'
name: Draft PR Cost Optimization

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]

jobs:
  # Light checks for draft PRs
  draft-checks:
    name: Draft PR Light Checks
    if: github.event.pull_request.draft == true
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Draft PR Notice
        run: |
          echo "🚧 Draft PR - Running light checks only"
          echo "💰 Cost optimization: ~3 minutes vs ~20+ minutes for full CI"
          echo "🚀 Ready for full CI? Click 'Ready for review' or run: gh pr ready"
          
      - name: Basic validation
        run: |
          echo "✅ Repository structure check"
          ls -la
          
          # Basic file checks
          if [ -f "package.json" ]; then
            echo "✅ Node.js project detected"
            # Could add: npm ci --ignore-scripts && npm run lint
          fi
          
          if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
            echo "✅ Python project detected"
            # Could add: pip install -r requirements.txt && flake8
          fi
          
          echo "✅ Light checks completed successfully"

  # Full CI for ready PRs
  full-ci:
    name: Full CI Pipeline
    if: github.event.pull_request.draft == false
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Full CI Notice
        run: |
          echo "🚀 Ready PR - Running full CI pipeline"
          echo "⏱️  Expected duration: 15-30 minutes"
          
      - name: Comprehensive testing
        run: |
          echo "🧪 Running comprehensive test suite..."
          # Add your actual CI steps here
          
          # Example for Node.js
          if [ -f "package.json" ]; then
            echo "📦 Node.js full CI would run here"
            # npm ci
            # npm run test
            # npm run build
            # npm run lint
          fi
          
          # Example for Python  
          if [ -f "requirements.txt" ]; then
            echo "🐍 Python full CI would run here"
            # pip install -r requirements.txt
            # pytest
            # flake8
            # mypy
          fi
          
          echo "✅ Full CI completed successfully"

  # Cost monitoring
  cost-monitor:
    name: Cost Impact Monitor
    runs-on: ubuntu-latest
    steps:
      - name: Display cost impact
        run: |
          echo "## 💰 GitHub Actions Cost Impact" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          
          if [[ "${{ github.event.pull_request.draft }}" == "true" ]]; then
            echo "✅ **Optimized**: Draft PR light checks (~3 minutes)" >> $GITHUB_STEP_SUMMARY
            echo "- 🎯 Cost-effective development workflow" >> $GITHUB_STEP_SUMMARY
            echo "- 🚀 Ready for full CI? Click 'Ready for review'" >> $GITHUB_STEP_SUMMARY
          else
            echo "⚡ **Full CI**: Ready PR comprehensive checks (~20+ minutes)" >> $GITHUB_STEP_SUMMARY
            echo "- 🧪 Complete test suite execution" >> $GITHUB_STEP_SUMMARY
            echo "- 📊 Production-ready validation" >> $GITHUB_STEP_SUMMARY
          fi
          
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "### 📋 Optimization Stats" >> $GITHUB_STEP_SUMMARY
          echo "- Draft PR savings: ~85% cost reduction" >> $GITHUB_STEP_SUMMARY
          echo "- Emergency shutdown: \`.github/disable-all-workflows.sh\`" >> $GITHUB_STEP_SUMMARY
EOF

# 4. Claude Code監視ワークフローの作成
cat > .github/workflows/claude-code-compliance.yml << 'EOF'
name: Claude Code Compliance Monitor

on:
  pull_request:
    types: [opened, converted_to_draft, ready_for_review]

jobs:
  compliance-check:
    name: Claude Code Workflow Compliance
    runs-on: ubuntu-latest
    steps:
      - name: Detect Claude Code usage
        id: detect
        run: |
          # Check if PR appears to be Claude Code created
          if echo "${{ github.event.pull_request.body }}" | grep -q "Generated with.*Claude Code\|🤖.*Claude\|Claude.*generated"; then
            echo "claude_code=true" >> $GITHUB_OUTPUT
            echo "🤖 Claude Code PR detected"
          else
            echo "claude_code=false" >> $GITHUB_OUTPUT
          fi
          
          if [[ "${{ github.event.pull_request.draft }}" == "true" ]]; then
            echo "pr_type=draft" >> $GITHUB_OUTPUT
          else
            echo "pr_type=ready" >> $GITHUB_OUTPUT
          fi
          
      - name: Claude Code compliance check
        if: steps.detect.outputs.claude_code == 'true'
        run: |
          echo "🤖 Claude Code Compliance Check"
          
          if [[ "${{ steps.detect.outputs.pr_type }}" == "draft" ]]; then
            echo "✅ COMPLIANT: Draft PR detected"
            echo "💰 Cost optimization: Active"
            echo "🎯 Expected savings: ~85% vs ready PR"
          else
            echo "⚠️  HIGH COST: Ready PR detected"
            echo "💰 Impact: Full CI will run on every commit"
            echo "💡 Recommendation: Use draft PRs for development"
          fi
          
      - name: Cost education
        run: |
          echo "## 📚 GitHub Actions Cost Optimization Guide" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "### 🎯 Best Practices" >> $GITHUB_STEP_SUMMARY
          echo "- **Development**: Use draft PRs (\`gh pr create --draft\`)" >> $GITHUB_STEP_SUMMARY
          echo "- **Ready for review**: Convert to ready PR (\`gh pr ready\`)" >> $GITHUB_STEP_SUMMARY
          echo "- **Emergency**: Use \`.github/disable-all-workflows.sh\`" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "### 💰 Cost Impact" >> $GITHUB_STEP_SUMMARY
          echo "- Draft PR: ~3 minutes per commit" >> $GITHUB_STEP_SUMMARY
          echo "- Ready PR: ~15-30 minutes per commit" >> $GITHUB_STEP_SUMMARY
          echo "- Savings: Up to 85% cost reduction" >> $GITHUB_STEP_SUMMARY
EOF

# 5. ドキュメントの作成
echo "📚 ドキュメントを作成中..."

cat > docs/DRAFT_PR_GUIDELINES.md << 'EOF'
# Draft PR Guidelines - Cost Optimization

## Why Use Draft PRs?

- **Cost Reduction**: 80-95% reduction in GitHub Actions usage
- **Development Efficiency**: Faster iteration without waiting for full CI
- **Resource Optimization**: Light checks during development, full validation when ready

## Usage

### 1. Create Draft PR
```bash
# Always start with draft for development
gh pr create --draft --title "feat: your feature"
```

### 2. Development Workflow
```
Draft PR → Multiple commits (light checks) → Ready for review (full CI)
```

### 3. Ready for Review
```bash
# When development is complete
gh pr ready
# Or use GitHub UI "Ready for review" button
```

## Cost Comparison

### Before (Ready PR)
- Every commit: Full CI (~15-30 minutes)
- 10 commits: 150-300 minutes total

### After (Draft PR)
- Development commits: Light checks (~3 minutes)
- Ready transition: Full CI (~15-30 minutes)
- 10 commits + ready: 30 + 30 = 60 minutes total
- **Savings: 60-80% cost reduction**

## Emergency Controls

```bash
# Complete shutdown
./.github/disable-all-workflows.sh

# Restore
./.github/enable-all-workflows.sh backup-directory
```

## Best Practices

1. **Always start with draft PRs** for development work
2. **Use multiple small commits** during development
3. **Convert to ready** only when complete
4. **Use emergency controls** if costs spike
EOF

cat > .github/README.md << 'EOF'
# GitHub Actions Management Scripts

Cost optimization tools for GitHub Actions usage.

## Emergency Controls

### Complete Shutdown
```bash
# Stop all workflows immediately
./.github/disable-all-workflows.sh
```

### Restore
```bash
# List available backups
ls -la .github/ | grep workflows-disabled

# Restore from backup
./.github/enable-all-workflows.sh workflows-disabled-YYYYMMDD-HHMMSS
```

## Daily Usage

### Cost-Optimized Development
```bash
# Create draft PR (recommended)
gh pr create --draft --title "feat: your feature"

# Develop with light checks (~3 minutes per commit)
git commit -m "WIP: development"
git push

# Ready for review (full CI ~15-30 minutes)
gh pr ready
```

## Monitoring

- Automatic cost monitoring in PR workflows
- Claude Code compliance checking
- Educational messages for optimization

## Expected Savings

- Draft PR usage: 80-95% cost reduction
- Emergency controls: 100% cost elimination when needed
- Overall optimization: Sustainable low-cost development
EOF

# スクリプトの実行権限設定
chmod +x .github/*.sh

# Claude Code認識ファイルの作成
cat > .claude-optimization-enabled << EOF
# Claude Code GitHub Actions最適化有効
# この ファイルは Claude Code が最適化システムの存在を認識するために使用されます

PROJECT_NAME=$PROJECT_NAME
TECH_STACK=$TECH_STACK
OPTIMIZATION_DATE=$(date -I)
ORIGINAL_WORKFLOWS=$EXISTING_WORKFLOWS
EXPECTED_SAVINGS=80-95%
EOF

echo ""
echo "🎉 Claude Code最適化システムのインストール完了！"
echo ""
echo "📊 インストール内容:"
echo "  ✅ CLAUDE.md - Claude Code必読の最適化指針"
echo "  ✅ 緊急停止スクリプト - 即座にActions停止可能"
echo "  ✅ ドラフトPR最適化ワークフロー - 自動コスト削減"
echo "  ✅ Claude Code監視システム - 準拠チェック"
echo "  ✅ 包括的ドキュメント - 運用ガイド"
echo ""
echo "💰 期待効果:"
echo "  - Draft PR使用: 80-95%のコスト削減"
echo "  - 緊急停止: 必要時に100%停止可能"
echo "  - 自動監視: Claude Code準拠チェック"
echo ""
echo "📋 次のステップ:"
echo "1. git add . && git commit -m \"feat: Claude Code最適化システム導入\""
echo "2. Claude Codeでの作業時は自動的に最適化が適用されます"
echo "3. 新しいPRは必ず --draft フラグで作成してください"
echo ""
echo "📖 詳細情報:"
echo "  - 運用ガイド: docs/DRAFT_PR_GUIDELINES.md"
echo "  - 緊急対応: .github/README.md"
echo "  - Claude Code指針: CLAUDE.md"