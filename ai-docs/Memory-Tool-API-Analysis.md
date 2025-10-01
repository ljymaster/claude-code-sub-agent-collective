# Memory Tool API Analysis

**Date**: 2025-10-01
**Purpose**: Complete analysis of Anthropic's memory tool for potential integration into our deterministic task system

---

## Executive Summary

**Key Finding**: Anthropic has a production-ready memory tool (`memory_20250818`) that provides file-based persistent storage across Claude conversations. **However, this tool is NOT available in Claude Code CLI** - it's only available via the Claude API.

**For Claude Code**: We must implement our own file-based memory system using Read/Write tools, which is exactly what the DETERMINISTIC-TASK-SYSTEM-DESIGN.md proposes.

---

## Memory Tool Overview

### What It Is

- **Client-side file management system** for Claude's long-term memory
- **Persistent across conversations** - survives session boundaries
- **Secure path validation** - prevents directory traversal attacks
- **Multiple operations** - view, create, replace, insert, delete, rename

### Where It Works

✅ **Claude API** (via anthropic-python SDK)
✅ **Amazon Bedrock**
✅ **Google Cloud Vertex AI**
❌ **Claude Code CLI** (NOT available)

---

## Tool Definition

### Registration

```python
tools = [
    {
        "type": "memory_20250818",
        "name": "memory"
    }
]

# Required beta header
betas = ["context-management-2025-06-27"]
```

### Tool Schema

The tool accepts a single JSON object with a `command` parameter and command-specific parameters.

---

## Available Commands

### 1. `view` - Show directory or file contents

**Parameters**:
- `path` (required): Path starting with `/memories`
- `view_range` (optional): `[start_line, end_line]` for partial file reads

**Returns**:
```json
{"success": "Directory: /memories/projects\n- project1.md\n- project2.json"}
```

**Example**:
```json
{
  "command": "view",
  "path": "/memories"
}
```

---

### 2. `create` - Create or overwrite a file

**Parameters**:
- `path` (required): File path (must end in .txt, .md, .json, .py, .yaml, .yml)
- `file_text` (required): Content to write

**Returns**:
```json
{"success": "File created successfully at /memories/tasks.json"}
```

**Example**:
```json
{
  "command": "create",
  "path": "/memories/tasks.json",
  "file_text": "{\"version\": \"1.0.0\", \"tasks\": []}"
}
```

---

### 3. `str_replace` - Replace exact text in a file

**Parameters**:
- `path` (required): File path
- `old_str` (required): Exact string to find (must be unique)
- `new_str` (required): Replacement string

**Returns**:
```json
{"success": "File /memories/tasks.json has been edited successfully"}
```

**Error if string appears multiple times**:
```json
{"error": "String appears 3 times in /memories/tasks.json. The string must be unique. Use more specific context."}
```

**Example**:
```json
{
  "command": "str_replace",
  "path": "/memories/tasks.json",
  "old_str": "\"status\": \"pending\"",
  "new_str": "\"status\": \"done\""
}
```

---

### 4. `insert` - Insert text at specific line number

**Parameters**:
- `path` (required): File path
- `insert_line` (required): Line number (0-indexed)
- `insert_text` (required): Text to insert

**Returns**:
```json
{"success": "Text inserted at line 5 in /memories/notes.md"}
```

**Example**:
```json
{
  "command": "insert",
  "path": "/memories/notes.md",
  "insert_line": 5,
  "insert_text": "## New Section"
}
```

---

### 5. `delete` - Delete a file or directory

**Parameters**:
- `path` (required): Path to delete (cannot be `/memories` root)

**Returns**:
```json
{"success": "File deleted: /memories/old-tasks.json"}
```

**Example**:
```json
{
  "command": "delete",
  "path": "/memories/old-tasks.json"
}
```

---

### 6. `rename` - Rename or move a file/directory

**Parameters**:
- `old_path` (required): Source path
- `new_path` (required): Destination path (must not exist)

