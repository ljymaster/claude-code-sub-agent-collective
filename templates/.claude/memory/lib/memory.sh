#!/usr/bin/env bash
# Deterministic file-based memory operations for Claude Code projects
# Location: .claude/memory/lib/memory.sh

# Allowed file extensions
_MEMORY_ALLOWED_EXT="json|md|txt|yaml|yml"

# Validate a path is within .claude/memory and allowed
validate_memory_path() {
  local path="$1"

  if [[ -z "$path" ]]; then
    echo "ERROR: Path is required" >&2
    return 1
  fi

  # Must be in .claude/memory/
  if [[ ! "$path" =~ ^\.claude/memory/ ]]; then
    echo "ERROR: Path must be in .claude/memory/ (got: $path)" >&2
    return 1
  fi

  # Prevent directory traversal
  if [[ "$path" =~ (\../|/\.\./|\.{2}$) ]]; then
    echo "ERROR: Directory traversal not allowed ($path)" >&2
    return 1
  fi

  # Only allow text files by extension
  if [[ ! "$path" =~ \.(${_MEMORY_ALLOWED_EXT})$ ]]; then
    echo "ERROR: Only text files allowed (.json, .md, .txt, .yaml, .yml). Got: $path" >&2
    return 1
  fi

  return 0
}

# Ensure directory exists for a file path
_memory_ensure_dir() {
  local file="$1"
  local dir
  dir="$(dirname "$file")"
  mkdir -p "$dir" || {
    echo "ERROR: Failed to create directory: $dir" >&2
    return 1
  }
}

# Atomic write operation: overwrite/create file with provided content
# Usage: memory_write ".claude/memory/tasks/1.json" "$json_content"
memory_write() {
  local file="$1"
  local content="$2"

  validate_memory_path "$file" || return 1
  _memory_ensure_dir "$file" || return 1

  local tmp="${file}.tmp"

  # Write to temp (preserve newlines)
  printf "%s" "$content" > "$tmp" || {
    echo "ERROR: Failed to write temp file: $tmp" >&2
    rm -f "$tmp"
    return 1
  }

  # Verify readable
  cat "$tmp" >/dev/null 2>&1 || {
    echo "ERROR: Temp file not readable: $tmp" >&2
    rm -f "$tmp"
    return 1
  }

  # Atomic move
  mv "$tmp" "$file" || {
    echo "ERROR: Atomic move failed: $tmp → $file" >&2
    rm -f "$tmp"
    return 1
  }

  # Verify final
  cat "$file" >/dev/null 2>&1 || {
    echo "ERROR: Final file not readable: $file" >&2
    return 1
  }

  return 0
}

# Atomic read operation: print file to stdout
# Usage: memory_read ".claude/memory/tasks/1.json"
memory_read() {
  local file="$1"

  validate_memory_path "$file" || return 1

  if [[ ! -f "$file" ]]; then
    echo "ERROR: File does not exist: $file" >&2
    return 1
  fi

  cat "$file" || {
    echo "ERROR: Failed to read file: $file" >&2
    return 1
  }
  return 0
}

# Atomic JSON update using jq transformation
# Usage: memory_update_json ".claude/memory/tasks/1.json" '.status = "done"'
memory_update_json() {
  local file="$1"
  local jq_expression="$2"

  validate_memory_path "$file" || return 1

  if [[ ! -f "$file" ]]; then
    echo "ERROR: File does not exist: $file" >&2
    return 1
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required for JSON updates" >&2
    return 1
  fi

  local tmp="${file}.tmp"

  # Apply transformation
  if ! jq "$jq_expression" "$file" > "$tmp"; then
    echo "ERROR: jq transformation failed for: $file" >&2
    rm -f "$tmp"
    return 1
  fi

  # Validate JSON
  if ! jq empty "$tmp" >/dev/null 2>&1; then
    echo "ERROR: Result is not valid JSON for: $file" >&2
    rm -f "$tmp"
    return 1
  fi

  # Atomic move
  mv "$tmp" "$file" || {
    echo "ERROR: Atomic move failed: $tmp → $file" >&2
    rm -f "$tmp"
    return 1
  }

  return 0
}

# Optional: simple lock wrapper if flock is available
# Usage: with_memory_lock ".claude/memory/task-index.json" -- command args...
with_memory_lock() {
  local file="$1"; shift
  if command -v flock >/dev/null 2>&1; then
    exec 200>"${file}.lock"
    flock 200
    "$@"
    local rc=$?
    flock -u 200
    return $rc
  else
    # No flock; run command directly
    "$@"
  fi
}

