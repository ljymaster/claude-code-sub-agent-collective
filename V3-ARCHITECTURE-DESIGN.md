# V3.0 Architecture Design Document

**Status**: Design Phase
**Last Updated**: 2025-10-01
**Purpose**: Complete architectural specification for v3.0 migration leveraging Claude 4.5 Sonnet capabilities

---

## Executive Summary

V3.0 represents a fundamental architectural shift from v2.x orchestration patterns to native Claude 4.5 intelligence. The core innovation: **Hub Claude + Extended Thinking + Native Memory + Hooks = Deterministic Self-Orchestrating Collective**.

**Key Changes:**
- Remove ALL orchestration agents (Hub Claude replaces them)
- Remove TaskMaster dependency (native memory replaces it)
- Remove redundant testing agents (chrome-devtools only)
- Implement memory-based state management
- Enforce determinism through hooks

---

## Section 1: What Changed from v2.x

### Removed Components

#### Orchestration Agents (Hub Claude Replaces)
- ❌ **routing-agent.md** - Hub Claude routes natively via extended thinking
- ❌ **task-orchestrator.md** - Hub Claude + memory manages tasks
- ❌ **workflow-agent.md** - Hub Claude sequences complex workflows
- ❌ **task-executor.md** - Hub Claude deploys agents directly

**Rationale**: Claude 4.5 Sonnet's intelligence eliminates need for explicit orchestration layer. Hub Claude reads agent completion reports, uses extended thinking for complex decisions, and deploys next agent via Task tool.

#### Redundant Testing Agent
- ❌ **functional-testing-agent.md** - Uses Playwright MCP (v2.x artifact)

**Rationale**: chrome-devtools-testing-agent provides browser testing via Chrome DevTools MCP. Single browser testing solution prevents confusion.

#### External Dependencies
- ❌ **TaskMaster MCP integration** - Removed entirely
- ❌ **TaskMaster references in agents** - All stripped out
- ❌ **TaskMaster commands** - Removed from templates

**Rationale**: Native memory tool provides superior state management without external dependencies. Users can inspect/edit state directly as files.

### Architecture Transformation

**v2.x Pattern:**
```
User Request → routing-agent → task-orchestrator → task-executor → implementation agents
```

**v3.0 Pattern:**
```
User Request → Hub Claude (extended thinking) → implementation agents
                    ↓
                Memory queries/updates
                    ↓
                Hook validation gates
```

---

## Section 2: Claude 4.5 Core Capabilities Leveraged

### Extended Thinking
**What**: Step-by-step internal reasoning before delivering response
**Use Case**: Complex routing decisions, dependency analysis, workflow sequencing
**How**: Transparent thinking blocks show Hub Claude's decision process

**Example**:
```
User: "Build React app with Node.js API and PostgreSQL"

Hub Claude (extended thinking):
1. Analyze complexity: 3 technology stacks
2. Identify dependencies: infrastructure → parallel implementations
3. Determine sequence: research → infra → (component + feature) → validation
4. Deploy research-agent first
```

### Native Sub-Agent System
**What**: Agents operate in separate context windows with specialized tools
**Use Case**: Task-specific workflows with controlled tool access
**How**: Agent definitions with YAML frontmatter specify tools, model, description

**Key Features:**
- Automatic delegation based on task description
- Explicit invocation via @agent-name
- Tool access restrictions enforce single responsibility
- Independent context preserves focus

### Memory Tool (Native Claude 4.5 Feature)
**What**: Create/read/update/delete files in dedicated memory directory
**Persistence**: Across conversation sessions
**Storage**: Developer-managed infrastructure
**Operations**:
- `create_memory(path, content)` - Create new file
- `read_memory(path)` - Read existing file
- `update_memory(path, content)` - Update file contents
- `delete_memory(path)` - Remove file

**Use Case**: Persistent state management, task tracking, validation results

**STATUS**: ⚠️ Verify availability in Claude Code CLI (documented for API use)

### Enhanced Context & Reasoning
- 200k context window (1M in beta)
- Better instruction following
- Improved multi-turn consistency
- Parallel tool use

---

## Section 3: NEW State Management via Memory

### 🚧 STATUS: REQUIRES DETAILED DESIGN & IMPLEMENTATION

This section outlines the proposed memory-based state management system. **Full specification needed before implementation.**

