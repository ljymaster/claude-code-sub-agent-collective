# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **Claude Code Sub-Agent Collective** - an NPX-distributed framework that installs specialized AI agents, hooks, and behavioral systems for TDD-focused development workflows. The system enforces test-driven development through automated handoff validation and provides intelligent task routing through a hub-and-spoke architecture.

## CRITICAL REPOSITORY INFORMATION

**Git Remote URL:** https://github.com/vanzan01/claude-code-sub-agent-collective.git
**NEVER CHANGE THIS URL** - Always use this exact repository URL for all git operations.

## Architecture

### Core System
- **Hub-and-spoke architecture** with `@routing-agent` as central coordinator
- **Behavioral Operating System** defined in `CLAUDE.md` with prime directives
- **Test-Driven Handoffs** with contract validation between agents
- **Just-in-time context loading** to minimize memory usage

### Key Components
- **NPX Package**: `claude-code-collective` - Installable via `npx claude-code-collective init`
- **Agent System**: 30 specialized agents in `templates/agents/`
- **Hook System**: TDD enforcement hooks in `templates/hooks/`
- **Command System**: `/van` command activates collective framework
- **Template System**: Installation templates in `templates/`

## v3.0 Intelligent Agent Orchestration

### How It Works (CRITICAL - READ THIS)

**Agents are INTELLIGENT and analyze code to determine next steps. Users make simple requests, agents orchestrate the entire workflow automatically.**

### Complete Workflow Example

**User Request:**
```
/van

Build a simple login form with username and password fields
```

**Automatic Agent Sequence (NO user intervention):**

1. **Hub Claude** analyzes request → deploys `@component-implementation-agent` via Task tool

2. **@component-implementation-agent** executes:
   - TDD hook enforces tests-first (blocks Write until tests exist)
   - Writes tests first (e.g., `LoginForm.test.js`)
   - Writes implementation (e.g., `LoginForm.html`, `LoginForm.js`)
   - Completes with: "Deploy @tdd-validation-agent for final validation"

3. **Hub Claude** reads suggestion → deploys `@tdd-validation-agent` via Task tool

4. **@tdd-validation-agent** executes:
   - Runs tests to verify they pass
   - **SCANS IMPLEMENTATION CODE** for browser functionality:
     - Detects `<form>`, `<input>`, `<button>` elements
     - Detects `addEventListener`, `onclick` handlers
     - Detects DOM manipulation (`document.querySelector`, etc.)
   - **IF UI/DOM detected**: Suggests "Deploy @chrome-devtools-testing-agent"
   - **IF no UI/DOM**: Says "Task ready for closure"

5. **Hub Claude** reads suggestion → deploys `@chrome-devtools-testing-agent` via Task tool

6. **@chrome-devtools-testing-agent** executes:
   - Opens browser to application URL
   - **CLICKS and INTERACTS** with actual UI (no console.log needed)
   - Fills username field using `mcp__chrome-devtools__fill`
   - Fills password field using `mcp__chrome-devtools__fill`
   - Clicks submit button using `mcp__chrome-devtools__click`
   - **VERIFIES DOM STATE** using `mcp__chrome-devtools__evaluate_script`:
     - Checks if elements appeared/disappeared
     - Verifies text content changed
     - Confirms CSS classes updated
   - Takes before/after screenshots
   - Checks network requests completed
   - Reports: "UI interactions verified ✅"

7. **Hub Claude** reports all gates passed → Complete

### Key Principles (CRITICAL)

**AGENTS DECIDE NEXT STEPS, NOT USERS:**
- Users never say "add console.log" or "test in browser"
- Agents analyze code and suggest next agent automatically
- Hub Claude reads agent suggestions and deploys next agent

**BROWSER TESTING USES ACTUAL INTERACTIONS:**
- Chrome DevTools MCP **clicks buttons** and **fills forms**
- Verifies DOM state changes via JavaScript evaluation
- Takes screenshots for visual validation
- Does NOT rely on console.log (only checks for errors)

**TDD HOOKS ENFORCE TEST-FIRST:**
- PreToolUse hook blocks Write/Edit operations
- Implementation files cannot be written until tests exist
- Automatic and transparent to agents

### Agent Intelligence Rules

