#!/bin/bash
# remove-hub-sections.sh - Remove HUB RETURN PROTOCOL sections

set -e

AGENT_DIR="templates/agents"

echo "🔄 Removing HUB RETURN PROTOCOL sections..."

for agent_file in "$AGENT_DIR"/*.md; do
    filename=$(basename "$agent_file")

    # Check if file contains HUB RETURN PROTOCOL
    if grep -q "HUB RETURN PROTOCOL" "$agent_file"; then
        echo "  Processing: $filename"

        # Use awk to remove entire HUB RETURN PROTOCOL section until next ##  heading
        awk '
        BEGIN { skip = 0 }
        /^## .*HUB RETURN PROTOCOL/ { skip = 1; next }
        /^## [^#]/ { if (skip) skip = 0 }
        !skip { print }
        ' "$agent_file" > "${agent_file}.tmp"

        mv "${agent_file}.tmp" "$agent_file"
    fi
done

echo "✅ HUB RETURN PROTOCOL sections removed"