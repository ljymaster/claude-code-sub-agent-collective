# Memory System Implementation Strategy

**Date**: 2025-10-01
**Status**: Implementation Ready
**Purpose**: Build the DETERMINISTIC MEMORY LAYER (foundation for everything else)

---

## CRITICAL: What This Document Is About

**This document**: The memory system - deterministic file storage
**NOT this document**: The task system - that comes later

**Do not confuse these two systems.**

---

## Executive Summary

**What we're building**: A deterministic file-based storage layer that GUARANTEES consistent operations.

**Core principle**: Every read/write operation must be atomic, verified, and deterministic.

**Why**: The task system (and any other system) needs a reliable foundation. If memory operations are non-deterministic, everything built on top is non-deterministic.

**Decision**: Use Claude Code's Read/Write/Edit tools with atomic operation patterns.

---

## The Deterministic Memory Layer

### What Makes It Deterministic

**1. Atomic Operations**
```bash
# Write to temp, verify, atomic move
echo "$content" > file.tmp
cat file.tmp > /dev/null || exit 1  # Verify readable
mv file.tmp file                     # Atomic move
cat file > /dev/null || exit 1       # Verify worked
```

**2. Verification**
```bash
# Every operation verified
write_memory() && verify_write() || rollback()
```

**3. Consistent Behavior**
```bash
# Same input → Same result
write_memory "data.json" "content"  # Always succeeds or always fails
```

**4. Known States**
```bash
# Operations leave system in known state
# Success: File contains content
# Failure: Original file unchanged (or doesn't exist)
```

### Storage Location & Scalability

**CRITICAL DESIGN DECISION: File-Per-Entity Pattern**

**DO NOT store collections in single files.**

**Bad (Not Scalable):**
```bash
.claude/memory/
└── tasks.json          # ❌ All 1000 tasks in one file
```

**Good (Scalable):**
```bash
.claude/memory/
├── tasks/
│   ├── 1.json          # ✅ Just task 1 data
│   ├── 2.json          # ✅ Just task 2 data
│   ├── 3.json          # ✅ Just task 3 data
│   └── ...
└── task-index.json     # ✅ Lightweight index (IDs, status, deps only)
```

**Why File-Per-Entity:**

1. **Scalability** - Query one entity = read one file (not 1000)
2. **Performance** - Update one entity = write one file (not 1000)
3. **Concurrency** - Two agents can update different entities simultaneously
4. **Atomicity** - Updating entity 1 cannot corrupt entity 2
5. **Git-friendly** - Diff shows exactly what changed

**This is how Git works:**
```bash
.git/objects/
├── ab/cd1234...  # One commit object
├── ef/5678ab...  # One tree object
└── gh/90ijkl...  # One blob object
```

**Index Pattern:**

**Index file** (small, for coordination):
```json
{
  "version": "1.0.0",
  "entities": [
    {"id": "1", "status": "done"},
    {"id": "2", "status": "in-progress"},
    {"id": "3", "status": "pending"}
  ]
}
```

**Entity file** (full data):
```json
{
  "id": "1",
  "title": "Entity Title",
  "description": "Full description...",
  "status": "done",
  "metadata": {...},
  "largeFields": [...]
}
```

**Operations:**
- **Query one**: Read `.claude/memory/entities/1.json`
- **Find by criteria**: Read index, filter, then read matching entities
- **Update one**: Update entity file + update index

**Rules:**
- All memory operations happen in `.claude/memory/`
- Path validation prevents escape
- Only text-based files (.json, .md, .txt, .yaml)
- Collections use file-per-entity + index pattern

**Why**: Human-readable, Git-trackable, directly queryable, SCALABLE

---

### Hierarchical Structures (WBS Pattern)

**For hierarchical data** (Work Breakdown Structure, nested tasks, etc.), use **ID encoding** in flat structure:

```bash
.claude/memory/
├── tasks/
│   ├── 1.json          # Epic (top level)
│   ├── 1.1.json        # Feature (child of 1)
│   ├── 1.1.1.json      # Task (child of 1.1)
│   ├── 1.1.2.json      # Task (child of 1.1)
│   ├── 1.1.3.json      # Task (child of 1.1)
│   ├── 1.2.json        # Feature (child of 1)
│   ├── 1.2.1.json      # Task (child of 1.2)
│   └── ...
└── task-index.json     # Index with parent/children relationships
```

**ID encoding rules:**
- `1` = Epic (depth 1)
- `1.1` = Feature (depth 2, parent is `1`)
- `1.1.1` = Task (depth 3, parent is `1.1`)
- `1.1.2` = Task (depth 3, parent is `1.1`)

