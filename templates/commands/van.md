# /van - Deterministic Task System

**Description**: Activates deterministic task management using WBS hierarchy, hooks enforcement, and agent orchestration.

---

## Instructions

When user provides a request like "build me a todo app", you automatically execute this workflow:

## AUTOMATIC WORKFLOW

### STEP 1: Create Task Hierarchy (You decide WHAT)

Parse the user's request into WBS hierarchy and save to `.claude/memory/task-index.json`:

```json
{
  "version": "1.0.0",
  "tasks": [
    {
      "id": "1",
      "type": "epic",
      "title": "User's main goal",
      "status": "pending",
      "parent": null,
      "children": ["1.1", "1.2"]
    },
    {
      "id": "1.1",
      "type": "feature",
      "title": "Major component",
      "status": "pending",
      "parent": "1",
      "children": ["1.1.1", "1.1.2"],
      "dependencies": []
    },
    {
      "id": "1.1.1",
      "type": "task",
      "title": "Atomic work item",
      "status": "pending",
      "parent": "1.1",
      "children": [],
      "dependencies": [],
      "deliverables": ["file.js"]
    }
  ]
}
```

Show the user the hierarchy you created.

### STEP 2: Find Next Available Task (Deterministic query)

```bash
# Source helpers
source .claude/memory/lib/wbs-helpers.sh

# Get leaf tasks (no children)
leaf_tasks=$(get_leaf_tasks)

# Find first pending leaf task with satisfied dependencies
# Read task-index.json and filter
```

### STEP 3: Deploy Agent for Task (You trigger, hooks enforce)

Use Task tool to deploy appropriate agent:

```
Deploy @component-implementation-agent via Task tool for task 1.1.1
```

**PreToolUse(Task) hook automatically:**
- Checks if 1.1.1 is a leaf task (no children) → YES
- Checks if dependencies satisfied → YES
- Allows or BLOCKS deployment

### STEP 4: Agent Works (Agent decides HOW)

Agent reads task from memory and implements it.

### STEP 5: Validation (Hook does this deterministically)

**SubagentStop hook automatically:**
- Validates tests pass
- Validates deliverables exist
- Updates `.claude/memory/task-index.json` status to "done"
- Rolls up status through hierarchy using `propagate_status_up`
- BLOCKS if validation fails

### STEP 6: Loop

Read updated memory, find next task, deploy agent. Repeat until all tasks done.

## Example: "/van build me a simple todo application"

```
🚀 DETERMINISTIC TASK SYSTEM ACTIVATED

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 1: Creating Task Hierarchy
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Analyzing request: "build me a simple todo application"

Created WBS hierarchy:
  1. Todo Application (Epic)
    1.1 HTML Structure (Feature)
      1.1.1 Create index.html ← LEAF
      1.1.2 Add form for new todos ← LEAF
      1.1.3 Add container for list ← LEAF
    1.2 CSS Styling (Feature, depends on 1.1)
      1.2.1 Create styles.css ← LEAF
      1.2.2 Add responsive design ← LEAF
    1.3 JavaScript (Feature, depends on 1.1)
      1.3.1 Create app.js structure ← LEAF
      1.3.2 Add todo function ← LEAF (depends on 1.3.1)
      1.3.3 Delete function ← LEAF (depends on 1.3.2)
      1.3.4 Complete function ← LEAF (depends on 1.3.2)

✅ Saved to .claude/memory/task-index.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 2: Finding Next Available Task
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Querying memory for next task...
Found: Task 1.1.1 (Create index.html)
  ✅ Is leaf task (no children)
  ✅ No dependencies
  ✅ Status: pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 3: Deploying Agent
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Deploying @component-implementation-agent for task 1.1.1...

[PreToolUse(Task) hook runs]
  ✅ Task 1.1.1 is leaf (no children)
  ✅ Dependencies satisfied (none)
  → ALLOW deployment

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 4: Agent Working on Task 1.1.1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[@component-implementation-agent]
Reading task 1.1.1 from memory...
Creating index.html with semantic structure...
✅ Created index.html

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 5: Validation (SubagentStop Hook)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[SubagentStop hook runs automatically]
🔍 Validating task 1.1.1...
  ✅ Deliverable exists: index.html
  ✅ Updating task-index.json: 1.1.1 → "done"
  ✅ Rolling up status:
     - Feature 1.1: 1/3 tasks complete → "in-progress"
     - Epic 1: 1/9 tasks complete → "in-progress"

→ ALLOW Hub to proceed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 2: Finding Next Available Task
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found: Task 1.1.2 (Add form for new todos)
  ✅ Is leaf task
  ✅ No dependencies
  ✅ Status: pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 3: Deploying Agent
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Deploying @component-implementation-agent for task 1.1.2...

[... agent works, hook validates, status updates ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Continue through all tasks in dependency order]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 2: Finding Next Available Task
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found: Task 1.2.1 (Create styles.css)
  ✅ Is leaf task
  ✅ Dependency 1.1 satisfied (Feature 1.1 = "done")
  ✅ Status: pending

[Deploy agent, validate, continue...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FINAL STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Epic 1: Todo Application → DONE (3/3 features complete)
  Feature 1.1: HTML Structure → DONE (3/3 tasks)
  Feature 1.2: CSS Styling → DONE (2/2 tasks)
  Feature 1.3: JavaScript → DONE (4/4 tasks)

📁 Deliverables Created:
  ✅ index.html
  ✅ styles.css
  ✅ app.js

🎉 PROJECT COMPLETE
All tasks validated deterministically through hooks.
```

## How It Works (Critical Understanding)

**YOU (Hub Claude) decide:**
- WHAT tasks to create from user request (Step 1)
- WHICH agent to deploy for each task (Step 3)
- WHEN to move to next task (Step 6)

**HOOKS enforce deterministically:**
- PreToolUse(Task): BLOCKS agent deployment if:
  - Task has children (not a leaf)
  - Dependencies not satisfied
- SubagentStop: BLOCKS completion if:
  - Tests fail
  - Deliverables missing
- SubagentStop: AUTOMATICALLY updates:
  - Task status to "done"
  - Roll-up through hierarchy

**AGENTS implement:**
- HOW to write the code
- WHAT the code does
- Agents read tasks from memory
- Agents cannot bypass hooks

## Critical Rules

**What you DO:**
1. Parse user request into task hierarchy
2. Save to .claude/memory/task-index.json
3. Find next available leaf task
4. Deploy agent via Task tool
5. Read updated memory after hook validates
6. Loop until all tasks done

**What you NEVER do:**
- ❌ Work on tasks directly (always deploy agents)
- ❌ Manually update task status (hooks do this)
- ❌ Manually check dependencies (hooks do this)
- ❌ Manually roll up status (hooks do this)

**What HOOKS do automatically:**
- ✅ Block non-leaf tasks
- ✅ Block unsatisfied dependencies
- ✅ Validate tests and deliverables
- ✅ Update task status
- ✅ Roll up hierarchy status

## Active Systems

✅ **Deterministic Memory** - Atomic file operations
✅ **WBS Hierarchy** - 3-level structure with auto roll-up
✅ **PreToolUse(Task) Hook** - Blocks invalid agent deployments
✅ **SubagentStop Hook** - Validates and updates status automatically
✅ **Agent Orchestration** - Task tool deploys specialized agents

The deterministic task system is now active. Parse the user's request and start deploying agents.
