# Phase 5 Remediation: Command System

## Evidence (Present)
- Command parsing and system libs in `claude-code-collective/lib/*`
- Tests: `command-system.test.js`
- Docs: `claude-code-collective/docs/COMMAND-USAGE.md`

## Gaps
- No end-to-end tests from CLI entrypoint
- No routing accuracy metrics emitted
- No error-code taxonomy for command failures

## Remediation Steps
- Add E2E test invoking CLI with `/van`-style commands
- Emit metrics to NDJSON logs for routing accuracy
- Define error codes; ensure surfaced to users and logs

## DoD
- CLI E2E test passes; metrics visible; errors standardized