**Benefits:**
- ✅ **Flat file structure** - Simple to navigate
- ✅ **Hierarchy encoded in ID** - `1.1.1` is obviously child of `1.1`
- ✅ **Standard WBS numbering** - Industry standard format
- ✅ **Easy queries** - `ls tasks/1.1.*` gets all children of 1.1
- ✅ **Depth calculation** - Count dots: `1.1.1` has 2 dots = depth 3
- ✅ **Parent calculation** - Remove last segment: `1.1.1` → `1.1`

**Recommended depth limit: 3 levels**
- Level 1: Epic (large features, 1-3 months)
- Level 2: Feature (user stories, 1-2 weeks)
- Level 3: Task (atomic work, 1-3 days)

**Example task file** (tasks/1.1.1.json):
```json
{
  "id": "1.1.1",
  "type": "task",
  "parent": "1.1",
  "title": "Setup Vite",
  "status": "done",
  "children": [],
  "dependencies": []
}
```

**Example parent file** (tasks/1.1.json):
```json
{
  "id": "1.1",
  "type": "feature",
  "parent": "1",
  "title": "Infrastructure",
  "status": "in-progress",
  "children": ["1.1.1", "1.1.2", "1.1.3"],
  "progress": {"completed": 1, "total": 3}
}
```

---

### Helper Scripts for Hierarchical Operations

**Store deterministic operations in** `.claude/memory/lib/wbs-helpers.sh`:

```bash
#!/bin/bash
# Deterministic helper functions for WBS operations

get_parent() {
  local id=$1
  echo "$id" | sed 's/\.[^.]*$//'  # 1.2.3 → 1.2
}

get_children() {
  local parent_id=$1
  jq -r ".tasks[] | select(.parent==\"$parent_id\") | .id" .claude/memory/task-index.json
}

get_leaf_tasks() {
  # Only tasks with no children (atomic work)
  jq -r '.tasks[] | select(.children == [] or .children == null) | .id' \
    .claude/memory/task-index.json
}

calculate_rollup() {
  local parent_id=$1
  local children=$(get_children "$parent_id")

  local total=0
  local done=0

  for child in $children; do
    total=$((total + 1))
    status=$(jq -r ".tasks[] | select(.id==\"$child\") | .status" \
      .claude/memory/task-index.json)
    if [ "$status" = "done" ]; then
      done=$((done + 1))
    fi
  done

  # Determine parent status
  if [ $done -eq $total ]; then
    parent_status="done"
  elif [ $done -gt 0 ]; then
    parent_status="in-progress"
  else
    parent_status="pending"
  fi

  # Atomic update
  memory_update_json ".claude/memory/task-index.json" \
    ".tasks[] |= if .id == \"$parent_id\" then
      .status = \"$parent_status\" |
      .progress = {completed: $done, total: $total}
    else . end"
}

propagate_status_up() {
  local task_id=$1
  local current=$task_id

  # Walk up hierarchy, updating each parent
  while [ -n "$current" ]; do
    parent=$(get_parent "$current")
    if [ -z "$parent" ] || [ "$parent" = "$current" ]; then
      break
    fi

    calculate_rollup "$parent"
    current=$parent
  done
}
```

**These are PURE LOGIC - deterministic, testable, reliable.**

**Key principle:** LLM decides WHAT to do, scripts ensure HOW is done consistently.

---

## Core Deterministic Operations

### Path Validation (Required for ALL operations)

```bash
validate_memory_path() {
  local path="$1"

  # Must be in .claude/memory/
  if [[ ! "$path" =~ ^\.claude/memory/ ]]; then
    echo "ERROR: Path must be in .claude/memory/" >&2
    return 1
  fi

  # Prevent directory traversal
  if [[ "$path" =~ \.\. ]]; then
    echo "Error: Directory traversal not allowed" >&2
    return 1
  fi

  # Only allow text files
  if [[ ! "$path" =~ \.(json|md|txt|yaml|yml)$ ]]; then
    echo "ERROR: Only text files allowed (.json, .md, .txt, .yaml)" >&2
    return 1
  fi

  return 0
}
```

**EVERY operation MUST call this first. No exceptions.**

---

### Atomic Write Operation

