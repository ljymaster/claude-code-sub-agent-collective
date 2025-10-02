#!/bin/bash
# logging-disable.sh - Disable deterministic logging system

MEMORY_DIR=".claude/memory"
TOGGLE_FILE="$MEMORY_DIR/.logging-enabled"

# Remove toggle file
rm -f "$TOGGLE_FILE"

# Verify toggle file is gone
if [[ ! -f "$TOGGLE_FILE" ]]; then
    echo "✅ Toggle file removed"
else
    echo "❌ CRITICAL ERROR: Failed to remove toggle file"
    exit 1
fi

# Display confirmation
cat <<'EOF'
📊 Logging System DISABLED

Hooks will no longer write log entries.
Existing logs preserved in .claude/memory/logs/current/

To re-enable: /van logging enable
EOF
