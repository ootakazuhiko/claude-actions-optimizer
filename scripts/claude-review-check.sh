#!/bin/bash
# Claude Code Review Feedback Checker
# レビューフィードバックを確認・適用するスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Emojis
REVIEW="📋"
CHECK="✅"
WARNING="⚠️"
ERROR="❌"
SEARCH="🔍"
ACTION="🎯"

# 現在のインスタンス情報を取得
load_instance_info() {
    if [ -f "$CLAUDE_DIR/identity/current.json" ]; then
        INSTANCE_ID=$(jq -r '.instance_id' "$CLAUDE_DIR/identity/current.json")
        NAME=$(jq -r '.name' "$CLAUDE_DIR/identity/current.json")
        ROLE=$(jq -r '.role' "$CLAUDE_DIR/identity/current.json")
        return 0
    else
        echo -e "${ERROR} Claude identity not configured"
        echo -e "${BLUE}Run: ./scripts/claude-identity.sh setup${NC}"
        return 1
    fi
}

# レビューをチェック
check_reviews() {
    local days="${1:-7}"
    
    echo -e "${SEARCH} Checking reviews for ${YELLOW}$NAME${NC} (${BLUE}$ROLE${NC}) - Last $days days"
    echo "============================================"
    
    # ローカルストレージから確認
    local review_dir="$CLAUDE_DIR/reviews/$INSTANCE_ID"
    if [ -d "$review_dir" ]; then
        local review_count=$(find "$review_dir" -name "*.json" -mtime -$days 2>/dev/null | wc -l)
        echo -e "${REVIEW} Found ${GREEN}$review_count${NC} local reviews"
        
        if [ "$review_count" -gt 0 ]; then
            # 各レビューを表示
            find "$review_dir" -name "*.json" -mtime -$days | sort -r | while read review_file; do
                echo ""
                echo -e "${BLUE}--- Review: $(basename $review_file) ---${NC}"
                
                # レビュー内容を整形して表示
                jq -r '
                    def severity_color:
                        if . == "high" then "\u001b[31m" # Red
                        elif . == "medium" then "\u001b[33m" # Yellow
                        else "\u001b[32m" # Green
                        end;
                    
                    "PR: #\(.pr_number)",
                    "Reviewer: @\(.reviewer)",
                    "Type: \(.review_type)",
                    "Severity: \((.severity | severity_color) + .severity + "\u001b[0m")",
                    "Date: \(.timestamp)",
                    "Status: \(.status // "pending")",
                    "",
                    "Summary: \(.content.summary // "N/A")",
                    "",
                    "Action Items:",
                    (.action_items[] | "  ☐ \(.)")
                ' "$review_file" 2>/dev/null || echo "Error reading review file"
            done
        fi
    else
        echo -e "${WARNING} No local review directory found"
    fi
    
    # GitHub APIから確認
    echo ""
    echo -e "${SEARCH} Checking GitHub for reviews..."
    
    # 自分宛のメンションを検索
    if command -v gh &> /dev/null; then
        local search_query="@claude-review [$ROLE-$NAME"
        echo -e "${BLUE}Search query: $search_query${NC}"
        
        gh search issues "$search_query" \
            --repo "$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')" \
            --limit 10 \
            --json number,title,createdAt,url,state | \
        jq -r '
            if length > 0 then
                .[] | 
                "\nIssue #\(.number): \(.title)",
                "State: \(.state)",
                "Created: \(.createdAt)",
                "URL: \(.url)"
            else
                "No reviews found on GitHub"
            end
        ' 2>/dev/null || echo -e "${WARNING} Unable to search GitHub (check gh auth status)"
    else
        echo -e "${WARNING} GitHub CLI not installed"
    fi
    
    # 未対応のアクションアイテムを確認
    echo ""
    echo -e "${ACTION} Pending Action Items:"
    if command -v gh &> /dev/null; then
        gh issue list --label "claude:$NAME" --label "action-required" \
            --json number,title,url | \
        jq -r '
            if length > 0 then
                .[] | "  • #\(.number): \(.title)"
            else
                "  ✓ No pending action items"
            end
        ' 2>/dev/null || echo -e "${WARNING} Unable to check GitHub issues"
    fi
}

# 特定のPRのレビューを取得
get_pr_reviews() {
    local pr_number="$1"
    
    if [ -z "$pr_number" ]; then
        echo -e "${ERROR} PR number required"
        echo "Usage: $0 pr <number>"
        return 1
    fi
    
    echo -e "${REVIEW} Getting reviews for PR #$pr_number"
    echo "================================="
    
    if ! command -v gh &> /dev/null; then
        echo -e "${ERROR} GitHub CLI required for this operation"
        return 1
    fi
    
    # PRコメントからレビューを抽出
    gh pr view $pr_number --comments --json comments,reviews | \
    jq -r '
        def extract_reviews(items):
            items[] | 
            select(.body | contains("@claude-review")) |
            select(.body | contains("['"$ROLE"'-'"$NAME"'")) |
            "---",
            "Author: \(.author.login)",
            "Date: \(.createdAt // .submittedAt)",
            "Type: \(if .state then "Review: \(.state)" else "Comment" end)",
            "",
            .body,
            "";
            
        (extract_reviews(.comments), extract_reviews(.reviews))
    ' 2>/dev/null || echo -e "${ERROR} Failed to fetch PR reviews"
}

# レビューに基づくアクション実行
apply_review_feedback() {
    local review_file="$1"
    
    if [ -z "$review_file" ] || [ ! -f "$review_file" ]; then
        echo -e "${ERROR} Review file not found: $review_file"
        echo "Usage: $0 apply <review-file>"
        return 1
    fi
    
    echo -e "${ACTION} Applying feedback from review..."
    echo "================================="
    
    # レビュー内容を読み込み
    local pr_number=$(jq -r '.pr_number' "$review_file")
    local review_type=$(jq -r '.review_type' "$review_file")
    local severity=$(jq -r '.severity' "$review_file")
    
    echo -e "PR: #$pr_number"
    echo -e "Type: $review_type"
    echo -e "Severity: $severity"
    echo ""
    
    # アクションアイテムを表示
    echo -e "${ACTION} Action items to address:"
    jq -r '.action_items[] | "  • \(.)"' "$review_file"
    echo ""
    
    # ブランチを作成
    local current_branch=$(git branch --show-current)
    local branch_name="review-feedback/$pr_number-$(date +%s)"
    
    read -p "Create new branch '$branch_name'? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout -b "$branch_name"
        echo -e "${CHECK} Created branch: $branch_name"
    fi
    
    # レビュー対応用のテンプレートを作成
    local response_file="review-response-$pr_number.md"
    cat > "$response_file" << EOF
# Review Response for PR #$pr_number

## Review Information
- **Review File**: $review_file
- **Claude Instance**: $INSTANCE_ID
- **Date**: $(date)

## Addressed Feedback

### Action Items
$(jq -r '.action_items[] | "- [ ] \(.)"' "$review_file")

### Problems Fixed
$(jq -r '.content.problems[]? | "- [ ] \(.)"' "$review_file" 2>/dev/null || echo "- [ ] ")

## Changes Made
<!-- Describe your changes here -->

1. 

## Testing
<!-- Describe how you tested the changes -->

- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] No regressions found

## Additional Notes
<!-- Any additional context or explanations -->

---
Generated by claude-review-check.sh
EOF
    
    echo -e "${CHECK} Created response template: $response_file"
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Edit $response_file to track your progress"
    echo "2. Make the necessary code changes"
    echo "3. Commit with: ./scripts/claude-identity.sh commit \"fix: address review feedback for PR #$pr_number\""
    echo "4. Create PR with: ./scripts/claude-identity.sh pr \"fix: review feedback\" \"Addresses feedback from PR #$pr_number\""
}

