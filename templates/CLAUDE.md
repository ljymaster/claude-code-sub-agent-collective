## Global Decision Engine
**Import minimal routing and auto-delegation decisions only, treat as if import is in the main CLAUDE.md file.**
@./.claude-collective/DECISION.md

## Memory-Based Task System
**Import task breakdown methodology and execution workflow, treat as if import is in the main CLAUDE.md file.**
@./.claude-collective/task-system.md

## Deterministic Logging System

The collective includes a deterministic logging system that captures complete audit trails of hook decisions and memory operations during `/van` workflow execution.

### How to Use Logging

**Enable logging:**
```
/van logging enable
```

This creates the toggle file `.claude/memory/.logging-enabled` and initializes log directories. Once enabled, all hooks automatically log their decisions.

**Check logging status:**
```
/van logging status
```

Shows whether logging is enabled and displays recent hook/memory events.

**Disable logging:**
```
/van logging disable
```

Removes the toggle file (stops logging) but preserves existing logs.

### What Gets Logged

When enabled, the system captures:
- **Hook decisions** (hooks.jsonl) - PreToolUse and SubagentStop decisions with reasoning
- **Memory operations** (memory.jsonl) - Task status updates and WBS rollups

Logs are in JSONL format (one JSON object per line) in `.claude/memory/logs/current/`.

### Viewing Logs

```bash
# Count events
wc -l .claude/memory/logs/current/hooks.jsonl
wc -l .claude/memory/logs/current/memory.jsonl

# View hook decisions
jq '.hook + " | " + .decision + " | " + .reason' .claude/memory/logs/current/hooks.jsonl

# View memory operations
jq 'select(.type=="memory") | .op + " | " + .file' .claude/memory/logs/current/memory.jsonl

# View WBS rollups
jq 'select(.type=="rollup") | "Task " + .taskId + " → " + .newStatus' .claude/memory/logs/current/memory.jsonl
```

### Why Logging is Useful

- **Debugging** - Understand why workflows succeeded or failed
- **Research** - Analyze agent behavior and hook decisions
- **Audit trails** - Complete record of all workflow activities
- **Deterministic behavior** - Scripts guarantee toggle file creation (not instruction-based)

Logging is opt-in and has zero performance impact when disabled.

## Testing TDD Hooks

The Claude Code Collective uses PreToolUse hooks to enforce TDD workflow. To test that hooks are working correctly:

### Manual Hook Testing (Outside Claude Code Session)

Test hooks directly using bash and JSON input:

```bash
# Test TDD gate blocks implementation without tests
echo '{"tool_name": "Write", "tool_input": {"file_path": "src/MyService.js"}}' | ./.claude/hooks/tdd-gate.sh

# Expected output: permissionDecision = "deny" with TDD violation message

# Test TDD gate allows test file creation
echo '{"tool_name": "Write", "tool_input": {"file_path": "src/MyService.test.js"}}' | ./.claude/hooks/tdd-gate.sh

# Expected output: permissionDecision = "allow"

# Create test file, then test implementation is allowed
touch src/MyService.test.js
echo '{"tool_name": "Write", "tool_input": {"file_path": "src/MyService.js"}}' | ./.claude/hooks/tdd-gate.sh

# Expected output: permissionDecision = "allow" (tests exist)

# Test destructive command blocking
echo '{"tool_name": "Bash", "tool_input": {"command": "rm -rf /"}}' | ./.claude/hooks/block-destructive-commands.sh

# Expected output: permissionDecision = "deny" with blocked message
```

### Live Testing (Within Claude Code Session)

1. Start Claude Code in your project directory: `claude-code`
2. Request implementation WITHOUT tests first: "Create src/OrderService.js with order processing logic"
3. Hook should block with TDD violation message
4. Request test file: "Create src/OrderService.test.js with tests"
5. Hook should allow test creation
6. Request implementation again: "Now create src/OrderService.js implementation"
7. Hook should allow (tests exist)

### Hook Output Format

Hooks use Claude Code's native decision control with `hookSpecificOutput`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow" | "deny" | "ask",
    "permissionDecisionReason": "Explanation message"
  }
}
```

### Troubleshooting Hooks

If hooks aren't blocking as expected:

1. **Check hook permissions**: Hooks must be executable (`chmod +x .claude/hooks/*.sh`)
2. **Verify settings.json**: Ensure PreToolUse hooks are configured for Edit/Write tools
3. **Test hook manually**: Run hook scripts directly with sample JSON input (see above)
4. **Check hook output format**: Hooks must output valid `hookSpecificOutput` JSON
5. **Review hook logs**: Check `/tmp/blocked-commands.log` for destructive command hook activity