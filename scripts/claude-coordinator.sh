#!/bin/bash
# Claude Code Multi-Instance Coordinator
# Manages multiple Claude Code instances working on the same project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

# Instance identification
CLAUDE_INSTANCE_ID="${CLAUDE_INSTANCE_ID:-$(date +%s)-$(openssl rand -hex 4 2>/dev/null || echo "$(date +%s)-$$")}"
CLAUDE_SESSION_FILE="$CLAUDE_DIR/sessions/$CLAUDE_INSTANCE_ID.json"

# Files
LOCKS_FILE="$CLAUDE_DIR/locks.yml"
TASKS_FILE="$CLAUDE_DIR/tasks.yml"
AUDIT_FILE="$CLAUDE_DIR/audit.log"

# Initialize Claude directory structure
init_claude_dir() {
    mkdir -p "$CLAUDE_DIR"/{sessions,locks,tasks,logs,file_locks}
    
    # Create initial files if they don't exist
    [ ! -f "$LOCKS_FILE" ] && echo "locks: {}" > "$LOCKS_FILE"
    [ ! -f "$TASKS_FILE" ] && echo "tasks: []" > "$TASKS_FILE"
    [ ! -f "$AUDIT_FILE" ] && touch "$AUDIT_FILE"
}

# Log audit entry
audit_log() {
    local action="$1"
    local resource="$2"
    local details="$3"
    
    echo "$(date -Iseconds) | $CLAUDE_INSTANCE_ID | $action | $resource | $details" >> "$AUDIT_FILE"
}

# Check if file is locked using atomic lock files
is_file_locked() {
    local file_path="$1"
    local file_lockfile="${CLAUDE_DIR}/file_locks/$(echo "$file_path" | tr '/' '_').lock"
    
    # Check if atomic lock file exists
    if [ -f "$file_lockfile" ]; then
        return 0  # Locked
    else
        return 1  # Not locked
    fi
}

# Acquire file lock with atomic operation using individual lock files
acquire_lock() {
    local file_path="$1"
    local timeout_minutes="${2:-60}"
    local file_lockfile="${CLAUDE_DIR}/file_locks/$(echo "$file_path" | tr '/' '_').lock"
    local file_lockdir="${CLAUDE_DIR}/file_locks"
    
    # Create lock directory if it doesn't exist
    mkdir -p "$file_lockdir"
    
    # Try to create the lock file atomically (this is the critical atomic operation)
    if ! (set -C; echo "$CLAUDE_INSTANCE_ID" > "$file_lockfile") 2>/dev/null; then
        # Lock file already exists, check if it's expired
        if [ -f "$file_lockfile" ]; then
            local lock_owner=$(cat "$file_lockfile" 2>/dev/null || echo "unknown")
            echo "❌ File is already locked: $file_path (by $lock_owner)"
        else
            echo "❌ Failed to acquire lock for: $file_path"
        fi
        return 1
    fi
    
    # We successfully acquired the atomic lock, now record it
    local expires_at=$(date -d "+${timeout_minutes} minutes" -Iseconds)
    
    # Add lock entry to the main locks file
    cat >> "$LOCKS_FILE" << EOF
- path: "$file_path"
  locked_by: "$CLAUDE_INSTANCE_ID"
  locked_at: "$(date -Iseconds)"
  expires_at: "$expires_at"
EOF
    
    audit_log "LOCK_ACQUIRED" "$file_path" "timeout=${timeout_minutes}min"
    echo "🔒 Lock acquired for: $file_path (expires in ${timeout_minutes} minutes)"
    return 0
}

# Clean a single expired lock
clean_single_expired_lock() {
    local file_path="$1"
    
    if [ -f "$LOCKS_FILE" ]; then
        # Remove the lock entry and its associated lines
        sed -i "/^- path: \"$file_path\"$/,+3d" "$LOCKS_FILE"
        audit_log "LOCK_EXPIRED" "$file_path" "auto-cleaned"
    fi
}

# Release file lock
release_lock() {
    local file_path="$1"
    local file_lockfile="${CLAUDE_DIR}/file_locks/$(echo "$file_path" | tr '/' '_').lock"
    
    # Remove atomic lock file
    if [ -f "$file_lockfile" ]; then
        rm -f "$file_lockfile"
    fi
    
    # Remove lock entry from main locks file
    if [ -f "$LOCKS_FILE" ]; then
        # Remove the lock entry and its associated lines (4 lines total)
        sed -i "/^- path: \"$file_path\"$/,+3d" "$LOCKS_FILE"
    fi
    
    audit_log "LOCK_RELEASED" "$file_path" ""
    echo "🔓 Lock released for: $file_path"
}

# Clean expired locks
clean_expired_locks() {
    if [ ! -f "$LOCKS_FILE" ]; then
        return
    fi
    
    local current_time=$(date -Iseconds)
    local cleaned=false
    
    # In production, use proper YAML parser
    # For now, this is a simplified implementation
    echo "🧹 Cleaning expired locks..."
    
    # Create new locks file without expired entries
    echo "locks: []" > "${LOCKS_FILE}.new"
    
    # Note: This is simplified - proper implementation would parse YAML
    mv "${LOCKS_FILE}.new" "$LOCKS_FILE"
    
    if [ "$cleaned" = true ]; then
        audit_log "LOCKS_CLEANED" "expired" ""
        echo "✅ Expired locks cleaned"
    fi
}

# Get available tasks
get_available_tasks() {
    if [ ! -f "$TASKS_FILE" ]; then
        echo "No tasks available"
        return
    fi
    
    echo "📋 Available tasks:"
    # Simplified task listing
    grep -n "status: pending" "$TASKS_FILE" | head -5 || echo "No pending tasks"
}

