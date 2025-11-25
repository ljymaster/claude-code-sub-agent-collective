# Qoder CLI Usage Guide

## Installation for Qoder CLI

### Quick Install
```bash
npx claude-code-collective init --platform=qoder
```

### Express Install (no prompts)
```bash
npx claude-code-collective init --yes --platform=qoder
```

## What Gets Installed

```
your-project/
├── CLAUDE.md                    # Behavioral rules (loaded by Qoder)
├── .qoder/
│   ├── settings.json           # Qoder hook configuration
│   ├── agents/                 # 30+ specialized agents
│   │   ├── routing-agent.md
│   │   ├── task-orchestrator.md
│   │   ├── feature-implementation-agent.md
│   │   └── ... (all agents)
│   ├── hooks/                  # Platform-aware hooks
│   │   ├── load-behavioral-system.sh
│   │   ├── test-driven-handoff.sh
│   │   └── collective-metrics.sh
│   └── commands/               # Custom commands
└── .claude-collective/          # Shared testing & metrics
    ├── tests/                  # Contract validation tests
    └── metrics/                # Performance tracking
```

## Platform Detection

The collective automatically detects Qoder CLI through:
- `$QODER_PROJECT_DIR` environment variable
- `.qoder/` directory presence

All hooks and agents adapt automatically.

## Available Tools in Qoder

### Standard Tools
- **Read** - Read files
- **Write** - Create/overwrite files  
- **Edit** - Modify existing files
- **Bash** - Execute shell commands
- **Glob** - Find files by pattern
- **Grep** - Search file contents
- **Task** - Invoke sub-agents

### Web Tools
- **WebFetch** - Fetch web pages
- **WebSearch** - Search the web

## Agent Usage

### Basic Agent Invocation
```
Use the Task tool to invoke specialized agents:
- "Route this to @feature-implementation-agent"
- "Use @testing-agent to write tests"
- "Deploy @quality-agent for code review"
```

### Hub-and-Spoke Routing
The `@routing-agent` acts as the central hub:
```
User Request → @routing-agent → Specialized Agent → Result
```

### Common Workflows

#### TDD Development
```
1. @prd-research-agent - Research requirements
2. @task-orchestrator - Break down tasks
3. @testing-implementation-agent - Write tests (RED)
4. @feature-implementation-agent - Implement (GREEN)
5. @quality-agent - Review and refactor (REFACTOR)
```

#### Quick Feature
```
1. Request: "Add user authentication"
2. @routing-agent analyzes request
3. Routes to @feature-implementation-agent
4. TDD workflow automatically enforced
5. Tests + Implementation delivered
```

## Hook System

### How Hooks Work in Qoder

Hooks automatically trigger at key points:

#### SessionStart Hooks
- Load behavioral system on startup
- Inject CLAUDE.md and collective rules
- Set up TDD framework

#### PreToolUse Hooks
- Block destructive commands
- Enforce behavioral directives
- Validate tool usage

#### PostToolUse Hooks
- Validate agent handoffs
- Collect metrics
- Ensure TDD completion

### Hook Configuration

Edit `.qoder/settings.json` to customize hooks:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "$QODER_PROJECT_DIR/.qoder/hooks/load-behavioral-system.sh"
          }
        ]
      }
    ]
  }
}
```

## TDD Workflow

### RED Phase (Write Failing Tests)
```
Request: "Implement login feature"
→ @testing-agent writes tests first
→ Tests FAIL (expected - no implementation yet)
→ Clear success criteria defined
```

### GREEN Phase (Make Tests Pass)
```
→ @feature-implementation-agent implements
→ Minimal code to pass tests
→ Tests PASS
→ Feature confirmed working
```

### REFACTOR Phase (Improve Quality)
```
→ @quality-agent reviews code
→ @polish-agent optimizes
→ Tests still PASS
→ Production-ready code
```

## Common Commands

### Validation
```bash
# Check installation
npx claude-code-collective status

# Validate integrity
npx claude-code-collective validate --detailed

# Show platform info
npx claude-code-collective info
```

### Development
```bash
# In Qoder CLI, request work naturally:
"Build a React component for user profiles"
"Add tests for the authentication module"  
"Review and refactor the payment system"
```

## Differences from Claude Code

### What's the Same
✅ All agent definitions  
✅ TDD workflow enforcement  
✅ Hub-and-spoke routing  
✅ Hook system architecture  
✅ Behavioral directives  

### What's Different
❌ No MCP tools (Task Master, Context7)  
✅ Use WebFetch instead of Context7  
✅ Standard tool set instead of MCP  
❌ No SubagentStop events (simplified hooks)  

### Workarounds for Missing MCP

#### Task Master Alternative
Use Todo lists or project management tools:
```
Instead of: mcp__task-master__get_tasks
Use: Read .taskmaster/tasks.json (if exists)
Or: Natural language task tracking
```

#### Context7 Alternative  
Use WebFetch for documentation:
```
Instead of: mcp__context7__get-library-docs
Use: WebFetch("https://react.dev/reference")
```

## Troubleshooting

### Hooks Not Loading
```bash
# Check settings file exists
ls .qoder/settings.json

# Validate installation
npx claude-code-collective validate

# Reinstall if needed
npx claude-code-collective init --force --platform=qoder
```

### Agent Not Found
```bash
# List available agents
ls .qoder/agents/

# Check agent file exists
cat .qoder/agents/routing-agent.md
```

### Platform Detection Issues
```bash
# Force Qoder platform
npx claude-code-collective init --platform=qoder --force

# Check environment
echo $QODER_PROJECT_DIR
```

### Hook Scripts Not Executable
```bash
# Fix permissions (Linux/Mac)
chmod +x .qoder/hooks/*.sh

# On Windows, ensure bash is available
```

## Advanced Usage

### Custom Agent Creation
Create custom agents in `.qoder/agents/`:

```markdown
# @my-custom-agent

**Platform Support**: Claude Code, Qoder CLI
**Purpose**: Specialized task handling

## Core Responsibilities
- Task-specific implementation
- TDD enforcement
- Quality validation

## Usage
Invoke via: "Use @my-custom-agent to..."
```

### Custom Hooks
Add custom hooks in `.qoder/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "$QODER_PROJECT_DIR/.qoder/hooks/my-custom-hook.sh"
          }
        ]
      }
    ]
  }
}
```

## Best Practices

1. **Let routing handle selection** - Don't manually pick agents
2. **Trust TDD workflow** - Tests first, always
3. **Use natural language** - Describe what you want
4. **Review deliverables** - Check tests and implementation
5. **Iterate freely** - Agents handle complexity

## Getting Help

```bash
# CLI help
npx claude-code-collective --help

# Validation with details
npx claude-code-collective validate --detailed

# Check specific components
npx claude-code-collective status
```

## Migration from Claude Code

If you have an existing Claude Code installation:

```bash
# Install for both platforms
npx claude-code-collective init --platform=both --sync-platforms

# Creates both .claude/ and .qoder/ directories
# Settings synced automatically
```

Your project will work on both platforms with the same agents and rules.

---

**Platform**: Qoder CLI  
**Version**: 2.1.0  
**Status**: Production Ready  
