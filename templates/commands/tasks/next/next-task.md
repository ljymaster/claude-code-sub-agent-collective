---
description: Find and display the next available task to execute
---

# /tasks next

Find the next pending leaf task with satisfied dependencies that's ready to execute.

## Usage

```
/tasks next
```

## Execution

1. **Validate task-index.json exists**:
```bash
if [[ ! -f .claude/memory/task-index.json ]]; then
  echo "❌ No task-index.json found. Run /van first to create tasks."
  exit 1
fi
```

2. **Find next available task**:

```bash
echo "🔍 Finding next available task..."
echo ""

# Find first pending leaf task with satisfied dependencies
NEXT_TASK=$(jq -r '
  .tasks as $all_tasks |
  .tasks[] |
  select(.type == "task") |
  select(.status == "pending") |
  select(
    (.children // []) | length == 0
  ) |
  select(
    (.dependencies // []) as $deps |
    if ($deps | length) == 0 then
      true
    else
      $deps | all(
        . as $dep_id |
        $all_tasks[] |
        select(.id == $dep_id) |
        .status == "done"
      )
    end
  ) |
  .id
' .claude/memory/task-index.json | head -1)

if [[ -z "$NEXT_TASK" ]]; then
  # Check if all tasks done
  REMAINING=$(jq '[.tasks[] | select(.type=="task" and .status=="pending")] | length' .claude/memory/task-index.json)

  if [[ "$REMAINING" -eq 0 ]]; then
    echo "✅ All tasks complete!"
  else
    echo "⚠️ No tasks available (blocked by dependencies)"
    echo ""
    echo "Pending tasks:"
    jq -r '.tasks[] | select(.type=="task" and .status=="pending") |
      "  " + .id + " - " + .title + " (depends on: " + ((.dependencies // []) | join(", ")) + ")"' \
      .claude/memory/task-index.json
  fi
  exit 0
fi

# Display next task details
echo "📋 NEXT TASK: $NEXT_TASK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

jq -r ".tasks[] | select(.id==\"$NEXT_TASK\") |
  \"Title: \" + .title + \"\n\" +
  \"Agent: \" + (.agent // \"none\") + \"\n\" +
  \"Dependencies: \" + (if (.dependencies // []) | length > 0 then (.dependencies | join(\", \")) else \"none\" end) + \"\n\" +
  \"Deliverables: \" + (if (.deliverables // []) | length > 0 then (.deliverables | join(\", \")) else \"none\" end)" \
  .claude/memory/task-index.json

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "To execute: Deploy the agent shown above via Task tool"
```

## Example Output

```
🔍 Finding next available task...

📋 NEXT TASK: 1.1.1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Title: Write HTML structure tests
Agent: test-first-agent
Dependencies: none
Deliverables: tests/index.test.html

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
To execute: Deploy the agent shown above via Task tool
```

## Use Cases

- **Manual workflow execution** - Find what task to run next
- **Debugging** - Verify dependency resolution is working
- **Recovery** - After interruptions, find where to resume
- **Verification** - Confirm hooks are marking tasks correctly
