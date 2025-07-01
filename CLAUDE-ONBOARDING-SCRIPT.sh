#!/bin/bash
# Claude Code Onboarding Script for GitHub Actions Optimization
# 稼働中のClaude Codeに最適化システムを適用するスクリプト

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Unicode icons
CHECKMARK="✅"
WARNING="⚠️"
ERROR="❌"
INFO="ℹ️"
ROCKET="🚀"

echo -e "${BLUE}${ROCKET} Claude Code GitHub Actions 最適化システム${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "success") echo -e "${GREEN}${CHECKMARK} ${message}${NC}" ;;
        "warning") echo -e "${YELLOW}${WARNING} ${message}${NC}" ;;
        "error") echo -e "${RED}${ERROR} ${message}${NC}" ;;
        "info") echo -e "${BLUE}${INFO} ${message}${NC}" ;;
    esac
}

# Function to check prerequisites
check_prerequisites() {
    print_status "info" "前提条件をチェック中..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_status "error" "Gitリポジトリではありません"
        exit 1
    fi
    
    # Check if GitHub CLI is available
    if ! command -v gh &> /dev/null; then
        print_status "warning" "GitHub CLI (gh) が見つかりません。一部機能が制限されます"
    else
        print_status "success" "GitHub CLI が利用可能です"
    fi
    
    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        print_status "error" "curl が必要です"
        exit 1
    fi
    
    print_status "success" "前提条件チェック完了"
    echo ""
}

# Function to save current work
save_current_work() {
    print_status "info" "現在の作業状況を確認中..."
    
    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        print_status "warning" "未コミットの変更があります"
        read -p "現在の作業を一時保存しますか？ (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git add .
            git commit -m "wip: save work before applying optimization system"
            print_status "success" "作業内容を保存しました"
        else
            print_status "warning" "未保存の変更がありますが、続行します"
        fi
    else
        print_status "success" "クリーンな状態です"
    fi
    
    # Show current branch and PRs
    current_branch=$(git branch --show-current)
    print_status "info" "現在のブランチ: $current_branch"
    
    if command -v gh &> /dev/null; then
        open_prs=$(gh pr list --author @me --state open --json number,title 2>/dev/null | jq -r '.[] | "#\(.number) \(.title)"' || echo "なし")
        print_status "info" "オープンなPR: $open_prs"
    fi
    echo ""
}

# Function to apply optimization system
apply_optimization() {
    print_status "info" "最適化システムを適用中..."
    
    # Create .github/workflows directory if it doesn't exist
    mkdir -p .github/workflows
    
    # Download CLAUDE.md
    print_status "info" "CLAUDE.md をダウンロード中..."
    if curl -sSL -o CLAUDE.md "https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/templates/CLAUDE.md"; then
        print_status "success" "CLAUDE.md をダウンロードしました"
    else
        print_status "error" "CLAUDE.md のダウンロードに失敗しました"
        exit 1
    fi
    
    # Download draft-pr-quick-check workflow
    print_status "info" "ドラフトPRワークフローをダウンロード中..."
    if curl -sSL -o .github/workflows/draft-pr-quick-check.yml "https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/templates/draft-pr-quick-check.yml"; then
        print_status "success" "ドラフトPRワークフローをダウンロードしました"
    else
        print_status "error" "ワークフローのダウンロードに失敗しました"
        exit 1
    fi
    
    # Ask about multi-instance support
    read -p "複数のClaude Codeインスタンスを使用しますか？ (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        apply_multi_instance
    fi
    
    print_status "success" "最適化システムの適用が完了しました"
    echo ""
}

# Function to apply multi-instance coordination
apply_multi_instance() {
    print_status "info" "マルチインスタンス調整システムを適用中..."
    
    # Create coordination directories
    mkdir -p scripts .claude/{sessions,locks,tasks,logs,file_locks}
    
    # Download coordinator script
    if curl -sSL -o scripts/claude-coordinator.sh "https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/scripts/claude-coordinator.sh"; then
        chmod +x scripts/claude-coordinator.sh
        print_status "success" "調整システムをダウンロードしました"
    else
        print_status "error" "調整システムのダウンロードに失敗しました"
        return 1
    fi
    
    # Download multi-instance CLAUDE.md
    if curl -sSL -o CLAUDE.md "https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/templates/CLAUDE-multi-instance.md"; then
        print_status "success" "マルチインスタンス版CLAUDE.mdをダウンロードしました"
    else
        print_status "warning" "マルチインスタンス版CLAUDE.mdのダウンロードに失敗しました"
    fi
    
    # Initialize coordination system
    if ./scripts/claude-coordinator.sh init; then
        print_status "success" "調整システムを初期化しました"
    else
        print_status "warning" "調整システムの初期化で問題が発生しました"
    fi
    
    # Generate instance ID
    export CLAUDE_INSTANCE_ID="claude-$(date +%s)-$(openssl rand -hex 4 2>/dev/null || echo "$$")"
    echo "export CLAUDE_INSTANCE_ID=\"$CLAUDE_INSTANCE_ID\"" >> ~/.bashrc
    print_status "success" "インスタンスID: $CLAUDE_INSTANCE_ID"
}

