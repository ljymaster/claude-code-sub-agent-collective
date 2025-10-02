#!/usr/bin/env bash
# SubagentStop validation hook
# Validates work (tests + deliverables) and updates task memory deterministically

set -euo pipefail

MEMORY_DIR=".claude/memory"
TASKS_INDEX="$MEMORY_DIR/task-index.json"
LIB_DIR="$MEMORY_DIR/lib"

# shellcheck disable=SC1091
source "$LIB_DIR/memory.sh" || { echo "ERROR: Unable to source memory.sh" >&2; exit 0; }
# shellcheck disable=SC1091
source "$LIB_DIR/wbs-helpers.sh" || { echo "ERROR: Unable to source wbs-helpers.sh" >&2; exit 0; }
# shellcheck disable=SC1091
source "$LIB_DIR/logging.sh" 2>/dev/null || true

# Read JSON input from stdin
INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null || echo "false")

# Prevent infinite loops when stop hook is already active
if [[ "$STOP_HOOK_ACTIVE" == "true" ]]; then
  echo '{"hookSpecificOutput":{"hookEventName":"SubagentStop","permissionDecision":"allow","permissionDecisionReason":"Stop hook already active"}}'
  exit 0
fi

# If no index exists, nothing to validate
if [[ ! -f "$TASKS_INDEX" ]]; then
  echo '{"hookSpecificOutput":{"hookEventName":"SubagentStop","permissionDecision":"allow","permissionDecisionReason":"No task index present"}}'
  exit 0
fi

# Extract task ID from transcript (find last Task tool use)
TASK_ID=""
if [[ -n "$TRANSCRIPT_PATH" && -f "$TRANSCRIPT_PATH" ]]; then
  # Parse transcript to find the most recent Task tool call
  TASK_ID=$(jq -r '
    [.[] | select(.type == "tool_use" and .name == "Task")] |
    .[-1].input.prompt // empty
  ' "$TRANSCRIPT_PATH" 2>/dev/null | grep -oiP '(?<=task\s)[0-9]+(\.[0-9]+)*' | head -n1 || echo "")
fi

# Fallback: look for in-progress leaf task
if [[ -z "$TASK_ID" ]]; then
  TASK_ID=$(jq -r '.tasks[] | select(.status=="in-progress" and (.children == [] or .children == null)) | .id' "$TASKS_INDEX" | head -n1)
fi

if [[ -z "${TASK_ID:-}" || "$TASK_ID" == "null" ]]; then
  echo '{"hookSpecificOutput":{"hookEventName":"SubagentStop","permissionDecision":"allow","permissionDecisionReason":"No task detected for validation"}}'
  exit 0
fi

tests_pass=true
deliverables_exist=true
test_msg=""

# Run tests if npm available and test script exists
if command -v npm >/dev/null 2>&1; then
  if npm run -s | grep -q " test" 2>/dev/null; then
    if npm test >/tmp/claude-tests.log 2>&1; then
      tests_pass=true
      test_msg="Tests passed"
    else
      tests_pass=false
      test_msg="Tests failed"
    fi
  fi
fi

# Check deliverables from index
DELIVERABLES=$(jq -r ".tasks[] | select(.id==\"$TASK_ID\") | (.deliverables // [])[]?" "$TASKS_INDEX" 2>/dev/null || echo "")
if [[ -n "$DELIVERABLES" ]]; then
  while IFS= read -r f; do
    if [[ -z "$f" ]]; then continue; fi
    if [[ ! -f "$f" ]]; then
      deliverables_exist=false
    fi
  done <<< "$DELIVERABLES"
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [[ "$tests_pass" == true && "$deliverables_exist" == true ]]; then
  # Log validation success
  log_hook_event "SubagentStop" "" "$TASK_ID" "allow" "Validation passed" "{\"testsPass\":$tests_pass,\"deliverablesExist\":$deliverables_exist}"

  # Update task entity (if exists)
  TASK_FILE="$MEMORY_DIR/tasks/${TASK_ID}.json"
  if [[ -f "$TASK_FILE" ]]; then
    memory_update_json "$TASK_FILE" ".status=\"done\" | .completedAt=\"$TIMESTAMP\"" || true
  fi

  # Update index status via memory.sh (LOGGED!)
  with_memory_lock "$TASKS_INDEX" memory_update_json "$TASKS_INDEX" \
    ".tasks[] |= if .id == \"$TASK_ID\" then .status=\"done\" else . end"

  # Roll up via wbs-helpers.sh (LOGGED!)
  propagate_status_up "$TASK_ID" || true

  cat <<JSON
{"hookSpecificOutput":{"hookEventName":"SubagentStop","permissionDecision":"allow","permissionDecisionReason":"Task $TASK_ID validated: tests=$tests_pass, deliverables=$deliverables_exist"}}
JSON
  exit 0
else
  # Log validation failure
  log_hook_event "SubagentStop" "" "$TASK_ID" "deny" "Validation failed" "{\"testsPass\":$tests_pass,\"deliverablesExist\":$deliverables_exist}"

  cat <<JSON
{"hookSpecificOutput":{"hookEventName":"SubagentStop","permissionDecision":"deny","permissionDecisionReason":"Task $TASK_ID validation failed: tests=$tests_pass, deliverables=$deliverables_exist"}}
JSON
  exit 2
fi
