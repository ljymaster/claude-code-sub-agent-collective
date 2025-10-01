# Memory Schema (Deterministic File-Based)

Status: Current (v3)
Purpose: Normative JSON schemas and invariants for `.claude/memory/`

---

## Directory Layout

```
.claude/memory/
  tasks/                # One file per entity (epic/feature/task)
    1.json
    1.1.json
    1.1.1.json
    ...
  task-index.json       # Lightweight index for coordination
  lib/                  # Deterministic ops (memory.sh, wbs-helpers.sh)
```

---

## Common Conventions

- Encoding: UTF-8, LF line endings
- File types: `.json` for structured data (required), `.md`/`.txt` for notes
- IDs: Work Breakdown Structure (WBS) style — `1`, `1.1`, `1.1.1`
  - Depth 1: epics, depth 2: features, depth 3: tasks
  - Parent of `a.b.c` is `a.b`; parent of `a` is null
- Status enum: `pending` | `in-progress` | `done`
- Timestamps: ISO-8601 UTC (e.g., `2025-10-01T10:30:00Z`)
- Versioning: `version` field (semver string) in index

---

## task-index.json (Normative)

Minimal contract for coordination; must remain small and fast to read.

```json
{
  "version": "1.0.0",
  "tasks": [
    {
      "id": "1",
      "type": "epic",
      "status": "in-progress",
      "parent": null,
      "children": ["1.1", "1.2"],
      "dependencies": [],
      "progress": { "completed": 3, "total": 7 },
      "deliverables": ["README.md"]
    }
  ]
}
```

Required fields per entry:
- `id` (string, WBS ID)
- `type` (string: `epic` | `feature` | `task`)
- `status` (enum)
- `parent` (string or null)
- `children` (array of strings, may be empty)
- `dependencies` (array of strings, may be empty)

Optional fields:
- `progress` (object: `{completed:number, total:number}`)
- `deliverables` (array of strings)

Invariants:
- Parent/children referential integrity:
  - If A lists B in `children`, then `B.parent == A`
  - Root nodes have `parent == null`
- Status roll-up:
  - If all children `done` → parent `done`
  - If some children `done` → parent `in-progress`
  - If no children `done` → parent `pending`
- Dependencies:
  - A dependency ID must exist in the index

---

## tasks/<id>.json (Entity Files)

Full data for a single entity. Example (task):

```json
{
  "id": "1.2.3",
  "type": "task",
  "title": "Implement LoginForm",
  "description": "Create component and pass tests",
  "status": "in-progress",
  "parent": "1.2",
  "children": [],
  "dependencies": ["1.2.1"],
  "acceptanceCriteria": [
    "All tests pass",
    "No eslint errors"
  ],
  "deliverables": [
    "src/LoginForm.tsx",
    "tests/LoginForm.test.tsx"
  ],
  "tests": [
    "npm test"
  ],
  "agent": "component-implementation-agent",
  "startedAt": "2025-10-01T10:05:00Z",
  "completedAt": null,
  "validationResults": {
    "testsPass": false,
    "deliverablesExist": false
  }
}
```

Required fields:
- `id`, `type`, `status`

Optional fields:
- `title`, `description`, `parent`, `children`, `dependencies`, `acceptanceCriteria`, `deliverables`, `tests`, `agent`, `startedAt`, `completedAt`, `validationResults`

---

## Deterministic Operations

All tools and hooks MUST use the library in `.claude/memory/lib/memory.sh`:

- `memory_write(file, content)`
- `memory_read(file)`
- `memory_update_json(file, jq_expression)`

Atomicity: write to `file.tmp` → verify → `mv file.tmp file`

Security:
- Path MUST begin with `.claude/memory/`
- No directory traversal (`..`)
- Only text extensions: `.json`, `.md`, `.txt`, `.yaml`, `.yml`

---

## Validation and Repair

Recommended scripts (shipped in templates):
- `wbs-helpers.sh` — roll-up and propagation
- `subagent-validation.sh` — tests + deliverables + status updates (SubagentStop)

Add project scripts for:
- `memory-validate.sh` — check invariants
- `memory-rebuild-index.sh` — reconstruct index from `tasks/*.json`

