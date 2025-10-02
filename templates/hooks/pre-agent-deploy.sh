#!/usr/bin/env bash
# PreToolUse hook for dependency and leaf-task enforcement
# Prevents deploying agents for non-leaf tasks or tasks with unsatisfied dependencies

set -euo pipefail

MEMORY_DIR=".claude/memory"
TASKS_INDEX="$MEMORY_DIR/task-index.json"
LIB_DIR="$MEMORY_DIR/lib"

# Source logging library
# shellcheck disable=SC1091
source "$LIB_DIR/logging.sh" 2>/dev/null || true

# If no index exists, allow everything
if [[ ! -f "$TASKS_INDEX" ]]; then
  exit 0
fi

# Parse tool input from stdin
TOOL_INPUT=$(cat)
TOOL_NAME=$(echo "$TOOL_INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")

# Only validate Task tool (agent deployment)
if [[ "$TOOL_NAME" != "Task" ]]; then
  exit 0
fi

# Extract task ID from prompt (pattern: "task 1.2.3" or "Task 1.2.3")
PROMPT=$(echo "$TOOL_INPUT" | jq -r '.tool_input.prompt // empty' 2>/dev/null || echo "")
TASK_ID=$(echo "$PROMPT" | grep -oiP '(?<=task\s)[0-9]+(\.[0-9]+)*' | head -n1)

if [[ -z "$TASK_ID" ]]; then
  # No task ID found, allow (might be freeform work)
  exit 0
fi

# Check if task exists in index
if ! jq -e ".tasks[] | select(.id==\"$TASK_ID\")" "$TASKS_INDEX" >/dev/null 2>&1; then
  log_hook_event "PreToolUse" "Task" "$TASK_ID" "deny" "Task not found in index" '{"taskExists":false}'

  cat <<JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Task $TASK_ID not found in index"}}
JSON
  exit 2
fi

# 1. Check task is leaf (no children)
CHILDREN=$(jq -r ".tasks[] | select(.id==\"$TASK_ID\") | (.children // [])[]" "$TASKS_INDEX" 2>/dev/null || echo "")

if [[ -n "$CHILDREN" ]]; then
  log_hook_event "PreToolUse" "Task" "$TASK_ID" "deny" "Task has children: $CHILDREN" "{\"isLeaf\":false,\"children\":\"$CHILDREN\"}"

  cat <<JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Cannot work on $TASK_ID - has children. Work on leaf tasks only: $CHILDREN"}}
JSON
  exit 2
fi

# 2. Check dependencies satisfied AND validate previous work (defensive check)
DEPS=$(jq -r ".tasks[] | select(.id==\"$TASK_ID\") | (.dependencies // [])[]" "$TASKS_INDEX" 2>/dev/null || echo "")

if [[ -n "$DEPS" ]]; then
  ALL_DONE=true
  FAILED_DEPS=""
  MISSING_DELIVERABLES=""

  while IFS= read -r dep; do
    if [[ -z "$dep" ]]; then continue; fi

    dep_status=$(jq -r ".tasks[] | select(.id==\"$dep\") | .status // \"not-found\"" "$TASKS_INDEX")

    if [[ "$dep_status" != "done" ]]; then
      ALL_DONE=false
      FAILED_DEPS="$FAILED_DEPS $dep($dep_status)"
    else
      # Defensive validation: If task marked "done", verify deliverables actually exist
      deliverables=$(jq -r ".tasks[] | select(.id==\"$dep\") | (.deliverables // [])[]" "$TASKS_INDEX" 2>/dev/null || echo "")
      if [[ -n "$deliverables" ]]; then
        while IFS= read -r file; do
          if [[ -z "$file" ]]; then continue; fi
          if [[ ! -f "$file" ]]; then
            ALL_DONE=false
            MISSING_DELIVERABLES="$MISSING_DELIVERABLES $file"
          fi
        done <<< "$deliverables"
      fi
    fi
  done <<< "$DEPS"

  if [[ "$ALL_DONE" != true ]]; then
    if [[ -n "$MISSING_DELIVERABLES" ]]; then
      # SubagentStop validation failed - deliverables missing
      log_hook_event "PreToolUse" "Task" "$TASK_ID" "deny" "Dependencies marked done but deliverables missing:$MISSING_DELIVERABLES" "{\"depsSatisfied\":false,\"validationFailed\":true,\"missingFiles\":\"$MISSING_DELIVERABLES\"}"

      cat <<JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Task $TASK_ID blocked - previous validation failed. Missing deliverables:$MISSING_DELIVERABLES"}}
JSON
    else
      log_hook_event "PreToolUse" "Task" "$TASK_ID" "deny" "Dependencies not satisfied:$FAILED_DEPS" "{\"depsSatisfied\":false,\"failedDeps\":\"$FAILED_DEPS\"}"

      cat <<JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Task $TASK_ID blocked - dependencies not satisfied:$FAILED_DEPS"}}
JSON
    fi
    exit 2
  fi
fi

# All checks passed - mark task in-progress and allow
# shellcheck disable=SC1091
source "$LIB_DIR/memory.sh" || { echo "ERROR: Unable to source memory.sh" >&2; exit 0; }

# Mark task as in-progress (deterministic operation, logged!)
with_memory_lock "$TASKS_INDEX" memory_update_json "$TASKS_INDEX" \
  ".tasks[] |= if .id == \"$TASK_ID\" then .status=\"in-progress\" else . end" || true

log_hook_event "PreToolUse" "Task" "$TASK_ID" "allow" "Leaf task, dependencies satisfied, marked in-progress" '{"isLeaf":true,"depsSatisfied":true,"statusUpdated":"in-progress"}'

exit 0
