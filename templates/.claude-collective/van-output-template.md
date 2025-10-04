# /van Workflow Output Format Template

**CRITICAL: Hub Claude MUST follow these formats EXACTLY when executing /van workflows.**

This template defines the standardized, informative UI for all task execution workflows.

---

## Character Guide

**Tool Display (Claude Code UI provides):**
- `●` - Tool call indicator
- `⎿` - Tool result indicator

**Status Symbols:**
- `✅` - Success/Complete/Validated
- `⏳` - Pending/Waiting/Blocked
- `❌` - Failed/Error
- `🚀` - Activation/Start
- `🌐` - Browser/UI related
- `📊` - Logging/Metrics
- `🎉` - Celebration/Completion

**Formatting:**
- `━` - Separator line (exactly 43 characters: `━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`)
- `█` - Filled progress block
- `░` - Empty progress block

---

## STEP 0: Preflight Configuration (First Time Only)

**Check:** If `.claude/memory/.preflight-done` exists, skip this entirely.

**If not exists, display:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 0: Browser Testing Preflight Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then conduct conversational Q&A as defined in van.md STEP 0 section.

After completion:
```
● ✅ Preflight complete - Browser testing [enabled/disabled]
```

---

## STEP 1: Task Breakdown

**Format:**

```
● 🚀 DETERMINISTIC TASK SYSTEM ACTIVATED
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Analyzing PRD: [Title extracted from request]
  Tech Stack: [Detected technologies, e.g., "React 18 + TypeScript + Vite + Vitest"]

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  STEP 1: Creating Task Hierarchy
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

● task-breakdown-agent(Generate WBS from PRD)
  ⎿  Done ([N] tool uses · [X.X]k tokens · [M]m [S]s)

● ✅ Task hierarchy created successfully!
```

**Variables:**
- `[Title]` - Extract from user request or PRD
- `[Technologies]` - Auto-detected from request/PRD analysis
- `[N]` - Tool use count from agent
- `[X.X]k` - Token count formatted
- `[M]m [S]s` - Time duration

---

## STEP 2: Finding Next Available Task

**Format (for EACH task search):**

```
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  STEP 2: Finding Next Available Task
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

● Read(.claude/memory/task-index.json)
  ⎿  Read [N] lines (ctrl+o to expand)

● Found: Task [ID] ([Task Title])
    ✅ Is leaf task (no children)
    [Dependency line - see below]
    ✅ Status: pending
```

**Dependency Line Options:**
- If no dependencies: `✅ No dependencies`
- If dependencies satisfied: `✅ Dependency [ID1, ID2] satisfied (done)`
- If dependencies blocked: `⏳ Blocked - depends on [ID1, ID2]`

**Variables:**
- `[N]` - Line count from task-index.json
- `[ID]` - Task ID (e.g., "1.1.1")
- `[Task Title]` - Task title from task-index.json

---

## STEP 3: Deploying Agent

### For Test Tasks (RED Phase)

```
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  STEP 3: Deploying Agent for Task [ID] (RED phase)
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

● test-first-agent([Short description])
  ⎿  Done ([N] tool uses · [X.X]k tokens · [M]m [S]s)

● ✅ Task [ID] Complete - Tests written (RED phase)
```

### For Implementation Tasks (GREEN Phase)

```
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  STEP 3: Deploying Agent for Task [ID] (GREEN phase)
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

● [agent-name]([Short description])
  ⎿  Done ([N] tool uses · [X.X]k tokens · [M]m [S]s)

● ✅ Task [ID] Complete - Implementation done (GREEN phase)
```

**Agent Names:**
- `component-implementation-agent` - UI components
- `feature-implementation-agent` - Business logic
- `infrastructure-implementation-agent` - Build/config

**Variables:**
- `[ID]` - Task ID
- `[Short description]` - Brief task description (max 40 chars)
- `[agent-name]` - Actual agent deployed
- `[N]`, `[X.X]k`, `[M]m [S]s` - Stats from agent execution

---

## Hook Activity Summary

**Display after EVERY task completion:**

```
  Hook Activity Logged:
    ✅ PreToolUse: Task [ID] validated and marked in-progress
    [File operations line - see below]
    [TDD Gate line - see below]
    ✅ SubagentStop: [Test results], deliverables validated, task marked done
    ✅ WBS Rollup: Feature [FID] → [N]/[M] complete ([status])
    [Epic rollup line - see below]
```

**Conditional Lines:**

**File Operations:**
- If files written: `✅ PreToolUse: [N] file operations logged ([details])`
- If test files: `✅ PreToolUse: Test file writes allowed ([filenames])`
- Examples:
  - `✅ PreToolUse: 33 file operations logged (config files, tests, implementation)`
  - `✅ PreToolUse: Test file writes allowed (TodoItem.test.tsx, TodoList.test.tsx)`

