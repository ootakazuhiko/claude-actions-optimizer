# 実践的な使い方ガイド

## 📚 このガイドについて

このガイドでは、Claude Code GitHub Actions最適化システムを実際のプロジェクトで使用する際の、具体的な手順とベストプラクティスを説明します。

---

## 🎯 利用シナリオ別ガイド

### シナリオ1: 個人開発者（単一Claude Code）

#### 状況
- 個人でWebアプリケーションを開発
- Claude Codeを1つ使用
- GitHub Actionsの課金を抑えたい

#### セットアップ手順

```bash
# 1. プロジェクトディレクトリに移動
cd my-web-app

# 2. 最適化システムをインストール
curl -sSL https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/quick-deploy.sh | bash

# 3. 確認
cat CLAUDE.md  # Claude用の指示書が作成されている
ls -la .github/workflows/  # ワークフローが最適化されている
```

#### 日常の開発フロー

```bash
# 朝の作業開始
git pull origin main
git checkout -b feature/user-authentication

# Claude Codeで開発（自動的にドラフトPRを作成）
# Claude: "ユーザー認証機能を実装してください"
# → 自動的にドラフトPRが作成される

# 開発中は軽量チェックのみ（1分）
git add .
git commit -m "feat: add login form"
git push
# → 構文チェックとセキュリティスキャンのみ実行

# レビュー準備ができたら
gh pr ready
# → フルテスト実行（20分）
```

#### 💡 ポイント
- 開発中は常にドラフトPRを使用
- `gh pr ready`は本当に必要な時だけ実行
- 1日の終わりにまとめてレビュー準備

---

### シナリオ2: チーム開発（複数Claude Code）

#### 状況
- 3人のチームで開発
- 各メンバーがClaude Codeを使用
- 同時に異なる機能を開発

#### 初期セットアップ

```bash
# チームリーダーが実行
cd team-project
./claude-actions-optimizer/install.sh --multi-instance

# 各メンバーに共有
echo "調整システムをセットアップしました。
READMEの'マルチインスタンス開発'セクションを確認してください。" | 
gh issue create --title "Claude Code調整システム導入" --body -
```

#### チームメンバーA（認証機能担当）

```bash
# 作業開始前に必ず実行
./scripts/claude-coordinator.sh check
# 出力:
# 👥 アクティブインスタンス: 2
# 🔒 ロック中: src/components/Header.tsx (メンバーB)
# ✅ src/auth/* は編集可能

# タスクを取得
./scripts/claude-coordinator.sh claim auth-implementation
# → 自動的にブランチ作成: claude-a1b2c3d4/auth-implementation

# ファイル編集前にロック
./scripts/claude-coordinator.sh lock src/auth/login.tsx
# 🔒 ロック取得成功

# Claude Codeで開発
# "ログイン機能を実装してください"

# 作業完了
./scripts/claude-coordinator.sh complete auth-implementation
# → 自動的にロック解放、ドラフトPR作成
```

#### チームメンバーB（UI改善担当）

```bash
# 同時刻に別の作業
./scripts/claude-coordinator.sh check
# 👥 アクティブインスタンス: 2
# 🔒 ロック中: src/auth/login.tsx (メンバーA)
# ✅ src/components/* は編集可能（Header.tsx以外）

# UIコンポーネントの作業
./scripts/claude-coordinator.sh claim ui-improvements
./scripts/claude-coordinator.sh lock src/components/Button.tsx
# 🔒 ロック取得成功

# 並行して開発可能！
```

#### 💡 チーム開発のコツ

1. **朝会での調整**
   ```bash
   # 全員で状態確認
   ./scripts/claude-coordinator.sh status --team
   ```

2. **タスクの事前登録**
   ```yaml
   # .claude/tasks.yml
   tasks:
     - id: auth-001
       description: "ログイン機能"
       files: ["src/auth/*"]
       assigned: null
       
     - id: ui-001  
       description: "ボタンコンポーネント改善"
       files: ["src/components/Button.*"]
       assigned: null
   ```

3. **競合時の対処**
   ```bash
   # ロックが取れない場合
   ./scripts/claude-coordinator.sh lock src/shared/config.ts
   # ❌ 既にロックされています (by メンバーC)
   
   # 選択肢:
   # 1. 別のファイルで作業
   # 2. ロック解放を待つ（最大60分）
   # 3. Slackで調整
   ```

