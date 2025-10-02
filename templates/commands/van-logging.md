# /van logging - Logging System Control

Control the deterministic logging system for hooks and memory operations.

## Subcommands

### `/van logging enable`
Enable logging system to capture hook executions, memory operations, and status roll-ups.

**Steps:**
1. Create `.claude/memory/.logging-enabled` toggle file
2. Display confirmation message with log directory location
3. Explain what will be logged (hooks, memory ops, roll-ups)

**Output:**
```
📊 Logging enabled - logs in .claude/memory/logs/current/

What gets logged:
- Hook executions (pre-agent-deploy, subagent-validation, tdd-gate)
- Memory operations (reads, writes, updates)
- WBS status roll-ups (parent status calculations)

Log files:
- hooks.jsonl - All hook decisions and checks
- memory.jsonl - All memory/WBS operations
- session-info.json - Session metadata

Use 'jq' to query logs:
  jq -r 'select(.type=="hook") | [.ts, .hook, .decision, .reason] | @tsv' .claude/memory/logs/current/hooks.jsonl
```

### `/van logging disable`
Disable logging system to stop capturing events.

**Steps:**
1. Remove `.claude/memory/.logging-enabled` toggle file
2. Display confirmation message
3. Note that existing logs are preserved

**Output:**
```
📊 Logging disabled

Existing logs preserved in .claude/memory/logs/current/
To re-enable: /van logging enable
```

### `/van logging status`
Show current logging status and recent activity summary.

**Steps:**
1. Check if `.claude/memory/.logging-enabled` exists
2. If enabled, show:
   - Status: ENABLED
   - Log directory location
   - Recent hook activity count (last 10 entries)
   - Recent memory operations count (last 10 entries)
   - Last logged event timestamp
3. If disabled, show:
   - Status: DISABLED
   - How to enable

**Output (Enabled):**
```
📊 Logging Status: ENABLED
📂 Log Directory: .claude/memory/logs/current/

Recent Activity:
- Hooks: 15 events (last: 2025-10-02T14:32:15Z)
- Memory: 23 operations (last: 2025-10-02T14:32:10Z)

Last Hook Events:
  2025-10-02T14:32:15Z | PreToolUse    | allow | Leaf task, dependencies satisfied
  2025-10-02T14:30:42Z | SubagentStop  | allow | Validation passed
  2025-10-02T14:28:19Z | PreToolUse    | deny  | Task has children

Commands:
  /van logging disable - Stop logging
  jq '.type == "hook"' .claude/memory/logs/current/hooks.jsonl - Query hook logs
```

**Output (Disabled):**
```
📊 Logging Status: DISABLED

To enable logging:
  /van logging enable

What gets logged when enabled:
- Hook execution decisions (allow/deny/ask)
- Memory operations (read/write/update)
- WBS status roll-ups
```

### `/van logging query <type>`
Query recent log entries by type.

**Arguments:**
- `<type>` - Log type to query: `hooks`, `memory`, or `all`

**Steps:**
1. Check logging is enabled
2. Use `jq` to extract and format recent entries
3. Display in human-readable format

**Output:**
```
📊 Recent Hook Events (last 20):

2025-10-02T14:32:15Z | PreToolUse    | Task | 1.2.3 | allow | Leaf task, dependencies satisfied
  Checks: {"isLeaf":true,"depsSatisfied":true}

2025-10-02T14:30:42Z | SubagentStop  | -    | 1.2.3 | allow | Validation passed
  Checks: {"testsPass":true,"deliverablesExist":true}

2025-10-02T14:28:19Z | PreToolUse    | Task | 1.2   | deny  | Task has children: 1.2.1 1.2.2
  Checks: {"isLeaf":false,"children":"1.2.1 1.2.2"}
```

### `/van logging archive`
Archive current session logs and start fresh.

**Steps:**
1. Check if current logs exist
2. Create archive directory: `.claude/memory/logs/archive/<timestamp>/`
3. Move current logs to archive
4. Display confirmation

**Output:**
```
📊 Logs archived to .claude/memory/logs/archive/2025-10-02T14-35-42Z/

Archived files:
- hooks.jsonl (1,247 events)
- memory.jsonl (3,892 operations)
- session-info.json

New session started - logs will write to .claude/memory/logs/current/
```

## Implementation Notes

All commands use the logging library functions from `.claude/memory/lib/logging.sh`:
- `is_logging_enabled()` - Check toggle state
- `enable_logging()` - Create toggle file
- `disable_logging()` - Remove toggle file
- `get_logging_status()` - Get current status

Commands should use `jq` for querying JSONL logs and format output clearly for human readability.
