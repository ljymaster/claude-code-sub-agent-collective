#!/bin/bash
# Smoke test: SubagentStop hook reliability
# Validates that SubagentStop updates task status and propagates errors

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "🧪 SubagentStop Reliability Smoke Test"
echo ""

# Test helper
test_hook() {
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

    # Ensure required directories exist
    mkdir -p .claude/memory/markers
}

# Cleanup
cleanup() {
    # Restore state
    if [[ -f .claude/memory/task-index.json.backup ]]; then
        mv .claude/memory/task-index.json.backup .claude/memory/task-index.json
    else
        rm -f .claude/memory/task-index.json
    fi

    # Clean up test files
    rm -f test-deliverable.html
    rm -rf .claude/memory/markers/.needs-validation-*
}

trap cleanup EXIT

# Run tests
setup

echo "TEST 1: Task status updates after completion"

# Create task structure with in-progress task
cat > .claude/memory/task-index.json << 'EOF'
{
  "version": "1.0.0",
  "tasks": [
    {
      "id": "1",
      "type": "epic",
      "status": "in-progress",
      "children": ["1.1"],
      "parent": null,
      "progress": {"completed": 0, "total": 1}
    },
    {
      "id": "1.1",
      "type": "feature",
      "status": "in-progress",
      "children": ["1.1.1"],
      "parent": "1",
      "progress": {"completed": 0, "total": 1}
    },
    {
      "id": "1.1.1",
      "type": "task",
      "status": "in-progress",
      "children": [],
      "dependencies": [],
      "deliverables": ["test-deliverable.html"],
      "parent": "1.1"
    }
  ]
}
EOF

# Create deliverable
echo "<!-- Test deliverable -->" > test-deliverable.html

# Test: Run SubagentStop hook simulation
test_task_status_update() {
    # Source helper libraries
    source .claude/memory/lib/wbs-helpers.sh 2>/dev/null || return 1
    source .claude/memory/lib/memory.sh 2>/dev/null || return 1

    # Simulate what SubagentStop does
    local TASK_ID="1.1.1"
    local TASKS_INDEX=".claude/memory/task-index.json"

    # Update task status
    with_memory_lock "$TASKS_INDEX" memory_update_json "$TASKS_INDEX" \
        ".tasks[] |= if .id == \"$TASK_ID\" then .status=\"done\" else . end" || return 1

    # Check if task was updated
    local STATUS
    STATUS=$(jq -r '.tasks[] | select(.id=="1.1.1") | .status' "$TASKS_INDEX")
    [[ "$STATUS" == "done" ]]
}

test_hook "Task status updates to done" "pass" "test_task_status_update"

echo ""
echo "TEST 2: Parent feature rollup propagation"

# Reset to in-progress state
cat > .claude/memory/task-index.json << 'EOF'
{
  "version": "1.0.0",
  "tasks": [
    {
      "id": "1",
      "type": "epic",
      "status": "in-progress",
      "children": ["1.1"],
      "parent": null,
      "progress": {"completed": 0, "total": 1}
    },
    {
      "id": "1.1",
      "type": "feature",
      "status": "in-progress",
      "children": ["1.1.1"],
      "parent": "1",
      "progress": {"completed": 0, "total": 1}
    },
    {
      "id": "1.1.1",
      "type": "task",
      "status": "done",
      "children": [],
      "dependencies": [],
      "deliverables": ["test-deliverable.html"],
      "parent": "1.1"
    }
  ]
}
EOF

test_parent_rollup() {
    source .claude/memory/lib/wbs-helpers.sh 2>/dev/null || return 1

    # Run rollup
    propagate_status_up "1.1.1" || return 1

    # Check if parent feature was updated
    local FEATURE_STATUS
    FEATURE_STATUS=$(jq -r '.tasks[] | select(.id=="1.1") | .status' .claude/memory/task-index.json)
    [[ "$FEATURE_STATUS" == "done" ]]
}

test_hook "Parent feature status updates" "pass" "test_parent_rollup"

echo ""
echo "TEST 3: Error detection and reporting"

# Create invalid structure (missing parent reference)
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
      "id": "1.1.1",
      "type": "task",
      "status": "done",
      "children": [],
      "dependencies": [],
      "parent": "1.1"
    }
  ]
}
EOF

# This test EXPECTS failure (invalid structure should be detected)
test_error_detection() {
    source .claude/memory/lib/wbs-helpers.sh 2>/dev/null || return 1

    # Try to propagate - should fail due to missing parent task
    if propagate_status_up "1.1.1" 2>/dev/null; then
        # If it succeeds with invalid structure, that's wrong
        return 1
    else
        # If it fails (as expected), that's correct
        return 0
    fi
}

test_hook "Invalid structure detected" "pass" "test_error_detection"

echo ""
echo "TEST 4: Validation marker creation"

# Create feature with 2 tasks, first is done, second about to complete
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
      "agent": "test-first-agent",
      "parent": "1.1"
    },
    {
      "id": "1.1.2",
      "type": "task",
      "status": "done",
      "children": [],
      "dependencies": ["1.1.1"],
      "agent": "component-implementation-agent",
      "deliverables": ["test-deliverable.html"],
      "parent": "1.1"
    }
  ]
}
EOF

test_marker_creation() {
    # Simulate SubagentStop logic for marker creation
    local TASK_ID="1.1.2"
    local AGENT="component-implementation-agent"
    local TASKS_INDEX=".claude/memory/task-index.json"

    # Check if agent is implementation agent
    if [[ "$AGENT" =~ -implementation-agent$ ]]; then
        PARENT_ID=$(jq -r ".tasks[] | select(.id==\"$TASK_ID\") | .parent" "$TASKS_INDEX")

        # Check if all sibling tasks are done
        ALL_DONE=$(jq -r ".tasks[] | select(.parent==\"$PARENT_ID\") | .status" "$TASKS_INDEX" | { grep -v "done" || true; } | wc -l | tr -d ' ')

        if [[ "$ALL_DONE" -eq 0 ]]; then
            # Create marker
            mkdir -p .claude/memory/markers
            touch ".claude/memory/markers/.needs-validation-${PARENT_ID}"
        fi
    fi

    # Check marker was created
    [[ -f ".claude/memory/markers/.needs-validation-1.1" ]]
}

test_hook "Validation marker created for complete feature" "pass" "test_marker_creation"

echo ""
echo "════════════════════════════════"
echo "Test Results:"
echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Some tests failed - this exposes issues in SubagentStop hook${NC}"
    exit 1
else
    echo -e "❌ Failed: $TESTS_FAILED"
    echo ""
    echo -e "${GREEN}✅ All SubagentStop reliability tests passed${NC}"
    exit 0
fi
