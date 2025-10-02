#!/usr/bin/env bash
# Deterministic Logging Library
# Provides hook-enforced logging for task system verification and audit trail

set -euo pipefail

MEMORY_DIR=".claude/memory"
LOG_DIR="$MEMORY_DIR/logs/current"
TOGGLE_FILE="$MEMORY_DIR/.logging-enabled"

# Check if logging is enabled (deterministic file-based check)
is_logging_enabled() {
  [[ -f "$TOGGLE_FILE" ]]
}

# Enable logging
enable_logging() {
  mkdir -p "$LOG_DIR"
  touch "$TOGGLE_FILE"
  echo "📊 Logging enabled - logs in $LOG_DIR/" >&2
}

# Disable logging
disable_logging() {
  rm -f "$TOGGLE_FILE"
  echo "📊 Logging disabled" >&2
}

# Get logging status
get_logging_status() {
  if is_logging_enabled; then
    echo "ENABLED"
  else
    echo "DISABLED"
  fi
}

# Log hook execution
# Args: hook_name tool_name task_id decision reason checks_json
log_hook_event() {
  if ! is_logging_enabled; then return 0; fi

  local hook="$1"
  local tool="${2:-}"
  local task_id="${3:-}"
  local decision="${4:-}"
  local reason="${5:-}"
  local checks="${6:-{}}"

  local ts
  ts=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Escape quotes in reason
  reason="${reason//\"/\\\"}"

  mkdir -p "$LOG_DIR"

  cat >> "$LOG_DIR/hooks.jsonl" <<JSON
{"ts":"$ts","type":"hook","hook":"$hook","tool":"$tool","taskId":"$task_id","decision":"$decision","reason":"$reason","checks":$checks}
JSON
}

# Log memory operation
# Args: operation file_path extra_json
log_memory_operation() {
  if ! is_logging_enabled; then return 0; fi

  local op="$1"
  local file="$2"
  local extra="${3:-}"

  local ts
  ts=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

  mkdir -p "$LOG_DIR"

  if [[ -n "$extra" ]]; then
    cat >> "$LOG_DIR/memory.jsonl" <<JSON
{"ts":"$ts","type":"memory","op":"$op","file":"$file",$extra}
JSON
  else
    cat >> "$LOG_DIR/memory.jsonl" <<JSON
{"ts":"$ts","type":"memory","op":"$op","file":"$file"}
JSON
  fi
}

# Log status roll-up
# Args: task_id parent_id new_status progress
log_rollup() {
  if ! is_logging_enabled; then return 0; fi

  local task_id="$1"
  local parent_id="${2:-null}"
  local new_status="$3"
  local progress="${4:-}"

  local ts
  ts=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

  mkdir -p "$LOG_DIR"

  if [[ -n "$progress" ]]; then
    cat >> "$LOG_DIR/memory.jsonl" <<JSON
{"ts":"$ts","type":"rollup","taskId":"$task_id","parentId":"$parent_id","newStatus":"$new_status","progress":"$progress"}
JSON
  else
    cat >> "$LOG_DIR/memory.jsonl" <<JSON
{"ts":"$ts","type":"rollup","taskId":"$task_id","parentId":"$parent_id","newStatus":"$new_status"}
JSON
  fi
}

# Rotate logs if they exceed max lines
# Args: log_file max_lines
rotate_logs_if_needed() {
  local log_file="$1"
  local max_lines="${2:-10000}"

  if [[ ! -f "$log_file" ]]; then
    return 0
  fi

  local line_count
  line_count=$(wc -l < "$log_file" 2>/dev/null || echo "0")

  if [[ $line_count -gt $max_lines ]]; then
    local timestamp
    timestamp=$(date -u +"%Y%m%d-%H%M%S")
    mv "$log_file" "${log_file}.${timestamp}"

    # Compress in background
    gzip "${log_file}.${timestamp}" &
    disown

    echo "📊 Rotated log file: ${log_file}.${timestamp}.gz" >&2
  fi
}

# Initialize session logging
init_session_logging() {
  if ! is_logging_enabled; then
    return 0
  fi

  mkdir -p "$LOG_DIR"

  local ts
  ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  cat > "$LOG_DIR/session-info.json" <<JSON
{
  "sessionId": "$ts",
  "startTime": "$ts",
  "loggingEnabled": true
}
JSON
}