### Proposed Memory Schema

#### `memory/tasks.json`
```json
{
  "version": "3.0.0",
  "tasks": [
    {
      "id": "1",
      "title": "Build login form",
      "status": "in-progress",
      "phase": "GREEN",
      "dependencies": [],
      "subtasks": [
        {
          "id": "1.1",
          "title": "Write tests",
          "status": "done",
          "agent": "test-first-agent",
          "completedAt": "2025-10-01T10:30:00Z"
        },
        {
          "id": "1.2",
          "title": "Implement component",
          "status": "in-progress",
          "agent": "component-implementation-agent",
          "startedAt": "2025-10-01T10:35:00Z"
        }
      ]
    }
  ]
}
```

#### `memory/workflow-state.json`
```json
{
  "currentWorkflow": "simple-tdd",
  "phase": "GREEN",
  "agentsDeployed": ["test-first-agent", "component-implementation-agent"],
  "lastAgentCompleted": "test-first-agent",
  "nextAgentSuggested": "tdd-validation-agent",
  "timestamp": "2025-10-01T10:35:00Z"
}
```

#### `memory/validation-results.json`
```json
{
  "taskId": "1.2",
  "testsPass": true,
  "testResults": {
    "total": 3,
    "passed": 3,
    "failed": 0,
    "output": "All tests passing"
  },
  "deliverablesExist": true,
  "deliverables": [
    "src/LoginForm.js",
    "src/LoginForm.test.js"
  ],
  "validatedAt": "2025-10-01T10:40:00Z"
}
```

#### `memory/agent-history.json`
```json
{
  "deployments": [
    {
      "agent": "test-first-agent",
      "deployedAt": "2025-10-01T10:25:00Z",
      "completedAt": "2025-10-01T10:30:00Z",
      "outcome": "success",
      "suggestion": "Deploy component-implementation-agent for GREEN phase"
    }
  ]
}
```

### Hub Claude Memory Operations

**Query State:**
```javascript
// Hub Claude reads current state
const tasks = read_memory("tasks.json");
const workflow = read_memory("workflow-state.json");

// Extended thinking: Analyze dependencies, determine next agent
// Deploy agent via Task tool
```

**Update After Validation:**
```javascript
// After SubagentStop hook validates
update_memory("tasks.json", {
  // Mark subtask complete
  tasks[0].subtasks[0].status = "done"
});

update_memory("workflow-state.json", {
  phase: "REFACTOR",
  lastAgentCompleted: "component-implementation-agent"
});

update_memory("validation-results.json", {
  testsPass: true,
  deliverables: [...]
});
```

### Hook Integration with Memory

**SubagentStop Hook Flow:**
```bash
#!/bin/bash
# .claude/hooks/subagent-validation.sh

# 1. Read current state
TASKS=$(read_memory "tasks.json")
WORKFLOW=$(read_memory "workflow-state.json")

# 2. Run validation
npm test > test_output.txt
TEST_STATUS=$?

# 3. Check deliverables
FILES_EXIST=$(check_deliverables)

# 4. Update memory with results
update_memory "validation-results.json" "{
  \"testsPass\": $([ $TEST_STATUS -eq 0 ] && echo true || echo false),
  \"deliverablesExist\": $FILES_EXIST
}"

# 5. If all valid, update task status
if [ $TEST_STATUS -eq 0 ] && [ $FILES_EXIST = true ]; then
  update_memory "tasks.json" "{ /* mark complete */ }"
  exit 0  # Allow Hub to proceed
else
  exit 2  # Block Hub until fixed
fi
```

### Open Design Questions

1. **Memory Tool Availability**: Is `create_memory/read_memory/update_memory/delete_memory` available in Claude Code CLI?
   - If YES: Use native tool
   - If NO: Implement with Write/Read to `.claude/memory/` directory

2. **Concurrent Access**: How to handle parallel agents updating memory simultaneously?
   - File locking mechanism?
   - Atomic operations?
   - Queue-based updates?

3. **Error Recovery**: What happens if memory becomes corrupted?
   - Backup/restore mechanism?
   - Validation checksums?
   - Rollback to previous state?

4. **Schema Versioning**: How to handle schema changes across versions?
   - Migration scripts?
   - Backward compatibility?

