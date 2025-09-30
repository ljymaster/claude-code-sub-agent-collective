# V3 Migration Plan: Claude Code Collective → Native Claude 4.5 Features

**Version**: 2.0.8 → 3.0.0 (BREAKING CHANGES)
**Target Release**: Q1 2025
**Author**: Claude Code Collective Team
**Status**: Planning Phase

---

## 🎯 Executive Summary

### Goal
Migrate from custom handoff/routing system to native Claude 4.5 features while preserving core value propositions: TDD enforcement, quality gates, and research framework.

### Why Now?
Claude 4.5 introduces native capabilities that eliminate ~70% of our custom infrastructure:
- **Native Sub-Agent System** → Replaces custom handoff detection and routing
- **Native Memory System** → Replaces behavioral loading hooks
- **Enhanced Hook System** → Enables better TDD enforcement with decision control
- **Output Styles** → Provides mode switching without custom commands

### Impact
- **Code Reduction**: ~5000+ lines removed (handoff logic, routing, JSON parsing)
- **Reliability**: Eliminate regex patterns, Unicode normalization, JSON parsing edge cases
- **User Experience**: Automatic delegation (no `/van` command needed)
- **Maintenance**: 70% reduction in hook complexity

---

## 📊 Current State Analysis

### What We Built (v2.x)
Custom infrastructure to solve agent coordination problems:

1. **Custom Handoff System** (`test-driven-handoff.sh` - 651 lines)
   - Pattern matching: `Use the ([a-z0-9-]+) subagent to .+`
   - Unicode dash normalization
   - JSON parsing from tool responses
   - Automatic Task() emission

2. **Custom Routing Logic** (`DECISION.md` - 36 lines)
   - Auto-delegation detection
   - Behavioral rule loading decisions
   - Context file checking (`.claude/handoff/NEXT_ACTION.json`)

3. **Hub-Spoke Architecture** (`/van` command)
   - Central routing through task-orchestrator
   - Complex agent selection matrices
   - Handoff validation

4. **Behavioral Loading System** (`load-behavioral-system.sh`)
   - SessionStart hooks
   - Context injection
   - Prime directive loading

### Why It Was Necessary
At the time of creation (mid-2024), Claude Code lacked:
- Automatic agent routing
- Persistent memory
- Agent-to-agent communication
- Behavioral mode switching

Our system filled these gaps through clever engineering.

---

## 🚀 Native Claude 4.5 Capabilities

### 1. Native Sub-Agent System
**What It Does:**
- Automatic proactive delegation based on task/agent description matching
- Isolated context windows per agent
- Project-level agents take precedence over user-level
- Simple markdown file definitions in `.claude/agents/`

**What It Replaces:**
- ❌ `test-driven-handoff.sh` (651 lines)
- ❌ `DECISION.md` auto-delegation logic
- ❌ `routing-executor.sh`
- ❌ `handoff-automation.sh`
- ❌ Pattern matching and Task() emission

### 2. Native Memory System
**What It Does:**
- Hierarchical memory (enterprise → project → user → local)
- Automatic loading of memory files
- Import syntax: `@./path/to/file.md`
- `/memory` command for editing

**What It Replaces:**
- ❌ `load-behavioral-system.sh`
- ❌ Complex context loading in DECISION.md
- ❌ SessionStart hooks for behavioral rules

### 3. Enhanced Hook System
**What It Provides:**
- Decision control: `allow`/`deny` tool usage
- Context injection via `prompt` type hooks
- More events: `SessionStart`, `SessionEnd`, `PreCompact`, `Notification`
- Better JSON input/output structure

**What It Enables:**
- ✅ TDD gate with blocking capability
- ✅ Simplified metrics collection
- ✅ Better security controls

### 4. Output Styles
**What It Does:**
- Modify system prompt for different behaviors
- Built-in styles: Default, Explanatory, Learning
- Custom styles saved at user or project level

**What It Replaces:**
- ❌ `/van` command
- ❌ Complex mode switching logic

---

## 🗑️ Files to Remove (9 files, ~2000 lines)

### Templates
1. `templates/.claude-collective/DECISION.md` (36 lines)
2. `templates/hooks/test-driven-handoff.sh` (651 lines)
3. `templates/hooks/load-behavioral-system.sh` (~150 lines)
4. `templates/hooks/routing-executor.sh` (~200 lines)
5. `templates/hooks/handoff-automation.sh` (~150 lines)
6. `templates/hooks/agent-detection.sh` (~100 lines)
7. `templates/hooks/workflow-coordinator.sh` (~150 lines)
8. `templates/hooks/research-evidence-validation.sh` (~100 lines)
9. `templates/commands/van.md` (~500 lines)