```bash
memory_write() {
  local file="$1"
  local content="$2"

  # 1. Validate path
  validate_memory_path "$file" || return 1

  # 2. Write to temp file
  echo "$content" > "${file}.tmp" || {
    echo "ERROR: Failed to write temp file" >&2
    return 1
  }

  # 3. Verify temp file is readable
  cat "${file}.tmp" > /dev/null 2>&1 || {
    echo "ERROR: Temp file not readable" >&2
    rm -f "${file}.tmp"
    return 1
  }

  # 4. Atomic move (POSIX guarantees this is atomic)
  mv "${file}.tmp" "$file" || {
    echo "ERROR: Atomic move failed" >&2
    rm -f "${file}.tmp"
    return 1
  }

  # 5. Verify final file is readable
  cat "$file" > /dev/null 2>&1 || {
    echo "ERROR: Final file not readable" >&2
    return 1
  }

  # Success
  return 0
}
```

**Guarantees:**
- ✅ Either succeeds completely or fails completely
- ✅ No partial writes
- ✅ Original file unchanged on failure
- ✅ Verified readable after write

---

### Atomic Read Operation

```bash
memory_read() {
  local file="$1"

  # 1. Validate path
  validate_memory_path "$file" || return 1

  # 2. Check file exists
  if [ ! -f "$file" ]; then
    echo "ERROR: File does not exist: $file" >&2
    return 1
  fi

  # 3. Read and verify
  cat "$file" || {
    echo "ERROR: Failed to read file: $file" >&2
    return 1
  }

  return 0
}
```

**Guarantees:**
- ✅ File exists check before read
- ✅ Read operation verified
- ✅ Errors returned on failure

---

### Atomic Update Operation (for JSON)

```bash
memory_update_json() {
  local file="$1"
  local jq_expression="$2"

  # 1. Validate path
  validate_memory_path "$file" || return 1

  # 2. Check file exists
  if [ ! -f "$file" ]; then
    echo "ERROR: File does not exist: $file" >&2
    return 1
  fi

  # 3. Apply jq transformation to temp file
  jq "$jq_expression" "$file" > "${file}.tmp" || {
    echo "ERROR: jq transformation failed" >&2
    rm -f "${file}.tmp"
    return 1
  }

  # 4. Verify temp file is valid JSON
  jq empty "${file}.tmp" 2>/dev/null || {
    echo "ERROR: Result is not valid JSON" >&2
    rm -f "${file}.tmp"
    return 1
  }

  # 5. Atomic move
  mv "${file}.tmp" "$file" || {
    echo "ERROR: Atomic move failed" >&2
    rm -f "${file}.tmp"
    return 1
  }

  # Success
  return 0
}
```

**Guarantees:**
- ✅ Original file unchanged if jq fails
- ✅ Result is valid JSON
- ✅ Atomic replacement
- ✅ No corruption

---

## Summary: The Three Core Operations

**These are the ONLY operations anyone should use:**

### 1. `memory_write(file, content)`
- Creates or overwrites file
- Atomic operation
- Verified after write
- Returns 0 on success, 1 on failure

### 2. `memory_read(file)`
- Reads file contents
- Verifies file exists
- Returns content on stdout
- Returns 1 on failure

### 3. `memory_update_json(file, jq_expression)`
- Updates JSON file atomically
- Validates result is valid JSON
- Original unchanged on failure
- Returns 0 on success, 1 on failure

---

## How Other Systems Use This

**Task System** would use these operations:
```bash
# Read current tasks
content=$(memory_read ".claude/memory/tasks.json")

# Update task status
memory_update_json ".claude/memory/tasks.json" \
  '.tasks[0].status = "done"'

# Write new project
memory_write ".claude/memory/project.json" "$new_project_data"
```

**Any System** can use these operations - they're generic.

---

## What Makes This Deterministic

1. **Path Validation** - Same path always validated same way
2. **Atomic Operations** - No partial states
3. **Verification** - Every operation verified
4. **Error Handling** - Consistent error behavior
5. **Known States** - Success or failure leaves system in known state

**Result**: Same operation → Same outcome → Deterministic

---

## Implementation Checklist

- [ ] Create `.claude/memory/` directory
- [ ] Implement `validate_memory_path()` function
- [ ] Implement `memory_write()` function
- [ ] Implement `memory_read()` function
- [ ] Implement `memory_update_json()` function
- [ ] Test atomic operations (kill process mid-write)
- [ ] Test concurrent access
- [ ] Test error recovery
- [ ] Document for other systems to use

---

## This Is The Foundation

**Do not build anything on top until this works perfectly.**

The task system, validation hooks, and everything else depends on this being deterministic.

---

**Status**: Ready to implement
**Next**: Build these three functions and test thoroughly
