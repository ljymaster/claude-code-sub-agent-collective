#!/bin/bash
# logging-status.sh - Show current logging status and recent activity

MEMORY_DIR=".claude/memory"
TOGGLE_FILE="$MEMORY_DIR/.logging-enabled"
HOOKS_LOG="$MEMORY_DIR/logs/current/hooks.jsonl"
MEMORY_LOG="$MEMORY_DIR/logs/current/memory.jsonl"

# Check if logging is enabled
if [[ -f "$TOGGLE_FILE" ]]; then
    echo "📊 Logging Status: ENABLED"
    echo ""

    # Show recent hook events
    if [[ -f "$HOOKS_LOG" ]]; then
        echo "Recent Hook Events (last 5):"
        tail -5 "$HOOKS_LOG" 2>/dev/null || echo "  (no events yet)"
        echo ""
    fi

    # Show recent memory operations
    if [[ -f "$MEMORY_LOG" ]]; then
        echo "Recent Memory Operations (last 5):"
        tail -5 "$MEMORY_LOG" 2>/dev/null || echo "  (no operations yet)"
        echo ""
    fi

    # Show commands
    cat <<'EOF'
Commands:
  /van logging disable - Stop logging
  jq -r '.hook' .claude/memory/logs/current/hooks.jsonl - Query hooks
EOF
else
    echo "📊 Logging Status: DISABLED"
    echo ""
    cat <<'EOF'
To enable: /van logging enable

When enabled, hooks will log:
- PreToolUse decisions (task validation)
- SubagentStop decisions (completion validation)
- Memory writes/updates
- WBS rollup calculations
EOF
fi