5. **Hook-Memory Interface**: How do bash scripts invoke memory operations?
   - Via Claude Code CLI commands?
   - Direct file writes to .claude/memory/?
   - API calls to MCP server?

6. **Performance**: Memory file sizes, read/write frequency optimization
   - Incremental updates vs full rewrites?
   - Compression for large histories?

---

## Section 4: Deterministic Workflows via Hooks

### Hook Architecture

Hooks enforce determinism by creating **validation gates** between non-deterministic agent executions.

**Pattern**:
```
Agent completes → SubagentStop hook fires
                       ↓
              Hook validates work
              (tests pass, deliverables exist)
                       ↓
              Hook updates memory
              (mark task complete, advance phase)
                       ↓
              ONLY THEN Hub proceeds
                       ↓
        Hub reads memory → decides next agent
```

### SubagentStop Hook (New)

**Purpose**: Validate agent completion before Hub continues

**Validation Checklist**:
1. ✅ Tests pass (`npm test` returns 0)
2. ✅ Deliverables exist on filesystem
3. ✅ Memory updated with completion state
4. ✅ No errors in agent output

**Hook Implementation**: `templates/hooks/subagent-validation.sh`

**Exit Codes**:
- `0` - Validation passed, allow Hub to proceed
- `2` - Validation failed, block Hub (agent must fix issues)

**Output**: JSON with validation results

### PreToolUse(Task) Hook (New)

**Purpose**: Validate dependencies before deploying agent

**Validation Checklist**:
1. ✅ Previous phase complete (check memory)
2. ✅ Dependencies satisfied (if task-based)
3. ✅ Prerequisites met (e.g., infrastructure ready)
4. ✅ No blocking errors

**Hook Implementation**: `templates/hooks/pre-agent-deploy.sh`

**Exit Codes**:
- `0` - Dependencies satisfied, allow deployment
- `2` - Dependencies not met, block deployment

### Existing Hooks (Keep)

**PreToolUse(Write|Edit) - TDD Gate**:
- Block implementation until tests exist
- Enforce test-first development
- Exit 2 if no test file found

**PreToolUse(Bash) - Block Destructive Commands**:
- Prevent `rm -rf /`, `dd`, etc.
- Log blocked commands
- Exit 2 for dangerous operations

**SessionStart**:
- Display initialization message
- Load collective framework

### Hook Configuration

**File**: `templates/settings.json.template`

```json
{
  "hooks": {
    "SubagentStop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/subagent-validation.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Task",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/pre-agent-deploy.sh"
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/tdd-gate.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/block-destructive-commands.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-init.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Section 5: Hub Claude Orchestration Patterns

### Pattern 1: Simple TDD Workflow (/van command)

**Use Case**: Single component/feature request

**Example**: "Build login form"

**Flow**:
```
User: "Build login form"
    ↓
Hub Claude (extended thinking):
- Recognize TDD workflow pattern
- Initialize memory: {phase: "RED", component: "LoginForm"}
    ↓
Deploy test-first-agent (RED phase)
    ↓
SubagentStop hook validates:
- Tests created ✅
- Tests failing ✅ (expected)
- Update memory: {phase: "GREEN", testsExist: true}
    ↓
Hub reads agent suggestion: "Deploy component-implementation-agent"
    ↓
Deploy component-implementation-agent (GREEN phase)
    ↓
SubagentStop hook validates:
- Tests pass ✅
- Implementation exists ✅
- Update memory: {phase: "REFACTOR", testsPass: true}
    ↓
Hub reads agent suggestion: "Deploy tdd-validation-agent"
    ↓
Deploy tdd-validation-agent (REFACTOR phase)
    ↓
Agent scans for UI/DOM code:
- Detects <form>, <input>, event handlers
- Suggests: "Deploy chrome-devtools-testing-agent"
    ↓
Deploy chrome-devtools-testing-agent (BROWSER phase)
    ↓
SubagentStop hook validates:
- Browser tests complete ✅
- Screenshots captured ✅
- Update memory: {phase: "COMPLETE"}
    ↓
