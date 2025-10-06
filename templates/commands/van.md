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

### STEP 0: Preflight Configuration

**Check:** If `.claude/memory/.preflight-done` exists, skip this step entirely.

**If not exists, YOU MUST ASK THE USER INTERACTIVELY:**

🚨 **CRITICAL**: You CANNOT fabricate user responses. A PreToolUse hook validates the conversation transcript and will BLOCK preflight.sh if user messages don't exist. You MUST get actual user input.

**MANDATORY INTERACTIVE QUESTIONING:**

**1. ASK Question 1 (output to user):**
```
📊 Enable deterministic logging? This captures all hook decisions and memory operations to `.claude/memory/logs/current/*.jsonl` for debugging and research.

| Option | Description |
|--------|-------------|
| y | Enable logging |
| n | Disable logging |

Your answer (y/n):
```

**2. WAIT for user to respond** (their next message)

**3. READ their answer** and save as `LOGGING_ANSWER`

**4. ASK Question 2 (output to user):**
```
🌐 Enable browser testing with Chrome DevTools? This validates CSS loading, user interactions, and DOM changes in a real browser (~30-60s per UI task). Best for web apps.

| Option | Description |
|--------|-------------|
| y | Enable browser testing |
| n | Disable browser testing |

Your answer (y/n):
```

**5. WAIT for user to respond** (their next message)

**6. READ their answer** and save as `BROWSER_ANSWER`

**7. ONLY AFTER BOTH USER RESPONSES, execute preflight:**
```bash
./.claude/memory/lib/preflight.sh '{"logging":"LOGGING_ANSWER","browserTesting":"BROWSER_ANSWER","prdPath":"","userConfirmed":true}'
```

The preflight-confirmation hook will:
- Read the conversation transcript
- Verify user messages exist after questions
- Verify answers match command arguments
- DENY if fabricated, ALLOW if legitimate

**8. Read JSON output and confirm:**
```
✅ Configuration saved
- Logging: [enabled/disabled]
- Browser Testing: [enabled/disabled]

Ready to proceed.
```

---

### STEP 1: Create Task Hierarchy with TDD Structure

**ACTION:** Deploy `@task-breakdown-agent` via Task tool with the user's actual request.

The agent will parse the request and create task-index.json.

**NOTE:** Do NOT create tasks yourself. Do NOT use the example below as the actual output. The agent creates tasks based on the ACTUAL user request, not the example.

**For reference only, here is an example structure for a hypothetical "Login Form" request (this is NOT your actual task):**
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

**After task-breakdown-agent completes:**

**MANDATORY ACTIONS:**
1. Read the ACTUAL task data from `.claude/memory/task-index.json`
2. Display the hierarchy using this tree format template (replace [PLACEHOLDERS] with actual values from the JSON):

```
📋 WBS Hierarchy ([FEATURE_COUNT] features, [TASK_COUNT] tasks):

Epic [EPIC_ID]: [EPIC_TITLE]
├── Feature [FEATURE_1_ID]: [FEATURE_1_TITLE]
│   ├── Task [TASK_ID]: [TASK_TITLE] ([AGENT_NAME])
│   └── Task [TASK_ID]: [TASK_TITLE] ([AGENT_NAME])
├── Feature [FEATURE_2_ID]: [FEATURE_2_TITLE]
│   ├── Task [TASK_ID]: [TASK_TITLE] ([AGENT_NAME])
│   └── Task [TASK_ID]: [TASK_TITLE] ([AGENT_NAME])
└── Feature [FEATURE_3_ID]: [FEATURE_3_TITLE]
    ├── Task [TASK_ID]: [TASK_TITLE] ([AGENT_NAME])
    └── Task [TASK_ID]: [TASK_TITLE] ([AGENT_NAME])

Starting execution...
```

**For reference only, here is how the format looks with example data (DO NOT output this - output the ACTUAL data from task-index.json using the format above):**
```
📋 WBS Hierarchy (3 features, 6 tasks):

Epic 1: Todo Application
├── Feature 1.1: Project Setup
│   ├── Task 1.1.1: Write infrastructure tests (test-first-agent)
│   └── Task 1.1.2: Setup Vite + React + TypeScript (infrastructure-implementation-agent)
├── Feature 1.2: Todo List Component
│   ├── Task 1.2.1: Write TodoList tests (test-first-agent)
│   └── Task 1.2.2: Implement TodoList component (component-implementation-agent)
└── Feature 1.3: Add Todo Feature
    ├── Task 1.3.1: Write AddTodo tests (test-first-agent)
    └── Task 1.3.2: Implement AddTodo component (component-implementation-agent)

Starting execution...
```

**Display the ACTUAL hierarchy from task-index.json using this tree format, NOT the example above.**

### STEP 2: Find Next Available Task

**ACTION:** Use the `find_next_available_task` helper function to find the first pending leaf task with satisfied dependencies.

**REQUIRED STEPS:**

1. **Source the helper library and call the function:**
   ```bash
   source .claude/memory/lib/wbs-helpers.sh && find_next_available_task
   ```

2. **The function will return:**
   - Task ID (e.g., "1.1.1") if an available task is found
   - Exit code 1 if no tasks available

**Function behavior:**
- Finds pending leaf tasks (no children)
- Validates all dependencies have status="done"
- Returns first available task ID

**If you need details on the task system, consult:**
- `.claude-collective/task-system.md` - Complete task system documentation
- `.claude/memory/lib/wbs-helpers.sh` - Available helper functions

### STEP 3: Deploy Agent for Task

**ACTION:** Read task details from task-index.json and deploy agent with complete task context.

**MANDATORY STEPS:**

1. **Read the task details** from task-index.json:
   ```bash
   jq '.tasks[] | select(.id=="TASK_ID")' .claude/memory/task-index.json
   ```

2. **Extract key information**:
   - Task ID (e.g., "1.1.1")
   - Title (e.g., "Write HTML structure tests")
   - Agent (e.g., "test-first-agent")
   - Deliverables array (e.g., ["tests/index.test.html"])
   - Dependencies array (if any)
   - Parent feature ID (e.g., "1.1")

3. **Write .current-task marker** before deployment:
   ```bash
   mkdir -p .claude/memory/markers && echo "TASK_ID" > .claude/memory/markers/.current-task
   ```
   This ensures SubagentStop hook can reliably extract task ID.

4. **Deploy agent via Task tool** with complete context in prompt:

**CRITICAL FORMAT - Agents depend on this information:**
```
Task ID: [TASK_ID]
Title: [TASK_TITLE]
Parent Feature: [PARENT_ID]
Deliverables Expected: [LIST_OF_FILES]
Dependencies Completed: [LIST_OF_DEPENDENCY_IDS or "none"]

[USER_REQUEST_CONTEXT if first task, otherwise brief feature description]
```

**Example for task 1.1.1:**
```
Task ID: 1.1.1
Title: Write HTML structure tests
Parent Feature: 1.1
Deliverables Expected: tests/index.test.html
Dependencies Completed: none

User requested: "Build a simple HTML todo app"
Create tests for the HTML structure component.
```

**Example for task 1.1.2 (with dependency):**
```
Task ID: 1.1.2
Title: Implement HTML structure
Parent Feature: 1.1
Deliverables Expected: index.html
Dependencies Completed: 1.1.1

Implement the HTML structure to make tests pass.
Tests are at: tests/index.test.html
```

The PreToolUse hook will automatically validate and ALLOW or DENY deployment.

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

**🚨 CRITICAL: Hub Claude MUST NOT manually update task-index.json**
- ❌ DO NOT run `jq` commands to change task status
- ❌ DO NOT run `memory_update_json` to modify task-index.json
- ❌ DO NOT manually mark tasks as "done" or "in-progress"
- ✅ ONLY SubagentStop hook updates task status
- ✅ Wait for hook to run automatically when agent completes

### STEP 6: Loop Until Complete

Read updated task-index.json, find next task, deploy agent. Repeat until all leaf tasks done.

### STEP 7: Final Marker Check (MANDATORY)

**After all leaf tasks complete, BEFORE declaring workflow done:**

```bash
ls .claude/memory/markers/.needs-* 2>/dev/null
```

**If markers exist:**
1. Read marker filename to identify required action:
   - `.needs-validation-X.Y` → Deploy `@tdd-validation-agent` for feature X.Y
   - `.needs-browser-testing-X.Y` → Deploy `@chrome-devtools-testing-agent` for feature X.Y
2. Deploy the appropriate agent via Task tool
3. After agent completes, repeat marker check (STEP 7 again)
4. Continue until NO markers remain

**CRITICAL:** Only declare workflow complete when:
- All leaf tasks status = "done" AND
- `.claude/memory/markers/` contains NO `.needs-*` files

### Handling SubagentStop Denials

**If SubagentStop hook denies agent completion:**

1. Agent will show error: "Task operation blocked by hook: [reason]"
2. Read the denial reason carefully
3. **If reason says "Deploy @agent-name":**
   - Deploy that agent immediately via Task tool
   - After that agent completes and marker is removed
   - RE-DEPLOY the originally denied agent
   - Second attempt should succeed (marker removed, hook allows)
4. Continue workflow from where it was interrupted

**Example denial flow:**
```
tdd-validation-agent → denied by SubagentStop (browser marker exists)
→ Deploy chrome-devtools-testing-agent (removes marker)
→ RE-DEPLOY tdd-validation-agent (now succeeds)
→ Continue to next task
```

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

## Output Format

**MANDATORY: You MUST follow the van-output-template.md format EXACTLY - this is NOT optional.**

@./.claude-collective/van-output-template.md

**REQUIRED SECTIONS (follow template precisely):**
1. **STEP 1**: Task Breakdown with WBS tree (use EXACT tree format from template)
2. **STEP 2**: Finding Next Available Task (after EVERY task completion)
3. **STEP 3**: Deploying Agent (for each task, with RED/GREEN phase labels)
4. **Hook Activity Summary**: After EVERY task (PreToolUse, TDD Gate, SubagentStop, WBS Rollup)
5. **Progress Update**: After EVERY feature completion (with progress bar)
6. **Final Completion**: When epic done (with full statistics, deliverables, features)

**CONSISTENCY REQUIREMENTS:**
- Separator lines: ALWAYS exactly 43 `━` characters
- Progress bars: ALWAYS 20 blocks (`█` filled + `░` empty)
- Tree format: EXACTLY as shown in template (no extra IDs, no markdown bold)
- Hook summaries: MANDATORY after each task
- NO extra explanatory text beyond what template specifies

**Execute each STEP:**
- Deploy agents via Task tool
- Run actual commands
- Read actual files
- Display progress using the template format EXACTLY

The deterministic task system with TDD enforcement is now active.
