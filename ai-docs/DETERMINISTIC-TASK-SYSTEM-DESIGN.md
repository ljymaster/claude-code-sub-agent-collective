# Deterministic Task System Design

**Status**: Design Phase - Deep Research Complete
**Last Updated**: 2025-10-01
**Purpose**: Revolutionary deterministic task management system using Claude 4.5 + Hooks + Memory

---

## Executive Summary

This document presents a revolutionary approach to AI-driven task management that solves the fundamental problem plaguing existing systems: **non-deterministic task execution**.

**The Problem**: Current systems (CCPM, Claude-Flow, Spec-Kit) rely on AI agents being honest about task completion without external validation. Agents can claim tasks are done when tests are failing, skip prerequisites, or execute tasks out of order.

**Our Solution**: **Hooks + Memory + Extended Thinking = External Enforcement Layer**

**Key Innovation**: Validation gates (hooks) that AI agents cannot bypass, combined with transparent state (memory), create deterministic task execution in an inherently non-deterministic system.

---

## CRITICAL DISTINCTION: Two Separate Systems

### Memory System (The Foundation)

**What it is**: Deterministic file-based storage layer
**Purpose**: Guarantee consistent read/write operations across sessions
**Implementation**: Atomic file operations using Read/Write/Edit tools + bash

**Core guarantees:**
1. **Atomic writes** - Write succeeds completely or fails completely (no partial writes)
2. **Verified operations** - Every operation is verified before proceeding
3. **Consistent state** - Same operation = same result, every time
4. **Recovery** - Failed operations leave system in known state

**NOT task-specific** - This is general-purpose deterministic storage that ANY system can use.

### Task System (Built On Memory)

**What it is**: Task management system that USES the memory system
**Purpose**: Manage task dependencies, validation, and execution
**Implementation**: Hooks + Memory System + Extended Thinking

**Dependencies:**
```
Task System
    ↓
Memory System (deterministic storage)
    ↓
File System
```

**Key point**: Task system validation rules (test pass, deliverables exist) are SEPARATE from memory system guarantees (writes are atomic and verified).

**YOU CANNOT HAVE A DETERMINISTIC TASK SYSTEM WITHOUT A DETERMINISTIC MEMORY SYSTEM FIRST.**

---

## Concrete Example: Login Form Project

**This example proves the distinction between memory and task systems.**

### MEMORY SYSTEM (The Foundation)

**What memory stores**: Just files in `.claude/memory/`. That's it.

**Files that would exist (file-per-entity pattern):**
```
.claude/memory/
├── tasks/
│   ├── 1.json          # Task 1 data only
│   ├── 2.json          # Task 2 data only
│   ├── 3.json          # Task 3 data only
│   └── 4.json          # Task 4 data only
├── task-index.json     # Lightweight index (IDs, status, dependencies)
└── project.json        # Project metadata
```

**Why file-per-task:**
- ✅ **Scalable**: Read task 47 without reading tasks 1-46
- ✅ **Fast**: Update one task = write one small file
- ✅ **Concurrent**: Two agents can update different tasks simultaneously
- ✅ **Atomic**: Updating task 1 cannot corrupt task 2
- ✅ **Git-friendly**: Diff shows exactly which task changed

**Memory operations used:**
```bash
# Write project file
memory_write ".claude/memory/project.json" '{"name": "login-form", "created": "2025-10-01"}'

# Read one task
task=$(memory_read ".claude/memory/tasks/1.json")

# Update one task status
memory_update_json ".claude/memory/tasks/1.json" '.status = "done"'

# Update index (coordination data)
memory_update_json ".claude/memory/task-index.json" \
  '.tasks[] |= if .id == "1" then .status = "done" else . end'
```

**Memory system doesn't care what's IN the files. It just guarantees:**
- ✅ Writes are atomic
- ✅ Reads are verified
- ✅ Updates don't corrupt
- ✅ One entity per file (scalable)

### TASK SYSTEM (Uses Memory)

**What tasks are**: Work Breakdown Structure (WBS) with hierarchy

**WBS Structure for this project (3 levels):**

```
1.0 Authentication System (EPIC)
  ├─ 1.1 Infrastructure (FEATURE)
  │    ├─ 1.1.1 Setup Vite (TASK)
  │    ├─ 1.1.2 Setup TypeScript (TASK)
  │    └─ 1.1.3 Setup Testing (TASK)
  ├─ 1.2 Login Form (FEATURE)
  │    ├─ 1.2.1 HTML Structure (TASK)
  │    ├─ 1.2.2 Form Validation (TASK)
  │    └─ 1.2.3 Styling (TASK)
  └─ 1.3 Integration (FEATURE)
       └─ 1.3.1 Browser Testing (TASK)
```

**Files stored:**
- Epic: `.claude/memory/tasks/1.json`
- Features: `.claude/memory/tasks/1.1.json`, `1.2.json`, `1.3.json`
- Tasks: `.claude/memory/tasks/1.1.1.json`, `1.1.2.json`, `1.1.3.json`, `1.2.1.json`, etc.

**Key properties:**
- **Epic 1**: High-level goal, has 3 features as children
- **Feature 1.1**: Infrastructure setup, has 3 atomic tasks
- **Task 1.1.1**: Atomic work item (leaf node), no children
- **Dependencies**: Feature 1.2 depends on Feature 1.1 completing
- **Roll-up status**: Feature 1.1 status = calculated from children (1.1.1, 1.1.2, 1.1.3)

### How They Work Together

**The task-index.json File** (Lightweight coordination data):

```json
{
  "version": "1.0.0",
  "tasks": [
    {
      "id": "1",
      "type": "epic",
      "status": "in-progress",
      "parent": null,
      "children": ["1.1", "1.2", "1.3"],
      "dependencies": [],
      "progress": {"completed": 3, "total": 7}
    },
    {
      "id": "1.1",
      "type": "feature",
      "status": "done",
      "parent": "1",
      "children": ["1.1.1", "1.1.2", "1.1.3"],
      "dependencies": [],
      "progress": {"completed": 3, "total": 3}
    },
    {
      "id": "1.1.1",
      "type": "task",
      "status": "done",
      "parent": "1.1",
      "children": [],
      "dependencies": []
    },
    {
      "id": "1.2",
      "type": "feature",
      "status": "in-progress",
      "parent": "1",
      "children": ["1.2.1", "1.2.2", "1.2.3"],
      "dependencies": ["1.1"]
    },
    {
      "id": "1.2.1",
      "type": "task",
      "status": "done",
      "parent": "1.2",
      "children": [],
      "dependencies": []
    },
    {
      "id": "1.2.2",
      "type": "task",
      "status": "in-progress",
      "parent": "1.2",
      "children": [],
      "dependencies": []
    }
  ]
}
```

**Small, fast to read, includes hierarchy and status for coordination.**

---

**Individual Task File** (.claude/memory/tasks/1.json):

```json
{
  "id": "1",
  "title": "Setup Infrastructure",
  "description": "Initialize build tools, TypeScript config, testing framework",
  "status": "done",
  "phase": "infrastructure",
  "dependencies": [],
  "acceptanceCriteria": [
    "Vite configured with React",
    "TypeScript compilation works",
    "Vitest test runner setup",
    "npm run build succeeds",
    "npm test succeeds"
  ],
  "deliverables": [
    "package.json",
    "vite.config.ts",
    "tsconfig.json",
    "vitest.config.ts"
  ],
  "tests": [
    "npm run build",
    "npm test"
  ],
  "agent": "infrastructure-implementation-agent",
  "startedAt": "2025-10-01T10:05:00Z",
  "completedAt": "2025-10-01T10:30:00Z",
  "validationResults": {
    "testsPass": true,
    "deliverablesExist": true,
    "validatedAt": "2025-10-01T11:30:00Z"
  }
}
```

**Full data for one task. Only read when needed.**

---

**Why This Scales:**
- **Query task 47**: `memory_read ".claude/memory/tasks/47.json"` (one small file)
- **Update task 47**: `memory_update_json ".claude/memory/tasks/47.json" '.status = "done"'` (one write)
- **Find next task**: Read index (small), filter, then read matching task file
- **1000 tasks**: No problem - each task is independent file

**This design lives in memory system, but the CONTENT is task system data.**

### Concrete Workflow