### Rationale
- Native subagents handle routing automatically
- Memory system handles behavioral loading
- Output styles replace mode commands
- No need for handoff pattern detection

---

## ✂️ Files to Simplify (~3500 line reduction)

### 1. Agent Definitions (32 files)
**Current**: Each agent has ~100 lines of handoff instructions
**Target**: Remove handoff sections, keep TDD workflow

**Sections to Remove:**
- "CRITICAL: HUB DELEGATION REQUIRED" blocks
- Unicode dash normalization instructions
- Handoff pattern instructions ("Use the X subagent to...")
- `.claude/handoff/NEXT_ACTION.json` file writing
- Complex routing decision trees

**Sections to Keep:**
- Agent metadata (name, description, tools, color)
- TDD workflow (RED-GREEN-REFACTOR)
- TaskMaster integration
- Context7 integration
- Quality standards
- Delivery reports

**Example Transformation:**
```diff
- ### 📦 DELIVERY & HANDOFF
- Use the task-orchestrator subagent to coordinate the next phase.
-
- **CRITICAL: Write handoff file for hub detection**
- echo '{"action": "delegate", "agent": "task-orchestrator", ...}' > .claude/handoff/NEXT_ACTION.json

+ ### 📦 DELIVERY REPORT
+ Component implementation complete. Task marked as done in TaskMaster.
+
+ ✅ Tests passing
+ ✅ Implementation validated
+ 📊 Test Results: 5/5 passing
```

### 2. settings.json.template
**Current**: 125 lines with complex hook chains
**Target**: ~60 lines with native patterns

**Remove:**
- `SubagentStop` hooks (native handles this)
- Complex SessionStart chains
- Handoff detection hooks

**Keep:**
- `PreToolUse`: TDD gate, metrics, security
- `SessionStart`: One-time initialization (simplified)
- `PostToolUse`: Metrics only

**New Structure:**
```json
{
  "deniedTools": [
    "mcp__task-master__initialize_project"
  ],
  "hooks": {
    "SessionStart": [{
      "matcher": ".*",
      "hooks": [{
        "type": "prompt",
        "prompt": "Research framework active. TDD mode enabled."
      }]
    }],
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/tdd-gate.sh"
      }]
    }],
    "PostToolUse": [{
      "matcher": ".*",
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/collective-metrics.sh"
      }]
    }]
  }
}
```

### 3. Hook Scripts
**Simplify these:**
- `directive-enforcer.sh` → Use native decision control
- `collective-metrics.sh` → Remove handoff logic, keep metrics
- `block-destructive-commands.sh` → Enhance with native decisions

---

## 📝 Files to Create (8 new files)

### 1. Output Styles (3 files)

**File**: `templates/.claude/output-styles/tdd-mode.md`
```markdown
---
name: TDD-First Development
description: Enforces test-driven development with strict RED-GREEN-REFACTOR workflow
---

# TDD-First Development Mode

You are in strict Test-Driven Development mode.

## Core Rules
- NEVER write implementation code before tests exist
- RED → GREEN → REFACTOR cycle is mandatory
- Every code change requires corresponding test coverage
- Report test results before marking tasks complete

## Workflow
1. **RED**: Write minimal failing test
2. **GREEN**: Write minimal code to pass test
3. **REFACTOR**: Clean up while keeping tests green
4. **VALIDATE**: Run full test suite
5. **REPORT**: Show test results

## Blocking Conditions
- ❌ Implementation without tests
- ❌ Claiming "done" with failing tests
- ❌ Skipping test validation

## Success Criteria
- ✅ All tests passing
- ✅ Coverage meets standards
- ✅ Test results documented
```

