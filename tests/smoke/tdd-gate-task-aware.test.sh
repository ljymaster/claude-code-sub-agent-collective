#!/bin/bash
# Smoke test for task-aware TDD-gate hook
# Validates hook reads task-index.json and prevents agent gaming

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="/tmp/tdd-gate-smoke-test-$$"
HOOK_SCRIPT="$SCRIPT_DIR/../../templates/hooks/tdd-gate.sh"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

echo "🧪 TDD-Gate Task-Aware Smoke Test"
echo "=================================="
echo ""

# Setup test environment
setup_test_env() {
    echo "📁 Setting up test environment: $TEST_DIR"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"

    # Create memory structure
    mkdir -p .claude/memory/lib .claude/memory/logs/current .claude/hooks

    # Create minimal logging.sh stub
    cat > .claude/memory/lib/logging.sh << 'EOF'
#!/bin/bash
log_hook_event() { :; }
EOF

    # Copy TDD-gate hook
    cp "$HOOK_SCRIPT" .claude/hooks/tdd-gate.sh
    chmod +x .claude/hooks/tdd-gate.sh

    echo "✅ Environment ready"
    echo ""
}

# Cleanup
cleanup() {
    cd /
    rm -rf "$TEST_DIR"
}

trap cleanup EXIT

# Test helper: Run hook and check result
test_hook() {
    local test_name="$1"
    local tool_name="$2"
    local file_path="$3"
    local expected_decision="$4"
    local description="$5"

    echo -n "Testing: $description ... "

    # Create hook input JSON
    local input="{\"tool_name\":\"$tool_name\",\"tool_input\":{\"file_path\":\"$file_path\"}}"

    # Run hook
    local output
    output=$(echo "$input" | ./.claude/hooks/tdd-gate.sh 2>/dev/null || true)

    # Extract decision
    local decision
    decision=$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision // empty')

    if [[ "$decision" == "$expected_decision" ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        echo "  Expected: $expected_decision"
        echo "  Got: $decision"
        echo "  Output: $output"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 1: Allow test file creation (no task-index needed)
test_allow_test_files() {
    echo "TEST 1: Allow test file creation"
    echo "--------------------------------"

    test_hook "test1a" "Write" "tests/counter.test.html" "allow" "Test file in tests/ directory"
    test_hook "test1b" "Write" "index.test.js" "allow" "Test file with .test. extension"
    test_hook "test1c" "Write" "__tests__/index.js" "allow" "Test file in __tests__/"

    echo ""
}

# Test 2: Task-aware validation - dependency test exists
test_task_aware_allow() {
    echo "TEST 2: Task-aware validation - dependency test exists"
    echo "-------------------------------------------------------"

    # Create task-index.json
    cat > .claude/memory/task-index.json << 'EOF'
{
  "tasks": [
    {
      "id": "1.1.1",
      "type": "task",
      "title": "Write HTML structure tests",
      "status": "done",
      "dependencies": [],
      "deliverables": ["tests/counter.test.html"],
      "agent": "test-first-agent"
    },
    {
      "id": "1.1.2",
      "type": "task",
      "title": "Implement HTML structure",
      "status": "in-progress",
      "dependencies": ["1.1.1"],
      "deliverables": ["index.html"],
      "agent": "component-implementation-agent"
    }
  ]
}
EOF

    # Create the dependency test file
    mkdir -p tests
    echo "<!-- Test file -->" > tests/counter.test.html

    test_hook "test2" "Write" "index.html" "allow" "Implementation with existing dependency test"

    # Cleanup
    rm -f tests/counter.test.html
    rmdir tests 2>/dev/null || true
    rm -f .claude/memory/task-index.json

    echo ""
}

# Test 3: Task-aware validation - dependency test MISSING (task structure error)
test_task_aware_deny() {
    echo "TEST 3: Task-aware validation - dependency test MISSING"
    echo "--------------------------------------------------------"

    # Create task-index.json (same as Test 2)
    cat > .claude/memory/task-index.json << 'EOF'
{
  "tasks": [
    {
      "id": "1.1.1",
      "type": "task",
      "title": "Write HTML structure tests",
      "status": "done",
      "dependencies": [],
      "deliverables": ["tests/counter.test.html"],
      "agent": "test-first-agent"
    },
    {
      "id": "1.1.2",
      "type": "task",
      "title": "Implement HTML structure",
      "status": "in-progress",
      "dependencies": ["1.1.1"],
      "deliverables": ["index.html"],
      "agent": "component-implementation-agent"
    }
  ]
}
EOF

    # DO NOT create the test file - simulate task structure error
    # tests/counter.test.html is missing even though task 1.1.1 says it created it

    test_hook "test3" "Write" "index.html" "deny" "Implementation with MISSING dependency test (task structure error)"

    # Cleanup
    rm -f .claude/memory/task-index.json

    echo ""
}

# Test 4: Task with no dependencies (test task itself)
test_task_no_dependencies() {
    echo "TEST 4: Task with no dependencies (test task)"
    echo "----------------------------------------------"

    # Create task-index.json for test task
    cat > .claude/memory/task-index.json << 'EOF'
{
  "tasks": [
    {
      "id": "1.1.1",
      "type": "task",
      "title": "Write HTML structure tests",
      "status": "in-progress",
      "dependencies": [],
      "deliverables": ["tests/counter.test.html"],
      "agent": "test-first-agent"
    }
  ]
}
EOF

    # Test task can write its deliverable (no dependencies to check)
    test_hook "test4" "Write" "tests/counter.test.html" "allow" "Test task with no dependencies"

    # Cleanup
    rm -f .claude/memory/task-index.json

    echo ""
}

# Test 5: Fallback to pattern matching (no task-index.json)
test_fallback_pattern_matching() {
    echo "TEST 5: Fallback to pattern matching (no task-index)"
    echo "-----------------------------------------------------"

    # Ensure no task-index.json
    rm -f .claude/memory/task-index.json

    # Create test file using pattern matching
    echo "// Test" > index.test.js

    test_hook "test5a" "Write" "index.js" "allow" "Pattern matching - test file exists"

    # Remove test file
    rm -f index.test.js

    test_hook "test5b" "Write" "index.js" "deny" "Pattern matching - no test file exists"

    echo ""
}

# Test 6: Allow config/docs/infrastructure files
test_allow_special_files() {
    echo "TEST 6: Allow config/docs/infrastructure files"
    echo "-----------------------------------------------"

    test_hook "test6a" "Write" "package.json" "allow" "Config file (package.json)"
    test_hook "test6b" "Write" "README.md" "allow" "Documentation file"
    test_hook "test6c" "Write" ".claude/memory/task-index.json" "allow" "Infrastructure file"
    test_hook "test6d" "Write" "vitest.config.js" "allow" "Config file (vitest)"

    echo ""
}

# Run all tests
run_all_tests() {
    setup_test_env

    test_allow_test_files
    test_task_aware_allow
    test_task_aware_deny
    test_task_no_dependencies
    test_fallback_pattern_matching
    test_allow_special_files

    # Summary
    echo "=================================="
    echo "📊 Test Results"
    echo "=================================="
    echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"
        echo ""
        echo -e "${RED}❌ SMOKE TEST FAILED${NC}"
        exit 1
    else
        echo -e "${YELLOW}❌ Failed: $TESTS_FAILED${NC}"
        echo ""
        echo -e "${GREEN}✅ ALL SMOKE TESTS PASSED${NC}"
        exit 0
    fi
}

# Run tests
run_all_tests