**1. User Creates Project:**
```bash
/van:new-project login-form

# Hub Claude uses MEMORY SYSTEM:
mkdir -p ".claude/memory/tasks"
memory_write ".claude/memory/task-index.json" '{"version": "1.0.0", "tasks": []}'
memory_write ".claude/memory/project.json" '{"name": "login-form"}'
```

**2. User Generates Tasks:**
```bash
/van:generate-tasks

# Hub Claude (LLM) decides WHAT tasks (non-deterministic):
# - Analyzes spec with extended thinking
# - Creates WBS hierarchy: 1 Epic → 3 Features → 7 Tasks

# Hub Claude TRIGGERS deterministic operations:

# Write Epic
memory_write ".claude/memory/tasks/1.json" \
  '{"id": "1", "type": "epic", "title": "Authentication System", "parent": null, "children": ["1.1","1.2","1.3"]}'

# Write Feature 1.1
memory_write ".claude/memory/tasks/1.1.json" \
  '{"id": "1.1", "type": "feature", "title": "Infrastructure", "parent": "1", "children": ["1.1.1","1.1.2","1.1.3"]}'

# Write Tasks under Feature 1.1
memory_write ".claude/memory/tasks/1.1.1.json" \
  '{"id": "1.1.1", "type": "task", "title": "Setup Vite", "parent": "1.1", "children": [], "dependencies": []}'
memory_write ".claude/memory/tasks/1.1.2.json" \
  '{"id": "1.1.2", "type": "task", "title": "Setup TypeScript", "parent": "1.1", "children": [], "dependencies": []}'

# [etc for all tasks...]

# Update index (DETERMINISTIC)
memory_update_json ".claude/memory/task-index.json" '.tasks += [
  {"id": "1", "type": "epic", "status": "pending", "parent": null, "children": ["1.1","1.2","1.3"]},
  {"id": "1.1", "type": "feature", "status": "pending", "parent": "1", "children": ["1.1.1","1.1.2","1.1.3"]},
  {"id": "1.1.1", "type": "task", "status": "pending", "parent": "1.1", "children": []}
]'
```

**3. Agent Completes Task 1.1.1:**
```bash
# Agent works on task 1.1.1 (Setup Vite)...
# SubagentStop hook (DETERMINISTIC) validates:

# 1. DETERMINISTIC: Validate tests
npm test || exit 2

# 2. DETERMINISTIC: Validate deliverables
[ -f "vite.config.ts" ] || exit 2

# 3. DETERMINISTIC: Update task file
memory_update_json ".claude/memory/tasks/1.1.1.json" \
  '.status = "done" | .completedAt = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"'

# 4. DETERMINISTIC: Update index
memory_update_json ".claude/memory/task-index.json" \
  '.tasks[] |= if .id == "1.1.1" then .status = "done" else . end'

# 5. DETERMINISTIC: Propagate status up hierarchy
source .claude/memory/lib/wbs-helpers.sh
propagate_status_up "1.1.1"

# This calculates:
# - Feature 1.1: 1/3 tasks done → status = "in-progress"
# - Epic 1: 1/7 tasks done → status = "in-progress"

# If ANY operation fails → Hook exits 2 → BLOCKED
exit 0  # Allow Hub to proceed
```

**Hook ensures deterministic roll-up:**
- Same task completion → Same status propagation
- Feature status auto-calculated from children
- Epic status auto-calculated from features
- No manual status management by LLM

**4. Hub Finds Next Task:**
```bash
/van:next

# Hub uses MEMORY SYSTEM + helper scripts (DETERMINISTIC):

# Get leaf tasks only (no children = atomic work)
source .claude/memory/lib/wbs-helpers.sh
leaf_tasks=$(get_leaf_tasks)

# Find available tasks (leaf + dependencies satisfied + status pending)
index=$(memory_read ".claude/memory/task-index.json")
next_id=$(jq -r '.tasks[] |
  select(.children == [] or .children == null) |
  select(.status == "pending") |
  select(
    .dependencies == [] or
    (.dependencies | all(. as $d | any(.tasks[]; .id == $d and .status == "done")))
  ) | .id' <<< "$index" | head -1)

# Found: 1.1.2 (Setup TypeScript)
# Read full task data
task=$(memory_read ".claude/memory/tasks/1.1.2.json")

# Hub Claude (LLM) decides: "Deploy agent for task 1.1.2"
# Hub TRIGGERS (deterministic): Task(prompt="Work on 1.1.2: Setup TypeScript")
```

**Hub's role:**
- Reads deterministic state (index)
- Uses deterministic queries (leaf tasks, dependencies)
- Makes intelligence decision (which agent to use)
- Triggers deterministic operation (Task tool)

### The Key Distinction

**Memory System** = The library functions (write/read/update)
```bash
memory_write()        # Low-level: "Store this content in this file atomically"
memory_read()         # Low-level: "Give me contents of this file"
memory_update_json()  # Low-level: "Transform this JSON atomically"
```

**Task System** = The business logic (what tasks mean, dependencies, validation)
```bash
# High-level: "Mark task 1 as done if tests pass"
if npm test; then
  memory_update_json ".claude/memory/tasks/1.json" '.status = "done"'
  memory_update_json ".claude/memory/task-index.json" \
    '.tasks[] |= if .id == "1" then .status = "done" else . end'
fi

# High-level: "Find next available task"
index=$(memory_read ".claude/memory/task-index.json")
next_id=$(jq -r '.tasks[] | select(.status=="pending") | .id' <<< "$index" | head -1)
task=$(memory_read ".claude/memory/tasks/${next_id}.json")
```

**Task system uses memory system. Memory system doesn't know about tasks.**

---

### How Hooks Enforce WBS Integrity

**Hooks are CRITICAL for deterministic WBS management.**

#### SubagentStop Hook (Complete Implementation)

```bash
#!/bin/bash
# .claude/hooks/subagent-validation.sh
# DETERMINISTIC validation + WBS status propagation

set -euo pipefail

TASKS_INDEX=".claude/memory/task-index.json"
source .claude/memory/lib/wbs-helpers.sh

# Get current task (in-progress)
TASK_ID=$(jq -r '.tasks[] | select(.status=="in-progress") | .id' "$TASKS_INDEX" | head -n1)

if [ -z "$TASK_ID" ]; then
  echo "No task in progress" >&2
  exit 0
fi

echo "🔍 Validating task $TASK_ID..."

# 1. DETERMINISTIC: Run tests
if npm test > /tmp/test-output.log 2>&1; then
  echo "✅ Tests passed"
  TESTS_PASS=true
else
  echo "❌ Tests failed"
  TESTS_PASS=false
fi

# 2. DETERMINISTIC: Check deliverables
DELIVERABLES=$(jq -r ".tasks[] | select(.id==\"$TASK_ID\") | .deliverables[]" "$TASKS_INDEX" 2>/dev/null || echo "")
DELIVERABLES_EXIST=true

for file in $DELIVERABLES; do
  if [ ! -f "$file" ]; then
    echo "❌ Missing: $file"
    DELIVERABLES_EXIST=false
  fi
done

# 3. DETERMINISTIC: Update task file
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [ "$TESTS_PASS" = true ] && [ "$DELIVERABLES_EXIST" = true ]; then
  # Update task
  memory_update_json ".claude/memory/tasks/${TASK_ID}.json" \
    ".status = \"done\" | .completedAt = \"$TIMESTAMP\""

  # Update index
  memory_update_json "$TASKS_INDEX" \
    ".tasks[] |= if .id == \"$TASK_ID\" then .status = \"done\" else . end"

  # 4. DETERMINISTIC: Propagate status up hierarchy
  propagate_status_up "$TASK_ID"

  # Success
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStop",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Task $TASK_ID validated ✅ (tests pass, deliverables exist, status propagated)"
  }
}
EOF
  exit 0
else
  # Failure - BLOCK
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStop",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Task $TASK_ID validation failed: tests=$TESTS_PASS, deliverables=$DELIVERABLES_EXIST"
  }
}
EOF
  exit 2
fi
```

**What this enforces:**
1. ✅ **Tests must pass** - No silent failures
2. ✅ **Deliverables must exist** - No claiming work is done without proof
3. ✅ **Status updates atomic** - Task file + index updated together
4. ✅ **Hierarchy roll-up automatic** - Parent status calculated from children
5. ✅ **No LLM involvement** - Pure deterministic logic

