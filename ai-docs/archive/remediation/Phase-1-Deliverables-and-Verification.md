# Phase 1 Deliverables and Verification

## Scope

This document defines the Phase 1 critical deliverables required to make the autonomous agent system execute tools reliably, hand off work, and maintain state. It also verifies which pieces are already present in this repository and identifies precise gaps to close next.

## Phase 1 Deliverables (Definition of Done)

- **D1. Tool Spec Sheets**: Canonical invocation contracts for key MCP tools with examples, parameters, outputs, timeouts, and fallbacks.
- **D2. Global Execution Wrapper**: Shared helper that executes tools with retries, timeouts, structured logs; does not write TaskMaster storage locally.
- **D3. Schema Alignment (Read-Only Validation)**: Validate that TaskMaster outputs the fields consumers rely on (ids, dependencies, routing, gates). No new local schemas; no local writes to TaskMaster storage.
- **D4. Preflight/Health Checks**: Verify MCP connectivity, hook executability, directories, and permissions before launching flows. Do not create TaskMaster storage files locally.
- **D5. Handoff Contract Enforcement**: A strict SubagentStop payload consumed by existing hooks to continue work automatically.
- **D6. Observability Baseline**: NLJSON logs and a simple summarizer for success/error rates, durations, and routing accuracy.

## Repository Verification Matrix

- **Hooks present (partially satisfying D5/D6)**
  - Present: `.claude/hooks/` contains `handoff-automation.sh`, `test-driven-handoff.sh`, `research-evidence-validation.sh`, `routing-executor.sh`, `collective-metrics.sh`.
  - Present: `.claude/settings.json` wires SubagentStop hooks for `prd-research-agent` and generic `.*-agent$`.
  - Action: Ensure hooks validate schemas in D3 and emit logs in D6.

- **Research cache present (supports D1 evidence, research protocol)**
  - Present: `.taskmaster/docs/research/` contains dated research files (2025-08-10_*).
  - Action: Add freshness/quality checks in D4 and D6.

- **Tasks and state storage (owned by TaskMaster MCP)**
  - Current: `.taskmaster/tasks/` exists; files appear once MCP generates tasks.
  - Policy: Treat as read-only; only MCP writes these files.
  - Action: Do not create or modify locally. Preflight should check presence and instruct running TaskMaster generation if absent.

- **Schema alignment (read-only)**
  - Approach: No local schema authorship for TaskMaster storage.
  - Action: Implement a read-only validator that calls `mcp__task-master__get_tasks` and verifies minimal fields we consume.

- **Execution wrapper (missing; blocks D2)**
  - Missing: No shared wrapper detected for standardized tool execution.
  - Action: Implement as a reusable script or module and mandate usage in agents.

- **Preflight (missing; blocks D4)**
  - Missing: No `preflight.sh` found.
  - Action: Add and integrate into entrypoints.

## D1. Tool Spec Sheets

Create one-page spec per tool under `ai-docs/tool-specs/`. Include name, purpose, parameters, defaults, expected outputs, failure modes, timeout, retries, and fallback.

Example specs (abbreviated):

```markdown
Tool: mcp__task-master__parse_prd
Purpose: Generate base TaskMaster tasks from PRD text.
Call: mcp__task-master__parse_prd(projectRoot: string, prdPath: string)
Defaults: projectRoot = $PWD, prdPath = ".taskmaster/docs/prd.txt"
Output: { tasksFile: string, numTasks: number }
Timeout: 60s; Retries: 2 (exponential backoff: 1s, 3s)
Fallback: Use bash to copy PRD to temp and re-invoke; on failure, surface error code.
Notes: Idempotent; updates existing tasks by id when possible.
```

```markdown
Tool: mcp__task-master__get_tasks
Purpose: Load all generated tasks as JSON.
Call: mcp__task-master__get_tasks(projectRoot: string)
Output: { tasks: Task[] } where Task matches schema below.
Timeout: 15s; Retries: 1
```

```markdown
Tool: mcp__task-master__analyze_project_complexity
Purpose: Score complexity and enrich tasks.
Call: mcp__task-master__analyze_project_complexity(projectRoot: string)
Output: { complexityScore: number, annotations: string[] }
Timeout: 30s; Retries: 1
```

```markdown
Tool: mcp__context7__resolve-library-id
Purpose: Resolve library canonical ID for Context7.
Call: mcp__context7__resolve-library-id(libraryName: string)
Output: { context7CompatibleLibraryID: string }
Timeout: 15s; Retries: 2
```

```markdown
Tool: mcp__context7__get-library-docs
Purpose: Fetch relevant docs for a library/topic.
Call: mcp__context7__get-library-docs(context7CompatibleLibraryID: string, topic: string)
Output: { files: string[] } saved into .taskmaster/docs/research/
Timeout: 45s; Retries: 2
```