**TDD Gate:**
- Only for implementation tasks: `✅ TDD Gate: Enforced test-first ([description])`
- Examples:
  - `✅ TDD Gate: Enforced test-first (blocked main.tsx/App.tsx until tests created)`
  - `✅ TDD Gate: Enforced test-first (allowed component writes after tests exist)`

**Test Results:**
- Format: `Tests passed ([N]/[M])`
- If all pass: `Tests passed ([N]/[N])`
- Examples:
  - `Tests passed (22/23)` - Shows near-complete
  - `Tests passed` - When agent doesn't report specific count

**Epic Rollup:**
- Only when feature completes: `✅ WBS Rollup: Epic [EID] → [N]/[M] features complete ([status])`
- Example: `✅ WBS Rollup: Epic 1 → 2/7 features complete (in-progress)`

**Variables:**
- `[ID]` - Task ID (e.g., "1.2.1")
- `[FID]` - Feature ID (e.g., "1.2")
- `[EID]` - Epic ID (e.g., "1")
- `[N]/[M]` - Completion counts
- `[status]` - "in-progress" or "done"
- `[details]` - Brief description of files
- `[description]` - Brief enforcement description

---

## Progress Update

**Display after EVERY feature completion (when WBS rollup marks feature as "done"):**

```
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PROGRESS UPDATE
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Epic: [Epic Title] [[N]/[M] features] [progress bar] [percentage]%

  [Feature tree - see below]
```

### Progress Bar Calculation

**Formula:**
```javascript
totalBlocks = 20
completedFeatures = N  // from task-index.json
totalFeatures = M      // from task-index.json
percentage = Math.round((completedFeatures / totalFeatures) * 100)
filledBlocks = Math.round((completedFeatures / totalFeatures) * 20)
emptyBlocks = 20 - filledBlocks

progressBar = '█'.repeat(filledBlocks) + '░'.repeat(emptyBlocks)
```

**Examples:**
- 1/7 features (14%): `███░░░░░░░░░░░░░░░░░ 14%`
- 2/7 features (29%): `██████░░░░░░░░░░░░░░ 29%`
- 3/7 features (43%): `████████░░░░░░░░░░░░ 43%`
- 7/7 features (100%): `████████████████████ 100%`

### Feature Tree Format

**Completed Features:**
```
  ✅ [ID] [Feature Title] (DONE)
      ✅ [ID] [Task Title]
      ✅ [ID] [Task Title]
```

**Pending/Blocked Features:**
```
  ⏳ [ID] [Feature Title] (ready to start)
  ⏳ [ID] [Feature Title] (blocked - depends on [IDs])
  ⏳ [ID] [Feature Title] (pending)
```

**Status Determination:**
- `(DONE)` - Feature status = "done"
- `(ready to start)` - All dependencies satisfied, status = "pending"
- `(blocked - depends on [IDs])` - Has unsatisfied dependencies
- `(pending)` - No dependencies, status = "pending"

**Show ALL features in tree**, not just completed ones.

**Variables:**
- `[Epic Title]` - From task-index.json
- `[N]/[M]` - Completed/total feature counts
- `[ID]` - Feature or task ID
- `[Feature Title]` - From task-index.json
- `[Task Title]` - From task-index.json
- `[IDs]` - Comma-separated dependency IDs

---

## Parallel Execution Detection

**Display when 2 or more features have all dependencies satisfied:**

```
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PARALLEL EXECUTION OPPORTUNITY DETECTED
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [N] features can now execute in parallel:
    • [ID] [Feature Title] (depends on [IDs] ✅)
    • [ID] [Feature Title] (depends on [IDs] ✅)
    • [ID] [Feature Title] (depends on [IDs] ✅)
```

**Detection Logic:**
- Count features where status = "pending" AND all dependencies have status = "done"
- If count >= 2, display this section
- Show which dependencies are satisfied with ✅

**Variables:**
- `[N]` - Count of ready features
- `[ID]` - Feature ID
- `[Feature Title]` - Feature title
- `[IDs]` - Dependency IDs (show with ✅)

**Variation for 2 features:**
```
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PARALLEL EXECUTION OPPORTUNITY
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Two features can execute in parallel:
    • [ID] [Feature Title] (depends on [IDs] ✅)
    • [ID] [Feature Title] (depends on [IDs] ✅)
```

---

## Final Completion

**Display when all tasks complete (Epic status = "done"):**

