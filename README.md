# AI Code Collective

[![npm version](https://badge.fury.io/js/claude-code-collective.svg)](https://badge.fury.io/js/claude-code-collective)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Multi-Platform NPX installer for TDD-focused AI agents**

This installs a collection of AI agents designed for Test-Driven Development and rapid prototyping. Now supports **both Claude Code and Qoder CLI** with platform-agnostic agent definitions and hooks.

## Platform Support

🎯 **Fully supported platforms:**
- **Claude Code** - Full MCP integration, Context7 research
- **Qoder CLI** - Standard tool set, web-based research

The collective automatically detects your platform and installs the appropriate configuration.

## What this installs

```bash
npx claude-code-collective init
```

You get 30+ specialized agents that enforce TDD methodology and try to be smarter about using real documentation instead of guessing.

## Why this exists

I got tired of:
- AI giving me code without tests
- Having to manually look up library documentation
- Inconsistent development approaches across projects
- Breaking down complex features manually

So I built agents that:
1. Write tests first, always (RED → GREEN → REFACTOR)
2. Use Context7 to pull real documentation
3. Route work to specialists based on what needs doing
4. Break down complex requests intelligently

## What you get after installation

### Core Implementation Agents (TDD-enforced)
- **@component-implementation-agent** - UI components with tests and modern patterns
- **@feature-implementation-agent** - Business logic with comprehensive testing
- **@infrastructure-implementation-agent** - Build systems with testing setup
- **@testing-implementation-agent** - Test suites that actually test things
- **@polish-implementation-agent** - Performance optimization with preserved tests

### Quality & Validation
- **@quality-agent** - Code review and standards checking
- **@devops-agent** - Deployment and CI/CD setup
- **@functional-testing-agent** - Browser testing with Playwright
- **@enhanced-quality-gate** - Comprehensive validation gates
- **@completion-gate** - Task validation and completion checks

### Research & Intelligence (Experimental)
- **@research-agent** - Context7-powered documentation lookup
- **@prd-research-agent** - Intelligent requirement breakdown
- **@task-orchestrator** - Smart task parallelization

### System & Coordination
- **`/van` command** - Entry point that routes to @task-orchestrator
- **@task-orchestrator** - Central routing hub that picks the right specialist
- **@behavioral-transformation-agent** - System behavioral setup
- **@hook-integration-agent** - TDD enforcement automation
- **@van-maintenance-agent** - System maintenance and updates

**Plus 20+ other specialized agents** for specific development tasks.

## Installation options

### 🚀 从 GitHub 安装（推荐）

```bash
# 全局安装（可在任意项目使用）
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 在项目中初始化（支持 Qoder CLI）
cd /path/to/your/project
ccc init --yes --platform=qoder

# 验证安装
ccc status
```

**可用命令：**
- `ccc` - 短命令（推荐）
- `claude-code-collective-v2` - 完整命令

**与旧版本并存**: 本包使用 `@ljymaster/claude-code-collective` 包名，可与旧版本 `claude-code-collective` 完美并存。详见 [并存指南](./docs/COEXISTENCE-GUIDE.md)

**详细指南**: [GitHub 安装完整指南](./docs/GITHUB-INSTALL-GUIDE.md)

### 📦 从 NPM 安装（如已发布）

```bash
# 全局安装
npm install -g @ljymaster/claude-code-collective

# 或使用 npx（无需安装）
npx @ljymaster/claude-code-collective init
```

### Platform-specific installation
```bash
# For Claude Code only
ccc init --platform=claude

# For Qoder CLI only  
npx claude-code-collective init --platform=qoder

# Install for both platforms
npx claude-code-collective init --platform=both --sync-platforms
```

### Other options
```bash
# Minimal installation (core agents only)
npx claude-code-collective init --minimal

# Express mode (no prompts, smart defaults)
npx claude-code-collective init --yes

# Interactive setup with choices
npx claude-code-collective init --interactive
```

## What actually gets installed

```
your-project/
├── CLAUDE.md                    # Behavioral rules for agents
├── .claude/                     # Claude Code configuration (if using Claude)
│   ├── settings.json           # Claude-specific hook configuration
│   ├── agents/                 # Agent definitions (30+ files)
│   │   ├── prd-research-agent.md
│   │   ├── task-orchestrator.md
│   │   ├── lib/
│   │   │   └── research-analyzer.js  # Complexity analysis engine
│   │   └── ... (lots more agents)
│   └── hooks/                  # TDD enforcement scripts
│       ├── test-driven-handoff.sh
│       └── collective-metrics.sh
├── .qoder/                      # Qoder CLI configuration (if using Qoder)
│   ├── settings.json           # Qoder-specific hook configuration
│   ├── agents/                 # Same agent definitions
│   └── hooks/                  # Same hooks (platform-aware)
└── .claude-collective/
    ├── tests/                  # Test framework templates
    ├── metrics/                # Usage tracking (for development)
    └── package.json           # Testing setup (Vitest)
```

## How it works

1. **`/van` command** routes to **@task-orchestrator** (the routing hub) which analyzes requests and delegates to specialists
2. **Research phase** - agents use Context7 for real documentation  
3. **Tests written first** - before any implementation
4. **Implementation** - minimal code to make tests pass
5. **Refactoring** - clean up while keeping tests green
6. **Delivery** - you see what tests were added and results

### The TDD contract every agent follows

```
## DELIVERY COMPLETE
✅ Tests written first (RED phase)
✅ Implementation passes tests (GREEN phase)
✅ Code refactored for quality (REFACTOR phase)
📊 Test Results: X/X passing
```

## Management commands

```bash
# Check what's installed and working
npx claude-code-collective status

# Validate installation integrity
npx claude-code-collective validate

# Fix broken installations
npx claude-code-collective repair

# Remove everything
npx claude-code-collective clean

# Get help
npx claude-code-collective --help
```

## Current state (honest assessment)

### What works well
- TDD enforcement prevents a lot of bugs
- Multi-platform support for Claude Code and Qoder CLI
- Platform-agnostic agent definitions
- Routing usually picks the right agent for the job
- Breaking down complex tasks is genuinely helpful

### What's experimental/rough
- Some agents are still being refined
- Platform-specific features (MCP vs standard tools)
- Hook system requires restart after installation
- Documentation is being updated for multi-platform support

### Known limitations
- Requires Node.js >= 16
- Need to restart your AI coding platform after installation
- Opinionated about TDD (if you don't like tests, skip this)
- Some agents might be too thorough/slow for simple tasks
- Platform-specific tools (Context7 on Claude Code only)

## Testing your installation

After installing:

```bash
# 1. Validate everything installed correctly
npx claude-code-collective validate

# 2. Check status and platform detection
npx claude-code-collective status

# 3. Restart your AI coding platform
# - Claude Code: Restart the application
# - Qoder CLI: No restart needed (hooks load on next session)

# 4. Try it out
# In your AI platform: "Build a simple todo app with React"
# Expected: routes to research → breaks down task → writes tests → implements
```

## Troubleshooting

### Installation fails
- Check Node.js version: `node --version` (need >= 16)
- Clear npm cache: `npm cache clean --force`
- Try force install: `npx claude-code-collective init --force`

### Agents don't work
- Restart Claude Code (hooks need to load)
- Check `.claude/settings.json` exists
- Run `npx claude-code-collective validate`

### Tests don't run
- Make sure your project has a test runner (Jest, Vitest, etc.)
- Check if tests are actually being written to files
- Look at the TDD completion reports from agents

### Research is slow
- Context7 might be having connectivity issues
- Agent might be being thorough (this varies)
- Check `.claude-collective/metrics/` for timing data

## Requirements

- **Node.js**: >= 16.0.0
- **NPM**: >= 8.0.0
- **Platform**: Claude Code or Qoder CLI
- **Restart**: Required after installation (hooks need to load)

## Platform-Specific Features

### Claude Code
- Full Task Master MCP integration
- Context7 for real-time documentation lookup
- Advanced hook system with SubagentStop events

### Qoder CLI  
- Standard tool set (Read, Write, Edit, Bash, etc.)
- WebFetch/WebSearch for documentation
- All core TDD and routing features

Both platforms share the same agent definitions and behavioral system.

## What this is and isn't

### What it is
- Experimental development aid for rapid prototyping
- Collection of TDD-focused AI agents
- Personal project that I use for my own MVPs
- Opinionated about test-first development

### What it isn't
- Production-ready enterprise software
- Guaranteed to work perfectly
- Following any official standards
- A replacement for thinking or understanding code

## Why TDD?

Because in my experience:
- Writing tests first forces better design thinking
- Tests catch bugs when they're cheap to fix
- Refactoring is safe with good test coverage
- Code with tests is easier to change later

The agents enforce this because I believe it leads to better outcomes. If you disagree with TDD philosophy, this tool probably isn't for you.

## Research features (experimental)

To make agents smarter about modern development:

- **Context7 integration** - real, current library documentation
- **ResearchDrivenAnalyzer** - intelligent complexity assessment
- **Smart task breakdown** - only creates subtasks when actually needed
- **Best practice application** - research-informed patterns

This stuff is experimental and sometimes overthinks things, but generally helpful.

## Solutions to common agent problems

AI agents can be unreliable. Here's what I built to deal with that:

**Agents ignoring TDD rules**: Hook system enforces test-first development before any code gets written.

**Agents bypassing directives**: CLAUDE.md behavioral operating system with prime directives that override default behavior.

**Agents stopping mid-task**: Test-driven handoff validation ensures work gets completed or explicitly handed off.

**Agents making up APIs**: Context7 integration forces agents to use real, current documentation.

**Agents taking wrong approach**: Central routing through **@task-orchestrator** hub prevents agents from self-selecting incorrectly.

**Agents breaking coordination**: Hub-and-spoke architecture eliminates peer-to-peer communication chaos.

**Agents skipping quality steps**: Quality gates that block completion until standards are met.

**Agents losing context**: Handoff contracts preserve required information across agent transitions.

**Agents providing inconsistent output**: Standardized TDD completion reporting from every implementation agent.

**Agents working on wrong priorities**: ResearchDrivenAnalyzer scores complexity to focus effort appropriately.

Most of these are enforced automatically through hooks and behavioral constraints, not just hoping agents follow instructions.

## Support

This is a personal project, but:
- **Issues welcome** if you find bugs or have suggestions
- **PRs welcome** for small fixes or better agent prompts  
- **Don't expect rapid responses** - this is a side project

**Get help**: Run `npx claude-code-collective validate` for diagnostics

## License

MIT License - Use it, break it, fix it, whatever works for you.

---

**Experimental** | **TDD-Focused** | **Personal Project** | **Use At Your Own Risk**

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and release notes.