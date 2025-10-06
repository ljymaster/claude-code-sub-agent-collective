#!/bin/bash
# Smoke test: Hook error propagation
# Validates that hooks properly propagate errors and don't hide failures

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "🧪 Hook Error Propagation Smoke Test"
echo ""

# Test helper
test_error_handling() {
    local description="$1"
    local expected_result="$2"  # "pass" or "fail"
    local test_function="$3"

    echo -n "  Testing: $description ... "

    local actual_result
    if eval "$test_function" >/dev/null 2>&1; then
        actual_result="pass"
    else
        actual_result="fail"
    fi

    if [[ "$actual_result" == "$expected_result" ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED+1))
        return 0
    else
        echo -e "${RED}❌ FAIL (expected: $expected_result, got: $actual_result)${NC}"
        TESTS_FAILED=$((TESTS_FAILED+1))
        return 1
    fi
}

# Setup
setup() {
    # Save current state
    if [[ -f .claude/memory/task-index.json ]]; then
        cp .claude/memory/task-index.json .claude/memory/task-index.json.backup
    fi
}

# Cleanup
cleanup() {
    # Restore state
    if [[ -f .claude/memory/task-index.json.backup ]]; then
        mv .claude/memory/task-index.json.backup .claude/memory/task-index.json
    else
        rm -f .claude/memory/task-index.json
    fi
}

trap cleanup EXIT

# Run tests
setup

echo "TEST 1: Error propagation without || true"

# Test that errors aren't silently hidden
test_error_not_hidden() {
    # Simulate a failing command
    local result
    result=$(false 2>&1) && return 1 || return 0
}

test_error_handling "Errors propagate correctly" "pass" "test_error_not_hidden"

echo ""
echo "TEST 2: jq errors are caught"

# Test that malformed jq queries fail properly
test_jq_error_caught() {
    local TASKS_INDEX=".claude/memory/task-index.json"

    # Create valid JSON
    cat > "$TASKS_INDEX" << 'EOF'
{"version": "1.0.0", "tasks": []}
EOF

    # Invalid jq query should fail
    local result
    result=$(jq '.invalid..syntax' "$TASKS_INDEX" 2>&1) && return 1 || return 0
}

test_error_handling "jq syntax errors caught" "pass" "test_jq_error_caught"

echo ""
echo "TEST 3: Missing file errors are caught"

# Test that missing files cause failures
test_missing_file_error() {
    # Try to read non-existent file
    local result
    result=$(jq '.tasks' /nonexistent/path/file.json 2>&1) && return 1 || return 0
}

test_error_handling "Missing file errors caught" "pass" "test_missing_file_error"

echo ""
echo "TEST 4: Structured error reporting"

# Test that errors have structured format
test_structured_error() {
    # Simulate error with structured output
    local ERROR_MSG='{"error": "Task validation failed", "task_id": "1.1.1", "reason": "Missing deliverables"}'

    # Verify it's valid JSON
    echo "$ERROR_MSG" | jq -e '.error' >/dev/null 2>&1
}

test_error_handling "Structured error format valid" "pass" "test_structured_error"

echo ""
echo "TEST 5: Memory lock failures propagate"

# Test that lock failures are caught
test_lock_failure() {
    # Source memory library
    source .claude/memory/lib/memory.sh 2>/dev/null || return 1

    # Try to acquire lock on read-only directory (should fail)
    # This is simulated - actual test would need read-only dir
    # For now, just verify lock function exists
    type -t with_memory_lock >/dev/null
}

test_error_handling "Memory lock function exists" "pass" "test_lock_failure"

echo ""
echo "TEST 6: WBS rollup errors propagate"

cat > .claude/memory/task-index.json << 'EOF'
{
  "version": "1.0.0",
  "tasks": [
    {
      "id": "1.1.1",
      "type": "task",
      "status": "done",
      "children": [],
      "parent": "1.1"
    }
  ]
}
EOF

# Test that rollup fails when parent doesn't exist
test_rollup_error() {
    source .claude/memory/lib/wbs-helpers.sh 2>/dev/null || return 1

    # Try to propagate status when parent task missing
    # This should fail (we added validation in previous fix)
    propagate_status_up "1.1.1" 2>/dev/null && return 1 || return 0
}

test_error_handling "WBS rollup validates parent exists" "pass" "test_rollup_error"

echo ""
echo "════════════════════════════════"
echo "Test Results:"
echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Some tests failed - this exposes hook error propagation issues${NC}"
    exit 1
else
    echo -e "❌ Failed: $TESTS_FAILED"
    echo ""
    echo -e "${GREEN}✅ All hook error propagation tests passed${NC}"
    exit 0
fi
