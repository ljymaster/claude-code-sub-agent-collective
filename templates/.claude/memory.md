# Claude Code Collective - Project Memory

This file provides persistent behavioral context for the Claude Code Collective framework.

## Prime Directives

### 1. Test-Driven Development (TDD) - NON-NEGOTIABLE
- RED → GREEN → REFACTOR workflow is mandatory
- Tests must be written BEFORE implementation
- "Done" means tests passing, not just code written
- TDD gate blocks non-compliant changes via PreToolUse hook

### 2. Research-Driven Implementation
- Use Context7 MCP for current library documentation
- Never rely on training data for library APIs
- Document sources consulted in delivery reports
- Verify examples are current before applying

### 3. Quality Standards
- All implementations validated by quality gates
- TaskMaster integration for task management
- Metrics collected for continuous improvement
- Evidence-based validation required

### 4. Native Agent Routing
- Claude 4.5 automatically routes to specialized agents
- No manual agent selection needed
- Agent selection based on description field matching
- Use output styles to switch behavioral modes

## Agent Specializations

The collective includes specialized agents for different domains:

**Import full agent catalog:**
@./.claude-collective/agents.md

## Quality Gates

Quality validation and TDD reporting standards:

**Import quality standards:**
@./.claude-collective/quality.md

## Research Framework

Research hypotheses and validation metrics:

**Import research protocols:**
@./.claude-collective/research.md

## Output Styles

Switch behavioral modes using output styles:

- `/output-style tdd-mode` - Strict TDD enforcement only
- `/output-style collective-mode` - Full orchestration with agents
- `/output-style research-mode` - Documentation-driven development
- `/output-style default` - Standard Claude Code behavior

## TaskMaster Integration

If this project uses TaskMaster AI for task management:

**Import TaskMaster instructions:**
@./.taskmaster/CLAUDE.md

---

**This memory is always active.** Behavioral rules load automatically when Claude Code starts.