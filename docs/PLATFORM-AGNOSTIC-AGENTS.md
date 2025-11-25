# Platform-Agnostic Agent Definition Guidelines

## Overview
All agent definitions must be platform-agnostic to support both **Claude Code** and **Qoder CLI**.

## Key Changes Required

### 1. Remove Platform-Specific References

**BEFORE:**
```markdown
## Claude Code Integration
Use the following tools available in Claude Code...
```

**AFTER:**
```markdown
## Platform Integration
Use the following tools available in your AI coding platform...
```

### 2. Environment Variables

**BEFORE:**
```markdown
Check `$CLAUDE_PROJECT_DIR` for the project root.
```

**AFTER:**
```markdown
Check `$QODER_PROJECT_DIR` or `$CLAUDE_PROJECT_DIR` for the project root (platform-dependent).
```

### 3. Configuration Directory References

**BEFORE:**
```markdown
Review `.claude/settings.json` for configuration.
```

**AFTER:**
```markdown
Review configuration in `.qoder/settings.json` (Qoder) or `.claude/settings.json` (Claude Code).
```

### 4. Tool References

**BEFORE:**
```markdown
Use Claude Code's `WebFetch` tool to retrieve documentation.
```

**AFTER:**
```markdown
Use the `WebFetch` tool to retrieve documentation.
```

### 5. Hook References

**BEFORE:**
```markdown
The hook system in `.claude/hooks/` enforces TDD.
```

**AFTER:**
```markdown
The hook system enforces TDD through platform-specific hooks.
```

### 6. MCP/Tool Availability

**BEFORE:**
```markdown
## Required Tools
- Claude Code MCP: `mcp__task-master__*`
- Context7 integration for research
```

**AFTER:**
```markdown
## Required Tools
Platform-dependent tool availability:
- **Claude Code**: MCP tools (`mcp__task-master__*`), Context7
- **Qoder CLI**: Standard tool set, web research capabilities
```

### 7. Agent Invocation

**BEFORE:**
```markdown
To use this agent in Claude Code, invoke via:
```

**AFTER:**
```markdown
To use this agent, invoke via the Task tool:
```

## Template Pattern

Use this pattern at the beginning of each agent file:

```markdown
# @agent-name

**Platform Support**: Claude Code, Qoder CLI
**Version**: 2.1.0
**Last Updated**: 2024-11

## Purpose
[Agent description - platform-agnostic]

## Platform Notes
- **Claude Code**: Full MCP integration, Context7 research
- **Qoder CLI**: Standard tools, web-based research

## Core Responsibilities
[List responsibilities without platform-specific mentions]
```

## File Path References

Always use generic references:

```markdown
**Configuration**: Check your platform's config directory
**Hooks**: Available in your hook directory
**Agents**: Located in your agents directory
```

## Testing & Validation

Each agent should validate its platform at runtime if needed:

```markdown
## Platform Detection (if required)
The agent automatically detects the platform through:
- Environment variable `$QODER_PROJECT_DIR` (Qoder)
- Environment variable `$CLAUDE_PROJECT_DIR` (Claude Code)
```

## Migration Checklist

For each agent file:
- [ ] Remove "Claude Code" hardcoded mentions
- [ ] Replace `.claude/` paths with generic references
- [ ] Update environment variable references
- [ ] Add platform notes section if tools differ
- [ ] Review tool usage for cross-platform compatibility
- [ ] Update examples to be platform-neutral
- [ ] Test instructions work on both platforms

## Example: Before & After

### BEFORE (Claude-specific):
```markdown
# @research-agent

Use Claude Code's Context7 MCP server to fetch documentation.

Check `$CLAUDE_PROJECT_DIR/.claude/agents/` for available agents.
```

### AFTER (Platform-agnostic):
```markdown
# @research-agent

**Platform Support**: Claude Code, Qoder CLI

## Platform-Specific Features
- **Claude Code**: Context7 MCP for real-time documentation
- **Qoder CLI**: WebFetch tool for documentation retrieval

Check the platform's agent directory for available agents.
```

## Implementation Priority

1. **Critical agents** (routing, orchestration) - Update first
2. **Implementation agents** (feature, component, etc.) - High priority
3. **Quality agents** (testing, validation) - Medium priority
4. **Utility agents** (metrics, reporting) - Lower priority