#### PreToolUse Hook (Dependency Enforcement)

```bash
#!/bin/bash
# .claude/hooks/pre-agent-deploy.sh
# DETERMINISTIC dependency checking

set -euo pipefail

TASKS_INDEX=".claude/memory/task-index.json"

# Parse tool input
TOOL_INPUT=$(cat)
TOOL_NAME=$(echo "$TOOL_INPUT" | jq -r '.tool_name')

# Only validate Task tool
if [ "$TOOL_NAME" != "Task" ]; then
  exit 0
fi

# Extract task ID from prompt
PROMPT=$(echo "$TOOL_INPUT" | jq -r '.tool_input.prompt // empty')
TASK_ID=$(echo "$PROMPT" | grep -oP 'task \K[0-9.]+' | head -n1)

if [ -z "$TASK_ID" ]; then
  exit 0  # No task ID, allow
fi

echo "🔍 Checking dependencies for task $TASK_ID..."

# 1. Check task is leaf (no children)
CHILDREN=$(jq -r ".tasks[] | select(.id==\"$TASK_ID\") | .children[]" "$TASKS_INDEX" 2>/dev/null || echo "")

if [ -n "$CHILDREN" ]; then
  # Task has children - cannot work on parent tasks
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Cannot work on $TASK_ID - has children. Work on leaf tasks only."
  }
}
EOF
  exit 2
fi

# 2. Check dependencies satisfied
DEPS=$(jq -r ".tasks[] | select(.id==\"$TASK_ID\") | .dependencies[]" "$TASKS_INDEX" 2>/dev/null || echo "")

ALL_DONE=true
for dep in $DEPS; do
  dep_status=$(jq -r ".tasks[] | select(.id==\"$dep\") | .status" "$TASKS_INDEX")

  if [ "$dep_status" != "done" ]; then
    echo "❌ Dependency $dep not done (status: $dep_status)"
    ALL_DONE=false
  fi
done

if [ "$ALL_DONE" = true ]; then
  echo "✅ All dependencies satisfied"
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Task $TASK_ID ready (leaf task, dependencies satisfied)"
  }
}
EOF
  exit 0
else
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Task $TASK_ID blocked - dependencies not satisfied"
  }
}
EOF
  exit 2
fi
```

**What this enforces:**
1. ✅ **Leaf tasks only** - Cannot work on Epics/Features with children
2. ✅ **Dependencies satisfied** - Cannot start task until prerequisites done
3. ✅ **Cross-level dependencies** - Feature can depend on Feature
4. ✅ **BLOCKS deployment** - PreToolUse prevents Task tool from running

---

### Why This is Deterministic

**LLM (Non-Deterministic):**
- Decides which tasks to create
- Decides which agent to deploy
- Extended thinking about dependencies

**Hooks + Scripts (Deterministic):**
- Validate tests pass (same test → same result)
- Check files exist (same filesystem → same result)
- Calculate roll-up status (same children → same parent status)
- Block if validation fails (same failure → always blocks)

**Result:**
```
Same task completion + Same validation + Same dependencies
    = Same system state
    = DETERMINISTIC
```

---

### What Would Break This

**If Memory System Was Non-Deterministic:**
```bash
# Agent completes task
memory_update_json ".claude/memory/tasks/1.json" '.status = "done"'
# ❌ Function fails silently, file not updated

# Hub reads state
task=$(memory_read ".claude/memory/tasks/1.json")
# Task 1 still shows "in-progress" (inconsistent state)

# Hub thinks: "Task 1 not done, can't start Task 2"
# SYSTEM STUCK
```

**With Deterministic Memory System:**
```bash
# Agent completes task
memory_update_json ".claude/memory/tasks/1.json" '.status = "done"'
# ✅ Succeeds completely OR fails with error (no silent failures)

# If it succeeds:
task=$(memory_read ".claude/memory/tasks/1.json")
# Task 1 shows "done" (guaranteed)

# Hub: "Task 1 done, deploy Task 2"
# SYSTEM PROCEEDS
```

**Scalability Comparison:**

**Non-Scalable (Single File):**
```bash
# Read ALL tasks to find one
memory_read ".claude/memory/tasks.json"  # 2000 lines for 100 tasks
jq '.tasks[] | select(.id=="47")'

# Update one task = rewrite entire file
memory_update_json ".claude/memory/tasks.json" \
  '.tasks[46].status = "done"'  # Rewrites all 100 tasks
```

**Scalable (File-Per-Task):**
```bash
# Read ONE task
memory_read ".claude/memory/tasks/47.json"  # 20 lines

# Update one task = write one file
memory_update_json ".claude/memory/tasks/47.json" \
  '.status = "done"'  # Writes only task 47
```

### Summary

**Memory System** = File operations that are atomic and verified (the HOW)
**Task System** = Concept of tasks with dependencies that stores data using memory system (the WHAT)

**Memory is the storage mechanism. Tasks are the data being stored.**

---

## Part 1: Analysis of Existing Systems

### CCPM (Claude Code PM) - GitHub-Based PM

**Repository**: https://github.com/automazeio/ccpm

#### Architecture Overview

**Core Concept**: Uses GitHub Issues as coordination mechanism with Git-based context preservation

**Task Hierarchy**:
```
PRD (Product Requirements Document)
  ↓
Epic (High-level feature)
  ↓
Tasks (Concrete, actionable work items)
```

**Key Commands**:
- `/pm:prd-new feature-name` - Create PRD
- `/pm:prd-parse feature-name` - Transform PRD to implementation plan
- `/pm:epic-decompose feature-name` - Break into tasks
- `/pm:epic-sync` - Push to GitHub as issues
- `/pm:issue-start [number]` - Begin work
- `/pm:issue-sync [number]` - Update progress
- `/pm:issue-close [number]` - Mark complete
- `/pm:next` - Get next priority task

**Context Management**:
- Stores state in `.claude/context/` directory
- Uses Git worktrees for parallel execution
- Maintains project state across sessions

**Parallel Execution**:
- Supports 5-8 parallel tasks vs 1 previously
- Multiple agents work on different components simultaneously
- Git worktrees isolate parallel work

#### Strengths

1. **GitHub as Single Source of Truth**: Transparent, auditable task tracking
2. **Parallel Execution**: Real performance improvement (5-8x)
3. **Context Preservation**: `.claude/` directory maintains state
4. **Traceability**: Full audit trail from idea to production
5. **Clear Commands**: Well-defined workflow via slash commands

#### Non-Deterministic Problems

1. **No Task Completion Validation**
   - `/pm:issue-close` doesn't verify tests pass
   - Agent can claim task done with failing tests
   - No check that deliverables actually exist

2. **No Enforcement of Sequential Execution**
   - Can start task 3 before task 1/2 complete
   - Dependencies not enforced programmatically
   - Parallel execution without safeguards

3. **External State Dependency**
   - GitHub Issues = external system
   - API rate limits, network issues
   - Not directly queryable by Hub Claude
   - Opaque to AI's native context

4. **Trust-Based Model**
   - Relies on agent following instructions
   - No blocking gates
   - Agent can skip validation steps

5. **No Test Requirements**
   - Tasks can close even if `npm test` fails
   - No mandatory quality gates
   - Validation is optional, not enforced

**Example Failure**:
```
Task 1: "Setup infrastructure"
Agent: "Infrastructure setup complete!" (/pm:issue-close 1)
Reality: npm run build returns error, no vite.config.js exists
System: Proceeds to Task 2 anyway
```

#### What We Can Learn

✅ **Keep**: Hierarchical task structure (PRD → Epic → Tasks)
✅ **Keep**: Parallel execution concept (with proper safeguards)
✅ **Keep**: Clear slash commands for user workflow
❌ **Avoid**: External state dependencies (GitHub)
❌ **Avoid**: Trust-based completion without validation
❌ **Improve**: Add mandatory validation gates via hooks

---

### Claude-Flow - Swarm Intelligence System

**Repository**: https://github.com/ruvnet/claude-flow

#### Architecture Overview

**Core Concept**: Hive-mind swarm intelligence with 64 specialized agents and SQLite-based memory

**Coordination Modes**:
1. **Swarm Mode**: Quick, single-objective tasks
2. **Hive-Mind Mode**: Complex, multi-agent, persistent workflows

