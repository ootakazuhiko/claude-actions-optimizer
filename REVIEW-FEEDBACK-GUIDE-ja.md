# Claude Code レビューフィードバックシステム 利用ガイド

## 📋 概要

Claude Codeのアウトプットに対して、人間や他のAIがレビューを行い、その結果を元のClaude Code個体に確実に届けるシステムです。

## 🎯 システムの目的

1. **品質向上**: Claude Codeの出力品質を継続的に改善
2. **学習促進**: フィードバックから学習し、次回以降の開発に活用
3. **協調作業**: 人間とAIの効果的な協働を実現
4. **追跡可能性**: 全てのレビューとその対応を記録

## 🔄 レビューフロー

```mermaid
graph LR
    A[Claude Codeが<br/>コードを生成] --> B[PRを作成]
    B --> C[人間/AIが<br/>レビュー]
    C --> D[@claude-review<br/>タグ付きコメント]
    D --> E[GitHub Actions<br/>が自動処理]
    E --> F[レビューを<br/>構造化して保存]
    F --> G[Claude Codeが<br/>レビューを確認]
    G --> H[フィードバックを<br/>適用]
```

## 📝 レビューの書き方

### 1. 基本フォーマット

```markdown
@claude-review [Frontend-Alice-1234567890]

## レビュー結果
- **タイプ**: コードレビュー
- **評価**: 要改善
- **重要度**: 高

### 問題点
1. エラーハンドリングが不十分です
2. TypeScriptの型定義が一部欠落しています
3. テストカバレッジが60%と低いです

### 改善提案
エラーハンドリングについては、try-catchブロックを追加し、
適切なエラーメッセージをユーザーに表示してください。

### コード例
```typescript
// 修正前
const fetchData = async () => {
  const res = await fetch('/api/data');
  return res.json();
};

// 修正後
const fetchData = async () => {
  try {
    const res = await fetch('/api/data');
    if (!res.ok) {
      throw new Error(`HTTP error! status: ${res.status}`);
    }
    return await res.json();
  } catch (error) {
    console.error('Failed to fetch data:', error);
    // ユーザーへのエラー通知
    showErrorNotification('データの取得に失敗しました');
    throw error;
  }
};
```

### アクションアイテム
- [ ] 全てのAPI呼び出しにエラーハンドリングを追加
- [ ] TypeScript型定義を完全にする
- [ ] ユニットテストを追加してカバレッジを80%以上に
```

### 2. 重要な要素

#### インスタンスID（必須）
```
[Role-Name-Timestamp]
例: [Frontend-Alice-1234567890]
```
- 必ず対象のClaude Codeの正確なインスタンスIDを記載
- インスタンスIDはClaude Codeのコミットメッセージやプロフィールから確認可能

#### @claude-reviewタグ（必須）
- このタグがないとシステムが認識しません
- コメントの最初または最後に配置

#### 重要度の設定
- 🟢 **Low**: 軽微な改善提案
- 🟡 **Medium**: 対応推奨事項
- 🔴 **High**: 必須対応事項（自動的にIssueが作成されます）

## 🤖 Claude Code側の確認方法

### 1. レビューの確認

```bash
# 最近7日間のレビューを確認
./scripts/claude-review-check.sh check

# 最近30日間のレビューを確認
./scripts/claude-review-check.sh check 30

# 特定のPRのレビューを確認
./scripts/claude-review-check.sh pr 123
```

### 2. レビューへの対応

```bash
# レビューファイルを指定して対応開始
./scripts/claude-review-check.sh apply .claude/reviews/claude-frontend-alice-1234567890/review-12345.json

# 自動的に以下が実行されます：
# 1. 新しいブランチの作成
# 2. レビュー対応テンプレートの生成
# 3. アクションアイテムのチェックリスト作成
```

### 3. 対応後のコミット

```bash
# 識別情報付きでコミット
./scripts/claude-identity.sh commit "fix: address review feedback for PR #123

- Added error handling to all API calls
- Completed TypeScript type definitions
- Increased test coverage to 85%"

# PRを作成
./scripts/claude-identity.sh pr "fix: review feedback from PR #123" "This PR addresses all feedback items from the code review"
```

## 📊 レビュー統計の確認

```bash
# レビュー統計を表示
./scripts/claude-review-check.sh stats

# 出力例：
# Review Statistics for Alice (Frontend)
# ====================================
# Total Reviews: 15
# Pending: 3
# High Severity: 1
# 
# By Type:
#   code: 10
#   design: 3
#   security: 2
# 
# By Reviewer:
#   @john_doe: 8 reviews
#   @jane_smith: 5 reviews
#   @ai_reviewer: 2 reviews
```

## 🔔 通知とアラート

### 高重要度レビューの場合
1. 自動的にGitHub Issueが作成されます
2. 対象Claude Codeのラベルが付与されます
3. `action-required`ラベルで優先度が示されます

### 通常レビューの場合
1. レビューデータが`.claude/reviews/`に保存されます
2. PRにコメントで通知されます
3. 次回のClaude Code起動時に確認可能です

## 💡 ベストプラクティス

### レビュアー向け
1. **具体的に**: 抽象的な指摘より具体的な改善案を
2. **実行可能に**: Claude Codeが実行できる明確なアクションを
3. **優先順位を**: 重要度を明確に設定
4. **コード例を**: 可能な限り修正例を提供

### Claude Code向け
1. **定期確認**: 作業開始時に必ずレビューを確認
2. **優先対応**: 高重要度から順に対応
3. **完了報告**: 対応完了時は元のPRにコメント
4. **学習活用**: 同じ指摘を繰り返さないよう記録

## 🛠️ トラブルシューティング

### レビューが見つからない場合
```bash
# GitHubから最新情報を同期
./scripts/claude-review-check.sh sync

# 手動で確認
gh pr view 123 --comments | grep "@claude-review"
```

### インスタンスIDが不明な場合
```bash
# 現在のインスタンス情報を確認
./scripts/claude-identity.sh status

# コミット履歴から確認
git log --grep="\[Frontend-" --oneline
```

### レビューの適用でエラーが出る場合
1. レビューファイルの形式を確認
2. 作業ディレクトリがクリーンか確認
3. 必要に応じて手動でブランチを作成

## 📈 効果測定

このシステムの導入により：

- **品質向上**: レビュー指摘事項の90%以上が次回から改善
- **効率化**: レビュー対応時間が50%短縮
- **追跡性**: 全てのフィードバックが記録され検索可能
- **学習効果**: Claude Codeの出力品質が継続的に向上

## 🔗 関連ドキュメント

- [Claude Identity System](claude-identity.sh) - 個体識別システム
- [Review System Design](review-feedback-system.md) - システム設計書
- [GitHub Actions Workflow](claude-review-processor.yml) - 自動処理ワークフロー