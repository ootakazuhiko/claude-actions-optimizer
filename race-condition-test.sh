#!/bin/bash

# Specific test for race condition debugging
set -e

TEST_DIR="$(pwd)/race-test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Setup
git init
git config user.name "Test User"
git config user.email "test@example.com"

mkdir -p scripts .claude/{sessions,locks,tasks,logs}
cp ../scripts/claude-coordinator.sh scripts/
chmod +x scripts/claude-coordinator.sh

echo "locks: {}" > .claude/locks.yml
echo "tasks: []" > .claude/tasks.yml
touch .claude/audit.log

echo "=== Testing concurrent lock acquisition ==="

# Start Instance 1 and 2 exactly at the same time
(
    export CLAUDE_INSTANCE_ID="concurrent1"
    echo "Instance 1 starting..."
    ./scripts/claude-coordinator.sh lock test-concurrent.txt
    echo "Instance 1 result: $?"
) &

(
    export CLAUDE_INSTANCE_ID="concurrent2"
    echo "Instance 2 starting..."
    ./scripts/claude-coordinator.sh lock test-concurrent.txt
    echo "Instance 2 result: $?"
) &

# Wait for both to complete
wait

echo ""
echo "=== Final locks file content ==="
cat .claude/locks.yml

echo ""
echo "=== Final audit log ==="
cat .claude/audit.log

# Count successful locks
lock_count=$(grep -c "LOCK_ACQUIRED.*test-concurrent.txt" .claude/audit.log || echo 0)
echo ""
echo "Total successful locks: $lock_count"

if [ "$lock_count" -gt 1 ]; then
    echo "❌ RACE CONDITION: Multiple locks acquired for same file"
    exit 1
else
    echo "✅ Race condition test passed"
fi

# Cleanup
cd ..
rm -rf "$TEST_DIR"