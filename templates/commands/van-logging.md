# /van logging - Deterministic Logging System Control

Control the deterministic logging system for hooks and memory operations.

## Subcommands

### `/van logging enable`

Enable the deterministic logging system.

**Steps:**
1. Create `.claude/memory/.logging-enabled` toggle file (empty file)
2. Create log directory structure
3. Display confirmation with instructions

**Implementation:**
```bash
# Create toggle file
touch .claude/memory/.logging-enabled

# Create log directories
mkdir -p .claude/memory/logs/current

# Display confirmation
```

**Output:**
```
📊 Logging System ENABLED

Deterministic logging is now active. Hooks will log:
- Hook execution decisions (PreToolUse, SubagentStop)
- Memory operations (write, read, update)
- WBS rollup calculations

Log files (JSONL format):
- .claude/memory/logs/current/hooks.jsonl
- .claude/memory/logs/current/memory.jsonl

Query logs with jq:
  jq '.type == "hook"' .claude/memory/logs/current/hooks.jsonl
  jq '.type == "memory"' .claude/memory/logs/current/memory.jsonl

Disable: /van logging disable
Status: /van logging status
```

### `/van logging disable`

Disable the deterministic logging system.

**Steps:**
1. Remove `.claude/memory/.logging-enabled` toggle file
2. Display confirmation

**Implementation:**
```bash
# Remove toggle file
rm -f .claude/memory/.logging-enabled

# Display confirmation
```

**Output:**
```
📊 Logging System DISABLED

Hooks will no longer write log entries.
Existing logs preserved in .claude/memory/logs/current/

To re-enable: /van logging enable
```

### `/van logging status`

Show current logging status and recent activity.

**Steps:**
1. Check if `.claude/memory/.logging-enabled` exists
2. If enabled:
   - Show status and log locations
   - Read last 5 entries from hooks.jsonl
   - Read last 5 entries from memory.jsonl
   - Show summary
3. If disabled:
   - Show how to enable

**Implementation:**
```bash
# Check toggle file
if [[ -f .claude/memory/.logging-enabled ]]; then
  echo "Status: ENABLED"

  # Show recent hook events
  tail -5 .claude/memory/logs/current/hooks.jsonl

  # Show recent memory operations
  tail -5 .claude/memory/logs/current/memory.jsonl
else
  echo "Status: DISABLED"
fi
```

**Output (Enabled):**
```
📊 Logging Status: ENABLED

Recent Hook Events (last 5):
{"ts":"2025-10-02T14:32:15Z","type":"hook","hook":"PreToolUse","tool":"Task","taskId":"1.2.3","decision":"allow",...}
{"ts":"2025-10-02T14:30:42Z","type":"hook","hook":"SubagentStop","taskId":"1.2.3","decision":"allow",...}

Recent Memory Operations (last 5):
{"ts":"2025-10-02T14:32:16Z","type":"memory","op":"update","file":".claude/memory/task-index.json",...}
{"ts":"2025-10-02T14:32:17Z","type":"rollup","taskId":"1.2","newStatus":"done","progress":"2/2"}

Commands:
  /van logging disable - Stop logging
  jq -r '.hook' .claude/memory/logs/current/hooks.jsonl - Query hooks
```

**Output (Disabled):**
```
📊 Logging Status: DISABLED

To enable: /van logging enable

When enabled, hooks will log:
- PreToolUse decisions (task validation)
- SubagentStop decisions (completion validation)
- Memory writes/updates
- WBS rollup calculations
```

## Implementation Notes

**CRITICAL:** The logging system uses `.claude/memory/.logging-enabled` as the toggle file.

**Hooks check:**
```bash
source .claude/memory/lib/logging.sh
if is_logging_enabled; then
  log_hook_event "PreToolUse" "Task" "$TASK_ID" "allow" "reason" '{"data":"value"}'
fi
```

**The toggle file:**
- Empty file, just needs to exist
- Location: `.claude/memory/.logging-enabled`
- Created by: `/van logging enable`
- Removed by: `/van logging disable`
- Checked by: `is_logging_enabled()` function in logging.sh

**Log format:**
- JSONL (one JSON object per line)
- Use `jq` for querying
- Append-only for performance
- Atomic writes via logging.sh functions