**File**: `templates/.claude/output-styles/collective-mode.md`
```markdown
---
name: Collective Framework
description: Activates full agent collective with research framework and orchestration
---

# Collective Framework Mode

You are the Collective Hub Controller orchestrating specialized agents.

## Prime Directives
1. **NEVER implement directly** - Delegate to specialized agents
2. **Research-driven** - Use Context7 for current documentation
3. **TDD enforced** - All implementations must follow RED-GREEN-REFACTOR
4. **Quality gates** - Validate deliverables before acceptance

## Agent Delegation
- Analyze request semantically
- Select optimal specialized agent
- Monitor execution and validate
- Collect metrics for research

## Available Agents
- @component-implementation-agent - UI components
- @feature-implementation-agent - Business logic
- @testing-implementation-agent - Test suites
- @research-agent - Documentation lookup
- @quality-agent - Code review
- [Full catalog in .claude-collective/agents.md]

## Research Framework
- Context7 integration for library docs
- TaskMaster for task management
- Complexity analysis before decomposition
- Evidence-based validation
```

**File**: `templates/.claude/output-styles/research-mode.md`
```markdown
---
name: Research-Driven Development
description: Forces Context7 documentation lookup before any implementation
---

# Research-Driven Development Mode

You must research current documentation before implementing.

## Research Requirements
1. **Identify libraries** - What frameworks/libraries are involved?
2. **Fetch current docs** - Use Context7 MCP for up-to-date documentation
3. **Validate patterns** - Ensure examples are current (not from training data)
4. **Document sources** - Track which documentation was consulted

## Context7 Integration
```javascript
// Always resolve library ID first
mcp__context7__resolve-library-id({ libraryName: "react" })

// Then fetch focused documentation
mcp__context7__get-library-docs({
  context7CompatibleLibraryID: "/facebook/react",
  topic: "hooks",
  tokens: 5000
})
```

## Delivery Requirements
- 📚 Documentation sources cited
- 🔗 Library versions noted
- ✅ Current best practices applied
- ❌ No implementation from outdated training data
```

### 2. Native Memory File

**File**: `templates/.claude/memory.md`
```markdown
# Claude Code Collective - Project Memory

## Prime Directives

### 1. Test-Driven Development (TDD) - NON-NEGOTIABLE
- RED → GREEN → REFACTOR workflow is mandatory
- Tests must be written BEFORE implementation
- "Done" means tests passing, not code written
- TDD gate blocks non-compliant changes

### 2. Research-Driven Implementation
- Use Context7 MCP for current library documentation
- Never rely on training data for library APIs
- Document sources consulted
- Verify examples are current

### 3. Quality Standards
- All implementations validated by quality gates
- TaskMaster integration for task management
- Metrics collected for continuous improvement
- Evidence-based validation required

## Agent Specializations

Import agent catalog:
@./.claude-collective/agents.md

## Quality Gates

Import quality standards:
@./.claude-collective/quality.md

## Research Framework

Import research protocols:
@./.claude-collective/research.md

---

This memory is always active. Use output styles to switch modes:
- `/output-style tdd-mode` - Strict TDD enforcement
- `/output-style collective-mode` - Full orchestration
- `/output-style research-mode` - Documentation-driven
```

### 3. Simplified Hooks

**File**: `templates/hooks/tdd-gate.sh`
```bash
#!/bin/bash
# tdd-gate.sh - TDD enforcement using native decision control

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path')

# Only gate Edit/Write operations
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
    echo '{"allow": true}'
    exit 0
fi

# Check if this is test file (allow test creation)
if [[ "$FILE_PATH" =~ \.test\.|\.spec\.|__tests__ ]]; then
    echo '{"allow": true, "reason": "Test file modification allowed"}'
    exit 0
fi

# Check if corresponding test exists
FILE_DIR=$(dirname "$FILE_PATH")
FILE_NAME=$(basename "$FILE_PATH" | sed 's/\.[^.]*$//')

# Look for test files
TEST_PATTERNS=(
    "${FILE_DIR}/${FILE_NAME}.test.*"
    "${FILE_DIR}/${FILE_NAME}.spec.*"
    "${FILE_DIR}/__tests__/${FILE_NAME}.*"
    "tests/**/${FILE_NAME}.*"
)

TEST_FOUND=false
for pattern in "${TEST_PATTERNS[@]}"; do
    if compgen -G "$pattern" > /dev/null; then
        TEST_FOUND=true
        break
    fi
done

if [ "$TEST_FOUND" = true ]; then
    echo '{"allow": true, "reason": "Tests exist for this file"}'
    exit 0
else
    echo '{
        "allow": false,
        "reason": "TDD VIOLATION: No tests found. Write tests first (RED phase).\nExpected test locations:\n- '${FILE_DIR}'/'${FILE_NAME}'.test.*\n- '${FILE_DIR}'/__tests__/'${FILE_NAME}'.*"
    }'
    exit 0
fi
```

