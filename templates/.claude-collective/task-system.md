# Memory-Based Task System

**Purpose**: Deterministic task breakdown and execution using file-based memory system.

**Imported by**: `CLAUDE.md` via `@./.claude-collective/task-system.md`

---

## Overview

The collective uses a deterministic, file-based task management system that replaces external dependencies with built-in memory operations.

**Key Principles**:
- ✅ **Deterministic**: Same input = same tasks every time
- ✅ **File-based**: All state in `.claude/memory/task-index.json`
- ✅ **Hook-enforced**: Workflow validation via PreToolUse and SubagentStop hooks
- ✅ **Test-first**: Tests always created before implementation
- ✅ **3-tier hierarchy**: Epic → Features → Tasks (consistent structure)
- ✅ **Browser testing**: ON by default for UI projects (opt-out available)

---

## Browser Testing Configuration

### Overview

**Browser testing is ENABLED by default** for UI/browser-based projects.

When enabled, the system automatically:
- Validates CSS files load correctly in browser
- Tests user interactions (clicks, form submissions, navigation)
- Verifies DOM state changes as expected
- Takes screenshots for visual validation
- Checks for JavaScript errors in console

**Performance Impact**: Adds ~30-60 seconds per UI task

---

### When Browser Testing Runs

**Automatic Trigger** when these keywords detected:
- UI frameworks: `html`, `css`, `react`, `vue`, `svelte`, `angular`, `nextjs`
- UI elements: `form`, `button`, `input`, `component`, `modal`, `dropdown`
- UI concepts: `ui`, `interface`, `dashboard`, `page`, `layout`, `responsive`
- User actions: `login`, `signup`, `authentication`, `interactive`

**Workflow** (Hook-Enforced, 100% Deterministic):
```
1. task-breakdown-agent detects UI → shows browser testing notification
2. component-implementation-agent completes feature tasks
3. SubagentStop hook creates .needs-validation-{FEATURE_ID} marker
4. PreToolUse hook BLOCKS all agent deployments except tdd-validation-agent
5. tdd-validation-agent scans code for UI → creates .needs-browser-testing-{FEATURE_ID} marker
6. PreToolUse hook BLOCKS all agent deployments except chrome-devtools-testing-agent (if browserTesting=true)
7. chrome-devtools-testing-agent validates in browser → verifies CSS + interactions
```

**Enforcement Mechanism**:
- Physical marker files (.needs-validation-*, .needs-browser-testing-*) block workflow
- Hub Claude has NO CHOICE - hooks physically prevent skipping validation
- NOT based on LLM decisions or agent suggestions
- 100% deterministic - same config = same behavior every time

---

### How to Disable Browser Testing

**Create config file** before starting workflow:

```bash
# Create .claude/memory/config.json
cat > .claude/memory/config.json <<'EOF'
{
  "browserTesting": false,
  "cssValidation": false
}
EOF
```

**Or use echo**:
```bash
echo '{"browserTesting": false}' > .claude/memory/config.json
```

**Config Options**:
```json
{
  "browserTesting": true,     // Enable/disable browser validation (default: true)
  "cssValidation": true,       // Enable/disable CSS-specific checks (default: true)
  "visualTesting": false,      // Enable/disable screenshot comparison (future)
  "screenshotOnFailure": true  // Capture screenshots when tests fail (default: true)
}
```

---

### When to Disable Browser Testing

**Disable for**:
- Backend APIs (no UI)
- CLI tools (terminal-based)
- Libraries/SDKs (no browser dependency)
- Quick prototypes (fast iteration)

**Keep enabled for**:
- React/Vue/Svelte applications (UI components)
- HTML/CSS/JavaScript projects (browser-based)
- Forms, dashboards, interactive UIs
- Production-ready applications

---

## Task Hierarchy (Mandatory Structure)

### 3-Tier System (Always)

```
Epic (Level 1)
├── Feature (Level 2)
│   ├── Task: Write tests (Level 3)
│   └── Task: Implement (Level 3)
└── Feature (Level 2)
    ├── Task: Write tests (Level 3)
    └── Task: Implement (Level 3)
```