Hub reports: "All phases complete ✅"
```

**Determinism**: Hooks block between phases until validation passes

### Pattern 2: Complex Multi-Technology Workflow

**Use Case**: Multiple technologies, parallel development

**Example**: "Build React app with Node.js API and PostgreSQL"

**Flow**:
```
Hub Claude (extended thinking):
1. Analyze complexity: 3 tech stacks (React, Node.js, PostgreSQL)
2. Identify dependencies: Infrastructure → Parallel implementations
3. Determine sequence:
   - Research all technologies
   - Setup infrastructure
   - Deploy component-agent + feature-agent in parallel
   - Validation after both complete
    ↓
Initialize memory:
{
  "workflow": "complex-multi-tech",
  "technologies": ["React", "Node.js", "PostgreSQL"],
  "phases": ["research", "infrastructure", "parallel-implementation", "validation"]
}
    ↓
Phase 1: Research
- Deploy research-agent
- SubagentStop validates research complete
- Update memory: {currentPhase: "infrastructure"}
    ↓
Phase 2: Infrastructure
- Deploy infrastructure-implementation-agent
- SubagentStop validates: PostgreSQL configured, build tools ready
- Update memory: {currentPhase: "parallel-implementation"}
    ↓
Phase 3: Parallel Implementation
- Deploy component-implementation-agent (React frontend)
- Deploy feature-implementation-agent (Node.js API)
- SubagentStop hooks validate BOTH complete before proceeding
- Update memory: {frontendDone: true, backendDone: true}
    ↓
Phase 4: Validation
- Deploy tdd-validation-agent
- Validate integration tests pass
- Update memory: {workflow: "complete"}
```

**Determinism**: Hooks ensure parallel agents both finish before validation

### Pattern 3: Incremental Feature Development

**Use Case**: Adding feature to existing codebase

**Example**: "Add password reset to login system"

**Flow**:
```
Hub Claude:
1. Read memory: Check existing login system state
2. Extended thinking: Determine modification points
3. Deploy test-first-agent: Write password reset tests
4. Deploy component-implementation-agent: Implement feature
5. Deploy tdd-validation-agent: Ensure no regressions
6. Update memory: Track feature addition
```

### Hub Decision-Making Process

**Every agent deployment follows this pattern:**

1. **Query Memory**:
   ```javascript
   const state = read_memory("workflow-state.json");
   const tasks = read_memory("tasks.json");
   ```

2. **Extended Thinking**:
   ```
   Thinking: Current phase is GREEN, tests exist
   Thinking: Agent suggested component-implementation-agent
   Thinking: No dependencies blocking deployment
   Thinking: Deploy component-implementation-agent
   ```

3. **Deploy Agent**:
   ```javascript
   Task(subagent_type="component-implementation-agent", prompt="...")
   ```

4. **Wait for SubagentStop Hook**:
   - Hook validates completion
   - Hook updates memory
   - Hook exits 0 (allow) or 2 (block)

5. **Read Updated Memory**:
   ```javascript
   const updatedState = read_memory("workflow-state.json");
   // Check if proceeding to next phase
   ```

6. **Repeat**

---

## Section 6: Agent Inventory & Tool Assignments

### Agents to KEEP

#### Implementation Agents (Write/Edit/Bash)
- ✅ **component-implementation-agent** - UI components (React, HTML, CSS)
- ✅ **feature-implementation-agent** - Business logic, APIs, data services
- ✅ **infrastructure-implementation-agent** - Build configs, tooling, deployment
- ✅ **polish-implementation-agent** - Performance, accessibility, refinement
- ✅ **testing-implementation-agent** - Unit tests, integration tests

**Tools**: Read, Write, Edit, MultiEdit, Bash, Glob, Grep, LS

#### Testing Agents (Specialized MCP)
- ✅ **test-first-agent** - Writes tests only (RED phase)
  - **Tools**: Read, Write, Edit, Bash, Grep, Glob
- ✅ **chrome-devtools-testing-agent** - Browser testing via Chrome DevTools MCP
  - **Tools**: Read, mcp__chrome-devtools__* (25 tools)
  - **NO**: Write, Edit, Bash, Glob, Grep ❌

#### Validation Agents (Read/Bash only, NO Write/Edit)
- ✅ **tdd-validation-agent** - Validates TDD methodology, scans for UI
  - **Tools**: Read, Bash, Grep, Glob, LS
- ✅ **quality-agent** - Code quality checks
  - **Tools**: Read, Bash, Grep, Glob, LS
- ✅ **completion-gate** - Final validation
  - **Tools**: Read, Bash, Grep, LS
- ✅ **enhanced-quality-gate** - Advanced quality checks
  - **Tools**: Read, Bash, Grep, Glob, LS
- ✅ **readiness-gate** - Deployment readiness
  - **Tools**: Read

#### Research Agents
- ✅ **research-agent** - Context7 research, web search
  - **Tools**: mcp__context7__*, WebSearch, WebFetch, Read, Grep, LS
- ✅ **prd-research-agent** - PRD analysis with research
- ✅ **prd-agent** - PRD analysis
- ✅ **prd-parser-agent** - PRD parsing
- ✅ **prd-mvp** - MVP planning

#### Specialized Agents
- ✅ **devops-agent** - DevOps tasks
- ✅ **behavioral-transformation-agent** - Behavioral updates
- ✅ **command-system-agent** - Command management
- ✅ **hook-integration-agent** - Hook system
- ✅ **npx-package-agent** - NPX package tasks
- ✅ **task-generator-agent** - Task generation
- ✅ **task-checker** - Task validation
- ✅ **van-maintenance-agent** - System maintenance
- ✅ **metrics-collection-agent** - Metrics tracking
- ✅ **dynamic-agent-creator** - Create new agents
- ✅ **enhanced-project-manager-agent** - Project management
- ✅ **test-handoff-agent** - Test handoffs

### Agents to DELETE

#### v2.x Orchestration Agents (Hub Claude Replaces)
- ❌ **routing-agent.md** - No tools, conceptual only, Hub routes natively
- ❌ **task-orchestrator.md** - Hub + memory manages tasks
- ❌ **workflow-agent.md** - Hub + extended thinking sequences work
- ❌ **task-executor.md** - Hub deploys agents directly

#### Redundant Testing Agent
- ❌ **functional-testing-agent.md** - Uses Playwright MCP (v2.x artifact)
  - Replaced by: chrome-devtools-testing-agent

**Total Deletions**: 5 agents

### Tool Assignment Audit Results

**chrome-devtools-testing-agent** ✅ FIXED:
- **Before**: Read, Write, Edit, Glob, Grep, Bash, mcp__chrome-devtools__*
- **After**: Read, mcp__chrome-devtools__* (25 tools)
- **Rationale**: Agent should ONLY use MCP tools for browser testing, no file operations or manual server setup

**Other agents**: No changes needed, tool lists appropriate for responsibilities

---

## Section 7: Documentation Updates Needed

### Root Project Documentation

#### `CLAUDE.md` (Project Root)
**Lines 29-118**: Replace "v3.0 Intelligent Agent Orchestration" section

**New Content**:
```markdown
## V3.0 Claude 4.5 Native Orchestration

