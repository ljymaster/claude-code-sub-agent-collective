#!/bin/bash
# simplify-agents-v3.sh - Batch update all agents to remove handoff logic

set -e

AGENT_DIR="templates/agents"
BACKUP_DIR="templates/agents-v2-backup"

# Create backup
mkdir -p "$BACKUP_DIR"
cp -r "$AGENT_DIR"/*.md "$BACKUP_DIR"/

echo "🔄 Simplifying 32 agent files for v3.0..."
echo "📦 Backup created in: $BACKUP_DIR"
echo ""

# Process each agent file
for agent_file in "$AGENT_DIR"/*.md; do
    filename=$(basename "$agent_file")
    echo "Processing: $filename"

    # Create temp file
    temp_file=$(mktemp)

    # Read file and remove handoff sections
    awk '
    BEGIN {
        skip = 0
        in_handoff_section = 0
    }

    # Detect handoff-related section headers
    /^##.*HUB.*DELEGATION|^##.*HANDOFF|^##.*HUB RETURN|^###.*HANDOFF/ {
        in_handoff_section = 1
        skip = 1
        next
    }

    # Detect next section (reset skip)
    /^## [^#]/ {
        if (in_handoff_section) {
            in_handoff_section = 0
            skip = 0
        }
    }

    # Skip lines with handoff instructions
    /CRITICAL.*HUB.*DELEGATION/ { skip = 1; next }
    /CRITICAL.*HANDOFF/ { skip = 1; next }
    /COLLECTIVE_HANDOFF_READY/ { skip = 1; next }
    /Use the.*subagent to/ { skip = 1; next }
    /\.claude\/handoff\/NEXT_ACTION\.json/ { skip = 1; next }
    /Unicode.*dash.*normalization/ { skip = 1; next }

    # Print lines that are not being skipped
    !skip { print }

    # Reset skip after single-line patterns
    /CRITICAL.*HUB.*DELEGATION|CRITICAL.*HANDOFF|COLLECTIVE_HANDOFF_READY|Use the.*subagent to|\.claude\/handoff\/NEXT_ACTION\.json|Unicode.*dash.*normalization/ {
        if (!in_handoff_section) skip = 0
    }
    ' "$agent_file" > "$temp_file"

    # Replace original file
    mv "$temp_file" "$agent_file"
done

echo ""
echo "✅ All agents simplified"
echo "🔍 Review changes with: git diff templates/agents/"
echo "📦 Rollback if needed: cp templates/agents-v2-backup/*.md templates/agents/"