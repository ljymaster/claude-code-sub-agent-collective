# Hook Contracts (Claude Code)

Status: Current (v3)
Purpose: Define input/output contracts for hooks we use

---

## Events Used

- `SessionStart` — one-time initialization
- `PreToolUse` — decision gate before tool runs (TDD gate)
- `SubagentStop` — validation after subagent completes (tests + deliverables)

---

## Input Shape

Hooks receive JSON on stdin. The exact shape may evolve; the following fields are commonly available and safe to rely on where present:

```json
{
  "tool_name": "Edit|Write|Bash|Task|...",
  "tool_input": {
    "file_path": "src/Foo.ts",
    "path": "src/Foo.ts",
    "prompt": "Work on task 1.2.3"
  }
}
```

Notes:
- Not all tools include `file_path`/`path`. TDD gate must handle missing file path.
- For Task tool, prefer structured IDs over parsing `prompt`.

---

## Output Shape

Hooks must write a JSON object with `hookSpecificOutput` to stdout.

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse|SubagentStop|...",
    "permissionDecision": "allow|deny",
    "permissionDecisionReason": "Human-readable reason"
  }
}
```

Exit codes:
- `0` → Proceed normally
- `2` → Block the action (deny)

Claude Code uses both the JSON and exit code to determine behavior.

---

## Implemented Hooks

### 1) TDD Gate (PreToolUse)

File: `templates/hooks/tdd-gate.sh`

Behavior:
- Applies to `Edit|Write` only
- Allows: test files, docs, configs
- For implementation files: requires a matching test to exist
- Denies with clear instructions if missing

### 2) Subagent Validation (SubagentStop)

File: `templates/hooks/subagent-validation.sh`

Behavior:
- Identifies an `in-progress` task in `.claude/memory/task-index.json`
- Runs `npm test` if available
- Verifies deliverables (if listed)
- On success: marks task `done`, updates index, propagates status
- On failure: returns `deny` and blocks Hub

---

## Best Practices

- Source `.claude/memory/lib/memory.sh` and use deterministic ops
- Avoid parsing IDs from free text when possible; prefer structured task input
- Keep outputs small and deterministic; avoid noisy logs on stdout

