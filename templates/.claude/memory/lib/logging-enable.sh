#!/bin/bash
# logging-enable.sh - Enable deterministic logging system
# This script GUARANTEES the toggle file is created

MEMORY_DIR=".claude/memory"
TOGGLE_FILE="$MEMORY_DIR/.logging-enabled"
LOG_DIR="$MEMORY_DIR/logs/current"

# STEP 1: Create toggle file (CRITICAL)
touch "$TOGGLE_FILE"

# STEP 2: Create log directories
mkdir -p "$LOG_DIR"

# STEP 3: Create log files (initialize if missing)
touch "$LOG_DIR/hooks.jsonl"
touch "$LOG_DIR/memory.jsonl"

# STEP 4: Verify toggle file exists
if [[ -f "$TOGGLE_FILE" ]]; then
    echo "✅ Toggle file created: $TOGGLE_FILE"
else
    echo "❌ CRITICAL ERROR: Failed to create toggle file"
    exit 1
fi

# STEP 5: Display confirmation
cat <<'EOF'
📊 Logging System ENABLED

✅ Toggle file verified: .claude/memory/.logging-enabled exists
✅ Log directories created
✅ Log files initialized

Deterministic logging is now active. Hooks will log:
- Hook execution decisions (PreToolUse, SubagentStop)
- Memory operations (write, read, update)
- WBS rollup calculations

Log files (JSONL format):
- .claude/memory/logs/current/hooks.jsonl
- .claude/memory/logs/current/memory.jsonl

Query logs with jq:
  jq '.type == "hook"' .claude/memory/logs/current/hooks.jsonl
  jq '.type == "memory"' .claude/memory/logs/current/memory.jsonl

Disable: /van logging disable
Status: /van logging status
EOF
