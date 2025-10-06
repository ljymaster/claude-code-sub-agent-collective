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

## CRITICAL RULE: Determinism Through Hooks, Not Instructions

**NEVER add conditional logic or checks to van.md, agent files, or command files.**

❌ **WRONG (van.md):**
```
Check if .preflight-done exists. If YES, skip. If NO, run questions.
```

✅ **CORRECT (van.md):**
```
Run preflight questions. Create .preflight-done when complete.
```

**Why:**
- van.md/agents = **INSTRUCTIONS ONLY** - Tell Hub/agents what to do
- Hooks = **ALL LOGIC** - Check conditions, enforce rules, block/allow

**The hook handles:**
- Checking if .preflight-done exists
- Denying deployment if missing
- Allowing deployment if present

**van.md just says:**
- Do Step 0
- Do Step 1
- etc.

Hub Claude follows instructions. Hook enforces rules. Clean separation.

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

1. **Hub Claude** analyzes request → deploys `@task-breakdown-agent` via Task tool

2. **@task-breakdown-agent** executes:
   - Creates task hierarchy (Epic → Features → Tasks)
   - Creates test+implementation task pairs for each feature
   - Stores in `.claude/memory/task-index.json`

3. **For each feature, Hub Claude executes TDD cycle:**
   - Deploys `@test-first-agent` for test task (e.g., 1.1.1)
   - Deploys `@component-implementation-agent` for implementation task (e.g., 1.1.2)
   - TDD hooks enforce tests-first (blocks Write until tests exist)

4. **When feature completes (all tasks done), hooks ENFORCE 3-gate validation:**
   - **SubagentStop hook** creates TWO markers:
     - `.needs-validation-{FEATURE_ID}` → TDD validation required
     - `.needs-deliverables-validation-{FEATURE_ID}` → File validation required
   - **PreToolUse hook** BLOCKS all task deployments until validation complete

5. **Gate 1: TDD Validation** - `@tdd-validation-agent` (ENFORCED):
   - **PreToolUse hook** BLOCKS all agents except tdd-validation-agent
   - Hub MUST deploy `@tdd-validation-agent` (only way forward)
   - Runs tests to verify they pass
   - Removes validation marker when complete

6. **Gate 2: Deliverables Validation** - `@deliverables-validation-agent` (ENFORCED):
   - **PreToolUse hook** BLOCKS all agents except deliverables-validation-agent
   - Hub MUST deploy `@deliverables-validation-agent` (only way forward)
   - **INTELLIGENTLY analyzes files created during feature:**
     - Scans filesystem for files not in deliverables
     - CSS for HTML/JSX/TSX? → Adds to deliverables ✅
     - Assets in same directory? → Adds to deliverables ✅
     - Unrelated files? → Reports error ❌
   - Updates `task-index.json` deliverables array
   - Removes deliverables marker when complete

7. **Gate 3: Browser Testing** - `@chrome-devtools-testing-agent` (CONDITIONAL):
   - **tdd-validation-agent scans code** for UI elements:
     - Detects `<form>`, `<input>`, `<button>` elements
     - Detects `addEventListener`, `onclick` handlers
     - Detects DOM manipulation (`document.querySelector`, etc.)
   - **IF UI detected**: Creates `.needs-browser-testing-{FEATURE_ID}` marker
   - **IF no UI**: Skips browser testing, continues to next feature
   - **PreToolUse hook** BLOCKS all agents except chrome-devtools-testing-agent
   - Hub MUST deploy `@chrome-devtools-testing-agent` (if browserTesting=true)

8. **@chrome-devtools-testing-agent** executes:
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

8. **Workflow continues** to next feature → Repeat steps 3-7 for each feature

9. **Hub Claude** reports all features complete → Epic done

### Key Principles (CRITICAL)

**VALIDATION IS DETERMINISTIC AND ENFORCED:**
- Hooks physically block workflow until validation agents deployed
- Hub has NO CHOICE - must deploy tdd-validation-agent when feature completes
- Browser testing automatically enforced when UI detected + browserTesting=true
- NOT based on Hub decisions or agent suggestions - enforced by hooks

**BROWSER TESTING USES ACTUAL INTERACTIONS:**
- Chrome DevTools MCP **clicks buttons** and **fills forms**
- Verifies DOM state changes via JavaScript evaluation
- Takes screenshots for visual validation
- Does NOT rely on console.log (only checks for errors)

