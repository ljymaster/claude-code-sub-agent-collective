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
    # Create validation marker
    touch ".claude/memory/markers/.needs-validation-${PARENT_ID}"
  fi
fi
```

**Result**: Physical marker file created at `.claude/memory/markers/.needs-validation-{FEATURE_ID}`

#### 2. Validation Agent Enforcement

**When**: PreToolUse hook runs before deploying any agent

**Logic**:
```bash
# Check for validation markers
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
{"hookSpecificOutput":{"permissionDecision":"deny","permissionDecisionReason":"Feature $FEATURE_ID requires validation. MUST deploy @tdd-validation-agent before proceeding."}}
JSON
    exit 2  # DENY
  fi
fi
```

**Result**: Hub Claude CANNOT deploy next task's agent until tdd-validation-agent deployed

#### 3. Browser Testing Enforcement

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

**Enforcement Chain**:
```
Feature completes
  → SubagentStop creates marker
  → PreToolUse blocks all agents except validation agent
  → Hub Claude has NO CHOICE (physical file blocks workflow)
  → Must deploy validation agent to remove marker
  → Workflow continues
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

### Validation Agent Enforcement
- **Hook**: `pre-agent-deploy.sh` (PreToolUse on Task)
- **Agents**: tdd-validation-agent, chrome-devtools-testing-agent
- **Integration**: Hook creates/checks marker files
- **Result**: Impossible to skip validation when required

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

# View browser testing enforcement
cat .claude/memory/logs/current/hooks.jsonl | jq 'select(.reason | contains("browser testing"))'
```

### Manual Hook Testing

```bash
# Test validation marker creation (simulate feature completion)
mkdir -p .claude/memory/markers
touch .claude/memory/markers/.needs-validation-1.1

# Test PreToolUse blocking
echo '{"tool_name": "Task", "tool_input": {"prompt": "Deploy @component-implementation-agent for task 1.2.1"}}' | ./.claude/hooks/pre-agent-deploy.sh

# Expected: DENY with "Feature 1.1 requires validation"

# Test validation agent allowed
echo '{"tool_name": "Task", "tool_input": {"prompt": "Deploy @tdd-validation-agent for feature 1.1"}}' | ./.claude/hooks/pre-agent-deploy.sh

# Expected: ALLOW (marker removed)
```

---

## Summary

**Hook system provides**:
- ✅ 100% deterministic workflow enforcement
- ✅ Physical file gates (cannot be bypassed)
- ✅ Test-first methodology (enforced)
- ✅ Validation requirements (enforced)
- ✅ Browser testing (enforced when enabled)
- ✅ Complete audit trail (optional logging)
- ✅ No LLM decision-making in enforcement

**Agents follow hooks, not the other way around.**