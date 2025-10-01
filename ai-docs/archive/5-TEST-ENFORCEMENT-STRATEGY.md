# 5-Test Maximum Rule: Enforcement Strategy Document

## Executive Summary

The Claude Code Sub-Agent Collective has a critical issue: despite having a **5-test maximum rule** documented in agent configurations, the agents created **135+ tests** instead of the expected ~40-50. This document provides a comprehensive analysis and implementation plan to enforce the 5-test limit technically rather than just documentally.

---

## 1. Problem Analysis

### 1.1 Current State
- **Expected**: ~40-50 tests total (5 tests × 8-10 components/services)
- **Actually Created**: 135+ tests
- **Violation Rate**: 270% over expected maximum

### 1.2 Test Distribution Analysis

| Test File | Current Count | Should Be | Excess |
|-----------|--------------|-----------|---------|
| `useTodos.test.ts` | 15 | 5 | 10 |
| `useTodos.advanced.test.ts` | 17 | 0 (delete) | 17 |
| `useFilteredTodos.test.ts` | 6 | 5 | 1 |
| `localStorage.test.ts` | 14 | 5 | 9 |
| `TodoItem.test.tsx` | 5 | 5 | 0 ✅ |
| `TodoItem.advanced.test.tsx` | 21 | 0 (delete) | 21 |
| `todo-workflow.test.tsx` | 9 | 5 | 4 |
| `basic-performance.test.tsx` | 8 | 5 | 3 |
| `comprehensive-app.test.tsx` | 9 | 5 | 4 |
| **Total** | **135+** | **~45** | **90+** |

### 1.3 Root Cause Analysis

#### **Contradiction in Agent Instructions**
```markdown
# testing-implementation-agent.md
Line 42: "**MAXIMUM 5 ESSENTIAL TESTS** per component/service" ✅
Line 66: "Create extensive test suites for all functionality" ❌ CONTRADICTION!
```

#### **Misinterpreted Keywords**
- **"Comprehensive"** → Agents created exhaustive tests
- **"Advanced"** → Agents created duplicate test files
- **"80% Coverage"** → Agents prioritized quantity over quality
- **"Edge Cases"** → Despite instructions to avoid, agents added many

#### **No Enforcement Mechanism**
- Rule exists as text only
- No validation checks
- No consequences for violations
- No test counting before completion

---

## 2. Agent Configuration Status

### 2.1 Agents WITH 5-Test Rule ✅
1. **component-implementation-agent** - Has rule, clear instructions
2. **feature-implementation-agent** - Has rule, proper format
3. **polish-implementation-agent** - Has rule, quality focused
4. **infrastructure-implementation-agent** - Has rule, minimal approach
5. **testing-implementation-agent** - Has rule BUT contradictory line 66

### 2.2 Agents WITHOUT 5-Test Rule ❌
- quality-agent
- devops-agent
- research-agent
- task-orchestrator
- tdd-validation-agent

### 2.3 Research Documentation Issues
The `vitest-setup.md` research file:
- Shows examples with 3-4 tests (good)
- Doesn't emphasize 5-test maximum
- Includes integration examples encouraging many tests

---

## 3. Implementation Plan

### 3.1 Fix Agent Contradictions

#### **testing-implementation-agent.md Changes**
```diff
Line 66:
- 5. **Write Comprehensive Tests**: Create extensive test suites for all functionality
+ 5. **Write Focused Tests**: Create ONLY 5 focused tests per component - NO MORE
```

#### **Add Enforcement Statement to All Agents**
```markdown
**🚨 ENFORCEMENT PROTOCOL**
- Count tests before marking complete
- >5 tests = IMMEDIATE TASK FAILURE
- Report: "❌ VIOLATION: [file] has [count] tests (max 5)"
- Block handoff until compliant
```

### 3.2 Create Validation Hook