**File**: `templates/hooks/session-init.sh`
```bash
#!/bin/bash
# session-init.sh - One-time session initialization

echo "🚀 Claude Code Collective v3.0 initialized"
echo "📚 Research framework active (Context7 + TaskMaster)"
echo "🧪 TDD gate enabled"
echo ""
echo "💡 Use output styles to switch modes:"
echo "   /output-style tdd-mode       - Strict TDD enforcement"
echo "   /output-style collective-mode - Full orchestration"
echo "   /output-style research-mode   - Documentation-driven"
```

### 4. Documentation

**File**: `ai-docs/MIGRATION-GUIDE-v3.md`
```markdown
# Migration Guide: v2.x → v3.0

## Breaking Changes

### Removed Features
1. `/van` command → Use output styles instead
2. Custom handoff system → Native subagent routing
3. DECISION.md logic → Native memory system
4. Manual behavioral loading → Automatic memory loading

### Behavioral Changes
1. **Agent routing is automatic** - No need to explicitly call agents
2. **Output styles replace commands** - Use `/output-style` not `/van`
3. **Memory is always-on** - Behavioral rules load automatically
4. **Simplified hooks** - 60% reduction in hook complexity

## Automated Migration

```bash
# Option 1: Fresh installation (recommended for new projects)
npx claude-code-collective@3.0.0 init

# Option 2: Upgrade existing installation
npx claude-code-collective@3.0.0 migrate --from=v2
```

## Manual Migration Steps

### 1. Backup Existing Installation
```bash
cp -r .claude .claude-v2-backup
cp -r .claude-collective .claude-collective-v2-backup
cp CLAUDE.md CLAUDE-v2.md
```

### 2. Update Package
```bash
npm install -g claude-code-collective@3.0.0
```

### 3. Run Migration
```bash
npx claude-code-collective migrate --from=v2
```

### 4. Validate
```bash
npx claude-code-collective validate
```

### 5. Restart Claude Code
Hooks and memory require restart to load.

## What's Preserved

✅ **Your Custom Hooks** - Backed up and preserved
✅ **Your Agent Customizations** - Handoff sections removed, rest kept
✅ **TDD Enforcement** - Now uses native decision control
✅ **Quality Gates** - All gate agents preserved
✅ **TaskMaster Integration** - Fully preserved
✅ **Research Framework** - Fully preserved
✅ **Metrics Collection** - Simplified but functional

## Troubleshooting

### Agents not routing automatically
- Ensure agent descriptions are clear
- Check `.claude/agents/` files exist
- Restart Claude Code

### TDD gate not blocking
- Verify `tdd-gate.sh` has execute permissions
- Check settings.json has PreToolUse hook
- Test with: `ls -l .claude/hooks/tdd-gate.sh`

### Memory not loading
- Check `.claude/memory.md` exists
- Verify imports with `@` syntax are correct
- Use `/memory` command to view loaded memories

### Output styles not working
- Verify `.claude/output-styles/` directory exists
- Check markdown frontmatter is correct
- Use `/output-style` command to list available

## Rollback

If v3 doesn't work for you:

```bash
# Restore v2 backup
rm -rf .claude .claude-collective CLAUDE.md
mv .claude-v2-backup .claude
mv .claude-collective-v2-backup .claude-collective
mv CLAUDE-v2.md CLAUDE.md

# Reinstall v2.0.8
npx claude-code-collective@2.0.8 init --force
```

## Getting Help

- GitHub Issues: https://github.com/vanzan01/claude-code-sub-agent-collective/issues
- Validation: `npx claude-code-collective validate`
- Status: `npx claude-code-collective status`
```

**File**: `lib/v3-migrator.js`
(Implementation skeleton - to be filled during Phase 4)

---

## 🔄 Implementation Phases

### Phase 1: Create Native Replacements
**Duration**: 1-2 days
**Risk**: Low

**Tasks:**
1. Create 3 output style files
2. Create memory.md template
3. Create simplified hook templates (tdd-gate.sh, session-init.sh)
4. Test output styles manually in Claude Code

**Success Criteria:**
- ✅ Output styles load correctly
- ✅ Memory imports work
- ✅ TDD gate blocks non-compliant edits

### Phase 2: Infrastructure Updates
**Duration**: 2-3 days
**Risk**: Medium