**Revolutionary Architecture:**
Hub Claude + Extended Thinking + Native Memory + Hooks = Deterministic Self-Orchestrating Collective

**What Changed from v2.x:**
- Removed ALL orchestration agents (Hub Claude replaces them)
- Removed TaskMaster dependency (native memory replaces it)
- Removed Playwright testing (chrome-devtools only)
- Implemented memory-based state management
- Enforced determinism through hooks

**Hub Claude Capabilities:**
- Extended Thinking for complex routing decisions
- Native Memory for persistent state tracking
- SubagentStop hooks for deterministic validation
- Direct agent deployment via Task tool

**Three Orchestration Patterns:**
[Pattern 1, 2, 3 as outlined in Section 5]

**NO orchestration agents needed** - Claude 4.5 + Memory + Hooks = complete orchestration
```

### Template Documentation

#### `templates/.claude-collective/CLAUDE.md`
**Remove**:
- "Collective Controller" terminology
- "Hub-and-spoke coordination controller" language
- DIRECTIVE 1/2 about routing protocol
- References to orchestration agents

**Add**:
- Hub Claude native orchestration explanation
- Memory-based state management
- Hook validation gate pattern

#### `templates/commands/van.md`
**Update**:
- Clarify Hub Claude orchestrates directly (not via orchestration agents)
- Add memory queries in workflow examples
- Show hook validation gates between phases

#### `templates/.claude-collective/agents.md`
**Remove**:
- routing-agent description
- task-orchestrator description
- workflow-agent description
- task-executor description
- functional-testing-agent description

**Update**:
- Chrome devtools is ONLY browser testing agent
- Hub Claude handles all coordination

### Documentation Files to Update

**Remove Orchestration Agent References**:
- `templates/docs/Hub-Spoke-Coordination-Guide.md` - Update to Hub Claude native pattern
- `templates/docs/AGENT-INTERACTION-DIAGRAM.md` - Remove orchestration agents from diagrams
- `templates/docs/README.md` - Update architecture explanation
- `README.md` - Update to v3.0 architecture
- `USER-GUIDE.md` - Update workflow examples
- `TESTING-GUIDE.md` - Update testing patterns

**Remove ALL Playwright References**:
```bash
# Files containing Playwright:
- templates/agents/functional-testing-agent.md → DELETE FILE
- README.md → Remove mentions
- CHANGELOG.md → Historical only, no action needed
- templates/docs/RESEARCH-CACHE-PROTOCOL.md → Remove examples
- templates/docs/AGENT-INTERACTION-DIAGRAM.md → Remove from diagrams
- templates/.claude-collective/agents.md → Remove agent entry
```

**Remove ALL TaskMaster References** (except historical CHANGELOG):
```bash
# Search pattern:
grep -r "TaskMaster\|task-master\|mcp__task-master" templates/

