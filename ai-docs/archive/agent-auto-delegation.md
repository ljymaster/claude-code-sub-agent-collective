# Agent Auto‑Delegation and Handoff: Architecture, Rules, and Playbook

## Overview
This document explains how to make agents hand off to each other reliably in this project. Core principle: Only the hub can start subagents. Agents and hooks never invoke the Task tool; instead, agents emit a single-line delegation directive, and the hub auto‑delegates.

Reference: Anthropic Subagents model — the hub delegates subagents, not agents/hooks.
https://docs.anthropic.com/en/docs/claude-code/sub-agents

---

## Roles and Responsibilities
- **Hub (controller)**:
  - Reads last assistant line; if it matches the delegation directive, immediately calls the Task tool for the target subagent.
  - Must not print summaries before delegating (or the directive stops being last).
- **Agents (subagents)**:
  - Do work and end with a single final directive line: “Use the [agent-name] subagent to … now.”
  - Never call Task. Never emit tokens. Never wrap in code blocks.
- **Hooks**:
  - Validation/metrics only. No routing or delegation.

---

## Why agents couldn’t call each other (root causes)
- Only the hub can call the Task tool. Agents/hooks cannot.
- Earlier failures:
  - Delegation line wasn’t the last line (summaries printed after).
  - Non‑ASCII hyphens (“research‑enhanced”) broke pattern matching.
  - Legacy routing hooks printed token prompts and stderr noise.
  - Hub summaries displaced the last agent line, so the rule didn’t trigger.

---

## Auto‑Delegation Trigger Contract
- Exact final line (no code fences, no trailing spaces/lines):
  `Use the [agent-name] subagent to [one-sentence task] now.`
- ASCII only. Example (ASCII hyphen):
  `Use the task-orchestrator subagent to coordinate implementation using the research-enhanced tasks now.`
- Regex the hub uses:
  `^Use the ([a-z0-9-]+) subagent to .+$`

When matched, the hub immediately emits only this tool call (no other output):
```
Task(subagent_type="[agentId]", description="Auto-delegation from directive", prompt="Continue from last agent output and execute next phase.")
```

---

## Agent Authoring Rules (must-follow)
- End every delegating reply with the directive as the final line.
- Use ASCII hyphen “-” (avoid non‑breaking hyphen).
- Do not add any text after the directive (no “I do not invoke tools …”).
- No code blocks, bullets, emojis, or headers after the directive.
- Ensure `name:` in target subagent file matches the directive exactly.

Example tail for a delegating agent:
```
### MANDATORY ENDING:
Use the task-orchestrator subagent to coordinate implementation using the research-enhanced tasks now.
```

---

## Hub Configuration (global, applies to all threads)
- The hub must auto‑delegate before any summary.
- Place this at the top of `CLAUDE.md` (global hub rules):

```
MANDATORY AUTO-DELEGATION (GLOBAL, FIRST ACTION)
- On every turn, BEFORE ANY OUTPUT:
  - If the previous assistant message ends with:
    ^Use the ([a-z0-9-]+) subagent to .+$
  - Then output ONLY:
    Task(subagent_type="[agentId]", description="Auto-delegation from directive", prompt="Continue from last agent output and execute next phase.")
  - Output NOTHING else (no analysis, no headers, no summaries).
- agentId is the regex capture.
```

- Keep the same rule in `/van` if you use `/van`, but ensure the global rule catches direct `@agent` runs too.

---

## Hooks Policy
- Keep hooks validation-only:
  - Enabled: `.claude/hooks/test-driven-handoff.sh`, `collective-metrics.sh`
  - Disabled for routing: `routing-executor.sh`, `handoff-automation.sh`
- Do not attempt routing or Task calls from hooks; hub ignores hook stdout for execution.

---

## Known Good Config Baseline
- `.claude/settings.json`:
  - No routing hooks on PostToolUse:Task.
  - SubagentStop: only `test-driven-handoff.sh` and `collective-metrics.sh`.
- `routing-executor.sh`: no-op (exit 0).
- `mock-prd-research-agent.md`:
  - Ends with the exact ASCII directive as final line.
- `task-orchestrator.md`:
  - No changes required for hub-based auto-delegation.

---

## Testing Playbook
1) Direct agent path (no `/van`):
   - Run `@agent-mock-prd-research-agent`.
   - Verify the agent ends with the final ASCII directive line and nothing after.

2) Observe hub action:
   - The very next hub message must be a Task call:
     `Task(subagent_type="task-orchestrator", ...)`

3) Smoke checks in logs:
   - Hub should not print “Van Collective” or any summary before the Task call.
   - Pre/PostToolUse hooks run; SubagentStop runs validation hooks only.
   - No “HANDOFF_TOKEN” retries/noise.

4) Manual override (if needed):
   - Paste the one-line Task call as the only message:
     `Task(subagent_type="task-orchestrator", description="Auto-delegation from mock PRD research", prompt="Continue from mock-prd-research-agent output and coordinate implementation now.")`

---

## Troubleshooting Checklist
- Delegation line is the final non-empty line; no text after.
- ASCII hyphen is used in “research-enhanced”.
- Hub auto-delegation rule is global (in `CLAUDE.md`), executes before summaries.
- No routing hooks enabled; validation-only hooks are fine.
- Subagent `name:` matches directive name exactly.
- No mid-stream aborts or OOMs observed in logs.

---

## FAQ
- Q: Why did `task-orchestrator` seem to work “without changes” before?
  - A: It was launched via a direct Task tool call by the hub/user, not auto-delegation from text.

- Q: Can agents call Task themselves?
  - A: No. Only the hub can invoke Task. Agents emit the directive; the hub executes.

- Q: Can hooks trigger Task?
  - A: Not in this setup. Hook stdout is parsed/logged but not executed.

---

## Appendix: Log Patterns
- Successful auto‑delegation:
  - “executePreToolHooks called for tool: Task”
  - “task-orchestrator(Auto-delegation from directive)”

- Failure modes:
  - “The mock-prd-research-agent … routing to the task-orchestrator …” with no Task call after (hub summary displaced the directive).
  - Any “HANDOFF_TOKEN” messages (legacy routing still active).