```
  🎉 [EPIC TITLE] COMPLETE! 🎉
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Epic: [Epic Title] [[M]/[M] features] ████████████████████████████ 100%

  ✅ ALL FEATURES COMPLETE

  [Complete feature tree with all tasks - use format from Progress Update]

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  FINAL STATISTICS
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Total Tasks: [N] ([T] test tasks + [I] implementation tasks)
  TDD Workflow: 100% test-first methodology
  Hook Enforcement: All tasks validated by hooks
  Memory System: All state tracked in task-index.json
  [Logging line - see below]

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  DELIVERABLES CREATED
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [Organized list - see below]

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  FEATURES IMPLEMENTED
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [Feature list with checkmarks - see below]

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  PROJECT STATUS: COMPLETE ✅

  [Summary - see below]
```

### Logging Line

**If logging enabled:**
```
  Logging: All [N] hook decisions logged
```

**If logging disabled:**
```
  Logging: Disabled (enable with /van logging enable)
```

Check for `.claude/memory/.logging-enabled` file existence.

### Deliverables List Format

**Organize by category:**

```
  Project Configuration:
    ✅ [filename]
    ✅ [filename]

  Type Definitions:
    ✅ [filename]

  Hooks:
    ✅ [filename]

  Components:
    ✅ [filename]
    ✅ [filename]

  Utilities:
    ✅ [filename]

  Styling:
    ✅ [filename]

  Tests (All Passing):
    ✅ [filename] ([N] tests)
    ✅ [filename] ([N] tests)
```

**Category Detection:**
- File extension and path determine category
- Common categories: Project Configuration, Type Definitions, Hooks, Components, Utilities, Styling, Tests
- Collect from all task deliverables in task-index.json

### Features Implemented Format

**Extract from features, bullet list:**

```
  ✅ [User-facing feature description]
  ✅ [User-facing feature description]
  ✅ [User-facing feature description]
```

**Examples:**
```
  ✅ Add new todos with input validation
  ✅ Edit todos inline (click to edit)
  ✅ Delete todos
  ✅ Mark todos as complete/incomplete
  ✅ Filter by all/active/completed
  ✅ Search todos by text (case-insensitive)
  ✅ localStorage persistence across sessions
  ✅ Responsive design (mobile + desktop)
  ✅ Clean, accessible UI
  ✅ Full test coverage with TDD methodology
```

Convert feature titles to user-facing descriptions.

### Final Summary Format

```
  The [Project Title] has been built following strict TDD methodology
  with deterministic task management and complete hook enforcement.

  Run the app: [command from package.json]
  Run tests: [test command from package.json]
```

**Variables:**
- `[Project Title]` - Epic title
- `[command]` - Detect from package.json scripts (npm run dev, npm start, etc.)
- `[test command]` - Usually "npm test"

---

## Special Cases

### When Last Task in Epic

**On FINAL task (before completion):**

```
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  FINAL TASK - STEP 2: Finding Next Available Task
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Found: Task [ID] ([Task Title])
    ✅ Is leaf task (no children)
    ✅ Dependency [IDs] satisfied (done)
    ✅ Status: pending

  This is the LAST task in the [Epic Title] epic!
```

### When No Next Task Available

**If all tasks complete but some blocked:**

```
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  STEP 2: Finding Next Available Task
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  No available tasks. All remaining tasks blocked by dependencies.

  Blocked Tasks:
    ⏳ [ID] [Title] (depends on [IDs])
    ⏳ [ID] [Title] (depends on [IDs])
```

This should not happen in correct WBS but handle gracefully.

---

## Consistency Rules

1. **Separator Lines**: Always exactly 43 `━` characters
2. **Indentation**: Use 2 spaces for nested content under bullets
3. **Tool Display**: Let Claude Code UI handle `●` and `⎿` - just format text around it
4. **Checkmarks**: Use `✅` for complete/validated, `⏳` for pending/blocked, `❌` for errors
5. **Progress Bars**: Always 20 blocks total (█ + ░)
6. **Emojis**: Use sparingly - only where specified in template
7. **Line Breaks**: Single blank line between major sections
8. **Variables**: Replace all `[brackets]` with actual values
9. **Capitalization**: "STEP 1", "STEP 2" always uppercase
10. **Phase Labels**: "(RED phase)", "(GREEN phase)" in deployment headers

---

## Template Usage

**Hub Claude MUST:**
- Follow these formats EXACTLY for all /van workflows
- Calculate progress bars using provided formula
- Display hook activity after every task
- Show progress updates after every feature completion
- Detect and announce parallel execution opportunities
- Provide complete final summary with all sections

**Do NOT:**
- Deviate from separator line length (43 chars)
- Skip hook activity summaries
- Omit progress updates
- Change emoji usage
- Modify progress bar block count (always 20)
- Summarize or truncate final completion report

This template ensures consistent, informative, professional output for all users.