**Tasks:**
1. Update `lib/file-mapping.js`
   - Remove mappings for deleted files
   - Add mappings for new files
2. Create `lib/v3-migrator.js`
   - Detect v2 installation
   - Backup existing files
   - Remove obsolete files
   - Install new templates
3. Update `lib/installer.js`
   - Add migration detection
   - Call migrator when needed

**Success Criteria:**
- ✅ Fresh install works with new structure
- ✅ Migrator correctly identifies v2
- ✅ Migration preserves customizations

### Phase 3: Remove Obsolete Files
**Duration**: 1 day
**Risk**: Low

**Tasks:**
1. Delete 9 obsolete template files
2. Update file-mapping.js to reflect deletions
3. Update tests to remove handoff test cases
4. Run test suite to catch breakage

**Success Criteria:**
- ✅ All tests pass after deletion
- ✅ No broken file references
- ✅ Installation still works

### Phase 4: Simplify Agent Files
**Duration**: 2-3 days
**Risk**: Medium-High

**Tasks:**
1. Create batch update script
2. Process all 32 agent files:
   - Remove handoff sections
   - Keep TDD workflow
   - Update delivery reports
3. Special handling for task-orchestrator
4. Validate agent markdown syntax

**Success Criteria:**
- ✅ All 32 agents updated
- ✅ No syntax errors
- ✅ TDD workflow preserved
- ✅ Agents still route correctly

### Phase 5: Update Documentation
**Duration**: 1-2 days
**Risk**: Low

**Tasks:**
1. Update CLAUDE.md
   - Remove hub-spoke details
   - Add native feature docs
   - Update hook system docs
2. Update README.md
   - Simplify architecture section
   - Add migration instructions
3. Create MIGRATION-GUIDE-v3.md
4. Update CHANGELOG.md

**Success Criteria:**
- ✅ Documentation accurate
- ✅ Migration guide complete
- ✅ README reflects v3

### Phase 6: Testing & Validation
**Duration**: 2-3 days
**Risk**: High

**Testing Workflow:**
```bash
# 1. Run all tests
npm run test:jest

# 2. Test fresh installation
./scripts/test-local.sh
cd ../npm-tests/ccc-v3-fresh-v1
npx claude-code-collective init
npx claude-code-collective validate

# 3. Test migration
cd ../npm-tests/ccc-v3-migration-v1
npm install <v2-tarball>
npx claude-code-collective init
npm install <v3-tarball>
npx claude-code-collective migrate --from=v2
npx claude-code-collective validate

# 4. Manual testing
# - Test native agent routing
# - Test output styles
# - Test TDD gate
# - Test metrics collection
# - Test TaskMaster integration
```

**Success Criteria:**
- ✅ All automated tests pass
- ✅ Fresh install works
- ✅ v2 → v3 migration works
- ✅ Native routing functional
- ✅ TDD gate enforces rules
- ✅ Output styles switch modes
- ✅ Memory system loads
- ✅ Metrics still collected

---

## 📋 Detailed Checklist

### Phase 1: Foundations ✓
- [ ] Create `templates/.claude/output-styles/tdd-mode.md`
- [ ] Create `templates/.claude/output-styles/collective-mode.md`
- [ ] Create `templates/.claude/output-styles/research-mode.md`
- [ ] Create `templates/.claude/memory.md`
- [ ] Create `templates/hooks/tdd-gate.sh`
- [ ] Create `templates/hooks/session-init.sh`
- [ ] Test output styles in Claude Code
- [ ] Test memory imports
- [ ] Test TDD gate hook

### Phase 2: Infrastructure ✓
- [ ] Update `lib/file-mapping.js` (remove old mappings)
- [ ] Update `lib/file-mapping.js` (add new mappings)
- [ ] Create `lib/v3-migrator.js` (detection)
- [ ] Create `lib/v3-migrator.js` (backup)
- [ ] Create `lib/v3-migrator.js` (migration)
- [ ] Create `lib/v3-migrator.js` (validation)
- [ ] Update `lib/installer.js` (add migration call)
- [ ] Test fresh installation
- [ ] Test migration detection

