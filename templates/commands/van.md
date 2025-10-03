# /van - Deterministic Task System with TDD Workflow

**Description**: Activates deterministic task management using WBS hierarchy, TDD enforcement, hooks validation, and agent orchestration.

---

## Logging System

**IMPORTANT:** If user has enabled logging (`/van logging enable`), all hook decisions and memory operations are logged to:
- `.claude/memory/logs/current/hooks.jsonl` - All hook execution decisions
- `.claude/memory/logs/current/memory.jsonl` - All memory operations and WBS rollups

**Hook logging is automatic - you do NOT log anything.** Hooks check for `.claude/memory/.logging-enabled` toggle file and log themselves.

---

## Instructions

When user provides a request, you automatically execute this workflow combining WBS task management with strict TDD methodology.

## AUTOMATIC WORKFLOW

### STEP 0: Browser Testing Preflight Check (DETERMINISTIC)

**BEFORE creating tasks, run preflight script:**

```bash
# Run browser testing preflight notification
bash .claude/memory/lib/browser-testing-preflight.sh "USER_REQUEST_HERE"
```

This script:
- ✅ Detects UI keywords (html, css, react, form, button, etc.)
- ✅ Shows browser testing notification (ENABLED by default)
- ✅ Checks for opt-out config (.claude/memory/config.json)
- ✅ Runs deterministically (always executes, no instructions needed)

**Output when UI detected:**
```
🌐 Browser UI Detected
✅ Automated browser testing: ENABLED (default)
   → Validates CSS loads correctly
   ...
⚙️  To DISABLE: echo '{"browserTesting": false}' > .claude/memory/config.json
```

---

### STEP 1: Create Task Hierarchy with Task Breakdown Agent

**Deploy task-breakdown-agent to create task hierarchy:**

Use Task tool to deploy task-breakdown-agent with user request. Agent will create `.claude/memory/task-index.json` deterministically.

**CRITICAL: For each implementation task, create TWO subtasks:**
1. Test task (deploys @test-first-agent)
2. Implementation task (depends on test task, deploys implementation agent)

**Example structure:**
```json
{
  "version": "1.0.0",
  "tasks": [
    {
      "id": "1",
      "type": "epic",
      "title": "Login Form Component",
      "status": "pending",
      "parent": null,
      "children": ["1.1", "1.2"]
    },
    {
      "id": "1.1",
      "type": "feature",
      "title": "Component Structure",
      "status": "pending",
      "parent": "1",
      "children": ["1.1.1", "1.1.2"],
      "dependencies": []
    },
    {
      "id": "1.1.1",
      "type": "task",
      "title": "Write LoginForm tests",
      "status": "pending",
      "parent": "1.1",
      "children": [],
      "dependencies": [],
      "deliverables": ["src/LoginForm.test.jsx"],
      "agent": "test-first-agent"
    },
    {
      "id": "1.1.2",
      "type": "task",
      "title": "Implement LoginForm component",
      "status": "pending",
      "parent": "1.1",
      "children": [],
      "dependencies": ["1.1.1"],
      "deliverables": ["src/LoginForm.jsx"],
      "agent": "component-implementation-agent"
    }
  ]
}
```

**Key principles:**
- Test task ALWAYS comes first (no dependencies)
- Implementation task ALWAYS depends on test task
- This enforces TDD at the task structure level

### STEP 2: Find Next Available Task

```bash
# Source helpers
source .claude/memory/lib/wbs-helpers.sh

# Get leaf tasks (no children)
leaf_tasks=$(get_leaf_tasks)

# Find first pending leaf task with satisfied dependencies
next_task=$(jq -r '.tasks[] |
  select(.children == [] or .children == null) |
  select(.status == "pending") |
  select(
    (.dependencies // []) as $deps |
    all($deps[]; . as $dep |
      any($tasks[]; .id == $dep and .status == "done")
    )
  ) |
  .id' .claude/memory/task-index.json | head -1)
```

### STEP 3: Deploy Agent for Task

Use Task tool to deploy the agent specified in the task's "agent" field:

```
Deploy @test-first-agent via Task tool for task 1.1.1
```

**PreToolUse(Task) hook automatically:**
- Checks if 1.1.1 is a leaf task (no children) → YES
- Checks if dependencies satisfied → YES (none for test tasks)
- Logs decision to hooks.jsonl
- Allows or BLOCKS deployment