#### **File: `.claude/hooks/test-count-validator.sh`**
```bash
#!/bin/bash
# Test Count Validator - Enforces 5-test maximum rule

echo "🔍 Validating test count compliance..."

VIOLATIONS=0
for file in $(find src -name "*.test.ts" -o -name "*.test.tsx"); do
  count=$(grep -c "^\s*it\|^\s*test" "$file" 2>/dev/null || echo 0)
  
  if [ "$count" -gt 5 ]; then
    echo "❌ VIOLATION: $file has $count tests (max 5 allowed)"
    VIOLATIONS=$((VIOLATIONS + 1))
  else
    echo "✅ COMPLIANT: $file has $count tests"
  fi
done

if [ "$VIOLATIONS" -gt 0 ]; then
  echo "🚫 FAILED: $VIOLATIONS files violate 5-test maximum"
  exit 1
fi

echo "✅ PASSED: All test files comply with 5-test maximum"
exit 0
```

### 3.3 Update Research Documentation

#### **vitest-setup.md Header Addition**
```markdown
# 🚨 CRITICAL: Maximum 5 Tests Per Component Rule

**MANDATORY TESTING CONSTRAINT**: Each test file must contain EXACTLY 5 or fewer tests.

## Why 5 Tests?
- **Focus**: Forces selection of most critical functionality
- **Maintenance**: Reduces test suite complexity
- **Speed**: Faster test execution
- **Quality**: Better tests over more tests

## Example: Perfect 5-Test Suite
```typescript
describe('Component', () => {
  it('renders correctly')        // Core: Display
  it('handles user interaction') // Core: Primary function
  it('validates input')         // Core: Validation
  it('manages state')           // Core: State management
  it('handles errors')          // Core: Error handling
  // STOP HERE - 5 is the maximum
})
```
```

### 3.4 Concrete Examples for Agents

#### **Add to Each Agent's Documentation**
```typescript
// ✅ CORRECT: Exactly 5 focused tests
describe('TodoItem', () => {
  it('renders todo text')           // 1. Display
  it('toggles completion')          // 2. Main interaction
  it('handles delete')              // 3. Removal
  it('enters edit mode')            // 4. Editing
  it('validates empty input')       // 5. Validation
  // NO MORE TESTS - 5 is the maximum
})

// ❌ WRONG: Too many tests
describe('TodoItem', () => {
  it('renders todo text')
  it('toggles completion')
  it('handles delete')
  it('enters edit mode')
  it('validates empty input')
  it('handles special characters')  // ❌ 6th test - VIOLATION
  it('handles long text')           // ❌ 7th test - VIOLATION
  // FAILURE: >5 tests breaks the rule
})
```

### 3.5 Fix Existing Test Files

#### **Reduction Strategy**
```markdown
## useTodos.test.ts (15 → 5 tests)
KEEP:
1. initializes with empty array
2. adds new todo
3. toggles todo completion
4. deletes todo
5. filters todos

REMOVE: 10 edge cases and variations

## localStorage.test.ts (14 → 5 tests)
KEEP:
1. saves data to localStorage
2. loads data from localStorage
3. handles invalid JSON
4. handles quota exceeded error
5. clears storage

REMOVE: 9 edge cases and error variations

## DELETE ENTIRELY:
- useTodos.advanced.test.ts (17 tests)
- TodoItem.advanced.test.tsx (21 tests)
(These are redundant "advanced" files)
```

### 3.6 Terminology Updates

#### **Global Replacements in All Agents**
| Old Term | New Term |
|----------|----------|
| "Comprehensive testing" | "Focused testing" |
| "Complete coverage" | "Core validation" |
| "Extensive test suites" | "5-test validation" |
| "Edge cases" | "Essential paths only" |
| "80% coverage" | "Quality over quantity" |

### 3.7 TDD Validation Protocol Updates

#### **Add to tdd-validation-agent.md**
```markdown
## 🚨 MANDATORY FIRST CHECK: Test Count Validation

1. **Count Tests**: 
   ```bash
   for file in $(find src -name "*.test.ts*"); do
     count=$(grep -c "it(\|test(" "$file")
     echo "$file: $count tests"
   done
   ```

2. **Validation Rules**:
   - ≤5 tests per file: ✅ PASS
   - >5 tests per file: ❌ IMMEDIATE FAILURE
   
3. **Failure Protocol**:
   - Report specific violations
   - Block task completion
   - Require remediation before proceeding
```

---

## 4. Enforcement Mechanisms

### 4.1 Multi-Layer Enforcement
1. **Agent Instructions**: Clear 5-test rule in all agents
2. **Validation Hooks**: Automated test counting
3. **TDD Gates**: Validation before completion
4. **Examples**: Concrete right/wrong demonstrations
5. **Terminology**: No ambiguous words like "comprehensive"

