#!/bin/bash
# Smoke test: TDD-gate hook task-aware logic
# Validates hook reads task-index.json to find dependency test files

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "🧪 TDD-Gate Task-Aware Smoke Test"
echo ""

# Test helper
test_hook() {
    local description="$1"
    local tool_name="$2"
    local file_path="$3"
    local expected_decision="$4"

    echo -n "  Testing: $description ... "

    local input="{\"tool_name\":\"$tool_name\",\"tool_input\":{\"file_path\":\"$file_path\"}}"
    local output
    output=$(echo "$input" | ./.claude/hooks/tdd-gate.sh 2>/dev/null || echo '{}')

    local decision
    decision=$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision // "error"')

    if [[ "$decision" == "$expected_decision" ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAIL (expected: $expected_decision, got: $decision)${NC}"
        ((TESTS_FAILED++))
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
    fi
    # Remove test files
    rm -f smoke-test-impl.html smoke-test-impl.test.html tests/smoke-test.test.html
}

trap cleanup EXIT

# Run tests
setup

echo "TEST 1: Allow test file creation"
test_hook "Test file in tests/" "Write" "tests/smoke-test.test.html" "allow"
test_hook "Test file with .test." "Write" "smoke-test-impl.test.html" "allow"

echo ""
echo "TEST 2: Task-aware with dependency test exists"

# Create task structure
cat > .claude/memory/task-index.json << 'EOF'
{
  "tasks": [
    {
      "id": "smoke-test-1",
      "dependencies": [],
      "deliverables": ["tests/smoke-test.test.html"]
    },
    {
      "id": "smoke-test-2",
      "dependencies": ["smoke-test-1"],
      "deliverables": ["smoke-test-impl.html"]
    }
  ]
}
EOF

# Create dependency test file
mkdir -p tests
echo "<!-- Test -->" > tests/smoke-test.test.html

test_hook "Implementation with existing dependency test" "Write" "smoke-test-impl.html" "allow"

# Cleanup test file
rm -f tests/smoke-test.test.html
rmdir tests 2>/dev/null || true

echo ""
echo "TEST 3: Task-aware with MISSING dependency test"

# Same task structure, but test file doesn't exist
test_hook "Implementation with MISSING dependency test" "Write" "smoke-test-impl.html" "deny"

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