**Returns**:
```json
{"success": "Renamed /memories/draft.md to /memories/final.md"}
```

**Example**:
```json
{
  "command": "rename",
  "old_path": "/memories/draft.md",
  "new_path": "/memories/final.md"
}
```

---

## Implementation Details

### Security Features

#### 1. Path Validation

All paths must:
- Start with `/memories`
- Not attempt directory traversal (`../`, etc.)
- Stay within the memory root directory

```python
def _validate_path(self, path: str) -> Path:
    if not path.startswith("/memories"):
        raise ValueError("Path must start with /memories")

    # Resolve to absolute path
    full_path = (self.memory_root / relative_path).resolve()

    # Verify still within memory_root
    full_path.relative_to(self.memory_root.resolve())

    return full_path
```

#### 2. File Type Restrictions

The `create` command only allows:
- `.txt`
- `.md`
- `.json`
- `.py`
- `.yaml` / `.yml`

This prevents creating arbitrary binary files or directories.

#### 3. Unique String Replacement

The `str_replace` command requires the `old_str` to appear exactly once:

```python
count = content.count(old_str)
if count == 0:
    return {"error": "String not found"}
elif count > 1:
    return {"error": f"String appears {count} times. Must be unique."}
```

This prevents accidental mass replacements.

---

## Storage Architecture

### Directory Structure

```
./memory_storage/
└── memories/
    ├── projects/
    │   ├── auth-system.md
    │   └── tasks.json
    ├── patterns/
    │   └── code-review-learnings.md
    └── notes.txt
```

### File Organization

**Recommended structure** (from cookbook):

```
/memories/
  ├── current_project/       # Active project state
  │   ├── tasks.json
  │   └── progress.md
  ├── patterns/              # Learned patterns
  │   ├── architecture.md
  │   └── conventions.md
  └── cross_session/         # Persistent knowledge
      └── preferences.json
```

---

## Python Implementation

### Complete Handler Class

```python
from pathlib import Path
from typing import Any

class MemoryToolHandler:
    def __init__(self, base_path: str = "./memory_storage"):
        self.base_path = Path(base_path).resolve()
        self.memory_root = self.base_path / "memories"
        self.memory_root.mkdir(parents=True, exist_ok=True)

    def execute(self, **params: Any) -> dict[str, str]:
        """Execute memory tool command"""
        command = params.get("command")

        if command == "view":
            return self._view(params)
        elif command == "create":
            return self._create(params)
        elif command == "str_replace":
            return self._str_replace(params)
        elif command == "insert":
            return self._insert(params)
        elif command == "delete":
            return self._delete(params)
        elif command == "rename":
            return self._rename(params)
        else:
            return {"error": f"Unknown command: {command}"}
```

### Usage with Claude API

```python
import anthropic

client = anthropic.Anthropic(api_key="your-api-key")

response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    tools=[{"type": "memory_20250818", "name": "memory"}],
    betas=["context-management-2025-06-27"],
    messages=[{
        "role": "user",
        "content": "Remember that our authentication system uses JWT tokens"
    }]
)

# Handle tool use
for content in response.content:
    if content.type == "tool_use":
        result = memory_handler.execute(**content.input)
        # Send result back to Claude...
```

---

## Comparison: Memory Tool vs Our File-Based Approach

| Feature | Memory Tool (API) | Our Approach (Claude Code) |
|---------|------------------|---------------------------|
| **Availability** | ❌ API only | ✅ Works in Claude Code |
| **Storage** | `./memory_storage/memories/` | `.claude/memory/` |
| **Operations** | 6 commands (view, create, etc.) | Read/Write/Edit tools |
| **Path Validation** | Built-in security | We implement manually |
| **Persistence** | ✅ Survives sessions | ✅ File-based (Git tracked) |
| **Claude Access** | ✅ Native tool | ✅ Direct file reads |
| **Human Readable** | ✅ Text files | ✅ JSON files |
| **Hook Access** | ❌ Needs API call | ✅ Direct jq/bash access |
| **Atomic Updates** | Single-file operations | We implement with temp files |