**TDD HOOKS ENFORCE TEST-FIRST:**
- PreToolUse hook blocks Write/Edit operations
- Implementation files cannot be written until tests exist
- Automatic and transparent to agents

**HOOK-BASED ENFORCEMENT SYSTEM:**
- SubagentStop creates validation markers when features complete
- PreToolUse blocks tasks until correct validation agents deployed
- Markers removed when correct agent deployed
- System is 100% deterministic - no LLM decision-making

### Agent Intelligence Rules

**task-breakdown-agent:**
- Creates deterministic task hierarchy from user request
- Creates test+implementation task pairs for each feature
- Assigns specialist agents to each task

**test-first-agent:**
- Writes tests BEFORE implementation
- Creates test files that hooks will use for TDD enforcement

**component-implementation-agent:**
- Implements UI components after tests written
- Completes task → hook creates validation marker → workflow blocked

**tdd-validation-agent:**
- DEPLOYED AUTOMATICALLY when feature completes (hook enforced - Gate 1)
- Validates TDD methodology (tests pass, build succeeds)
- **Scans code for**: `<form>`, `<input>`, event handlers, DOM APIs
- **IF UI detected**: Creates browser testing marker → workflow blocked again
- **IF no UI**: Workflow continues

**deliverables-validation-agent:**
- DEPLOYED AUTOMATICALLY after TDD validation (hook enforced - Gate 2)
- Scans filesystem for files created during feature
- **INTELLIGENTLY categorizes files**:
  - CSS/SCSS/SASS for HTML/JSX/TSX → Adds to deliverables ✅
  - Assets in same directory → Adds to deliverables ✅
  - Test/config files → Skips (infrastructure)
  - Unrelated files → Reports error ❌
- Updates `task-index.json` deliverables array
- Validation happens at feature completion (full context available)

**chrome-devtools-testing-agent:**
- DEPLOYED AUTOMATICALLY when UI detected + browserTesting=true (hook enforced - Gate 3)
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

**Test changes before publishing to ensure templates install correctly:**

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

### CRITICAL: Development vs User Files

**Root `.claude/` Directory (YOUR development environment):**
- ❌ **NEVER COMMIT** - This is your local Claude Code configuration
- ❌ **NOT DISTRIBUTED** - Users never see this
- ✅ **Git ignored** - Should be in `.gitignore`
- Purpose: Your personal development setup for working on this NPM package

**`templates/.claude/` Directory (what USERS get):**
- ✅ **COMMIT ALL CHANGES** - This gets distributed to users
- ✅ **PACKAGED IN NPM** - Installed when users run `npx claude-code-collective init`
- ✅ **Git tracked** - Core part of the package
- Purpose: The collective framework that users install in their projects

**Rule: Edit `templates/` to update the collective, ignore root `.claude/`**

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

## TDD-Based Issue Remediation Framework

### When to Use This Framework

Apply this systematic approach when:
- **Fixing reported bugs** in hooks, agents, or core systems
- **Implementing new features** that could break existing behavior
- **Refactoring critical paths** like task management or validation logic
- **Addressing user feedback** about workflow failures

### The RED-GREEN-REFACTOR Cycle

**Core Principle**: Write the test FIRST, watch it FAIL, then fix the code.

#### Phase 1: RED (Write Failing Test)

1. **Create smoke test file** in `templates/.claude-collective/smoke-tests/`:
   ```bash
   # Naming convention: [component]-[issue].test.sh
   # Examples:
   # - subagent-stop-reliability.test.sh
   # - tdd-gate-completion.test.sh
   # - task-id-extraction.test.sh
   # - hook-error-propagation.test.sh
   ```