# Update all agent files removing:
- mcp__task-master__* tools
- TaskMaster workflow references
- Task status management via TaskMaster
```

---

## Section 8: Implementation Phases

### Phase 1: Cleanup & Removal (IMMEDIATE)

**Status**: Ready to implement

#### Step 1.1: Delete Orchestration Agents
```bash
rm templates/agents/routing-agent.md
rm templates/agents/task-orchestrator.md
rm templates/agents/workflow-agent.md
rm templates/agents/task-executor.md
rm templates/agents/functional-testing-agent.md
```

#### Step 1.2: Update File Mapping
**File**: `lib/file-mapping.js`

Remove from `getAgentMapping()`:
```javascript
// DELETE these entries:
{ template: 'routing-agent.md', destination: '.claude/agents/routing-agent.md' },
{ template: 'task-orchestrator.md', destination: '.claude/agents/task-orchestrator.md' },
{ template: 'workflow-agent.md', destination: '.claude/agents/workflow-agent.md' },
{ template: 'task-executor.md', destination: '.claude/agents/task-executor.md' },
{ template: 'functional-testing-agent.md', destination: '.claude/agents/functional-testing-agent.md' },
```

#### Step 1.3: Remove TaskMaster References
**Search and remove**:
```bash
# Find all TaskMaster tool references
grep -r "mcp__task-master__" templates/agents/

