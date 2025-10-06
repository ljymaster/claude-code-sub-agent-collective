#!/usr/bin/env bash
# Deterministic helper functions for WBS operations
# Depends on memory.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/memory.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/logging.sh" 2>/dev/null || true

TASKS_INDEX=".claude/memory/task-index.json"

_require_index() {
  if [[ ! -f "$TASKS_INDEX" ]]; then
    echo "ERROR: Missing $TASKS_INDEX" >&2
    return 1
  fi
  return 0
}

get_parent() {
  local id="$1"
  # 1.2.3 -> 1.2 ; 1 -> empty
  if [[ "$id" == *.* ]]; then
    echo "$id" | sed 's/\.[^.]*$//'
  else
    echo ""
  fi
}

get_children() {
  local parent_id="$1"
  _require_index || return 1
  jq -r ".tasks[] | select(.parent==\"$parent_id\") | .id" "$TASKS_INDEX"
}

get_leaf_tasks() {
  _require_index || return 1
  jq -r '.tasks[] | select((.children == [] or .children == null)) | .id' "$TASKS_INDEX"
}

calculate_rollup() {
  local parent_id="$1"
  _require_index || return 1

  # Validate parent task exists
  local parent_exists
  parent_exists=$(jq --arg pid "$parent_id" '[.tasks[] | select(.id==$pid)] | length' "$TASKS_INDEX")
  if [[ "$parent_exists" -eq 0 ]]; then
    echo "ERROR: Parent task $parent_id does not exist in task hierarchy" >&2
    return 1
  fi

  local summary
  summary=$(jq --arg pid "$parent_id" '
    . as $root | (
      [ .tasks[] | select(.parent==$pid) ]
    ) as $kids |
    {
      total: ($kids | length),
      done: ($kids | map(select(.status=="done")) | length)
    }' "$TASKS_INDEX") || return 1

  local total done parent_status
  total=$(jq -r '.total' <<<"$summary")
  done=$(jq -r '.done' <<<"$summary")

  if (( done == total )) && (( total > 0 )); then
    parent_status="done"
  elif (( done > 0 )); then
    parent_status="in-progress"
  else
    parent_status="pending"
  fi

  with_memory_lock "$TASKS_INDEX" memory_update_json "$TASKS_INDEX" \
    ".tasks[] |= if .id == \"$parent_id\" then (.status = \"$parent_status\" | .progress = {completed: $done, total: $total}) else . end"

  # Log rollup calculation
  log_rollup "$parent_id" "null" "$parent_status" "$done/$total"
}

propagate_status_up() {
  local task_id="$1"
  local current="$task_id"

  while [[ -n "$current" ]]; do
    local parent
    parent=$(get_parent "$current")
    if [[ -z "$parent" ]] || [[ "$parent" == "$current" ]]; then
      break
    fi
    calculate_rollup "$parent" || return 1
    current="$parent"
  done
}

find_next_available_task() {
  _require_index || return 1

  # Find all pending leaf tasks
  local pending_tasks
  pending_tasks=$(jq -r '.tasks[] | select(.type=="task" and .status=="pending" and (.children | length) == 0) | .id' "$TASKS_INDEX")

  # Check each task to see if dependencies are satisfied
  for task_id in $pending_tasks; do
    # Get dependencies for this task
    local deps
    deps=$(jq -r --arg tid "$task_id" '.tasks[] | select(.id == $tid) | .dependencies[]? // empty' "$TASKS_INDEX")

    # If no dependencies, this task is available
    if [[ -z "$deps" ]]; then
      echo "$task_id"
      return 0
    fi

    # Check if all dependencies are done
    local all_done=true
    for dep_id in $deps; do
      local dep_status
      dep_status=$(jq -r --arg did "$dep_id" '.tasks[] | select(.id == $did) | .status' "$TASKS_INDEX")
      if [[ "$dep_status" != "done" ]]; then
        all_done=false
        break
      fi
    done

    # If all dependencies done, this task is available
    if [[ "$all_done" = true ]]; then
      echo "$task_id"
      return 0
    fi
  done

  # No available tasks
  return 1
}

