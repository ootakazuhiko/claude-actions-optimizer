# Claude Code レビューフィードバックシステム

## 📋 概要

Claude Codeのアウトプットに対して、人間や他のAIからのレビューを構造化して収集し、元のClaude Code個体にフィードバックを届けるシステムです。

## 🎯 システム設計

### 1. レビュー識別メカニズム

```markdown
<!-- PRコメントでのレビュー例 -->
@claude-review [Frontend-Alice-1234567890]

## レビュー結果
- **タイプ**: コードレビュー
- **評価**: 要改善
- **重要度**: 高

### 問題点
1. エラーハンドリングが不十分
2. 型定義が一部欠落
3. テストカバレッジが低い

### 改善提案
```typescript
// Before
const fetchData = async () => {
  const res = await fetch('/api/data');
  return res.json();
};

// After - エラーハンドリング追加
const fetchData = async () => {
  try {
    const res = await fetch('/api/data');
    if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
    return await res.json();
  } catch (error) {
    console.error('Failed to fetch data:', error);
    throw error;
  }
};
```

### アクションアイテム
- [ ] エラーハンドリングの追加
- [ ] TypeScript型定義の補完
- [ ] ユニットテストの追加
```

### 2. GitHub Actions ワークフロー

```yaml
# .github/workflows/claude-review-processor.yml
name: Claude Review Processor

on:
  issue_comment:
    types: [created, edited]
  pull_request_review:
    types: [submitted]
  pull_request_review_comment:
    types: [created]

jobs:
  process-review:
    runs-on: ubuntu-latest
    if: contains(github.event.comment.body, '@claude-review') || contains(github.event.review.body, '@claude-review')
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Extract Claude Instance Info
        id: extract
        run: |
          # レビューからインスタンスIDを抽出
          COMMENT_BODY="${{ github.event.comment.body || github.event.review.body }}"
          INSTANCE_ID=$(echo "$COMMENT_BODY" | grep -oP '\[([A-Za-z]+-[A-Za-z]+-[0-9]+)\]' | head -1 | tr -d '[]')
          echo "instance_id=$INSTANCE_ID" >> $GITHUB_OUTPUT
          
          # インスタンス情報を分解
          ROLE=$(echo "$INSTANCE_ID" | cut -d'-' -f1)
          NAME=$(echo "$INSTANCE_ID" | cut -d'-' -f2)
          echo "role=$ROLE" >> $GITHUB_OUTPUT
          echo "name=$NAME" >> $GITHUB_OUTPUT
      
      - name: Parse Review Content
        id: parse
        run: |
          # レビュー内容をパース
          python3 scripts/parse_review.py \
            --comment "${{ github.event.comment.body || github.event.review.body }}" \
            --output review_data.json
      
      - name: Store Review Feedback
        run: |
          # レビューを構造化して保存
          mkdir -p .claude/reviews/${{ steps.extract.outputs.instance_id }}
          
          cat > .claude/reviews/${{ steps.extract.outputs.instance_id }}/review-${{ github.run_id }}.json << EOF
          {
            "review_id": "${{ github.run_id }}",
            "instance_id": "${{ steps.extract.outputs.instance_id }}",
            "pr_number": "${{ github.event.pull_request.number || github.event.issue.number }}",
            "reviewer": "${{ github.event.comment.user.login || github.event.review.user.login }}",
            "timestamp": "$(date -Iseconds)",
            "review_type": "$(cat review_data.json | jq -r .type)",
            "severity": "$(cat review_data.json | jq -r .severity)",
            "content": $(cat review_data.json | jq .content),
            "action_items": $(cat review_data.json | jq .action_items),
            "github_url": "${{ github.event.comment.html_url || github.event.review.html_url }}"
          }
          EOF
      
      - name: Create Review Issue
        if: steps.parse.outputs.severity == 'high'
        uses: actions/github-script@v7
        with:
          script: |
            const instanceId = '${{ steps.extract.outputs.instance_id }}';
            const role = '${{ steps.extract.outputs.role }}';
            const name = '${{ steps.extract.outputs.name }}';
            
            // 高重要度レビューの場合、専用Issueを作成
            const issue = await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `[Review] Action required for ${instanceId}`,
              body: `## 📋 レビューフィードバック
              
              **対象Claude**: ${name} (${role})
              **PR**: #${{ github.event.pull_request.number || github.event.issue.number }}
              **レビュアー**: @${{ github.event.comment.user.login || github.event.review.user.login }}
              
              ### アクションアイテム
              ${JSON.parse(fs.readFileSync('review_data.json', 'utf8')).action_items.map(item => `- [ ] ${item}`).join('\n')}
              
              ---
              [元のレビューを見る](${{ github.event.comment.html_url || github.event.review.html_url }})`,
              labels: [`claude:${role}`, `claude:${name}`, 'review-feedback', 'action-required']
            });
      
      - name: Update PR Status
        if: github.event.pull_request
        run: |
          # PRステータスを更新
          gh pr review ${{ github.event.pull_request.number }} \
            --comment "🤖 Review feedback stored for ${{ steps.extract.outputs.instance_id }}"
```