Notes:
- All tools should accept `projectRoot` defaulting to the current working directory on WSL2 (e.g., `/mnt/h/Active/taskmaster-agent-claude-code`).
- Return payloads must be structured JSON; logs emitted separately.

## D2. Global Execution Wrapper (spec)

Implement as `scripts/exec_tool.sh` or a small module used by agents.

Responsibilities:
- Parameter normalization: ensure `projectRoot`, absolute paths, and defaults.
- Timeout and retries with exponential backoff; configurable via env (`TOOL_TIMEOUT_MS`, `TOOL_MAX_RETRIES`).
- Structured logging (newline-delimited JSON) with fields: `timestamp`, `agent`, `tool`, `taskId`, `attempt`, `durationMs`, `status`, `errorCode`, `message`.
- Idempotent writes: use atomic temp files for `tasks.json` and `state.json`, then move.
- Locking: acquire `.taskmaster/.lock` (flock or mkdir-based) around writes.
- Fallbacks: upon tool failure, optionally run a bash fallback if defined by the spec, then report.

Pseudocode:

```bash
# scripts/exec_tool.sh (interface sketch)
# Usage: exec_tool.sh <toolName> --param key=value ...

set -euo pipefail
TOOL_TIMEOUT_MS=${TOOL_TIMEOUT_MS:-60000}
TOOL_MAX_RETRIES=${TOOL_MAX_RETRIES:-2}

# normalize params, run with retries, capture stdout JSON, emit NLJSON logs, handle fallbacks
```

Mandate: All agents call tools exclusively through this wrapper.

## D3. JSON Schemas

Place under `ai-docs/schemas/` and enforce via hooks.

```json
{
  "$id": "ai-docs/schemas/tasks.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "TaskMaster Tasks",
  "type": "object",
  "required": ["version", "tasks"],
  "properties": {
    "version": { "type": "string", "pattern": "^v[0-9]+\\.[0-9]+$" },
    "generatedAt": { "type": "string", "format": "date-time" },
    "tasks": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "title"],
        "properties": {
          "id": { "type": "string", "pattern": "^[0-9]+(\\.[0-9]+)*$" },
          "title": { "type": "string", "minLength": 3 },
          "description": { "type": "string" },
          "dependencies": { "type": "array", "items": { "type": "string" } },
          "priority": { "type": "string", "enum": ["low", "medium", "high"] },
          "research_context": {
            "type": "object",
            "properties": {
              "technologies": { "type": "array", "items": { "type": "string" } },
              "context7_docs": { "type": "array", "items": { "type": "string" } },
              "cached_research": { "type": "array", "items": { "type": "string" } },
              "key_findings": { "type": "array", "items": { "type": "string" } }
            },
            "additionalProperties": true
          },
          "execution_routing": {
            "type": "object",
            "properties": {
              "primary_agent": { "type": "string" },
              "support_agents": { "type": "array", "items": { "type": "string" } },
              "tdd_requirements": {
                "type": "object",
                "properties": {
                  "test_first": { "type": "boolean" },
                  "coverage_target": { "type": "number", "minimum": 0, "maximum": 100 },
                  "test_types": { "type": "array", "items": { "type": "string" } }
                },
                "additionalProperties": false
              }
            },
            "additionalProperties": true
          },
          "validation_gates": {
            "type": "object",
            "properties": {
              "must_pass_tests": { "type": "boolean" },
              "security_scan": { "type": "boolean" },
              "performance_check": { "type": "boolean" }
            },
            "additionalProperties": false
          },
          "status": { "type": "string", "enum": ["todo", "in_progress", "done", "blocked"] }
        },
        "additionalProperties": true
      }
    }
  },
  "additionalProperties": false
}
```

```json
{
  "$id": "ai-docs/schemas/state.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "TaskMaster State",
  "type": "object",
  "required": ["version", "current_phase", "completed_tasks", "pending_tasks"],
  "properties": {
    "version": { "type": "string", "pattern": "^v[0-9]+\\.[0-9]+$" },
    "current_phase": { "type": "string" },
    "active_agents": { "type": "array", "items": { "type": "string" } },
    "completed_tasks": { "type": "array", "items": { "type": "string" } },
    "pending_tasks": { "type": "array", "items": { "type": "string" } },
    "agent_context": { "type": "object", "additionalProperties": { "type": "object" } },
    "interrupted": { "type": "boolean" },
    "last_checkpoint": { "type": "string" },
    "updatedAt": { "type": "string", "format": "date-time" }
  },
  "additionalProperties": false
}
```