2. **Test structure** (use this template):
   ```bash
   #!/bin/bash
   # Smoke test: [Description of what's being tested]
   # Validates that [specific behavior or requirement]

   set -euo pipefail

   # Colors
   GREEN='\033[0;32m'
   RED='\033[0;31m'
   YELLOW='\033[1;33m'
   NC='\033[0m'

   TESTS_PASSED=0
   TESTS_FAILED=0

   # Test helper
   test_hook() {
       local description="$1"
       local expected_result="$2"  # "pass" or "fail"
       local test_function="$3"

       # Test logic here
       # Increment TESTS_PASSED or TESTS_FAILED
   }

   # Setup/cleanup
   setup() { ... }
   cleanup() { ... }
   trap cleanup EXIT

   # Run tests
   setup
   echo "TEST 1: [Description]"
   test_hook "Specific behavior" "pass" "test_function_name"

   # Summary
   if [[ $TESTS_FAILED -gt 0 ]]; then
       exit 1
   else
       exit 0
   fi
   ```

3. **Test coverage requirements**:
   - Minimum 3 test cases per smoke test
   - Cover happy path (expected success)
   - Cover error path (expected failure)
   - Cover edge cases (boundary conditions)

4. **Make executable and register**:
   ```bash
   chmod +x templates/.claude-collective/smoke-tests/[test-name].test.sh
   ```

   Add to `lib/file-mapping.js`:
   ```javascript
   {
     file: 'smoke-tests/[test-name].test.sh',
     required: true,
     executable: true,
     description: '[Description] validation smoke test'
   }
   ```

5. **Deploy and verify FAILURE**:
   ```bash
   ./scripts/test-local.sh 2>&1 | grep -A 20 "[test-name]"
   ```

   **CRITICAL**: At least one test MUST fail initially. If all tests pass, the test isn't detecting the bug.

#### Phase 2: GREEN (Fix the Code)

1. **Locate the bug** using test failure output:
   ```bash
   # Failed test tells you exactly what's broken
   # Example: "Testing: Extract from .current-task marker ... ❌ FAIL"
   ```

2. **Fix the root cause** (not symptoms):
   - Hooks: `templates/hooks/[hook-name].sh`
   - Libraries: `templates/.claude/memory/lib/[lib-name].sh`
   - Commands: `templates/commands/[command-name].md`
   - Agents: `templates/agents/[agent-name].md`

3. **Avoid these anti-patterns**:
   - ❌ Adding `|| true` to hide errors
   - ❌ Fixing only the specific test case
   - ❌ Working around the bug instead of fixing it
   - ❌ Changing test to match broken behavior

4. **Verify fix**:
   ```bash
   ./scripts/test-local.sh 2>&1 | grep -A 20 "[test-name]"
   # All tests should now pass
   ```

5. **Verify no regressions**:
   ```bash
   ./scripts/test-local.sh 2>&1 | tail -20
   # Should show: "✅ ALL SMOKE TESTS PASSED"
   ```

#### Phase 3: COMMIT (Document the Fix)