**Rules**:
1. **Epic** = Single top-level container for entire request
2. **Features** = 3-7 major components (based on complexity)
3. **Tasks** = Atomic work units (tests + implementation pairs)

**IDs**: Use hierarchical numbering: `1` (epic), `1.1` (feature), `1.1.1` (task)

---

## Workflows

### Simple Natural Language (Primary)

**User Request**:
```bash
/van build me a simple HTML todo app
```

**What Happens**:
1. Hub Claude analyzes request
2. Deploys `task-breakdown-agent` with natural language description
3. Agent infers technology stack (HTML, CSS, JS)
4. Creates 3 features, 6 tasks in task-index.json
5. Hub Claude executes first leaf task

**User provides**: Description in plain English
**No PRD required**: Agent infers structure

---

### PRD-Based (Optional for Complex Projects)

**User Request**:
```bash
/van build application with this PRD document
```

**What Happens**:
1. Hub Claude analyzes request (detects PRD)
2. Deploys `prd-parser-agent` to extract requirements
3. Deploys `task-breakdown-agent` with parsed data
4. Creates 7+ features, 20+ tasks in task-index.json
5. Hub Claude executes first leaf task

**User provides**: Formal PRD document
**PRD required**: For complex multi-technology projects

---

## Test-First Pattern (Enforced)

**Every feature MUST have**:
- Task X.1: "Write [feature] tests"
- Task X.2: "Implement [feature]"
- Dependency: X.2 depends on X.1

**Example**:
```json
{
  "id": "1.1.1",
  "type": "task",
  "title": "Write HTML structure tests",
  "agent": "test-first-agent",
  "deliverables": ["tests/index.test.html"]
},
{
  "id": "1.1.2",
  "type": "task",
  "title": "Implement HTML structure",
  "dependencies": ["1.1.1"],
  "agent": "component-implementation-agent",
  "deliverables": ["index.html"]
}
```

**TDD Hook enforces**: Cannot write implementation (1.1.2) until tests (1.1.1) exist.

---

## Agent Assignment (Deterministic)

Tasks are automatically assigned to specialist agents based on type:

| Task Type | Agent |
|-----------|-------|
| Write tests | `test-first-agent` |
| UI components | `component-implementation-agent` |
| Business logic | `feature-implementation-agent` |
| Infrastructure | `infrastructure-implementation-agent` |
| Styling | `component-implementation-agent` |

**Assignment happens**: During task breakdown by `task-breakdown-agent`

---

## task-index.json Schema

### Complete Example

```json
{
  "version": "1.0.0",
  "tasks": [
    {
      "id": "1",
      "type": "epic",
      "title": "Todo Application",
      "status": "in-progress",
      "parent": null,
      "children": ["1.1", "1.2", "1.3"],
      "progress": {
        "completed": 1,
        "total": 3
      }
    },
    {
      "id": "1.1",
      "type": "feature",
      "title": "HTML Structure",
      "status": "done",
      "parent": "1",
      "children": ["1.1.1", "1.1.2"],
      "dependencies": [],
      "progress": {
        "completed": 2,
        "total": 2
      }
    },
    {
      "id": "1.1.1",
      "type": "task",
      "title": "Write HTML structure tests",
      "status": "done",
      "parent": "1.1",
      "children": [],
      "dependencies": [],
      "deliverables": ["tests/index.test.html"],
      "agent": "test-first-agent"
    },
    {
      "id": "1.1.2",
      "type": "task",
      "title": "Implement HTML structure",
      "status": "done",
      "parent": "1.1",
      "children": [],
      "dependencies": ["1.1.1"],
      "deliverables": ["index.html"],
      "agent": "component-implementation-agent"
    }
  ]
}
```

### Field Definitions

**Required Fields (All Tasks)**:
- `id` - Hierarchical ID (1, 1.1, 1.1.1)
- `type` - epic | feature | task
- `title` - Human-readable name
- `status` - pending | in-progress | done
- `parent` - Parent task ID (null for epic)
- `children` - Array of child IDs

**Task-Specific Fields**:
- `dependencies` - Array of task IDs that must complete first
- `deliverables` - Array of file paths expected
- `agent` - Agent name responsible for implementation