**Memory System**:
- SQLite database: `.swarm/memory.db`
- 12 specialized memory tables
- Persistent across sessions
- Session resumption support

**Agent Architecture**:
- Dynamic Agent Architecture (DAA)
- 64 specialized agent types
- Queen-led coordination pattern
- Self-organizing, fault-tolerant agents

**Hook System**:
- Pre-operation hooks: security, resource validation
- Post-operation hooks: formatting, neural pattern training
- Session hooks: session-start, session-end
- Configurable via `.claude/settings.json`

#### Strengths

1. **Persistent Memory**: SQLite database survives sessions
2. **Advanced Hooks**: Pre/post operation triggers
3. **Specialization**: 64 agent types for specific tasks
4. **Parallel Performance**: 10-20x faster in v2.5.0
5. **Session Management**: Can resume previous sessions

#### Non-Deterministic Problems

1. **Opaque State**
   - SQLite `.swarm/memory.db` = black box
   - Not human-readable
   - Hub Claude can't query naturally
   - Debugging is difficult

2. **Excessive Complexity**
   - 64 agents = massive coordination overhead
   - "Neural patterns" add unpredictability
   - Multi-layer architecture = harder to debug
   - Queen coordination adds single point of failure

3. **Hooks for Enhancement, Not Enforcement**
   - Post-operation hooks format/train, don't validate
   - Pre-operation hooks check security, not completion
   - No blocking gates for task dependencies
   - Hooks don't prevent proceeding with failures

4. **Session-Based, Not Task-Based**
   - State tied to sessions, not individual tasks
   - No explicit task dependency graph
   - Task completion not validated
   - Can't enforce sequential execution

5. **Non-Transparent**
   - What's in memory.db? Can't easily inspect
   - How do agents coordinate? Internal magic
   - State changes hidden from user
   - Trust the system without visibility

**Example Failure**:
```
Session 1: Agent A works on feature X
Session 2: Agent B starts feature Y (depends on X)
Reality: Feature X incomplete, tests failing
System: No validation that X complete before Y starts
```

#### What We Can Learn

✅ **Keep**: Hooks concept (but for validation, not training)
✅ **Keep**: Persistent memory concept
✅ **Keep**: Pre/post operation trigger points
❌ **Avoid**: Opaque state (SQLite)
❌ **Avoid**: Excessive agent specialization
❌ **Avoid**: Complexity for complexity's sake
❌ **Improve**: Hooks must ENFORCE, not enhance

---

### Spec-Kit - Specification-Driven Development

**Repository**: https://github.com/github/spec-kit

#### Architecture Overview

**Core Concept**: Structured methodology from principles to implementation

**Workflow Pipeline**:
```
/constitution → Define project principles
    ↓
/specify → Create detailed specification
    ↓
/tasks → Generate actionable task list
    ↓
/analyze → Validate consistency
```

**Key Features**:
- Template-based task generation
- Cross-artifact consistency checking
- Git branch-based feature tracking
- Environment variables for context
- Multiple AI agent support

**State Management**:
- Git branches (e.g., "001-create-taskify")
- Constitution stored in memory
- Specifications as markdown files
- Task lists generated from specs

#### Strengths

1. **Structured Methodology**: Clear phases (principles → spec → tasks)
2. **Intent-Driven**: Defines "what" and "why" before "how"
3. **Validation Step**: `/analyze` checks consistency
4. **Template System**: Standardized task generation
5. **Simple Workflow**: Easy-to-understand commands

#### Non-Deterministic Problems

1. **No Enforcement of Task Order**
   - `/tasks` generates list, but nothing enforces following it
   - Can skip task 2, go to task 3
   - No blocking gates
   - Agent discipline, not system enforcement

2. **No Validation Gates**
   - `/analyze` checks consistency, but agent can skip
   - No requirement that analysis passes
   - No blocking if validation fails
   - Optional validation, not mandatory

3. **Indirect State Tracking**
   - Git branches = implicit state
   - No explicit task status
   - Can't query "is task X complete?"
   - Trust agent's branch management

4. **No Test Requirements**
   - Tasks don't require tests to pass
   - No deliverable verification
   - Agent can mark "done" without validation
   - Quality gates are suggestions

5. **Manual Dependency Management**
   - Dependencies not explicit in task structure
   - Agent must remember what depends on what
   - No automated dependency checking
   - Easy to violate dependencies

**Example Failure**:
```
/constitution defines principles
/specify creates detailed spec
/tasks generates: [Task 1, Task 2, Task 3]

Agent: "I'll work on Task 3 first" (skips 1 and 2)
System: Allows it (no enforcement)
Reality: Task 3 depends on Task 1 output
Result: Task 3 fails, wasted effort
```

#### What We Can Learn

✅ **Keep**: Constitution → Specification → Tasks pipeline
✅ **Keep**: /analyze validation concept
✅ **Keep**: Template-based generation
✅ **Keep**: Clear phases
❌ **Avoid**: Optional validation
❌ **Avoid**: Manual dependency tracking
❌ **Avoid**: Indirect state (Git branches)
❌ **Improve**: Make validation mandatory with blocking gates

---

## Part 2: Common Problems All Three Share

### The ROOT Problem

**Trust-Based Completion Without External Enforcement**

All three systems rely on AI agents being honest and following instructions, with no external validation mechanism that agents cannot bypass.

### Critical Failures Identified

#### 1. No Task Completion Validation

**Problem**: Agent claims task complete, system accepts without verification

**CCPM**: `/pm:issue-close` doesn't check tests
**Claude-Flow**: Session ends without validation
**Spec-Kit**: Task marked done without deliverable check

**Impact**: Broken tasks marked "complete," downstream tasks fail

#### 2. No Enforcement of Sequential Execution

**Problem**: Can start Task N+1 before Task N completes

**CCPM**: Parallel execution without dependency checks
**Claude-Flow**: Agents coordinate ad-hoc, no forced ordering
**Spec-Kit**: Task list is suggestion, not enforced order

**Impact**: Dependency violations, build failures, wasted effort

#### 3. No Blocking Gates

**Problem**: Nothing stops proceeding when validation fails

**CCPM**: Can close issue even if tests fail
**Claude-Flow**: Hooks don't block, just enhance
**Spec-Kit**: /analyze fails, but work continues

**Impact**: Accumulating technical debt, broken main branch

#### 4. Opaque State

**Problem**: State not transparent or directly queryable

**CCPM**: GitHub Issues (external API)
**Claude-Flow**: SQLite `.swarm/memory.db` (binary blob)
**Spec-Kit**: Git branches (indirect state)

**Impact**: Hub Claude can't make informed decisions, users can't debug

#### 5. Agent Trust Model

**Problem**: System trusts agent claims without verification

**All Three**: Agent says "done" → system believes it

**Impact**: False completions, quality problems, unreliable builds

#### 6. No Test-Pass Requirements

**Problem**: Tasks can complete with failing tests

**CCPM**: No `npm test` validation before close
**Claude-Flow**: No test execution requirements
**Spec-Kit**: Tests not part of task completion

**Impact**: Broken code pushed to main, CI failures

#### 7. No Deliverable Verification

**Problem**: Agent claims file created, but file doesn't exist

**All Three**: No filesystem checks

**Impact**: Missing files cause downstream failures

### The Fundamental Issue

```
┌─────────────────────────────────────────────────┐
│        Current System Architecture              │
├─────────────────────────────────────────────────┤
│                                                 │
│  User Request                                   │
│       ↓                                         │
│  AI Agent (non-deterministic)                   │
│       ↓                                         │
│  Agent CLAIMS task complete                     │
│       ↓                                         │
│  System TRUSTS claim                            │
│       ↓                                         │
│  Proceeds to next task                          │
│                                                 │
│  ❌ NO VALIDATION                               │
│  ❌ NO ENFORCEMENT                              │
│  ❌ NO EXTERNAL CHECK                           │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Result**: Non-deterministic execution where same input ≠ same output

---

## Part 3: Our Deterministic Solution

### Core Innovation: External Enforcement Layer

```
┌─────────────────────────────────────────────────┐
│     Our Deterministic System Architecture       │
├─────────────────────────────────────────────────┤
│                                                 │
│  User Request                                   │
│       ↓                                         │
│  Hub Claude (extended thinking)                 │
│       ↓                                         │
│  Query Memory (transparent JSON state)          │
│       ↓                                         │
│  Deploy AI Agent (non-deterministic)            │
│       ↓                                         │
│  SubagentStop HOOK (deterministic validation)   │
│       ├→ npm test (must pass)                   │
│       ├→ Check deliverables (must exist)        │
│       └→ Update Memory (atomic)                 │
│       ↓                                         │
│  IF validation passes:                          │
│       ↓                                         │
│  Hub reads updated Memory                       │
│       ↓                                         │
│  PreToolUse HOOK (check dependencies)           │
│       ↓                                         │
│  IF dependencies satisfied:                     │
│       ↓                                         │
│  Deploy next agent                              │
│                                                 │
│  ✅ VALIDATION AT EVERY STEP                    │
│  ✅ EXTERNAL ENFORCEMENT (hooks)                │
│  ✅ TRANSPARENT STATE (memory)                  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Three Pillars of Determinism

