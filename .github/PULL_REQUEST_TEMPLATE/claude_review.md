## Claude Code Review Template

**Target Claude Instance**: [Role-Name-Timestamp]
<!-- 例: [Frontend-Alice-1234567890] -->
<!-- 必ず対象のClaude Codeのインスタンス情報を記載してください -->

### Review Type
- [ ] Code Review / コードレビュー
- [ ] Design Review / 設計レビュー  
- [ ] Security Review / セキュリティレビュー
- [ ] Performance Review / パフォーマンスレビュー

### Severity / 重要度
- [ ] 🟢 Low - Minor improvements / 軽微な改善
- [ ] 🟡 Medium - Should be addressed / 対応推奨
- [ ] 🔴 High - Must be fixed / 要修正

### Review Summary / レビュー要約
<!-- 1-2文でレビューの要点を記載 -->

### Problems Identified / 問題点
1. 
2. 
3. 

### Suggestions for Improvement / 改善提案
1. 
2. 
3. 

### Code Examples / コード例
```language
// Before / 修正前
// Your current code here

// After / 修正後  
// Your suggested code here
```

### Action Items / アクションアイテム
<!-- Claude Codeが実行すべき具体的なタスク -->
- [ ] Action item 1
- [ ] Action item 2
- [ ] Action item 3

### Additional Context / 補足情報
<!-- 参考リンク、関連Issue、デザイン資料等 -->

### Expected Response / 期待する対応
<!-- いつまでに、どのような対応を期待するか -->

---
@claude-review
<!-- このタグを削除しないでください。Claude Code向けレビューの識別に使用されます -->

### How to use this template / テンプレートの使い方
1. Fill in the Claude instance ID at the top / 最上部にClaude インスタンスIDを記入
2. Check the appropriate review type and severity / レビュータイプと重要度を選択
3. Provide specific, actionable feedback / 具体的で実行可能なフィードバックを記載
4. Keep the @claude-review tag at the bottom / 最下部の@claude-reviewタグは削除しない