```json
{
  "$id": "ai-docs/schemas/handoff.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Subagent Handoff Payload",
  "type": "object",
  "required": ["agent", "taskId", "status", "artifacts", "next_actions"],
  "properties": {
    "agent": { "type": "string" },
    "taskId": { "type": "string" },
    "status": { "type": "string", "enum": ["success", "partial", "failed"] },
    "summary": { "type": "string" },
    "artifacts": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["path"],
        "properties": {
          "path": { "type": "string" },
          "bytes": { "type": "number", "minimum": 0 },
          "sha256": { "type": "string" },
          "kind": { "type": "string" }
        },
        "additionalProperties": true
      }
    },
    "evidence": { "type": "array", "items": { "type": "string" } },
    "next_actions": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["action", "target"],
        "properties": {
          "action": { "type": "string" },
          "target": { "type": "string" },
          "params": { "type": "object" }
        },
        "additionalProperties": true
      }
    }
  },
  "additionalProperties": false
}
```

Enforcement: Update hooks to validate payloads/files against these schemas (e.g., `jq` + `ajv` in Node or a small Python validator).

## D4. Preflight/Health Checks (spec)

Add `scripts/preflight.sh` and run it before orchestrations and in CI.

Checks:
- Validate directories and permissions: `.taskmaster/docs/research`, `.taskmaster/tasks`, `.taskmaster/reports`.
- Ensure hooks are executable: `chmod +x .claude/hooks/*.sh`.
- MCP health: perform a no-op or light call to each required tool and measure latency.
- WSL2 path sanity: `pwd` resolves to `/mnt/...`; verify write access.
- Ensure TaskMaster storage presence by calling generation tools if needed (do not create files locally).

Example commands:

```bash
[ -d .taskmaster/docs/research ] || mkdir -p .taskmaster/docs/research
[ -d .taskmaster/tasks ] || mkdir -p .taskmaster/tasks
if [ ! -f .taskmaster/tasks/tasks.json ]; then
  echo "ℹ️ TaskMaster tasks file not found. Run MCP generation (e.g., mcp__task-master__parse_prd) to initialize." >&2
fi
if [ ! -f .taskmaster/state.json ]; then
  echo "ℹ️ TaskMaster state file not found. It will be created by the MCP server on first write." >&2
fi
```

## D5. Handoff Contract Enforcement (spec)

- Update `handoff-automation.sh` and `test-driven-handoff.sh` to:
  - Validate SubagentStop payload against `handoff.schema.json`.
  - Append artifacts to a run report under `.taskmaster/reports/`.
  - Trigger next agent based on `next_actions` entries.

## D6. Observability Baseline (spec)

- Logging: NLJSON file at `.taskmaster/reports/execution.log.ndjson`.
- Metrics: lightweight summarizer `scripts/summarize-logs.sh` to compute counts and durations by tool/agent/status.
- Required fields: `timestamp`, `agent`, `tool`, `taskId`, `status`, `durationMs`, `errorCode`, `message`.

## Optional (Nice-to-Have): TaskMaster Storage Protection Hook

Purpose:
- Ensure local agents/hooks cannot modify `.taskmaster/tasks/tasks.json` or `.taskmaster/state.json`.

Approach:
- Add `protect-taskmaster-storage.sh` and register under `PostToolUse` and `SubagentStop`.
- Whitelist `mcp__task-master__*` calls; otherwise block and log if diffs touch those files.
- Optionally auto-revert unintended changes.

## Concrete Next Steps

1. Implement `scripts/exec_tool.sh` and mandate usage in agent specs (no local writes to TaskMaster storage).
2. Add `scripts/preflight.sh`; run before `/van` flows; do not create TaskMaster files locally.
3. Implement read-only validator for TaskMaster outputs and integrate into hooks.
4. Update hooks to enforce handoff contract and write NLJSON logs.
5. (Optional) Add storage protection hook.
6. Re-run the PRD flow; confirm research cache present, tasks generated by MCP, handoffs validated, and orchestration continues automatically.

## Current Status Summary (from repo scan)

- Achieved:
  - Hook framework and wiring in `.claude/settings.json` with SubagentStop and metrics.
  - Research cache exists with multiple 2025-08-10 files.

- Needs Adjustment/Implementation:
  - Missing `tasks.json` and `state.json` files.
  - No JSON Schemas checked in; hooks do not validate structures.
  - No standardized execution wrapper for tool calls.
  - No preflight script; add and integrate.
  - Observability logging is not standardized to NLJSON with summarizer.

Once the above are committed and wired, Phase 1 is considered complete.

## System Assessment Pointer

See `ai-docs/remediation/Phases-Master-Roadmap.md` → System Assessment for an executive review of viability, risks, and next actions tied to this phase.