---

### シナリオ3: 大規模プロジェクト

#### 状況
- 10人以上の開発チーム
- 複数のマイクロサービス
- 厳格なコスト管理が必要

#### エンタープライズ設定

```bash
# 1. 中央管理リポジトリ作成
gh repo create company/claude-optimizer-config --private

# 2. 組織全体の設定
cat > claude-config.yml << EOF
organization:
  max_instances: 10
  cost_limit_daily: 50  # $50/日
  
projects:
  - name: frontend
    max_instances: 3
    workflows:
      - build
      - test
      - e2e
      
  - name: backend
    max_instances: 5
    workflows:
      - test
      - integration
      - security

monitoring:
  slack_webhook: ${SLACK_WEBHOOK}
  alert_threshold: 0.8  # 80%でアラート
EOF

# 3. 各プロジェクトに展開
for project in frontend backend shared; do
  cd $project
  ../claude-actions-optimizer/install.sh --config ../claude-config.yml
done
```

#### モニタリングダッシュボード

```bash
# コスト監視スクリプト
cat > monitor-costs.sh << 'EOF'
#!/bin/bash
# 日次レポート生成
echo "=== Claude Code コスト日報 ==="
echo "日付: $(date +%Y-%m-%d)"
echo ""

# 各プロジェクトのコスト集計
for project in frontend backend shared; do
  minutes=$(gh api repos/company/$project/actions/usage | jq '.minutes_used')
  cost=$(echo "$minutes * 0.008" | bc)
  echo "$project: ${minutes}分 (\$${cost})"
done

# アラート判定
total=$(gh api orgs/company/actions/usage | jq '.total_minutes_used')
if [ $total -gt 6000 ]; then  # 50ドル相当
  echo "⚠️ コスト警告: 本日の使用量が制限に近づいています"
  # Slackに通知
fi
EOF

# cronで自動実行
echo "0 18 * * * /path/to/monitor-costs.sh" | crontab -
```

---

## 🔧 実践的なTips

### 1. 効率的なブランチ戦略

```bash
# ❌ 避けるべきパターン
git checkout -b feature/big-feature
# 大きな機能を1つのPRに

# ✅ 推奨パターン
git checkout -b feature/auth-step1-ui
# 小さく分割、ドラフトPRで随時確認
git checkout -b feature/auth-step2-logic
git checkout -b feature/auth-step3-tests
```

### 2. コミットメッセージの工夫

```bash
# Claude Code用のプレフィックス
git commit -m "wip: [skip-heavy-tests] UIの仮実装"
git commit -m "feat: [ready-for-review] ログイン機能完成"

# 自動化スクリプト
alias gcommit-wip='git commit -m "wip: [skip-ci] $(date +%H:%M) - "'
alias gcommit-ready='git commit -m "feat: [full-test] "'
```

### 3. 緊急時の操作

#### 本番障害対応時

```bash
# 1. 全Claude Codeを一時停止
echo "EMERGENCY_MODE=true" > .claude/emergency

# 2. 手動で緊急修正
git checkout -b hotfix/critical-bug
# 手動修正...

# 3. 通常CIをスキップしてデプロイ
git push origin hotfix/critical-bug
gh pr create --title "[EMERGENCY] Critical fix" --body "Skip all checks"

# 4. 復旧後
rm .claude/emergency
```

### 4. カスタムワークフローとの統合

```yaml
# .github/workflows/custom-deploy.yml
name: Custom Deploy
on:
  pull_request:
    types: [labeled]
    
jobs:
  deploy-preview:
    if: contains(github.event.label.name, 'deploy-preview')
    # ドラフトでもプレビューデプロイは実行
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to preview
        run: |
          # デプロイ処理
```

---

## 📊 パフォーマンス最適化

### メトリクス収集