---

## Key Insights for Our Design

### 1. File-Based is Correct

The memory tool uses **file-based storage**, not a database. This validates our design approach of using `.claude/memory/tasks.json`.

### 2. Security Matters

The memory tool has extensive path validation. We should implement similar safeguards in our hooks:

```bash
# Hook validation example
validate_path() {
  local path=$1
  case "$path" in
    .claude/memory/*) return 0 ;;
    *) echo "Invalid path: $path" >&2; return 1 ;;
  esac
}
```

### 3. Atomic Operations

The memory tool operates on **single files at a time**. For atomic updates to `tasks.json`, we should use:

```bash
# Atomic update pattern
jq '.tasks[0].status = "done"' tasks.json > tasks.json.tmp
mv tasks.json.tmp tasks.json  # Atomic on POSIX systems
```

### 4. Error Handling

The memory tool returns structured errors:
```json
{"error": "String not found in file"}
{"success": "File created successfully"}
```

Our hooks should do the same via `hookSpecificOutput`.

### 5. No Database Needed

The memory tool proves that **simple file operations** are sufficient for persistent state management. We don't need SQLite or external APIs.

---

## What This Means for Our Implementation

### ✅ Validated Decisions

1. **JSON files in `.claude/memory/`** - Correct approach (matches memory tool philosophy)
2. **Read/Write/Edit tools** - Correct implementation (Claude Code equivalent of memory tool)
3. **Hooks read/write files directly** - Correct (bash + jq is fine)
4. **No external API needed** - Correct (everything is local files)

### 🆕 New Best Practices

1. **Path validation in hooks**:
   ```bash
   if [[ ! "$path" =~ ^\.claude/memory/ ]]; then
     echo "Error: Invalid path" >&2
     exit 1
   fi
   ```

2. **Atomic updates with temp files**:
   ```bash
   jq '...' tasks.json > tasks.json.tmp && mv tasks.json.tmp tasks.json
   ```

3. **Structured error returns**:
   ```json
   {"hookSpecificOutput": {
     "permissionDecision": "deny",
     "permissionDecisionReason": "Task validation failed: tests not found"
   }}
   ```

4. **File type restrictions**:
   - Only allow `.json` files in `.claude/memory/`
   - Prevent accidental writes outside memory directory

### 📋 Implementation Checklist

- [ ] Create memory directory: `.claude/memory/`
- [ ] Implement path validation in hooks
- [ ] Use atomic updates (temp files + mv)
- [ ] Add error handling with structured returns
- [ ] Restrict file types to `.json`
- [ ] Document memory schema in templates
- [ ] Add memory validation to `/van:validate` command

---

## Conclusion

**The memory tool validates our entire approach.** Anthropic's production implementation uses:

1. ✅ File-based storage (not database)
2. ✅ Simple CRUD operations
3. ✅ Client-side execution
4. ✅ Path validation for security
5. ✅ Persistent across sessions

**Our plan is sound.** We'll implement the same concepts using Claude Code's Read/Write/Edit tools, with hooks providing the enforcement layer.

**Next Steps**:

1. Implement `.claude/memory/tasks.json` schema
2. Update hooks with path validation
3. Add atomic update mechanisms
4. Test memory persistence across sessions
5. Document memory system in user guide

---

**References**:

- Memory Tool Source: https://github.com/anthropics/claude-cookbooks/blob/main/tool_use/memory_tool.py
- Memory Cookbook: https://github.com/anthropics/claude-cookbooks/blob/main/tool_use/memory_cookbook.ipynb
- Context Management: https://www.anthropic.com/news/context-management
- Claude 4.5 Release: https://docs.claude.com/en/docs/about-claude/models/whats-new-sonnet-4-5