### STEP 4: Agent Executes

**If test task (@test-first-agent):**
- Agent writes ONLY test files
- Tests are failing (RED phase - expected)
- Agent completes

**If implementation task (@component-implementation-agent):**
- Agent reads existing tests (written in previous task)
- Agent writes implementation to make tests pass (GREEN phase)
- Agent completes

### STEP 5: Validation (SubagentStop hook)

**SubagentStop hook automatically:**
- Validates tests pass (if tests exist)
- Validates deliverables exist (from task definition)
- Updates `.claude/memory/task-index.json` status to "done"
- Rolls up status through hierarchy using `propagate_status_up`
- Logs validation decision to hooks.jsonl
- BLOCKS if validation fails

### STEP 6: Loop Until Complete

Read updated task-index.json, find next task, deploy agent. Repeat until all leaf tasks done.

## TDD Workflow Integration

**The WBS structure ENFORCES TDD:**

1. **Test tasks have no dependencies** → Always available first
2. **Implementation tasks depend on test tasks** → Can't start until tests written
3. **Hooks enforce at runtime** → TDD-gate blocks writes without tests (defensive layer)
4. **SubagentStop validates** → Tests must pass before marking done

**Result:** TDD is guaranteed by task structure + hook enforcement (belt and suspenders)

## Example: "/van build me a simple login form"

```
🚀 DETERMINISTIC TASK SYSTEM ACTIVATED

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 1: Creating Task Hierarchy
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Analyzing request: "build me a simple login form"

Created WBS hierarchy with TDD structure:
  1. Login Form Component (Epic)
    1.1 Component Structure (Feature)
      1.1.1 Write LoginForm tests ← LEAF (test-first-agent)
      1.1.2 Implement LoginForm ← LEAF (component-implementation-agent, depends on 1.1.1)
    1.2 Validation (Feature, depends on 1.1)
      1.2.1 Write validation tests ← LEAF (test-first-agent)
      1.2.2 Implement validation ← LEAF (feature-implementation-agent, depends on 1.2.1)

✅ Saved to .claude/memory/task-index.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 2: Finding Next Available Task
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Querying memory for next task...
Found: Task 1.1.1 (Write LoginForm tests)
  ✅ Is leaf task (no children)
  ✅ No dependencies
  ✅ Status: pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 3: Deploying Agent
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Deploying @test-first-agent for task 1.1.1...

[PreToolUse(Task) hook runs]
  ✅ Task 1.1.1 is leaf (no children)
  ✅ Dependencies satisfied (none)
  → ALLOW deployment

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 4: Agent Working on Task 1.1.1 (RED PHASE)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[@test-first-agent]
Writing tests for LoginForm component...
✅ Created src/LoginForm.test.jsx
❌ Tests failing (expected - no implementation yet)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 5: Validation (SubagentStop Hook)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[SubagentStop hook runs automatically]
🔍 Validating task 1.1.1...
  ✅ Deliverable exists: src/LoginForm.test.jsx
  ✅ Updating task-index.json: 1.1.1 → "done"
  ✅ Rolling up status:
     - Feature 1.1: 1/2 tasks complete → "in-progress"
     - Epic 1: 1/4 tasks complete → "in-progress"

→ ALLOW Hub to proceed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 2: Finding Next Available Task
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found: Task 1.1.2 (Implement LoginForm)
  ✅ Is leaf task
  ✅ Dependency 1.1.1 satisfied (done)
  ✅ Status: pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 3: Deploying Agent
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Deploying @component-implementation-agent for task 1.1.2...

[PreToolUse(Task) hook runs]
  ✅ Task 1.1.2 is leaf
  ✅ Dependency 1.1.1 = done
  ✅ Defensive check: src/LoginForm.test.jsx exists
  → ALLOW deployment

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 4: Agent Working on Task 1.1.2 (GREEN PHASE)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[@component-implementation-agent]
Reading tests from src/LoginForm.test.jsx...
Understanding requirements from test assertions...
Writing implementation to make tests pass...
✅ Created src/LoginForm.jsx
✅ All tests now passing

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 5: Validation (SubagentStop Hook)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[SubagentStop hook runs automatically]
🔍 Validating task 1.1.2...
  ✅ Tests pass: 10/10
  ✅ Deliverable exists: src/LoginForm.jsx
  ✅ Updating task-index.json: 1.1.2 → "done"
  ✅ Rolling up status:
     - Feature 1.1: 2/2 tasks complete → "done"
     - Epic 1: 2/4 tasks complete → "in-progress"

→ ALLOW Hub to proceed

[Continue through remaining tasks...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FINAL STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Epic 1: Login Form Component → DONE (2/2 features complete)
  Feature 1.1: Component Structure → DONE (2/2 tasks)
    1.1.1 Write LoginForm tests → DONE
    1.1.2 Implement LoginForm → DONE
  Feature 1.2: Validation → DONE (2/2 tasks)
    1.2.1 Write validation tests → DONE
    1.2.2 Implement validation → DONE

📁 Deliverables Created:
  ✅ src/LoginForm.test.jsx
  ✅ src/LoginForm.jsx
  ✅ src/validation.test.js
  ✅ src/validation.js

🎉 PROJECT COMPLETE
All tasks validated deterministically through WBS + TDD + hooks.

💡 If logging is enabled (/van logging enable), all hook decisions and memory operations have been logged to:
   - .claude/memory/logs/current/hooks.jsonl
   - .claude/memory/logs/current/memory.jsonl
```