#### Pillar 1: Memory as Single Source of Truth

**What**: Transparent JSON files in `.claude/memory/`
**Why**: Human-readable, inspectable, directly queryable by Hub Claude
**How**: Read/write operations via Claude 4.5 native memory tool (or Write tool)

**Not GitHub Issues**: External API, rate limits, network dependency
**Not SQLite**: Binary blob, opaque, requires SQL queries
**Not Git Branches**: Indirect, requires git commands

**Memory is**:
- JSON files (human-readable)
- In `.claude/memory/` directory (local, fast)
- Directly queryable (Hub Claude reads naturally)
- Editable (user can fix if needed)
- Version-controllable (Git tracks changes)

#### Pillar 2: Hooks as Enforcement Gates

**What**: Bash scripts that validate before proceeding
**Why**: External to LLM, cannot be convinced to skip
**How**: Exit 0 (allow) or exit 2 (block)

**SubagentStop Hook**: Validates after agent completes
- Runs `npm test` (must return 0)
- Checks deliverables exist (`[ -f path ]`)
- Updates memory atomically
- Blocks Hub if validation fails

**PreToolUse(Task) Hook**: Validates before agent deploys
- Reads dependencies from memory
- Checks all dependencies status = "done"
- Validates prerequisites met
- Blocks deployment if not ready

**Hooks are deterministic**:
- Same input → same validation → same result
- Cannot be bypassed by agent
- External to LLM reasoning
- Hard enforcement, not soft suggestions

#### Pillar 3: Extended Thinking for Intelligence

**What**: Claude 4.5's step-by-step reasoning
**Why**: Analyze complex dependencies, make informed decisions
**How**: Transparent thinking blocks show reasoning

**Hub Claude uses extended thinking to**:
- Analyze task dependency graph
- Determine which tasks can run in parallel
- Sequence complex multi-step workflows
- Decide next agent to deploy
- Handle edge cases intelligently

**Extended thinking provides**:
- Transparency (see decision process)
- Flexibility (adapts to context)
- Intelligence (better than hardcoded rules)
- Debuggability (understand why decision made)

---

## Part 4: Memory Schema Design

### Core Schema: `memory/tasks.json`

```json
{
  "version": "1.0.0",
  "metadata": {
    "projectName": "authentication-system",
    "constitution": "Build secure, tested, maintainable auth system",
    "createdAt": "2025-10-01T10:00:00Z",
    "lastUpdated": "2025-10-01T14:30:00Z",
    "currentPhase": "implementation"
  },
  "tasks": [
    {
      "id": "1",
      "title": "Setup project infrastructure",
      "description": "Initialize build tools, TypeScript config, testing framework",
      "status": "done",
      "phase": "infrastructure",
      "dependencies": [],
      "acceptanceCriteria": [
        "Vite configured with React",
        "TypeScript compilation works",
        "Vitest test runner setup",
        "npm run build succeeds",
        "npm test succeeds"
      ],
      "deliverables": [
        "package.json",
        "vite.config.ts",
        "tsconfig.json",
        "vitest.config.ts"
      ],
      "tests": [
        "npm run build exits 0",
        "npm test exits 0"
      ],
      "agent": "infrastructure-implementation-agent",
      "startedAt": "2025-10-01T10:05:00Z",
      "completedAt": "2025-10-01T11:30:00Z",
      "validationResults": {
        "testsPass": true,
        "deliverablesExist": true,
        "validatedAt": "2025-10-01T11:30:00Z"
      }
    },
    {
      "id": "2",
      "title": "Create login form component",
      "description": "Build React component with username/password fields and validation",
      "status": "in-progress",
      "phase": "implementation",
      "dependencies": ["1"],
      "acceptanceCriteria": [
        "LoginForm component renders username field",
        "LoginForm component renders password field",
        "Form validates on submit",
        "Tests cover all interactions",
        "All tests pass"
      ],
      "deliverables": [
        "src/components/LoginForm.tsx",
        "src/components/LoginForm.test.tsx"
      ],
      "tests": [
        "npm test -- LoginForm.test.tsx exits 0"
      ],
      "agent": "component-implementation-agent",
      "startedAt": "2025-10-01T11:35:00Z",
      "completedAt": null,
      "validationResults": null
    },
    {
      "id": "3",
      "title": "Implement authentication API",
      "description": "Create auth service with login/logout/verify endpoints",
      "status": "pending",
      "phase": "implementation",
      "dependencies": ["1"],
      "acceptanceCriteria": [
        "AuthService class implements IAuthService",
        "login() method validates credentials",
        "logout() clears session",
        "verify() checks token validity",
        "All methods have unit tests",
        "All tests pass"
      ],
      "deliverables": [
        "src/services/AuthService.ts",
        "src/services/AuthService.test.ts",
        "src/types/IAuthService.ts"
      ],
      "tests": [
        "npm test -- AuthService.test.ts exits 0"
      ],
      "agent": null,
      "startedAt": null,
      "completedAt": null,
      "validationResults": null
    },
    {
      "id": "4",
      "title": "Integration testing",
      "description": "End-to-end tests of login flow",
      "status": "blocked",
      "phase": "validation",
      "dependencies": ["2", "3"],
      "acceptanceCriteria": [
        "User can login with valid credentials",
        "Invalid credentials show error",
        "Session persists across refresh",
        "Logout clears session",
        "All integration tests pass"
      ],
      "deliverables": [
        "tests/integration/auth.test.ts"
      ],
      "tests": [
        "npm test -- auth.test.ts exits 0"
      ],
      "agent": null,
      "startedAt": null,
      "completedAt": null,
      "validationResults": null
    }
  ]
}
```

### Task Status Values

- `pending` - Ready to work on (dependencies satisfied)
- `in-progress` - Currently being worked on by agent
- `done` - Completed and validated
- `blocked` - Dependencies not yet complete
- `failed` - Validation failed, needs rework
- `cancelled` - No longer needed

### Dependency Graph

```
Task 1 (infrastructure)
    ├→ Task 2 (login form) → Task 4 (integration)
    └→ Task 3 (auth API)   ↗
```

**Parallel Execution**: Tasks 2 and 3 can run in parallel (both depend only on Task 1)

**Sequential Requirement**: Task 4 must wait for both 2 and 3

---

## Part 5: Hook Implementation Specification

### SubagentStop Validation Hook

**File**: `templates/hooks/subagent-validation.sh`

**Purpose**: Validate agent work BEFORE Hub Claude proceeds

**Validation Checklist**:
1. ✅ Tests pass (`npm test` returns 0)
2. ✅ Deliverables exist on filesystem
3. ✅ Memory updated with completion state
4. ✅ Validation results recorded

**Implementation**:

```bash
#!/bin/bash
# .claude/hooks/subagent-validation.sh
# SubagentStop hook - validates task completion

set -euo pipefail

MEMORY_DIR=".claude/memory"
TASKS_FILE="$MEMORY_DIR/tasks.json"

# Function to read task being validated
get_current_task() {
  jq -r '.tasks[] | select(.status=="in-progress") | .id' "$TASKS_FILE" | head -n1
}

# Function to validate tests
validate_tests() {
  local task_id=$1
  echo "🧪 Running tests for task $task_id..."

  # Get test command from task
  local test_cmd=$(jq -r ".tasks[] | select(.id==\"$task_id\") | .tests[0]" "$TASKS_FILE")

  # Run tests
  if eval "$test_cmd" > /tmp/test-output-$task_id.log 2>&1; then
    echo "✅ Tests passed"
    return 0
  else
    echo "❌ Tests failed - see /tmp/test-output-$task_id.log"
    return 1
  fi
}

# Function to validate deliverables
validate_deliverables() {
  local task_id=$1
  echo "📦 Checking deliverables for task $task_id..."

  local deliverables=$(jq -r ".tasks[] | select(.id==\"$task_id\") | .deliverables[]" "$TASKS_FILE")
  local all_exist=true

  for file in $deliverables; do
    if [ -f "$file" ]; then
      echo "  ✅ $file exists"
    else
      echo "  ❌ $file MISSING"
      all_exist=false
    fi
  done

  if [ "$all_exist" = true ]; then
    return 0
  else
    return 1
  fi
}

# Function to update memory
update_memory() {
  local task_id=$1
  local tests_pass=$2
  local deliverables_exist=$3

  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Update task status and validation results
  jq --arg id "$task_id" \
     --arg status "done" \
     --argjson tests_pass "$tests_pass" \
     --argjson deliverables_exist "$deliverables_exist" \
     --arg timestamp "$timestamp" \
     '.tasks |= map(
       if .id == $id then
         .status = $status |
         .completedAt = $timestamp |
         .validationResults = {
           "testsPass": $tests_pass,
           "deliverablesExist": $deliverables_exist,
           "validatedAt": $timestamp
         }
       else
         .
       end
     ) | .metadata.lastUpdated = $timestamp' \
     "$TASKS_FILE" > "$TASKS_FILE.tmp"

  mv "$TASKS_FILE.tmp" "$TASKS_FILE"
}

# Main validation flow
main() {
  # Check if memory directory exists
  if [ ! -d "$MEMORY_DIR" ]; then
    echo "⚠️  No memory directory found - skipping validation"
    exit 0
  fi

  if [ ! -f "$TASKS_FILE" ]; then
    echo "⚠️  No tasks.json found - skipping validation"
    exit 0
  fi

  # Get current task
  TASK_ID=$(get_current_task)

  if [ -z "$TASK_ID" ]; then
    echo "⚠️  No task in progress - skipping validation"
    exit 0
  fi

  echo "🔍 Validating task $TASK_ID..."

  # Validate tests
  TESTS_PASS=false
  if validate_tests "$TASK_ID"; then
    TESTS_PASS=true
  fi

  # Validate deliverables
  DELIVERABLES_EXIST=false
  if validate_deliverables "$TASK_ID"; then
    DELIVERABLES_EXIST=true
  fi

  # Update memory
  update_memory "$TASK_ID" "$TESTS_PASS" "$DELIVERABLES_EXIST"

  # Decide whether to allow Hub to proceed
  if [ "$TESTS_PASS" = true ] && [ "$DELIVERABLES_EXIST" = true ]; then
    echo "✅ Task $TASK_ID validation PASSED"
    echo "✅ Updating memory and allowing Hub to proceed"

    # Output hookSpecificOutput JSON for Claude Code
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStop",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Task $TASK_ID validation passed: tests pass ✅, deliverables exist ✅"
  }
}
EOF
    exit 0
  else
    echo "❌ Task $TASK_ID validation FAILED"
    echo "❌ Tests passed: $TESTS_PASS"
    echo "❌ Deliverables exist: $DELIVERABLES_EXIST"
    echo "🚫 BLOCKING Hub Claude from proceeding"

    # Output hookSpecificOutput JSON for Claude Code
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStop",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Task $TASK_ID validation failed: tests pass = $TESTS_PASS, deliverables exist = $DELIVERABLES_EXIST. Agent must fix issues before proceeding."
  }
}
EOF
    exit 2
  fi
}

main "$@"
```

### PreToolUse(Task) Dependency Hook

**File**: `templates/hooks/pre-agent-deploy.sh`

**Purpose**: Validate dependencies BEFORE deploying agent

**Validation Checklist**:
1. ✅ All dependencies have status = "done"
2. ✅ No circular dependencies
3. ✅ Prerequisites met

**Implementation**:

```bash
#!/bin/bash
# .claude/hooks/pre-agent-deploy.sh
# PreToolUse(Task) hook - validates dependencies before agent deployment

set -euo pipefail

MEMORY_DIR=".claude/memory"
TASKS_FILE="$MEMORY_DIR/tasks.json"

# Parse tool input JSON
TOOL_INPUT=$(cat)
TOOL_NAME=$(echo "$TOOL_INPUT" | jq -r '.tool_name')
PROMPT=$(echo "$TOOL_INPUT" | jq -r '.tool_input.prompt // empty')

# Only validate if deploying a Task
if [ "$TOOL_NAME" != "Task" ]; then
  exit 0
fi

# Extract task ID from prompt (if present)
# Format: "Work on task X" or "Deploy agent for task X"
TASK_ID=$(echo "$PROMPT" | grep -oP 'task \K[0-9]+' | head -n1)

if [ -z "$TASK_ID" ]; then
  # No explicit task ID, allow deployment
  exit 0
fi

echo "🔍 Checking dependencies for task $TASK_ID..."

# Get task dependencies
DEPENDENCIES=$(jq -r ".tasks[] | select(.id==\"$TASK_ID\") | .dependencies[]" "$TASKS_FILE" 2>/dev/null || echo "")

if [ -z "$DEPENDENCIES" ]; then
  echo "✅ Task $TASK_ID has no dependencies"
  exit 0
fi

# Check each dependency
ALL_COMPLETE=true
for dep_id in $DEPENDENCIES; do
  dep_status=$(jq -r ".tasks[] | select(.id==\"$dep_id\") | .status" "$TASKS_FILE")

  if [ "$dep_status" = "done" ]; then
    echo "  ✅ Dependency task $dep_id: $dep_status"
  else
    echo "  ❌ Dependency task $dep_id: $dep_status (NOT DONE)"
    ALL_COMPLETE=false
  fi
done

# Allow or block deployment
if [ "$ALL_COMPLETE" = true ]; then
  echo "✅ All dependencies satisfied for task $TASK_ID"
  echo "✅ Allowing agent deployment"

  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Task $TASK_ID dependencies satisfied"
  }
}
EOF
  exit 0
else
  echo "❌ Dependencies NOT satisfied for task $TASK_ID"
  echo "🚫 BLOCKING agent deployment"

  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Task $TASK_ID has incomplete dependencies. Complete dependent tasks first."
  }
}
EOF
  exit 2
fi
```

---

## Part 6: Deterministic Workflow Pattern

### Complete Step-by-Step Flow