# Claim a task
claim_task() {
    local task_id="$1"
    
    if [ -z "$task_id" ]; then
        echo "❌ Task ID required"
        return 1
    fi
    
    # Check if task exists and is available
    if ! grep -q "id: $task_id" "$TASKS_FILE" 2>/dev/null; then
        echo "❌ Task not found: $task_id"
        return 1
    fi
    
    if grep -A5 "id: $task_id" "$TASKS_FILE" | grep -q "status: in_progress"; then
        echo "❌ Task already in progress: $task_id"
        return 1
    fi
    
    # Update task status (simplified)
    sed -i "s/status: pending/status: in_progress/" "$TASKS_FILE"
    
    # Create work branch
    local branch_name="claude-${CLAUDE_INSTANCE_ID:0:8}/task-$task_id"
    git checkout -b "$branch_name" 2>/dev/null || git checkout "$branch_name"
    
    audit_log "TASK_CLAIMED" "$task_id" "branch=$branch_name"
    echo "✅ Task claimed: $task_id"
    echo "🌿 Working branch: $branch_name"
    
    # Store session info
    cat > "$CLAUDE_SESSION_FILE" << EOF
{
  "instance_id": "$CLAUDE_INSTANCE_ID",
  "current_task": "$task_id",
  "branch": "$branch_name",
  "started_at": "$(date -Iseconds)"
}
EOF
}

# Complete task
complete_task() {
    local task_id="$1"
    
    if [ ! -f "$CLAUDE_SESSION_FILE" ]; then
        echo "❌ No active session found"
        return 1
    fi
    
    # Release all locks held by this instance
    echo "🔓 Releasing all locks..."
    
    if [ -f "$LOCKS_FILE" ]; then
        # Find and release all locks held by this instance
        while IFS= read -r line; do
            if echo "$line" | grep -q "locked_by: \"$CLAUDE_INSTANCE_ID\""; then
                # Get the path from the previous line
                local locked_file=$(grep -B1 "locked_by: \"$CLAUDE_INSTANCE_ID\"" "$LOCKS_FILE" | grep "^- path:" | cut -d'"' -f2)
                if [ -n "$locked_file" ]; then
                    release_lock "$locked_file"
                fi
            fi
        done < "$LOCKS_FILE"
    fi
    
    # Create PR (draft)
    local current_branch=$(git branch --show-current)
    if command -v gh &> /dev/null; then
        gh pr create --draft --title "Claude Code: Complete task $task_id" --body "Automatically created by Claude instance $CLAUDE_INSTANCE_ID" || true
    fi
    
    # Update task status
    sed -i "s/status: in_progress/status: completed/" "$TASKS_FILE"
    
    audit_log "TASK_COMPLETED" "$task_id" "branch=$current_branch"
    echo "✅ Task completed: $task_id"
    
    # Clean up session
    rm -f "$CLAUDE_SESSION_FILE"
}

# Check for conflicts with other instances
check_conflicts() {
    echo "🔍 Checking for conflicts..."
    
    # Check active sessions
    local active_sessions=$(ls "$CLAUDE_DIR/sessions/"*.json 2>/dev/null | wc -l)
    echo "👥 Active Claude instances: $active_sessions"
    
    # Check locks
    if [ -f "$LOCKS_FILE" ] && [ -s "$LOCKS_FILE" ]; then
        echo "🔒 Active locks:"
        grep -E "(path|locked_by)" "$LOCKS_FILE" | head -10 || echo "None"
    fi
    
    # Clean expired locks
    clean_expired_locks
    
    echo "✅ Conflict check completed"
}

# Show status
show_status() {
    echo "🤖 Claude Instance: $CLAUDE_INSTANCE_ID"
    echo "📁 Project: $(basename "$PROJECT_ROOT")"
    echo ""
    
    if [ -f "$CLAUDE_SESSION_FILE" ]; then
        echo "📋 Current session:"
        cat "$CLAUDE_SESSION_FILE" | sed 's/^/  /'
    else
        echo "📋 No active session"
    fi
    
    echo ""
    check_conflicts
    echo ""
    get_available_tasks
}

# Main command handling
case "${1:-status}" in
    "init")
        init_claude_dir
        echo "✅ Claude coordinator initialized"
        ;;
    
    "status")
        show_status
        ;;
    
    "check")
        check_conflicts
        ;;
    
    "lock")
        if [ -z "$2" ]; then
            echo "Usage: $0 lock <file_path> [timeout_minutes]"
            exit 1
        fi
        acquire_lock "$2" "$3"
        ;;
    
    "unlock")
        if [ -z "$2" ]; then
            echo "Usage: $0 unlock <file_path>"
            exit 1
        fi
        release_lock "$2"
        ;;
    
    "tasks")
        get_available_tasks
        ;;
    
    "claim")
        if [ -z "$2" ]; then
            echo "Usage: $0 claim <task_id>"
            exit 1
        fi
        claim_task "$2"
        ;;
    
    "complete")
        complete_task "$2"
        ;;
    
    "clean")
        clean_expired_locks
        ;;
    
    *)
        echo "Claude Code Multi-Instance Coordinator"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  init                 Initialize coordinator"
        echo "  status               Show current status"
        echo "  check                Check for conflicts"
        echo "  lock <file> [mins]   Acquire file lock"
        echo "  unlock <file>        Release file lock"
        echo "  tasks                List available tasks"
        echo "  claim <task_id>      Claim a task"
        echo "  complete [task_id]   Complete current task"
        echo "  clean                Clean expired locks"
        echo ""
        echo "Environment:"
        echo "  CLAUDE_INSTANCE_ID   Unique instance identifier"
        ;;
esac