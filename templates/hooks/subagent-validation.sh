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

# If no index exists, nothing to validate
if [[ ! -f "$TASKS_INDEX" ]]; then
  echo '{"hookSpecificOutput":{"hookEventName":"SubagentStop","permissionDecision":"allow","permissionDecisionReason":"No task index present"}}'
  exit 0
fi

# Determine current in-progress task (first LEAF match - tasks with no children)
TASK_ID=$(jq -r '.tasks[] | select(.status=="in-progress" and (.children == [] or .children == null)) | .id' "$TASKS_INDEX" | head -n1)

if [[ -z "${TASK_ID:-}" || "$TASK_ID" == "null" ]]; then
  echo '{"hookSpecificOutput":{"hookEventName":"SubagentStop","permissionDecision":"allow","permissionDecisionReason":"No in-progress task detected"}}'
  exit 0
fi

tests_pass=true
deliverables_exist=true
test_msg=""

# Run tests if npm available and test script likely exists
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

# Check deliverables from index (optional)
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

  # Update index status
  with_memory_lock "$TASKS_INDEX" memory_update_json "$TASKS_INDEX" \
    ".tasks[] |= if .id == \"$TASK_ID\" then .status=\"done\" else . end"

  # Roll up
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

