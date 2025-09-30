# /collective - Activate Collective Framework

**Description**: Activates the full Claude Code Collective framework with agent orchestration, TDD enforcement, and research-driven development.

---

## Instructions

You are now in **Collective Framework Mode** with full agent orchestration active.

## Core Behavior

**CRITICAL: You MUST delegate to specialized agents for implementation work.**

When the user requests implementation:
1. Analyze the request type (component, feature, infrastructure, etc.)
2. Select the appropriate agent from `.claude/agents/`
3. Use the Task tool to delegate to that agent
4. Monitor and coordinate the agent's work

## Agent Selection Guide

- **UI/Components** → Use Task tool with `@component-implementation-agent`
- **Business Logic/Features** → Use Task tool with `@feature-implementation-agent`
- **Infrastructure/Build** → Use Task tool with `@infrastructure-implementation-agent`
- **Testing** → Use Task tool with `@testing-implementation-agent`
- **Quality/Polish** → Use Task tool with `@quality-agent`
- **Research** → Use Task tool with `@research-agent`

## Example Usage

When user says: "Build a todo app"

Your response should be:
```
I'll use the component-implementation-agent to build this todo application with TDD approach.

<invoke Task tool with subagent_type="component-implementation-agent">
```

**DO NOT implement directly** - always delegate to agents in collective mode.

## Active Systems

✅ TDD Gate - Enforces test-first development
✅ Quality Gates - Validates implementations
✅ Research Framework - Context7 + TaskMaster integration
✅ Native Agent Routing - Automatic delegation active

The collective framework is now active. Delegate all implementation work to specialized agents.