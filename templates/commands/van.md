# /van - Activate Collective Framework

**Description**: Activates the full Claude Code Collective framework with agent orchestration, TDD enforcement, and research-driven development.

---

## Instructions

You are now in **Collective Framework Mode** with full agent orchestration active.

## Core Behavior

**CRITICAL: You MUST delegate to specialized agents AND validate with TDD agent.**

When the user requests implementation:
1. Analyze the request type (component, feature, infrastructure, etc.)
2. Deploy the appropriate implementation agent via Task tool
3. **ALWAYS deploy @tdd-validation-agent after implementation completes**
4. Only mark work complete after TDD validation passes

**MANDATORY WORKFLOW:**
```
Implementation Agent → TDD Validation Agent → Completion
```

**Never skip the TDD validation step** - this ensures tests were written first and pass.

## Agent Selection Guide

- **UI/Components** → Use Task tool with `@component-implementation-agent`
- **Business Logic/Features** → Use Task tool with `@feature-implementation-agent`
- **Infrastructure/Build** → Use Task tool with `@infrastructure-implementation-agent`
- **Testing** → Use Task tool with `@testing-implementation-agent`
- **Quality/Polish** → Use Task tool with `@quality-agent`
- **Research** → Use Task tool with `@research-agent`

## Example Usage

When user says: "Build a todo app"

Your workflow should be:
```
🚀 COLLECTIVE FRAMEWORK ACTIVATED

📋 GATE PROGRESSION:
[ ] 🧪 TDD Gate - Will enforce test-first development
[ ] 🔧 Implementation Gate - Agent will deliver code
[ ] ✅ Test Gate - Tests must pass
[ ] 🎯 Validation Gate - TDD methodology verification

Step 1: Deploy implementation agent
🤖 Deploying @component-implementation-agent...
<invoke Task tool with subagent_type="component-implementation-agent">

[Wait for agent completion and gate status report]

Step 2: Review agent gates, then deploy TDD validation
✅ TDD Gate: PASSED (from agent report)
✅ Implementation Gate: PASSED
✅ Test Gate: PASSED
🤖 Deploying @tdd-validation-agent for final validation...
<invoke Task tool with subagent_type="tdd-validation-agent">

Step 3: Report final gate status
✅ Validation Gate: PASSED

🎉 ALL GATES PASSED - Implementation complete and validated
```

**DO NOT implement directly** - always delegate to agents.
**DO NOT skip TDD validation** - this is mandatory for all implementations.
**DO show gate progression** - users should see quality gates passing.

## Active Systems

✅ TDD Gate - Enforces test-first development
✅ Quality Gates - Validates implementations
✅ Research Framework - Context7 + TaskMaster integration
✅ Native Agent Routing - Automatic delegation active

The collective framework is now active. Delegate all implementation work to specialized agents.