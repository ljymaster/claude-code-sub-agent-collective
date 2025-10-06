#!/bin/bash
# Smoke test: Preflight user confirmation validation
# Validates preflight script requires userConfirmed:true to prevent bypassing user questions

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "🧪 Preflight User Confirmation Smoke Test"
echo ""

# Test helper
test_preflight() {
    local description="$1"
    local json_input="$2"
    local expected_status="$3"  # "success" or "error"

    echo -n "  Testing: $description ... "

    local output
    local exit_code
    output=$(./.claude/memory/lib/preflight.sh "$json_input" 2>&1) || exit_code=$?

    local actual_status
    if echo "$output" | jq -e '.error' >/dev/null 2>&1; then
        actual_status="error"
    elif echo "$output" | jq -e '.status == "complete"' >/dev/null 2>&1; then
        actual_status="success"
    else
        actual_status="unknown"
    fi

    if [[ "$actual_status" == "$expected_status" ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED+1))
        return 0
    else
        echo -e "${RED}❌ FAIL (expected: $expected_status, got: $actual_status)${NC}"
        echo "     Output: $output"
        TESTS_FAILED=$((TESTS_FAILED+1))
        return 1
    fi
}

# Setup
setup() {
    # Save current state
    if [[ -f .claude/memory/.preflight-done ]]; then
        cp .claude/memory/.preflight-done .claude/memory/.preflight-done.backup
    fi
    if [[ -f .claude/memory/config.json ]]; then
        cp .claude/memory/config.json .claude/memory/config.json.backup
    fi
}

# Cleanup
cleanup() {
    # Restore state
    if [[ -f .claude/memory/.preflight-done.backup ]]; then
        mv .claude/memory/.preflight-done.backup .claude/memory/.preflight-done
    else
        rm -f .claude/memory/.preflight-done
    fi
    if [[ -f .claude/memory/config.json.backup ]]; then
        mv .claude/memory/config.json.backup .claude/memory/config.json
    else
        rm -f .claude/memory/config.json
    fi
}

trap cleanup EXIT

# Run tests
setup

echo "TEST 1: Deny without userConfirmed"
test_preflight "Missing userConfirmed field" '{"logging":"y","browserTesting":"y","prdPath":""}' "error"
test_preflight "userConfirmed explicitly false" '{"logging":"y","browserTesting":"y","prdPath":"","userConfirmed":false}' "error"

echo ""
echo "TEST 2: Allow with userConfirmed true"
test_preflight "userConfirmed true" '{"logging":"y","browserTesting":"n","prdPath":"","userConfirmed":true}' "success"
test_preflight "userConfirmed true with all options" '{"logging":"n","browserTesting":"y","prdPath":"test.txt","userConfirmed":true}' "success"

echo ""
echo "TEST 3: Deny empty input"
test_preflight "Empty JSON" '{}' "error"
test_preflight "Only userConfirmed (missing answers)" '{"userConfirmed":true}' "success"

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