**component-implementation-agent:**
- Builds UI components with TDD
- Suggests: "Deploy @tdd-validation-agent"

**tdd-validation-agent:**
- Validates TDD methodology
- **Scans code for**: `<form>`, `<input>`, event handlers, DOM APIs
- **IF UI detected**: Suggests "Deploy @chrome-devtools-testing-agent"
- **IF no UI**: Says "Task ready for closure"

**chrome-devtools-testing-agent:**
- Tests browser functionality via actual interactions
- Primary method: Click, fill, verify DOM changes
- Secondary: Network requests, console errors
- Never requires console.log to be present

## Essential Commands

### Development
```bash
# Run tests (primary test suite)
npm test                    # Vitest tests
npm run test:jest          # Jest tests (comprehensive)
npm run test:coverage      # Coverage reports

# Run specific test suites  
npm run test:contracts     # Contract validation tests
npm run test:handoffs      # Agent handoff tests
npm run test:agents        # Agent system tests

# Package management
npm run install-collective # Install to current directory
npm run validate          # Validate installation
npm run metrics:report    # View metrics data
```

### Local Testing Workflow

For testing changes before publishing (see ai-docs/Simple-Local-Testing-Workflow.md):

```bash
# Automated testing (does everything automatically)
./scripts/test-local.sh
# This script automatically:
# - Creates package (.tgz file)  
# - Creates test directory ../npm-tests/ccc-testing-vN (auto-numbered)
# - Installs the package in test directory
# - Runs basic validation tests
# - Leaves you in the test directory ready for more testing

# Additional manual testing (you're already in test directory after script)
npx claude-code-collective init            # Interactive mode
npx claude-code-collective init --minimal  # Minimal installation  
npx claude-code-collective --help          # Help information

# Return to main directory and cleanup when done
cd ../taskmaster-agent-claude-code
./scripts/cleanup-tests.sh # Removes test directories and tarballs
```

#### Testing Scripts Available
- `scripts/test-local.sh` - Automated package testing in dedicated `../npm-tests/` directory
- `scripts/cleanup-tests.sh` - Clean up test artifacts and directories (removes npm-tests when empty)

#### NPM Testing Directory Naming Standards

**MANDATORY NAMING CONVENTION**: All npm testing directories MUST follow the established pattern:

- **Manual testing**: `ccc-manual-v[N]` (e.g., `ccc-manual-v1`, `ccc-manual-v2`)
- **Automated testing**: `ccc-automated-v[N]` (e.g., `ccc-automated-v1`, `ccc-automated-v2`) 
- **Feature-specific testing**: `ccc-[feature]-v[N]` (e.g., `ccc-backup-test-v1`, `ccc-hooks-test-v1`)

**DO NOT** use arbitrary names like `test-backup-validation` or any other format. Always use the `ccc-*` prefix followed by descriptive name and version number.

### NPX Package Testing
```bash
# Test the NPX package locally (quick testing)
npx . init                 # Test installation from current directory
npx . status              # Test status command
npx . validate            # Test validation
npx . repair              # Test repair functionality
npx . clean               # Test cleanup functionality
```

### Additional Testing Scripts
```bash
# Alternative manual/automated testing approaches
./scripts/test-automated.sh  # Automated testing variant
./scripts/test-manual.sh     # Manual testing variant
```

## Key Development Files

### Core Implementation
- `lib/index.js` - Main entry point and ClaudeCodeCollective class
- `lib/installer.js` - NPX installation logic
- `lib/command-system.js` - Natural language command processing
- `lib/AgentRegistry.js` - Agent management and lifecycle
- `lib/file-mapping.js` - Defines template-to-destination mapping for all installed files
- `bin/claude-code-collective.js` - CLI interface

### Testing Infrastructure
- `jest.config.js` - Jest configuration for comprehensive testing
- `vitest.config.js` - Vitest configuration for fast iteration
- `tests/setup.js` - Test environment setup
- `tests/contracts/` - Contract validation tests
- `tests/handoffs/` - Agent handoff tests

### Templates and Distribution
- `templates/` - All installation templates (agents, hooks, configs)
- `templates/CLAUDE.md` - Behavioral system template
- `templates/settings.json` - Claude Code configuration template
- `lib/file-mapping.js` - Template to destination mapping

