---
description: List all tasks with their current status
---

# /tasks list

Display all tasks in the hierarchy with status indicators.

## Usage

```
/tasks list
/tasks list pending
/tasks list done
/tasks list in-progress
```

## Execution

1. **Validate task-index.json exists**:
```bash
if [[ ! -f .claude/memory/task-index.json ]]; then
  echo "❌ No task-index.json found. Run /van first to create tasks."
  exit 1
fi
```

2. **Parse filter (if provided)**:
```bash
FILTER="{ARGS}"  # Can be: pending, done, in-progress, or empty for all
```

3. **Display tasks**:

```bash
echo "📋 TASK LIST"
if [[ -n "$FILTER" ]]; then
  echo "Filter: $FILTER"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Build jq filter
if [[ -n "$FILTER" ]]; then
  JQ_FILTER=".tasks[] | select(.status==\"$FILTER\")"
else
  JQ_FILTER=".tasks[]"
fi

# Display epic
jq -r "$JQ_FILTER | select(.type==\"epic\") |
  \"Epic \" + .id + \": \" + .title + \" [\" + .status + \"]\"" \
  .claude/memory/task-index.json

echo ""

# Display features with indentation
jq -r "$JQ_FILTER | select(.type==\"feature\") |
  \"  Feature \" + .id + \": \" + .title + \" [\" + .status + \"]\"" \
  .claude/memory/task-index.json

echo ""

# Display tasks with indentation and status symbols
jq -r "$JQ_FILTER | select(.type==\"task\") |
  \"    \" +
  (if .status == \"done\" then \"✅\" elif .status == \"in-progress\" then \"🔄\" else \"⏳\" end) +
  \" Task \" + .id + \": \" + .title + \" (\" + (.agent // \"no agent\") + \")\"" \
  .claude/memory/task-index.json

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Summary
TOTAL=$(jq "[.tasks[] | select(.type==\"task\")] | length" .claude/memory/task-index.json)
DONE=$(jq "[.tasks[] | select(.type==\"task\" and .status==\"done\")] | length" .claude/memory/task-index.json)
PENDING=$(jq "[.tasks[] | select(.type==\"task\" and .status==\"pending\")] | length" .claude/memory/task-index.json)
IN_PROGRESS=$(jq "[.tasks[] | select(.type==\"task\" and .status==\"in-progress\")] | length" .claude/memory/task-index.json)

echo "Summary: $DONE done, $IN_PROGRESS in-progress, $PENDING pending (total: $TOTAL)"
```

## Example Output

**All tasks**:
```
📋 TASK LIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Epic 1: Counter Button Application [in-progress]

  Feature 1.1: HTML Structure [done]
  Feature 1.2: CSS Styling [in-progress]
  Feature 1.3: JavaScript Functionality [pending]

    ✅ Task 1.1.1: Write HTML structure tests (test-first-agent)
    ✅ Task 1.1.2: Implement HTML structure (component-implementation-agent)
    🔄 Task 1.2.1: Write CSS styling tests (test-first-agent)
    ⏳ Task 1.2.2: Implement CSS styles (component-implementation-agent)
    ⏳ Task 1.3.1: Write JavaScript functionality tests (test-first-agent)
    ⏳ Task 1.3.2: Implement JavaScript counter functionality (feature-implementation-agent)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary: 2 done, 1 in-progress, 3 pending (total: 6)
```

**Pending tasks only**:
```
/tasks list pending

📋 TASK LIST
Filter: pending
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Feature 1.3: JavaScript Functionality [pending]

    ⏳ Task 1.2.2: Implement CSS styles (component-implementation-agent)
    ⏳ Task 1.3.1: Write JavaScript functionality tests (test-first-agent)
    ⏳ Task 1.3.2: Implement JavaScript counter functionality (feature-implementation-agent)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary: 0 done, 0 in-progress, 3 pending (total: 6)
```

## Use Cases

- **Progress tracking** - See what's been completed
- **Queue inspection** - See what's waiting to execute
- **Debug stuck workflows** - Identify tasks that should be done but aren't
- **Agent verification** - See which agents are assigned to which tasks
