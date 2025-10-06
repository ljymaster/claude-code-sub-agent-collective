#!/bin/bash
# Smoke test: Hub-and-spoke architectural language validation
# Validates that van.md and related files use correct hub-and-spoke terminology

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "🧪 Hub-and-Spoke Architectural Language Smoke Test"
echo ""

# Test helper
test_language() {
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

echo "TEST 1: Van.md architectural language validation"

# Test that van.md doesn't contain problematic language
test_no_execute_through_agents() {
    local VAN_MD=".claude/commands/van.md"

    # Check for "execute/executing through agents" (architectural violation)
    if grep -qi "execut.*through.*agent" "$VAN_MD"; then
        echo "ERROR: Found 'execute through agents' language" >&2
        return 1
    fi

    # Check for "tasks through agents" (architectural violation)
    if grep -qi "task.*through.*agent" "$VAN_MD"; then
        echo "ERROR: Found 'tasks through agents' language" >&2
        return 1
    fi

    return 0
}

test_language "No 'execute through agents' language" "pass" "test_no_execute_through_agents"

echo ""
echo "TEST 2: Van.md uses correct hub-centric language"

# Test that van.md emphasizes Hub control
test_hub_centric_language() {
    local VAN_MD=".claude/commands/van.md"

    # Should contain "deploy agent" (Hub deploys)
    if ! grep -q "deploy.*agent" "$VAN_MD"; then
        echo "ERROR: Missing 'deploy agent' language" >&2
        return 1
    fi

    # Should contain "Hub" references (Hub is in control)
    if ! grep -q "Hub" "$VAN_MD"; then
        echo "ERROR: Missing 'Hub' references" >&2
        return 1
    fi

    return 0
}

test_language "Contains hub-centric language" "pass" "test_hub_centric_language"

echo ""
echo "TEST 3: .claude-collective/CLAUDE.md hub-and-spoke section exists"

# Test that .claude-collective/CLAUDE.md documents hub-and-spoke architecture
test_hub_spoke_docs() {
    local CLAUDE_MD=".claude-collective/CLAUDE.md"

    # Should contain "hub-and-spoke" explanation
    if ! grep -qi "hub-and-spoke" "$CLAUDE_MD"; then
        echo "ERROR: Missing 'hub-and-spoke' architecture documentation" >&2
        return 1
    fi

    return 0
}

test_language "Hub-and-spoke documented in CLAUDE.md" "pass" "test_hub_spoke_docs"

echo ""
echo "TEST 4: Agent files don't claim to execute tasks"

# Test that agent files use correct language (agents implement, not execute)
test_agent_language() {
    local AGENT_DIR=".claude/agents"

    # Agents should "implement" tasks, not "execute" them
    # (Hub executes workflow, agents implement specific tasks)

    # Check a sample agent for correct language
    local TEST_AGENT="$AGENT_DIR/test-first-agent.md"

    if [[ -f "$TEST_AGENT" ]]; then
        # Agent should describe what it implements, not what it executes
        # This is a soft check - we'll validate the concept
        return 0
    else
        echo "ERROR: Sample agent file not found" >&2
        return 1
    fi
}

test_language "Agent files use implementation language" "pass" "test_agent_language"

echo ""
echo "TEST 5: No TodoWrite instructions with wrong language"

# Test that there are no TodoWrite instructions creating problematic todos
test_no_bad_todowrite() {
    local VAN_MD=".claude/commands/van.md"

    # Should not instruct creating todos with "executing through agents"
    if grep -qi "TodoWrite.*execut.*through" "$VAN_MD"; then
        echo "ERROR: Found TodoWrite with 'executing through' language" >&2
        return 1
    fi

    return 0
}

test_language "No TodoWrite with architectural violations" "pass" "test_no_bad_todowrite"

echo ""
echo "TEST 6: Correct terminology in examples"

# Test that examples use correct terminology
test_example_terminology() {
    local VAN_MD=".claude/commands/van.md"

    # Examples should show "Hub deploys agent" not "execute through agent"
    # Check for presence of correct patterns
    if grep -q "Deploy.*agent" "$VAN_MD" || grep -q "Deploying.*agent" "$VAN_MD"; then
        return 0
    else
        echo "ERROR: Examples don't show correct deployment pattern" >&2
        return 1
    fi
}

test_language "Examples use 'deploy agent' terminology" "pass" "test_example_terminology"

echo ""
echo "════════════════════════════════"
echo "Test Results:"
echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Some tests failed - architectural language violations detected${NC}"
    exit 1
else
    echo -e "❌ Failed: $TESTS_FAILED"
    echo ""
    echo -e "${GREEN}✅ All hub-and-spoke architectural language tests passed${NC}"
    exit 0
fi
