#!/bin/bash
# Smoke test: TDD-gate completion logic
# Validates that TDD-gate allows writes after epic completion

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "🧪 TDD-Gate Completion Logic Smoke Test"
echo ""

# Test helper
test_hook() {
    local description="$1"
    local expected_result="$2"  # "allow" or "deny"
    local test_file="$3"

    echo -n "  Testing: $description ... "

    # Call TDD-gate hook
    local hook_output
    hook_output=$(echo "{\"tool_name\": \"Write\", \"tool_input\": {\"file_path\": \"$test_file\"}}" | ./.claude/hooks/tdd-gate.sh 2>&1)

    local actual_result
    if echo "$hook_output" | jq -e '.hookSpecificOutput.permissionDecision == "allow"' >/dev/null 2>&1; then
        actual_result="allow"
    else
        actual_result="deny"
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
    rm -f .claude/memory/markers/.project-complete
}

trap cleanup EXIT

# Run tests
setup

echo "TEST 1: Blocks implementation without tests (epic in-progress)"

# Create epic with in-progress status
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
      "status": "in-progress",
      "children": [],
      "dependencies": ["1.1.1"],
      "parent": "1.1"
    }
  ]
}
EOF

test_hook "Block implementation (epic in-progress)" "deny" "src/NewFeature.js"

echo ""
echo "TEST 2: Allows writes after epic completion (all tasks done)"

# Update epic to done status
cat > .claude/memory/task-index.json << 'EOF'
{
  "version": "1.0.0",
  "tasks": [
    {
      "id": "1",
      "type": "epic",
      "status": "done",
      "children": ["1.1"],
      "parent": null,
      "progress": {
        "completed": 1,
        "total": 1
      }
    },
    {
      "id": "1.1",
      "type": "feature",
      "status": "done",
      "children": ["1.1.1", "1.1.2"],
      "parent": "1",
      "progress": {
        "completed": 2,
        "total": 2
      }
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
      "status": "done",
      "children": [],
      "dependencies": ["1.1.1"],
      "parent": "1.1"
    }
  ]
}
EOF

# This test EXPECTS to FAIL initially (current TDD-gate blocks even after epic done)
test_hook "Allow writes after epic done" "allow" "integration/final-touches.js" || true

echo ""
echo "TEST 3: Allows writes with .project-complete marker"

# Create .project-complete marker
touch .claude/memory/markers/.project-complete

test_hook "Allow writes with completion marker" "allow" "docs/README.md" || true

echo ""
echo "TEST 4: Still blocks without tests if epic not complete"

# Reset to in-progress epic
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

# Remove marker
rm -f .claude/memory/markers/.project-complete

test_hook "Block when epic not complete" "deny" "src/Implementation.js"

echo ""
echo "════════════════════════════════"
echo "Test Results:"
echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Some tests failed - this exposes TDD-gate completion logic issues${NC}"
    exit 1
else
    echo -e "❌ Failed: $TESTS_FAILED"
    echo ""
    echo -e "${GREEN}✅ All TDD-gate completion tests passed${NC}"
    exit 0
fi
