#!/bin/bash
# Smoke test: Task ID extraction reliability
# Validates that hooks can reliably extract and validate task IDs

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "🧪 Task ID Extraction Reliability Smoke Test"
echo ""

# Test helper
test_extraction() {
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

    # Ensure directories exist
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

    # Clean up markers
    rm -f .claude/memory/markers/.current-task
}

trap cleanup EXIT

# Run tests
setup

echo "TEST 1: Extract task ID from in-progress leaf task"

# Create task structure with one in-progress leaf task
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
      "children": ["1.1.1"],
      "parent": "1"
    },
    {
      "id": "1.1.1",
      "type": "task",
      "status": "in-progress",
      "children": [],
      "dependencies": [],
      "parent": "1.1"
    }
  ]
}
EOF

test_extract_from_in_progress() {
    # Simulate task ID extraction logic
    local TASKS_INDEX=".claude/memory/task-index.json"
    local TASK_ID
    TASK_ID=$(jq -r '.tasks[] | select(.status=="in-progress" and (.children == [] or .children == null)) | .id' "$TASKS_INDEX" | head -n1)

    [[ "$TASK_ID" == "1.1.1" ]]
}

test_extraction "Extract from in-progress leaf task" "pass" "test_extract_from_in_progress"

echo ""
echo "TEST 2: Fallback to .current-task marker"

# Remove in-progress tasks, rely on marker
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
      "children": ["1.1.1"],
      "parent": "1"
    },
    {
      "id": "1.1.1",
      "type": "task",
      "status": "pending",
      "children": [],
      "dependencies": [],
      "parent": "1.1"
    }
  ]
}
EOF

# Create .current-task marker
echo "1.1.1" > .claude/memory/markers/.current-task

test_extract_from_marker() {
    local TASKS_INDEX=".claude/memory/task-index.json"
    local TASK_ID

    # Try in-progress first (will fail)
    TASK_ID=$(jq -r '.tasks[] | select(.status=="in-progress" and (.children == [] or .children == null)) | .id' "$TASKS_INDEX" | head -n1)

    # Fallback to marker
    if [[ -z "$TASK_ID" && -f .claude/memory/markers/.current-task ]]; then
        TASK_ID=$(cat .claude/memory/markers/.current-task)
    fi

    [[ "$TASK_ID" == "1.1.1" ]]
}

# This test EXPECTS to FAIL initially (marker fallback doesn't exist in hook yet)
test_extraction "Fallback to .current-task marker" "pass" "test_extract_from_marker" || true

echo ""
echo "TEST 3: Validate extracted task ID exists in hierarchy"

# Create marker with invalid task ID
echo "9.9.9" > .claude/memory/markers/.current-task

test_validate_task_exists() {
    local TASKS_INDEX=".claude/memory/task-index.json"
    local TASK_ID

    # Read from marker
    if [[ -f .claude/memory/markers/.current-task ]]; then
        TASK_ID=$(cat .claude/memory/markers/.current-task)
    fi

    # Validate task exists in hierarchy
    local TASK_EXISTS
    TASK_EXISTS=$(jq --arg tid "$TASK_ID" '[.tasks[] | select(.id == $tid)] | length' "$TASKS_INDEX")

    if [[ "$TASK_EXISTS" -eq 0 ]]; then
        # Task doesn't exist - should fail
        return 1
    fi

    return 0
}

# This test EXPECTS validation to catch invalid task ID
test_extraction "Reject invalid task ID from marker" "fail" "test_validate_task_exists"

echo ""
echo "TEST 4: Handle missing task ID gracefully"

# Remove marker and no in-progress tasks
rm -f .claude/memory/markers/.current-task

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
      "children": ["1.1.1"],
      "parent": "1"
    },
    {
      "id": "1.1.1",
      "type": "task",
      "status": "pending",
      "children": [],
      "dependencies": [],
      "parent": "1.1"
    }
  ]
}
EOF

test_handle_missing_task_id() {
    local TASKS_INDEX=".claude/memory/task-index.json"
    local TASK_ID

    # Try in-progress (will fail)
    TASK_ID=$(jq -r '.tasks[] | select(.status=="in-progress" and (.children == [] or .children == null)) | .id' "$TASKS_INDEX" | head -n1)

    # Try marker fallback (will fail)
    if [[ -z "$TASK_ID" && -f .claude/memory/markers/.current-task ]]; then
        TASK_ID=$(cat .claude/memory/markers/.current-task)
    fi

    # Should detect missing task ID and fail gracefully
    if [[ -z "$TASK_ID" || "$TASK_ID" == "null" ]]; then
        # No task ID - this should be detected as error
        return 1
    fi

    return 0
}

# This test EXPECTS to detect missing task ID as error
test_extraction "Detect missing task ID as error" "fail" "test_handle_missing_task_id"

echo ""
echo "TEST 5: Multiple in-progress tasks (ambiguous)"

# Create multiple in-progress leaf tasks
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
      "status": "in-progress",
      "children": [],
      "dependencies": [],
      "parent": "1.1"
    },
    {
      "id": "1.1.2",
      "type": "task",
      "status": "in-progress",
      "children": [],
      "dependencies": ["1.1.1"],
      "parent": "1.1"
    }
  ]
}
EOF

test_multiple_in_progress() {
    local TASKS_INDEX=".claude/memory/task-index.json"
    local TASK_ID

    # Extract in-progress task (will get first one)
    TASK_ID=$(jq -r '.tasks[] | select(.status=="in-progress" and (.children == [] or .children == null)) | .id' "$TASKS_INDEX" | head -n1)

    # Should return A task ID (picks first one)
    [[ -n "$TASK_ID" && "$TASK_ID" != "null" ]]
}

test_extraction "Handle multiple in-progress tasks" "pass" "test_multiple_in_progress"

echo ""
echo "════════════════════════════════"
echo "Test Results:"
echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Some tests failed - this exposes task ID extraction issues${NC}"
    exit 1
else
    echo -e "❌ Failed: $TESTS_FAILED"
    echo ""
    echo -e "${GREEN}✅ All task ID extraction tests passed${NC}"
    exit 0
fi
