#!/bin/bash

# Debug race condition in locking mechanism
set -e

TEST_DIR="$(pwd)/debug-race"
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

# Instance 1 acquires lock
export CLAUDE_INSTANCE_ID="test1-1234"
echo "=== Instance 1 acquiring lock ==="
./scripts/claude-coordinator.sh lock test-file.txt

echo "Locks file after Instance 1:"
cat .claude/locks.yml
echo ""
echo "File exists check:"
ls -la .claude/locks.yml

# Instance 2 tries to acquire same lock - with debug info
export CLAUDE_INSTANCE_ID="test2-5678"
echo ""
echo "=== Instance 2 debug info ==="
echo "Locks file before Instance 2 attempt:"
cat .claude/locks.yml
echo ""
echo "Grep test (should find the lock):"
grep -q "^- path: \"test-file.txt\"$" .claude/locks.yml && echo "FOUND" || echo "NOT FOUND"

echo ""
echo "=== Instance 2 attempting lock ==="
if ./scripts/claude-coordinator.sh lock test-file.txt 2>&1; then
    echo "❌ Instance 2 succeeded (should have failed)"
    echo "Final locks file:"
    cat .claude/locks.yml
else
    echo "✅ Instance 2 correctly failed"
fi

# Cleanup
cd ..
rm -rf "$TEST_DIR"