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

## Delivery Format
```markdown
## DELIVERY COMPLETE
✅ Tests written first (RED phase)
✅ Implementation passes tests (GREEN phase)
✅ Code refactored for quality (REFACTOR phase)
📊 Test Results: X/X passing
```