### Phase 3: Cleanup ✓
- [ ] Delete `templates/.claude-collective/DECISION.md`
- [ ] Delete `templates/hooks/test-driven-handoff.sh`
- [ ] Delete `templates/hooks/load-behavioral-system.sh`
- [ ] Delete `templates/hooks/routing-executor.sh`
- [ ] Delete `templates/hooks/handoff-automation.sh`
- [ ] Delete `templates/hooks/agent-detection.sh`
- [ ] Delete `templates/hooks/workflow-coordinator.sh`
- [ ] Delete `templates/hooks/research-evidence-validation.sh`
- [ ] Delete `templates/commands/van.md`
- [ ] Update file-mapping.js (remove deletions)
- [ ] Remove handoff test files
- [ ] Run `npm run test:jest`

### Phase 4: Agent Simplification ✓
- [ ] Create batch update script for agents
- [ ] Update component-implementation-agent.md
- [ ] Update feature-implementation-agent.md
- [ ] Update infrastructure-implementation-agent.md
- [ ] Update testing-implementation-agent.md
- [ ] Update polish-implementation-agent.md
- [ ] Update task-orchestrator.md (special handling)
- [ ] Update task-executor.md
- [ ] Update quality-agent.md
- [ ] Update research-agent.md
- [ ] Update prd-research-agent.md
- [ ] Update devops-agent.md
- [ ] Update all remaining agents (22 more)
- [ ] Validate markdown syntax
- [ ] Test agent routing

### Phase 5: Documentation ✓
- [ ] Update CLAUDE.md (architecture)
- [ ] Update CLAUDE.md (remove handoffs)
- [ ] Update CLAUDE.md (add native features)
- [ ] Update README.md (simplify)
- [ ] Update README.md (add migration)
- [ ] Create `ai-docs/MIGRATION-GUIDE-v3.md`
- [ ] Update CHANGELOG.md (v3.0.0 section)
- [ ] Review all documentation

### Phase 6: Testing ✓
- [ ] Run `npm run test:jest` (all pass)
- [ ] Run `npm run test:coverage` (maintain coverage)
- [ ] Test fresh install (./scripts/test-local.sh)
- [ ] Test v2 → v3 migration
- [ ] Manual: Test agent routing
- [ ] Manual: Test output styles
- [ ] Manual: Test TDD gate
- [ ] Manual: Test memory system
- [ ] Manual: Test metrics collection
- [ ] Manual: Test TaskMaster integration
- [ ] Manual: Test quality gates
- [ ] Create test report

### Phase 7: Release ✓
- [ ] Bump package.json to 3.0.0
- [ ] Update version in all docs
- [ ] Create comprehensive commit
- [ ] Push branch
- [ ] Create PR with full details
- [ ] Review and approve
- [ ] Merge to main
- [ ] Tag release v3.0.0
- [ ] Publish to npm
- [ ] Announce breaking changes

---

## 🎯 Success Metrics

### Code Quality
- ✅ **~5000 lines removed** (handoff logic, routing, parsing)
- ✅ **~800 lines added** (output styles, simplified hooks, migration tool)
- ✅ **Net reduction: ~4200 lines** (70% complexity reduction)
- ✅ **Zero new dependencies** (use native features)

### Reliability
- ✅ **Eliminate regex edge cases** (no more pattern matching)
- ✅ **Eliminate JSON parsing errors** (native handles this)
- ✅ **Eliminate Unicode issues** (no dash normalization)
- ✅ **Deterministic routing** (native subagent system)

### User Experience
- ✅ **Automatic delegation** (no `/van` needed)
- ✅ **Faster routing** (native is immediate)
- ✅ **Better error messages** (native error handling)
- ✅ **Cleaner output** (less hook noise)

### Maintainability
- ✅ **70% fewer hooks** (9 files → 3 files)
- ✅ **Simpler agent files** (~100 lines → ~50 lines each)
- ✅ **Native features** (less custom code to maintain)
- ✅ **Better documentation** (migration guide, updated README)

---

## ⚠️ Risk Mitigation

### Risk 1: Breaking Existing Users
**Probability**: High
**Impact**: High
**Mitigation**:
- Automated migration tool
- Comprehensive migration guide
- Keep v2.0.8 available on npm
- Clear communication about breaking changes
- Testing on multiple projects

### Risk 2: Native Features Insufficient
**Probability**: Medium
**Impact**: High
**Mitigation**:
- Thorough testing of native capabilities
- Keep TDD gate as custom hook (proven)
- Preserve quality gates (unique value)
- Document any gaps found
- Plan for fallbacks if needed

