# Claude Actions Optimizer ドキュメント一覧

## 📚 ドキュメント体系

このディレクトリには、Claude Code GitHub Actions最適化システムに関する包括的なドキュメントが含まれています。

### 📖 日本語ドキュメント

| ドキュメント | 説明 | 対象読者 |
|------------|------|---------|
| [README-ja.md](./README-ja.md) | システムの概要、導入効果、基本的な使い方 | すべてのユーザー |
| [USAGE-GUIDE-ja.md](./USAGE-GUIDE-ja.md) | 実践的な使い方ガイド、シナリオ別の詳細手順 | 開発者、チームリーダー |
| [DIAGRAMS-ja.md](./DIAGRAMS-ja.md) | システム構成図、フロー図、視覚的な説明 | アーキテクト、技術者 |
| [FAQ-TROUBLESHOOTING-ja.md](./FAQ-TROUBLESHOOTING-ja.md) | よくある質問、トラブルシューティング、緊急対応 | サポート担当、管理者 |

### 📄 英語ドキュメント

| ドキュメント | 説明 | 対象読者 |
|------------|------|---------|
| [README.md](./README.md) | System overview and quick start | All users |
| [multi-instance-support.md](./multi-instance-support.md) | Multi-instance coordination details | Advanced users |
| [REPOSITORY_STRATEGY.md](./REPOSITORY_STRATEGY.md) | Repository management strategy | Administrators |

### 🔧 技術リファレンス

| ファイル | 説明 | 用途 |
|---------|------|------|
| [install.sh](./install.sh) | メインインストーラー | システム導入 |
| [scripts/claude-coordinator.sh](./scripts/claude-coordinator.sh) | 調整システムコア | マルチインスタンス管理 |
| [templates/](./templates/) | 設定テンプレート | カスタマイズ |

---

## 🎯 目的別ガイド

### 初めて使う方

1. **[README-ja.md](./README-ja.md)** - システムの概要を理解
2. **[USAGE-GUIDE-ja.md](./USAGE-GUIDE-ja.md)** - シナリオ1（個人開発）を参照
3. **[FAQ-TROUBLESHOOTING-ja.md](./FAQ-TROUBLESHOOTING-ja.md)** - Q1-Q3を確認

### チーム導入を検討中の方

1. **[README-ja.md](./README-ja.md)** - 導入効果とROIを確認
2. **[DIAGRAMS-ja.md](./DIAGRAMS-ja.md)** - システム構成を理解
3. **[USAGE-GUIDE-ja.md](./USAGE-GUIDE-ja.md)** - シナリオ2（チーム開発）を参照

### 技術的な詳細を知りたい方

1. **[DIAGRAMS-ja.md](./DIAGRAMS-ja.md)** - アーキテクチャとフロー
2. **[multi-instance-support.md](./multi-instance-support.md)** - 技術仕様
3. **ソースコード** - 実装の詳細

### トラブルが発生した方

1. **[FAQ-TROUBLESHOOTING-ja.md](./FAQ-TROUBLESHOOTING-ja.md)** - エラー別の対処法
2. **緊急対応手順** - システムリセット方法
3. **お問い合わせ** - サポート窓口

---

## 📊 ドキュメントの関係性

```
README-ja.md（概要）
    │
    ├─→ USAGE-GUIDE-ja.md（使い方）
    │       │
    │       └─→ 実践的なシナリオ
    │
    ├─→ DIAGRAMS-ja.md（図解）
    │       │
    │       └─→ 視覚的理解
    │
    └─→ FAQ-TROUBLESHOOTING-ja.md（問題解決）
            │
            └─→ エラー対処法
```

---

## 🔄 ドキュメントの更新

ドキュメントは定期的に更新されます。最新情報は以下で確認できます：

- **GitHub リポジトリ**: [claude-actions-optimizer](https://github.com/ootakazuhiko/claude-actions-optimizer)
- **リリースノート**: [Releases](https://github.com/ootakazuhiko/claude-actions-optimizer/releases)
- **変更履歴**: [CHANGELOG.md](https://github.com/ootakazuhiko/claude-actions-optimizer/blob/main/CHANGELOG.md)

---

## 💡 フィードバック

ドキュメントに関するご意見・ご要望は以下までお寄せください：

- **改善提案**: [GitHub Issues](https://github.com/ootakazuhiko/claude-actions-optimizer/issues)
- **質問**: [GitHub Discussions](https://github.com/ootakazuhiko/claude-actions-optimizer/discussions)
- **誤字・脱字**: Pull Requestを歓迎します

---

**ドキュメントバージョン**: 1.0.0  
**最終更新日**: 2024年12月29日