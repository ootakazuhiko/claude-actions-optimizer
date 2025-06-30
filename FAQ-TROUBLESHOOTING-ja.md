# FAQ・トラブルシューティングガイド

## 📚 目次

1. [よくある質問（FAQ）](#よくある質問faq)
2. [トラブルシューティング](#トラブルシューティング)
3. [エラーメッセージ一覧](#エラーメッセージ一覧)
4. [緊急対応手順](#緊急対応手順)
5. [お問い合わせ](#お問い合わせ)

---

## ❓ よくある質問（FAQ）

### 基本的な質問

#### Q1: このシステムは何をするものですか？

**A**: Claude Code（AIコーディングアシスタント）を使用した開発において、GitHub Actionsの実行コストを95%削減しながら、複数のClaude Codeインスタンスが競合せずに作業できるようにするシステムです。

主な機能：
- ドラフトPRで軽量チェックのみ実行（20分→1分）
- 重複ワークフローの統合
- ファイルレベルの排他制御

#### Q2: どのくらいコストを削減できますか？

**A**: 典型的なプロジェクトでは以下の削減が期待できます：

```
導入前: 100コミット/日 × 20分 = 2,000分 ≈ $16/日
導入後: 100コミット/日 × 1分 = 100分 ≈ $0.80/日

削減率: 95%
月間削減額: 約$450
```

#### Q3: 既存のプロジェクトに導入できますか？

**A**: はい、できます。インストーラーが既存の設定を分析し、影響を最小限に抑えながら統合します。

```bash
# 既存設定を保持しながらインストール
./install.sh --preserve-existing

# バックアップも自動作成されます
ls -la .github/workflows.backup/
```

### 技術的な質問

#### Q4: ドラフトPRとは何ですか？

**A**: GitHubの機能で、まだレビュー準備ができていないPRを示します。本システムでは、ドラフト状態では軽量チェックのみ実行し、レビュー準備完了時にフルテストを実行します。

```bash
# ドラフトPRの作成
gh pr create --draft

# レビュー準備完了
gh pr ready
```

#### Q5: マルチインスタンスとは何ですか？

**A**: 複数のClaude Codeが同時に同じプロジェクトで作業することです。本システムは、ファイルロック機構により競合を防ぎます。

```
Claude #1 → auth.tsx を編集
Claude #2 → header.tsx を編集（同時作業OK）
Claude #3 → auth.tsx を編集しようとする → ロック済みエラー
```

#### Q6: ロックのタイムアウトはどのくらいですか？

**A**: デフォルトは60分です。変更可能です：

```bash
# 30分に変更
./scripts/claude-coordinator.sh lock src/file.ts 30

# グローバル設定
echo "DEFAULT_LOCK_TIMEOUT=30" >> .claude/config
```

### 運用に関する質問

#### Q7: チーム全員がこのシステムを使う必要がありますか？

**A**: Claude Codeを使用する開発者のみが必要です。人間の開発者は通常通り作業できます。

#### Q8: 本番環境への影響はありますか？

**A**: ありません。このシステムは開発時のCI/CDパイプラインのみに影響し、本番デプロイメントには影響しません。

#### Q9: セキュリティ上の懸念はありますか？

**A**: システムは以下のセキュリティ対策を実装しています：
- ローカルファイルのみでロック管理（外部通信なし）
- GitHub Actionsの標準的なセキュリティモデルに準拠
- 機密情報の保存なし

---

## 🔧 トラブルシューティング

### インストール関連

#### 問題: インストールスクリプトが失敗する

**症状**:
```
Error: Project type detection failed
```

**解決法**:
```bash
# 手動でプロジェクトタイプを指定
./install.sh --type nodejs

# または手動インストール
cp templates/CLAUDE.md ./
cp templates/draft-pr-quick-check.yml .github/workflows/
```

#### 問題: 権限エラーが発生する

**症状**:
```
Permission denied: ./install.sh
```

**解決法**:
```bash
# 実行権限を付与
chmod +x install.sh
chmod +x scripts/*.sh

# または bash で直接実行
bash install.sh
```

### ワークフロー関連

#### 問題: CIが実行されない

**症状**: コミットしてもGitHub Actionsが起動しない

**診断手順**:
```bash
# 1. ワークフローの状態確認
gh workflow list

# 2. ワークフローが無効化されていないか確認
gh workflow enable draft-pr-quick-check

# 3. YAMLの構文チェック
yamllint .github/workflows/*.yml

# 4. 条件の確認
grep -n "if:" .github/workflows/*.yml
```

**一般的な原因と解決法**:

1. **ワークフローが無効**: 
   ```bash
   gh workflow enable <workflow-name>
   ```

2. **YAML構文エラー**:
   ```yaml
   # ❌ 間違い
   if: github.event.pull_request.draft == false
   
   # ✅ 正しい
   if: github.event.pull_request.draft == false || github.event_name == 'push'
   ```

3. **ブランチ保護ルール**:
   Settings → Branches → 保護ルールの確認

#### 問題: ドラフトPRでもフルテストが実行される

**症状**: 軽量チェックのみのはずが、全テストが実行される

**解決法**:
```bash
# 1. 条件を確認
cat .github/workflows/*.yml | grep -B2 -A2 "draft"

# 2. 正しい条件に修正
sed -i 's/if: always()/if: github.event.pull_request.draft == false/' \
  .github/workflows/*.yml

# 3. 確認
gh pr view --json isDraft
```

### ロック関連

#### 問題: ファイルロックが取得できない

**症状**:
```
❌ File is already locked: src/components/Header.tsx (by claude-abc123)
```

**解決法**:

1. **ロック状態を確認**:
   ```bash
   ./scripts/claude-coordinator.sh status
   
   # 特定ファイルの確認
   ls -la .claude/file_locks/src_components_Header.tsx.lock
   ```

2. **ロックの所有者を確認**:
   ```bash
   cat .claude/locks.yml | grep -A3 "Header.tsx"
   ```

3. **期限切れを待つ**:
   ```bash
   # 残り時間を確認
   ./scripts/claude-coordinator.sh check-lock src/components/Header.tsx
   ```

4. **緊急時の強制解放**:
   ```bash
   # チームリーダーのみ実行可能
   ./scripts/claude-coordinator.sh admin unlock src/components/Header.tsx --force
   ```

#### 問題: ロックが自動解放されない

**症状**: タスク完了後もロックが残っている

**解決法**:
```bash
# 1. 期限切れロックをクリーンアップ
./scripts/claude-coordinator.sh clean

# 2. 手動で特定ロックを解放
./scripts/claude-coordinator.sh unlock src/file.tsx

# 3. 全ロックをリセット（最終手段）
rm -rf .claude/file_locks/*
echo "locks: {}" > .claude/locks.yml
```

### パフォーマンス関連

#### 問題: 軽量チェックが遅い

**症状**: ドラフトPRでも5分以上かかる

**診断**:
```bash
# 実行時間の分析
gh run list --limit 10 --json name,durationMS | \
  jq '.[] | "\(.durationMS/1000)秒 \(.name)"'
```

**最適化**:
```yaml
# .github/workflows/draft-pr-quick-check.yml
jobs:
  quick-check:
    timeout-minutes: 5  # タイムアウト設定
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 1  # 浅いクローン
          
      - name: Cache dependencies
        uses: actions/cache@v3
        # キャッシュ設定...
```

### コスト関連

#### 問題: 予想よりコストが高い

**診断スクリプト**:
```bash
cat > analyze-costs.sh << 'EOF'
#!/bin/bash
echo "=== コスト分析 ==="

# ドラフトPRの割合
total_prs=$(gh pr list --limit 100 --json isDraft | jq length)
draft_prs=$(gh pr list --limit 100 --json isDraft | jq '[.[] | select(.isDraft)] | length')
echo "ドラフトPR率: $(( draft_prs * 100 / total_prs ))%"

# 平均実行時間
avg_time=$(gh run list --limit 50 --json durationMS | \
  jq '[.[] | .durationMS] | add / length / 60000')
echo "平均実行時間: ${avg_time}分"

# 推奨事項
if (( $(echo "$avg_time > 5" | bc -l) )); then
  echo "⚠️ 軽量チェックの最適化が必要です"
fi
EOF

bash analyze-costs.sh
```

---

## 🚨 エラーメッセージ一覧

### インストール時のエラー

| エラーメッセージ | 原因 | 解決法 |
|--------------|------|--------|
| `Project type not detected` | package.json等が見つからない | `--type` オプションで指定 |
| `Workflow directory not found` | .github/workflowsが存在しない | `mkdir -p .github/workflows` |
| `Permission denied` | 実行権限なし | `chmod +x install.sh` |
| `curl: command not found` | curlがインストールされていない | `apt-get install curl` |

### 実行時のエラー

| エラーメッセージ | 原因 | 解決法 |
|--------------|------|--------|
| `File is already locked` | 他のインスタンスが編集中 | 別のファイルを編集するか待機 |
| `No active session found` | セッションが初期化されていない | `claude-coordinator.sh init` |
| `Task already in progress` | タスクが既に割り当て済み | 別のタスクを選択 |
| `Lock expired` | ロックがタイムアウト | 再度ロックを取得 |

### GitHub Actions関連のエラー

| エラーメッセージ | 原因 | 解決法 |
|--------------|------|--------|
| `Workflow not found` | ワークフローファイルが存在しない | ファイルパスを確認 |
| `Invalid workflow file` | YAML構文エラー | yamllintで検証 |
| `Required check failed` | 必須チェックが失敗 | ログを確認して修正 |

---

## 🆘 緊急対応手順

### 1. 全ワークフローを一時停止

```bash
#!/bin/bash
# emergency-stop.sh
echo "🚨 緊急停止中..."

# ワークフローを一時的に無効化
cd .github
mv workflows workflows.emergency-backup
mkdir workflows
echo "name: Emergency Stop
on: workflow_dispatch
jobs:
  stop:
    runs-on: ubuntu-latest
    steps:
      - run: echo 'All workflows stopped'" > workflows/emergency.yml

echo "✅ 全ワークフローを停止しました"
echo "復旧するには: mv .github/workflows.emergency-backup .github/workflows"
```

### 2. ロックシステムのリセット

```bash
#!/bin/bash
# reset-locks.sh
echo "🔄 ロックシステムをリセット中..."

# バックアップ作成
cp -r .claude .claude.backup.$(date +%Y%m%d-%H%M%S)

# ロックをクリア
rm -rf .claude/file_locks/*
echo "locks: {}" > .claude/locks.yml
> .claude/audit.log

# セッションをクリア
rm -rf .claude/sessions/*

echo "✅ リセット完了"
```

### 3. コスト制限の設定

```bash
#!/bin/bash
# cost-limit.sh
cat > .github/workflows/cost-limiter.yml << 'EOF'
name: Cost Limiter
on:
  workflow_run:
    workflows: ["*"]
    types: [requested]

jobs:
  check-limit:
    runs-on: ubuntu-latest
    steps:
      - name: Check daily limit
        run: |
          DAILY_LIMIT=3000  # 分
          USED=$(gh api /repos/${{ github.repository }}/actions/usage | jq .minutes_used_today)
          if [ $USED -gt $DAILY_LIMIT ]; then
            echo "::error::Daily limit exceeded: ${USED}/${DAILY_LIMIT} minutes"
            exit 1
          fi
EOF

echo "✅ コスト制限を設定しました（3000分/日）"
```

### 4. 診断情報の収集

```bash
#!/bin/bash
# collect-diagnostics.sh
DIAG_DIR="diagnostics-$(date +%Y%m%d-%H%M%S)"
mkdir -p $DIAG_DIR

echo "📊 診断情報を収集中..."

# システム情報
{
  echo "=== System Info ==="
  date
  pwd
  git rev-parse HEAD
  echo ""
} > $DIAG_DIR/system.txt

# ワークフロー状態
{
  echo "=== Workflows ==="
  gh workflow list
  echo ""
  echo "=== Recent Runs ==="
  gh run list --limit 20
} > $DIAG_DIR/workflows.txt

# ロック状態
{
  echo "=== Lock Status ==="
  ./scripts/claude-coordinator.sh status
  echo ""
  echo "=== Lock Files ==="
  ls -la .claude/file_locks/
  echo ""
  echo "=== locks.yml ==="
  cat .claude/locks.yml
} > $DIAG_DIR/locks.txt

# エラーログ
{
  echo "=== Recent Errors ==="
  gh run list --status failure --limit 10
} > $DIAG_DIR/errors.txt

# アーカイブ作成
tar -czf $DIAG_DIR.tar.gz $DIAG_DIR/

echo "✅ 診断情報を収集しました: $DIAG_DIR.tar.gz"
echo "サポートに送信する際はこのファイルを添付してください"
```

---

## 📞 お問い合わせ

### サポートチャンネル

1. **GitHub Issues** (推奨)
   - [バグ報告](https://github.com/ootakazuhiko/claude-actions-optimizer/issues/new?template=bug_report.md)
   - [機能リクエスト](https://github.com/ootakazuhiko/claude-actions-optimizer/issues/new?template=feature_request.md)

2. **GitHub Discussions**
   - [Q&A](https://github.com/ootakazuhiko/claude-actions-optimizer/discussions/categories/q-a)
   - [アイデア共有](https://github.com/ootakazuhiko/claude-actions-optimizer/discussions/categories/ideas)

3. **緊急サポート**
   - 重大な問題の場合は、Issueに`urgent`ラベルを付けてください

### 報告時に含めるべき情報

```markdown
## 環境
- OS: [例: Ubuntu 22.04]
- Git version: [git --version の出力]
- GitHub CLI version: [gh --version の出力]
- Project type: [Node.js/Python/etc]

## 問題の説明
[具体的に何が起きているか]

## 再現手順
1. [ステップ1]
2. [ステップ2]
3. [エラー発生]

## エラーメッセージ
```
[エラーメッセージをここに貼り付け]
```

## 診断情報
[collect-diagnostics.sh の出力ファイルを添付]
```

---

**最終更新日**: 2024年12月29日  
**バージョン**: 1.0.0