#!/bin/bash
# Smoke test: Van command instructions validation
# Validates van.md instructions reference actual functions that exist

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "🧪 Van Instructions Smoke Test"
echo ""

# Test helper
test_instruction() {
    local description="$1"
    local bash_command="$2"
    local expected_result="$3"  # "success" or "function_exists"

    echo -n "  Testing: $description ... "

    if [[ "$expected_result" == "success" ]]; then
        # Test bash command executes successfully
        if eval "$bash_command" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ PASS${NC}"
            TESTS_PASSED=$((TESTS_PASSED+1))
            return 0
        else
            echo -e "${RED}❌ FAIL (command failed)${NC}"
            TESTS_FAILED=$((TESTS_FAILED+1))
            return 1
        fi
    elif [[ "$expected_result" == "function_exists" ]]; then
        # Test function exists
        if eval "$bash_command" 2>&1 | grep -q "function"; then
            echo -e "${GREEN}✅ PASS${NC}"
            TESTS_PASSED=$((TESTS_PASSED+1))
            return 0
        else
            echo -e "${RED}❌ FAIL (function not found)${NC}"
            TESTS_FAILED=$((TESTS_FAILED+1))
            return 1
        fi
    fi
}

# Setup
setup() {
    # Create minimal task-index.json for testing
    mkdir -p .claude/memory
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
}

# Cleanup
cleanup() {
    rm -f .claude/memory/task-index.json
}

trap cleanup EXIT

# Run tests
setup

echo "TEST 1: Van.md STEP 2 instructions are executable"

# Van.md says: source .claude/memory/lib/wbs-helpers.sh && find_next_available_task
test_instruction "Source wbs-helpers.sh" "source .claude/memory/lib/wbs-helpers.sh" "success"
test_instruction "find_next_available_task exists" "source .claude/memory/lib/wbs-helpers.sh && type -t find_next_available_task" "function_exists"

echo ""
echo "TEST 2: Function returns expected output"
test_instruction "find_next_available_task returns task ID" "source .claude/memory/lib/wbs-helpers.sh && [[ \$(find_next_available_task) == '1.1.1' ]]" "success"

echo ""
echo "TEST 3: Referenced documentation files exist"
test_instruction ".claude-collective/task-system.md exists" "test -f .claude-collective/task-system.md" "success"
test_instruction ".claude/memory/lib/wbs-helpers.sh exists" "test -f .claude/memory/lib/wbs-helpers.sh" "success"

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