**Container-Specific Fields** (Epic/Feature):
- `progress` - Object with `{completed, total}` counts

---

## Hook Enforcement

### PreToolUse Hook (pre-agent-deploy.sh)

**Validates before agent deployment**:
1. ✅ Task ID is valid (exists in task-index.json)
2. ✅ Task is leaf (no children)
3. ✅ Dependencies satisfied (all deps have status=done)
4. ✅ Task marked as in-progress

**If validation fails**: Hook denies with reason, Hub Claude cannot deploy agent

---

### TDD Hook (tdd-gate.sh)

**Validates before Write/Edit operations**:
1. ✅ Is this a test file? → Allow
2. ✅ Do tests exist for this implementation file? → Allow
3. ❌ No tests exist → Deny with "TDD violation" message

**Enforces test-first**: Cannot implement until tests written

---

### SubagentStop Hook (subagent-validation.sh)

**Validates on agent completion**:
1. ✅ Tests pass (runs test command)
2. ✅ Deliverables exist (checks file paths)
3. ✅ Updates task status to "done"
4. ✅ Triggers WBS rollup (updates parent progress)
5. ✅ Creates validation markers when features complete

**If validation fails**: Agent cannot complete, status stays in-progress

**Marker Creation Logic**:
- Detects when implementation agent completes (agent name matches `*-implementation-agent`)
- Checks if all sibling tasks in feature are done
- If feature complete: creates `.needs-validation-{FEATURE_ID}` marker
- This marker physically blocks workflow until validation agent deployed

---

### Marker-Based Validation Enforcement

**How It Works**:

1. **Feature Completion Detection**:
   - SubagentStop hook checks if last task in feature just completed
   - Creates `.claude/memory/markers/.needs-validation-{FEATURE_ID}` file
   - This marker is a physical file that blocks workflow

2. **Validation Agent Enforcement**:
   - PreToolUse hook checks for `.needs-validation-*` markers before deploying agents
   - If marker exists AND agent != tdd-validation-agent: DENY deployment
   - If marker exists AND agent == tdd-validation-agent: ALLOW + remove marker
   - Hub Claude physically cannot skip validation

3. **Browser Testing Enforcement** (if browserTesting=true):
   - tdd-validation-agent scans code for UI elements (`<form>`, event handlers, etc.)
   - If UI detected: creates `.needs-browser-testing-{FEATURE_ID}` marker
   - PreToolUse hook checks for browser testing marker
   - If marker exists AND agent != chrome-devtools-testing-agent: DENY deployment
   - If marker exists AND agent == chrome-devtools-testing-agent: ALLOW + remove marker

**Result**: 100% deterministic validation enforcement. No LLM decision-making. Physical file gates.

---

## Inspecting Task State

### View All Tasks

```bash
cat .claude/memory/task-index.json | jq '.tasks[] | {id, title, status}'
```

### View Current Progress

```bash
cat .claude/memory/task-index.json | jq '.tasks[] | select(.status=="in-progress")'
```

### View Task Hierarchy

```bash
cat .claude/memory/task-index.json | jq '.tasks[] | {id, parent, children}'
```

### View Dependencies

```bash
cat .claude/memory/task-index.json | jq '.tasks[] | select(.dependencies | length > 0) | {id, dependencies}'
```

### View Epic Progress

```bash
cat .claude/memory/task-index.json | jq '.tasks[] | select(.type=="epic") | {id, title, progress}'
```

---

## Memory Operations

### Writing Tasks (Deterministic)

**From bash (hooks or agents)**:
```bash
source .claude/memory/lib/memory.sh

# Create task-index.json
memory_write ".claude/memory/task-index.json" "$json_content"
```

**From agent (via Bash tool)**:
```bash
# Agent calls memory_write via bash
source .claude/memory/lib/memory.sh && memory_write ".claude/memory/task-index.json" "$(cat <<'EOF'
{
  "version": "1.0.0",
  "tasks": [...]
}
EOF
)"
```

---

### Updating Task Status