# GitHubから最新のレビューを同期
sync_reviews() {
    echo -e "${SEARCH} Syncing reviews from GitHub..."
    echo "=============================="
    
    if ! command -v gh &> /dev/null; then
        echo -e "${ERROR} GitHub CLI required for sync"
        return 1
    fi
    
    # レビューディレクトリを作成
    mkdir -p "$CLAUDE_DIR/reviews/$INSTANCE_ID"
    
    # GraphQL クエリで検索（より効率的）
    local repo_info=$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')
    local owner=$(echo "$repo_info" | cut -d'/' -f1)
    local repo=$(echo "$repo_info" | cut -d'/' -f2)
    
    # 最近のレビューを取得
    gh api graphql -f query='
    query($searchQuery: String!) {
      search(query: $searchQuery, type: ISSUE, first: 20) {
        nodes {
          ... on Issue {
            number
            title
            body
            createdAt
            author { login }
            url
            comments(first: 100) {
              nodes {
                body
                createdAt
                author { login }
              }
            }
          }
          ... on PullRequest {
            number
            title
            body
            createdAt
            author { login }
            url
            comments(first: 100) {
              nodes {
                body
                createdAt
                author { login }
              }
            }
          }
        }
      }
    }' -f searchQuery="repo:$owner/$repo @claude-review [$ROLE-$NAME" > "$CLAUDE_DIR/reviews/$INSTANCE_ID/sync-$(date +%s).json"
    
    echo -e "${CHECK} Sync completed"
    echo -e "${BLUE}Review files saved to: $CLAUDE_DIR/reviews/$INSTANCE_ID/${NC}"
}

