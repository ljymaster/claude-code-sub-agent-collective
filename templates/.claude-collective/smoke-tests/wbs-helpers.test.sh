#!/bin/bash
# Smoke test: WBS helper functions validation
# Validates wbs-helpers.sh functions work correctly

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "🧪 WBS Helpers Smoke Test"
echo ""

# Test helper
test_function() {
    local description="$1"
    local expected_output="$2"
    local command="$3"

    echo -n "  Testing: $description ... "

    local actual_output
    actual_output=$(eval "$command" 2>&1) || actual_output="ERROR"

    if [[ "$actual_output" == "$expected_output" ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED+1))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        echo "     Expected: $expected_output"
        echo "     Got: $actual_output"
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

echo "TEST 1: Function existence check"

# Source the helpers
source .claude/memory/lib/wbs-helpers.sh 2>/dev/null || {
    echo -e "${RED}❌ FAIL - Cannot source wbs-helpers.sh${NC}"
    exit 1
}

# Check if functions exist
test_function "find_next_available_task exists" "function" "type -t find_next_available_task"
test_function "get_parent exists" "function" "type -t get_parent"
test_function "get_children exists" "function" "type -t get_children"
test_function "get_leaf_tasks exists" "function" "type -t get_leaf_tasks"
test_function "calculate_rollup exists" "function" "type -t calculate_rollup"
test_function "propagate_status_up exists" "function" "type -t propagate_status_up"

echo ""
echo "TEST 2: find_next_available_task with no dependencies"

# Create task structure with task that has no dependencies
cat > .claude/memory/task-index.json << 'EOF'
{
  "version": "1.0.0",
  "tasks": [
    {
      "id": "1",
      "type": "epic",
      "status": "pending",
      "children": ["1.1"],
      "parent": null
    },
    {
      "id": "1.1",
      "type": "feature",
      "status": "pending",
      "children": ["1.1.1", "1.1.2"],
      "parent": "1"
    },
    {
      "id": "1.1.1",
      "type": "task",
      "status": "pending",
      "children": [],
      "dependencies": [],
      "parent": "1.1"
    },
    {
      "id": "1.1.2",
      "type": "task",
      "status": "pending",
      "children": [],
      "dependencies": ["1.1.1"],
      "parent": "1.1"
    }
  ]
}
EOF

test_function "Returns task with no dependencies" "1.1.1" "find_next_available_task"

echo ""
echo "TEST 3: find_next_available_task skips incomplete dependencies"

# Update task structure - mark 1.1.1 as done, 1.1.2 should be available
cat > .claude/memory/task-index.json << 'EOF'
{
  "version": "1.0.0",
  "tasks": [
    {
      "id": "1",
      "type": "epic",
      "status": "in-progress",
      "children": ["1.1"],
      "parent": null
    },
    {
      "id": "1.1",
      "type": "feature",
      "status": "in-progress",
      "children": ["1.1.1", "1.1.2"],
      "parent": "1"
    },
    {
      "id": "1.1.1",
      "type": "task",
      "status": "done",
      "children": [],
      "dependencies": [],
      "parent": "1.1"
    },
    {
      "id": "1.1.2",
      "type": "task",
      "status": "pending",
      "children": [],
      "dependencies": ["1.1.1"],
      "parent": "1.1"
    }
  ]
}
EOF

test_function "Returns task with satisfied dependencies" "1.1.2" "find_next_available_task"

echo ""
echo "TEST 4: get_parent function"
test_function "Get parent of 1.1.1" "1.1" "get_parent 1.1.1"
test_function "Get parent of 1.1" "1" "get_parent 1.1"
test_function "Get parent of 1" "" "get_parent 1"

echo ""
echo "════════════════════════════════"
echo "Test Results:"
echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"
    exit 1
else
    echo -e "❌ Failed: $TESTS_FAILED"
    exit 0
fi
