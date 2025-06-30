# Claude Actions Optimizer 完全導入ガイド

## 📋 目次

1. [導入概要](#導入概要)
2. [前提条件](#前提条件)
3. [段階別導入手順](#段階別導入手順)
4. [メイン端末での完全導入](#メイン端末での完全導入)
5. [クライアント端末での設定](#クライアント端末での設定)
6. [動作確認](#動作確認)
7. [運用開始](#運用開始)

---

## 🎯 導入概要

### システム構成

```
                    GitHub Repository
                    ┌─────────────────┐
                    │  ワークフロー    │
                    │  設定ファイル    │
                    │  ラベル設定      │
                    └─────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
    メイン端末         端末2              端末3
  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
  │ 完全導入     │  │ クライアント │  │ クライアント │
  │ - 全機能     │  │ - 個体識別   │  │ - 個体識別   │
  │ - 調整機能   │  │ - 調整機能   │  │ - 調整機能   │
  │ - 管理機能   │  │              │  │              │
  └──────────────┘  └──────────────┘  └──────────────┘
       Alice             Bob             Charlie
    (Frontend)        (Backend)         (DevOps)
```

### 導入により実現すること

- ✅ **95%のコスト削減**: GitHub Actions実行時間の大幅短縮
- ✅ **マルチインスタンス対応**: 複数Claude Codeの並行作業
- ✅ **個体識別**: 各Claude Codeの作業追跡
- ✅ **役割管理**: 専門分野別のタスク割り当て
- ✅ **競合防止**: ファイルロック機構

---

## 📋 前提条件

### 必要なツール

```bash
# すべての端末で必要
git --version          # Git 2.20+
gh --version           # GitHub CLI 2.0+
bash --version         # Bash 4.0+
curl --version         # curl (or wget)

# メイン端末でのみ必要
jq --version           # JSON processor
yamllint --version     # YAML validator (optional)
```

### GitHub権限

- リポジトリの**Admin**権限（ワークフロー設定、ラベル作成のため）
- または**Write**権限 + **Actions**管理権限

### 確認コマンド

```bash
# GitHub CLI認証確認
gh auth status

# リポジトリ権限確認
gh repo view --json permissions

# 必要な権限: "admin": true または "push": true + actions管理権限
```

---

## 🚀 段階別導入手順

### フェーズ1: リポジトリ準備
1. GitHub リポジトリ側設定
2. 基本ワークフローの導入

### フェーズ2: メイン端末セットアップ
1. 完全システム導入
2. 調整機能の初期化
3. 動作確認

### フェーズ3: クライアント端末セットアップ
1. 個体識別設定
2. 調整機能接続
3. テスト実行

---

## 🏗️ メイン端末での完全導入

### Step 1: リポジトリクローンと移動

```bash
# リポジトリをクローン（まだの場合）
git clone https://github.com/your-org/your-project.git
cd your-project

# またはすでにある場合
cd /path/to/your-project
git pull origin main
```

### Step 2: 最適化システムの完全導入

```bash
# 最新の最適化システムをダウンロード
curl -sSL -o setup-complete.sh https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/install.sh

# 完全インストール実行
chmod +x setup-complete.sh
./setup-complete.sh --complete --multi-instance

# または手動で段階的に実行
mkdir -p temp-optimizer
cd temp-optimizer
git clone https://github.com/ootakazuhiko/claude-actions-optimizer.git
cd claude-actions-optimizer

# プロジェクトディレクトリに戻って実行
cd ../../
./temp-optimizer/claude-actions-optimizer/install.sh --complete --multi-instance
```

### Step 3: GitHub リポジトリ設定

```bash
# 必要なGitHubラベルを作成
gh label create "claude:frontend" --color "FF6B6B" --description "Frontend Claude instance"
gh label create "claude:backend" --color "4ECDC4" --description "Backend Claude instance"
gh label create "claude:devops" --color "45B7D1" --description "DevOps Claude instance"
gh label create "claude:fullstack" --color "96CEB4" --description "Fullstack Claude instance"
gh label create "claude:testing" --color "FFEAA7" --description "Testing Claude instance"
gh label create "claude:documentation" --color "DDA0DD" --description "Documentation Claude instance"

# ブランチ保護ルールの設定（オプション）
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["draft-pr-quick-check"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null
```

### Step 4: メイン管理者の個体識別設定

```bash
# 管理者として自分のClaude Codeを設定
./scripts/claude-identity.sh setup

# 例: 
# Name: Admin
# Role: fullstack
# Specialty: "Project Management, Full-stack Development, System Administration"

# 設定確認
./scripts/claude-identity.sh status
```

### Step 5: 調整システムの初期化

```bash
# マルチインスタンス調整システム初期化
./scripts/claude-coordinator.sh init

# 状態確認
./scripts/claude-coordinator.sh status

# 設定ファイル確認
ls -la .claude/
```

### Step 6: 初期設定をコミット

```bash
# 設定ファイルをリポジトリに追加
git add .github/ .claude/ CLAUDE.md scripts/
git commit -m "feat: setup Claude Actions Optimizer complete system

✅ GitHub Actions optimization system deployed
✅ Multi-instance coordination enabled
✅ Identity management configured
✅ 95% cost reduction active

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# リモートにプッシュ
git push origin main
```

---

## 💻 クライアント端末での設定

### Step 1: リポジトリの取得

```bash
# 既存プロジェクトをクローン
git clone https://github.com/your-org/your-project.git
cd your-project

# 最新の設定を取得
git pull origin main
```

### Step 2: クライアント環境のセットアップ

```bash
# 必要な権限を設定
chmod +x scripts/claude-*.sh

# 調整システムが利用可能か確認
./scripts/claude-coordinator.sh status
```

### Step 3: 個体識別の設定

```bash
# 各端末で異なるClaude Codeとして設定
./scripts/claude-identity.sh setup

# 例: 端末2（Backend専門）
# Name: Bob
# Role: backend  
# Specialty: "Python, FastAPI, PostgreSQL, Redis"

# 例: 端末3（DevOps専門）
# Name: Charlie
# Role: devops
# Specialty: "Docker, Kubernetes, CI/CD, Monitoring"
```

### Step 4: 環境変数の永続化

```bash
# 設定を永続化
source .claude/identity/env.sh

# bashrcに追加（オプション）
echo "source $(pwd)/.claude/identity/env.sh" >> ~/.bashrc

# または毎回手動で実行
echo '#!/bin/bash
source .claude/identity/env.sh
echo "✅ Claude identity loaded: $CLAUDE_NAME ($CLAUDE_ROLE)"' > load-claude.sh
chmod +x load-claude.sh
```

### Step 5: 接続テスト

```bash
# 調整システムへの接続確認
./scripts/claude-coordinator.sh check

# 他のインスタンスが見えることを確認
./scripts/claude-coordinator.sh status

# 簡単なロックテスト
./scripts/claude-coordinator.sh lock test-file.txt
./scripts/claude-coordinator.sh unlock test-file.txt
```

---

## ✅ 動作確認

### 全端末での確認項目

#### 1. 基本機能確認

```bash
# 各端末で実行
echo "### 端末: $(hostname) ###"
echo "Claude Identity: $(cat .claude/identity/current.json | jq -r '.name + " (" + .role + ")"')"
echo "Instance ID: $CLAUDE_INSTANCE_ID"
echo "調整システム: $(./scripts/claude-coordinator.sh status | head -1)"
```

#### 2. 個体識別テスト

```bash
# テスト用ファイル作成
echo "# Test by $(cat .claude/identity/current.json | jq -r '.name')" > test-identity.md

# 識別情報付きコミット
./scripts/claude-identity.sh commit "test: identity verification for $(cat .claude/identity/current.json | jq -r '.name')"

# コミット確認
git log -1 --pretty=format:"%s%n%b" | head -5
```

#### 3. マルチインスタンス調整テスト

```bash
# 端末1で実行
./scripts/claude-coordinator.sh lock shared-test.txt
echo "Locked by $(cat .claude/identity/current.json | jq -r '.name')" > shared-test.txt

# 端末2で実行（失敗するはず）
./scripts/claude-coordinator.sh lock shared-test.txt
# Expected: ❌ File is already locked

# 端末1で解放
./scripts/claude-coordinator.sh unlock shared-test.txt

# 端末2で再試行（成功するはず）
./scripts/claude-coordinator.sh lock shared-test.txt
# Expected: ✅ Lock acquired
```

#### 4. ドラフトPR動作確認

```bash
# 各端末でテストPR作成
./scripts/claude-identity.sh pr "test: identity system verification" "Testing the identity and coordination system"

# GitHub上で確認
gh pr list --search "test: identity"
```

---

## 🎯 運用開始

### 日常の作業フロー

#### メイン管理者（Admin）の作業

```bash
# 毎朝の状況確認
./scripts/claude-coordinator.sh status
./scripts/claude-identity.sh list

# 週次レポート生成
./scripts/claude-identity.sh report 7

# 問題発生時の調整
./scripts/claude-coordinator.sh clean
```

#### 各専門端末での作業

```bash
# 作業開始時
source .claude/identity/env.sh
./scripts/claude-coordinator.sh check

# タスク取得
./scripts/claude-coordinator.sh assign-role-task $CLAUDE_ROLE

# ファイル編集前
./scripts/claude-coordinator.sh lock src/target-file.js

# 作業完了時
./scripts/claude-coordinator.sh complete task-id
```

### モニタリングとメンテナンス

#### 週次メンテナンス

```bash
# コスト効果の確認
echo "=== 週次コスト削減レポート ==="
gh api repos/:owner/:repo/actions/usage | jq '.total_minutes_used_in_billing_cycle'

# 活動統計
./scripts/claude-identity.sh report 7

# システムヘルスチェック
./scripts/claude-coordinator.sh status
ls -la .claude/file_locks/  # 不要なロックファイルがないか確認
```

#### 月次レビュー

```bash
# 全体的な効果測定
./scripts/claude-identity.sh report 30

# パフォーマンス分析
git log --since="1 month ago" --grep="\[.*-.*\]" --oneline | wc -l
gh pr list --search "is:merged \[" --limit 100 | wc -l

# 設定の最適化
# 役割分担の見直し
# タスク配分の調整
```

---

## 🆘 トラブルシューティング

### よくある問題と解決法

#### 1. 権限エラー

```bash
# 問題: "Permission denied" エラー
# 解決:
chmod +x scripts/claude-*.sh
chmod -R 755 .claude/

# GitHub CLI再認証
gh auth login --web
```

#### 2. インスタンス間の通信問題

```bash
# 問題: 他のインスタンスが見えない
# 解決:
# .claude ディレクトリの権限確認
ls -la .claude/

# 最新の状態を取得
git pull origin main

# 調整システム再初期化
./scripts/claude-coordinator.sh init
```

#### 3. ワークフロー実行エラー

```bash
# 問題: CI が実行されない
# 解決:
# ワークフロー確認
gh workflow list

# 有効化
gh workflow enable draft-pr-quick-check

# ログ確認
gh run list --limit 5
```

---

## 📊 導入効果の測定

### 導入前後の比較

```bash
# 導入効果測定スクリプト
cat > measure-effectiveness.sh << 'EOF'
#!/bin/bash
echo "=== Claude Actions Optimizer 導入効果測定 ==="
echo "測定期間: 過去30日"
echo ""

# CI実行時間の分析
echo "📊 CI実行時間分析:"
avg_time=$(gh run list --limit 100 --json durationMS | jq '[.[] | .durationMS] | add / length / 60000')
echo "  平均実行時間: ${avg_time}分"

draft_ratio=$(gh pr list --limit 100 --json isDraft | jq '[.[] | select(.isDraft == true)] | length')
total_prs=$(gh pr list --limit 100 | wc -l)
draft_percentage=$(echo "scale=1; $draft_ratio * 100 / $total_prs" | bc)
echo "  ドラフトPR率: ${draft_percentage}%"

# コスト推定
estimated_savings=$(echo "scale=2; ($total_prs * 19 * $draft_percentage / 100) * 0.008" | bc)
echo "  推定月間削減額: \$${estimated_savings}"

# インスタンス活動
echo ""
echo "🤖 Claude インスタンス活動:"
for role in frontend backend devops fullstack testing documentation; do
  commits=$(git log --since="30 days ago" --grep="\[$role-" --oneline | wc -l)
  [ "$commits" -gt 0 ] && echo "  $role: $commits commits"
done

# 競合状況
echo ""
echo "🔒 競合管理:"
conflicts=$(git log --since="30 days ago" --grep="merge conflict\|Merge conflict" --oneline | wc -l)
echo "  マージ競合: $conflicts件"
echo "  現在のロック: $(ls .claude/file_locks/ 2>/dev/null | wc -l)件"
EOF

chmod +x measure-effectiveness.sh
./measure-effectiveness.sh
```

---

## 🎉 導入完了

すべての手順が完了すると、以下が実現されます：

### ✅ 実現された機能

1. **95%のコスト削減**: ドラフトPRによる軽量CI
2. **マルチインスタンス対応**: 複数Claude Codeの並行作業
3. **個体識別**: GitHub上での作業追跡
4. **役割管理**: 専門分野別の効率的な作業
5. **競合防止**: 完全なファイルロック機構

### 📈 期待される効果

- **開発速度向上**: 即座のフィードバック（1-3分）
- **コスト削減**: 月数百ドルの節約
- **品質向上**: 競合なしでの安定した開発
- **可視性向上**: 全ての作業が追跡可能

### 🔄 継続的改善

- 月次でのパフォーマンスレビュー
- 役割分担の最適化
- 新機能の段階的導入

**導入完了日**: _______________  
**導入責任者**: _______________  
**参加インスタンス数**: _______________