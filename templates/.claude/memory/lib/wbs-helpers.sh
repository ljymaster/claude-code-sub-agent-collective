#!/usr/bin/env bash
# Deterministic helper functions for WBS operations
# Depends on memory.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/memory.sh"

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

