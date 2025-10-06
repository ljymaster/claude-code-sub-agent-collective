---
description: Display detailed information about a specific task from task-index.json
---

# /tasks show <task-id>

Show complete details for a task including status, dependencies, deliverables, and agent assignment.

## Usage

```
/tasks show 1.1.1
/tasks show 1.2
/tasks show 1
```

## Execution

1. **Validate task-index.json exists**:
```bash
if [[ ! -f .claude/memory/task-index.json ]]; then
  echo "❌ No task-index.json found. Run /van first to create tasks."
  exit 1
fi
```

2. **Extract task ID from arguments**: `{ARGS}` contains the task ID

3. **Query task data**:
```bash
TASK_ID="{ARGS}"
TASK_DATA=$(jq ".tasks[] | select(.id==\"$TASK_ID\")" .claude/memory/task-index.json)

if [[ -z "$TASK_DATA" ]]; then
  echo "❌ Task $TASK_ID not found"
  exit 1
fi
```

4. **Display task details**:

```
📋 Task {TASK_ID}: {TITLE}

Type: {TYPE}
Status: {STATUS}
Parent: {PARENT}
Agent: {AGENT}

Dependencies:
{LIST_DEPENDENCIES}

Deliverables:
{LIST_DELIVERABLES}

Children:
{LIST_CHILDREN}

Progress: {COMPLETED}/{TOTAL}
```

**Template with actual jq commands**:
```bash
TASK_ID="{ARGS}"

echo "📋 Task Details"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
jq -r ".tasks[] | select(.id==\"$TASK_ID\") |
  \"ID: \" + .id + \"\n\" +
  \"Title: \" + .title + \"\n\" +
  \"Type: \" + .type + \"\n\" +
  \"Status: \" + .status + \"\n\" +
  \"Parent: \" + (.parent // \"none\") + \"\n\" +
  (if .agent then \"Agent: \" + .agent + \"\n\" else \"\" end) +
  (if .dependencies | length > 0 then
    \"Dependencies: \" + (.dependencies | join(\", \")) + \"\n\"
  else \"Dependencies: none\n\" end) +
  (if .deliverables | length > 0 then
    \"Deliverables: \" + (.deliverables | join(\", \")) + \"\n\"
  else \"\" end) +
  (if .children | length > 0 then
    \"Children: \" + (.children | join(\", \")) + \"\n\"
  else \"\" end)" \
  .claude/memory/task-index.json

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

## Examples

**Show epic**:
```
/tasks show 1

📋 Task Details
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ID: 1
Title: Counter Button Application
Type: epic
Status: in-progress
Parent: none
Children: 1.1, 1.2, 1.3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Show task**:
```
/tasks show 1.1.1

📋 Task Details
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ID: 1.1.1
Title: Write HTML structure tests
Type: task
Status: done
Parent: 1.1
Agent: test-first-agent
Dependencies: none
Deliverables: tests/index.test.html
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
