# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🤖 CRITICAL: Multi-Instance Coordination

**MANDATORY**: All Claude Code instances MUST coordinate to prevent conflicts when multiple instances work simultaneously.

### Pre-Work Coordination Check

**REQUIRED before any work**: Check for other active instances and potential conflicts:

```bash
# Always run this first
./scripts/claude-coordinator.sh check

# Expected output:
# 🔍 Checking for conflicts...
# 👥 Active Claude instances: 2
# 🔒 Active locks: src/components/Auth.tsx (by claude-1234abcd)
# ✅ Conflict check completed
```

### Instance Identification

Each Claude Code session gets a unique identifier:

```bash
# Auto-generated instance ID
CLAUDE_INSTANCE_ID=$(date +%s)-$(openssl rand -hex 4)

# Session tracking
echo "🤖 Claude Instance: $CLAUDE_INSTANCE_ID"
```

### Safe File Editing Protocol

**REQUIRED before editing any file**:

```bash
# 1. Check if file is locked
./scripts/claude-coordinator.sh lock src/components/Auth.tsx

# Success:
# 🔒 Lock acquired for: src/components/Auth.tsx (expires in 60 minutes)

# If locked by another instance:
# ❌ File is already locked: src/components/Auth.tsx
# Locked by: claude-5678efgh (expires in 45 minutes)
```

### Coordinated Development Workflow

#### 1. Session Initialization
```bash
# Initialize coordination system
./scripts/claude-coordinator.sh init

# Check current status
./scripts/claude-coordinator.sh status
```

#### 2. Task-Based Work Assignment
```bash
# View available tasks
./scripts/claude-coordinator.sh tasks

# Claim a specific task
./scripts/claude-coordinator.sh claim task-001

# Auto-creates branch: claude-1234abcd/task-001
```

#### 3. Safe File Operations
```bash
# Before editing any file
./scripts/claude-coordinator.sh lock src/components/Login.tsx

# Edit the file
# ... make changes ...

# Release lock when done
./scripts/claude-coordinator.sh unlock src/components/Login.tsx
```

#### 4. PR Creation with Coordination
```bash
# Always create draft PR initially
gh pr create --draft --title "Claude ${CLAUDE_INSTANCE_ID:0:8}: Implement feature X"

# Include instance info in PR body
--body "
🤖 Claude Instance: $CLAUDE_INSTANCE_ID
📋 Task: task-001
🌿 Branch: claude-1234abcd/task-001
"
```

#### 5. Task Completion
```bash
# Mark task as complete
./scripts/claude-coordinator.sh complete task-001

# Auto-releases all locks and updates task status
```

### Conflict Resolution

When conflicts occur:

```bash
# Check what's causing the conflict
./scripts/claude-coordinator.sh status

# Options:
# 1. Wait for lock to expire
# 2. Work on different files/tasks
# 3. Coordinate with other instance (via PR comments)
```

### Emergency Coordination

If coordination system fails:

```bash
# Clean all expired locks
./scripts/claude-coordinator.sh clean

# Force unlock (emergency only)
rm -f .claude/locks.yml

# Reset coordination state
rm -rf .claude/sessions/*
```

## 🚨 CRITICAL: GitHub Actions Cost Optimization

**MANDATORY**: All instances must follow draft PR workflow for cost optimization.

### Coordinated Draft PR Usage

```bash
# Each instance works in its own branch
BRANCH_NAME="claude-${CLAUDE_INSTANCE_ID:0:8}/${TASK_TYPE}/${TASK_NAME}"

# Always create draft PR
gh pr create --draft --title "Claude ${CLAUDE_INSTANCE_ID:0:8}: ${TASK_DESCRIPTION}"
```

### Multi-Instance Cost Impact

**Cost calculation with multiple instances**:
- Single instance draft PR: ~3 minutes per commit
- Multiple instances (coordinated): ~3 minutes each (parallel)
- Multiple instances (uncoordinated): ~20+ minutes each (conflicts)

**Example with 3 instances**:
- Coordinated: 3 × 3 min = 9 minutes total
- Uncoordinated: 3 × 20 min = 60 minutes total
- **Coordination saves 85% even with multiple instances**

## 📋 Claude Code Multi-Instance Checklist

Before any work, Claude Code must:

- [ ] Run coordination check: `./scripts/claude-coordinator.sh check`
- [ ] Verify instance ID is set: `echo $CLAUDE_INSTANCE_ID`
- [ ] Check for available tasks: `./scripts/claude-coordinator.sh tasks`
- [ ] Claim appropriate task: `./scripts/claude-coordinator.sh claim task-ID`
- [ ] Acquire file locks before editing: `./scripts/claude-coordinator.sh lock file.ts`
- [ ] Create draft PR with instance info
- [ ] Release locks when done: `./scripts/claude-coordinator.sh unlock file.ts`
- [ ] Complete task: `./scripts/claude-coordinator.sh complete`

### Coordination Benefits

1. **Zero Conflicts**: Automatic lock management prevents file conflicts
2. **Parallel Efficiency**: Multiple instances work simultaneously without interference
3. **Cost Optimization**: Draft PR workflow maintained across all instances
4. **Audit Trail**: Complete tracking of who did what when
5. **Emergency Recovery**: Robust error handling and recovery mechanisms

### Advanced Coordination

For complex scenarios:

```bash
# Coordinate with semantic locks (feature-level)
./scripts/claude-coordinator.sh lock --semantic "authentication-system"

# Request priority for urgent tasks
./scripts/claude-coordinator.sh claim task-urgent-001 --priority high

# Coordinate across multiple repositories
export CLAUDE_MULTI_REPO_MODE=true
```

## 🔄 Integration with Existing Optimization

The multi-instance system is fully compatible with existing optimizations:

- ✅ Draft PR workflow maintained
- ✅ Emergency shutdown works across all instances
- ✅ Cost monitoring includes all instances
- ✅ Compliance checking coordinated

**Failure to coordinate may result in:**
- Git merge conflicts
- Wasted CI/CD resources
- Increased GitHub Actions costs
- Development inefficiency

**Successful coordination ensures:**
- Seamless parallel development
- Maintained cost optimizations
- Zero conflicts between instances
- Maximized development velocity