### Risk 3: Migration Tool Failures
**Probability**: Medium
**Impact**: Medium
**Mitigation**:
- Backup before migration
- Manual migration guide as fallback
- Rollback instructions
- Validation after migration
- Test migration on multiple projects

### Risk 4: Test Coverage Loss
**Probability**: Low
**Impact**: High
**Mitigation**:
- Maintain test coverage metrics
- Update tests, don't just delete
- Add tests for new native features
- Manual testing checklist
- CI/CD validation

### Risk 5: User Confusion
**Probability**: Medium
**Impact**: Medium
**Mitigation**:
- Clear migration documentation
- Video walkthrough (optional)
- Example projects
- GitHub discussions
- Quick troubleshooting guide

---

## 📅 Timeline

### Week 1: Foundations
- Day 1-2: Create output styles, memory files
- Day 3-4: Create simplified hooks
- Day 5: Test new components

### Week 2: Infrastructure & Cleanup
- Day 1-2: Update file-mapping, create migrator
- Day 3: Delete obsolete files
- Day 4-5: Update installer

### Week 3: Agent Simplification
- Day 1: Create batch update script
- Day 2-4: Update all 32 agent files
- Day 5: Validate and test

### Week 4: Documentation & Testing
- Day 1-2: Update all documentation
- Day 3-5: Comprehensive testing

### Week 5: Release
- Day 1-2: Final testing and fixes
- Day 3: Create PR and review
- Day 4-5: Merge, tag, publish, announce

**Total Duration**: ~5 weeks

---

## 🚦 Go/No-Go Criteria

### Must Have (Go Criteria)
- ✅ All tests passing
- ✅ Fresh install working
- ✅ v2 → v3 migration working
- ✅ Native routing functional
- ✅ TDD gate enforcing
- ✅ Output styles working
- ✅ Memory system loading
- ✅ Migration guide complete

### Should Have
- ✅ Test coverage maintained
- ✅ Metrics still collected
- ✅ Quality gates functional
- ✅ TaskMaster integration intact
- ✅ Documentation comprehensive

### Nice to Have
- 📹 Video walkthrough
- 🎨 Example projects
- 📝 Blog post announcement
- 💬 Community feedback

---

## 📞 Communication Plan

### Internal
- Development updates in GitHub issues
- Weekly sync on progress
- Testing reports shared
- Code review for all changes

### External
- GitHub release notes (detailed)
- npm package description update
- README.md prominent notice
- MIGRATION-GUIDE-v3.md linked everywhere
- Optional: Blog post or video

### Message
```
🚀 Claude Code Collective v3.0 - Major Upgrade

We've rebuilt the collective to use native Claude 4.5 features!

✨ What's New:
- Native sub-agent routing (no /van needed!)
- Output styles for mode switching
- Memory system for behavioral rules
- 70% simpler hook configuration

⚠️ Breaking Changes:
- Custom handoff system removed
- /van command removed
- Some hooks simplified

📖 Migration:
npx claude-code-collective@3.0.0 migrate --from=v2

Full guide: ai-docs/MIGRATION-GUIDE-v3.md

Your TDD enforcement, quality gates, and research framework are all preserved and improved!
```

---

## 🎓 Lessons Learned (Retrospective Planning)

### What We'll Track
1. **Migration success rate** - How many users migrate smoothly?
2. **Native feature gaps** - What did we miss?
3. **Performance improvements** - Is routing actually faster?
4. **User feedback** - What do users like/dislike?
5. **Bug reports** - What breaks in the wild?

### Post-Release Review
- 1 week after: Quick feedback check
- 1 month after: Comprehensive review
- 3 months after: Lessons learned document

---

## 📚 References

### Documentation
- [Claude 4.5 Sub-Agents](https://docs.claude.com/en/docs/claude-code/sub-agents.md)
- [Claude 4.5 Memory System](https://docs.claude.com/en/docs/claude-code/memory.md)
- [Claude 4.5 Hooks](https://docs.claude.com/en/docs/claude-code/hooks.md)
- [Claude 4.5 Output Styles](https://docs.claude.com/en/docs/claude-code/output-styles.md)

### Internal Docs
- Current CLAUDE.md
- Current README.md
- Agent definitions (templates/agents/)
- Hook implementations (templates/hooks/)

---

**Status**: Plan Complete ✅
**Next Step**: Begin Phase 1 - Create Native Replacements
**Review Date**: Before starting implementation