## How It Works (Critical Understanding)

**YOU (Hub Claude) decide:**
- WHAT tasks to create from user request (Step 1)
- Task structure ENFORCES TDD (test task before implementation task)
- WHICH agent to deploy for each task (Step 3)
- WHEN to move to next task (Step 6)

**HOOKS enforce deterministically:**
- PreToolUse(Task): BLOCKS agent deployment if:
  - Task has children (not a leaf)
  - Dependencies not satisfied
  - Logs every decision to hooks.jsonl
- PreToolUse(Write/Edit): BLOCKS file writes without tests (TDD-gate, defensive layer)
- SubagentStop: BLOCKS completion if:
  - Tests fail
  - Deliverables missing
  - Logs validation and updates to memory.jsonl
- SubagentStop: AUTOMATICALLY updates:
  - Task status to "done"
  - Roll-up through hierarchy
  - Memory operations logged

**AGENTS implement:**
- HOW to write the code
- WHAT the code does
- Agents read tasks from memory
- Agents cannot bypass hooks
- test-first-agent writes ONLY tests
- Implementation agents write ONLY implementation

## Critical Rules

**What you DO:**
1. Parse user request into WBS hierarchy with TDD structure
2. For each implementation need, create test task + implementation task (with dependency)
3. Save to .claude/memory/task-index.json
4. Find next available leaf task (use wbs-helpers.sh)
5. Deploy agent specified in task's "agent" field via Task tool
6. Read updated memory after hook validates
7. Loop until all leaf tasks done

**What you NEVER do:**
- ❌ Work on tasks directly (always deploy agents)
- ❌ Manually update task status (hooks do this)
- ❌ Manually check dependencies (hooks do this)
- ❌ Manually roll up status (hooks do this)
- ❌ Create implementation tasks without test tasks
- ❌ Create test tasks that depend on implementation (backwards!)

**What HOOKS do automatically:**
- ✅ Block non-leaf tasks
- ✅ Block unsatisfied dependencies
- ✅ Block writes without tests (TDD-gate, defensive)
- ✅ Validate tests and deliverables
- ✅ Update task status
- ✅ Roll up hierarchy status
- ✅ Log all decisions and memory operations

## Active Systems

✅ **Deterministic Memory** - Atomic file operations, logged
✅ **WBS Hierarchy** - 3-level structure with auto roll-up, logged
✅ **TDD Enforcement** - Task structure + hook enforcement (belt and suspenders)
✅ **PreToolUse(Task) Hook** - Blocks invalid agent deployments, logs decisions
✅ **PreToolUse(Write/Edit) Hook** - TDD-gate blocks writes without tests, logs violations
✅ **SubagentStop Hook** - Validates and updates status automatically, logs operations
✅ **Logging System** - All hook decisions and memory operations logged to .claude/memory/logs/current/

The deterministic task system with TDD enforcement is now active. Parse the user's request, create WBS with test+implementation task pairs, and start deploying agents.
