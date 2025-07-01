#!/bin/bash

# Debug script to test lock mechanism
set -e

TEST_DIR="$(pwd)/debug-locks"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Initialize git and copy coordinator
git init
git config user.name "Test User"
git config user.email "test@example.com"

mkdir -p scripts .claude/{sessions,locks,tasks,logs}
cp ../scripts/claude-coordinator.sh scripts/
chmod +x scripts/claude-coordinator.sh

# Initialize
echo "locks: {}" > .claude/locks.yml
echo "tasks: []" > .claude/tasks.yml
touch .claude/audit.log

echo "=== Initial state ==="
echo "locks.yml content:"
cat .claude/locks.yml
echo ""

# Test Instance 1
export CLAUDE_INSTANCE_ID="test1-1234"
echo "=== Instance 1 acquiring lock ==="
./scripts/claude-coordinator.sh lock test-file.txt

echo "locks.yml after first lock:"
cat .claude/locks.yml
echo ""

# Test Instance 2
export CLAUDE_INSTANCE_ID="test2-5678"
echo "=== Instance 2 trying to acquire same lock ==="
if ./scripts/claude-coordinator.sh lock test-file.txt; then
    echo "❌ FAILED: Instance 2 was able to acquire lock"
    echo "Final locks.yml:"
    cat .claude/locks.yml
    exit 1
else
    echo "✅ SUCCESS: Instance 2 correctly denied lock"
fi

# Cleanup
cd ..
rm -rf "$TEST_DIR"