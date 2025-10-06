# Hook and Agent System Integration

## Critical Hook Requirements
**CRITICAL**: Any changes to hooks (.claude/hooks/) or agent configurations require a user restart.

## When to Request Restart
- Modifying .claude/hooks/pre-task.sh
- Modifying .claude/hooks/post-task.sh
- Modifying .claude/settings.json hook configuration
- Changes to agent validation logic
- Updates to enforcement rules
- Creating or modifying .claude/agents/ files
- Updates to behavioral system enforcement

## Restart Procedure
1. Commit changes first
2. Ask user to restart Claude Code
3. DO NOT continue testing until restart confirmed
4. Never assume hooks or agents work without restart

---

## Hook System Overview

The Claude Code Collective uses a **deterministic hook-based enforcement system** to guarantee workflow compliance. All validation is enforced through physical file gates (marker files) - NOT through LLM decision-making.

### Core Hooks

1. **PreToolUse Hook** (`pre-agent-deploy.sh`)
   - Validates task readiness before agent deployment
   - Enforces marker-based validation requirements
   - Blocks workflow until validation agents deployed

2. **TDD Gate Hook** (`tdd-gate.sh`)
   - Enforces test-first development
   - Blocks implementation until tests exist
   - Cannot be bypassed

3. **SubagentStop Hook** (`subagent-validation.sh`)
   - Validates work quality on agent completion
   - Creates validation markers when features complete
   - Updates task status and triggers WBS rollup

---

## Marker-Based Validation Enforcement (v3.0)

**Philosophy**: Physical file gates provide 100% deterministic enforcement. Hub Claude has NO CHOICE - hooks physically prevent non-compliant actions.

### How It Works

#### 1. Feature Completion Detection

**When**: SubagentStop hook runs after implementation agent completes

**Logic**:
```bash
# Check if agent is an implementation agent
if [[ "$AGENT" =~ -implementation-agent$ ]]; then
  # Get parent feature ID
  PARENT_ID=$(jq -r ".tasks[] | select(.id==\"$TASK_ID\") | .parent" task-index.json)

  # Count sibling tasks that are not done
  ALL_DONE=$(jq -r ".tasks[] | select(.parent==\"$PARENT_ID\") | .status" task-index.json | grep -v "done" | wc -l)

  # If all sibling tasks done, feature is complete
  if [[ "$ALL_DONE" -eq 0 ]]; then
    # Create TWO validation markers (3-gate system)
    touch ".claude/memory/markers/.needs-validation-${PARENT_ID}"
    touch ".claude/memory/markers/.needs-deliverables-validation-${PARENT_ID}"
  fi
fi
```

**Result**: TWO physical marker files created:
- `.claude/memory/markers/.needs-validation-{FEATURE_ID}` → TDD validation required
- `.claude/memory/markers/.needs-deliverables-validation-{FEATURE_ID}` → File validation required

#### 2. Gate 1: TDD Validation Agent Enforcement

**When**: PreToolUse hook runs before deploying any agent (Gate 1 of 3)

**Logic**:
```bash
# Check for TDD validation markers
if ls .claude/memory/markers/.needs-validation-* 2>/dev/null; then
  MARKER_FILE=$(ls .claude/memory/markers/.needs-validation-* | head -1)
  FEATURE_ID=$(basename "$MARKER_FILE" | sed 's/^\.needs-validation-//')

  # Extract requested agent from prompt
  REQUESTED_AGENT=$(echo "$PROMPT" | grep -oP '@\K[a-z-]+-agent')

  if [[ "$REQUESTED_AGENT" == "tdd-validation-agent" ]]; then
    # Correct agent - remove marker and allow
    rm "$MARKER_FILE"
    exit 0  # ALLOW
  else
    # Wrong agent - block deployment
    cat <<JSON
{"hookSpecificOutput":{"permissionDecision":"deny","permissionDecisionReason":"⚠️ GATE 1 BLOCKED: Feature $FEATURE_ID requires TDD validation. MUST deploy @tdd-validation-agent before proceeding."}}
JSON
    exit 2  # DENY
  fi
fi
```

**Result**: Hub Claude CANNOT proceed until tdd-validation-agent validates tests pass

#### 3. Gate 2: Deliverables Validation Agent Enforcement

**When**: PreToolUse hook runs after TDD validation completes (Gate 2 of 3)

