---
description: Display project progress overview from task-index.json
---

# /tasks status

Show overall project status including epic progress, feature completion, and task breakdown.

## Usage

```
/tasks status
```

## Execution

1. **Validate task-index.json exists**:
```bash
if [[ ! -f .claude/memory/task-index.json ]]; then
  echo "❌ No task-index.json found. Run /van first to create tasks."
  exit 1
fi
```

2. **Display project overview**:

```bash
echo "📊 PROJECT STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Epic summary
jq -r '.tasks[] | select(.type=="epic") |
  "Epic: " + .title + "\n" +
  "Status: " + .status + "\n" +
  "Progress: " + (.progress.completed | tostring) + "/" + (.progress.total | tostring) + " features complete"' \
  .claude/memory/task-index.json

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "FEATURES:"
echo ""

# Feature breakdown
jq -r '.tasks[] | select(.type=="feature") |
  "  " + .id + " " + .title + " → " + .status + " (" +
  (.progress.completed | tostring) + "/" + (.progress.total | tostring) + " tasks)"' \
  .claude/memory/task-index.json

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TASK SUMMARY:"
echo ""

# Task counts by status
TOTAL=$(jq '[.tasks[] | select(.type=="task")] | length' .claude/memory/task-index.json)
DONE=$(jq '[.tasks[] | select(.type=="task" and .status=="done")] | length' .claude/memory/task-index.json)
IN_PROGRESS=$(jq '[.tasks[] | select(.type=="task" and .status=="in-progress")] | length' .claude/memory/task-index.json)
PENDING=$(jq '[.tasks[] | select(.type=="task" and .status=="pending")] | length' .claude/memory/task-index.json)

echo "  Total Tasks: $TOTAL"
echo "  ✅ Done: $DONE"
echo "  🔄 In Progress: $IN_PROGRESS"
echo "  ⏳ Pending: $PENDING"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Current task (if any)
CURRENT=$(jq -r '.tasks[] | select(.type=="task" and .status=="in-progress") | .id + " - " + .title' .claude/memory/task-index.json | head -1)

if [[ -n "$CURRENT" ]]; then
  echo "CURRENT TASK:"
  echo "  $CURRENT"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi
```

## Example Output

```
📊 PROJECT STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Epic: Counter Button Application
Status: in-progress
Progress: 1/3 features complete

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FEATURES:

  1.1 HTML Structure → done (2/2 tasks)
  1.2 CSS Styling → in-progress (1/2 tasks)
  1.3 JavaScript Functionality → pending (0/2 tasks)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TASK SUMMARY:

  Total Tasks: 6
  ✅ Done: 2
  🔄 In Progress: 1
  ⏳ Pending: 3

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CURRENT TASK:
  1.2.1 - Write CSS styling tests
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Use Cases

- **Check progress** during long workflows
- **Verify task completion** after agents finish
- **Identify stuck tasks** (in-progress but not completing)
- **See what's next** in the queue
