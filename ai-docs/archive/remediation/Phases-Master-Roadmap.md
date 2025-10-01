# Master Phases Roadmap

This master document unifies our phases into three complementary views and links to the canonical specs:
- Build-out Phases (program roadmap for capability delivery)
- Execution Stabilization (immediate critical fixes)
- Runtime Workflow Phases (how an end-to-end build runs)

## System Assessment (Executive)

- Ambitious and directionally right; not fully operational yet.
- Strengths: hub-and-spoke handoffs, execute-not-describe, research-first, TDD, hooks/metrics scaffolding.
- Risks/Gaps: execution core missing (schemas, wrapper, preflight, logs), no idempotency/locking, potential process drag if too many phases enabled early.
- Impact: Will speed PRD-to-feature once D1–D6 are live; before that, overhead outweighs benefits.
- Over-engineering: Borderline; defer dynamic agents/advanced learning until core loop is solid.
- Next actions: Ship D1–D6, create skeleton tasks/state, add locking/atomic writes, run one end-to-end flow, then enable limited parallelism.

## Build-out Phases (Program Roadmap)

1. **Phase 1: Behavioral System (Day 1-2)**
   - Goal: Encode hub-and-spoke behavior, “execute don’t describe”.
   - Primary docs: `ai-docs/phases/Phase-1-Behavioral.md`, `ai-docs/collective-enhancement-plan.md`.
   - Exit: Behavioral directives enforced in agents.

2. **Phase 2: Testing Framework (Day 2-3)**
   - Goal: Jest/RTL setup, test contracts, coverage targets.
   - Docs: `ai-docs/phases/Phase-2-Testing.md`.
   - Exit: Tests run in CI; baseline coverage met.

3. **Phase 3: Hook Integration (Day 3-4)**
   - Goal: Enforce validations via hooks (handoff, metrics).
   - Docs: `ai-docs/phases/Phase-3-Hooks.md`.
   - Exit: Hooks validate outputs; autonomous continuation wired.

4. **Phase 4: NPX Package (Day 5)**
   - Goal: Package distribution for easy install/use.
   - Docs: `ai-docs/phases/Phase-4-NPX.md`.
   - Exit: NPX flow installs and runs locally.

5. **Phase 5: Command System (Day 6)**
   - Goal: Natural language command routing (`/van ...`).
   - Docs: `ai-docs/phases/Phase-5-Commands.md`.
   - Exit: Commands trigger correct agents reliably.

6. **Phase 6: Research Metrics (Day 6)**
   - Goal: Collect research/execution metrics and quality gates.
   - Docs: `ai-docs/phases/Phase-6-Metrics.md`.
   - Exit: Metrics dashboards/logs operational.

7. **Phase 7: Dynamic Agents (Week 2)**
   - Goal: Create/register agents on-the-fly for new tech.
   - Docs: `ai-docs/phases/Phase-7-DynamicAgents.md`.
   - Exit: Gap detection → agent creation → routing works.

8. **Phase 8: Van Maintenance (Week 2)**
   - Goal: Maintenance, upgrades, self-healing.
   - Docs: `ai-docs/phases/Phase-8-VanMaintenance.md`.
   - Exit: Routine upkeep automated with validations.

## Execution Stabilization (Immediate Critical Fixes) — Remediation

Purpose: Ensure agents actually execute tools, hand off work, and maintain state.

- Canonical doc: `ai-docs/remediation/Phase-1-Deliverables-and-Verification.md` (D1–D6)
  - D1 Tool Spec Sheets
  - D2 Global Execution Wrapper
  - D3 Validated Schemas (tasks/state/handoff)
  - D4 Preflight/Health Checks
  - D5 Handoff Contract Enforcement
  - D6 Observability Baseline

Status snapshot (from repo scan):
- Achieved: Hook framework wired; research cache present.
- Pending: `tasks.json`, `state.json`, JSON Schemas, execution wrapper, preflight, NDJSON logs/summarizer.

Gating: Complete D1–D6 before scaling parallelism or dynamic agents.

Remediation status by item:
- D1 Tool Spec Sheets: Pending (spec structure drafted; needs files in `ai-docs/tool-specs/`).
- D2 Execution Wrapper: Pending (spec drafted; implement `scripts/exec_tool.sh`).
- D3 Schema Alignment (Read-Only): Pending (implement read-only validation of TaskMaster outputs; no local writers).
- D4 Preflight: Pending (add `scripts/preflight.sh`; do not create TaskMaster files locally).
- D5 Handoff Enforcement: Partially present (hooks wired); add contract validation and next-action triggers.
- D6 Observability: Pending (standardize NDJSON logs + summarizer script).
- Optional: TaskMaster Storage Protection Hook to block non-MCP writes.

## Phase Remediation Index

- Phase 2: Testing Framework → `ai-docs/remediation/Phase-2-Remediation.md`
- Phase 3: Hook Integration → `ai-docs/remediation/Phase-3-Remediation.md`
- Phase 4: NPX Package → `ai-docs/remediation/Phase-4-Remediation.md`
- Phase 5: Command System → `ai-docs/remediation/Phase-5-Remediation.md`
- Phase 6: Research Metrics → `ai-docs/remediation/Phase-6-Remediation.md`
- Phase 7: Dynamic Agents → `ai-docs/remediation/Phase-7-Remediation.md`
- Phase 8: Van Maintenance → `ai-docs/remediation/Phase-8-Remediation.md`

## Runtime Workflow Phases (End-to-End Build)

These describe the operational flow for building from a PRD (not the program roadmap): see `ai-docs/Autonomous-PRD-Workflow-Analysis.md`.

1. Request Entry & Initial Routing → route to PRD research
2. PRD Analysis & Task Generation → TaskMaster task graph
3. Task Orchestration Deployment → parallel executors
4. Task Execution & Agent Delegation → component/feature agents
5. TDD Implementation → RED/GREEN/REFACTOR
6. Quality Validation → tests, gates, status updates
7. Tech Gap Detection → dynamic agent creation (when needed)
8. Continuous Orchestration Loop → monitor, dispatch, complete

## Dependencies and Gates

- Phase 3 (Hooks) depends on Phase 1–2.
- Phase 4–8 depend on Phase 3’s validations and the Stabilization D1–D6.
- Runtime phases 3–8 depend on successful completion of Stabilization and PRD research (runtime phases 1–2).

## Where to Start

1) Finish Execution Stabilization (D1–D6).
2) Re-run the runtime workflow end-to-end.
3) Advance program phases 4–8 with guardrails in place.