### 3. レビュー取得スクリプト

```bash
#!/bin/bash
# scripts/claude-review-check.sh
# Claude Codeがレビューフィードバックを確認するスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

# 現在のインスタンス情報を取得
if [ -f "$CLAUDE_DIR/identity/current.json" ]; then
    INSTANCE_ID=$(jq -r '.instance_id' "$CLAUDE_DIR/identity/current.json")
    NAME=$(jq -r '.name' "$CLAUDE_DIR/identity/current.json")
    ROLE=$(jq -r '.role' "$CLAUDE_DIR/identity/current.json")
else
    echo "❌ Claude identity not configured"
    exit 1
fi

# レビューをチェック
check_reviews() {
    local days="${1:-7}"
    
    echo "🔍 Checking reviews for $NAME ($ROLE) - Last $days days"
    echo "============================================"
    
    # ローカルストレージから確認
    local review_dir="$CLAUDE_DIR/reviews/$INSTANCE_ID"
    if [ -d "$review_dir" ]; then
        local review_count=$(find "$review_dir" -name "*.json" -mtime -$days | wc -l)
        echo "📋 Found $review_count local reviews"
        
        # 各レビューを表示
        find "$review_dir" -name "*.json" -mtime -$days | while read review_file; do
            echo ""
            echo "--- Review: $(basename $review_file) ---"
            jq -r '
                "PR: #\(.pr_number)",
                "Reviewer: \(.reviewer)",
                "Type: \(.review_type)",
                "Severity: \(.severity)",
                "Date: \(.timestamp)",
                "",
                "Action Items:",
                (.action_items[] | "  - \(.)")
            ' "$review_file"
        done
    fi
    
    # GitHub APIから確認
    echo ""
    echo "📊 Checking GitHub for reviews..."
    
    # 自分宛のメンションを検索
    gh search issues "@claude-review [$ROLE-$NAME" \
        --repo "$GITHUB_REPOSITORY" \
        --limit 20 \
        --json number,title,createdAt,url,body | \
    jq -r '.[] | 
        "Issue #\(.number): \(.title)",
        "Created: \(.createdAt)",
        "URL: \(.url)",
        ""'
    
    # 未対応のアクションアイテムを確認
    echo ""
    echo "⚠️ Pending Action Items:"
    gh issue list --label "claude:$NAME" --label "action-required" \
        --json number,title,url | \
    jq -r '.[] | "  - #\(.number): \(.title)"'
}

# 特定のPRのレビューを取得
get_pr_reviews() {
    local pr_number="$1"
    
    echo "📝 Getting reviews for PR #$pr_number"
    
    # PRコメントからレビューを抽出
    gh pr view $pr_number --comments --json comments | \
    jq -r '.comments[] | 
        select(.body | contains("@claude-review")) | 
        select(.body | contains("['$ROLE'-'$NAME'")) |
        "---",
        "Author: \(.author.login)",
        "Date: \(.createdAt)",
        "",
        .body,
        ""'
}

# レビューに基づくアクション実行
apply_review_feedback() {
    local review_file="$1"
    
    if [ ! -f "$review_file" ]; then
        echo "❌ Review file not found"
        return 1
    fi
    
    echo "🔧 Applying feedback from review..."
    
    # レビュー内容を読み込み
    local pr_number=$(jq -r '.pr_number' "$review_file")
    local action_items=$(jq -r '.action_items[]' "$review_file")
    
    # ブランチを作成
    local branch_name="review-feedback-$pr_number-$(date +%s)"
    git checkout -b "$branch_name"
    
    echo "📌 Created branch: $branch_name"
    echo "📋 Action items to address:"
    echo "$action_items" | nl
    
    # レビュー対応用のテンプレートを作成
    cat > review-response.md << EOF
# Review Response for PR #$pr_number

## Addressed Feedback
$(echo "$action_items" | sed 's/^/- [ ] /')

## Changes Made
- 

## Testing
- 

---
Review data: $review_file
Claude Instance: $INSTANCE_ID
EOF
    
    echo "✅ Ready to address review feedback"
    echo "📝 Edit review-response.md to track your progress"
}

# メイン処理
main() {
    case "${1:-check}" in
        "check")
            check_reviews "${2:-7}"
            ;;
        "pr")
            get_pr_reviews "$2"
            ;;
        "apply")
            apply_review_feedback "$2"
            ;;
        "sync")
            # GitHubから最新のレビューを同期
            echo "🔄 Syncing reviews from GitHub..."
            mkdir -p "$CLAUDE_DIR/reviews/$INSTANCE_ID"
            
            # 最近のレビューを取得して保存
            gh api graphql -f query='
            {
              search(query: "repo:OWNER/REPO @claude-review ['$ROLE'-'$NAME'", type: ISSUE, first: 10) {
                nodes {
                  ... on Issue {
                    number
                    title
                    body
                    createdAt
                    author { login }
                    url
                  }
                  ... on PullRequest {
                    number
                    title
                    body
                    createdAt
                    author { login }
                    url
                  }
                }
              }
            }' | jq -r '.data.search.nodes[]' > "$CLAUDE_DIR/reviews/$INSTANCE_ID/sync-$(date +%s).json"
            
            echo "✅ Sync completed"
            ;;
        *)
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  check [days]     Check reviews (default: last 7 days)"
            echo "  pr <number>      Get reviews for specific PR"
            echo "  apply <file>     Apply feedback from review file"
            echo "  sync             Sync reviews from GitHub"
            ;;
    esac
}

main "$@"
```

