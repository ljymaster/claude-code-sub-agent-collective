# /van logging - Deterministic Logging System Control

Control the deterministic logging system for hooks and memory operations.

## Subcommands

### `/van logging enable`

Enable the deterministic logging system.

**What you do:**
Run the deterministic logging enable script using the Bash tool:

```bash
bash .claude/memory/lib/logging-enable.sh
```

**What the script does (automatically):**
- Creates `.claude/memory/.logging-enabled` toggle file
- Creates log directories
- Initializes log files
- Verifies toggle file was created
- Displays confirmation message

**Output the script's message to the user directly.** The script guarantees deterministic behavior.

### `/van logging disable`

Disable the deterministic logging system.

**What you do:**
Run the deterministic logging disable script using the Bash tool:

```bash
bash .claude/memory/lib/logging-disable.sh
```

**What the script does (automatically):**
- Removes `.claude/memory/.logging-enabled` toggle file
- Verifies toggle file was removed
- Preserves existing logs
- Displays confirmation message

**Output the script's message to the user directly.** The script guarantees deterministic behavior.

### `/van logging status`

Show current logging status and recent activity.

**What you do:**
Run the deterministic logging status script using the Bash tool:

```bash
bash .claude/memory/lib/logging-status.sh
```

**What the script does (automatically):**
- Checks if logging is enabled (toggle file exists)
- Shows recent hook events (last 5)
- Shows recent memory operations (last 5)
- Provides query commands for log analysis
- Displays status report

**Output the script's message to the user directly.** The script guarantees deterministic behavior.

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