```bash
# 週次パフォーマンスレポート
cat > weekly-report.sh << 'EOF'
#!/bin/bash
echo "=== 週次パフォーマンスレポート ==="
echo "期間: $(date -d '7 days ago' +%Y-%m-%d) - $(date +%Y-%m-%d)"

# ドラフトPR vs 通常PR
draft_count=$(gh pr list --search "is:draft created:>$(date -d '7 days ago' +%Y-%m-%d)" | wc -l)
ready_count=$(gh pr list --search "-is:draft created:>$(date -d '7 days ago' +%Y-%m-%d)" | wc -l)

echo "ドラフトPR: $draft_count"
echo "通常PR: $ready_count"
echo "最適化率: $(( draft_count * 100 / (draft_count + ready_count) ))%"

# 平均CI時間
echo ""
echo "平均CI実行時間:"
gh run list --limit 100 --json conclusion,durationMS | \
  jq -r '.[] | select(.conclusion=="success") | .durationMS' | \
  awk '{sum+=$1; count++} END {print sum/count/1000 " 秒"}'
EOF
```

### ボトルネック分析

```bash
# 最も時間のかかるジョブを特定
gh run list --limit 20 --json name,durationMS | \
  jq -r '.[] | "\(.durationMS/1000)秒 \(.name)"' | \
  sort -rn | head -5

# 最適化候補の提案
./scripts/analyze-workflows.sh --suggest-optimizations
```

---

## 🎓 ベストプラクティス

### DO ✅

1. **毎朝の習慣**
   ```bash
   ./scripts/claude-coordinator.sh check
   git pull origin main
   ```

2. **こまめなコミット**
   - 1時間ごとにコミット
   - ドラフトPRで進捗を可視化

3. **チーム連携**
   - タスクを事前に登録
   - ロックは必要最小限の時間

### DON'T ❌

1. **避けるべきこと**
   - 巨大なPRを作成
   - ロックしたまま長時間放置
   - `gh pr ready`の乱用

2. **アンチパターン**
   ```bash
   # ❌ 全ファイルをロック
   find src -name "*.tsx" | xargs -I {} ./scripts/claude-coordinator.sh lock {}
   
   # ❌ 無計画な並行作業
   # インスタンス1: src/utils/helpers.ts を編集
   # インスタンス2: src/utils/helpers.ts を同時編集（競合！）
   ```

---

## 🆘 トラブルシューティング

### よくある問題と解決法

#### 1. "ロックが取得できません"

```bash
# 原因確認
./scripts/claude-coordinator.sh status --locks

# 解決法1: 期限切れを待つ
echo "ロックは60分で自動解放されます"

# 解決法2: 緊急解放（チームリーダーのみ）
./scripts/claude-coordinator.sh admin unlock src/important.ts --force
```

#### 2. "CIが実行されません"

```bash
# チェックリスト
echo "1. ドラフトPRですか？"
gh pr view --json isDraft

echo "2. ワークフローは有効ですか？"
gh workflow list

echo "3. 条件は正しいですか？"
cat .github/workflows/*.yml | grep -A5 "if:"
```

#### 3. "コストが予想より高い"

```bash
# 詳細分析
./scripts/cost-analyzer.sh --breakdown

# 最適化提案
./scripts/suggest-optimization.sh

# 一時的な制限
echo "MAX_PARALLEL_RUNS=2" >> .github/claude-optimizer.conf
```

---

## 📝 設定のカスタマイズ

### プロジェクト別設定

```yaml
# .claude-optimizer.yml
version: 1
project:
  type: web-app
  language: typescript
  size: large

optimization:
  draft_pr:
    enabled: true
    light_checks:
      - lint
      - typecheck
      - security-scan
    skip:
      - e2e-tests
      - performance-tests
      
  parallel_instances:
    max: 5
    lock_timeout: 60  # minutes
    
  cost_control:
    daily_limit: 30  # dollars
    alert_threshold: 0.8
    
monitoring:
  reports:
    - type: daily
      time: "18:00"
      channel: slack
    - type: weekly
      time: "MON 09:00"
      email: team@example.com
```

---

## 🎯 次のステップ

1. **基本設定を完了したら**
   - チーム全員にガイドを共有
   - 最初の1週間はメトリクスを注視

2. **運用が安定したら**
   - カスタム最適化ルールを追加
   - 他のプロジェクトにも展開

3. **継続的改善**
   - 月次でコスト分析
   - 四半期ごとにワークフロー見直し

---

**質問・サポート**: [GitHub Discussions](https://github.com/ootakazuhiko/claude-actions-optimizer/discussions) でお気軽にご相談ください！