# Phase 3 Remediation: Hook Integration

## Evidence (Present)
- Hooks present: `.claude/hooks/*.sh`
- Settings wired: `.claude/settings.json` (PreToolUse, PostToolUse, SubagentStop)

## Gaps
- Hooks do not validate JSON Schemas (tasks/state/handoff)
- No standardized NDJSON logging contract enforced
- No lock/atomic write guarantees around `.taskmaster/*`

## Remediation Steps
- Add schema validation in hooks (use `ajv` or Python validator)
- Standardize logs to `.taskmaster/reports/execution.log.ndjson`
- Add file locking and atomic writes for `tasks.json` and `state.json`
- Ensure hooks trigger next agent via `next_actions` contract

## DoD
- Hooks reject invalid payloads/files; write NDJSON logs
- Writes are atomic and race-safe; next actions trigger reliably
