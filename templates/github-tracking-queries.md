# GitHub追跡クエリ集

## 🔍 Claude Code インスタンス追跡用GitHubクエリ

### コミット検索クエリ

```bash
# 特定インスタンスのコミット検索
git log --grep="[Frontend-Alice]" --oneline --since="1 week ago"

# 役割別コミット検索
git log --grep="[Backend-" --oneline --since="1 month ago"

# 全Claude Codeのコミット統計
git log --grep="\[.*-.*\]" --pretty=format:"%an | %s" --since="1 week ago" | sort | uniq -c

# 期間別コミット数
for role in frontend backend devops; do
  echo "$role: $(git log --grep="[$role-" --oneline --since="1 week ago" | wc -l) commits"
done
```

### PR検索クエリ

```bash
# 特定インスタンスのPR検索
gh pr list --search "[Frontend-Alice]" --state all --json title,createdAt,state

# 役割別PR検索
gh pr list --search "[Backend-" --state all --limit 20

# Claude Code全体のPR統計
gh pr list --search "author:claude OR [" --state all --json author,title,createdAt

# ドラフトPRの状況
gh pr list --search "is:draft [" --json title,author,createdAt

# マージ済みPRの分析
gh pr list --search "is:merged [" --limit 50 --json title,mergedAt,createdAt
```

### Issue追跡クエリ

```bash
# Claude Codeが作成したIssue
gh issue list --search "author:claude" --state all

# 特定ラベル付きIssue
gh issue list --label "claude:frontend" --state all

# Claude関連のすべてのIssue
gh issue list --search "claude OR [frontend- OR [backend- OR [devops-" --state all
```

### 高度な分析クエリ

```bash
# インスタンス別生産性分析
generate_productivity_report() {
    local instance="$1"
    local days="${2:-30}"
    
    echo "=== Productivity Report: $instance (Last $days days) ==="
    
    # コミット数
    local commits=$(git log --grep="[$instance]" --since="$days days ago" --oneline | wc -l)
    echo "Commits: $commits"
    
    # PR数
    local prs=$(gh pr list --search "[$instance]" --state all --limit 100 --json createdAt | \
                jq --arg days "$days" '[.[] | select((.createdAt | fromdateiso8601) > (now - ($days | tonumber) * 86400))] | length')
    echo "PRs: $prs"
    
    # 変更行数
    local lines_changed=$(git log --grep="[$instance]" --since="$days days ago" --numstat --pretty=format: | \
                          awk '{add+=$1; del+=$2} END {print "Added: " add ", Deleted: " del}')
    echo "Lines changed: $lines_changed"
    
    # 平均マージ時間
    local avg_merge_time=$(gh pr list --search "[$instance] is:merged" --limit 20 --json mergedAt,createdAt | \
                          jq -r '.[] | ((.mergedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 3600' | \
                          awk '{sum+=$1; count++} END {if(count>0) print sum/count " hours"; else print "N/A"}')
    echo "Avg merge time: $avg_merge_time"
}

# 役割別効率性分析
analyze_role_efficiency() {
    echo "=== Role Efficiency Analysis ==="
    
    for role in frontend backend devops testing documentation; do
        echo ""
        echo "🎯 Role: $role"
        
        # 最近30日のコミット数
        local commits=$(git log --grep="\[$role-" --since="30 days ago" --oneline | wc -l)
        
        # PR数とマージ率
        local total_prs=$(gh pr list --search "[$role-" --state all --limit 100 --json state | jq length)
        local merged_prs=$(gh pr list --search "[$role- is:merged" --limit 100 --json state | jq length)
        local merge_rate=$(echo "scale=1; $merged_prs * 100 / $total_prs" | bc 2>/dev/null || echo "N/A")
        
        echo "  Commits (30d): $commits"
        echo "  Total PRs: $total_prs"
        echo "  Merged PRs: $merged_prs"
        echo "  Merge rate: ${merge_rate}%"
        
        # 最も活発なインスタンス
        local top_instance=$(git log --grep="\[$role-" --since="30 days ago" --pretty=format:"%s" | \
                            grep -o "\[$role-[^]]*\]" | sort | uniq -c | sort -nr | head -1 | \
                            awk '{print $2}')
        echo "  Most active: $top_instance"
    done
}

# チーム協調分析
analyze_team_coordination() {
    echo "=== Team Coordination Analysis ==="
    
    # 同じファイルへの協調作業
    echo "File collaboration patterns:"
    git log --since="1 week ago" --name-only --pretty=format:"%s" | \
    grep -E "^\[.*-.*\]" -A 10 | \
    grep -v "^\[" | grep -v "^$" | sort | uniq -c | sort -nr | head -10
    
    # PR相互レビュー
    echo ""
    echo "PR review patterns:"
    gh pr list --state all --limit 50 --json title,reviews | \
    jq -r '.[] | select(.title | contains("[")) | .title as $title | .reviews[] | "\($title) reviewed by \(.author.login)"' | \
    head -10
    
    # 競合発生頻度
    echo ""
    echo "Merge conflicts in last 30 days:"
    git log --since="30 days ago" --grep="Merge conflict\|merge conflict" --oneline | wc -l
}
```

