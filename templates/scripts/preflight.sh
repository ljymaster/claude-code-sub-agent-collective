#!/bin/bash
set -euo pipefail

# Preflight configuration script for /van command
# Follows spec-kit pattern: Script handles imperative logic, command stays declarative
#
# Usage: preflight.sh '{"logging":"y","browserTesting":"y","prdPath":"path/to/prd.txt"}'
# Returns: JSON status object

RESPONSES="${1:-}"

# Validate input
if [[ -z "$RESPONSES" ]]; then
  echo '{"error": "No responses provided", "status": "failed"}' >&2
  exit 1
fi

# Check jq availability
if ! command -v jq &> /dev/null; then
  echo '{"error": "jq not installed", "status": "failed"}' >&2
  exit 1
fi

# Parse responses with defaults
LOGGING=$(echo "$RESPONSES" | jq -r '.logging // "n"')
BROWSER=$(echo "$RESPONSES" | jq -r '.browserTesting // "y"')  # Default true
PRD_PATH=$(echo "$RESPONSES" | jq -r '.prdPath // ""')

# Create directory structure
mkdir -p .claude/memory/config

# Configure logging
if [[ "$LOGGING" == "y" ]]; then
  touch .claude/memory/config/.logging-enabled
  mkdir -p .claude/memory/logs/current
else
  rm -f .claude/memory/config/.logging-enabled
fi

# Configure browser testing (default enabled)
if [[ "$BROWSER" == "y" ]]; then
  touch .claude/memory/config/.browser-testing
else
  rm -f .claude/memory/config/.browser-testing
fi

# Configure PRD path
if [[ -n "$PRD_PATH" && "$PRD_PATH" != "null" ]]; then
  echo "$PRD_PATH" > .claude/memory/config/.prd-path
else
  # Create empty file (indicates no PRD)
  touch .claude/memory/config/.prd-path
fi

# Create config.json for Hub Claude to read later
jq -n \
  --arg log "$LOGGING" \
  --arg browser "$BROWSER" \
  --arg prd "$PRD_PATH" \
  '{
    "loggingEnabled": ($log == "y"),
    "browserTesting": ($browser == "y"),
    "prdPath": (if $prd == "" or $prd == "null" then null else $prd end)
  }' > .claude/memory/config.json

# Mark preflight complete
touch .claude/memory/.preflight-done

# Output structured JSON for Hub Claude to consume (immediate response)
jq -n \
  --arg log "$LOGGING" \
  --arg browser "$BROWSER" \
  --arg prd "$PRD_PATH" \
  '{
    "loggingEnabled": ($log == "y"),
    "browserTesting": ($browser == "y"),
    "prdPath": (if $prd == "" or $prd == "null" then null else $prd end),
    "status": "complete",
    "message": "Preflight configuration saved successfully"
  }'
