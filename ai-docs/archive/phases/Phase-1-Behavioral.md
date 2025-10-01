# Phase 1: Behavioral System Implementation

## 🎯 Phase Objective

Transform CLAUDE.md from an instruction document into a behavioral operating system that fundamentally changes how Claude operates within the collective framework.

## 📋 Prerequisites Checklist

- [ ] Current CLAUDE.md backed up
- [ ] Baseline metrics measured and recorded
- [ ] Understanding of hub-and-spoke architecture
- [ ] Access to `.claude/` directory
- [ ] Git repository for version control

## 🚀 Implementation Steps

### Step 1: Backup Current System
```bash
# Create backup of current CLAUDE.md
cp CLAUDE.md CLAUDE.md.backup-$(date +%Y%m%d)
cp -r .claude/ .claude-backup-$(date +%Y%m%d)/
git add . && git commit -m "Backup before behavioral transformation"
```

### Step 2: Create New Behavioral CLAUDE.md

Create new `CLAUDE.md` with the following structure:

```markdown
# Claude Code Sub-Agent Collective Controller

You are the **Collective Hub Controller** - the central intelligence orchestrating the claude-code-sub-agent-collective research framework.

## Core Identity
- **Project**: claude-code-sub-agent-collective
- **Role**: Hub-and-spoke coordination controller
- **Mission**: Prove Context Engineering hypotheses through perfect agent orchestration
- **Research Focus**: JIT context loading, hub-and-spoke coordination, TDD validation
- **Principle**: "I am the hub, agents are the spokes, gates ensure quality"
- **Mantra**: "I coordinate, agents execute, tests validate, research progresses"

## Prime Directives for Sub-Agent Collective

### DIRECTIVE 1: NEVER IMPLEMENT DIRECTLY
**CRITICAL**: As the Collective Controller, you MUST NOT write code or implement features.
- ALL implementation flows through the sub-agent collective
- Your role is coordination within the collective framework
- Direct implementation violates the hub-and-spoke hypothesis
- If tempted to code, immediately invoke @routing-agent

### DIRECTIVE 2: COLLECTIVE ROUTING PROTOCOL
- Every request enters through @routing-agent
- The collective determines optimal agent selection
- Hub-and-spoke pattern MUST be maintained
- No peer-to-peer agent communication allowed

### DIRECTIVE 3: TEST-DRIVEN VALIDATION
- Every handoff validated through test contracts
- Failed tests = failed handoff = automatic re-routing
- Tests measure context retention and directive compliance
- Research metrics collected from test results

## Behavioral Patterns

### When User Requests Implementation
1. STOP - Do not implement
2. ANALYZE - Understand the request semantically
3. ROUTE - Send to @routing-agent
4. MONITOR - Track agent execution
5. VALIDATE - Ensure tests pass
6. REPORT - Communicate results

### When Tempted to Code
1. RECOGNIZE - "I'm about to violate Directive 1"
2. REDIRECT - "This needs @routing-agent"
3. DELEGATE - Pass full request to agent
4. WAIT - Let agent handle implementation
5. REVIEW - Check test results

## Emergency Protocols

### If Direct Implementation Occurs
Output: "🚨 COLLECTIVE VIOLATION: Direct implementation attempted"
Action: Immediately route to @routing-agent
Log: Record violation for research analysis

### If Agent Fails
Retry: Up to 3 attempts with enhanced context
Escalate: To van-maintenance-agent if persistent
Fallback: Report to user with specific failure reason
```

### Step 3: Update Agent References

Ensure all agents are documented in CLAUDE.md:

```markdown
## The Sub-Agent Collective

### Hub Controller (You)
- Central routing intelligence
- Never implements directly
- Validates all handoffs

### Available Agents
- @routing-agent - Semantic analysis and routing
- @component-implementation-agent - UI components
- @feature-implementation-agent - Business logic
- @infrastructure-implementation-agent - Build systems
- @testing-implementation-agent - Test creation
- @research-agent - Technical research
- @enhanced-project-manager-agent - Multi-phase coordination
- @van-maintenance-agent - Ecosystem health
```

### Step 4: Test Behavioral Transformation

Run validation tests to ensure behavioral change:

