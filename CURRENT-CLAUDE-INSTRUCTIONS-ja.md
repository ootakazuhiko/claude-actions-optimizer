# 現在のClaude Codeに対する即座の指示

## 🎯 このドキュメントの目的

現在稼働中のClaude Codeに対して、GitHub Actions最適化システムを適用した直後に伝えるべき明確な指示をまとめています。

---

## 📢 Claude Code への緊急指示

### 最重要: 即座に実行してください

**Claude Code、以下の指示に従ってください：**

```
✅ CLAUDE.mdファイルが更新されました
✅ 内容を確認し、今後は以下のルールに厳密に従ってください
✅ 新しいPRは必ずドラフトで作成してください
✅ レビュー準備完了時のみ gh pr ready を実行してください
```

---

## 🔄 新しいワークフロー

### 1. PR作成時（必須）

```bash
# ❌ 今後は禁止
gh pr create --title "feat: new feature"

# ✅ 必ずこれを使用
gh pr create --draft --title "feat: new feature"
```

### 2. レビュー準備完了時のみ

```bash
# レビューの準備ができた時のみ実行
gh pr ready
```

### 3. マルチインスタンス使用時

```bash
# 作業前に必ず実行
./scripts/claude-coordinator.sh check

# ファイル編集前にロック
./scripts/claude-coordinator.sh lock src/filename.tsx

# 作業完了時にロック解放
./scripts/claude-coordinator.sh complete task-id
```

---

## 📋 変更点の確認

以下を確認してください：

### ✅ CLAUDE.mdの内容確認
```bash
cat CLAUDE.md
```

### ✅ 新しいワークフローファイル確認
```bash
ls -la .github/workflows/draft-pr-quick-check.yml
```

### ✅ マルチインスタンス対応確認（該当する場合）
```bash
ls -la scripts/claude-coordinator.sh
./scripts/claude-coordinator.sh status
```

---

## 🎯 期待される効果

この変更により：

1. **CI実行時間**: 20分 → 1-3分（95%削減）
2. **コスト削減**: 月数百ドルの節約
3. **並列作業**: 複数Claude Code間の競合なし
4. **開発効率**: 即座のフィードバック

---

## ⚠️ 重要な注意事項

1. **必ずドラフトPRを使用**
   - 通常のPRは避ける
   - コスト削減効果が失われます

2. **gh pr ready は慎重に**
   - レビュー準備が完全に整った時のみ
   - フルテストが実行されます（20分）

3. **マルチインスタンス環境では調整必須**
   - ファイルロック必須
   - 競合チェック必須

---

## 🧪 テスト実行

### 動作確認のため、以下をテストしてください：

```bash
# 1. テスト用の変更
echo "# Optimization Test" >> README.md
git add README.md
git commit -m "test: optimization system verification"

# 2. ドラフトPR作成（必須）
gh pr create --draft --title "test: optimization verification"

# 3. GitHub Actionsの実行確認
gh run list --limit 1

# 4. 実行時間確認（1-3分であることを確認）
```

---

## 🆘 トラブル時の対応

### 問題が発生した場合

1. **緊急停止**
   ```bash
   .github/disable-all-workflows.sh
   ```

2. **サポート確認**
   - [FAQ-TROUBLESHOOTING-ja.md](./FAQ-TROUBLESHOOTING-ja.md)
   - [GitHub Issues](https://github.com/ootakazuhiko/claude-actions-optimizer/issues)

3. **元に戻す**
   ```bash
   git checkout HEAD~1 -- CLAUDE.md
   ```

---

## 📞 確認事項

以下を Claude Code に確認してください：

- [ ] CLAUDE.md の内容を理解しましたか？
- [ ] ドラフトPRルールを理解しましたか？
- [ ] 今後のPR作成で --draft を使用しますか？
- [ ] レビュー準備完了時のみ gh pr ready を実行しますか？
- [ ] （該当する場合）マルチインスタンス調整を使用しますか？

---

## 🎉 成功の確認

Claude Code が正しく理解した場合、次のコミット時に：

1. 自動的にドラフトPRが作成される
2. GitHub ActionsでドラフトチェックのみAが実行される（1-3分）
3. フルテストは実行されない（コスト削減）

**これで95%のコスト削減が実現されます！**

---

**適用日時**: _______________  
**Claude Code確認**: [ ] 完了