# Function to verify installation
verify_installation() {
    print_status "info" "インストールを検証中..."
    
    # Check if CLAUDE.md exists and has content
    if [ -f "CLAUDE.md" ] && [ -s "CLAUDE.md" ]; then
        print_status "success" "CLAUDE.md が正常にインストールされました"
    else
        print_status "error" "CLAUDE.md の確認に失敗しました"
        exit 1
    fi
    
    # Check if draft workflow exists
    if [ -f ".github/workflows/draft-pr-quick-check.yml" ]; then
        print_status "success" "ドラフトPRワークフローが正常にインストールされました"
    else
        print_status "error" "ワークフローファイルの確認に失敗しました"
        exit 1
    fi
    
    # Check multi-instance components if applicable
    if [ -f "scripts/claude-coordinator.sh" ]; then
        print_status "success" "マルチインスタンス調整システムが利用可能です"
    fi
    
    print_status "success" "インストール検証完了"
    echo ""
}

# Function to provide next steps
provide_next_steps() {
    echo -e "${GREEN}${ROCKET} セットアップが完了しました！${NC}"
    echo ""
    echo -e "${BLUE}📋 次のステップ:${NC}"
    echo ""
    echo -e "${YELLOW}1. Claude Code への指示:${NC}"
    echo "   Claude Code に以下を伝えてください："
    echo "   「CLAUDE.mdファイルが更新されました。内容を確認して、今後は必ずドラフトPRで作業してください。」"
    echo ""
    echo -e "${YELLOW}2. テスト実行:${NC}"
    echo "   # テスト用の変更を作成"
    echo "   echo '# Optimization Test' >> README.md"
    echo "   git add README.md"
    echo "   git commit -m 'test: optimization system verification'"
    echo ""
    echo -e "${YELLOW}3. 効果確認:${NC}"
    echo "   - 次のPRがドラフトで作成されることを確認"
    echo "   - CI実行時間が1-3分に短縮されることを確認"
    echo "   - gh run list --limit 1 でワークフロー実行を確認"
    echo ""
    
    if [ -f "scripts/claude-coordinator.sh" ]; then
        echo -e "${YELLOW}4. マルチインスタンス使用時:${NC}"
        echo "   ./scripts/claude-coordinator.sh status  # 状態確認"
        echo "   ./scripts/claude-coordinator.sh check   # 競合チェック"
        echo ""
    fi
    
    echo -e "${YELLOW}5. サポート:${NC}"
    echo "   問題がある場合は以下を参照："
    echo "   - FAQ: https://github.com/ootakazuhiko/claude-actions-optimizer/blob/main/FAQ-TROUBLESHOOTING-ja.md"
    echo "   - Issues: https://github.com/ootakazuhiko/claude-actions-optimizer/issues"
    echo ""
    echo -e "${GREEN}${CHECKMARK} GitHub Actions コストを95%削減する準備が整いました！${NC}"
}

# Function to create a test
create_test() {
    print_status "info" "動作テストを実行しますか？"
    read -p "テスト用のコミットを作成しますか？ (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "# Claude Actions Optimizer Test" >> README.md
        git add README.md
        git commit -m "test: Claude Actions optimization system verification"
        print_status "success" "テストコミットを作成しました"
        
        if command -v gh &> /dev/null; then
            print_status "info" "Claude Code にドラフトPRの作成を指示してください"
            echo "推奨コマンド: gh pr create --draft --title 'test: optimization verification'"
        fi
    fi
}

# Main execution
main() {
    check_prerequisites
    save_current_work
    apply_optimization
    verify_installation
    create_test
    provide_next_steps
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --multi-instance)
            FORCE_MULTI_INSTANCE=true
            shift
            ;;
        --test-only)
            TEST_ONLY=true
            shift
            ;;
        --help)
            echo "Usage: $0 [--multi-instance] [--test-only] [--help]"
            echo "  --multi-instance  : Force multi-instance setup"
            echo "  --test-only      : Only create test, don't install"
            echo "  --help           : Show this help"
            exit 0
            ;;
        *)
            print_status "error" "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Execute main function if not test-only
if [ "$TEST_ONLY" = true ]; then
    create_test
else
    main
fi