# Remove from tool lists (except where documented as historical)
```

**Agents to clean**:
- All implementation agents (component, feature, infrastructure, polish, testing)
- All validation agents (tdd-validation, quality, gates)
- Specialized agents (devops, behavioral-transformation, etc.)

#### Step 1.4: Remove Playwright References
```bash
# Remove from:
- README.md
- templates/docs/RESEARCH-CACHE-PROTOCOL.md
- templates/docs/AGENT-INTERACTION-DIAGRAM.md
- templates/.claude-collective/agents.md
```

#### Step 1.5: Update Root CLAUDE.md
**File**: `/mnt/h/Active/taskmaster-agent-claude-code/CLAUDE.md`
- Replace lines 29-118 with new v3.0 orchestration section
- Add memory-based state management explanation
- Document hook validation gates

#### Step 1.6: Update Template Documentation
- Update `templates/.claude-collective/CLAUDE.md`
- Update `templates/commands/van.md`
- Update `templates/.claude-collective/agents.md`
- Update `templates/docs/*.md`

#### Step 1.7: Test Installation
```bash
./scripts/test-local.sh
# Verify:
# - 5 agents removed from installation
# - No TaskMaster references
# - No Playwright references
# - Documentation consistent
```

---

### Phase 2: Memory System Implementation (REQUIRES DESIGN)

**Status**: ⚠️ Design phase - needs detailed specification

#### Step 2.1: Verify Memory Tool Availability
**Research needed**:
- Is `create_memory/read_memory/update_memory/delete_memory` available in Claude Code CLI?
- If not, what's the workaround? (Write to `.claude/memory/` directory?)

#### Step 2.2: Design Memory Schema
**Design decisions needed**:
- JSON structure for tasks, workflow state, validation results
- Schema versioning strategy
- Backward compatibility approach

#### Step 2.3: Implement Memory Operations
**If native memory tool available**:
```javascript
// Hub Claude uses built-in tool
create_memory("tasks.json", JSON.stringify(tasks));
const state = read_memory("workflow-state.json");
update_memory("validation-results.json", JSON.stringify(results));
```

**If workaround needed**:
```javascript
// Use Write/Read tools to .claude/memory/ directory
Write(".claude/memory/tasks.json", JSON.stringify(tasks));
const state = JSON.parse(Read(".claude/memory/workflow-state.json"));
```

#### Step 2.4: Create Hook-Memory Integration
**Design needed**:
- How bash hooks invoke memory operations
- Atomic update mechanisms
- Concurrent access handling

#### Step 2.5: Implement SubagentStop Hook
**File**: `templates/hooks/subagent-validation.sh`

**Functionality**:
- Read workflow state from memory
- Run validation (npm test, check deliverables)
- Update memory with validation results
- Update task status in memory
- Exit 0 (allow) or 2 (block)

#### Step 2.6: Implement PreToolUse(Task) Hook
**File**: `templates/hooks/pre-agent-deploy.sh`

**Functionality**:
- Read task dependencies from memory
- Check prerequisites met
- Verify previous phase complete
- Exit 0 (allow) or 2 (block)

#### Step 2.7: Update Hook Configuration
**File**: `templates/settings.json.template`

Add SubagentStop and PreToolUse(Task) hook configurations

---

### Phase 3: Validation & Testing

**Status**: After Phase 2 complete

#### Step 3.1: Test Simple TDD Workflow
```bash
cd test-installation
claude-code

# Test:
/van
Build a simple login form

# Verify:
# - Hub deploys test-first-agent
# - SubagentStop validates tests created
# - Hub deploys component-implementation-agent
# - SubagentStop validates tests pass
# - Hub deploys tdd-validation-agent
# - Hub deploys chrome-devtools-testing-agent
# - Memory tracks all state correctly
```

#### Step 3.2: Test Complex Multi-Agent Workflow
```bash
# Test:
/van
Build React app with Node.js API

# Verify:
# - Hub uses extended thinking for sequencing
# - Parallel agent deployment works
# - Hooks validate both complete before proceeding
# - Memory tracks complex workflow state
```

#### Step 3.3: Test Hook Enforcement
```bash
# Test:
# Manually break a test after implementation

# Verify:
# - SubagentStop hook detects test failure
# - Hub is blocked from proceeding
# - User must fix tests before continuing
```

#### Step 3.4: Test Memory Persistence
```bash
# Test:
# Start workflow, exit Claude Code mid-workflow
# Restart Claude Code

# Verify:
# - Memory persists across sessions
# - Hub resumes from correct state
# - No work is lost
```

---

## Section 9: Open Questions & Design Needs

### Critical Design Questions

1. **Memory Tool API in Claude Code CLI**
   - Is it available? How to invoke?
   - If not, what's the workaround?
   - When will it be available?

2. **Memory Schema Specification**
   - Exact JSON structure for all memory files
   - Required vs optional fields
   - Validation rules

3. **Hook-Memory Integration**
   - How do bash scripts invoke memory operations?
   - Direct file writes to .claude/memory/?
   - Claude Code CLI commands?
   - MCP server for memory?

4. **Concurrent Access Handling**
   - What if parallel agents update memory simultaneously?
   - File locking mechanism?
   - Atomic operations?
   - Queue-based updates?

5. **Error Recovery**
   - Memory corruption detection
   - Backup/restore mechanism
   - Rollback to previous state
   - Validation checksums

6. **Schema Versioning**
   - How to handle schema changes across versions?
   - Migration scripts?
   - Backward compatibility strategy?

7. **Performance Optimization**
   - Memory file sizes (how large?)
   - Read/write frequency optimization
   - Incremental updates vs full rewrites
   - Compression for large histories

8. **User Experience**
   - How do users inspect memory state?
   - Can users manually edit memory files?
   - How to debug memory issues?
   - Memory visualization tools?

9. **Migration Path**
   - How do existing users transition from TaskMaster to memory?
   - Compatibility mode during transition?
   - Migration utilities?

10. **Security**
    - Sensitive data in memory files?
    - Encryption needed?
    - Access controls?

---

## Section 10: Revolutionary Aspects

### Why This Architecture is Groundbreaking

#### 1. First Framework Using LLM Native Memory for Task Management
**Innovation**: State management is built into the LLM, not bolted on externally

**Traditional Approach**:
```
LLM → External Task Manager (TaskMaster, Jira, etc.) → External Database
```

**v3.0 Approach**:
```
LLM ← Native Memory → LLM's own tool calls
```

**Benefits**:
- Zero external dependencies
- State is transparent (human-readable files)
- LLM queries its own memory naturally
- No API translation layers

#### 2. Deterministic Checkpoints in Non-Deterministic System
**Innovation**: Hooks create validation gates that enforce determinism

**The Paradox**:
- Claude 4.5 is non-deterministic (creative, intelligent routing)
- Software development needs determinism (tests must pass, deliverables must exist)

**The Solution**:
```
Non-Deterministic Agent Work → Deterministic Validation Gate → Non-Deterministic Next Agent
```

**Example**:
```
Agent A completes (non-deterministic output)
    ↓
SubagentStop hook validates (deterministic checkpoint)
    ↓
IF tests pass AND deliverables exist:
    Allow Hub to proceed ✅
ELSE:
    Block Hub until fixed ❌
```

**Result**: Reliable software development with creative AI

#### 3. Self-Orchestrating Intelligence
**Innovation**: No orchestration layer, Hub Claude is smart enough

**Traditional Multi-Agent Systems**:
```
User → Orchestrator Agent → Routes to specialized agents
```

**v3.0**:
```
User → Hub Claude (extended thinking) → Deploys agents directly
```

**Why This Works**:
- Claude 4.5 Sonnet's intelligence sufficient for routing
- Extended thinking shows decision process
- Memory queries provide state context
- Agent suggestions guide next steps

**Benefits**:
- Simpler architecture (fewer agents)
- More transparent (see Hub's thinking)
- More flexible (Hub adapts to context)
- Less overhead (no orchestration layer)

#### 4. Zero External Dependencies
**Innovation**: Everything runs within Claude 4.5 + hooks

**v2.x Dependencies**:
- TaskMaster MCP server
- External task database
- Orchestration agents
- Multiple MCP servers

**v3.0 Dependencies**:
- Chrome DevTools MCP (for browser testing)
- Context7 MCP (for documentation research)
- That's it

**Benefits**:
- Easier installation
- Fewer failure points
- More portable
- Simpler maintenance

#### 5. Transparent State Management
**Innovation**: Memory is human-readable, inspectable, editable

**Traditional Systems**:
```
State stored in database → Opaque to users → Must trust system
```

**v3.0**:
```
State in .claude/memory/*.json → Users can inspect → Users can edit if needed
```

**Benefits**:
- Full transparency
- Easy debugging
- Manual recovery possible
- Trust through verification

#### 6. Hook-Enforced Workflows
**Innovation**: Bash scripts enforce deterministic rules on non-deterministic AI

**Example**:
```bash
# SubagentStop hook enforces:
# "No task is complete until tests pass"

npm test || exit 2  # Block Hub if tests fail
```

**This is revolutionary because**:
- Hooks are external to LLM (can't be "convinced" to skip)
- Hooks are deterministic (same input = same output)
- Hooks enforce hard constraints (no negotiation)

**Result**: AI flexibility + human-defined guardrails = reliable system

---

## Conclusion

V3.0 represents a fundamental architectural evolution:
- **From**: Explicit orchestration via specialized agents
- **To**: Native Claude 4.5 intelligence with memory + hooks

**Core Innovation**: Deterministic validation gates (hooks) around non-deterministic AI work (agents) with transparent state management (memory).

**Implementation Status**:
- **Phase 1 (Cleanup)**: Ready to implement immediately
- **Phase 2 (Memory)**: Requires design specification and API verification
- **Phase 3 (Validation)**: After Phase 2 complete

**Next Steps**:
1. Execute Phase 1 cleanup
2. Research memory tool availability in Claude Code CLI
3. Design complete memory schema and integration
4. Implement Phase 2 memory system
5. Validate with comprehensive testing

---

**Document Version**: 1.0
**Last Updated**: 2025-10-01
**Status**: Design Phase - Awaiting Phase 2 specification
