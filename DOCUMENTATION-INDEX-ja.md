# Claude Actions Optimizer ドキュメント一覧

## 📚 ドキュメント体系

このディレクトリには、Claude Code GitHub Actions最適化システムに関する包括的なドキュメントが含まれています。

### 🆕 新機能ドキュメント

| ドキュメント | 説明 | 対象読者 |
|------------|------|---------|
| [NEW-FEATURES-OVERVIEW-ja.md](./NEW-FEATURES-OVERVIEW-ja.md) | 2024年新機能の概要と使い方 | すべてのユーザー |
| [REVIEW-FEEDBACK-GUIDE-ja.md](./REVIEW-FEEDBACK-GUIDE-ja.md) | レビューフィードバックシステム利用ガイド | 開発者、レビュアー |
| [COMPLETE-SETUP-GUIDE-ja.md](./COMPLETE-SETUP-GUIDE-ja.md) | 完全導入ガイド（メイン/クライアント端末） | 管理者、セットアップ担当 |
| [QUICK-START-CHECKLIST-ja.md](./QUICK-START-CHECKLIST-ja.md) | 5分クイックスタートチェックリスト | 初めての方 |

### 📖 基本ドキュメント

| ドキュメント | 説明 | 対象読者 |
|------------|------|---------|
| [README-ja.md](./README-ja.md) | システムの概要、導入効果、基本的な使い方 | すべてのユーザー |
| [USAGE-GUIDE-ja.md](./USAGE-GUIDE-ja.md) | 実践的な使い方ガイド、シナリオ別の詳細手順 | 開発者、チームリーダー |
| [DIAGRAMS-ja.md](./DIAGRAMS-ja.md) | システム構成図、フロー図、視覚的な説明 | アーキテクト、技術者 |
| [FAQ-TROUBLESHOOTING-ja.md](./FAQ-TROUBLESHOOTING-ja.md) | よくある質問、トラブルシューティング、緊急対応 | サポート担当、管理者 |

### 📄 英語ドキュメント

| ドキュメント | 説明 | 対象読者 |
|------------|------|---------|
| [README.md](./README.md) | System overview with latest features | All users |
| [multi-instance-support.md](./multi-instance-support.md) | Multi-instance coordination details | Advanced users |
| [review-feedback-system.md](./review-feedback-system.md) | Review feedback system design | System architects |
| [REPOSITORY_STRATEGY.md](./REPOSITORY_STRATEGY.md) | Repository management strategy | Administrators |

### 🔧 技術リファレンス

| ファイル | 説明 | 用途 |
|---------|------|------|
| [AUTO-SETUP-SCRIPT.sh](./AUTO-SETUP-SCRIPT.sh) | 対話型自動セットアップ | 完全自動導入 |
| [install.sh](./install.sh) | メインインストーラー | 基本システム導入 |
| [scripts/claude-coordinator.sh](./scripts/claude-coordinator.sh) | マルチインスタンス調整 | 競合防止管理 |
| [scripts/claude-identity.sh](./scripts/claude-identity.sh) | 個体識別・役割管理 | Claude Code識別 |
| [scripts/claude-review-check.sh](./scripts/claude-review-check.sh) | レビュー確認・適用 | フィードバック処理 |

### 📋 導入・移行ガイド

| ドキュメント | 説明 | 対象読者 |
|------------|------|---------|
| [APPLY-TO-RUNNING-CLAUDE-ja.md](./APPLY-TO-RUNNING-CLAUDE-ja.md) | 稼働中Claudeへの適用ガイド | 既存環境管理者 |
| [CURRENT-CLAUDE-INSTRUCTIONS-ja.md](./CURRENT-CLAUDE-INSTRUCTIONS-ja.md) | 現在稼働中のClaude向け即効性のある手順 | 運用担当者 |
| [LIVE-APPLICATION-CHECKLIST-ja.md](./LIVE-APPLICATION-CHECKLIST-ja.md) | ライブ適用チェックリスト | 実装担当者 |

### 📂 テンプレート・設定

| ファイル | 説明 | 用途 |
|---------|------|------|
| [templates/CLAUDE-multi-instance.md](./templates/CLAUDE-multi-instance.md) | マルチインスタンス用CLAUDE.md | プロジェクト設定 |
| [templates/github-tracking-queries.md](./templates/github-tracking-queries.md) | GitHub追跡クエリ集 | 活動監視 |
| [templates/multi-instance-coordination.yml](./templates/multi-instance-coordination.yml) | 調整システム設定 | 環境構築 |
| [.github/PULL_REQUEST_TEMPLATE/claude_review.md](./.github/PULL_REQUEST_TEMPLATE/claude_review.md) | レビューテンプレート | 標準化レビュー |