**Logic**:
```bash
# Check for deliverables validation markers
if ls .claude/memory/markers/.needs-deliverables-validation-* 2>/dev/null; then
  MARKER_FILE=$(ls .claude/memory/markers/.needs-deliverables-validation-* | head -1)
  FEATURE_ID=$(basename "$MARKER_FILE" | sed 's/^\.needs-deliverables-validation-//')

  # Extract requested agent from prompt
  REQUESTED_AGENT=$(echo "$PROMPT" | grep -oP '@\K[a-z-]+-agent')

  if [[ "$REQUESTED_AGENT" == "deliverables-validation-agent" ]]; then
    # Correct agent - remove marker and allow
    rm "$MARKER_FILE"
    exit 0  # ALLOW
  else
    # Wrong agent - block deployment
    cat <<JSON
{"hookSpecificOutput":{"permissionDecision":"deny","permissionDecisionReason":"⚠️ GATE 2 BLOCKED: Feature $FEATURE_ID requires deliverables validation. MUST deploy @deliverables-validation-agent before proceeding."}}
JSON
    exit 2  # DENY
  fi
fi
```

**What deliverables-validation-agent does**:
- Scans filesystem for all files created during feature
- Validates expected deliverables exist (from task-index.json)
- **Intelligently categorizes additional files**:
  - CSS for HTML/JSX/TSX → Adds to deliverables ✅
  - Assets in same directory → Adds to deliverables ✅
  - Unrelated files (different directory tree) → Reports error ❌
  - Config/test files → Skips (handled by other gates)
- Updates task-index.json deliverables array with related files
- Ensures deliverables accurately reflect what was created

**Result**: Hub Claude CANNOT proceed until deliverables-validation-agent validates files

#### 4. Gate 3: Browser Testing Enforcement

**When**: After tdd-validation-agent completes

**tdd-validation-agent Logic**:
```bash
# Scan code for UI elements
if grep -r "<form\|<input\|addEventListener\|onclick" implementation_files; then
  # UI detected - create browser testing marker
  FEATURE_ID=$(jq -r '.tasks[] | select(.status=="done" and .type=="feature") | .id' task-index.json | tail -1)
  touch ".claude/memory/markers/.needs-browser-testing-${FEATURE_ID}"
fi
```

**PreToolUse Hook Logic**:
```bash
# Check for browser testing markers
if ls .claude/memory/markers/.needs-browser-testing-* 2>/dev/null; then
  MARKER_FILE=$(ls .claude/memory/markers/.needs-browser-testing-* | head -1)
  FEATURE_ID=$(basename "$MARKER_FILE" | sed 's/^\.needs-browser-testing-//')

  # Check config
  BROWSER_TESTING=$(jq -r '.browserTesting // true' .claude/memory/config.json)

  if [[ "$BROWSER_TESTING" == "true" ]]; then
    REQUESTED_AGENT=$(echo "$PROMPT" | grep -oP '@\K[a-z-]+-agent')

    if [[ "$REQUESTED_AGENT" == "chrome-devtools-testing-agent" ]]; then
      # Correct agent - remove marker and allow
      rm "$MARKER_FILE"
      exit 0  # ALLOW
    else
      # Wrong agent - block deployment
      cat <<JSON
{"hookSpecificOutput":{"permissionDecision":"deny","permissionDecisionReason":"Feature $FEATURE_ID requires browser testing. MUST deploy @chrome-devtools-testing-agent before proceeding."}}
JSON
      exit 2  # DENY
    fi
  else
    # Browser testing disabled - remove marker and allow
    rm "$MARKER_FILE"
    exit 0
  fi
fi
```

**Result**: Hub Claude CANNOT skip browser testing if browserTesting=true AND UI detected

---

## Determinism Guarantees

**Physical File Gates**:
- ✅ Marker files are physical filesystem entities
- ✅ Hooks check for marker existence before allowing operations
- ✅ No LLM interpretation or decision-making
- ✅ Same config = same behavior every time

**3-Gate Enforcement Chain**:
```
Feature completes
  → SubagentStop creates TWO markers (.needs-validation-*, .needs-deliverables-validation-*)

GATE 1: TDD Validation
  → PreToolUse blocks all agents except tdd-validation-agent
  → Hub deploys tdd-validation-agent (runs tests)
  → Marker removed when tests pass
  → Workflow proceeds to Gate 2

GATE 2: Deliverables Validation
  → PreToolUse blocks all agents except deliverables-validation-agent
  → Hub deploys deliverables-validation-agent (validates files, adds CSS/assets)
  → Marker removed when deliverables validated
  → Workflow proceeds to Gate 3 (if UI detected)

GATE 3: Browser Testing (if UI detected + browserTesting=true)
  → tdd-validation-agent creates .needs-browser-testing-* marker
  → PreToolUse blocks all agents except chrome-devtools-testing-agent
  → Hub deploys chrome-devtools-testing-agent (tests interactions)
  → Marker removed when browser tests pass
  → Workflow continues to next feature
```

