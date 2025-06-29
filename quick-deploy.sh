#!/bin/bash
# Claude Code最適化システム - クイックデプロイ
# 既存プロジェクトに最速で最適化を適用

set -e

echo "⚡ Claude Code最適化システム - クイックデプロイ"
echo "Fastest deployment for existing projects"
echo ""

# 引数チェック
if [ $# -eq 0 ]; then
    echo "使用方法: $0 <project-directory> [project-type]"
    echo ""
    echo "project-type (optional):"
    echo "  nodejs    - Node.js project"
    echo "  python    - Python project"
    echo "  generic   - Generic project (default)"
    echo ""
    echo "例:"
    echo "  $0 /path/to/my-project nodejs"
    echo "  $0 . python"
    exit 1
fi

PROJECT_DIR="$1"
PROJECT_TYPE="${2:-generic}"

# プロジェクトディレクトリの確認
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ エラー: プロジェクトディレクトリが見つかりません: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"
PROJECT_NAME=$(basename "$(pwd)")

echo "📁 プロジェクト: $PROJECT_NAME"
echo "📋 タイプ: $PROJECT_TYPE"
echo "📍 パス: $(pwd)"
echo ""

# 技術スタックの自動検出（指定がない場合）
if [ "$PROJECT_TYPE" = "generic" ]; then
    if [ -f "package.json" ]; then
        PROJECT_TYPE="nodejs"
        echo "🔍 自動検出: Node.js project"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        PROJECT_TYPE="python"
        echo "🔍 自動検出: Python project"
    fi
fi

# 必要なディレクトリ作成
echo "📁 ディレクトリ構造を作成..."
mkdir -p .github/workflows .github/actions docs

# 1. 最小限のCLAUDE.md作成
echo "📝 CLAUDE.md作成..."
cat > CLAUDE.md << EOF
# CLAUDE.md

## 🚨 CRITICAL: GitHub Actions Cost Optimization

**MANDATORY**: All Claude Code instances MUST use draft PRs for development.

### Required Workflow
\`\`\`bash
# ✅ CORRECT: Always create draft PRs
gh pr create --draft --title "feat: your feature"

# ❌ WRONG: Never create ready PRs for development  
gh pr create --title "feat: your feature"
\`\`\`

### Emergency Controls
\`\`\`bash
# Complete shutdown
./.github/disable-all-workflows.sh

# Restore
./.github/enable-all-workflows.sh backup-directory
\`\`\`

### Cost Impact
- Draft PR: ~3 minutes per commit
- Ready PR: ~15-30 minutes per commit
- **Savings: 80-95% cost reduction**

## Claude Code Checklist
- [ ] Create draft PR with \`--draft\` flag
- [ ] Include draft PR explanation in description
- [ ] Use \`gh pr ready\` when complete
- [ ] Reference cost optimization in workflow
EOF

# 2. 緊急停止スクリプト
echo "🛑 緊急停止スクリプト作成..."
cat > .github/disable-all-workflows.sh << 'EOF'
#!/bin/bash
set -e
echo "🚨 GitHub Actions緊急停止"
if [ -d ".github/workflows" ]; then
    BACKUP_DIR="workflows-disabled-$(date +%Y%m%d-%H%M%S)"
    mv .github/workflows ".github/$BACKUP_DIR"
    echo "✅ 停止完了: .github/$BACKUP_DIR"
    echo "復元: mv .github/$BACKUP_DIR .github/workflows"
else
    echo "ワークフローディレクトリが見つかりません"
fi
EOF

cat > .github/enable-all-workflows.sh << 'EOF'
#!/bin/bash
set -e
if [ $# -eq 0 ]; then
    echo "使用方法: $0 <disabled-directory>"
    ls -la .github/ | grep workflows-disabled
    exit 1
fi
if [ -d ".github/$1" ]; then
    mv ".github/$1" .github/workflows
    echo "✅ 復元完了"
else
    echo "❌ エラー: .github/$1 が見つかりません"
fi
EOF

# 3. プロジェクトタイプ別の最適化ワークフロー
echo "⚙️ 最適化ワークフロー作成..."

if [ "$PROJECT_TYPE" = "nodejs" ]; then
    cat > .github/workflows/optimized-ci.yml << 'EOF'
name: Optimized CI (Node.js)
on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
jobs:
  draft-checks:
    if: github.event.pull_request.draft == true
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci --ignore-scripts
      - run: npm run lint || echo "No lint script"
      - run: npx tsc --noEmit || echo "No TypeScript"
  full-ci:
    if: github.event.pull_request.draft == false
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npm run lint
      - run: npm test
      - run: npm run build
EOF

elif [ "$PROJECT_TYPE" = "python" ]; then
    cat > .github/workflows/optimized-ci.yml << 'EOF'
name: Optimized CI (Python)
on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
jobs:
  draft-checks:
    if: github.event.pull_request.draft == true
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.11' }
      - run: python -m py_compile **/*.py || true
      - run: pip install flake8 && flake8 --select=E9,F63,F7,F82
  full-ci:
    if: github.event.pull_request.draft == false
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.11' }
      - run: pip install -r requirements.txt || pip install -e .
      - run: pip install flake8 pytest
      - run: flake8
      - run: pytest
EOF

else
    cat > .github/workflows/optimized-ci.yml << 'EOF'
name: Optimized CI (Generic)
on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
jobs:
  draft-checks:
    if: github.event.pull_request.draft == true
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Basic validation
        run: |
          echo "✅ Draft PR light checks"
          find . -name "*.sh" -exec shellcheck {} \; || true
  full-ci:
    if: github.event.pull_request.draft == false
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Full validation
        run: |
          echo "🧪 Full CI checks"
          # Add your project-specific CI steps here
EOF
fi

# 4. 簡易ドキュメント
echo "📚 ドキュメント作成..."
cat > docs/QUICK_GUIDE.md << 'EOF'
# Claude Code最適化 - クイックガイド

## 使用方法

### 開発開始
```bash
gh pr create --draft --title "feat: 新機能"
```

### 開発中
```bash
git commit -m "WIP: 実装中"
git push  # 軽量チェック（~3分）
```

### 完成時
```bash
gh pr ready  # フルCI（~15-30分）
```

### 緊急停止
```bash
./.github/disable-all-workflows.sh
```

## 効果
- Draft PR: 80-95%コスト削減
- 開発効率: 大幅なCI待機時間短縮
EOF

# 5. 実行権限設定
chmod +x .github/*.sh

# 6. 最適化フラグ作成
cat > .claude-optimization-enabled << EOF
QUICK_DEPLOY=true
PROJECT_TYPE=$PROJECT_TYPE
DEPLOY_DATE=$(date -I)
EXPECTED_SAVINGS=80-95%
EOF

echo ""
echo "🎉 クイックデプロイ完了！"
echo ""
echo "📊 導入内容:"
echo "  ✅ CLAUDE.md - 最適化指針"
echo "  ✅ 緊急停止スクリプト"
echo "  ✅ $PROJECT_TYPE 最適化ワークフロー"
echo "  ✅ クイックガイド"
echo ""
echo "💰 期待効果: 80-95%のコスト削減"
echo ""
echo "📋 次のステップ:"
echo "1. git add . && git commit -m \"feat: Claude Code最適化導入\""
echo "2. 今後のPRは --draft フラグで作成"
echo "3. 緊急時は ./.github/disable-all-workflows.sh"
echo ""
echo "📖 詳細: docs/QUICK_GUIDE.md"