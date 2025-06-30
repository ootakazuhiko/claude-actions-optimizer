# 稼働中のClaude Codeへの適用ガイド

## 📋 目次

1. [概要](#概要)
2. [事前準備](#事前準備)
3. [適用方法](#適用方法)
4. [動作確認](#動作確認)
5. [トラブルシューティング](#トラブルシューティング)
6. [ベストプラクティス](#ベストプラクティス)

---

## 🎯 概要

このガイドでは、現在稼働中のClaude Codeセッションに、GitHub Actions最適化システムを適用する方法を説明します。

### 重要なポイント

- ✅ **作業中断なし**: Claude Codeの現在の作業を中断せずに適用可能
- ✅ **即座に効果**: 適用後すぐにコスト削減効果が発生
- ✅ **安全**: 既存の作業に影響を与えません

---

## 📝 事前準備

### 1. 現在の状態確認

```bash
# 現在のブランチを確認
git branch --show-current

# 未コミットの変更を確認
git status

# 現在のPRを確認
gh pr list --author @me --state open
```

### 2. 作業の保存（推奨）

```bash
# 現在の作業を一時的にコミット
git add .
git commit -m "wip: 作業中の内容を保存"
```

---

## 🚀 適用方法

### 方法1: クイック適用（推奨）

現在のClaude Codeセッションで以下のコマンドを実行してください：

```bash
# 1. 最適化システムをダウンロードして適用
curl -sSL https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/quick-deploy.sh | bash

# 2. 確認メッセージ
echo "✅ 最適化システムが適用されました"

# 3. CLAUDE.mdの内容を確認
cat CLAUDE.md
```

### 方法2: 手動適用（カスタマイズが必要な場合）

```bash
# 1. 一時ディレクトリで最適化システムをクローン
cd /tmp
git clone https://github.com/ootakazuhiko/claude-actions-optimizer.git
cd claude-actions-optimizer

# 2. プロジェクトディレクトリに戻る
cd -  # 元のプロジェクトディレクトリに戻る

# 3. インストールスクリプトを実行
/tmp/claude-actions-optimizer/install.sh

# 4. マルチインスタンス対応を有効化（複数Claude使用時）
/tmp/claude-actions-optimizer/install.sh --multi-instance
```

### 方法3: 最小限の適用（CLAUDE.mdのみ）

```bash
# CLAUDE.mdファイルをダウンロード
curl -o CLAUDE.md https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/templates/CLAUDE.md

# 内容を確認
cat CLAUDE.md

# Claudeに再読み込みを促す
echo "📋 CLAUDE.mdを更新しました。内容を確認して、今後はドラフトPRで作業してください。"
```

---

## ✅ 動作確認

### 1. 適用状態の確認

```bash
# CLAUDE.mdが存在することを確認
ls -la CLAUDE.md

# ドラフトPRワークフローが存在することを確認
ls -la .github/workflows/draft-pr-quick-check.yml

# 既存ワークフローの最適化状態を確認
grep -n "draft" .github/workflows/*.yml | head -5
```

### 2. Claude Codeへの指示

適用後、Claude Codeに以下を伝えてください：

```
CLAUDE.mdファイルを確認して、今後は以下のルールに従ってください：
1. 新しいPRは必ずドラフトで作成
2. レビュー準備ができたらgh pr readyを実行
3. マルチインスタンス使用時は調整システムを利用
```

### 3. 次のコミットでテスト

```bash
# テスト用の変更
echo "# Test" >> README.md
git add README.md
git commit -m "test: 最適化システムの動作確認"

# ドラフトPRを作成（Claudeが自動的に行うはず）
gh pr create --draft --title "test: optimization check"

# GitHub Actionsの実行時間を確認（1-3分になるはず）
gh run list --limit 1
```

---

## 🔧 トラブルシューティング

### 問題: Claudeが引き続き通常のPRを作成する

**解決法**:
```bash
# CLAUDE.mdの内容を明示的に伝える
echo "重要: CLAUDE.mdファイルが更新されました。必ず内容を確認し、ドラフトPRルールに従ってください。"

# 具体的な指示を出す
echo "次のPRから、必ず --draft オプションを付けてください: gh pr create --draft"
```

### 問題: 既存のPRが最適化されない

**解決法**:
```bash
# 既存の通常PRをドラフトに変換
gh pr list --author @me --state open --json number,isDraft | \
  jq -r '.[] | select(.isDraft == false) | .number' | \
  xargs -I {} gh pr ready {} --undo

echo "✅ 既存のPRをドラフトに変換しました"
```

### 問題: マルチインスタンス調整が機能しない

**解決法**:
```bash
# 調整システムを初期化
./scripts/claude-coordinator.sh init

# インスタンスIDを設定
export CLAUDE_INSTANCE_ID="claude-$(date +%s)-$$"
echo "Instance ID: $CLAUDE_INSTANCE_ID"

# 状態確認
./scripts/claude-coordinator.sh status
```

---

## 💡 ベストプラクティス

### 1. 段階的な適用

```bash
# Step 1: まずCLAUDE.mdだけ適用
curl -o CLAUDE.md https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/templates/CLAUDE.md

# Step 2: 動作を確認してから完全適用
# 数回のコミットで問題ないことを確認

# Step 3: フル機能を適用
./install.sh --preserve-existing
```

### 2. チームへの周知

```bash
# チームメンバーに通知
cat > team-notice.md << 'EOF'
## 📢 GitHub Actions最適化システムを導入しました

### 変更点
1. 新しいPRは自動的にドラフトで作成されます
2. レビュー準備完了時に `gh pr ready` を実行してください
3. CI実行時間が20分→1分に短縮されます（95%削減）

### 必要なアクション
- CLAUDE.mdファイルを確認してください
- 複数のClaude Codeを使用する場合は調整システムを利用してください

### サポート
問題がある場合は、以下を参照：
- FAQ: FAQ-TROUBLESHOOTING-ja.md
- 緊急時: .github/disable-all-workflows.sh
EOF

# PRまたはIssueで共有
gh issue create --title "GitHub Actions最適化システム導入のお知らせ" --body-file team-notice.md
```

### 3. 効果測定

```bash
# 導入前後の比較スクリプト
cat > measure-impact.sh << 'EOF'
#!/bin/bash
echo "=== GitHub Actions 最適化効果測定 ==="
echo "期間: 過去7日間"

# ドラフトPRの割合
total=$(gh pr list --limit 100 --json isDraft | jq length)
draft=$(gh pr list --limit 100 --json isDraft | jq '[.[] | select(.isDraft)] | length')
echo "ドラフトPR率: $(( draft * 100 / total ))%"

# 平均実行時間
echo "平均CI実行時間:"
gh run list --limit 50 --json durationMS | \
  jq '[.[] | .durationMS] | add / length / 60000' | \
  xargs printf "%.1f分\n"

# コスト削減額（概算）
minutes_saved=$(( (20 - 1) * draft ))
cost_saved=$(echo "$minutes_saved * 0.008" | bc)
echo "削減額（週間）: \$${cost_saved}"
EOF

chmod +x measure-impact.sh
./measure-impact.sh
```

---

## 📊 適用後のモニタリング

### リアルタイムモニタリング

```bash
# CI実行状況を監視
watch -n 60 'gh run list --limit 5'

# コスト追跡
cat > monitor-costs.sh << 'EOF'
#!/bin/bash
while true; do
  clear
  echo "=== リアルタイムコストモニター ==="
  echo "時刻: $(date)"
  echo ""
  
  # 本日の使用量
  minutes=$(gh api repos/$GITHUB_REPOSITORY/actions/runs \
    --jq '[.workflow_runs[] | select(.created_at | startswith("'$(date +%Y-%m-%d)'")) | .run_duration_ms] | add / 60000' 2>/dev/null || echo 0)
  
  echo "本日のCI実行時間: ${minutes}分"
  echo "推定コスト: \$$(echo "$minutes * 0.008" | bc)"
  
  sleep 300  # 5分ごとに更新
done
EOF

chmod +x monitor-costs.sh
# バックグラウンドで実行
./monitor-costs.sh &
```

### 週次レポート

```bash
# 自動レポート生成
echo "0 9 * * 1 /path/to/weekly-report.sh | mail -s 'GitHub Actions週次レポート' team@example.com" | crontab -
```

---

## 🎯 次のステップ

1. **基本適用完了後**
   - 数日間モニタリング
   - チームメンバーのフィードバック収集

2. **安定稼働確認後**
   - カスタマイズルールの追加
   - 他のプロジェクトへの展開

3. **長期運用**
   - 月次でコスト分析
   - 最適化ルールの継続的改善

---

## 📞 サポート

問題が発生した場合：

1. **ドキュメント確認**: [FAQ-TROUBLESHOOTING-ja.md](./FAQ-TROUBLESHOOTING-ja.md)
2. **GitHub Issues**: [サポートリクエスト](https://github.com/ootakazuhiko/claude-actions-optimizer/issues)
3. **緊急時**: `.github/disable-all-workflows.sh` で一時停止

---

**最終更新日**: 2024年12月29日  
**バージョン**: 1.0.0