**Via memory_update_json**:
```bash
source .claude/memory/lib/memory.sh

# Mark task as done
memory_update_json ".claude/memory/task-index.json" \
  '(.tasks[] | select(.id=="1.1.1")).status = "done"'
```

**Hooks use this**: SubagentStop hook updates status automatically

---

## WBS Rollup (Automatic)

**When leaf task completes**:
1. SubagentStop hook marks task as "done"
2. WBS helper recalculates parent feature progress
3. If all children done → mark feature as "done"
4. Recalculate epic progress
5. If all children done → mark epic as "done"

**Result**: Parent task progress updates automatically when children complete.

**Example**:
```
Task 1.1.1 done → Feature 1.1 progress 1/2
Task 1.1.2 done → Feature 1.1 done, Epic 1 progress 1/3
```

---

## Complexity Scaling

**Simple projects** (3-5 tasks):
- 1 epic
- 2-3 features
- 4-6 tasks (test + implementation pairs)

**Medium projects** (10-20 tasks):
- 1 epic
- 4-5 features
- 12-20 tasks

**Complex projects** (30+ tasks):
- 1 epic
- 6-7 features
- 30-50 tasks
- May include sub-features (1.1.1 type="feature")

**Agent decides**: Based on request complexity and technology count

---

## User Experience

### What Users Do

1. **Describe feature**: `/van build a todo app`
2. **Wait**: System creates tasks automatically
3. **Review**: Progress shown via task completion messages
4. **Inspect** (optional): View task-index.json if needed

### What Users DON'T Do

- ❌ Write tasks manually
- ❌ Update task status
- ❌ Manage dependencies
- ❌ Assign agents
- ❌ Track progress

**System handles everything automatically.**

---

## Determinism Guarantees

**Same request → Same tasks**:
- Task breakdown follows fixed rules
- Agent assignment is rule-based
- Dependencies computed deterministically
- No LLM variance in structure

**Reproducible**:
- Can call task-breakdown-agent multiple times
- Same PRD produces identical task hierarchy
- Tests always before implementation

**Verifiable**:
- task-index.json is plain JSON
- Hooks log all decisions (if logging enabled)
- Complete audit trail available

---

## Integration with Collective

### Hub Claude Role

1. **Receives user request** via `/van`
2. **Decides workflow**: Simple or PRD-based
3. **Deploys task-breakdown-agent** with appropriate input
4. **Waits for task-index.json** to be created
5. **Reads first leaf task** from task-index.json
6. **Deploys implementation agent** for that task
7. **Repeats** until all tasks complete

**Hub does NOT**:
- ❌ Create tasks itself (delegates to task-breakdown-agent)
- ❌ Implement directly (delegates to specialist agents)
- ❌ Update task status (hooks do this)

---

### Agent Specialization

**task-breakdown-agent**:
- **Input**: Natural language OR parsed PRD
- **Output**: task-index.json
- **Responsibility**: Task hierarchy creation

**Implementation agents**:
- **Input**: Task ID from task-index.json
- **Output**: Code + tests
- **Responsibility**: Execute single task

**Validation agents**:
- **Input**: Completed work
- **Output**: Pass/fail
- **Responsibility**: Quality gates

**Clean separation of concerns.**

---

## Logging (Optional)

Enable deterministic logging to capture all hook decisions:

```bash
/van logging enable
```

**Logs captured**:
- Hook decisions (allow/deny with reasons)
- Memory operations (writes, updates)
- Task status transitions
- WBS rollups

**View logs**:
```bash
cat .claude/memory/logs/current/hooks.jsonl | jq
cat .claude/memory/logs/current/memory.jsonl | jq
```

**Useful for**: Debugging, research, understanding workflow

---

## Summary

**Memory-based task system provides**:
- ✅ Deterministic task breakdown
- ✅ Automatic workflow enforcement via hooks
- ✅ Test-first methodology (enforced)
- ✅ Hierarchical task structure (epic → features → tasks)
- ✅ Progress tracking (automatic WBS rollup)
- ✅ Simple user experience (natural language)
- ✅ Complex project support (PRD-based)
- ✅ Complete audit trail (optional logging)
- ✅ Zero external dependencies

**Users describe features, system handles execution.**
