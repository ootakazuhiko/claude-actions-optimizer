# claude-actions-optimizer 外部参照ガイド

このガイドでは、`shirokane-app-site-test-fork` などの他のプロジェクトから独立した `claude-actions-optimizer` リポジトリを参照して利用する方法を説明します。

## 🎯 推奨運用方法

### 方法1: シンボリックリンクを使用（推奨）

フォーク内の `claude-actions-optimizer` ディレクトリを削除し、独立したリポジトリへのシンボリックリンクを作成します。

```bash
# shirokane-app-site-test-fork ディレクトリで実行
cd /path/to/shirokane-app-site-test-fork

# 既存のディレクトリを削除（必要に応じてバックアップ）
rm -rf claude-actions-optimizer

# シンボリックリンクを作成
ln -s ../claude-actions-optimizer claude-actions-optimizer

# 確認
ls -la claude-actions-optimizer
```

**メリット:**
- 常に最新版を自動的に参照
- ディスク容量の節約
- メンテナンスが簡単

### 方法2: スクリプトによる同期

定期的に最新版を同期するスクリプトを使用します。

```bash
#!/bin/bash
# sync-claude-optimizer.sh

# 独立リポジトリから最新版を取得
cd /path/to/claude-actions-optimizer
git pull origin main

# 必要なファイルをコピー（フォーク側は変更しない）
echo "✅ claude-actions-optimizer は最新版です"
echo "📍 場所: $(pwd)"
```

### 方法3: 環境変数による参照

プロジェクトで環境変数を設定して外部リポジトリを参照します。

```bash
# .env または環境設定
export CLAUDE_OPTIMIZER_PATH="/path/to/claude-actions-optimizer"

# スクリプト内で使用
source "$CLAUDE_OPTIMIZER_PATH/install.sh"
```

## 📋 運用フロー

### 1. 初期セットアップ

```bash
# 独立したclaude-actions-optimizerリポジトリをクローン
cd /path/to/your/workspace
git clone https://github.com/ootakazuhiko/claude-actions-optimizer.git

# shirokane-app-site-test-fork内の古いディレクトリを削除
cd shirokane-app-site-test-fork
rm -rf claude-actions-optimizer

# シンボリックリンクを作成
ln -s ../claude-actions-optimizer claude-actions-optimizer
```

### 2. 更新時の操作

```bash
# 独立リポジトリを更新
cd /path/to/claude-actions-optimizer
git pull origin main

# フォーク側は自動的に最新版を参照（シンボリックリンクの場合）
```

### 3. プロジェクトでの使用

```bash
# shirokane-app-site-test-fork で作業
cd /path/to/shirokane-app-site-test-fork

# claude-actions-optimizer のスクリプトを実行
./claude-actions-optimizer/install.sh
```

## ⚠️ 注意事項

1. **Git管理**: シンボリックリンクを使用する場合、`.gitignore` に追加することを推奨
   ```
   # .gitignore
   claude-actions-optimizer
   ```

2. **パス依存**: 相対パスでシンボリックリンクを作成した場合、ディレクトリ構造の変更に注意

3. **CI/CD**: GitHub Actions などでは、実行時に独立リポジトリをクローンする必要があります
   ```yaml
   - name: Clone claude-actions-optimizer
     run: |
       git clone https://github.com/ootakazuhiko/claude-actions-optimizer.git
   ```

## 🔧 トラブルシューティング

### シンボリックリンクが機能しない場合

```bash
# 絶対パスで再作成
ln -sf /absolute/path/to/claude-actions-optimizer claude-actions-optimizer
```

### 権限エラーが発生する場合

```bash
# 実行権限を確認
chmod +x claude-actions-optimizer/scripts/*.sh
```

## 📚 関連ドキュメント

- [README.md](README.md) - プロジェクト概要
- [USAGE-GUIDE-ja.md](USAGE-GUIDE-ja.md) - 詳細な使用方法
- [FAQ-TROUBLESHOOTING-ja.md](FAQ-TROUBLESHOOTING-ja.md) - よくある質問