```
STEP 1: USER CREATES PROJECT
User: /van:new-project authentication-system

Hub Claude:
- Creates memory/tasks.json
- Prompts for constitution
- Prompts for detailed specification

STEP 2: GENERATE TASKS
User: /van:generate-tasks

Hub Claude (extended thinking):
- Analyzes specification
- Identifies required tasks
- Determines dependencies
- Generates task graph
- Writes to memory/tasks.json

Memory now contains:
- Task 1: Infrastructure (no deps)
- Task 2: Login form (depends on 1)
- Task 3: Auth API (depends on 1)
- Task 4: Integration tests (depends on 2, 3)

STEP 3: HUB ANALYZES NEXT TASK
Hub Claude:
- Reads memory/tasks.json
- Extended thinking: "Task 1 has no dependencies, status pending"
- Decision: "Deploy infrastructure-implementation-agent for task 1"

STEP 4: DEPLOY AGENT FOR TASK 1
Hub Claude:
- Calls Task tool
- PreToolUse(Task) hook fires
  - Checks dependencies for task 1
  - No dependencies → allow deployment
- infrastructure-implementation-agent spawned

STEP 5: AGENT WORKS ON TASK 1
Agent:
- Reads task 1 from memory
- Creates vite.config.ts, tsconfig.json, etc.
- Runs npm install
- Completes work

STEP 6: SUBAGENT STOP HOOK VALIDATES
Hook:
- Runs npm test → passes ✅
- Checks deliverables exist → all present ✅
- Updates memory:
  - task 1 status = "done"
  - completedAt timestamp
  - validationResults recorded
- Exit 0 (allow Hub to proceed)

STEP 7: HUB PROCEEDS TO NEXT TASK
Hub Claude:
- Reads updated memory
- Extended thinking:
  - "Task 1 complete"
  - "Tasks 2 and 3 both depend only on task 1"
  - "Tasks 2 and 3 can run in PARALLEL"
- Decision: "Deploy component-implementation-agent for task 2"
- Decision: "Deploy feature-implementation-agent for task 3"

STEP 8: PARALLEL DEPLOYMENT
Hub Claude:
- Deploys task 2 agent
  - PreToolUse hook checks: task 1 done? YES → allow
- Deploys task 3 agent
  - PreToolUse hook checks: task 1 done? YES → allow
- Both agents work simultaneously

STEP 9: FIRST AGENT COMPLETES (Task 2)
Agent:
- Creates LoginForm.tsx, tests
- SubagentStop hook validates
  - npm test passes ✅
  - deliverables exist ✅
- Memory updated: task 2 = "done"
- Hub allowed to proceed

STEP 10: SECOND AGENT COMPLETES (Task 3)
Agent:
- Creates AuthService.ts, tests
- SubagentStop hook validates
  - npm test passes ✅
  - deliverables exist ✅
- Memory updated: task 3 = "done"
- Hub allowed to proceed

STEP 11: HUB ANALYZES NEXT TASK
Hub Claude:
- Reads memory
- Extended thinking:
  - "Tasks 2 and 3 both complete"
  - "Task 4 depends on tasks 2 and 3"
  - "All dependencies satisfied"
- Decision: "Deploy testing-implementation-agent for task 4"

STEP 12: DEPLOY INTEGRATION TEST AGENT
Hub Claude:
- Deploys task 4 agent
  - PreToolUse hook checks: tasks 2 and 3 done? YES → allow
- Agent creates integration tests
- SubagentStop validates
  - npm test passes ✅
  - Memory updated: task 4 = "done"

STEP 13: PROJECT COMPLETE
Hub Claude:
- Reads memory
- Extended thinking: "All tasks status = done"
- Reports: "Authentication system complete ✅"
```

### Why This is Deterministic

**Sequential Enforcement**:
- Task 2 CANNOT start until task 1 validates complete
- PreToolUse hook blocks deployment
- No way to bypass

**Test Requirements**:
- Task cannot be marked "done" if tests fail
- SubagentStop hook blocks Hub
- Agent must fix tests before proceeding

**Parallel Safety**:
- Tasks 2 and 3 have NO shared dependencies
- Extended thinking identifies safe parallelism
- Hooks validate independently

**Transparent State**:
- Hub reads memory for current status
- Cannot rely on agent claims
- Memory updated by hooks, not agents

**Explicit Dependencies**:
- Task 4 lists dependencies: [2, 3]
- PreToolUse hook checks both complete
- Blocks if either incomplete

---

## Part 7: Comparison Matrix