### 🔄 GitHub Actionsワークフロー

| ファイル | 説明 | 機能 |
|---------|------|------|
| [.github/workflows/claude-review-processor.yml](./.github/workflows/claude-review-processor.yml) | レビュー自動処理 | フィードバック収集 |
| [.github/workflows/draft-pr-quick-check.yml](./.github/workflows/draft-pr-quick-check.yml) | ドラフトPR最適化 | CI時間短縮 |

---

## 🎯 目的別ガイド

### 初めて使う方
1. **[NEW-FEATURES-OVERVIEW-ja.md](./NEW-FEATURES-OVERVIEW-ja.md)** - 新機能の概要を確認
2. **[QUICK-START-CHECKLIST-ja.md](./QUICK-START-CHECKLIST-ja.md)** - 5分でセットアップ
3. **[README-ja.md](./README-ja.md)** - システムの詳細を理解

### マルチインスタンスを導入したい方
1. **[COMPLETE-SETUP-GUIDE-ja.md](./COMPLETE-SETUP-GUIDE-ja.md)** - 完全導入手順
2. **[scripts/claude-identity.sh](./scripts/claude-identity.sh)** - 個体設定方法
3. **[multi-instance-support.md](./multi-instance-support.md)** - 技術仕様

### レビューシステムを活用したい方
1. **[REVIEW-FEEDBACK-GUIDE-ja.md](./REVIEW-FEEDBACK-GUIDE-ja.md)** - 使い方ガイド
2. **[review-feedback-system.md](./review-feedback-system.md)** - システム設計
3. **[scripts/claude-review-check.sh](./scripts/claude-review-check.sh)** - コマンド詳細

### チーム導入を検討中の方
1. **[USAGE-GUIDE-ja.md](./USAGE-GUIDE-ja.md)** - シナリオ2（チーム開発）
2. **[DIAGRAMS-ja.md](./DIAGRAMS-ja.md)** - システム構成を理解
3. **[FAQ-TROUBLESHOOTING-ja.md](./FAQ-TROUBLESHOOTING-ja.md)** - 導入時の注意点

### トラブルが発生した方
1. **[FAQ-TROUBLESHOOTING-ja.md](./FAQ-TROUBLESHOOTING-ja.md)** - エラー別の対処法
2. **緊急停止**: `.github/disable-all-workflows.sh`
3. **サポート**: [GitHub Issues](https://github.com/ootakazuhiko/claude-actions-optimizer/issues)

---

## 📊 ドキュメントの関係性

```
NEW-FEATURES-OVERVIEW-ja.md（新機能概要）
    │
    ├─→ マルチインスタンス機能
    │   ├─→ COMPLETE-SETUP-GUIDE-ja.md（導入）
    │   ├─→ claude-identity.sh（個体識別）
    │   └─→ claude-coordinator.sh（調整）
    │
    ├─→ レビューフィードバック
    │   ├─→ REVIEW-FEEDBACK-GUIDE-ja.md（使い方）
    │   ├─→ claude-review-check.sh（コマンド）
    │   └─→ claude-review-processor.yml（自動化）
    │
    └─→ 基本最適化機能
        ├─→ README-ja.md（概要）
        ├─→ USAGE-GUIDE-ja.md（使い方）
        └─→ FAQ-TROUBLESHOOTING-ja.md（トラブル対応）
```

---

## 🔄 ドキュメントの更新

ドキュメントは定期的に更新されます。最新情報は以下で確認できます：

- **GitHub リポジトリ**: [claude-actions-optimizer](https://github.com/ootakazuhiko/claude-actions-optimizer)
- **リリースノート**: [Releases](https://github.com/ootakazuhiko/claude-actions-optimizer/releases)
- **変更履歴**: 各ドキュメントの更新日時を確認

---

## 💡 フィードバック

ドキュメントに関するご意見・ご要望は以下までお寄せください：

- **機能リクエスト**: [GitHub Issues](https://github.com/ootakazuhiko/claude-actions-optimizer/issues) に`enhancement`ラベル
- **バグ報告**: [GitHub Issues](https://github.com/ootakazuhiko/claude-actions-optimizer/issues) に`bug`ラベル
- **質問**: [GitHub Discussions](https://github.com/ootakazuhiko/claude-actions-optimizer/discussions)
- **ドキュメント改善**: Pull Requestを歓迎します

---

**ドキュメントバージョン**: 2.0.0  
**最終更新日**: 2024年6月30日  
**主な更新内容**: マルチインスタンス機能、レビューフィードバックシステム、完全自動セットアップを追加