# レビュー統計を表示
show_stats() {
    echo -e "${REVIEW} Review Statistics for $NAME ($ROLE)"
    echo "===================================="
    
    local review_dir="$CLAUDE_DIR/reviews/$INSTANCE_ID"
    if [ ! -d "$review_dir" ]; then
        echo -e "${WARNING} No reviews found"
        return
    fi
    
    # 統計を計算
    local total_reviews=$(find "$review_dir" -name "*.json" | wc -l)
    local pending_reviews=$(find "$review_dir" -name "*.json" -exec jq -r 'select(.status == "pending" or .status == null) | .review_id' {} \; 2>/dev/null | wc -l)
    local high_severity=$(find "$review_dir" -name "*.json" -exec jq -r 'select(.severity == "high") | .review_id' {} \; 2>/dev/null | wc -l)
    
    echo -e "Total Reviews: ${GREEN}$total_reviews${NC}"
    echo -e "Pending: ${YELLOW}$pending_reviews${NC}"
    echo -e "High Severity: ${RED}$high_severity${NC}"
    echo ""
    
    # レビュータイプ別
    echo "By Type:"
    find "$review_dir" -name "*.json" -exec jq -r '.review_type' {} \; 2>/dev/null | sort | uniq -c | while read count type; do
        echo -e "  $type: $count"
    done
    
    echo ""
    echo "By Reviewer:"
    find "$review_dir" -name "*.json" -exec jq -r '.reviewer' {} \; 2>/dev/null | sort | uniq -c | sort -rn | head -5 | while read count reviewer; do
        echo -e "  @$reviewer: $count reviews"
    done
}

# ヘルプメッセージ
show_help() {
    echo "Claude Code Review Feedback System"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  check [days]     Check reviews (default: last 7 days)"
    echo "  pr <number>      Get reviews for specific PR"
    echo "  apply <file>     Apply feedback from review file"
    echo "  sync             Sync reviews from GitHub"
    echo "  stats            Show review statistics"
    echo "  help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 check                  # Check reviews from last 7 days"
    echo "  $0 check 30               # Check reviews from last 30 days"
    echo "  $0 pr 123                 # Get reviews for PR #123"
    echo "  $0 apply review-123.json  # Apply feedback from review file"
    echo "  $0 sync                   # Sync latest reviews from GitHub"
}

# メイン処理
main() {
    # インスタンス情報をロード
    if ! load_instance_info; then
        exit 1
    fi
    
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
            sync_reviews
            ;;
        "stats")
            show_stats
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            echo -e "${ERROR} Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 実行
main "$@"