### 4. レビューダッシュボード

```typescript
// frontend/src/features/claude-review/ReviewDashboard.tsx
import React, { useEffect, useState } from 'react';
import { Card, Badge, Timeline, Button, Alert } from 'antd';
import { CheckCircleOutlined, ClockCircleOutlined, ExclamationCircleOutlined } from '@ant-design/icons';

interface Review {
  review_id: string;
  instance_id: string;
  pr_number: number;
  reviewer: string;
  timestamp: string;
  review_type: 'code' | 'design' | 'security' | 'performance';
  severity: 'low' | 'medium' | 'high';
  content: {
    summary: string;
    problems: string[];
    suggestions: string[];
    code_examples?: string[];
  };
  action_items: string[];
  status: 'pending' | 'in_progress' | 'completed';
}

export const ReviewDashboard: React.FC = () => {
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);
  const [instanceId, setInstanceId] = useState<string>('');

  useEffect(() => {
    // 現在のClaude instanceを取得
    fetch('/.claude/identity/current.json')
      .then(res => res.json())
      .then(data => {
        setInstanceId(data.instance_id);
        return fetchReviews(data.instance_id);
      })
      .then(setReviews)
      .finally(() => setLoading(false));
  }, []);

  const fetchReviews = async (instanceId: string): Promise<Review[]> => {
    const response = await fetch(`/api/claude/reviews/${instanceId}`);
    return response.json();
  };

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'high': return 'red';
      case 'medium': return 'orange';
      case 'low': return 'green';
      default: return 'default';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'completed': return <CheckCircleOutlined style={{ color: 'green' }} />;
      case 'in_progress': return <ClockCircleOutlined style={{ color: 'orange' }} />;
      default: return <ExclamationCircleOutlined style={{ color: 'red' }} />;
    }
  };

  if (loading) return <div>Loading reviews...</div>;

  return (
    <div className="review-dashboard">
      <h2>📋 Review Feedback Dashboard</h2>
      <Alert
        message={`Claude Instance: ${instanceId}`}
        type="info"
        showIcon
        style={{ marginBottom: 16 }}
      />

      <div className="review-stats">
        <Card>
          <div>Total Reviews: {reviews.length}</div>
          <div>Pending: {reviews.filter(r => r.status === 'pending').length}</div>
          <div>High Priority: {reviews.filter(r => r.severity === 'high').length}</div>
        </Card>
      </div>

      <Timeline style={{ marginTop: 24 }}>
        {reviews.map(review => (
          <Timeline.Item
            key={review.review_id}
            dot={getStatusIcon(review.status)}
          >
            <Card
              title={
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span>PR #{review.pr_number} - {review.review_type} Review</span>
                  <Badge color={getSeverityColor(review.severity)} text={review.severity} />
                </div>
              }
              extra={<span>by @{review.reviewer}</span>}
            >
              <h4>Summary</h4>
              <p>{review.content.summary}</p>

              {review.content.problems.length > 0 && (
                <>
                  <h4>Problems Identified</h4>
                  <ul>
                    {review.content.problems.map((problem, idx) => (
                      <li key={idx}>{problem}</li>
                    ))}
                  </ul>
                </>
              )}

              <h4>Action Items</h4>
              {review.action_items.map((item, idx) => (
                <div key={idx}>
                  <input
                    type="checkbox"
                    checked={review.status === 'completed'}
                    onChange={() => handleActionItemToggle(review.review_id, idx)}
                  />
                  <span style={{ marginLeft: 8 }}>{item}</span>
                </div>
              ))}

              <div style={{ marginTop: 16 }}>
                <Button
                  type="primary"
                  onClick={() => handleApplyFeedback(review)}
                >
                  Apply Feedback
                </Button>
                <Button
                  style={{ marginLeft: 8 }}
                  onClick={() => window.open(`https://github.com/owner/repo/pull/${review.pr_number}`)}
                >
                  View PR
                </Button>
              </div>
            </Card>
          </Timeline.Item>
        ))}
      </Timeline>
    </div>
  );

  function handleActionItemToggle(reviewId: string, itemIndex: number) {
    // アクションアイテムの完了状態を更新
    console.log('Toggle action item', reviewId, itemIndex);
  }

  function handleApplyFeedback(review: Review) {
    // レビューフィードバックを適用
    console.log('Apply feedback', review);
  }
};
```

### 5. バックエンドAPI

```python
# backend/app/blueprints/claude_review.py
from flask import Blueprint, jsonify, request
from datetime import datetime, timedelta
import json
import os
from pathlib import Path

