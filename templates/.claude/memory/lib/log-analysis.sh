#!/usr/bin/env bash
# Log Analysis Tools
# Helper functions for querying and analyzing deterministic logs

set -euo pipefail

MEMORY_DIR=".claude/memory"
LOG_DIR="$MEMORY_DIR/logs/current"

# Verify jq is available
require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required for log analysis" >&2
    return 1
  fi
}

# Check if logs exist
check_logs_exist() {
  if [[ ! -d "$LOG_DIR" ]]; then
    echo "ERROR: No logs found at $LOG_DIR" >&2
    echo "Logging may not be enabled. Run: /van logging enable" >&2
    return 1
  fi
}

# Get recent hook events
# Usage: get_recent_hooks [limit]
get_recent_hooks() {
  local limit="${1:-20}"
  local hooks_log="$LOG_DIR/hooks.jsonl"

  require_jq || return 1
  check_logs_exist || return 1

  if [[ ! -f "$hooks_log" ]]; then
    echo "No hook events logged yet" >&2
    return 0
  fi

  tail -n "$limit" "$hooks_log" | jq -r '
    [.ts, .hook, .tool // "-", .taskId // "-", .decision, .reason] | @tsv
  ' | while IFS=$'\t' read -r ts hook tool task decision reason; do
    printf "%s | %-15s | %-4s | %-6s | %-5s | %s\n" \
      "$ts" "$hook" "$tool" "$task" "$decision" "$reason"
  done
}

# Get recent memory operations
# Usage: get_recent_memory [limit]
get_recent_memory() {
  local limit="${1:-20}"
  local memory_log="$LOG_DIR/memory.jsonl"

  require_jq || return 1
  check_logs_exist || return 1

  if [[ ! -f "$memory_log" ]]; then
    echo "No memory operations logged yet" >&2
    return 0
  fi

  tail -n "$limit" "$memory_log" | jq -r '
    if .type == "rollup" then
      [.ts, "rollup", .taskId, .newStatus, .progress // "-"] | @tsv
    else
      [.ts, .op, .file, "-", "-"] | @tsv
    end
  ' | while IFS=$'\t' read -r ts op file status progress; do
    if [[ "$op" == "rollup" ]]; then
      printf "%s | %-8s | Task %-6s → %-12s (%s)\n" \
        "$ts" "$op" "$file" "$status" "$progress"
    else
      printf "%s | %-8s | %s\n" "$ts" "$op" "$file"
    fi
  done
}

# Count events by type
# Usage: count_events <hooks|memory>
count_events() {
  local log_type="$1"
  local log_file="$LOG_DIR/${log_type}.jsonl"

  require_jq || return 1
  check_logs_exist || return 1

  if [[ ! -f "$log_file" ]]; then
    echo "0"
    return 0
  fi

  wc -l < "$log_file"
}

# Get last event timestamp
# Usage: get_last_event_time <hooks|memory>
get_last_event_time() {
  local log_type="$1"
  local log_file="$LOG_DIR/${log_type}.jsonl"

  require_jq || return 1
  check_logs_exist || return 1

  if [[ ! -f "$log_file" ]] || [[ ! -s "$log_file" ]]; then
    echo "No events"
    return 0
  fi

  tail -n 1 "$log_file" | jq -r '.ts'
}

# Query hooks by decision type
# Usage: query_hooks_by_decision <allow|deny|ask>
query_hooks_by_decision() {
  local decision="$1"
  local hooks_log="$LOG_DIR/hooks.jsonl"

  require_jq || return 1
  check_logs_exist || return 1

  if [[ ! -f "$hooks_log" ]]; then
    echo "No hook events logged yet" >&2
    return 0
  fi

  jq -r --arg dec "$decision" '
    select(.decision == $dec) |
    [.ts, .hook, .tool // "-", .taskId // "-", .reason] | @tsv
  ' "$hooks_log" | while IFS=$'\t' read -r ts hook tool task reason; do
    printf "%s | %-15s | %-4s | %-6s | %s\n" \
      "$ts" "$hook" "$tool" "$task" "$reason"
  done
}

# Query hooks by task ID
# Usage: query_hooks_by_task <task_id>
query_hooks_by_task() {
  local task_id="$1"
  local hooks_log="$LOG_DIR/hooks.jsonl"

  require_jq || return 1
  check_logs_exist || return 1

  if [[ ! -f "$hooks_log" ]]; then
    echo "No hook events logged yet" >&2
    return 0
  fi

  jq -r --arg tid "$task_id" '
    select(.taskId == $tid) |
    [.ts, .hook, .decision, .reason, (.checks | tostring)] | @tsv
  ' "$hooks_log" | while IFS=$'\t' read -r ts hook decision reason checks; do
    echo "─────────────────────────────────────────────────────────────"
    printf "Time:     %s\n" "$ts"
    printf "Hook:     %s\n" "$hook"
    printf "Decision: %s\n" "$decision"
    printf "Reason:   %s\n" "$reason"
    printf "Checks:   %s\n" "$checks"
    echo ""
  done
}

# Get rollup history for a task
# Usage: query_rollups_by_task <task_id>
query_rollups_by_task() {
  local task_id="$1"
  local memory_log="$LOG_DIR/memory.jsonl"

  require_jq || return 1
  check_logs_exist || return 1

  if [[ ! -f "$memory_log" ]]; then
    echo "No memory operations logged yet" >&2
    return 0
  fi

  jq -r --arg tid "$task_id" '
    select(.type == "rollup" and .taskId == $tid) |
    [.ts, .newStatus, .progress // "-"] | @tsv
  ' "$memory_log" | while IFS=$'\t' read -r ts status progress; do
    printf "%s | %s → %-12s (%s)\n" "$ts" "$task_id" "$status" "$progress"
  done
}

# Generate summary report
# Usage: generate_summary
generate_summary() {
  require_jq || return 1
  check_logs_exist || return 1

  local hooks_log="$LOG_DIR/hooks.jsonl"
  local memory_log="$LOG_DIR/memory.jsonl"

  echo "════════════════════════════════════════════════════════════"
  echo "  Logging System Summary"
  echo "════════════════════════════════════════════════════════════"
  echo ""

  # Hook statistics
  if [[ -f "$hooks_log" ]]; then
    local total_hooks
    total_hooks=$(wc -l < "$hooks_log" 2>/dev/null || echo 0)

    local allow_count deny_count ask_count
    allow_count=$(jq -r 'select(.decision=="allow")' "$hooks_log" 2>/dev/null | wc -l || echo 0)
    deny_count=$(jq -r 'select(.decision=="deny")' "$hooks_log" 2>/dev/null | wc -l || echo 0)
    ask_count=$(jq -r 'select(.decision=="ask")' "$hooks_log" 2>/dev/null | wc -l || echo 0)

    echo "Hook Events: $total_hooks total"
    echo "  • Allowed: $allow_count"
    echo "  • Denied:  $deny_count"
    echo "  • Asked:   $ask_count"
    echo ""

    # Last hook event
    local last_hook_time
    last_hook_time=$(get_last_event_time "hooks")
    echo "  Last event: $last_hook_time"
    echo ""
  else
    echo "Hook Events: 0 (no hooks.jsonl found)"
    echo ""
  fi

  # Memory statistics
  if [[ -f "$memory_log" ]]; then
    local total_memory
    total_memory=$(wc -l < "$memory_log" 2>/dev/null || echo 0)

    local read_count write_count update_count rollup_count
    read_count=$(jq -r 'select(.op=="read")' "$memory_log" 2>/dev/null | wc -l || echo 0)
    write_count=$(jq -r 'select(.op=="write")' "$memory_log" 2>/dev/null | wc -l || echo 0)
    update_count=$(jq -r 'select(.op=="update")' "$memory_log" 2>/dev/null | wc -l || echo 0)
    rollup_count=$(jq -r 'select(.type=="rollup")' "$memory_log" 2>/dev/null | wc -l || echo 0)

    echo "Memory Operations: $total_memory total"
    echo "  • Reads:   $read_count"
    echo "  • Writes:  $write_count"
    echo "  • Updates: $update_count"
    echo "  • Rollups: $rollup_count"
    echo ""

    # Last memory event
    local last_memory_time
    last_memory_time=$(get_last_event_time "memory")
    echo "  Last event: $last_memory_time"
    echo ""
  else
    echo "Memory Operations: 0 (no memory.jsonl found)"
    echo ""
  fi

  echo "════════════════════════════════════════════════════════════"
}

# Verify system is working (check for recent activity)
# Usage: verify_system_activity [minutes]
verify_system_activity() {
  local minutes="${1:-5}"

  require_jq || return 1
  check_logs_exist || return 1

  local cutoff_time
  cutoff_time=$(date -u -d "$minutes minutes ago" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || \
                date -u -v-${minutes}M +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || \
                echo "1970-01-01T00:00:00Z")

  local hooks_log="$LOG_DIR/hooks.jsonl"
  local memory_log="$LOG_DIR/memory.jsonl"

  local recent_hooks=0
  local recent_memory=0

  if [[ -f "$hooks_log" ]]; then
    recent_hooks=$(jq -r --arg cutoff "$cutoff_time" \
      'select(.ts >= $cutoff)' "$hooks_log" 2>/dev/null | wc -l || echo 0)
  fi

  if [[ -f "$memory_log" ]]; then
    recent_memory=$(jq -r --arg cutoff "$cutoff_time" \
      'select(.ts >= $cutoff)' "$memory_log" 2>/dev/null | wc -l || echo 0)
  fi

  echo "Activity in last $minutes minutes:"
  echo "  • Hook events: $recent_hooks"
  echo "  • Memory operations: $recent_memory"

  if (( recent_hooks > 0 || recent_memory > 0 )); then
    echo ""
    echo "✅ System is actively logging"
    return 0
  else
    echo ""
    echo "⚠️  No recent activity (may be idle or logging disabled)"
    return 1
  fi
}
