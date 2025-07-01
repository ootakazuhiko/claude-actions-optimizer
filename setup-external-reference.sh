#!/bin/bash
# 外部プロジェクトからclaude-actions-optimizerを参照するためのセットアップスクリプト

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}claude-actions-optimizer 外部参照セットアップ${NC}"
echo -e "${BLUE}=====================================${NC}"
echo

# claude-actions-optimizerのパスを取得
CLAUDE_OPTIMIZER_PATH=$(cd "$(dirname "$0")" && pwd)
echo -e "${GREEN}✓ claude-actions-optimizer パス: $CLAUDE_OPTIMIZER_PATH${NC}"

# 対象プロジェクトのパスを取得
echo -e "${YELLOW}セットアップ対象のプロジェクトパスを入力してください:${NC}"
read -p "パス: " TARGET_PROJECT_PATH

# パスの存在確認
if [ ! -d "$TARGET_PROJECT_PATH" ]; then
    echo -e "${RED}エラー: 指定されたパスが存在しません${NC}"
    exit 1
fi

cd "$TARGET_PROJECT_PATH"

# 既存のclaude-actions-optimizerディレクトリの確認
if [ -d "claude-actions-optimizer" ]; then
    echo -e "${YELLOW}既存のclaude-actions-optimizerディレクトリが見つかりました${NC}"
    echo "どのように処理しますか？"
    echo "1) バックアップして置き換える"
    echo "2) 削除して置き換える"
    echo "3) キャンセル"
    read -p "選択 (1-3): " choice
    
    case $choice in
        1)
            backup_name="claude-actions-optimizer.backup.$(date +%Y%m%d_%H%M%S)"
            mv claude-actions-optimizer "$backup_name"
            echo -e "${GREEN}✓ バックアップ作成: $backup_name${NC}"
            ;;
        2)
            rm -rf claude-actions-optimizer
            echo -e "${GREEN}✓ 既存ディレクトリを削除しました${NC}"
            ;;
        3)
            echo -e "${YELLOW}セットアップをキャンセルしました${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}無効な選択です${NC}"
            exit 1
            ;;
    esac
fi

# シンボリックリンクの作成
echo -e "${BLUE}シンボリックリンクを作成しています...${NC}"
ln -s "$CLAUDE_OPTIMIZER_PATH" claude-actions-optimizer
echo -e "${GREEN}✓ シンボリックリンクを作成しました${NC}"

# .gitignoreの更新
if [ -f ".gitignore" ]; then
    if ! grep -q "^claude-actions-optimizer$" .gitignore; then
        echo -e "${BLUE}.gitignoreを更新しています...${NC}"
        echo "" >> .gitignore
        echo "# claude-actions-optimizer external reference" >> .gitignore
        echo "claude-actions-optimizer" >> .gitignore
        echo -e "${GREEN}✓ .gitignoreを更新しました${NC}"
    else
        echo -e "${GREEN}✓ .gitignoreは既に設定済みです${NC}"
    fi
fi

# 環境変数スクリプトの作成
echo -e "${BLUE}環境設定スクリプトを作成しています...${NC}"
cat > .claude-optimizer-env.sh << EOF
#!/bin/bash
# claude-actions-optimizer 環境設定
export CLAUDE_OPTIMIZER_PATH="$CLAUDE_OPTIMIZER_PATH"

# エイリアスの設定（オプション）
alias claude-install="\$CLAUDE_OPTIMIZER_PATH/install.sh"
alias claude-update="cd \$CLAUDE_OPTIMIZER_PATH && git pull origin main && cd -"

echo "claude-actions-optimizer 環境が設定されました"
echo "パス: \$CLAUDE_OPTIMIZER_PATH"
EOF

chmod +x .claude-optimizer-env.sh
echo -e "${GREEN}✓ 環境設定スクリプトを作成しました: .claude-optimizer-env.sh${NC}"

# 完了メッセージ
echo
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}セットアップが完了しました！${NC}"
echo -e "${GREEN}=====================================${NC}"
echo
echo -e "${BLUE}使用方法:${NC}"
echo "1. 環境変数を読み込む:"
echo "   source .claude-optimizer-env.sh"
echo
echo "2. インストールスクリプトを実行:"
echo "   ./claude-actions-optimizer/install.sh"
echo
echo "3. 最新版に更新:"
echo "   cd $CLAUDE_OPTIMIZER_PATH && git pull origin main"
echo
echo -e "${YELLOW}ヒント: .bashrc や .zshrc に以下を追加すると便利です:${NC}"
echo "source $TARGET_PROJECT_PATH/.claude-optimizer-env.sh"