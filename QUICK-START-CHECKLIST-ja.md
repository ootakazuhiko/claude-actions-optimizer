# クイックスタート チェックリスト

## 🚀 5分で始めるClaude Actions Optimizer

### 📋 メイン端末セットアップ（管理者）

#### Step 1: 基本導入
- [ ] リポジトリに移動: `cd your-project`
- [ ] システムダウンロード: `curl -sSL https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/install.sh | bash`
- [ ] 完了確認: `ls .github/workflows/draft-pr-quick-check.yml`

#### Step 2: マルチインスタンス有効化
- [ ] 調整システム初期化: `./scripts/claude-coordinator.sh init`
- [ ] 個体識別設定: `./scripts/claude-identity.sh setup`
- [ ] 状態確認: `./scripts/claude-coordinator.sh status`

#### Step 3: GitHub設定
- [ ] ラベル作成: 自動作成されることを確認
- [ ] 設定コミット: `git add . && git commit -m "feat: setup optimization system"`
- [ ] プッシュ: `git push origin main`

---

### 💻 クライアント端末セットアップ

#### Step 1: 準備
- [ ] リポジトリクローン: `git clone <repository>`
- [ ] 最新取得: `git pull origin main`
- [ ] スクリプト権限: `chmod +x scripts/claude-*.sh`

#### Step 2: 個体設定
- [ ] 個体識別設定: `./scripts/claude-identity.sh setup`
- [ ] 役割選択: frontend/backend/devops/etc
- [ ] 設定確認: `./scripts/claude-identity.sh status`

#### Step 3: 接続確認
- [ ] 調整システム確認: `./scripts/claude-coordinator.sh check`
- [ ] 他インスタンス確認: `./scripts/claude-identity.sh list`

---

### ✅ 動作テスト

#### 全端末で実行
- [ ] テストファイル作成: `echo "# Test" > test.md`
- [ ] 識別コミット: `./scripts/claude-identity.sh commit "test: setup verification"`
- [ ] PR作成: `./scripts/claude-identity.sh pr "test: setup" "Testing system"`
- [ ] GitHub確認: `gh pr list` で識別情報付きPRを確認

#### マルチインスタンステスト
- [ ] 端末1でロック: `./scripts/claude-coordinator.sh lock test.txt`
- [ ] 端末2で試行: `./scripts/claude-coordinator.sh lock test.txt` (失敗するはず)
- [ ] 端末1で解放: `./scripts/claude-coordinator.sh unlock test.txt`
- [ ] 端末2で成功: `./scripts/claude-coordinator.sh lock test.txt` (成功するはず)

---

### 🎯 運用開始

#### 日常フロー
- [ ] 作業開始: `./scripts/claude-coordinator.sh check`
- [ ] ファイルロック: `./scripts/claude-coordinator.sh lock <file>`
- [ ] 識別コミット: `./scripts/claude-identity.sh commit "<message>"`
- [ ] 識別PR: `./scripts/claude-identity.sh pr "<title>" "<body>"`

#### 確認項目
- [ ] CI実行時間: 1-3分になることを確認
- [ ] ドラフトPR: 自動的にドラフトで作成されることを確認
- [ ] 個体識別: コミット・PRに識別情報が含まれることを確認
- [ ] 競合防止: ファイルロックが機能することを確認

---

### 📊 効果確認

#### 1週間後の確認
- [ ] コスト削減: `gh api repos/:owner/:repo/actions/usage`
- [ ] 活動レポート: `./scripts/claude-identity.sh report 7`
- [ ] 競合状況: `ls .claude/file_locks/` (空であることを確認)

---

## ⚠️ よくある問題

| 問題 | 解決法 |
|------|--------|
| 権限エラー | `chmod +x scripts/claude-*.sh` |
| CI未実行 | `gh workflow enable draft-pr-quick-check` |
| インスタンス未検出 | `git pull && ./scripts/claude-coordinator.sh init` |
| ロック取得失敗 | `./scripts/claude-coordinator.sh clean` |

---

## 🆘 緊急時

```bash
# 全システム一時停止
.github/disable-all-workflows.sh

# ロック全解除
rm -rf .claude/file_locks/*

# 復旧
.github/enable-all-workflows.sh
```

---

**セットアップ完了日**: _______________  
**担当者**: _______________