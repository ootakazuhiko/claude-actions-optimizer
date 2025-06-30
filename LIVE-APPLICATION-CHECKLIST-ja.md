# ライブ適用チェックリスト

## 📋 稼働中Claude Code適用チェックリスト

現在作業中のClaude Codeセッションに最適化システムを適用する際の、ステップバイステップチェックリストです。

---

## 🚦 適用前チェック

### ✅ 準備段階

- [ ] 現在の作業ブランチを確認: `git branch --show-current`
- [ ] 未保存の変更を確認: `git status`
- [ ] アクティブなPRを確認: `gh pr list --author @me --state open`
- [ ] 重要な作業を一時保存: `git add . && git commit -m "wip: save current work"`
- [ ] プロジェクトのバックアップ（オプション）

### ✅ 環境確認

- [ ] GitHub CLIが利用可能: `gh --version`
- [ ] 適切な権限でGitHubにログイン: `gh auth status`
- [ ] curlまたはwgetが利用可能
- [ ] bashシェルが利用可能

---

## ⚡ クイック適用（推奨）

### ✅ ワンライナー実行

```bash
# チェックボックスをクリックしながら実行
curl -sSL https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/quick-deploy.sh | bash
```

- [ ] コマンド実行完了
- [ ] エラーメッセージなし
- [ ] `CLAUDE.md`ファイル作成確認: `ls -la CLAUDE.md`
- [ ] ワークフローファイル作成確認: `ls -la .github/workflows/draft-pr-quick-check.yml`

---

## 🔍 動作確認

### ✅ Claude Code への指示

Claude Codeに以下を明確に伝える：

- [ ] "CLAUDE.mdファイルが更新されました。内容を確認してください。"
- [ ] "今後のPRは必ずドラフトで作成してください（gh pr create --draft）"
- [ ] "レビュー準備完了時のみ gh pr ready を実行してください"

### ✅ テスト実行

```bash
# テスト用の変更を作成
echo "# Optimization Test" >> README.md
git add README.md
git commit -m "test: optimization system verification"
```

- [ ] テスト変更作成完了
- [ ] Claude CodeがドラフトPRを作成することを確認
- [ ] GitHub ActionsでdraftCheckワークフローが実行されることを確認
- [ ] 実行時間が1-3分以内であることを確認: `gh run list --limit 1`

---

## 🛠️ 高度な設定（必要に応じて）

### ✅ マルチインスタンス対応

複数のClaude Codeを使用する場合：

```bash
# 調整システムを初期化
./scripts/claude-coordinator.sh init
```

- [ ] 調整システム初期化完了
- [ ] インスタンスID生成確認: `echo $CLAUDE_INSTANCE_ID`
- [ ] 調整システム動作確認: `./scripts/claude-coordinator.sh status`

### ✅ カスタム設定

特別な要件がある場合：

- [ ] プロジェクト固有の設定を追加
- [ ] 除外ファイルの設定
- [ ] チーム固有ルールの適用

---

## 📊 効果測定

### ✅ 即座の確認

- [ ] 次のコミットでドラフトPRが作成される
- [ ] CI実行時間が大幅に短縮される（20分→1-3分）
- [ ] 既存の開発フローに影響なし

### ✅ 24時間後の確認

- [ ] 複数のドラフトPRで短時間CI実行を確認
- [ ] コスト削減効果を確認: `gh api repos/$GITHUB_REPOSITORY/actions/usage`
- [ ] エラーや問題が発生していないことを確認

---

## ⚠️ トラブル対応

### ✅ 一般的な問題

**問題**: Claude Codeが引き続き通常PRを作成

- [ ] CLAUDE.mdの存在を再確認
- [ ] Claude Codeに明示的に指示
- [ ] 必要に応じて手動でドラフトに変換: `gh pr ready --undo <PR番号>`

**問題**: CI が実行されない

- [ ] ワークフロー有効性確認: `gh workflow list`
- [ ] YAML構文エラー確認: `yamllint .github/workflows/*.yml`
- [ ] 条件式確認: `grep -n "if:" .github/workflows/*.yml`

### ✅ 緊急時対応

問題が発生した場合の緊急停止：

```bash
# 全ワークフローを一時停止
.github/disable-all-workflows.sh
```

- [ ] 緊急停止スクリプト確認
- [ ] 復旧手順の理解: `.github/enable-all-workflows.sh`

---

## 📝 チーム共有

### ✅ チームへの連絡

- [ ] チームメンバーに変更を通知
- [ ] 新しいワークフローの説明
- [ ] 質問受付窓口の設定

### ✅ ドキュメント共有

- [ ] README-ja.mdをチームに共有
- [ ] USAGE-GUIDE-ja.mdの関連セクションを案内
- [ ] FAQ-TROUBLESHOOTING-ja.mdをブックマーク

---

## 🎯 成功確認

### ✅ 最終チェック

すべてが正常に動作していることを確認：

- [ ] Claude Codeが新しいルールに従って動作
- [ ] ドラフトPRが自動作成される
- [ ] CI実行時間が大幅に短縮
- [ ] 開発フローに悪影響なし
- [ ] チーム全体が新システムを理解

### ✅ 長期モニタリング設定

- [ ] 週次コストレポートの設定
- [ ] パフォーマンス監視の設定
- [ ] 問題発生時のアラート設定

---

## 📞 サポート連絡先

何か問題が発生した場合：

- [ ] [FAQ-TROUBLESHOOTING-ja.md](./FAQ-TROUBLESHOOTING-ja.md) を確認
- [ ] [GitHub Issues](https://github.com/ootakazuhiko/claude-actions-optimizer/issues) でサポート要請
- [ ] 緊急時は一時停止後に調査

---

## ✨ 適用完了

すべてのチェックボックスが完了したら、最適化システムの適用が完了です！

**期待される効果**:
- 🎯 CI実行時間: 20分 → 1-3分（95%削減）
- 💰 月間コスト削減: 数百ドル
- 🚀 開発効率向上: 即座のフィードバック
- 👥 マルチインスタンス対応: 競合なし

---

**チェックリスト完了日**: _______________  
**適用者**: _______________  
**プロジェクト名**: _______________