claude_review_bp = Blueprint('claude_review', __name__)

@claude_review_bp.route('/api/claude/reviews/<instance_id>', methods=['GET'])
def get_reviews(instance_id):
    """特定のClaude instanceのレビューを取得"""
    days = request.args.get('days', 7, type=int)
    status = request.args.get('status', None)
    
    review_dir = Path(f'.claude/reviews/{instance_id}')
    if not review_dir.exists():
        return jsonify([])
    
    reviews = []
    cutoff_date = datetime.now() - timedelta(days=days)
    
    for review_file in review_dir.glob('*.json'):
        with open(review_file, 'r') as f:
            review = json.load(f)
            
        # 日付フィルタ
        review_date = datetime.fromisoformat(review['timestamp'].replace('Z', '+00:00'))
        if review_date < cutoff_date:
            continue
            
        # ステータスフィルタ
        if status and review.get('status') != status:
            continue
            
        reviews.append(review)
    
    # 新しい順にソート
    reviews.sort(key=lambda x: x['timestamp'], reverse=True)
    
    return jsonify(reviews)

@claude_review_bp.route('/api/claude/reviews/<instance_id>/<review_id>', methods=['PATCH'])
def update_review_status(instance_id, review_id):
    """レビューのステータスを更新"""
    data = request.json
    new_status = data.get('status')
    
    if new_status not in ['pending', 'in_progress', 'completed']:
        return jsonify({'error': 'Invalid status'}), 400
    
    review_file = Path(f'.claude/reviews/{instance_id}/review-{review_id}.json')
    if not review_file.exists():
        return jsonify({'error': 'Review not found'}), 404
    
    with open(review_file, 'r') as f:
        review = json.load(f)
    
    review['status'] = new_status
    review['updated_at'] = datetime.now().isoformat()
    
    with open(review_file, 'w') as f:
        json.dump(review, f, indent=2)
    
    return jsonify(review)

