#!/bin/bash
# Update implementation agents to use memory-based task system instead of TaskMaster MCP

set -euo pipefail

AGENTS_DIR="templates/agents"

# Define the new task context protocol section
read -r -d '' NEW_TASK_PROTOCOL << 'EOF' || true
### **🚨 CRITICAL: Task Context Protocol**

**Hub Claude provides task context in the deployment prompt using this format:**

```
Task ID: [TASK_ID]
Title: [TASK_TITLE]
Parent Feature: [PARENT_ID]
Deliverables Expected: [LIST_OF_FILES]
Dependencies Completed: [LIST_OF_DEPENDENCY_IDS or "none"]

[TASK_DESCRIPTION]
```

**I MUST extract this information from the prompt:**

1. **Task ID** - The task I'm implementing (e.g., "1.2.1")
2. **Title** - What I'm building (e.g., "Implement user validation")
3. **Deliverables** - Files I must create (e.g., "src/validation.js")
4. **Dependencies** - Tasks completed before me (tests written first)
5. **Description** - Context about what to build

**If task context is missing from prompt:**
```markdown
❌ CANNOT PROCEED WITHOUT TASK CONTEXT
Hub Claude must provide task details in the deployment prompt.
Required format:
  Task ID: [id]
  Title: [title]
  Deliverables Expected: [files]
  Dependencies Completed: [task ids or "none"]
```
EOF

# List of agents to update
AGENTS=(
  "test-first-agent.md"
  "feature-implementation-agent.md"
  "infrastructure-implementation-agent.md"
  "polish-implementation-agent.md"
  "testing-implementation-agent.md"
)

echo "🔧 Updating agents for memory-based task system..."
echo ""

for agent in "${AGENTS[@]}"; do
  agent_path="$AGENTS_DIR/$agent"

  if [[ ! -f "$agent_path" ]]; then
    echo "⚠️  Skipping $agent (not found)"
    continue
  fi

  echo "📝 Updating $agent..."

  # Remove TaskMaster MCP tools from tools line
  sed -i 's/, mcp__task-master__get_task, mcp__task-master__set_task_status//g' "$agent_path"
  sed -i 's/mcp__task-master__get_task, mcp__task-master__set_task_status, //g' "$agent_path"

  # Remove old TaskMaster protocol sections (between two specific headers)
  # This is agent-specific, so we'll handle it manually for now

  echo "  ✅ Removed TaskMaster MCP tools"
done

echo ""
echo "✅ All agents updated"
echo "⚠️  Manual step required: Replace TaskMaster protocol sections with new task context protocol"
echo ""
echo "New protocol to add:"
echo "$NEW_TASK_PROTOCOL"