### 4.2 Validation Points
- **Pre-handoff**: Count tests before agent completion
- **Post-implementation**: Validate in TDD gates
- **CI/CD Integration**: Hook in build pipeline
- **Manual Review**: Human verification checkpoint

### 4.3 Consequences for Violations
- **Immediate Failure**: Task cannot complete
- **Specific Reporting**: Which files violate and by how much
- **Blocked Handoff**: Cannot proceed to next agent
- **Required Fix**: Must reduce to 5 tests

---

## 5. Expected Outcomes

### 5.1 Quantitative Goals
- **Total Tests**: Reduce from 135+ to ~45
- **Tests per File**: Maximum 5 (currently up to 21)
- **Violation Rate**: 0% (currently 270% over limit)
- **Execution Time**: 60% faster test runs

### 5.2 Qualitative Benefits
- **Better Focus**: Only essential functionality tested
- **Easier Maintenance**: Simpler test suites
- **Clearer Intent**: Each test has clear purpose
- **Faster Development**: Less time writing tests
- **Higher Quality**: More thoughtful test selection

---

## 6. Implementation Timeline

### Phase 1: Immediate Actions (Day 1)
- [ ] Fix testing-implementation-agent contradiction
- [ ] Create test-count-validator.sh hook
- [ ] Update research documentation headers

### Phase 2: Agent Updates (Day 2)
- [ ] Add enforcement statements to all agents
- [ ] Add concrete examples to each agent
- [ ] Update terminology globally

### Phase 3: Test Reduction (Day 3)
- [ ] Reduce existing test files to 5 tests each
- [ ] Delete redundant "advanced" test files
- [ ] Validate all files comply

### Phase 4: Validation (Day 4)
- [ ] Run validation hook on entire codebase
- [ ] Test agent behavior with new rules
- [ ] Document results and compliance

---

## 7. Success Metrics

### 7.1 Compliance Metrics
```markdown
✅ SUCCESS CRITERIA:
- 100% of test files have ≤5 tests
- 0 "advanced" or duplicate test files
- All agents have consistent 5-test rule
- Validation hook passes on all files
```

### 7.2 Performance Metrics
```markdown
EXPECTED IMPROVEMENTS:
- Test execution: 60% faster
- Test maintenance: 70% less code
- Development speed: 40% faster
- Code clarity: Significantly improved
```

---

## 8. Conclusion

The 5-test maximum rule exists in documentation but lacks enforcement. By implementing technical validation, updating contradictory instructions, and providing clear examples, we can ensure agents follow the rule consistently. This will result in a focused, maintainable test suite that validates core functionality without excessive overhead.

The key insight: **Rules without enforcement are merely suggestions.** This plan makes the 5-test limit technically enforced at multiple levels, making violations impossible rather than just discouraged.

---

## Appendix A: Current Violations

```bash
# Files currently violating 5-test rule:
src/hooks/__tests__/useTodos.test.ts: 15 tests (10 over)
src/hooks/__tests__/useTodos.advanced.test.ts: 17 tests (17 over - delete file)
src/utils/__tests__/localStorage.test.ts: 14 tests (9 over)
src/components/features/__tests__/TodoItem.advanced.test.tsx: 21 tests (21 over - delete file)
src/test/integration/todo-workflow.test.tsx: 9 tests (4 over)
src/test/performance/basic-performance.test.tsx: 8 tests (3 over)
src/test/comprehensive-app.test.tsx: 9 tests (4 over)
src/hooks/__tests__/useFilteredTodos.test.ts: 6 tests (1 over)
```

---

## Appendix B: Agent File Locations

```bash
# Agent configurations to update:
.claude/agents/component-implementation-agent.md
.claude/agents/feature-implementation-agent.md
.claude/agents/testing-implementation-agent.md  # LINE 66 CRITICAL FIX
.claude/agents/polish-implementation-agent.md
.claude/agents/infrastructure-implementation-agent.md
.claude/agents/quality-agent.md  # ADD 5-test rule
.claude/agents/tdd-validation-agent.md  # ADD validation check
```

---

*Document Version: 1.0*  
*Date: 2024*  
*Status: Implementation Ready*