## Development Workflow

### Branch-Based Testing Workflow

**Standard process for testing changes before merging:**

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # Make changes...
   git add . && git commit -m "feat: your changes"
   ```

2. **Test Locally** 
   ```bash
   ./scripts/test-local.sh
   # This creates ccc-testing-vN directory and tests your changes
   # Script shows version number to confirm you're testing your branch
   ```

3. **Manual Testing** (you'll be in test directory)
   ```bash
   # Non-interactive testing (for validation/CI)
   npx claude-code-collective init --yes --force
   npx claude-code-collective status  
   npx claude-code-collective validate
   
   # Interactive testing (for development)
   npx claude-code-collective init
   # Test all functionality you changed
   ```

4. **Fix Issues** (if any)
   ```bash
   cd ../taskmaster-agent-claude-code
   # Make fixes...
   git add . && git commit -m "fix: issue description"
   # Repeat from step 2
   ```

5. **Clean Up & Merge**
   ```bash
   ./scripts/cleanup-tests.sh  # Remove test artifacts
   git push -u origin feature/your-feature-name
   # Create PR, merge when approved
   ```

**Key Benefits:**
- Tests exact user installation experience
- Catches template/file mapping issues
- Verifies version changes work correctly
- No need to push to test (works locally)

### Adding New Agents
1. Create agent definition in `templates/agents/agent-name.md`
2. Update `lib/file-mapping.js` - add to `getAgentMapping()` array
3. Add contract tests in `tests/agents/`
4. Test via `npm run test:agents`
5. Test installation: `./scripts/test-local.sh`

### Modifying Hooks
1. Edit hook scripts in `templates/hooks/`
2. Update `templates/settings.json` if needed
3. Test hook behavior with `npm run test:handoffs`
4. Validate with `npm run test:contracts`

### Testing Installation
1. Make changes to templates or core logic
2. Test locally: `npx . init --force`
3. Validate: `npx . validate`
4. Run full test suite: `npm test`

## Code Architecture Patterns

### Agent System
- **Agent Registry**: Centralized agent tracking and lifecycle management (lib/AgentRegistry.js:35-120)
- **Template System**: Handlebars-based template rendering for dynamic agent creation
- **Spawning System**: Dynamic agent instantiation with proper context loading
- **File Mapping**: Template-to-destination mapping system (lib/file-mapping.js:20-580)

### Hook System
- **Test-Driven Handoffs**: Automated validation of agent transitions
- **Behavioral Enforcement**: Hooks enforce TDD and routing requirements
- **Metrics Collection**: Automated data gathering for research hypotheses
- **Hook Configuration**: Defined in templates/settings.json.template

### Command System
- **Natural Language Processing**: Converts user intent to structured commands
- **Namespace Routing**: `/collective`, `/agent`, `/gate`, `/van` command spaces
- **Auto-completion**: Context-aware command suggestions
- **TaskMaster Integration**: Full command structure in templates/commands/tm/

### Installation System
- **NPX Distribution**: Package distributed via npm, installed with npx
- **Template Processing**: All files in templates/ get processed and installed
- **Directory Structure**: Creates .claude/, .claude-collective/, and root files
- **Validation**: Built-in validation checks installation integrity

## Testing Strategy

### Test Suites
1. **Unit Tests** (`tests/*.test.js`) - Core functionality
2. **Contract Tests** (`tests/contracts/`) - Agent handoff validation
3. **Integration Tests** (`tests/handoffs/`) - End-to-end workflows
4. **Installation Tests** - NPX package validation

### Test Execution
- **Vitest**: Fast iteration during development (`npm test`)
- **Jest**: Comprehensive validation (`npm run test:jest`)
- **Coverage**: Track test coverage (`npm run test:coverage`)

### Quality Gates
- All tests must pass before releases
- Contract validation ensures agent compatibility
- Installation tests verify NPX package integrity

## Important Notes

### Development Environment
- **Node.js**: >= 16.0.0 required
- **Dependencies**: Use `npm install` not `yarn`
- **Testing**: Both Vitest and Jest configured for different use cases

### Release Process
1. Update version in `package.json`
2. Run full test suite: `npm run test:jest`
3. Test NPX installation: `npx . init --force`
4. Update `CHANGELOG.md` with changes
5. Commit and tag release

### File Management
- Never manually edit generated files in `.claude/` or `.claude-collective/`
- Template changes must be tested through full installation cycle
- Agent definitions follow strict markdown format requirements
- All templates live in `templates/` directory
- File mapping is the single source of truth for what gets installed (lib/file-mapping.js:20-580)

### TDD Requirements
- All new functionality must have tests first
- Agent handoffs must include contract validation
- Behavioral changes require integration test updates

### Standards Compliance

**CRITICAL**: Do not modify established standards without explicit permission. This includes:

- **Naming conventions** (testing directories, file patterns, etc.)
- **Code formatting standards** 
- **Testing procedures and workflows**
- **Documentation structure**
- **Git workflow patterns**
- **Release processes**

When in doubt, follow existing patterns exactly. Ask for clarification before deviating from any established standard.

### NPM Version Release Automation

**When user says "npm version [patch|minor|major]":**
- Always use a proper commit message based on recent changes
- Check git log for recent features/fixes to craft meaningful message
- Use format: `npm version patch -m "chore: release v%s - [summary of changes]"`
- Example: `npm version patch -m "chore: release v%s - fix CI race conditions and add comprehensive testing"`
- Never use the default "2.0.7" commit message

## Template System Architecture

The installation system uses a template-based architecture:

1. **Templates Directory Structure**:
   - `templates/agents/` - 28 agent definitions in markdown format
   - `templates/hooks/` - 6 hook scripts for TDD enforcement
   - `templates/commands/` - Core commands + full TaskMaster command tree
   - `templates/.claude-collective/` - Test framework, metrics, configs
   - `templates/settings.json.template` - Hook configuration template
   - `templates/CLAUDE.md` - Behavioral system template

2. **File Mapping System** (lib/file-mapping.js):
   - `getAgentMapping()` - Maps agent definitions to .claude/agents/
   - `getHookMapping()` - Maps hooks to .claude/hooks/ with executable permissions
   - `getCommandMapping()` - Maps commands to .claude/commands/ (including tm/ subdirectory)
   - `getTestMapping()` - Maps test framework to .claude-collective/tests/
   - `getConfigMapping()` - Maps configuration files
   - `getCollectiveMapping()` - Maps behavioral system files to .claude-collective/

3. **Installation Flow**:
   - User runs `npx claude-code-collective init`
   - Installer reads file-mapping.js for complete installation manifest
   - Creates directory structure (.claude/, .claude-collective/)
   - Copies templates to destinations with proper permissions
   - Validates installation integrity
   - Reports success with installed file counts

**Key Implementation Note**: When adding new files to installation, ALWAYS update lib/file-mapping.js. The file mapping is the single source of truth for what gets installed.

## Testing TDD Hooks

### Hook Architecture (v3.0)

Claude Code Collective v3.0 uses native Claude Code PreToolUse hooks with `hookSpecificOutput` decision control. Hooks must return proper JSON format to function correctly.

### Manual Hook Testing (Development Testing)

When developing or debugging hooks, test them manually outside Claude Code:

```bash
# Navigate to test installation
cd /mnt/h/Active/npm-tests/ccc-testing-v5

# Test TDD gate blocks implementation without tests
echo '{"tool_name": "Write", "tool_input": {"file_path": "src/PaymentService.js"}}' | ./.claude/hooks/tdd-gate.sh

# Expected: {"hookSpecificOutput": {"permissionDecision": "deny", ...}}

# Test TDD gate allows test files
echo '{"tool_name": "Write", "tool_input": {"file_path": "src/PaymentService.test.js"}}' | ./.claude/hooks/tdd-gate.sh

# Expected: {"hookSpecificOutput": {"permissionDecision": "allow", ...}}

# Create test file, verify implementation now allowed
mkdir -p src && touch src/PaymentService.test.js
echo '{"tool_name": "Write", "tool_input": {"file_path": "src/PaymentService.js"}}' | ./.claude/hooks/tdd-gate.sh

# Expected: {"hookSpecificOutput": {"permissionDecision": "allow", "permissionDecisionReason": "Tests exist for this file"}}

# Test destructive command blocking
echo '{"tool_name": "Bash", "tool_input": {"command": "rm -rf /"}}' | ./.claude/hooks/block-destructive-commands.sh

# Expected: {"hookSpecificOutput": {"permissionDecision": "deny", ...}}
```

### Live Hook Testing (User Experience Testing)

To test hooks in a real Claude Code session:

```bash
# 1. Deploy package locally
./scripts/test-local.sh

# 2. Navigate to test directory (script does this automatically)
cd /mnt/h/Active/npm-tests/ccc-testing-vN

# 3. Start Claude Code
claude-code

# 4. In Claude Code session, request implementation WITHOUT tests
> Create a file src/UserService.js with a simple user management class

# Expected: Hook should BLOCK with TDD violation message:
# "🧪 TDD VIOLATION: No tests found for UserService.js..."

# 5. Request test file creation
> Create src/UserService.test.js with tests for UserService

# Expected: Hook should ALLOW (test files always allowed)

# 6. Request implementation again
> Now create src/UserService.js implementation

# Expected: Hook should ALLOW (tests exist)
```

### Hook Output Format (v3.0+)

All PreToolUse hooks MUST use this exact JSON format:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow" | "deny" | "ask",
    "permissionDecisionReason": "Human-readable explanation"
  }
}
```

**DEPRECATED (v2.x)**: Old format no longer works:
```json
{"allow": true, "reason": "..."}  // ❌ Does not work
```

### Troubleshooting Hook Failures

**Symptom**: Hooks don't block/allow as expected, operations succeed when they should be blocked.

**Common Causes**:

1. **Wrong JSON format** - Hooks using deprecated `{"allow": ...}` format instead of `hookSpecificOutput`
2. **Non-executable hooks** - Run `chmod +x .claude/hooks/*.sh`
3. **Missing settings.json configuration** - Verify `.claude/settings.json` has PreToolUse hooks configured
4. **Hook script errors** - Test hook manually to see error messages

**Debugging Steps**:

```bash
# 1. Test hook manually with verbose output
cd /path/to/test/directory
echo '{"tool_name": "Write", "tool_input": {"file_path": "test.js"}}' | bash -x ./.claude/hooks/tdd-gate.sh

# 2. Check hook permissions
ls -la .claude/hooks/
# All .sh files should have execute permission (rwxr-xr-x)

# 3. Verify settings.json configuration
cat .claude/settings.json | jq '.hooks.PreToolUse'
# Should show tdd-gate.sh configured for Edit|Write matcher

# 4. Check hook output is valid JSON
echo '{"tool_name": "Write", "tool_input": {"file_path": "test.js"}}' | ./.claude/hooks/tdd-gate.sh | jq .
# Should parse without errors and show hookSpecificOutput structure
```

### Hook Development Workflow

When modifying hooks:

1. **Edit hook template** in `templates/hooks/`
2. **Update tests** if hook behavior changes
3. **Test manually** using echo/pipe method (see above)
4. **Deploy locally** with `./scripts/test-local.sh`
5. **Test in live Claude Code session** to verify user experience
6. **Document changes** in CHANGELOG.md

## Testing Deterministic Logging System (v3.0)

### Logging System Overview

The deterministic logging system captures complete audit trails of all hook decisions and memory operations. This is critical for research, debugging, and understanding workflow behavior.

### Testing Logging End-to-End

**Step 1: Deploy Package**
```bash
./scripts/test-local.sh
cd /mnt/h/Active/npm-tests/ccc-testing-vN
```

**Step 2: Start Claude Code Session**
```bash
claude-code
```

**Step 3: Enable Logging**
```
/van logging enable
```

Expected output:
```
✅ Toggle file created: .claude/memory/.logging-enabled
📊 Logging System ENABLED
...
```

**Step 4: Verify Toggle File Created**
```bash
test -f .claude/memory/.logging-enabled && echo "✅ Toggle exists" || echo "❌ Missing"
```

**Step 5: Run Workflow**
```
/van "build me a simple todo application"
```

**Step 6: Check Logs Populated**
```bash
# Count events
wc -l .claude/memory/logs/current/hooks.jsonl
wc -l .claude/memory/logs/current/memory.jsonl

# Should show non-zero line counts (e.g., 37 and 36)
```

**Step 7: Inspect Log Content**
```bash
# View hook decisions
head -5 .claude/memory/logs/current/hooks.jsonl

# Count hook types
grep -o '"hook":"[^"]*"' .claude/memory/logs/current/hooks.jsonl | sort | uniq -c

# View memory rollups
grep '"type":"rollup"' .claude/memory/logs/current/memory.jsonl | head -5
```

**Step 8: Test Disable**
```
/van logging disable
```

Expected: Toggle file removed, logs preserved.

### What Should Be Logged

**Hook Events (hooks.jsonl)**:
- PreToolUse decisions for Task, Write, Edit operations
- SubagentStop validations (tests + deliverables)
- TDD gate enforcement decisions
- Decision reasons and validation checks

**Memory Operations (memory.jsonl)**:
- Task status updates (pending → in-progress → done)
- WBS rollups (status propagation through hierarchy)
- File paths and operation types

### Common Issues

**Empty log files despite workflow completing**:
- Check toggle file exists: `test -f .claude/memory/.logging-enabled`
- If missing: `/van logging enable` wasn't run correctly
- Solution: Logging scripts guarantee toggle file creation

**Logs not updating**:
- Verify hooks have executable permissions: `ls -la .claude/hooks/*.sh`
- Check hooks source logging.sh library
- Verify hooks call log_hook_event() before decisions

**Malformed JSON in logs**:
- Check hook scripts properly escape reason strings
- Verify jq can parse: `jq . .claude/memory/logs/current/hooks.jsonl`

## Testing Complete Agent Workflow (v3.0)

### Full Integration Test - Login Form Example

This test validates the ENTIRE intelligent agent orchestration system:

**Step 1: Deploy Package**
```bash
./scripts/test-local.sh
cd /mnt/h/Active/npm-tests/ccc-testing-vN  # Script auto-navigates here
```

**Step 2: Start Claude Code Session**
```bash
claude-code
```

**Step 3: Make Simple Request**
```
/van

Build a simple login form with username and password fields
```

**Expected Agent Workflow (Automatic):**

```
🚀 COLLECTIVE FRAMEWORK ACTIVATED

Step 1: Deploying @component-implementation-agent
[Agent writes tests first - TDD hook enforces this]
[Agent writes login form implementation]
✅ Agent suggests: "Deploy @tdd-validation-agent"

Step 2: Hub deploys @tdd-validation-agent
[Agent validates TDD methodology]
[Agent scans code, detects <form> and event handlers]
✅ Agent suggests: "Deploy @chrome-devtools-testing-agent - UI detected"

Step 3: Hub deploys @chrome-devtools-testing-agent
[Agent starts dev server or navigates to page]
[Agent fills username field]
[Agent fills password field]
[Agent clicks submit button]
[Agent verifies DOM state changed]
[Agent takes before/after screenshots]
✅ Agent reports: "UI interactions verified"

🎉 ALL GATES PASSED - Complete
```

### What to Verify

**TDD Hook Working:**
- Implementation agent should create test file BEFORE implementation file
- If you see implementation created first → hook is broken

**Agent Handoffs Working:**
- Hub should deploy tdd-validation-agent after implementation agent completes
- Hub should deploy chrome-devtools-testing-agent after TDD validation (if UI detected)
- If Hub implements directly → delegation broken

**Browser Testing Working:**
- Chrome DevTools agent should CLICK and FILL forms (not rely on console.log)
- Agent should verify DOM state changes via evaluate_script
- Agent should take screenshots
- If agent asks for console.log → agent instructions broken

### Common Issues

**"Hub implements directly instead of using agents"**
- Check `/van` command instructs "MUST delegate via Task tool"
- Check agent descriptions are clear for routing

**"Browser testing not triggered"**
- Check tdd-validation-agent scans for DOM/UI code
- Check agent suggests chrome-devtools-testing-agent

**"TDD hook doesn't block"**
- Check hook uses hookSpecificOutput JSON format
- Check settings.json has PreToolUse hooks configured
- Test hook manually: `echo '{"tool_name": "Write", "tool_input": {"file_path": "test.js"}}' | ./.claude/hooks/tdd-gate.sh`

This codebase implements a sophisticated agent collective system with strong TDD enforcement and intelligent routing capabilities.