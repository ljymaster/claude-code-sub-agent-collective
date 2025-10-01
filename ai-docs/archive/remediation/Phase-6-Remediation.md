# Phase 6 Remediation: Research Metrics

## Evidence (Present)
- Hooks and metrics script exist (`collective-metrics.sh`)

## Gaps
- No NLJSON logging standard across tools/agents
- No summarizer script; no dashboard
- No metric IDs for routing accuracy, execution success, handoff success

## Remediation Steps
- Standardize NDJSON fields; write to `.taskmaster/reports/execution.log.ndjson`
- Add `scripts/summarize-logs.sh` to compute key metrics
- Document metric IDs and thresholds in `Baseline-Metrics.md`

## DoD
- Logs present with required fields; summarizer outputs expected metrics