**Commit message template**:
```
test: Add [component] smoke test and fix [issue]

RED Phase (Test First):
- Created [test-name].test.sh with N test cases
- TEST X exposed bug: [description of bug]
- Test failed as expected, proving bug exists

GREEN Phase (Fix):
- [Description of fix applied]
- [Specific file and function modified]
- All N tests now passing

Test Coverage:
1. [Test case 1 description] ✅
2. [Test case 2 description] ✅
3. [Test case 3 description] ✅
...

Bug Fixed: [High-level description of what's now fixed]

Impact: [What this enables or prevents]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Example commits**: `58be664`, `4d78ba5`, `c6de3e2`, `5af882f` (see git log)

### Real-World Examples

#### Example 1: SubagentStop Reliability (Issue #1)

**Problem**: Hook silently failed when parent task didn't exist in hierarchy.

**RED Phase**:
```bash
# Created: subagent-stop-reliability.test.sh
# TEST 3: Error detection and reporting
# Result: ❌ FAIL (expected: pass, got: fail)
```

**GREEN Phase**:
```bash
# Fixed: templates/.claude/memory/lib/wbs-helpers.sh
# Added parent validation to calculate_rollup()
# Result: ✅ PASS (all 4 tests)
```

**Impact**: Prevents task hierarchy corruption.

#### Example 2: TDD-Gate Completion Logic (Issue #2)

**Problem**: TDD-gate blocked writes even after epic completion.

**RED Phase**:
```bash
# Created: tdd-gate-completion.test.sh
# TEST 2: Allows writes after epic completion
# Result: ❌ FAIL (expected: allow, got: deny)
```

**GREEN Phase**:
```bash
# Fixed: templates/hooks/tdd-gate.sh
# Added epic completion check (allow integration phase)
# Result: ✅ PASS (all 4 tests)
```

**Impact**: Enables final integration work after all tasks complete.

#### Example 3: Task ID Extraction (Issue #3)

**Problem**: SubagentStop couldn't extract task ID with complex prompts.

**RED Phase**:
```bash
# Created: task-id-extraction.test.sh (5 test cases)
# All tests passed in isolation (testing correct logic)
# But hook implementation missing fallback mechanism
```

**GREEN Phase**:
```bash
# Fixed: templates/hooks/subagent-validation.sh
# Added .current-task marker fallback (3rd extraction method)
# Added task ID validation (prevents invalid IDs)
# Updated: templates/commands/van.md (write marker before deployment)
# Result: ✅ PASS (all 5 tests)
```

**Impact**: Reliable task extraction even with parallel execution.

#### Example 4: Hook Error Propagation (Issue #4)

**Problem**: Critical errors hidden by `|| true` statements.

**RED Phase**:
```bash
# Created: hook-error-propagation.test.sh (6 test cases)
# Tests validated error handling logic worked
# Identified 2 critical `|| true` locations hiding errors
```

**GREEN Phase**:
```bash
# Fixed: templates/hooks/subagent-validation.sh (line 142)
# Removed `|| true` from propagate_status_up
# Added structured error reporting
# Fixed: templates/hooks/pre-agent-deploy.sh (line 222)
# Removed `|| true` from status update
# Returns structured deny decision on failure
# Result: ✅ PASS (all 6 tests)
```

**Impact**: Errors surface immediately instead of corrupting state.

### Smoke Test Organization

**Directory structure**:
```
templates/.claude-collective/smoke-tests/
├── run-all.sh                           # Master test runner
├── preflight-validation.test.sh         # User input validation
├── subagent-stop-reliability.test.sh    # Hook reliability
├── tdd-gate-completion.test.sh          # Completion logic
├── task-id-extraction.test.sh           # ID extraction
├── hook-error-propagation.test.sh       # Error handling
├── tdd-gate-task-aware.test.sh          # Task awareness
├── van-instructions.test.sh             # Command accuracy
└── wbs-helpers.test.sh                  # WBS functions
```

**Naming conventions**:
- `[component]-[issue].test.sh` - Specific issue tests
- `[component]-validation.test.sh` - Input/output validation
- `[component]-reliability.test.sh` - Reliability/consistency tests
- `[library].test.sh` - Library function tests

### Running Smoke Tests

**During development**:
```bash
# Test single suite
cd /path/to/test/installation
./.claude-collective/smoke-tests/[test-name].test.sh

# Test all suites
./.claude-collective/smoke-tests/run-all.sh
```

**Full deployment test**:
```bash
# From repository root
./scripts/test-local.sh