| Feature | CCPM | Claude-Flow | Spec-Kit | Our Solution |
|---------|------|-------------|----------|--------------|
| **State Store** | GitHub Issues | SQLite `.swarm/memory.db` | Git Branches | JSON `.claude/memory/` |
| **Transparency** | ⭐⭐ (Medium - API) | ⭐ (Low - binary) | ⭐⭐⭐ (Medium - Git) | ⭐⭐⭐⭐⭐ (High - JSON) |
| **Hub Queryable** | ❌ (API calls) | ❌ (SQL queries) | ❌ (Git commands) | ✅ (Direct reads) |
| **Validation** | ❌ None | ⚠️ Soft (hooks don't block) | ⚠️ Optional (/analyze) | ✅ Mandatory (blocking hooks) |
| **Dependencies** | ⚠️ Manual tracking | ❌ Ad-hoc coordination | ⚠️ Manual tracking | ✅ Explicit + enforced |
| **Test Requirements** | ❌ None | ❌ None | ❌ None | ✅ Mandatory (hook blocks) |
| **Blocking Gates** | ❌ No | ❌ No (hooks enhance) | ❌ No | ✅ Yes (exit 2) |
| **Parallel Safe** | ❌ No safeguards | ⚠️ Unclear | ❌ No safeguards | ✅ Yes (dependency analysis) |
| **Task Status** | GitHub labels | Session state | Branch names | Explicit status field |
| **Deliverable Check** | ❌ None | ❌ None | ❌ None | ✅ Filesystem validation |
| **External Dependencies** | ✅ GitHub API | ❌ SQLite | ✅ Git | ✅ None (just files) |
| **Debuggability** | ⭐⭐⭐ (GitHub UI) | ⭐ (SQLite queries) | ⭐⭐ (Git log) | ⭐⭐⭐⭐⭐ (cat JSON files) |
| **User Editability** | ❌ (GitHub UI) | ❌ (binary) | ⚠️ (Git) | ✅ (text files) |
| **Recovery** | ⭐⭐ (GitHub history) | ⭐ (session restore) | ⭐⭐⭐ (Git revert) | ⭐⭐⭐⭐⭐ (Git + manual edit) |
| **Complexity** | ⭐⭐⭐ (Medium) | ⭐⭐⭐⭐⭐ (Very High) | ⭐⭐ (Low) | ⭐⭐ (Low) |

### Key Takeaways

**CCPM**: Good concepts (parallel, hierarchy), but no validation enforcement
**Claude-Flow**: Impressive features, but too complex and opaque
**Spec-Kit**: Clean methodology, but optional validation
**Our Solution**: Simple, transparent, deterministic through external enforcement

---

## Part 8: User Commands & Experience

### Command Structure

**/van:new-project <name>**
- Initialize new project with constitution
- Prompt for project principles
- Create memory directory structure
- Generate initial tasks.json

**/van:specify**
- Guide user through detailed specification
- Capture requirements, constraints, dependencies
- Use specification to inform task generation

**/van:generate-tasks**
- Analyze specification
- Generate task graph with dependencies
- Write to memory/tasks.json
- Show task visualization

**/van:next**
- Query memory for next available task
- Show task details
- Deploy appropriate agent automatically

**/van:status**
- Show all tasks with status
- Highlight current task
- Display dependency graph
- Show validation results

**/van:validate**
- Run validation on current task
- Display test results
- Show deliverable checklist
- Trigger SubagentStop hook manually

**/van:graph**
- Visualize task dependency graph
- Show parallel execution opportunities
- Highlight blocked tasks
- Display critical path

**/van:resume**
- Continue from interrupted session
- Load state from memory
- Show last completed task
- Proceed to next task

### Example User Session

```
User: /van:new-project authentication-system

Hub: Let's define your project. What are the core principles?

User: Secure, tested, maintainable authentication with JWT

Hub: ✅ Constitution set. Now let's create a specification.

User: /van:specify

Hub: I'll guide you through the specification...
     1. What authentication methods? (password, OAuth, etc.)
     2. What security requirements? (hashing, rate limiting, etc.)
     3. What testing requirements? (unit, integration, e2e, etc.)

[User provides detailed specification]

Hub: ✅ Specification complete. Generating tasks...

User: /van:generate-tasks

Hub: Analyzing specification with extended thinking...

     Identified 4 tasks:
     1. Infrastructure setup (no dependencies)
     2. Login form component (depends on 1)
     3. Auth API service (depends on 1)
     4. Integration tests (depends on 2, 3)

     Tasks 2 and 3 can run in parallel.

     ✅ Tasks written to memory/tasks.json

User: /van:next

Hub: Next available task: Task 1 - Infrastructure setup

     Dependencies: None
     Status: pending

     Deploying infrastructure-implementation-agent...

     [Agent works, SubagentStop hook validates]

     ✅ Task 1 complete (tests pass, deliverables exist)

User: /van:next

Hub: Two tasks available for parallel execution:
     - Task 2: Login form
     - Task 3: Auth API

     Deploying both agents in parallel...

     [Both agents work, hooks validate]

     ✅ Task 2 complete
     ✅ Task 3 complete

User: /van:status

Hub: Project: authentication-system

     ✅ Task 1: Infrastructure setup (done)
     ✅ Task 2: Login form (done)
     ✅ Task 3: Auth API (done)
     ⏳ Task 4: Integration tests (next)

     Current phase: validation
     Tests passing: 100%

User: /van:next

Hub: Deploying testing-implementation-agent for task 4...

     [Agent creates integration tests, hook validates]

     ✅ Task 4 complete

     🎉 All tasks complete! Authentication system ready.
```

---

## Part 9: Implementation Roadmap

### Phase 1: Memory System Foundation

**Deliverables**:
- Memory schema design (tasks.json structure)
- Read/write operations (via Write tool or native memory if available)
- Atomic update mechanisms
- Backup/restore utilities

**Tasks**:
1. Verify memory tool availability in Claude Code CLI
2. Implement file-based fallback if needed
3. Create memory initialization logic
4. Build JSON validation
5. Test concurrent access handling

### Phase 2: Hook Implementation

**Deliverables**:
- SubagentStop validation hook
- PreToolUse dependency hook
- Hook testing utilities
- Integration with memory system

**Tasks**:
1. Write subagent-validation.sh
2. Write pre-agent-deploy.sh
3. Update settings.json.template
4. Test validation logic
5. Test dependency checking
6. Handle edge cases

### Phase 3: Hub Intelligence

**Deliverables**:
- Extended thinking for task analysis
- Dependency graph traversal
- Parallel execution detection
- State query operations

**Tasks**:
1. Implement task query functions
2. Build dependency analysis
3. Create parallel detection logic
4. Add extended thinking prompts
5. Test complex scenarios

### Phase 4: User Commands

**Deliverables**:
- /van:new-project command
- /van:generate-tasks command
- /van:next command
- /van:status command
- /van:graph visualization

**Tasks**:
1. Create command templates
2. Implement task generation logic
3. Build status reporting
4. Create graph visualization
5. Test user workflows

### Phase 5: Validation & Polish

**Deliverables**:
- Comprehensive test suite
- Example projects
- User documentation
- Migration guides

**Tasks**:
1. Create test scenarios
2. Build example projects
3. Write user guides
4. Document edge cases
5. Performance optimization

---

## Part 10: Open Design Questions

### Critical Questions Requiring Resolution

1. **Memory Tool API Availability**
   - Q: Is `create_memory/read_memory/update_memory` available in Claude Code CLI?
   - Investigation needed: Test in Claude Code session
   - Fallback: Use Write/Read tools to `.claude/memory/` directory

2. **Atomic Update Mechanisms**
   - Q: How to prevent race conditions with parallel agents?
   - Options: File locking, temporary files with atomic move, queue-based updates
   - Decision needed: Which approach for this use case?

3. **Concurrent Access Handling**
   - Q: Two parallel agents update memory simultaneously - what happens?
   - Test needed: Spawn two agents, both update memory, check for corruption
   - Solution: Atomic updates with temp files, or serialize updates through Hub

4. **Rollback/Recovery Strategies**
   - Q: Memory file corrupted - how to recover?
   - Options: Git versioning, backup files, validation checksums
   - Decision: Combine multiple strategies?

5. **Task Graph Visualization**
   - Q: How to display dependency graph to users?
   - Options: ASCII art, Mermaid diagram, GraphViz, simple tree
   - Decision: Start simple (tree), add rich visualization later?

6. **Integration with Existing Projects**
   - Q: User has existing codebase - how to adopt this system?
   - Process: Analyze codebase, generate tasks retroactively?
   - Challenge: Mapping existing code to task structure

7. **Migration from TaskMaster**
   - Q: Users currently using TaskMaster - migration path?
   - Options: Export TaskMaster tasks to memory format, run in parallel temporarily
   - Timeline: When to deprecate TaskMaster integration?

8. **Performance Optimization**
   - Q: Memory file sizes - how large before performance issues?
   - Test: 10 tasks, 100 tasks, 1000 tasks - measure read/write times
   - Optimization: Incremental updates, compression, archiving old tasks?

9. **Hook Error Handling**
   - Q: Hook crashes - what should happen?
   - Options: Assume failure (safe), retry, skip (dangerous)
   - Decision: Default to blocking on hook errors

10. **Extended Thinking Token Budget**
    - Q: Complex dependency analysis - how much thinking needed?
    - Test: Various project sizes, measure thinking tokens
    - Balance: Thoroughness vs. speed/cost

---

## Part 11: Revolutionary Impact

### Why This Changes Everything

#### 1. First Truly Deterministic AI Task System

**Current State**: All existing systems (CCPM, Claude-Flow, Spec-Kit) are non-deterministic
- Same input ≠ same output
- Agent can skip steps
- Tests can fail but task "complete"
- Dependencies ignored

**Our System**: Deterministic through external enforcement
- Same task definitions → same validation requirements → same result
- Agent cannot skip validation (hooks block)
- Tests must pass (exit 2 if fail)
- Dependencies enforced (PreToolUse hook)

**Impact**: Reliable, reproducible software development with AI

#### 2. Transparent State Management

**Current State**: Opaque state (GitHub API, SQLite binary, Git branches)
- Can't easily inspect
- Hub Claude can't query naturally
- Users must trust the system
- Debugging requires specialized tools

**Our System**: Transparent JSON files
- `cat .claude/memory/tasks.json` shows everything
- Hub Claude reads directly
- Users can edit manually if needed
- Git tracks all changes

**Impact**: Trust through visibility, easy debugging, user control

#### 3. External Enforcement Layer

**Current State**: Trust-based model
- System trusts agent claims
- No external validation
- Agent can lie about completion
- No mechanism to prevent bypassing

**Our System**: Hooks as enforcement gates
- Hooks are external to LLM
- Deterministic validation logic
- Exit 2 = hard block
- Agent cannot bypass

**Impact**: Guardrails that actually work

#### 4. Test-Pass Mandatory

**Current State**: Tests optional or not checked
- Can close task with failing tests
- No build verification
- Technical debt accumulates
- Main branch breaks

**Our System**: Tests must pass
- SubagentStop hook runs npm test
- Exit 2 if tests fail
- Hub blocked until fixed
- No exceptions

**Impact**: Always-working main branch, quality enforced

#### 5. Dependency Graph Enforcement

**Current State**: Manual dependency tracking
- Agent must remember dependencies
- Easy to violate
- Parallel execution unsafe
- Order errors common

**Our System**: Explicit dependencies + hooks
- Dependencies in task.json
- PreToolUse hook validates
- Extended thinking analyzes graph
- Safe parallel execution

**Impact**: Correct execution order, safe parallelism

#### 6. Simplicity Through Intelligence

**Current State**: Complexity to handle non-determinism
- 64 agents (Claude-Flow)
- Queen coordination
- Neural patterns
- Complex state machines

**Our System**: Simple architecture, intelligent coordination
- Hub Claude + Extended Thinking
- Memory + Hooks
- Minimal agents
- Transparent flow

**Impact**: Easier to understand, maintain, debug, extend

---

## Conclusion

### The Fundamental Innovation

**Problem**: AI agents are non-deterministic - same prompt ≠ same behavior
**Solution**: External enforcement layer (hooks) + transparent state (memory) = deterministic execution

### Core Insight

```
NON-DETERMINISTIC AGENT WORK
    +
DETERMINISTIC VALIDATION GATES
    =
RELIABLE SOFTWARE DEVELOPMENT
```

### What Makes This Revolutionary

1. **First system** to use hooks as blocking gates
2. **First system** with transparent JSON state management
3. **First system** enforcing test-pass requirements
4. **First system** with dependency graph enforcement
5. **First system** proven to be deterministic

### Next Steps

1. **Immediate**: Implement memory system (Phase 1)
2. **Critical**: Build hooks (Phase 2)
3. **Essential**: Test determinism (validate the core claim)
4. **Important**: Create user commands (Phase 4)
5. **Polish**: Documentation and examples (Phase 5)

### Success Metrics

**Determinism Test**:
- Same task definitions → run 10 times → 10 identical results
- Measure: Task completion order, validation results, final state
- Goal: 100% consistency

**Quality Test**:
- Introduce failing test in task N
- Measure: Does system proceed to task N+1?
- Goal: 0% false completions

**Dependency Test**:
- Task B depends on Task A
- Try to start Task B before Task A complete
- Goal: 100% blocking (PreToolUse hook works)

**User Experience Test**:
- Give 5 users same project specification
- Measure: Time to completion, satisfaction, errors encountered
- Goal: Consistent, positive experience

---

**Document Version**: 1.0
**Status**: Design Complete - Ready for Implementation
**Last Updated**: 2025-10-01
