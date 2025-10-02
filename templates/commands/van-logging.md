# /van logging - Deterministic Logging System Control

Control the deterministic logging system for hooks and memory operations.

## Subcommands

### `/van logging enable`

Enable the deterministic logging system.

**Implementation:**
Execute the logging enable script:
```bash
bash .claude/memory/lib/logging-enable.sh
```

This script GUARANTEES:
- Toggle file `.claude/memory/.logging-enabled` is created
- Log directories exist
- Log files are initialized
- System verifies toggle file creation

**CRITICAL:** Do NOT manually run commands. Always use the script to ensure deterministic behavior.

### `/van logging disable`

Disable the deterministic logging system.

**Implementation:**
Execute the logging disable script:
```bash
bash .claude/memory/lib/logging-disable.sh
```

This script GUARANTEES:
- Toggle file `.claude/memory/.logging-enabled` is removed
- System verifies toggle file deletion
- Existing logs are preserved

**CRITICAL:** Do NOT manually run commands. Always use the script to ensure deterministic behavior.

### `/van logging status`

Show current logging status and recent activity.

**Implementation:**
Execute the logging status script:
```bash
bash .claude/memory/lib/logging-status.sh
```

This script:
- Checks if logging is enabled (toggle file exists)
- Shows recent hook events (last 5)
- Shows recent memory operations (last 5)
- Provides query commands for log analysis

**CRITICAL:** Do NOT manually run commands. Always use the script to ensure deterministic behavior.

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