# Check results
# Should show: "✅ ALL SMOKE TESTS PASSED"
```

### Troubleshooting Failed Tests

**If test fails unexpectedly**:

1. **Run with verbose output**:
   ```bash
   bash -x ./.claude-collective/smoke-tests/[test-name].test.sh
   ```

2. **Check test isolation**:
   - Does setup() create clean state?
   - Does cleanup() restore original state?
   - Are tests interdependent (bad)?

3. **Verify test logic**:
   - Is expected_result correct?
   - Is the test function testing the right thing?
   - Are file paths absolute or relative?

4. **Check test environment**:
   - Does .claude/memory/task-index.json exist?
   - Are required libraries sourced?
   - Do marker directories exist?

### Best Practices

1. **Test in isolation**: Each test case should be independent
2. **Clean state**: Setup creates fresh environment, cleanup restores
3. **Descriptive names**: Test name should explain what's being validated
4. **Fail fast**: Use `set -euo pipefail` to catch errors early
5. **Structured output**: Use color coding and consistent formatting
6. **No manual intervention**: Tests should run completely automated
7. **Exit codes**: 0 = all pass, 1 = some failed (for CI/CD)

### Anti-Patterns to Avoid

❌ **Changing test to match bug**:
```bash
# WRONG: Test expects broken behavior
test_hook "Allow invalid task ID" "allow" "test_invalid_id"
```

✅ **Changing code to match test**:
```bash
# CORRECT: Test expects correct behavior
test_hook "Reject invalid task ID" "deny" "test_invalid_id"
# Then fix code to make test pass
```

❌ **Skipping RED phase**:
```bash
# WRONG: Fix code first, then write test
# You don't know if test actually catches the bug
```

✅ **Always RED first**:
```bash
# CORRECT: Write test, see it fail, then fix
# Proves test actually detects the bug
```

❌ **Batch fixing multiple issues**:
```bash
# WRONG: Fix 4 issues in 1 commit
# Hard to review, hard to revert, hard to understand
```

✅ **One issue per commit**:
```bash
# CORRECT: 1 smoke test + 1 fix per commit
# Easy to review, easy to revert, clear history
```

### Metrics and Quality Indicators

**Good test coverage**:
- 8+ smoke test suites
- 35+ individual test cases
- 100% smoke test pass rate
- No `|| true` in critical paths

**Signs of quality**:
- All tests independent (can run in any order)
- Tests complete in < 5 seconds each
- Setup/cleanup properly isolate tests
- Failures provide actionable error messages

**Red flags**:
- Tests that "sometimes" fail (non-deterministic)
- Tests requiring manual setup
- Tests with hardcoded paths outside test directory
- Tests that modify repository state without cleanup

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

### Documentation Cross-Referencing (MANDATORY)

**CRITICAL**: All documentation must be properly cross-referenced to maintain document hierarchy and traceability.

**Rules:**
1. **Never create standalone documents** - All new documents MUST reference their parent/related documents
2. **Document hierarchy**:
   - `ai-docs/START-HERE.md` - Main entry point (read this first)
   - `ai-docs/V3-Cleanup-And-Final-Analysis.md` - Current focus document for v3.0 work
   - All other docs link back to one of these
3. **Reference format** - Include parent document link at the top of any detailed plan/analysis document
4. **Update parent AND START-HERE** - When creating a detailed document, ALWAYS add reference to it in parent document AND update START-HERE.md if it's a major doc
5. **Related documents** - List all related documents for context

**Example (Correct):**
```markdown
# Phase 0.5: PRD Workflow Integration - Implementation Plan

**Parent Document**: `ai-docs/V3-Cleanup-And-Final-Analysis.md` (see Phase 0.5 section)
**Related Documents:**
- `ai-docs/PRD-Workflow-Gap-Analysis.md` - Gap analysis
- `ai-docs/V3-IMPLEMENTATION-SUMMARY.md` - Overall summary

...document content...
```

**In Parent Document:**
```markdown
### Phase 0.5: PRD Workflow Integration

**📋 DETAILED IMPLEMENTATION PLAN:** See `ai-docs/Phase-0.5-Implementation-Plan.md`

**Quick Summary:**
- Key points here
- Link to detailed plan above
```

**Why This Matters:**
- User needs to understand document relationships
- Prevents orphaned documents
- Maintains clear document hierarchy
- Makes it easy to navigate documentation
- Ensures all work is tracked in main document

**If you violate this rule:** User will call it out as unacceptable (and they're right)

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
- SubagentStop hook should create validation marker when feature completes
- PreToolUse hook should BLOCK Hub from deploying any agent except tdd-validation-agent
- tdd-validation-agent should create browser testing marker when UI detected
- PreToolUse hook should BLOCK Hub from deploying any agent except chrome-devtools-testing-agent (if browserTesting=true)
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
- Check SubagentStop hook creates validation marker when feature completes
- Check PreToolUse hook blocks workflow until tdd-validation-agent deployed
- Check tdd-validation-agent scans for DOM/UI code and creates browser testing marker
- Check PreToolUse hook blocks workflow until chrome-devtools-testing-agent deployed (if browserTesting=true)
- Check .claude/memory/markers/ directory for marker files
- Check hook logs: `cat .claude/memory/logs/current/hooks.jsonl | jq 'select(.reason | contains("validation"))'`

**"TDD hook doesn't block"**
- Check hook uses hookSpecificOutput JSON format
- Check settings.json has PreToolUse hooks configured
- Test hook manually: `echo '{"tool_name": "Write", "tool_input": {"file_path": "test.js"}}' | ./.claude/hooks/tdd-gate.sh`

This codebase implements a sophisticated agent collective system with strong TDD enforcement and intelligent routing capabilities.