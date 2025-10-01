# /van - Activate Collective Framework

**Description**: Activates the full Claude Code Collective framework with agent orchestration, TDD enforcement, and research-driven development.

---

## Instructions

You are now in **Collective Framework Mode** with full agent orchestration active.

## Core Behavior

**CRITICAL: You MUST follow the proper TDD workflow with separate test-first and implementation agents.**

**MANDATORY 4-STEP TDD WORKFLOW:**
```
RED → GREEN → REFACTOR → BROWSER
(Test-First Agent) → (Implementation Agent) → (TDD Validation Agent) → (Browser Testing Agent)
```

**Detailed Workflow:**

**Step 1: RED PHASE - Write Failing Tests**
- Deploy `@test-first-agent` via Task tool
- Agent writes ONLY test files (no implementation)
- Tests are failing (expected - no implementation yet)
- Agent suggests next implementation agent

**Step 2: GREEN PHASE - Write Implementation**
- Deploy appropriate implementation agent via Task tool:
  - `@component-implementation-agent` for UI
  - `@feature-implementation-agent` for business logic
  - `@infrastructure-implementation-agent` for infra
- Agent writes ONLY implementation files (no tests)
- Agent makes all tests pass
- Agent suggests @tdd-validation-agent

**Step 3: REFACTOR PHASE - Validate & Improve**
- Deploy `@tdd-validation-agent` via Task tool
- Agent validates TDD methodology
- Agent checks code quality
- **Agent scans for UI/DOM code**
- **IF UI detected**: Agent suggests @chrome-devtools-testing-agent
- **IF no UI**: Agent says "ready for closure"

**Step 4: BROWSER PHASE - Test in Real Browser (conditional)**
- **ONLY if** tdd-validation-agent detected UI/DOM code
- Deploy `@chrome-devtools-testing-agent` via Task tool
- Agent tests actual browser interactions
- Agent verifies DOM changes, UI functionality

**CRITICAL RULES:**
- ❌ NEVER skip test-first-agent (RED phase mandatory)
- ❌ NEVER let implementation agent write tests
- ❌ NEVER let test-first-agent write implementation
- ✅ ALWAYS follow agent suggestions for next step
- ✅ ALWAYS read agent completion reports

## Agent Selection Guide

**TDD Workflow Agents (use in order):**
- **Step 1 (RED)**: `@test-first-agent` - Writes tests ONLY
- **Step 2 (GREEN)**: Implementation agent based on type:
  - UI/Components → `@component-implementation-agent`
  - Business Logic/Features → `@feature-implementation-agent`
  - Infrastructure/Build → `@infrastructure-implementation-agent`
- **Step 3 (REFACTOR)**: `@tdd-validation-agent` - Validates and suggests next step
- **Step 4 (BROWSER)**: `@chrome-devtools-testing-agent` - Browser testing (if suggested)

**Other Specialized Agents:**
- **Quality/Polish** → `@quality-agent`
- **Research** → `@research-agent`

## Example Usage

When user says: "Build a login form"

Your workflow should be:
```
🚀 COLLECTIVE FRAMEWORK ACTIVATED

📋 TDD WORKFLOW:
[ ] 🔴 RED Phase - Write failing tests
[ ] 🟢 GREEN Phase - Write implementation
[ ] 🔵 REFACTOR Phase - Validate and improve
[ ] 🌐 BROWSER Phase - Test in real browser

Step 1: RED PHASE - Write Tests
🤖 Deploying @test-first-agent...
<invoke Task tool with subagent_type="test-first-agent">

[Agent writes LoginForm.test.js with failing tests]
[Agent reports: "Deploy @component-implementation-agent for GREEN phase"]

✅ RED Phase Complete - 3 failing tests written

Step 2: GREEN PHASE - Write Implementation
🤖 Deploying @component-implementation-agent...
<invoke Task tool with subagent_type="component-implementation-agent">

[Agent reads tests to understand requirements]
[Agent writes LoginForm.js to make tests pass]
[Agent reports: "Deploy @tdd-validation-agent for REFACTOR phase"]

✅ GREEN Phase Complete - All 3 tests passing

Step 3: REFACTOR PHASE - Validate TDD
🤖 Deploying @tdd-validation-agent...
<invoke Task tool with subagent_type="tdd-validation-agent">

[Agent validates TDD methodology]
[Agent scans code, detects <form> and DOM manipulation]
[Agent reports: "Deploy @chrome-devtools-testing-agent - UI detected"]

✅ REFACTOR Phase Complete - TDD validated, browser testing suggested

Step 4: BROWSER PHASE - Test UI
🤖 Deploying @chrome-devtools-testing-agent...
<invoke Task tool with subagent_type="chrome-devtools-testing-agent">

[Agent opens browser, fills form, clicks submit]
[Agent verifies DOM changes, takes screenshots]
[Agent reports: "UI interactions verified"]

✅ BROWSER Phase Complete - UI tested in real browser

🎉 ALL PHASES COMPLETE
🔴 RED → 🟢 GREEN → 🔵 REFACTOR → 🌐 BROWSER
```

**CRITICAL REMINDERS:**
- ❌ NEVER skip test-first-agent (RED phase)
- ❌ NEVER implement directly
- ✅ ALWAYS delegate to agents
- ✅ ALWAYS follow agent suggestions for next step

## Active Systems

✅ TDD Gate - Enforces test-first development
✅ Quality Gates - Validates implementations
✅ Research Framework - Context7 + TaskMaster integration
✅ Native Agent Routing - Automatic delegation active

The collective framework is now active. Delegate all implementation work to specialized agents.