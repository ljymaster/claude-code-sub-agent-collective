# Claude Code Collective — User Guide (v3)

Last Updated: 2025-10-01

---

## Quick Start

Install templates into your project:

```bash
npx claude-code-collective init
```

Key files created:
- `.claude/settings.json` — hook configuration
- `.claude/memory.md` — behavioral memory (always loaded)
- `.claude/memory/lib/*` — deterministic memory ops
- `.claude/hooks/*` — TDD gate + Subagent validation
- `.claude/agents/*` — specialized agents

---

## Modes (Output Styles)

Switch behavior without custom commands:

- `/output-style tdd-mode` — strict TDD flow
- `/output-style collective-mode` — full orchestration with agents
- `/output-style research-mode` — documentation-first

Tip: See `templates/.claude/output-styles/` for details.

---

## Deterministic Memory

Location: `.claude/memory/`

- File-per-entity under `tasks/` (e.g., `1.json`, `1.2.3.json`)
- Lightweight index: `task-index.json`
- Deterministic library: `.claude/memory/lib/memory.sh`
  - `memory_write(file, content)`
  - `memory_read(file)`
  - `memory_update_json(file, jq_expression)`

See ai-docs/MEMORY-SCHEMA.md for normative schemas.

---

## Hooks (Enforcement Gates)

Configured in `.claude/settings.json`:

- `PreToolUse` — TDD Gate (`tdd-gate.sh`)
  - Applies to `Edit|Write`
  - Allows tests/docs/configs
  - For implementation files, requires matching tests

- `SubagentStop` — Validation Gate (`subagent-validation.sh`)
  - After a subagent completes
  - Runs tests (if available)
  - Verifies deliverables (if listed)
  - Updates task status and propagates roll-up

Hook contracts: ai-docs/HOOK-CONTRACTS.md

---

## Typical Workflow (TDD)

1) RED — `@test-first-agent` writes failing tests
2) GREEN — Implementation agent makes tests pass
3) REFACTOR — `@tdd-validation-agent` validates and suggests next step
4) BROWSER (conditional) — `@chrome-devtools-testing-agent` for UI

Determinism:
- TDD gate blocks non-test-first edits
- Subagent gate blocks completion without tests/deliverables
- Memory updates are atomic and verified

---

## Minimal Commands You Need

- Switch mode: `/output-style tdd-mode`
- Inspect memory: open `.claude/memory/task-index.json`
- Add/modify tasks: use hooks + memory library (agents and Hub manage when possible)

Legacy: `/van` still exists for older flows, but v3 favors output styles and hook-enforced orchestration.

---

## Key Files

- `.claude/settings.json` — hooks
- `.claude/memory/lib/memory.sh` — deterministic ops
- `.claude/memory/lib/wbs-helpers.sh` — roll-up helpers
- `.claude/hooks/tdd-gate.sh` — TDD enforcement
- `.claude/hooks/subagent-validation.sh` — SubagentStop validation

---

## Troubleshooting

- Hook not firing? Restart Claude Code after changes
- `jq` missing? Install it: `brew install jq` or your package manager
- No tests configured? Subagent validation skips tests if none are defined