### GitHub Actions ワークフロー追跡

```yaml
# .github/workflows/claude-tracking.yml
name: Claude Instance Tracking

on:
  push:
    branches: [ main, develop ]
  pull_request:
    types: [ opened, closed, merged ]

jobs:
  track-claude-activity:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Extract Claude instance info
        id: claude-info
        run: |
          # Extract instance info from commit message or PR title
          CLAUDE_INSTANCE=""
          if [[ "${{ github.event_name }}" == "push" ]]; then
            CLAUDE_INSTANCE=$(git log -1 --pretty=format:"%s" | grep -o '\[.*-.*\]' || echo "unknown")
          elif [[ "${{ github.event_name }}" == "pull_request" ]]; then
            CLAUDE_INSTANCE=$(echo "${{ github.event.pull_request.title }}" | grep -o '\[.*-.*\]' || echo "unknown")
          fi
          echo "claude_instance=$CLAUDE_INSTANCE" >> $GITHUB_OUTPUT
          
      - name: Update activity metrics
        if: steps.claude-info.outputs.claude_instance != 'unknown'
        run: |
          echo "Claude instance: ${{ steps.claude-info.outputs.claude_instance }}"
          echo "Activity type: ${{ github.event_name }}"
          echo "Repository: ${{ github.repository }}"
          echo "Timestamp: $(date -Iseconds)"
          
      - name: Generate daily report
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        run: |
          # Generate daily activity report
          cat > claude-daily-report.md << 'EOF'
          # Claude Code Daily Activity Report
          
          **Date**: $(date +%Y-%m-%d)
          **Repository**: ${{ github.repository }}
          
          ## Today's Activity
          
          $(git log --since="1 day ago" --grep='\[.*-.*\]' --pretty=format:"- %s (%an, %ar)" | head -10)
          
          ## Active Instances
          
          $(git log --since="1 day ago" --grep='\[.*-.*\]' --pretty=format:"%s" | grep -o '\[.*-.*\]' | sort | uniq -c)
          
          EOF
          
      - name: Comment on PR with instance info
        if: github.event_name == 'pull_request' && github.event.action == 'opened'
        uses: actions/github-script@v7
        with:
          script: |
            const claudeInstance = '${{ steps.claude-info.outputs.claude_instance }}';
            if (claudeInstance !== 'unknown') {
              github.rest.issues.createComment({
                issue_number: context.issue.number,
                owner: context.repo.owner,
                repo: context.repo.repo,
                body: `🤖 **Claude Instance Detected**: ${claudeInstance}\n\nThis PR was created by a Claude Code instance. Automated tracking enabled.`
              });
            }
```

### 検索とフィルタリングのベストプラクティス

```bash
# よく使用する検索パターンをエイリアス化
alias claude-commits="git log --grep='\[.*-.*\]' --oneline"
alias claude-prs="gh pr list --search '[' --state all"
alias claude-issues="gh issue list --search 'claude OR ['"

# 統計情報の自動生成
alias claude-stats="echo 'Commits:' && claude-commits --since='1 week ago' | wc -l && echo 'PRs:' && claude-prs --limit 100 | wc -l"

# 特定期間の活動サマリー
claude_activity_summary() {
    local period="${1:-1 week ago}"
    echo "=== Claude Activity Summary (since $period) ==="
    echo ""
    echo "📝 Commits by role:"
    for role in frontend backend devops testing documentation; do
        local count=$(git log --grep="\[$role-" --since="$period" --oneline | wc -l)
        [ "$count" -gt 0 ] && echo "  $role: $count"
    done
    
    echo ""
    echo "🔀 PRs by state:"
    echo "  Open: $(gh pr list --search "is:open [" | wc -l)"
    echo "  Merged: $(gh pr list --search "is:merged [" --limit 100 | wc -l)"
    echo "  Closed: $(gh pr list --search "is:closed [" --limit 100 | wc -l)"
}

# インスタンス協調状況の確認
check_instance_coordination() {
    echo "=== Instance Coordination Status ==="
    
    # 現在アクティブなインスタンス
    echo "Active instances:"
    if [ -f .claude/instances.yml ]; then
        awk '/name:/ {name=$2} /status: "active"/ {print "  " name}' .claude/instances.yml
    fi
    
    # ロック状況
    echo ""
    echo "Current locks:"
    if [ -f .claude/locks.yml ]; then
        grep -E "(path|locked_by)" .claude/locks.yml | paste - - | sed 's/^/  /'
    else
        echo "  No active locks"
    fi
    
    # 最近の競合
    echo ""
    echo "Recent coordination events:"
    if [ -f .claude/audit.log ]; then
        tail -5 .claude/audit.log | sed 's/^/  /'
    fi
}
```

これらのクエリを使用することで、GitHub上でClaude Codeインスタンスの活動を詳細に追跡し、分析することが可能になります。