@claude_review_bp.route('/api/claude/reviews/webhook', methods=['POST'])
def process_github_webhook():
    """GitHubからのレビューWebhookを処理"""
    event = request.headers.get('X-GitHub-Event')
    payload = request.json
    
    if event == 'issue_comment' and '@claude-review' in payload.get('comment', {}).get('body', ''):
        # レビューコメントを処理
        return process_review_comment(payload)
    
    return jsonify({'status': 'ignored'}), 200

def process_review_comment(payload):
    """レビューコメントを解析して保存"""
    comment_body = payload['comment']['body']
    
    # インスタンスIDを抽出
    import re
    instance_match = re.search(r'\[([A-Za-z]+-[A-Za-z]+-[0-9]+)\]', comment_body)
    if not instance_match:
        return jsonify({'error': 'No instance ID found'}), 400
    
    instance_id = instance_match.group(1)
    
    # レビュー内容を解析
    review_data = parse_review_content(comment_body)
    
    # レビューを保存
    review = {
        'review_id': str(payload['comment']['id']),
        'instance_id': instance_id,
        'pr_number': payload['issue']['number'],
        'reviewer': payload['comment']['user']['login'],
        'timestamp': payload['comment']['created_at'],
        'review_type': review_data.get('type', 'general'),
        'severity': review_data.get('severity', 'medium'),
        'content': review_data.get('content', {}),
        'action_items': review_data.get('action_items', []),
        'status': 'pending',
        'github_url': payload['comment']['html_url']
    }
    
    # ファイルに保存
    review_dir = Path(f'.claude/reviews/{instance_id}')
    review_dir.mkdir(parents=True, exist_ok=True)
    
    review_file = review_dir / f"review-{review['review_id']}.json"
    with open(review_file, 'w') as f:
        json.dump(review, f, indent=2)
    
    # 通知を送信（Redis経由など）
    notify_claude_instance(instance_id, review)
    
    return jsonify({'status': 'processed', 'review_id': review['review_id']})
```

### 6. レビューテンプレート

```markdown
<!-- .github/PULL_REQUEST_TEMPLATE/claude_review.md -->
## Claude Code Review Template

**Target Claude Instance**: [Role-Name-Timestamp]
<!-- 例: [Frontend-Alice-1234567890] -->

### Review Type
- [ ] Code Review
- [ ] Design Review
- [ ] Security Review
- [ ] Performance Review

### Severity
- [ ] 🟢 Low - Minor improvements
- [ ] 🟡 Medium - Should be addressed
- [ ] 🔴 High - Must be fixed

### Review Summary
<!-- 1-2文でレビューの要点を記載 -->

### Problems Identified
1. 
2. 
3. 

### Suggestions for Improvement
1. 
2. 
3. 

### Code Examples (if applicable)
```language
// Your code example here
```

### Action Items
- [ ] Action item 1
- [ ] Action item 2
- [ ] Action item 3

### Additional Context
<!-- 参考リンク、関連Issue等 -->

---
@claude-review
```

## 🚀 実装手順

1. **GitHub Webhookの設定**
   ```bash
   # リポジトリ設定でWebhookを追加
   # URL: https://your-app.com/api/claude/reviews/webhook
   # Events: Issue comments, Pull request reviews
   ```

2. **ワークフローの追加**
   ```bash
   cp claude-review-processor.yml .github/workflows/
   ```

3. **レビュースクリプトの配置**
   ```bash
   cp claude-review-check.sh scripts/
   chmod +x scripts/claude-review-check.sh
   ```

4. **Claude Codeでの使用**
   ```bash
   # レビューを確認
   ./scripts/claude-review-check.sh check
   
   # 特定PRのレビューを取得
   ./scripts/claude-review-check.sh pr 123
   
   # レビューを適用
   ./scripts/claude-review-check.sh apply .claude/reviews/instance-id/review-123.json
   ```

## 📊 効果

- **即座のフィードバック**: レビューが自動的に構造化されて保存
- **追跡可能性**: 全てのレビューが個体別に記録
- **アクション管理**: 未対応項目の可視化
- **継続的改善**: フィードバックループの確立