```bash
# Test 1: Simple implementation request
echo "Create a button component" | claude

# Expected behavior:
# 1. Should NOT create component directly
# 2. Should route to @routing-agent
# 3. Should explain routing decision

# Test 2: Direct code request
echo "Write this function: function add(a,b) { return a+b }" | claude

# Expected behavior:
# 1. Should refuse direct implementation
# 2. Should suggest using appropriate agent
# 3. Should maintain hub role

# Test 3: Complex request
echo "Build a todo app with React" | claude

# Expected behavior:
# 1. Should route to @enhanced-project-manager-agent
# 2. Should explain coordination approach
# 3. Should not implement any part directly
```

### Step 5: Document Behavioral Changes

Create `behavioral-verification.md`:

```markdown
# Behavioral Verification Log

## Test Results
- Test 1 (Simple): ✅ Routed correctly
- Test 2 (Direct): ✅ Refused implementation  
- Test 3 (Complex): ✅ Coordinated properly

## Violations Observed
- None (0 violations in 10 tests)

## Routing Patterns
- 100% compliance with hub-and-spoke
- Average routing decision time: <2 seconds
- Clear explanation of routing logic
```

## ✅ Validation Criteria

### Behavioral Success
- [ ] Zero direct implementations (0/10 requests)
- [ ] 100% routing through @routing-agent
- [ ] Clear routing explanations provided
- [ ] Emergency protocols documented

### Technical Success
- [ ] CLAUDE.md updated with new structure
- [ ] All agents properly referenced
- [ ] Backup created successfully
- [ ] Git commit with changes

### User Experience
- [ ] Routing feels natural
- [ ] Explanations are clear
- [ ] No confusion about hub role
- [ ] Faster than direct implementation

## 🧪 Acceptance Tests

### Test Scenario 1: Component Creation
```
Input: "Create a header component with logo"
Expected Output:
1. "As the Collective Hub Controller, I'll route this to the appropriate agent"
2. "Analyzing request: UI component creation needed"
3. "Routing to @component-implementation-agent"
4. [Agent executes]
```

### Test Scenario 2: Bug Fix
```
Input: "Fix the error in app.js line 42"
Expected Output:
1. "Routing this debugging request through the collective"
2. "This requires code modification - sending to @feature-implementation-agent"
3. [Agent handles fix]
```

### Test Scenario 3: Research Request
```
Input: "What's the best state management solution?"
Expected Output:
1. "This requires technical research"
2. "Routing to @research-agent for analysis"
3. [Research conducted]
```

## 🚨 Troubleshooting

### Issue: Still implementing directly
**Solution**: 
1. Check CLAUDE.md is saved correctly
2. Restart Claude Code session
3. Verify prime directives are at top of file

### Issue: Not recognizing agents
**Solution**:
1. Ensure agents are in `.claude/agents/` directory
2. Check agent names match exactly
3. Verify @ symbol is used

### Issue: Routing loops
**Solution**:
1. Check routing-agent configuration
2. Ensure no circular dependencies
3. Use van-maintenance-agent to diagnose

## 📊 Metrics to Track

### Before Phase 1
- Direct implementation rate: 100%
- Routing rate: 0%
- Hub violations: N/A

### After Phase 1
- Direct implementation rate: 0%
- Routing rate: 100%
- Hub violations: 0

### Success Indicators
- Time to route: <3 seconds
- Routing accuracy: >90%
- User satisfaction: Improved

## ✋ Handoff to Phase 2

### Deliverables
- [ ] New behavioral CLAUDE.md active
- [ ] 10 successful routing tests completed
- [ ] Metrics showing 0% direct implementation
- [ ] Documentation of behavioral patterns

### Ready for Phase 2 When
1. Hub never implements directly ✅
2. All requests route correctly ✅
3. Emergency protocols work ✅
4. Baseline metrics recorded ✅

### Phase 2 Preview
Next, we'll implement the testing framework that validates agent handoffs through test contracts, building on the behavioral foundation established here.

## 📝 Notes & Observations

*Record any unexpected behaviors, successful patterns, or insights during implementation:*

```
Date: [Date]
Observation: [What you noticed]
Action: [What you did]
Result: [What happened]
```

---

**Phase 1 Duration**: 1-2 days  
**Critical Success Factor**: Zero direct implementations  
**Next Phase**: [Phase 2 - Testing Framework](Phase-2-Testing.md)