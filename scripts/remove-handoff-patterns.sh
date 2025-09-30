#!/bin/bash
# remove-handoff-patterns.sh - Remove handoff patterns from all agent files

set -e

AGENT_DIR="templates/agents"

echo "🔄 Removing handoff patterns from agent files..."

for agent_file in "$AGENT_DIR"/*.md; do
    filename=$(basename "$agent_file")
    echo "  Processing: $filename"

    # Remove lines containing handoff patterns
    sed -i.bak \
        -e '/COLLECTIVE_HANDOFF_READY/d' \
        -e '/Use the.*subagent to coordinate/d' \
        -e '/Use the task-orchestrator subagent/d' \
        "$agent_file"

    # Remove .bak file
    rm -f "${agent_file}.bak"
done

echo "✅ Handoff patterns removed from all agents"
echo "🔍 Review changes: git diff templates/agents/"