**Cannot Be Bypassed**:
- Hub Claude cannot "decide" to skip validation
- Agents cannot "suggest" skipping steps
- No prompt engineering can override hooks
- Only way forward: deploy required agent

---

## Hook-Agent Integration Points

### TDD Enforcement
- **Hook**: `tdd-gate.sh` (PreToolUse on Write/Edit)
- **Agents**: All implementation agents
- **Integration**: Hook blocks Write/Edit until tests exist
- **Result**: Impossible to implement without tests

### Task Validation
- **Hook**: `pre-agent-deploy.sh` (PreToolUse on Task)
- **Agents**: All agents
- **Integration**: Hook validates task readiness (dependencies, leaf status)
- **Result**: Impossible to execute tasks out of order

### Quality Validation
- **Hook**: `subagent-validation.sh` (SubagentStop)
- **Agents**: All implementation agents
- **Integration**: Hook runs tests, checks deliverables, creates markers
- **Result**: Impossible to complete without passing tests

### 3-Gate Validation Enforcement
- **Hook**: `pre-agent-deploy.sh` (PreToolUse on Task)
- **Agents**: tdd-validation-agent, deliverables-validation-agent, chrome-devtools-testing-agent
- **Integration**: Hook creates/checks marker files for 3-gate sequence
- **Result**: Impossible to skip any validation gate when required

**Gate Sequence**:
1. **Gate 1 (TDD)**: tdd-validation-agent validates tests pass
2. **Gate 2 (Deliverables)**: deliverables-validation-agent validates files + adds related files (CSS, assets)
3. **Gate 3 (Browser)**: chrome-devtools-testing-agent validates UI interactions (if UI detected + browserTesting=true)

---

## Debugging Hooks

### View Hook Logs (if logging enabled)

```bash
# View all hook decisions
cat .claude/memory/logs/current/hooks.jsonl | jq

# View denied operations
cat .claude/memory/logs/current/hooks.jsonl | jq 'select(.decision=="deny")'

# View validation markers created
cat .claude/memory/logs/current/hooks.jsonl | jq 'select(.reason | contains("validation required"))'

# View deliverables validation enforcement
cat .claude/memory/logs/current/hooks.jsonl | jq 'select(.reason | contains("deliverables validation"))'

# View browser testing enforcement
cat .claude/memory/logs/current/hooks.jsonl | jq 'select(.reason | contains("browser testing"))'
```

### Manual Hook Testing

```bash
# Test 3-gate validation sequence

# GATE 1: TDD Validation
mkdir -p .claude/memory/markers
touch .claude/memory/markers/.needs-validation-1.1
touch .claude/memory/markers/.needs-deliverables-validation-1.1

# Test PreToolUse blocks wrong agent
echo '{"tool_name": "Task", "tool_input": {"prompt": "Deploy @component-implementation-agent for task 1.2.1"}}' | ./.claude/hooks/pre-agent-deploy.sh
# Expected: DENY with "⚠️ GATE 1 BLOCKED: Feature 1.1 requires TDD validation"

# Test tdd-validation-agent allowed
echo '{"tool_name": "Task", "tool_input": {"prompt": "Deploy @tdd-validation-agent for feature 1.1"}}' | ./.claude/hooks/pre-agent-deploy.sh
# Expected: ALLOW (TDD marker removed, deliverables marker remains)

# GATE 2: Deliverables Validation
# Test deliverables-validation-agent allowed
echo '{"tool_name": "Task", "tool_input": {"prompt": "Deploy @deliverables-validation-agent for feature 1.1"}}' | ./.claude/hooks/pre-agent-deploy.sh
# Expected: ALLOW (deliverables marker removed)

# GATE 3: Browser Testing (if UI detected)
touch .claude/memory/markers/.needs-browser-testing-1.1

# Test chrome-devtools-testing-agent allowed
echo '{"tool_name": "Task", "tool_input": {"prompt": "Deploy @chrome-devtools-testing-agent for feature 1.1"}}' | ./.claude/hooks/pre-agent-deploy.sh
# Expected: ALLOW (browser marker removed)
```

---

## Summary

**Hook system provides**:
- ✅ 100% deterministic workflow enforcement
- ✅ Physical file gates (cannot be bypassed)
- ✅ Test-first methodology (enforced)
- ✅ 3-gate validation sequence (TDD → Deliverables → Browser)
- ✅ Intelligent file analysis via agents (not hook heuristics)
- ✅ Browser testing (enforced when enabled + UI detected)
- ✅ Complete audit trail (optional logging)
- ✅ No LLM decision-making in enforcement

**Agents follow hooks, not the other way around.**

**Philosophy**: Hooks are guard rails that redirect, agents make intelligent decisions.